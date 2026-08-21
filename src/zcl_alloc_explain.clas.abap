CLASS zcl_alloc_explain DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_line_tab TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    "! <p class="shorttext synchronized">Explanation wired up the way a plain SAP system needs it</p>
    "!
    "!
    "! The settings travel as one structure, for the reason feature 126 gives.
    "!
    "! @parameter is_settings | <p class="shorttext synchronized">The plant's settings, as Customizing has them</p>
    "! @parameter io_strategy | <p class="shorttext synchronized">Distribution rule, the plant's by default</p>
    "! @parameter ro_explain | <p class="shorttext synchronized">Ready to use</p>
    CLASS-METHODS create_default
      IMPORTING
        is_settings       TYPE zif_alloc_config=>ty_config
        io_strategy       TYPE REF TO zif_allocation_strategy OPTIONAL
      RETURNING
        VALUE(ro_explain) TYPE REF TO zcl_alloc_explain.

    "! <p class="shorttext synchronized">Explanation, wired up for a plant</p>
    "!
    "! Everything but the question comes from the plant's own settings, read
    "! here rather than by the caller: an answer worked out by different rules
    "! than the run uses is answering a different question in the same words,
    "! and a factory that cannot read them itself is one that will be called
    "! wrongly. Feature 92 is what that looks like when it happens.
    "!
    "! @parameter iv_werks | <p class="shorttext synchronized">Plant</p>
    "! @parameter ro_explain | <p class="shorttext synchronized">Ready to use, as the plant would</p>
    CLASS-METHODS create_for_plant
      IMPORTING
        iv_werks          TYPE mard-werks
      RETURNING
        VALUE(ro_explain) TYPE REF TO zcl_alloc_explain.

    "! <p class="shorttext synchronized">Wire up the explanation</p>
    "!
    "! @parameter io_supply    | <p class="shorttext synchronized">What the plant has to give away</p>
    "! @parameter io_demand    | <p class="shorttext synchronized">What is left to serve, as the run reads it</p>
    "! @parameter io_gross     | <p class="shorttext synchronized">What the documents ask for, before netting</p>
    "! @parameter io_engine    | <p class="shorttext synchronized">Works out who would get what</p>
    "! @parameter io_authority | <p class="shorttext synchronized">Decides who may see a plant</p>
    "! @parameter iv_today     | <p class="shorttext synchronized">Day to measure a hold against, today if empty</p>
    METHODS constructor
      IMPORTING
        io_supply    TYPE REF TO zif_supply_reader
        io_demand    TYPE REF TO zif_demand_reader
        io_gross     TYPE REF TO zif_demand_reader OPTIONAL
        io_engine    TYPE REF TO zcl_allocation_engine
        io_authority TYPE REF TO zif_allocation_authority
        iv_today     TYPE d OPTIONAL.

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

    DATA mo_converter TYPE REF TO zif_unit_converter.

    CONSTANTS c_width_id   TYPE i VALUE 26.
    CONSTANTS c_width_date TYPE i VALUE 12.
    CONSTANTS c_width_qty  TYPE i VALUE 14.

    "! Reading a situation, not changing it.
    CONSTANTS c_activity_display TYPE activ_auth VALUE '03'.

    DATA mo_supply    TYPE REF TO zif_supply_reader.
    DATA mo_demand    TYPE REF TO zif_demand_reader.
    DATA mo_gross     TYPE REF TO zif_demand_reader.
    DATA mo_engine    TYPE REF TO zcl_allocation_engine.
    DATA mo_authority TYPE REF TO zif_allocation_authority.

    "! The material being explained, so that the parts of the page that have
    "! to ask the documents something know what to ask about.
    DATA mv_matnr TYPE mard-matnr.
    DATA mv_werks TYPE mard-werks.
    DATA mv_today     TYPE d.

    METHODS unit_of
      IMPORTING
        iv_matnr      TYPE mard-matnr
      RETURNING
        VALUE(rv_uom) TYPE string.

    METHODS rule_lines
      IMPORTING
        iv_matnr       TYPE mard-matnr
        iv_werks       TYPE mard-werks
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab.

    METHODS supply_lines
      IMPORTING
        it_supply      TYPE zif_supply_reader=>ty_supply_tab
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab.

    METHODS why_nothing_is_waiting
      IMPORTING
        iv_matnr       TYPE mard-matnr
        iv_werks       TYPE mard-werks
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab.

    METHODS demand_lines
      IMPORTING
        it_demand      TYPE zif_allocation=>ty_demand_tab
        it_gross       TYPE zif_allocation=>ty_demand_tab
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab.

    METHODS gross_of
      IMPORTING
        it_gross           TYPE zif_allocation=>ty_demand_tab
        iv_demand_id       TYPE zif_allocation=>ty_demand_id
      RETURNING
        VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity.

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
      iv_lgort     = is_settings-lgort
      iv_planned   = is_settings-planned ).
    " two readers on purpose: what the documents ask for, and what is left of
    " it once the deliveries and the earlier runs have been taken off. The
    " answer is worked out from the second, because that is what a run works
    " with; the first is there so the difference can be shown rather than
    " leaving somebody to wonder why a line of ten is asking for four.
    DATA(lo_gross)  = zcl_allocation_service=>create_default_demand(
      io_converter = lo_converter
      iv_ship_days = is_settings-ship_days ).
    DATA(lo_demand) = zcl_allocation_service=>create_default_open_demand(
      io_converter    = lo_converter
      iv_horizon_days = is_settings-horizon_days
      iv_ship_days    = is_settings-ship_days
      iv_age_days     = is_settings-age_days
      iv_work_days    = is_settings-work_days
      iv_sto_priority = is_settings-sto_priority ).

    ro_explain = NEW zcl_alloc_explain(
      io_supply    = lo_supply
      io_demand    = lo_demand
      io_gross     = lo_gross
      io_engine    = NEW zcl_allocation_engine(
        io_supply_reader = lo_supply
        io_demand_reader = lo_demand
        io_strategy      = zcl_allocation_service=>create_default_strategy(
          is_settings = is_settings
          io_strategy = io_strategy ) )
      io_authority = NEW zcl_authority_alloc( c_activity_display ) ).

  ENDMETHOD.

  METHOD create_for_plant.

    DATA(ls_settings) = CAST zif_alloc_config( NEW zcl_alloc_config( ) )->for_plant( iv_werks ).

    ro_explain = create_default(
      is_settings = ls_settings
      io_strategy = zcl_alloc_config=>strategy_of( ls_settings ) ).

  ENDMETHOD.

  METHOD constructor.

    mo_supply    = io_supply.
    mo_converter = NEW zcl_unit_converter( ).
    mo_demand    = io_demand.
    mo_gross     = io_gross.
    mo_engine    = io_engine.
    mo_authority = io_authority.

    " the day is handed in so a test can say what today is
    mv_today = iv_today.
    IF mv_today IS INITIAL.
      mv_today = sy-datum.
    ENDIF.

  ENDMETHOD.

  METHOD run.

    DATA lt_gross TYPE zif_allocation=>ty_demand_tab.

    mo_authority->check_plant( iv_werks ).

    mv_matnr = iv_matnr.
    mv_werks = iv_werks.

    APPEND |Material { iv_matnr } in plant { iv_werks }| &&
           COND string( WHEN unit_of( iv_matnr ) IS NOT INITIAL
                        THEN |, quantities in { unit_of( iv_matnr ) }| ) TO rt_line.

    " a material the plant has put on hold reads as a material nobody wants,
    " because the demand readers leave it out. An explanation that goes quiet
    " on the one question it exists to answer is worse than no explanation.
    DATA(lv_hold) = zcl_alloc_hold=>reason_for(
      iv_matnr = iv_matnr
      iv_werks = iv_werks
      iv_today = mv_today ).
    IF lv_hold IS NOT INITIAL.
      APPEND |On hold: { lv_hold }| TO rt_line.
      APPEND `Nothing is allocated for a material on hold, whatever is waiting` TO rt_line.
    ENDIF.

    APPEND LINES OF rule_lines(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ) TO rt_line.

    APPEND LINES OF supply_lines( mo_supply->read_supply(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ) ) TO rt_line.

    DATA(lt_demand) = mo_demand->read_open_demand(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    IF mo_gross IS BOUND.
      lt_gross = mo_gross->read_open_demand(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ).
    ENDIF.

    APPEND LINES OF demand_lines(
      it_demand = lt_demand
      it_gross  = lt_gross ) TO rt_line.

    " the same calculation a run does, thrown away afterwards. Reading it back
    " from the last recorded run would show what was true last night, and the
    " question is always about now.
    APPEND LINES OF answer_lines( mo_engine->allocate(
      iv_matnr  = iv_matnr
      iv_werks  = iv_werks
      it_demand = lt_demand ) ) TO rt_line.

  ENDMETHOD.

  METHOD unit_of.

    " every quantity below is in the base unit of the material, and a page of
    " numbers that does not say which unit that is asks the reader to know
    TRY.
        rv_uom = |{ mo_converter->base_unit( iv_matnr ) }|.
      CATCH zcx_allocation.
        CLEAR rv_uom.
    ENDTRY.

  ENDMETHOD.

  METHOD rule_lines.

    " what has been set aside or agreed for this material, in the rows the
    " rules themselves read. A planner looking at an answer that does not
    " follow from the priorities is looking for exactly these two tables, and
    " an explanation that leaves them out sends them to SE16.
    LOOP AT zcl_alloc_promised=>promised_for(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ) INTO DATA(ls_promise).

      IF lines( rt_line ) = 0.
        APPEND `Promised by hand` TO rt_line.
      ENDIF.

      APPEND |  { ls_promise-demand_id } { ls_promise-quantity }| &&
             COND string( WHEN ls_promise-valid_to IS NOT INITIAL
                          THEN | until { ls_promise-valid_to DATE = ISO }| ) &&
             COND string( WHEN ls_promise-reason IS NOT INITIAL
                          THEN |, { ls_promise-reason }| ) TO rt_line.

    ENDLOOP.

    DATA(lv_quotas) = abap_false.

    LOOP AT zcl_alloc_quota=>quotas_for(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ) INTO DATA(ls_quota).

      IF lv_quotas = abap_false.
        APPEND `Quotas agreed` TO rt_line.
        lv_quotas = abap_true.
      ENDIF.

      APPEND |  { COND string( WHEN ls_quota-kunnr IS INITIAL
                               THEN `everybody`
                               ELSE |{ ls_quota-kunnr }| ) } | &&
             |{ ls_quota-quantity } for | &&
             |{ ls_quota-date_from DATE = ISO } to { ls_quota-date_to DATE = ISO }| TO rt_line.

    ENDLOOP.

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

  METHOD why_nothing_is_waiting.

    " "nothing is waiting" is true of a material nobody has ordered and of one
    " whose every order was thrown out by a filter, and those are not the same
    " news at all. The readers cannot say which, because by the time they have
    " finished there is nothing left to say it about, so the explanation asks
    " the documents itself -- the one place in the solution that reads them a
    " second way, and the reason is that it is explaining the first way.
    SELECT SINGLE lvorm
      FROM mara
      WHERE matnr = @iv_matnr
      INTO @DATA(lv_flagged).
    IF sy-subrc = 0 AND lv_flagged <> space.
      APPEND `  the material is flagged for deletion` TO rt_line.
      RETURN.
    ENDIF.

    SELECT SINGLE lvorm
      FROM marc
      WHERE matnr = @iv_matnr
        AND werks = @iv_werks
      INTO @DATA(lv_plant_flag).
    IF sy-subrc = 0 AND lv_plant_flag <> space.
      APPEND `  the material is flagged for deletion in this plant` TO rt_line.
      RETURN.
    ENDIF.

    SELECT COUNT( * )
      FROM vbap
      WHERE matnr = @iv_matnr
        AND werks = @iv_werks
      INTO @DATA(lv_items).
    IF sy-subrc <> 0 OR lv_items = 0.
      APPEND `  no sales order line has ever asked for it here` TO rt_line.
      RETURN.
    ENDIF.

    APPEND |  { lv_items } sales order line(s) exist and none of them counts: | &&
           |delivered, rejected, blocked, credit blocked, on its own stock, | &&
           |or beyond the horizon| TO rt_line.

  ENDMETHOD.

  METHOD demand_lines.

    " typed explicitly: an inline declaration from arithmetic loses the
    " decimals, see ANOMALIES.md
    DATA lv_total  TYPE zif_allocation=>ty_quantity.
    DATA lv_served TYPE zif_allocation=>ty_quantity.

    APPEND || TO rt_line.
    APPEND `What is waiting for it, and what is already taken care of` TO rt_line.

    IF it_demand IS INITIAL.
      APPEND `  nothing` TO rt_line.
      APPEND LINES OF why_nothing_is_waiting(
        iv_matnr = mv_matnr
        iv_werks = mv_werks ) TO rt_line.
      RETURN.
    ENDIF.

    LOOP AT it_demand INTO DATA(ls_demand).

      lv_total = lv_total + ls_demand-quantity.

      " what the order asks for, and what is left of it: the difference is
      " what deliveries and earlier runs have already taken care of, which is
      " the first thing anybody wonders about a line asking for less than it
      " was written for
      DATA(lv_gross) = gross_of(
        it_gross     = it_gross
        iv_demand_id = ls_demand-demand_id ).

      lv_served = lv_gross - ls_demand-quantity.

      APPEND |  { ls_demand-demand_id WIDTH = c_width_id }| &&
             |{ date_text( ls_demand-req_date ) WIDTH = c_width_date }| &&
             |{ ls_demand-quantity WIDTH = c_width_qty ALIGN = RIGHT }| &&
             |{ COND string( WHEN lv_served > 0
                             THEN |{ lv_served }|
                             ELSE `` ) WIDTH = c_width_qty ALIGN = RIGHT }| &&
             |  { ls_demand-priority }  { ls_demand-customer }| TO rt_line.

    ENDLOOP.

    APPEND |  { `Total` WIDTH = c_width_id }| &&
           |{ `` WIDTH = c_width_date }| &&
           |{ lv_total WIDTH = c_width_qty ALIGN = RIGHT }| TO rt_line.

  ENDMETHOD.

  METHOD gross_of.

    READ TABLE it_gross INTO DATA(ls_gross)
      WITH KEY demand_id = iv_demand_id.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    rv_quantity = ls_gross-quantity.

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
