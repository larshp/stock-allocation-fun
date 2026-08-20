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

    TYPES ty_demand_id_tab TYPE STANDARD TABLE OF zif_allocation=>ty_demand_id WITH EMPTY KEY.

    DATA mo_strategy TYPE REF TO zif_allocation_strategy.

    METHODS worst_partial_line
      IMPORTING
        it_demand           TYPE zif_allocation=>ty_demand_tab
        it_allocation       TYPE zif_allocation=>ty_allocation_tab
      RETURNING
        VALUE(rv_demand_id) TYPE zif_allocation=>ty_demand_id.

    METHODS without
      IMPORTING
        it_demand        TYPE zif_allocation=>ty_demand_tab
        it_demand_id     TYPE ty_demand_id_tab
      RETURNING
        VALUE(rt_demand) TYPE zif_allocation=>ty_demand_tab.

    METHODS answer_with_nothing
      IMPORTING
        it_demand            TYPE zif_allocation=>ty_demand_tab
        it_demand_id         TYPE ty_demand_id_tab
      RETURNING
        VALUE(rt_allocation) TYPE zif_allocation=>ty_allocation_tab.

ENDCLASS.


CLASS zcl_alloc_all_or_nothing IMPLEMENTATION.

  METHOD constructor.
    mo_strategy = io_strategy.
  ENDMETHOD.

  METHOD zif_allocation_strategy~allocate.

    DATA lt_dropped TYPE ty_demand_id_tab.
    DATA lv_passes  TYPE i.

    " a line is dropped and the stock offered again, until no line marked for
    " complete delivery is left holding a part of what it asked for. Each pass
    " drops exactly one line, so the number of lines bounds the passes; the
    " extra one is the pass that finds nothing left to drop.
    lv_passes = lines( it_demand ) + 1.

    DO lv_passes TIMES.

      rt_allocation = mo_strategy->allocate(
        iv_available = iv_available
        it_demand    = without(
          it_demand    = it_demand
          it_demand_id = lt_dropped ) ).

      DATA(lv_drop) = worst_partial_line(
        it_demand     = it_demand
        it_allocation = rt_allocation ).
      IF lv_drop IS INITIAL.
        EXIT.
      ENDIF.

      APPEND lv_drop TO lt_dropped.

    ENDDO.

    " every demand line is answered exactly once, so the dropped lines come
    " back too, with nothing confirmed and the whole quantity short
    APPEND LINES OF answer_with_nothing(
      it_demand    = it_demand
      it_demand_id = lt_dropped ) TO rt_allocation.

  ENDMETHOD.

  METHOD worst_partial_line.

    DATA lv_worst TYPE zif_allocation=>ty_quantity.

    LOOP AT it_allocation INTO DATA(ls_allocation).

      " nothing confirmed is already all or nothing, and nothing short is the
      " whole line, so neither is a problem
      IF ls_allocation-confirmed <= 0 OR ls_allocation-shortfall <= 0.
        CONTINUE.
      ENDIF.

      IF NOT line_exists( it_demand[ demand_id = ls_allocation-demand_id
                                     complete  = abap_true ] ).
        CONTINUE.
      ENDIF.

      " the line furthest from complete goes first: it frees the most stock and
      " is the least likely to fit even after the others have gone. On a tie the
      " line the strategy served last goes, which is the one it favoured least.
      IF ls_allocation-shortfall >= lv_worst.
        lv_worst     = ls_allocation-shortfall.
        rv_demand_id = ls_allocation-demand_id.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD without.

    rt_demand = it_demand.

    LOOP AT it_demand_id INTO DATA(lv_demand_id).
      DELETE rt_demand WHERE demand_id = lv_demand_id.
    ENDLOOP.

  ENDMETHOD.

  METHOD answer_with_nothing.

    LOOP AT it_demand_id INTO DATA(lv_demand_id).

      DATA(ls_demand) = it_demand[ demand_id = lv_demand_id ].

      APPEND VALUE #(
        demand_id = ls_demand-demand_id
        req_date  = ls_demand-req_date
        requested = ls_demand-quantity
        confirmed = 0
        shortfall = COND #( WHEN ls_demand-quantity > 0
                            THEN ls_demand-quantity
                            ELSE 0 )
        reason    = zif_allocation=>c_reason-complete_only ) TO rt_allocation.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
