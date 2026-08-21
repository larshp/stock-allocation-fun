CLASS zcl_alloc_quota DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_allocation_strategy.

    "! <p class="shorttext synchronized">Hold a customer to its quota for a period</p>
    "!
    "! The customer share of feature 30 is a share of whatever happens to be
    "! available on the night, which is not what a business agrees with a
    "! customer. What it agrees is a quantity over a period: so many tonnes of
    "! this material a month, whether the month is a good one or a bad one.
    "! `ZSTOCK_ALLOC_QTA` says that, per plant, material, customer and period,
    "! and this holds the run to it.
    "!
    "! It is a quota over the demand of one allocation, not over what a customer
    "! has ever been given: a run re-cutting a material it allocated yesterday
    "! sees the same lines again, and counting yesterday's answer as well would
    "! take the quota away twice from the same orders.
    "!
    "! @parameter io_strategy | <p class="shorttext synchronized">Strategy that distributes the stock</p>
    METHODS constructor
      IMPORTING
        io_strategy TYPE REF TO zif_allocation_strategy.

    "! One quota row. Declared explicitly rather than inferred with
    "! INTO TABLE @DATA(), see ANOMALIES.md.
    TYPES:
      BEGIN OF ty_quota,
        kunnr     TYPE zstock_alloc_qta-kunnr,
        date_from TYPE zstock_alloc_qta-date_from,
        date_to   TYPE zstock_alloc_qta-date_to,
        quantity  TYPE zif_allocation=>ty_quantity,
      END OF ty_quota.
    TYPES ty_quota_tab TYPE STANDARD TABLE OF ty_quota WITH EMPTY KEY.

    "! <p class="shorttext synchronized">The quotas agreed for one material</p>
    "!
    "! Public for the reason ZCL_ALLOC_PROMISED=>PROMISED_FOR is: the
    "! explanation has to show the rows the rule acts on rather than read the
    "! table a second way of its own.
    "!
    "! @parameter iv_matnr | <p class="shorttext synchronized">Material number</p>
    "! @parameter iv_werks | <p class="shorttext synchronized">Plant</p>
    "! @parameter rt_quota | <p class="shorttext synchronized">Quota rows of the material</p>
    CLASS-METHODS quotas_for
      IMPORTING
        iv_matnr        TYPE mard-matnr
        iv_werks        TYPE mard-werks
      RETURNING
        VALUE(rt_quota) TYPE ty_quota_tab.

  PRIVATE SECTION.

    "! What is left of one quota row, kept across the days of one allocation.
    TYPES:
      BEGIN OF ty_left,
        kunnr     TYPE zstock_alloc_qta-kunnr,
        date_from TYPE zstock_alloc_qta-date_from,
        quantity  TYPE zif_allocation=>ty_quantity,
      END OF ty_left.
    TYPES ty_left_tab TYPE STANDARD TABLE OF ty_left WITH EMPTY KEY.

    "! Which period a demand line falls in, worked out once per call and read
    "! again when the answer comes back.
    TYPES:
      BEGIN OF ty_line,
        demand_id TYPE zif_allocation=>ty_demand_id,
        kunnr     TYPE zstock_alloc_qta-kunnr,
        date_from TYPE zstock_alloc_qta-date_from,
        quantity  TYPE zif_allocation=>ty_quantity,
      END OF ty_line.
    TYPES ty_line_tab TYPE STANDARD TABLE OF ty_line WITH EMPTY KEY.

    DATA mo_strategy TYPE REF TO zif_allocation_strategy.

    "! One plant's quota rows, material and all.
    TYPES:
      BEGIN OF ty_row,
        matnr     TYPE zstock_alloc_qta-matnr,
        kunnr     TYPE zstock_alloc_qta-kunnr,
        date_from TYPE zstock_alloc_qta-date_from,
        date_to   TYPE zstock_alloc_qta-date_to,
        quantity  TYPE zif_allocation=>ty_quantity,
      END OF ty_row.
    TYPES ty_row_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    "! The quotas of the whole plant, read the first time anything is
    "! allocated in it. A plant wide run asks per material, and one round trip
    "! per material for a table this size is five thousand round trips to read
    "! a page of Customizing. What bounds it is that quotas are agreed by
    "! people: a plant with more of them than fit in memory has a different
    "! problem.
    DATA mt_row   TYPE ty_row_tab.
    DATA mv_werks TYPE mard-werks.
    DATA mv_read  TYPE abap_bool.

    "! The rows of the material being allocated, out of the plant's.
    DATA mt_quota TYPE ty_quota_tab.
    DATA mv_matnr TYPE mard-matnr.

    "! What is left of each quota of the allocation that is going on, and the
    "! demand that allocation started with. The engine offers one day of supply
    "! at a time, so an allocation is several calls and a quota has to hold
    "! across all of them.
    DATA mt_left  TYPE ty_left_tab.
    DATA mv_start TYPE zif_allocation=>ty_quantity.

    METHODS quotas_of
      IMPORTING
        iv_matnr        TYPE mard-matnr
        iv_werks        TYPE mard-werks
      RETURNING
        VALUE(rt_quota) TYPE ty_quota_tab.

    METHODS start_over_if_new
      IMPORTING
        it_demand TYPE zif_allocation=>ty_demand_tab.

    METHODS total_of
      IMPORTING
        it_demand          TYPE zif_allocation=>ty_demand_tab
      RETURNING
        VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity.

    METHODS quota_for
      IMPORTING
        it_quota        TYPE ty_quota_tab
        iv_kunnr        TYPE vbak-kunnr
        iv_date         TYPE d
      RETURNING
        VALUE(rs_quota) TYPE ty_quota.

    METHODS demand_within_quota
      IMPORTING
        it_demand TYPE zif_allocation=>ty_demand_tab
        it_quota  TYPE ty_quota_tab
      EXPORTING
        et_demand TYPE zif_allocation=>ty_demand_tab
        et_line   TYPE ty_line_tab.

    METHODS take_from_quota
      IMPORTING
        it_line       TYPE ty_line_tab
        it_allocation TYPE zif_allocation=>ty_allocation_tab.

    METHODS answer_the_real_demand
      IMPORTING
        it_demand            TYPE zif_allocation=>ty_demand_tab
        it_line              TYPE ty_line_tab
        it_allocation        TYPE zif_allocation=>ty_allocation_tab
      RETURNING
        VALUE(rt_allocation) TYPE zif_allocation=>ty_allocation_tab.

ENDCLASS.


CLASS zcl_alloc_quota IMPLEMENTATION.

  METHOD constructor.
    mo_strategy = io_strategy.
  ENDMETHOD.

  METHOD zif_allocation_strategy~allocate.

    DATA lt_line    TYPE ty_line_tab.
    DATA lt_allowed TYPE zif_allocation=>ty_demand_tab.

    " every line of one call is one material in one plant: the engine allocates
    " a material at a time, which is what makes reading the quotas here cheap
    READ TABLE it_demand INTO DATA(ls_first) INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    DATA(lt_quota) = quotas_of(
      iv_matnr = ls_first-matnr
      iv_werks = ls_first-werks ).

    IF lt_quota IS INITIAL.
      rt_allocation = mo_strategy->allocate(
        iv_available = iv_available
        it_demand    = it_demand ).
      RETURN.
    ENDIF.

    start_over_if_new( it_demand ).

    demand_within_quota(
      EXPORTING
        it_demand = it_demand
        it_quota  = lt_quota
      IMPORTING
        et_demand = lt_allowed
        et_line   = lt_line ).

    DATA(lt_answer) = mo_strategy->allocate(
      iv_available = iv_available
      it_demand    = lt_allowed ).

    " what a customer really got is what comes off its quota: a line that was
    " allowed thirty and confirmed ten because the stock ran out has not used
    " twenty of anything
    take_from_quota(
      it_line       = lt_line
      it_allocation = lt_answer ).

    rt_allocation = answer_the_real_demand(
      it_demand     = it_demand
      it_line       = lt_line
      it_allocation = lt_answer ).

  ENDMETHOD.

  METHOD quotas_for.

    " the rows of the material in this plant, whether they name a customer or
    " apply to all of them. Which of the two wins is decided per line in the
    " rule, because a customer with a quota of its own is not also part of the
    " quota everybody shares.
    SELECT kunnr,
           date_from,
           date_to,
           quantity
      FROM zstock_alloc_qta
      WHERE werks = @iv_werks
        AND matnr = @iv_matnr
      ORDER BY kunnr, date_from
      INTO TABLE @rt_quota.
    IF sy-subrc <> 0.
      CLEAR rt_quota.
    ENDIF.

  ENDMETHOD.

  METHOD quotas_of.

    DATA ls_quota TYPE ty_quota.

    IF mv_read = abap_true AND mv_matnr = iv_matnr AND mv_werks = iv_werks.
      rt_quota = mt_quota.
      RETURN.
    ENDIF.

    IF mv_read = abap_false OR mv_werks <> iv_werks.
      SELECT matnr,
             kunnr,
             date_from,
             date_to,
             quantity
        FROM zstock_alloc_qta
        WHERE werks = @iv_werks
        ORDER BY matnr, kunnr, date_from
        INTO TABLE @mt_row.
      IF sy-subrc <> 0.
        CLEAR mt_row.
      ENDIF.
    ENDIF.

    LOOP AT mt_row INTO DATA(ls_row)
        WHERE matnr = iv_matnr.
      ls_quota-kunnr     = ls_row-kunnr.
      ls_quota-date_from = ls_row-date_from.
      ls_quota-date_to   = ls_row-date_to.
      ls_quota-quantity  = ls_row-quantity.
      APPEND ls_quota TO rt_quota.
    ENDLOOP.

    mt_quota = rt_quota.
    mv_matnr = iv_matnr.
    mv_werks = iv_werks.
    mv_read  = abap_true.

    " another material is another allocation, whatever was left of the one
    " before it
    CLEAR mt_left.
    CLEAR mv_start.

  ENDMETHOD.

  METHOD start_over_if_new.

    " the engine walks the days of supply and asks once per day, each time with
    " what is left of the demand, so a quota has to be spent across the whole
    " walk rather than granted again every morning.
    "
    " What tells one walk from the next is that the demand has not shrunk: a
    " line only ever gets smaller while an allocation is under way, once
    " something has been confirmed for it. Demand that is back to what the walk
    " started with, or above it, is a new walk -- and if it is not, nothing has
    " been confirmed yet either, so there is nothing to start over from.
    DATA(lv_total) = total_of( it_demand ).

    IF lv_total < mv_start.
      RETURN.
    ENDIF.

    CLEAR mt_left.
    mv_start = lv_total.

  ENDMETHOD.

  METHOD total_of.

    LOOP AT it_demand INTO DATA(ls_demand).
      IF ls_demand-quantity > 0.
        rv_quantity = rv_quantity + ls_demand-quantity.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD quota_for.

    " the customer's own row first, the row for everybody second: a quota
    " agreed with one customer replaces the house rule rather than being
    " served on top of it
    LOOP AT it_quota INTO DATA(ls_quota)
        WHERE kunnr = iv_kunnr.
      IF iv_date >= ls_quota-date_from AND iv_date <= ls_quota-date_to.
        rs_quota = ls_quota.
        RETURN.
      ENDIF.
    ENDLOOP.

    LOOP AT it_quota INTO DATA(ls_house)
        WHERE kunnr IS INITIAL.
      IF iv_date >= ls_house-date_from AND iv_date <= ls_house-date_to.
        rs_quota       = ls_house.
        rs_quota-kunnr = iv_kunnr.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD demand_within_quota.

    DATA ls_line TYPE ty_line.
    DATA lv_take TYPE zif_allocation=>ty_quantity.
    DATA lv_left TYPE zif_allocation=>ty_quantity.

    " the lines of a customer are cut back from the far end, in the order the
    " strategies serve demand, so what a customer loses to its quota is its
    " least urgent lines rather than a shaving off every one of them. Same
    " reasoning as ZCL_ALLOC_CUSTOMER_CAP.
    DATA(lt_sorted) = it_demand.
    SORT lt_sorted BY customer ASCENDING
                     priority ASCENDING
                     req_date ASCENDING
                     demand_id ASCENDING.

    DATA(lt_spent) = mt_left.

    LOOP AT lt_sorted INTO DATA(ls_demand).

      CLEAR ls_line.
      ls_line-demand_id = ls_demand-demand_id.
      ls_line-quantity  = ls_demand-quantity.

      " a requirement with no customer has no quota: a stock transport order
      " is not a customer, which is the line every rule here draws
      IF ls_demand-customer IS INITIAL OR ls_demand-quantity <= 0.
        APPEND ls_demand TO et_demand.
        APPEND ls_line TO et_line.
        CONTINUE.
      ENDIF.

      DATA(ls_quota) = quota_for(
        it_quota = it_quota
        iv_kunnr = ls_demand-customer
        iv_date  = ls_demand-req_date ).

      " a line outside every period is outside every quota: a quota says what
      " a customer may take in the months it covers and nothing at all about
      " the months it does not
      IF ls_quota-date_from IS INITIAL.
        APPEND ls_demand TO et_demand.
        APPEND ls_line TO et_line.
        CONTINUE.
      ENDIF.

      READ TABLE lt_spent INTO DATA(ls_spent)
        WITH KEY kunnr     = ls_quota-kunnr
                 date_from = ls_quota-date_from.
      IF sy-subrc = 0.
        lv_left = ls_spent-quantity.
      ELSE.
        " the first day of the allocation that this quota is asked about: it
        " is remembered here, untouched, and spent when the strategy answers
        lv_left            = ls_quota-quantity.
        ls_spent-kunnr     = ls_quota-kunnr.
        ls_spent-date_from = ls_quota-date_from.
        ls_spent-quantity  = lv_left.
        APPEND ls_spent TO lt_spent.
        APPEND ls_spent TO mt_left.
      ENDIF.

      lv_take = ls_demand-quantity.
      IF lv_take > lv_left.
        lv_take = lv_left.
      ENDIF.
      IF lv_take < 0.
        CLEAR lv_take.
      ENDIF.

      " a line held back entirely stays in the demand with nothing to ask for,
      " so the strategy still answers it and the answer covers every line
      ls_demand-quantity = lv_take.
      APPEND ls_demand TO et_demand.

      ls_line-kunnr     = ls_quota-kunnr.
      ls_line-date_from = ls_quota-date_from.
      ls_line-quantity  = lv_take.
      APPEND ls_line TO et_line.

      " within one call the lines of a customer share what is left, so what
      " this line may take is off the table for the next one. What is really
      " spent is settled once the strategy has answered.
      ls_spent-quantity = lv_left - lv_take.
      MODIFY lt_spent FROM ls_spent
        TRANSPORTING quantity
        WHERE kunnr     = ls_spent-kunnr
          AND date_from = ls_spent-date_from.

    ENDLOOP.

  ENDMETHOD.

  METHOD take_from_quota.

    DATA ls_left TYPE ty_left.

    LOOP AT it_allocation INTO DATA(ls_answer).

      IF ls_answer-confirmed <= 0.
        CONTINUE.
      ENDIF.

      READ TABLE it_line INTO DATA(ls_line)
        WITH KEY demand_id = ls_answer-demand_id.
      IF sy-subrc <> 0 OR ls_line-date_from IS INITIAL.
        CONTINUE.
      ENDIF.

      READ TABLE mt_left INTO ls_left
        WITH KEY kunnr     = ls_line-kunnr
                 date_from = ls_line-date_from.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      ls_left-quantity = ls_left-quantity - ls_answer-confirmed.
      IF ls_left-quantity < 0.
        CLEAR ls_left-quantity.
      ENDIF.

      MODIFY mt_left FROM ls_left
        TRANSPORTING quantity
        WHERE kunnr     = ls_left-kunnr
          AND date_from = ls_left-date_from.

    ENDLOOP.

  ENDMETHOD.

  METHOD answer_the_real_demand.

    DATA lv_requested TYPE zif_allocation=>ty_quantity.
    DATA lv_allowed   TYPE zif_allocation=>ty_quantity.

    " the strategy answered a demand that was cut back, and the answer has to
    " be about the demand as the orders have it: what a line asked for is what
    " was ordered, and the part it did not get is short whether the quota or
    " the stock stopped it
    LOOP AT it_allocation INTO DATA(ls_line).

      IF NOT line_exists( it_demand[ demand_id = ls_line-demand_id ] ).
        APPEND ls_line TO rt_allocation.
        CONTINUE.
      ENDIF.

      lv_requested      = it_demand[ demand_id = ls_line-demand_id ]-quantity.
      ls_line-requested = lv_requested.
      ls_line-shortfall = COND #( WHEN lv_requested > ls_line-confirmed
                                  THEN lv_requested - ls_line-confirmed
                                  ELSE 0 ).

      IF ls_line-shortfall > 0
          AND line_exists( it_line[ demand_id = ls_line-demand_id ] ).
        lv_allowed = it_line[ demand_id = ls_line-demand_id ]-quantity.
        IF ls_line-confirmed >= lv_allowed.
          ls_line-reason = zif_allocation=>c_reason-quota.
        ENDIF.
      ENDIF.

      APPEND ls_line TO rt_allocation.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
