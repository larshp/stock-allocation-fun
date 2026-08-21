CLASS zcl_alloc_whatif DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_line_tab TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    "! The demand line the question is about. It is not on the books, so it
    "! cannot carry a document number, and it is marked as what it is.
    CONSTANTS c_demand_id TYPE zif_allocation=>ty_demand_id VALUE 'WHAT-IF'.

    "! <p class="shorttext synchronized">Question wired up the way a plain SAP system needs it</p>
    "!
    "!
    "! The settings travel as one structure, for the reason feature 126 gives.
    "!
    "! @parameter is_settings | <p class="shorttext synchronized">The plant's settings, as Customizing has them</p>
    "! @parameter io_strategy | <p class="shorttext synchronized">Distribution rule, the plant's by default</p>
    "! @parameter ro_whatif | <p class="shorttext synchronized">Ready to use</p>
    CLASS-METHODS create_default
      IMPORTING
        is_settings      TYPE zif_alloc_config=>ty_config
        io_strategy      TYPE REF TO zif_allocation_strategy OPTIONAL
      RETURNING
        VALUE(ro_whatif) TYPE REF TO zcl_alloc_whatif.

    "! <p class="shorttext synchronized">Question, wired up for a plant</p>
    "!
    "! Everything but the question comes from the plant's own settings, read
    "! here rather than by the caller: an answer worked out by different rules
    "! than the run uses is answering a different question in the same words,
    "! and a factory that cannot read them itself is one that will be called
    "! wrongly. Feature 92 is what that looks like when it happens.
    "!
    "! @parameter iv_werks | <p class="shorttext synchronized">Plant</p>
    "! @parameter ro_whatif | <p class="shorttext synchronized">Ready to use, as the plant would</p>
    CLASS-METHODS create_for_plant
      IMPORTING
        iv_werks         TYPE mard-werks
      RETURNING
        VALUE(ro_whatif) TYPE REF TO zcl_alloc_whatif.

    "! <p class="shorttext synchronized">Wire up the question</p>
    "!
    "! @parameter io_supply      | <p class="shorttext synchronized">What the plant has to give away</p>
    "! @parameter io_demand      | <p class="shorttext synchronized">What is already waiting for it</p>
    "! @parameter io_before      | <p class="shorttext synchronized">Works out the answer as it stands</p>
    "! @parameter io_after       | <p class="shorttext synchronized">Works out the answer with the extra line</p>
    "! @parameter io_authority   | <p class="shorttext synchronized">Decides who may see a plant</p>
    "! @parameter iv_ship_days   | <p class="shorttext synchronized">Days between the goods being ready and gone</p>
    "! @parameter io_calendar    | <p class="shorttext synchronized">Which days the plant works, every day if none</p>
    METHODS constructor
      IMPORTING
        io_supply    TYPE REF TO zif_supply_reader
        io_demand    TYPE REF TO zif_demand_reader
        io_before    TYPE REF TO zcl_allocation_engine
        io_after     TYPE REF TO zcl_allocation_engine
        io_authority TYPE REF TO zif_allocation_authority
        iv_ship_days TYPE i DEFAULT 0
        io_calendar  TYPE REF TO zif_work_calendar OPTIONAL.

    "! <p class="shorttext synchronized">What one more order would get, and who would pay for it</p>
    "!
    "! The promise of feature 76 answers "how much of this can I have, and
    "! from when". It answers it out of what is left over, which is the honest
    "! answer to a question about stock and the wrong answer to a question
    "! about a business: an order taken at a good price can be worth serving
    "! ahead of one that is already on the books, and somebody has to be able
    "! to see what that would cost before agreeing to it.
    "!
    "! This puts the line into the demand as if it had been typed, works the
    "! whole material out again, and shows what each line has now against what
    "! it would have. It allocates nothing, records nothing and reserves
    "! nothing.
    "!
    "! @parameter iv_matnr       | <p class="shorttext synchronized">Material number</p>
    "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
    "! @parameter iv_quantity    | <p class="shorttext synchronized">Quantity the order would be for</p>
    "! @parameter iv_req_date    | <p class="shorttext synchronized">Day it would be wanted, today if empty</p>
    "! @parameter iv_kunnr       | <p class="shorttext synchronized">Customer it would be for</p>
    "! @parameter iv_priority    | <p class="shorttext synchronized">Where it would stand in the queue</p>
    "! @parameter rt_line        | <p class="shorttext synchronized">Lines to display</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">Plant may not be seen, or reading failed</p>
    METHODS run
      IMPORTING
        iv_matnr       TYPE mard-matnr
        iv_werks       TYPE mard-werks
        iv_quantity    TYPE zif_allocation=>ty_quantity
        iv_req_date    TYPE d OPTIONAL
        iv_kunnr       TYPE vbak-kunnr OPTIONAL
        iv_priority    TYPE zif_allocation=>ty_priority DEFAULT '50'
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
    DATA mo_before    TYPE REF TO zcl_allocation_engine.
    DATA mo_after     TYPE REF TO zcl_allocation_engine.
    DATA mo_authority TYPE REF TO zif_allocation_authority.
    DATA mv_ship_days TYPE i.
    DATA mo_calendar  TYPE REF TO zif_work_calendar.

    METHODS extra_line
      IMPORTING
        iv_matnr         TYPE mard-matnr
        iv_werks         TYPE mard-werks
        iv_quantity      TYPE zif_allocation=>ty_quantity
        iv_req_date      TYPE d
        iv_kunnr         TYPE vbak-kunnr
        iv_priority      TYPE zif_allocation=>ty_priority
      RETURNING
        VALUE(rs_demand) TYPE zif_allocation=>ty_demand
      RAISING
        zcx_allocation.

    METHODS confirmed_for
      IMPORTING
        it_allocation      TYPE zif_allocation=>ty_allocation_tab
        iv_demand_id       TYPE zif_allocation=>ty_demand_id
      RETURNING
        VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity.

    METHODS answer_for_the_order
      IMPORTING
        it_after       TYPE zif_allocation=>ty_allocation_tab
        iv_quantity    TYPE zif_allocation=>ty_quantity
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab.

    METHODS what_it_would_cost
      IMPORTING
        it_demand      TYPE zif_allocation=>ty_demand_tab
        it_before      TYPE zif_allocation=>ty_allocation_tab
        it_after       TYPE zif_allocation=>ty_allocation_tab
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab.

    METHODS format_row
      IMPORTING
        iv_id          TYPE string
        iv_kunnr       TYPE string
        iv_now         TYPE string
        iv_would       TYPE string
      RETURNING
        VALUE(rv_line) TYPE string.

ENDCLASS.


CLASS zcl_alloc_whatif IMPLEMENTATION.

  METHOD create_default.

    DATA(lo_converter) = NEW zcl_unit_converter( ).

    DATA(lo_supply) = zcl_allocation_service=>create_default_supply(
      io_converter = lo_converter
      iv_lgort     = is_settings-lgort
      iv_planned   = is_settings-planned ).

    DATA(lo_demand) = zcl_allocation_service=>create_default_open_demand(
      io_converter    = lo_converter
      iv_horizon_days = is_settings-horizon_days
      iv_ship_days    = is_settings-ship_days
      iv_age_days     = is_settings-age_days
      iv_work_days    = is_settings-work_days
      iv_sto_priority = is_settings-sto_priority ).

    " each of the two answers gets a distribution rule of its own. The rules a
    " plant can put around a strategy remember what they have handed out while
    " a material is being worked out, and the two answers here are two
    " workings out of the same material: one chain would carry the first into
    " the second.
    ro_whatif = NEW zcl_alloc_whatif(
      io_supply    = lo_supply
      io_demand    = lo_demand
      io_before    = NEW zcl_allocation_engine(
        io_supply_reader = lo_supply
        io_demand_reader = lo_demand
        io_strategy      = zcl_allocation_service=>create_default_strategy(
          is_settings = is_settings
          io_strategy = io_strategy ) )
      io_after     = NEW zcl_allocation_engine(
        io_supply_reader = lo_supply
        io_demand_reader = lo_demand
        io_strategy      = zcl_allocation_service=>create_default_strategy(
          is_settings = is_settings
          io_strategy = io_strategy ) )
      io_authority = NEW zcl_authority_alloc( c_activity_display )
      iv_ship_days = is_settings-ship_days
      io_calendar  = COND #( WHEN is_settings-work_days = abap_true
                             THEN NEW zcl_calendar_factory( ) ) ).

  ENDMETHOD.

  METHOD create_for_plant.

    DATA(ls_settings) = CAST zif_alloc_config( NEW zcl_alloc_config( ) )->for_plant( iv_werks ).

    ro_whatif = create_default(
      is_settings = ls_settings
      io_strategy = zcl_alloc_config=>strategy_of( ls_settings ) ).

  ENDMETHOD.

  METHOD constructor.

    mo_supply    = io_supply.
    mo_demand    = io_demand.
    mo_before    = io_before.
    mo_after     = io_after.
    mo_authority = io_authority.
    mv_ship_days = iv_ship_days.

    " the line is built here rather than read, so it has to be given the same
    " calendar the readers give a real one
    mo_calendar = io_calendar.
    IF mo_calendar IS NOT BOUND.
      mo_calendar = NEW zcl_calendar_plain( ).
    ENDIF.

  ENDMETHOD.

  METHOD run.

    mo_authority->check_plant( iv_werks ).

    DATA(lv_req_date) = iv_req_date.
    IF lv_req_date IS INITIAL.
      lv_req_date = sy-datum.
    ENDIF.

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
    " of it: reading it twice would let an order arriving in between look like
    " something this one displaced
    DATA(lt_demand) = mo_demand->read_open_demand(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    DATA(lt_with) = lt_demand.
    APPEND extra_line(
      iv_matnr    = iv_matnr
      iv_werks    = iv_werks
      iv_quantity = iv_quantity
      iv_req_date = lv_req_date
      iv_kunnr    = iv_kunnr
      iv_priority = iv_priority ) TO lt_with.

    DATA(lt_before) = mo_before->allocate(
      iv_matnr  = iv_matnr
      iv_werks  = iv_werks
      it_demand = lt_demand ).

    DATA(lt_after) = mo_after->allocate(
      iv_matnr  = iv_matnr
      iv_werks  = iv_werks
      it_demand = lt_with ).

    APPEND |Material { iv_matnr } in plant { iv_werks }, what one more order would do| TO rt_line.
    APPEND |An order for { iv_quantity } wanted on { lv_req_date }| &&
           COND string( WHEN iv_kunnr IS NOT INITIAL
                        THEN | by { iv_kunnr }| ) &&
           |, priority { iv_priority }| TO rt_line.
    APPEND || TO rt_line.

    APPEND LINES OF answer_for_the_order(
      it_after    = lt_after
      iv_quantity = iv_quantity ) TO rt_line.

    APPEND LINES OF what_it_would_cost(
      it_demand = lt_demand
      it_before = lt_before
      it_after  = lt_after ) TO rt_line.

  ENDMETHOD.

  METHOD extra_line.

    " the line is built here rather than read, so the shipping time the demand
    " readers put on a real line has to be put on this one: without it the
    " order would be allowed to take stock arriving on the day it ships
    DATA(lv_ready_by) = mo_calendar->days_before(
      iv_werks = iv_werks
      iv_date  = iv_req_date
      iv_days  = mv_ship_days ).

    rs_demand = VALUE #(
      demand_id = c_demand_id
      matnr     = iv_matnr
      werks     = iv_werks
      quantity  = iv_quantity
      req_date  = iv_req_date
      ready_by  = lv_ready_by
      priority  = iv_priority
      customer  = iv_kunnr
      unit_size = 1 ).

  ENDMETHOD.

  METHOD answer_for_the_order.

    DATA lv_short TYPE zif_allocation=>ty_quantity.

    READ TABLE it_after INTO DATA(ls_line)
      WITH KEY demand_id = c_demand_id.
    IF sy-subrc <> 0.
      APPEND `The order would get nothing` TO rt_line.
      RETURN.
    ENDIF.

    APPEND |The order would be confirmed { ls_line-confirmed } of { iv_quantity }| TO rt_line.

    IF ls_line-avail_date IS NOT INITIAL.
      APPEND |and would be there in full on { ls_line-avail_date }| TO rt_line.
    ENDIF.

    lv_short = iv_quantity - ls_line-confirmed.
    IF lv_short > 0.
      APPEND |{ lv_short } short: { zcl_alloc_reason_text=>text( ls_line-reason ) }| TO rt_line.
    ENDIF.

    APPEND || TO rt_line.

  ENDMETHOD.

  METHOD what_it_would_cost.

    DATA lv_lost  TYPE zif_allocation=>ty_quantity.
    DATA lv_lines TYPE i.

    APPEND format_row(
      iv_id    = `Demand`
      iv_kunnr = `Customer`
      iv_now   = `Has now`
      iv_would = `Would have` ) TO rt_line.

    LOOP AT it_demand INTO DATA(ls_demand).

      DATA(lv_now) = confirmed_for(
        it_allocation = it_before
        iv_demand_id  = ls_demand-demand_id ).
      DATA(lv_would) = confirmed_for(
        it_allocation = it_after
        iv_demand_id  = ls_demand-demand_id ).

      " a line that keeps what it has is not what somebody is asking about,
      " and a line that would gain cannot happen: the same stock is being
      " distributed to one line more
      IF lv_would >= lv_now.
        CONTINUE.
      ENDIF.

      lv_lost  = lv_lost + ( lv_now - lv_would ).
      lv_lines = lv_lines + 1.

      APPEND format_row(
        iv_id    = |{ ls_demand-demand_id }|
        iv_kunnr = |{ ls_demand-customer }|
        iv_now   = |{ lv_now }|
        iv_would = |{ lv_would }| ) TO rt_line.

    ENDLOOP.

    APPEND || TO rt_line.

    IF lv_lines = 0.
      APPEND `Nobody would lose anything` TO rt_line.
      RETURN.
    ENDIF.

    APPEND |{ lv_lines } line(s) would lose { lv_lost } between them| TO rt_line.

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
