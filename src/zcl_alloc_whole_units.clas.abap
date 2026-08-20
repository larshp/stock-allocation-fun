CLASS zcl_alloc_whole_units DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_allocation_strategy.

    "! <p class="shorttext synchronized">Wrap a strategy so it confirms whole units only</p>
    "!
    "! A line ordered in cartons is confirmed in cartons. What a strategy hands
    "! it beyond the last whole one cannot be shipped as ordered, so it is cut
    "! off and offered to the other lines instead.
    "!
    "! @parameter io_strategy | <p class="shorttext synchronized">Strategy that distributes the stock</p>
    METHODS constructor
      IMPORTING
        io_strategy TYPE REF TO zif_allocation_strategy.

  PRIVATE SECTION.

    "! What one line may take at most, after the last pass found it could not
    "! use all of what it was given.
    TYPES:
      BEGIN OF ty_cap,
        demand_id TYPE zif_allocation=>ty_demand_id,
        quantity  TYPE zif_allocation=>ty_quantity,
      END OF ty_cap.
    TYPES ty_cap_tab TYPE STANDARD TABLE OF ty_cap WITH EMPTY KEY.

    DATA mo_strategy TYPE REF TO zif_allocation_strategy.

    METHODS whole_part
      IMPORTING
        is_demand          TYPE zif_allocation=>ty_demand
        iv_quantity        TYPE zif_allocation=>ty_quantity
      RETURNING
        VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity.

    METHODS worst_part_unit
      IMPORTING
        it_demand     TYPE zif_allocation=>ty_demand_tab
        it_allocation TYPE zif_allocation=>ty_allocation_tab
      RETURNING
        VALUE(rs_cap) TYPE ty_cap.

    METHODS capped
      IMPORTING
        it_demand        TYPE zif_allocation=>ty_demand_tab
        it_cap           TYPE ty_cap_tab
      RETURNING
        VALUE(rt_demand) TYPE zif_allocation=>ty_demand_tab.

    METHODS answer_for
      IMPORTING
        it_demand            TYPE zif_allocation=>ty_demand_tab
        it_cap               TYPE ty_cap_tab
        it_allocation        TYPE zif_allocation=>ty_allocation_tab
      RETURNING
        VALUE(rt_allocation) TYPE zif_allocation=>ty_allocation_tab.

ENDCLASS.


CLASS zcl_alloc_whole_units IMPLEMENTATION.

  METHOD constructor.
    mo_strategy = io_strategy.
  ENDMETHOD.

  METHOD zif_allocation_strategy~allocate.

    DATA lt_cap    TYPE ty_cap_tab.
    DATA lv_passes TYPE i.

    " a line that was given part of a unit is held to the whole part of it and
    " the stock offered again, so what it cannot use reaches a line that can.
    " Each pass caps one line lower than it was, so the passes are bounded; the
    " extra one is the pass that finds nothing left to cap.
    lv_passes = lines( it_demand ) + 1.

    DO lv_passes TIMES.

      DATA(lt_allocation) = mo_strategy->allocate(
        iv_available = iv_available
        it_demand    = capped(
          it_demand = it_demand
          it_cap    = lt_cap ) ).

      DATA(ls_cap) = worst_part_unit(
        it_demand     = it_demand
        it_allocation = lt_allocation ).
      IF ls_cap-demand_id IS INITIAL.
        EXIT.
      ENDIF.

      DELETE lt_cap WHERE demand_id = ls_cap-demand_id.
      APPEND ls_cap TO lt_cap.

    ENDDO.

    " the answer is about the demand as it was asked for, not as the passes
    " capped it, and a line the passes never settled is cut here. That the cut
    " happens whatever the loop did is what makes the rule a rule.
    rt_allocation = answer_for(
      it_demand     = it_demand
      it_cap        = lt_cap
      it_allocation = lt_allocation ).

  ENDMETHOD.

  METHOD whole_part.

    " no unit, or a unit that is the base unit, is no rounding: every quantity
    " is a whole number of them
    IF is_demand-unit_size <= 1.
      rv_quantity = iv_quantity.
      RETURN.
    ENDIF.

    IF iv_quantity <= 0.
      RETURN.
    ENDIF.

    rv_quantity = floor( iv_quantity / is_demand-unit_size ) * is_demand-unit_size.

  ENDMETHOD.

  METHOD worst_part_unit.

    DATA lv_worst TYPE zif_allocation=>ty_quantity.

    LOOP AT it_allocation INTO DATA(ls_allocation).

      READ TABLE it_demand INTO DATA(ls_demand)
        WITH KEY demand_id = ls_allocation-demand_id.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      DATA(lv_whole) = whole_part(
        is_demand   = ls_demand
        iv_quantity = ls_allocation-confirmed ).

      DATA(lv_part) = ls_allocation-confirmed - lv_whole.
      IF lv_part <= 0.
        CONTINUE.
      ENDIF.

      " the line holding the biggest part of a unit goes first: it frees the
      " most stock for the lines that can still use it
      IF lv_part > lv_worst.
        lv_worst          = lv_part.
        rs_cap-demand_id  = ls_allocation-demand_id.
        rs_cap-quantity   = lv_whole.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD capped.

    rt_demand = it_demand.

    LOOP AT it_cap INTO DATA(ls_cap).

      READ TABLE rt_demand ASSIGNING FIELD-SYMBOL(<ls_demand>)
        WITH KEY demand_id = ls_cap-demand_id.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      <ls_demand>-quantity = ls_cap-quantity.

    ENDLOOP.

  ENDMETHOD.

  METHOD answer_for.

    LOOP AT it_allocation INTO DATA(ls_allocation).

      READ TABLE it_demand INTO DATA(ls_demand)
        WITH KEY demand_id = ls_allocation-demand_id.
      IF sy-subrc <> 0.
        APPEND ls_allocation TO rt_allocation.
        CONTINUE.
      ENDIF.

      DATA(lv_whole) = whole_part(
        is_demand   = ls_demand
        iv_quantity = ls_allocation-confirmed ).

      " the rule only explains a line it actually cut, here or in one of the
      " passes. One that was short before it looked at it is short for
      " whatever reason made it so.
      IF lv_whole < ls_allocation-confirmed
          OR line_exists( it_cap[ demand_id = ls_allocation-demand_id ] ).
        ls_allocation-reason = zif_allocation=>c_reason-whole_units.
      ENDIF.

      ls_allocation-confirmed = lv_whole.
      ls_allocation-requested = ls_demand-quantity.
      ls_allocation-shortfall = COND #(
        WHEN ls_allocation-requested > ls_allocation-confirmed
        THEN ls_allocation-requested - ls_allocation-confirmed
        ELSE 0 ).

      APPEND ls_allocation TO rt_allocation.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
