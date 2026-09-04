CLASS zcl_alloc_customer_cap DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_allocation_strategy.

    "! No cap at all, which is what a plant gets until it asks for one.
    CONSTANTS c_no_cap TYPE i VALUE 0.

    "! <p class="shorttext synchronized">Stop one customer taking the whole pool</p>
    "!
    "! A single large order can otherwise take everything a plant has, however
    "! the stock is then distributed. This offers the strategy at most a share of
    "! what is available per customer, so the rest is still there for everybody
    "! else. Within its share a customer is served in the order the strategies
    "! serve demand, so what it loses is its least urgent lines rather than a
    "! slice off every one of them.
    "!
    "! @parameter io_strategy | <p class="shorttext synchronized">Strategy that distributes the stock</p>
    "! @parameter iv_percent  | <p class="shorttext synchronized">Most one customer may take, 0 for no cap</p>
    METHODS constructor
      IMPORTING
        io_strategy TYPE REF TO zif_allocation_strategy
        iv_percent  TYPE i DEFAULT c_no_cap.

  PRIVATE SECTION.

    "! The cap is worked out in whole thousandths and divided with DIV, which
    "! truncates: a percentage of the pool must never come out above it. Same
    "! technique as ZCL_ALLOC_STRATEGY_FAIRSHARE, for the same reason.
    TYPES ty_thousandths TYPE p LENGTH 16 DECIMALS 0.

    CONSTANTS c_thousandth TYPE zif_allocation=>ty_quantity VALUE '0.001'.
    CONSTANTS c_percent    TYPE i VALUE 100.

    DATA mo_strategy TYPE REF TO zif_allocation_strategy.
    DATA mv_percent  TYPE i.

    METHODS cap_quantity
      IMPORTING
        iv_available  TYPE zif_allocation=>ty_quantity
      RETURNING
        VALUE(rv_cap) TYPE zif_allocation=>ty_quantity.

    METHODS capped_demand
      IMPORTING
        it_demand        TYPE zif_allocation=>ty_demand_tab
        iv_cap           TYPE zif_allocation=>ty_quantity
      RETURNING
        VALUE(rt_demand) TYPE zif_allocation=>ty_demand_tab.

    METHODS answer_the_real_demand
      IMPORTING
        it_demand            TYPE zif_allocation=>ty_demand_tab
        it_capped            TYPE zif_allocation=>ty_demand_tab
        it_allocation        TYPE zif_allocation=>ty_allocation_tab
      RETURNING
        VALUE(rt_allocation) TYPE zif_allocation=>ty_allocation_tab.

ENDCLASS.


CLASS zcl_alloc_customer_cap IMPLEMENTATION.

  METHOD constructor.

    mo_strategy = io_strategy.
    mv_percent  = iv_percent.

  ENDMETHOD.

  METHOD zif_allocation_strategy~allocate.

    " a cap of a hundred percent or more is no cap, and neither is one on
    " nothing: both go straight to the strategy, demand untouched
    IF mv_percent <= c_no_cap OR mv_percent >= c_percent OR iv_available <= 0.
      rt_allocation = mo_strategy->allocate(
        iv_available = iv_available
        it_demand    = it_demand ).
      RETURN.
    ENDIF.

    DATA(lt_capped) = capped_demand(
      it_demand = it_demand
      iv_cap    = cap_quantity( iv_available ) ).

    rt_allocation = answer_the_real_demand(
      it_demand     = it_demand
      it_capped     = lt_capped
      it_allocation = mo_strategy->allocate(
        iv_available = iv_available
        it_demand    = lt_capped ) ).

  ENDMETHOD.

  METHOD cap_quantity.

    DATA lv_thousandths TYPE ty_thousandths.

    IF iv_available <= 0.
      RETURN.
    ENDIF.

    lv_thousandths = ( iv_available * 1000 * mv_percent ) DIV c_percent.
    rv_cap         = lv_thousandths * c_thousandth.

  ENDMETHOD.

  METHOD capped_demand.

    DATA lv_customer TYPE vbak-kunnr.
    DATA lv_left     TYPE zif_allocation=>ty_quantity.
    DATA lv_take     TYPE zif_allocation=>ty_quantity.

    " within a customer the lines are cut back from the far end, in the order
    " the strategies serve demand, so a customer keeps its urgent lines whole
    " instead of getting a shaving off each of them
    DATA(lt_sorted) = it_demand.
    SORT lt_sorted BY customer ASCENDING
                     priority ASCENDING
                     req_date ASCENDING
                     demand_id ASCENDING.

    LOOP AT lt_sorted INTO DATA(ls_demand).

      " demand that belongs to no customer is not part of anybody's share: a
      " stock transport order is not a customer, and lumping every requirement
      " without one together would cap them as if they were the same party
      IF ls_demand-customer IS INITIAL OR ls_demand-quantity <= 0.
        APPEND ls_demand TO rt_demand.
        CONTINUE.
      ENDIF.

      IF ls_demand-customer <> lv_customer.
        lv_customer = ls_demand-customer.
        lv_left     = iv_cap.
      ENDIF.

      lv_take = ls_demand-quantity.
      IF lv_take > lv_left.
        lv_take = lv_left.
      ENDIF.

      " a line held back entirely stays in the demand with nothing to ask for,
      " so the strategy still answers it and the answer covers every line
      ls_demand-quantity = lv_take.
      lv_left            = lv_left - lv_take.

      APPEND ls_demand TO rt_demand.

    ENDLOOP.

  ENDMETHOD.

  METHOD answer_the_real_demand.

    DATA lv_requested TYPE zif_allocation=>ty_quantity.
    DATA lv_allowed   TYPE zif_allocation=>ty_quantity.

    " the strategy answered a demand that was cut back, but the answer is about
    " the demand as it stands: what a line asked for is what the order says, and
    " the part it did not get is short whether the cap or the stock stopped it
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

      " a line that got everything its share allowed and still asked for more
      " was stopped by the cap, not by the stock: there was some left, its
      " customer had simply had their share of it
      IF ls_line-shortfall > 0
          AND line_exists( it_capped[ demand_id = ls_line-demand_id ] ).
        lv_allowed = it_capped[ demand_id = ls_line-demand_id ]-quantity.
        IF ls_line-confirmed >= lv_allowed.
          ls_line-reason = zif_allocation=>c_reason-customer_cap.
        ENDIF.
      ENDIF.

      APPEND ls_line TO rt_allocation.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
