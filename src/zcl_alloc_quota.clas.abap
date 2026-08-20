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

  PRIVATE SECTION.

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

    "! What is left of one quota row while the demand is walked through.
    TYPES:
      BEGIN OF ty_left,
        kunnr     TYPE zstock_alloc_qta-kunnr,
        date_from TYPE zstock_alloc_qta-date_from,
        quantity  TYPE zif_allocation=>ty_quantity,
      END OF ty_left.
    TYPES ty_left_tab TYPE STANDARD TABLE OF ty_left WITH EMPTY KEY.

    DATA mo_strategy TYPE REF TO zif_allocation_strategy.

    "! The quotas of one material, read the first time it is allocated and kept
    "! for as long as the object lives: a run allocates a material once.
    DATA mt_quota TYPE ty_quota_tab.
    DATA mv_matnr TYPE mard-matnr.
    DATA mv_werks TYPE mard-werks.
    DATA mv_read  TYPE abap_bool.

    METHODS quotas_of
      IMPORTING
        iv_matnr        TYPE mard-matnr
        iv_werks        TYPE mard-werks
      RETURNING
        VALUE(rt_quota) TYPE ty_quota_tab.

    METHODS quota_for
      IMPORTING
        it_quota        TYPE ty_quota_tab
        iv_kunnr        TYPE vbak-kunnr
        iv_date         TYPE d
      RETURNING
        VALUE(rs_quota) TYPE ty_quota.

    METHODS demand_within_quota
      IMPORTING
        it_demand        TYPE zif_allocation=>ty_demand_tab
        it_quota         TYPE ty_quota_tab
      RETURNING
        VALUE(rt_demand) TYPE zif_allocation=>ty_demand_tab.

    METHODS answer_the_real_demand
      IMPORTING
        it_demand            TYPE zif_allocation=>ty_demand_tab
        it_allowed           TYPE zif_allocation=>ty_demand_tab
        it_allocation        TYPE zif_allocation=>ty_allocation_tab
      RETURNING
        VALUE(rt_allocation) TYPE zif_allocation=>ty_allocation_tab.

ENDCLASS.


CLASS zcl_alloc_quota IMPLEMENTATION.

  METHOD constructor.
    mo_strategy = io_strategy.
  ENDMETHOD.

  METHOD zif_allocation_strategy~allocate.

    IF it_demand IS INITIAL.
      RETURN.
    ENDIF.

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

    DATA(lt_allowed) = demand_within_quota(
      it_demand = it_demand
      it_quota  = lt_quota ).

    rt_allocation = answer_the_real_demand(
      it_demand     = it_demand
      it_allowed    = lt_allowed
      it_allocation = mo_strategy->allocate(
        iv_available = iv_available
        it_demand    = lt_allowed ) ).

  ENDMETHOD.

  METHOD quotas_of.

    IF mv_read = abap_true AND mv_matnr = iv_matnr AND mv_werks = iv_werks.
      rt_quota = mt_quota.
      RETURN.
    ENDIF.

    " the rows of the material in this plant, whether they name a customer or
    " apply to all of them. Which of the two wins is decided per line below,
    " because a customer with a quota of its own is not also part of the
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

    mt_quota = rt_quota.
    mv_matnr = iv_matnr.
    mv_werks = iv_werks.
    mv_read  = abap_true.

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
        rs_quota = ls_house.
        rs_quota-kunnr = iv_kunnr.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD demand_within_quota.

    DATA lt_left TYPE ty_left_tab.
    DATA ls_left TYPE ty_left.
    DATA lv_take TYPE zif_allocation=>ty_quantity.

    " the lines of a customer are cut back from the far end, in the order the
    " strategies serve demand, so what a customer loses to its quota is its
    " least urgent lines rather than a shaving off every one of them. Same
    " reasoning as ZCL_ALLOC_CUSTOMER_CAP.
    DATA(lt_sorted) = it_demand.
    SORT lt_sorted BY customer ASCENDING
                     priority ASCENDING
                     req_date ASCENDING
                     demand_id ASCENDING.

    LOOP AT lt_sorted INTO DATA(ls_demand).

      " a requirement with no customer has no quota: a stock transport order
      " is not a customer, which is the line every rule here draws
      IF ls_demand-customer IS INITIAL OR ls_demand-quantity <= 0.
        APPEND ls_demand TO rt_demand.
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
        APPEND ls_demand TO rt_demand.
        CONTINUE.
      ENDIF.

      READ TABLE lt_left INTO ls_left
        WITH KEY kunnr     = ls_demand-customer
                 date_from = ls_quota-date_from.
      IF sy-subrc <> 0.
        ls_left-kunnr     = ls_demand-customer.
        ls_left-date_from = ls_quota-date_from.
        ls_left-quantity  = ls_quota-quantity.
        APPEND ls_left TO lt_left.
      ENDIF.

      lv_take = ls_demand-quantity.
      IF lv_take > ls_left-quantity.
        lv_take = ls_left-quantity.
      ENDIF.
      IF lv_take < 0.
        CLEAR lv_take.
      ENDIF.

      " a line held back entirely stays in the demand with nothing to ask for,
      " so the strategy still answers it and the answer covers every line
      ls_demand-quantity = lv_take.
      APPEND ls_demand TO rt_demand.

      ls_left-quantity = ls_left-quantity - lv_take.
      MODIFY lt_left FROM ls_left
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
          AND line_exists( it_allowed[ demand_id = ls_line-demand_id ] ).
        lv_allowed = it_allowed[ demand_id = ls_line-demand_id ]-quantity.
        IF ls_line-confirmed >= lv_allowed.
          ls_line-reason = zif_allocation=>c_reason-quota.
        ENDIF.
      ENDIF.

      APPEND ls_line TO rt_allocation.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
