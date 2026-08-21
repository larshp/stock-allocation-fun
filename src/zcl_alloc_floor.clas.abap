CLASS zcl_alloc_floor DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_allocation_strategy.

    "! <p class="shorttext synchronized">Hand a line its quantity before the rules run</p>
    "!
    "! Some quantities are decided before the distribution rules are asked
    "! anything: a promise somebody made by hand, a delivery that is loading
    "! tomorrow. What they have in common is the mechanics -- take the
    "! quantity off the top, take it out of the demand the rules then see, and
    "! add it back to the answer so that every line is answered exactly once
    "! with the quantity its order really asked for.
    "!
    "! That mechanics is here, once, and what is handed over comes from a
    "! source. Two copies of it would drift, and the copy that drifted would
    "! confirm quantities nobody can explain.
    "!
    "! @parameter io_strategy | <p class="shorttext synchronized">Strategy that distributes what is left</p>
    "! @parameter io_floor    | <p class="shorttext synchronized">Says what is handed over first</p>
    METHODS constructor
      IMPORTING
        io_strategy TYPE REF TO zif_allocation_strategy
        io_floor    TYPE REF TO zif_alloc_floor.

  PRIVATE SECTION.

    DATA mo_strategy TYPE REF TO zif_allocation_strategy.
    DATA mo_floor    TYPE REF TO zif_alloc_floor.

    "! What is left of each floor, and the demand the allocation started with:
    "! the engine walks the days of supply and asks once per day, so a floor
    "! has to be handed over across the whole walk rather than granted again
    "! every morning. Same way of telling one walk from the next as
    "! ZCL_ALLOC_QUOTA.
    DATA mt_left  TYPE zif_alloc_floor=>ty_floor_tab.
    DATA mv_start TYPE zif_allocation=>ty_quantity.

    "! Which material the walk is of. A run allocates every material in the
    "! plant through the same strategy chain, and what is left of one
    "! material's floors means nothing for the next one.
    DATA mv_matnr TYPE mard-matnr.
    DATA mv_werks TYPE mard-werks.

    METHODS start_over_if_new
      IMPORTING
        it_demand TYPE zif_allocation=>ty_demand_tab
        it_floor  TYPE zif_alloc_floor=>ty_floor_tab.

    METHODS handed_over
      IMPORTING
        it_demand    TYPE zif_allocation=>ty_demand_tab
        iv_available TYPE zif_allocation=>ty_quantity
      EXPORTING
        et_given     TYPE zif_alloc_floor=>ty_floor_tab
        ev_left      TYPE zif_allocation=>ty_quantity.

    METHODS demand_less_floors
      IMPORTING
        it_demand        TYPE zif_allocation=>ty_demand_tab
        it_given         TYPE zif_alloc_floor=>ty_floor_tab
      RETURNING
        VALUE(rt_demand) TYPE zif_allocation=>ty_demand_tab.

    METHODS answer_with_floors
      IMPORTING
        it_demand            TYPE zif_allocation=>ty_demand_tab
        it_given             TYPE zif_alloc_floor=>ty_floor_tab
        it_allocation        TYPE zif_allocation=>ty_allocation_tab
      RETURNING
        VALUE(rt_allocation) TYPE zif_allocation=>ty_allocation_tab.

ENDCLASS.


CLASS zcl_alloc_floor IMPLEMENTATION.

  METHOD constructor.

    mo_strategy = io_strategy.
    mo_floor    = io_floor.

  ENDMETHOD.

  METHOD zif_allocation_strategy~allocate.

    DATA lt_given TYPE zif_alloc_floor=>ty_floor_tab.
    DATA lv_left  TYPE zif_allocation=>ty_quantity.

    DATA(lt_floor) = mo_floor->floors_for( it_demand ).

    IF lt_floor IS INITIAL.
      rt_allocation = mo_strategy->allocate(
        iv_available = iv_available
        it_demand    = it_demand ).
      RETURN.
    ENDIF.

    start_over_if_new(
      it_demand = it_demand
      it_floor  = lt_floor ).

    handed_over(
      EXPORTING
        it_demand    = it_demand
        iv_available = iv_available
      IMPORTING
        et_given     = lt_given
        ev_left      = lv_left ).

    " what is left of the stock is distributed by the rules, over demand that
    " no longer includes what has just been handed over
    rt_allocation = answer_with_floors(
      it_demand     = it_demand
      it_given      = lt_given
      it_allocation = mo_strategy->allocate(
        iv_available = lv_left
        it_demand    = demand_less_floors(
          it_demand = it_demand
          it_given  = lt_given ) ) ).

  ENDMETHOD.

  METHOD start_over_if_new.

    DATA lv_total TYPE zif_allocation=>ty_quantity.
    DATA lv_new   TYPE abap_bool.

    LOOP AT it_demand INTO DATA(ls_demand).
      IF ls_demand-quantity > 0.
        lv_total = lv_total + ls_demand-quantity.
      ENDIF.
    ENDLOOP.

    " a run allocates every material in the plant through this same chain, and
    " what is left of one material's floors means nothing for the next one --
    " which the demand total cannot tell us, because the next material may
    " well be asked for less than this one was
    READ TABLE it_demand INTO DATA(ls_first) INDEX 1.
    IF sy-subrc = 0 AND ( ls_first-matnr <> mv_matnr OR ls_first-werks <> mv_werks ).
      lv_new   = abap_true.
      mv_matnr = ls_first-matnr.
      mv_werks = ls_first-werks.
    ENDIF.

    " the demand shrinks as the walk goes on, so a total at least as big as
    " the one the walk started with is a new walk
    IF lv_new = abap_false AND lv_total < mv_start.
      RETURN.
    ENDIF.

    mt_left  = it_floor.
    mv_start = lv_total.

  ENDMETHOD.

  METHOD handed_over.

    DATA ls_left TYPE zif_alloc_floor=>ty_floor.
    DATA ls_give TYPE zif_alloc_floor=>ty_floor.
    DATA lv_take TYPE zif_allocation=>ty_quantity.

    ev_left = iv_available.

    LOOP AT it_demand INTO DATA(ls_demand).

      READ TABLE mt_left INTO ls_left
        WITH KEY demand_id = ls_demand-demand_id.
      IF sy-subrc <> 0 OR ls_left-quantity <= 0.
        CONTINUE.
      ENDIF.

      " a floor is a floor under a line, so it cannot hand over more than the
      " line still asks for, and it cannot hand over stock that is not there:
      " what it does is decide who gets it first
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

  METHOD demand_less_floors.

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

  METHOD answer_with_floors.

    DATA lv_requested TYPE zif_allocation=>ty_quantity.
    DATA ls_line      TYPE zif_allocation=>ty_allocation.

    " the rules answered a demand that had the floors taken out of it, and the
    " answer has to be about the demand as the orders have it: what a line
    " asked for is what was ordered, and what it got is what was handed over
    " plus whatever the rules then gave it
    LOOP AT it_allocation INTO ls_line.

      READ TABLE it_given INTO DATA(ls_given)
        WITH KEY demand_id = ls_line-demand_id.
      IF sy-subrc = 0.
        ls_line-confirmed = ls_line-confirmed + ls_given-quantity.
        " a line that got its floor was not held back by a rule that only
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
    " still has what was handed over, and every line has to be answered
    " exactly once
    LOOP AT it_given INTO ls_given.

      IF line_exists( rt_allocation[ demand_id = ls_given-demand_id ] ).
        CONTINUE.
      ENDIF.

      CLEAR ls_line.
      ls_line-demand_id = ls_given-demand_id.
      ls_line-confirmed = ls_given-quantity.

      IF line_exists( it_demand[ demand_id = ls_given-demand_id ] ).
        DATA(ls_demand)   = it_demand[ demand_id = ls_given-demand_id ].
        ls_line-requested = ls_demand-quantity.
        ls_line-req_date  = ls_demand-req_date.
        ls_line-customer  = ls_demand-customer.
        ls_line-shortfall = COND #( WHEN ls_demand-quantity > ls_line-confirmed
                                    THEN ls_demand-quantity - ls_line-confirmed
                                    ELSE 0 ).
      ENDIF.

      APPEND ls_line TO rt_allocation.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
