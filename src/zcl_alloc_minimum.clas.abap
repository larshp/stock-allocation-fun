CLASS zcl_alloc_minimum DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_allocation_strategy.

    "! No minimum at all, which is what a plant gets until it asks for one.
    CONSTANTS c_no_minimum TYPE i VALUE 0.

    "! <p class="shorttext synchronized">A confirmation too small to be worth shipping is none</p>
    "!
    "! A line for a thousand pieces confirmed for three has cost the plant a
    "! delivery, a lorry booking and an invoice, and has given the customer
    "! something they cannot use. Everybody involved would rather the three
    "! pieces had gone to a line that could ship, and the customer had been
    "! told the truth a week earlier.
    "!
    "! This is the complete delivery rule of feature 25 with the bar somewhere
    "! other than the top: a line that cannot be confirmed at least this share
    "! of what it asked for is confirmed nothing, and the stock goes to the
    "! lines behind it.
    "!
    "! @parameter io_strategy | <p class="shorttext synchronized">Strategy that distributes the stock</p>
    "! @parameter iv_percent  | <p class="shorttext synchronized">Least share of a line worth confirming, 0 for none</p>
    METHODS constructor
      IMPORTING
        io_strategy TYPE REF TO zif_allocation_strategy
        iv_percent  TYPE i DEFAULT c_no_minimum.

  PRIVATE SECTION.

    CONSTANTS c_percent TYPE i VALUE 100.

    TYPES ty_demand_id_tab TYPE STANDARD TABLE OF zif_allocation=>ty_demand_id WITH EMPTY KEY.

    DATA mo_strategy TYPE REF TO zif_allocation_strategy.
    DATA mv_percent  TYPE i.

    METHODS worst_thin_line
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


CLASS zcl_alloc_minimum IMPLEMENTATION.

  METHOD constructor.

    mo_strategy = io_strategy.
    mv_percent  = iv_percent.

  ENDMETHOD.

  METHOD zif_allocation_strategy~allocate.

    DATA lt_dropped TYPE ty_demand_id_tab.
    DATA lv_passes  TYPE i.

    " a bar at or above the whole line is the complete delivery rule, which is
    " a rule of the document rather than of the plant and is applied outside
    " this one
    IF mv_percent <= c_no_minimum OR mv_percent > c_percent.
      rt_allocation = mo_strategy->allocate(
        iv_available = iv_available
        it_demand    = it_demand ).
      RETURN.
    ENDIF.

    " one line dropped per pass and the stock offered again, exactly as the
    " complete delivery rule does it: dropping the thinnest line frees the
    " least stock, which is what gives the line behind it the best chance of
    " clearing the bar itself
    lv_passes = lines( it_demand ) + 1.

    DO lv_passes TIMES.

      rt_allocation = mo_strategy->allocate(
        iv_available = iv_available
        it_demand    = without(
          it_demand    = it_demand
          it_demand_id = lt_dropped ) ).

      DATA(lv_drop) = worst_thin_line(
        it_demand     = it_demand
        it_allocation = rt_allocation ).
      IF lv_drop IS INITIAL.
        EXIT.
      ENDIF.

      APPEND lv_drop TO lt_dropped.

    ENDDO.

    " every demand line is answered exactly once, so the dropped lines come
    " back with nothing confirmed
    APPEND LINES OF answer_with_nothing(
      it_demand    = it_demand
      it_demand_id = lt_dropped ) TO rt_allocation.

  ENDMETHOD.

  METHOD worst_thin_line.

    DATA lv_bar    TYPE zif_allocation=>ty_quantity.
    DATA lv_worst  TYPE zif_allocation=>ty_quantity.
    DATA lv_wanted TYPE zif_allocation=>ty_quantity.

    lv_worst = -1.

    LOOP AT it_allocation INTO DATA(ls_allocation).

      " nothing confirmed is already nothing, and a line served in full is
      " over the bar whatever the bar is
      IF ls_allocation-confirmed <= 0 OR ls_allocation-shortfall <= 0.
        CONTINUE.
      ENDIF.

      IF NOT line_exists( it_demand[ demand_id = ls_allocation-demand_id ] ).
        CONTINUE.
      ENDIF.

      lv_wanted = it_demand[ demand_id = ls_allocation-demand_id ]-quantity.
      IF lv_wanted <= 0.
        CONTINUE.
      ENDIF.

      lv_bar = lv_wanted * mv_percent / c_percent.
      IF ls_allocation-confirmed >= lv_bar.
        CONTINUE.
      ENDIF.

      " the thinnest confirmation goes first: it is the one furthest from
      " being worth shipping, and dropping it disturbs the least
      IF lv_worst < 0 OR ls_allocation-confirmed < lv_worst.
        lv_worst     = ls_allocation-confirmed.
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
        customer  = ls_demand-customer
        requested = ls_demand-quantity
        confirmed = 0
        shortfall = COND #( WHEN ls_demand-quantity > 0
                            THEN ls_demand-quantity
                            ELSE 0 )
        reason    = zif_allocation=>c_reason-too_little ) TO rt_allocation.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
