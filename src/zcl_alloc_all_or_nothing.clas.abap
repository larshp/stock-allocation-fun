CLASS zcl_alloc_all_or_nothing DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_allocation_strategy.

    "! <p class="shorttext synchronized">Wrap a strategy with the complete delivery rule</p>
    "!
    "! @parameter io_strategy | <p class="shorttext synchronized">Strategy that distributes the stock</p>
    METHODS constructor
      IMPORTING
        io_strategy TYPE REF TO zif_allocation_strategy.

  PRIVATE SECTION.

    "! What a set of lines that has to ship in one go is called here. KIND says
    "! which rule made it a set, because that is what a line dropped by it has
    "! to give as its reason; IDENT is what the lines have in common. An initial
    "! KIND is a line no rule of this sort applies to.
    TYPES:
      BEGIN OF ty_group,
        kind  TYPE c LENGTH 1,
        ident TYPE c LENGTH 24,
      END OF ty_group.
    TYPES ty_group_tab TYPE STANDARD TABLE OF ty_group WITH EMPTY KEY.

    "! Where the obligation to ship in one go came from. A line marked for
    "! complete delivery is a group of one, which is why one rule answers both:
    "! the alternative was two decorators doing the same arithmetic, and feature
    "! 148 says what that costs.
    CONSTANTS:
      BEGIN OF c_kind,
        line  TYPE c LENGTH 1 VALUE 'L',
        order TYPE c LENGTH 1 VALUE 'O',
      END OF c_kind.

    DATA mo_strategy TYPE REF TO zif_allocation_strategy.

    METHODS group_of
      IMPORTING
        is_demand       TYPE zif_allocation=>ty_demand
      RETURNING
        VALUE(rs_group) TYPE ty_group.

    METHODS worst_partial_group
      IMPORTING
        it_demand       TYPE zif_allocation=>ty_demand_tab
        it_allocation   TYPE zif_allocation=>ty_allocation_tab
      RETURNING
        VALUE(rs_group) TYPE ty_group.

    METHODS without
      IMPORTING
        it_demand        TYPE zif_allocation=>ty_demand_tab
        it_group         TYPE ty_group_tab
      RETURNING
        VALUE(rt_demand) TYPE zif_allocation=>ty_demand_tab.

    METHODS answer_with_nothing
      IMPORTING
        it_demand            TYPE zif_allocation=>ty_demand_tab
        it_group             TYPE ty_group_tab
      RETURNING
        VALUE(rt_allocation) TYPE zif_allocation=>ty_allocation_tab.

    METHODS reason_of
      IMPORTING
        is_group         TYPE ty_group
      RETURNING
        VALUE(rv_reason) TYPE zif_allocation=>ty_reason.

ENDCLASS.


CLASS zcl_alloc_all_or_nothing IMPLEMENTATION.

  METHOD constructor.
    mo_strategy = io_strategy.
  ENDMETHOD.

  METHOD zif_allocation_strategy~allocate.

    DATA lt_dropped TYPE ty_group_tab.
    DATA lv_passes  TYPE i.

    " a group is dropped and the stock offered again, until no group that has
    " to ship in one go is left holding a part of what it asked for. Each pass
    " drops exactly one group, and a group holds at least one line, so the
    " number of lines bounds the passes; the extra one is the pass that finds
    " nothing left to drop.
    lv_passes = lines( it_demand ) + 1.

    DO lv_passes TIMES.

      rt_allocation = mo_strategy->allocate(
        iv_available = iv_available
        it_demand    = without(
          it_demand = it_demand
          it_group  = lt_dropped ) ).

      DATA(ls_drop) = worst_partial_group(
        it_demand     = it_demand
        it_allocation = rt_allocation ).
      IF ls_drop IS INITIAL.
        EXIT.
      ENDIF.

      APPEND ls_drop TO lt_dropped.

    ENDDO.

    " every demand line is answered exactly once, so the dropped lines come
    " back too, with nothing confirmed and the whole quantity short
    APPEND LINES OF answer_with_nothing(
      it_demand = it_demand
      it_group  = lt_dropped ) TO rt_allocation.

  ENDMETHOD.

  METHOD group_of.

    " an order the customer takes in one delivery outranks the flag on the
    " line: the line cannot ship on its own whatever the line says about
    " itself, and the wider rule is the one whose reason the planner needs
    IF is_demand-ship_group IS NOT INITIAL.
      rs_group-kind  = c_kind-order.
      rs_group-ident = is_demand-ship_group.
      RETURN.
    ENDIF.

    IF is_demand-complete = abap_true.
      rs_group-kind  = c_kind-line.
      rs_group-ident = is_demand-demand_id.
    ENDIF.

  ENDMETHOD.

  METHOD worst_partial_group.

    TYPES:
      BEGIN OF ty_total,
        kind      TYPE c LENGTH 1,
        ident     TYPE c LENGTH 24,
        confirmed TYPE zif_allocation=>ty_quantity,
        shortfall TYPE zif_allocation=>ty_quantity,
      END OF ty_total.
    DATA lt_total TYPE STANDARD TABLE OF ty_total WITH EMPTY KEY.
    DATA lv_worst TYPE zif_allocation=>ty_quantity.

    " what the group as a whole was awarded, in the order the strategy answered
    " its lines: a group is served in part when some of it is confirmed and
    " some of it is still short, whichever of its lines that happened to
    LOOP AT it_allocation INTO DATA(ls_allocation).

      DATA(ls_group) = group_of( it_demand[ demand_id = ls_allocation-demand_id ] ).
      IF ls_group IS INITIAL.
        CONTINUE.
      ENDIF.

      DATA(lv_index) = line_index( lt_total[ kind  = ls_group-kind
                                            ident = ls_group-ident ] ).
      IF lv_index = 0.
        APPEND VALUE #( kind  = ls_group-kind
                        ident = ls_group-ident ) TO lt_total.
        lv_index = lines( lt_total ).
      ENDIF.

      IF ls_allocation-confirmed > 0.
        lt_total[ lv_index ]-confirmed = lt_total[ lv_index ]-confirmed + ls_allocation-confirmed.
      ENDIF.
      IF ls_allocation-shortfall > 0.
        lt_total[ lv_index ]-shortfall = lt_total[ lv_index ]-shortfall + ls_allocation-shortfall.
      ENDIF.

    ENDLOOP.

    LOOP AT lt_total INTO DATA(ls_total).

      " nothing confirmed is already all or nothing, and nothing short is the
      " whole group, so neither is a problem
      IF ls_total-confirmed <= 0 OR ls_total-shortfall <= 0.
        CONTINUE.
      ENDIF.

      " the group furthest from complete goes first: it frees the most stock and
      " is the least likely to fit even after the others have gone. On a tie the
      " group the strategy served last goes, which is the one it favoured least.
      IF ls_total-shortfall >= lv_worst.
        lv_worst       = ls_total-shortfall.
        rs_group-kind  = ls_total-kind.
        rs_group-ident = ls_total-ident.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD without.

    LOOP AT it_demand INTO DATA(ls_demand).
      DATA(ls_group) = group_of( ls_demand ).
      IF NOT line_exists( it_group[ kind  = ls_group-kind
                                    ident = ls_group-ident ] ).
        APPEND ls_demand TO rt_demand.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD answer_with_nothing.

    LOOP AT it_demand INTO DATA(ls_demand).

      DATA(ls_group) = group_of( ls_demand ).
      IF NOT line_exists( it_group[ kind  = ls_group-kind
                                    ident = ls_group-ident ] ).
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        demand_id = ls_demand-demand_id
        req_date  = ls_demand-req_date
        requested = ls_demand-quantity
        confirmed = 0
        shortfall = COND #( WHEN ls_demand-quantity > 0
                            THEN ls_demand-quantity
                            ELSE 0 )
        customer  = ls_demand-customer
        reason    = reason_of( ls_group ) ) TO rt_allocation.

    ENDLOOP.

  ENDMETHOD.

  METHOD reason_of.

    rv_reason = COND #( WHEN is_group-kind = c_kind-order
                        THEN zif_allocation=>c_reason-ship_together
                        ELSE zif_allocation=>c_reason-complete_only ).

  ENDMETHOD.

ENDCLASS.
