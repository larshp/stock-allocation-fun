CLASS zcl_alloc_explain DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_line_tab TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    "! <p class="shorttext synchronized">Explanation wired up the way a plain SAP system needs it</p>
    "!
    "! @parameter iv_lgort   | <p class="shorttext synchronized">Location to allocate from, all if empty</p>
    "! @parameter iv_planned | <p class="shorttext synchronized">Planned orders count as supply too</p>
    "! @parameter ro_explain | <p class="shorttext synchronized">Ready to use explanation</p>
    CLASS-METHODS create_default
      IMPORTING
        iv_lgort          TYPE mard-lgort OPTIONAL
        iv_planned        TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(ro_explain) TYPE REF TO zcl_alloc_explain.

    "! <p class="shorttext synchronized">Wire up the explanation</p>
    "!
    "! @parameter io_supply    | <p class="shorttext synchronized">What the plant has to give away</p>
    "! @parameter io_demand    | <p class="shorttext synchronized">What is waiting for it</p>
    "! @parameter io_engine    | <p class="shorttext synchronized">Works out who would get what</p>
    "! @parameter io_authority | <p class="shorttext synchronized">Decides who may see a plant</p>
    METHODS constructor
      IMPORTING
        io_supply    TYPE REF TO zif_supply_reader
        io_demand    TYPE REF TO zif_demand_reader
        io_engine    TYPE REF TO zcl_allocation_engine
        io_authority TYPE REF TO zif_allocation_authority.

    "! <p class="shorttext synchronized">Show the working behind one material's answer</p>
    "!
    "! The result of a run says what each line got and, since feature 47, what
    "! stopped it. This says why there was that much to go round in the first
    "! place: every day of supply the run would see, every line competing for
    "! it, and what the two of them come to. For the question that follows
    "! every shortage, which is "are you sure?".
    "!
    "! It allocates nothing, records nothing and reserves nothing.
    "!
    "! @parameter iv_matnr       | <p class="shorttext synchronized">Material number</p>
    "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
    "! @parameter rt_line        | <p class="shorttext synchronized">Lines to display</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">Plant may not be seen, or reading failed</p>
    METHODS run
      IMPORTING
        iv_matnr       TYPE mard-matnr
        iv_werks       TYPE mard-werks
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab
      RAISING
        zcx_allocation.

  PRIVATE SECTION.

    CONSTANTS c_width_id   TYPE i VALUE 26.
    CONSTANTS c_width_date TYPE i VALUE 12.
    CONSTANTS c_width_qty  TYPE i VALUE 14.

    "! Reading a situation, not changing it.
    CONSTANTS c_activity_display TYPE activ_auth VALUE '03'.

    DATA mo_supply    TYPE REF TO zif_supply_reader.
    DATA mo_demand    TYPE REF TO zif_demand_reader.
    DATA mo_engine    TYPE REF TO zcl_allocation_engine.
    DATA mo_authority TYPE REF TO zif_allocation_authority.

    METHODS supply_lines
      IMPORTING
        it_supply      TYPE zif_supply_reader=>ty_supply_tab
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab.

    METHODS demand_lines
      IMPORTING
        it_demand      TYPE zif_allocation=>ty_demand_tab
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab.

    METHODS answer_lines
      IMPORTING
        it_allocation  TYPE zif_allocation=>ty_allocation_tab
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab.

    METHODS date_text
      IMPORTING
        iv_date        TYPE d
      RETURNING
        VALUE(rv_text) TYPE string.

ENDCLASS.


CLASS zcl_alloc_explain IMPLEMENTATION.

  METHOD create_default.

    " the same sources a run reads, so the working shown is the working done
    DATA(lo_converter) = NEW zcl_unit_converter( ).
    DATA(lo_supply)    = zcl_allocation_service=>create_default_supply(
      io_converter = lo_converter
      iv_lgort     = iv_lgort
      iv_planned   = iv_planned ).
    DATA(lo_demand)    = zcl_allocation_service=>create_default_demand( io_converter = lo_converter ).

    ro_explain = NEW zcl_alloc_explain(
      io_supply    = lo_supply
      io_demand    = lo_demand
      io_engine    = NEW zcl_allocation_engine(
        io_supply_reader = lo_supply
        io_demand_reader = lo_demand
        io_strategy      = NEW zcl_alloc_strategy_priority( ) )
      io_authority = NEW zcl_authority_plant( c_activity_display ) ).

  ENDMETHOD.

  METHOD constructor.

    mo_supply    = io_supply.
    mo_demand    = io_demand.
    mo_engine    = io_engine.
    mo_authority = io_authority.

  ENDMETHOD.

  METHOD run.

    mo_authority->check_plant( iv_werks ).

    APPEND |Material { iv_matnr } in plant { iv_werks }| TO rt_line.

    APPEND LINES OF supply_lines( mo_supply->read_supply(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ) ) TO rt_line.

    DATA(lt_demand) = mo_demand->read_open_demand(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    APPEND LINES OF demand_lines( lt_demand ) TO rt_line.

    " the same calculation a run does, thrown away afterwards. Reading it back
    " from the last recorded run would show what was true last night, and the
    " question is always about now.
    APPEND LINES OF answer_lines( mo_engine->allocate(
      iv_matnr  = iv_matnr
      iv_werks  = iv_werks
      it_demand = lt_demand ) ) TO rt_line.

  ENDMETHOD.

  METHOD supply_lines.

    DATA lv_total TYPE zif_allocation=>ty_quantity.

    APPEND || TO rt_line.
    APPEND `What there is to give away` TO rt_line.

    IF it_supply IS INITIAL.
      APPEND `  nothing` TO rt_line.
      RETURN.
    ENDIF.

    DATA(lt_sorted) = it_supply.
    SORT lt_sorted BY avail_date ASCENDING.

    LOOP AT lt_sorted INTO DATA(ls_supply).
      lv_total = lv_total + ls_supply-quantity.
      APPEND |  { date_text( ls_supply-avail_date ) WIDTH = c_width_date }| &&
             |{ ls_supply-quantity WIDTH = c_width_qty ALIGN = RIGHT }| TO rt_line.
    ENDLOOP.

    APPEND |  { `Total` WIDTH = c_width_date }| &&
           |{ lv_total WIDTH = c_width_qty ALIGN = RIGHT }| TO rt_line.

  ENDMETHOD.

  METHOD demand_lines.

    DATA lv_total TYPE zif_allocation=>ty_quantity.

    APPEND || TO rt_line.
    APPEND `What is waiting for it` TO rt_line.

    IF it_demand IS INITIAL.
      APPEND `  nothing` TO rt_line.
      RETURN.
    ENDIF.

    LOOP AT it_demand INTO DATA(ls_demand).
      lv_total = lv_total + ls_demand-quantity.
      APPEND |  { ls_demand-demand_id WIDTH = c_width_id }| &&
             |{ date_text( ls_demand-req_date ) WIDTH = c_width_date }| &&
             |{ ls_demand-quantity WIDTH = c_width_qty ALIGN = RIGHT }| &&
             |  { ls_demand-priority }  { ls_demand-customer }| TO rt_line.
    ENDLOOP.

    APPEND |  { `Total` WIDTH = c_width_id }| &&
           |{ `` WIDTH = c_width_date }| &&
           |{ lv_total WIDTH = c_width_qty ALIGN = RIGHT }| TO rt_line.

  ENDMETHOD.

  METHOD answer_lines.

    APPEND || TO rt_line.
    APPEND `What a run would confirm now` TO rt_line.

    IF it_allocation IS INITIAL.
      APPEND `  nothing` TO rt_line.
      RETURN.
    ENDIF.

    LOOP AT it_allocation INTO DATA(ls_allocation).
      APPEND |  { ls_allocation-demand_id WIDTH = c_width_id }| &&
             |{ ls_allocation-confirmed WIDTH = c_width_qty ALIGN = RIGHT }| &&
             |{ ls_allocation-shortfall WIDTH = c_width_qty ALIGN = RIGHT }| &&
             |  { zcl_alloc_reason_text=>text( ls_allocation-reason ) }| TO rt_line.
    ENDLOOP.

  ENDMETHOD.

  METHOD date_text.

    IF iv_date IS INITIAL.
      rv_text = `now`.
      RETURN.
    ENDIF.

    rv_text = |{ iv_date+0(4) }-{ iv_date+4(2) }-{ iv_date+6(2) }|.

  ENDMETHOD.

ENDCLASS.
