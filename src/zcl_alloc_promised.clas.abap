CLASS zcl_alloc_promised DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_allocation_strategy.

    "! <p class="shorttext synchronized">Serve what somebody promised by hand first</p>
    "!
    "! Every rule here is a rule about the ordinary night. What a business also
    "! has is the extraordinary one: a director has promised a customer a
    "! hundred pieces, and the run is going to distribute them by delivery
    "! priority to somebody else. Without somewhere to put that, it is done by
    "! reserving the stock in MB21 behind the run's back, where the allocation
    "! cannot see it and the next re-cut fights it.
    "!
    "! `ZSTOCK_ALLOC_FIX` is that somewhere: a quantity, a demand line, and who
    "! promised it. It is taken off the top before the distribution rules see
    "! the stock, so a promise is not cut back by the customer share or by a
    "! quota -- the point of a promise is that it outranks the rules.
    "!
    "! @parameter io_strategy | <p class="shorttext synchronized">Strategy that distributes what is left</p>
    METHODS constructor
      IMPORTING
        io_strategy TYPE REF TO zif_allocation_strategy.

  PRIVATE SECTION.

    "! One promise. Declared explicitly rather than inferred with
    "! INTO TABLE @DATA(), see ANOMALIES.md.
    TYPES:
      BEGIN OF ty_promise,
        demand_id TYPE zstock_alloc_fix-demand_id,
        quantity  TYPE zif_allocation=>ty_quantity,
      END OF ty_promise.
    TYPES ty_promise_tab TYPE STANDARD TABLE OF ty_promise WITH EMPTY KEY.

    DATA mo_strategy TYPE REF TO zif_allocation_strategy.

    "! The promises of one material, read the first time it is allocated.
    DATA mt_promise TYPE ty_promise_tab.
    DATA mv_matnr   TYPE mard-matnr.
    DATA mv_werks   TYPE mard-werks.
    DATA mv_read    TYPE abap_bool.

    "! What is left of each promise, and the demand the allocation started
    "! with: the engine walks the days of supply and asks once per day, so a
    "! promise has to be handed over across the whole walk rather than granted
    "! again every morning. Same reasoning, and the same way of telling one
    "! walk from the next, as ZCL_ALLOC_QUOTA.
    DATA mt_left  TYPE ty_promise_tab.
    DATA mv_start TYPE zif_allocation=>ty_quantity.

    METHODS promises_of
      IMPORTING
        iv_matnr          TYPE mard-matnr
        iv_werks          TYPE mard-werks
      RETURNING
        VALUE(rt_promise) TYPE ty_promise_tab.

    METHODS start_over_if_new
      IMPORTING
        it_demand TYPE zif_allocation=>ty_demand_tab.

    METHODS handed_over
      IMPORTING
        it_demand    TYPE zif_allocation=>ty_demand_tab
        iv_available TYPE zif_allocation=>ty_quantity
      EXPORTING
        et_given     TYPE ty_promise_tab
        ev_left      TYPE zif_allocation=>ty_quantity.

    METHODS demand_less_promises
      IMPORTING
        it_demand        TYPE zif_allocation=>ty_demand_tab
        it_given         TYPE ty_promise_tab
      RETURNING
        VALUE(rt_demand) TYPE zif_allocation=>ty_demand_tab.

    METHODS answer_with_promises
      IMPORTING
        it_demand            TYPE zif_allocation=>ty_demand_tab
        it_given             TYPE ty_promise_tab
        it_allocation        TYPE zif_allocation=>ty_allocation_tab
      RETURNING
        VALUE(rt_allocation) TYPE zif_allocation=>ty_allocation_tab.

ENDCLASS.


CLASS zcl_alloc_promised IMPLEMENTATION.

  METHOD constructor.
    mo_strategy = io_strategy.
  ENDMETHOD.

  METHOD zif_allocation_strategy~allocate.

    DATA lt_given TYPE ty_promise_tab.
    DATA lv_left  TYPE zif_allocation=>ty_quantity.

    READ TABLE it_demand INTO DATA(ls_first) INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    DATA(lt_promise) = promises_of(
      iv_matnr = ls_first-matnr
      iv_werks = ls_first-werks ).

    IF lt_promise IS INITIAL.
      rt_allocation = mo_strategy->allocate(
        iv_available = iv_available
        it_demand    = it_demand ).
      RETURN.
    ENDIF.

    start_over_if_new( it_demand ).

    handed_over(
      EXPORTING
        it_demand    = it_demand
        iv_available = iv_available
      IMPORTING
        et_given     = lt_given
        ev_left      = lv_left ).

    " what is left of the stock is distributed by the rules, over demand that
    " no longer includes what has just been handed over
    rt_allocation = answer_with_promises(
      it_demand     = it_demand
      it_given      = lt_given
      it_allocation = mo_strategy->allocate(
        iv_available = lv_left
        it_demand    = demand_less_promises(
          it_demand = it_demand
          it_given  = lt_given ) ) ).

  ENDMETHOD.

  METHOD promises_of.

    IF mv_read = abap_true AND mv_matnr = iv_matnr AND mv_werks = iv_werks.
      rt_promise = mt_promise.
      RETURN.
    ENDIF.

    SELECT demand_id,
           quantity
      FROM zstock_alloc_fix
      WHERE werks = @iv_werks
        AND matnr = @iv_matnr
      ORDER BY demand_id
      INTO TABLE @rt_promise.
    IF sy-subrc <> 0.
      CLEAR rt_promise.
    ENDIF.

    mt_promise = rt_promise.
    mv_matnr   = iv_matnr.
    mv_werks   = iv_werks.
    mv_read    = abap_true.

    " another material is another allocation, whatever was left of the one
    " before it
    CLEAR mt_left.
    CLEAR mv_start.

  ENDMETHOD.

  METHOD start_over_if_new.

    DATA lv_total TYPE zif_allocation=>ty_quantity.

    LOOP AT it_demand INTO DATA(ls_demand).
      IF ls_demand-quantity > 0.
        lv_total = lv_total + ls_demand-quantity.
      ENDIF.
    ENDLOOP.

    IF lv_total < mv_start.
      RETURN.
    ENDIF.

    mt_left  = mt_promise.
    mv_start = lv_total.

  ENDMETHOD.

  METHOD handed_over.

    DATA ls_left TYPE ty_promise.
    DATA ls_give TYPE ty_promise.
    DATA lv_take TYPE zif_allocation=>ty_quantity.

    ev_left = iv_available.

    LOOP AT it_demand INTO DATA(ls_demand).

      READ TABLE mt_left INTO ls_left
        WITH KEY demand_id = ls_demand-demand_id.
      IF sy-subrc <> 0 OR ls_left-quantity <= 0.
        CONTINUE.
      ENDIF.

      " a promise is a promise about a line, so it cannot hand over more than
      " the line still asks for, and it cannot hand over stock that is not
      " there: what it does is decide who gets it first
      lv_take = ls_left-quantity.
      IF lv_take > ls_demand-quantity.
        lv_take = ls_demand-quantity.
      ENDIF.
      IF lv_take > ev_left.
        lv_take = ev_left.
      ENDIF.
      IF lv_take <= 0.
        CONTINUE.
      ENDIF.

      ls_give-demand_id = ls_demand-demand_id.
      ls_give-quantity  = lv_take.
      APPEND ls_give TO et_given.

      ev_left = ev_left - lv_take.

      ls_left-quantity = ls_left-quantity - lv_take.
      MODIFY mt_left FROM ls_left
        TRANSPORTING quantity
        WHERE demand_id = ls_left-demand_id.

    ENDLOOP.

  ENDMETHOD.

  METHOD demand_less_promises.

    LOOP AT it_demand INTO DATA(ls_demand).

      READ TABLE it_given INTO DATA(ls_given)
        WITH KEY demand_id = ls_demand-demand_id.
      IF sy-subrc = 0.
        ls_demand-quantity = ls_demand-quantity - ls_given-quantity.
        IF ls_demand-quantity < 0.
          CLEAR ls_demand-quantity.
        ENDIF.
      ENDIF.

      APPEND ls_demand TO rt_demand.

    ENDLOOP.

  ENDMETHOD.

  METHOD answer_with_promises.

    DATA lv_requested TYPE zif_allocation=>ty_quantity.
    DATA ls_line      TYPE zif_allocation=>ty_allocation.

    " the rules answered a demand that had the promises taken out of it, and
    " the answer has to be about the demand as the orders have it: what a line
    " asked for is what was ordered, and what it got is the promise plus
    " whatever the rules then gave it
    LOOP AT it_allocation INTO ls_line.

      READ TABLE it_given INTO DATA(ls_given)
        WITH KEY demand_id = ls_line-demand_id.
      IF sy-subrc = 0.
        ls_line-confirmed = ls_line-confirmed + ls_given-quantity.
        " a line that got its promise was not held back by a rule that only
        " looked at the rest of it
        CLEAR ls_line-reason.
      ENDIF.

      IF line_exists( it_demand[ demand_id = ls_line-demand_id ] ).
        lv_requested      = it_demand[ demand_id = ls_line-demand_id ]-quantity.
        ls_line-requested = lv_requested.
        ls_line-shortfall = COND #( WHEN lv_requested > ls_line-confirmed
                                    THEN lv_requested - ls_line-confirmed
                                    ELSE 0 ).
      ENDIF.

      APPEND ls_line TO rt_allocation.

    ENDLOOP.

    " a line the rules never answered because nothing was left of it for them
    " still has its promise, and every line has to be answered exactly once
    LOOP AT it_given INTO ls_given.

      IF line_exists( rt_allocation[ demand_id = ls_given-demand_id ] ).
        CONTINUE.
      ENDIF.

      CLEAR ls_line.
      ls_line-demand_id = ls_given-demand_id.
      ls_line-confirmed = ls_given-quantity.

      IF line_exists( it_demand[ demand_id = ls_given-demand_id ] ).
        DATA(ls_demand)    = it_demand[ demand_id = ls_given-demand_id ].
        ls_line-requested  = ls_demand-quantity.
        ls_line-req_date   = ls_demand-req_date.
        ls_line-customer   = ls_demand-customer.
        ls_line-shortfall  = COND #( WHEN ls_demand-quantity > ls_line-confirmed
                                     THEN ls_demand-quantity - ls_line-confirmed
                                     ELSE 0 ).
      ENDIF.

      APPEND ls_line TO rt_allocation.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
