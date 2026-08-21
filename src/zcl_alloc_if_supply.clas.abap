CLASS zcl_alloc_if_supply DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_line_tab TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    "! <p class="shorttext synchronized">Question wired up for a plant</p>
    "!
    "! Everything comes from the plant's own settings, for the reason feature
    "! 93 gives: an answer worked out by different rules than the run uses is
    "! answering a different question in the same words.
    "!
    "! @parameter iv_werks | <p class="shorttext synchronized">Plant</p>
    "! @parameter ro_if    | <p class="shorttext synchronized">Ready to use question</p>
    CLASS-METHODS create_for_plant
      IMPORTING
        iv_werks     TYPE mard-werks
      RETURNING
        VALUE(ro_if) TYPE REF TO zcl_alloc_if_supply.

    "! <p class="shorttext synchronized">Wire up the question</p>
    "!
    "! @parameter io_supply    | <p class="shorttext synchronized">What the plant has to give away</p>
    "! @parameter io_demand    | <p class="shorttext synchronized">What is waiting for it</p>
    "! @parameter io_strategy  | <p class="shorttext synchronized">The rule, wrapped as a run wraps it</p>
    "! @parameter io_authority | <p class="shorttext synchronized">Decides who may see a plant</p>
    METHODS constructor
      IMPORTING
        io_supply    TYPE REF TO zif_supply_reader
        io_demand    TYPE REF TO zif_demand_reader
        io_strategy  TYPE REF TO zif_allocation_strategy
        io_authority TYPE REF TO zif_allocation_authority.

    "! <p class="shorttext synchronized">Who would get one more delivery, and what it would fix</p>
    "!
    "! The mirror of feature 88. That one asks what an order would cost the
    "! book; this asks what a delivery would buy it, which is the question in
    "! front of somebody deciding whether to pay for an expedited shipment or
    "! to ring the supplier again: five hundred on Friday sounds useful, and
    "! whether it is depends on which lines could actually take it.
    "!
    "! It allocates nothing, records nothing and reserves nothing.
    "!
    "! @parameter iv_matnr       | <p class="shorttext synchronized">Material number</p>
    "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
    "! @parameter iv_quantity    | <p class="shorttext synchronized">Quantity that would land</p>
    "! @parameter iv_date        | <p class="shorttext synchronized">Day it would land, today if empty</p>
    "! @parameter rt_line        | <p class="shorttext synchronized">Lines to display</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">Plant may not be seen, or reading failed</p>
    METHODS run
      IMPORTING
        iv_matnr       TYPE mard-matnr
        iv_werks       TYPE mard-werks
        iv_quantity    TYPE zif_allocation=>ty_quantity
        iv_date        TYPE d OPTIONAL
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab
      RAISING
        zcx_allocation.

  PRIVATE SECTION.

    CONSTANTS c_width_id    TYPE i VALUE 26.
    CONSTANTS c_width_kunnr TYPE i VALUE 12.
    CONSTANTS c_width_qty   TYPE i VALUE 14.

    "! Asking what would happen, not making it happen.
    CONSTANTS c_activity_display TYPE activ_auth VALUE '03'.

    DATA mo_supply    TYPE REF TO zif_supply_reader.
    DATA mo_demand    TYPE REF TO zif_demand_reader.
    DATA mo_strategy  TYPE REF TO zif_allocation_strategy.
    DATA mo_authority TYPE REF TO zif_allocation_authority.

    METHODS confirmed_for
      IMPORTING
        it_allocation      TYPE zif_allocation=>ty_allocation_tab
        iv_demand_id       TYPE zif_allocation=>ty_demand_id
      RETURNING
        VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity.

    METHODS format_row
      IMPORTING
        iv_id          TYPE string
        iv_kunnr       TYPE string
        iv_now         TYPE string
        iv_would       TYPE string
      RETURNING
        VALUE(rv_line) TYPE string.

ENDCLASS.


CLASS zcl_alloc_if_supply IMPLEMENTATION.

  METHOD create_for_plant.

    DATA(ls_settings) = CAST zif_alloc_config( NEW zcl_alloc_config( ) )->for_plant( iv_werks ).
    DATA(lo_converter) = NEW zcl_unit_converter( ).

    ro_if = NEW zcl_alloc_if_supply(
      io_supply    = zcl_allocation_service=>create_default_supply(
        is_settings  = ls_settings
        io_converter = lo_converter )
      io_demand    = zcl_allocation_service=>create_default_open_demand(
        is_settings  = ls_settings
        io_converter = lo_converter )
      io_strategy  = zcl_allocation_service=>create_default_strategy(
        is_settings = ls_settings
        io_strategy = zcl_alloc_config=>strategy_of( ls_settings ) )
      io_authority = NEW zcl_authority_alloc( c_activity_display ) ).

  ENDMETHOD.

  METHOD constructor.

    mo_supply    = io_supply.
    mo_demand    = io_demand.
    mo_strategy  = io_strategy.
    mo_authority = io_authority.

  ENDMETHOD.

  METHOD run.

    DATA lv_gained TYPE zif_allocation=>ty_quantity.
    DATA lv_spare  TYPE zif_allocation=>ty_quantity.
    DATA lv_lines  TYPE i.

    mo_authority->check_plant( iv_werks ).

    DATA(lv_date) = iv_date.

    " a material the plant has put on hold reads as a material nobody wants,
    " because the demand readers leave it out. An answer that goes quiet about
    " the one thing that explains it is worse than no answer -- the same point
    " the explanation of feature 66 makes.
    DATA(lv_hold) = zcl_alloc_hold=>reason_for(
      iv_matnr = iv_matnr
      iv_werks = iv_werks
      iv_today = sy-datum ).
    IF lv_hold IS NOT INITIAL.
      APPEND |On hold: { lv_hold }| TO rt_line.
    ENDIF.

    " the demand is read once and both answers are worked out from the same
    " of it, as in feature 88: reading it twice would let an order that
    " arrived in between look like something the delivery fixed
    DATA(lt_demand) = mo_demand->read_open_demand(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    APPEND |Material { iv_matnr } in plant { iv_werks }, what one more delivery would fix| TO rt_line.
    APPEND |{ iv_quantity } landing | &&
           COND string( WHEN lv_date IS INITIAL
                        THEN `now`
                        ELSE |on { lv_date DATE = ISO }| ) TO rt_line.
    APPEND || TO rt_line.

    IF lt_demand IS INITIAL.
      APPEND `Nothing is waiting for this material` TO rt_line.
      RETURN.
    ENDIF.

    " each answer gets an engine of its own for the reason feature 88 gives:
    " the rules remember what they have handed out while a material is worked
    " out, and one chain used twice would carry the first answer into the
    " second
    DATA(lt_before) = NEW zcl_allocation_engine(
      io_supply_reader = mo_supply
      io_demand_reader = mo_demand
      io_strategy      = mo_strategy )->allocate(
        iv_matnr  = iv_matnr
        iv_werks  = iv_werks
        it_demand = lt_demand ).

    DATA(lt_after) = NEW zcl_allocation_engine(
      io_supply_reader = NEW zcl_supply_extra(
        io_supply   = mo_supply
        iv_matnr    = iv_matnr
        iv_werks    = iv_werks
        iv_quantity = iv_quantity
        iv_date     = lv_date )
      io_demand_reader = mo_demand
      io_strategy      = mo_strategy )->allocate(
        iv_matnr  = iv_matnr
        iv_werks  = iv_werks
        it_demand = lt_demand ).

    APPEND format_row(
      iv_id    = `Demand`
      iv_kunnr = `Customer`
      iv_now   = `Has now`
      iv_would = `Would have` ) TO rt_line.

    LOOP AT lt_demand INTO DATA(ls_demand).

      DATA(lv_now) = confirmed_for(
        it_allocation = lt_before
        iv_demand_id  = ls_demand-demand_id ).
      DATA(lv_would) = confirmed_for(
        it_allocation = lt_after
        iv_demand_id  = ls_demand-demand_id ).

      " a line that would be no better off is not what anybody is asking
      " about, and no line can be worse off for stock arriving
      IF lv_would <= lv_now.
        CONTINUE.
      ENDIF.

      lv_gained = lv_gained + ( lv_would - lv_now ).
      lv_lines  = lv_lines + 1.

      APPEND format_row(
        iv_id    = |{ ls_demand-demand_id }|
        iv_kunnr = |{ ls_demand-customer }|
        iv_now   = |{ lv_now }|
        iv_would = |{ lv_would }| ) TO rt_line.

    ENDLOOP.

    APPEND || TO rt_line.

    IF lv_lines = 0.
      APPEND `Nobody would be any better off` TO rt_line.
      RETURN.
    ENDIF.

    APPEND |{ lv_lines } line(s) would gain { lv_gained } between them| TO rt_line.

    " typed explicitly: a subtraction inside a string template is worked out
    " in floating point by the transpiler, see ANOMALIES.md
    IF lv_gained < iv_quantity.
      lv_spare = iv_quantity - lv_gained.
      APPEND |{ lv_spare } of the delivery would go to nobody| TO rt_line.
    ENDIF.

  ENDMETHOD.

  METHOD confirmed_for.

    READ TABLE it_allocation INTO DATA(ls_line)
      WITH KEY demand_id = iv_demand_id.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    rv_quantity = ls_line-confirmed.

  ENDMETHOD.

  METHOD format_row.

    rv_line = |{ iv_id WIDTH = c_width_id }|
           && |{ iv_kunnr WIDTH = c_width_kunnr }|
           && |{ iv_now WIDTH = c_width_qty ALIGN = RIGHT }|
           && |{ iv_would WIDTH = c_width_qty ALIGN = RIGHT }|.

  ENDMETHOD.

ENDCLASS.
