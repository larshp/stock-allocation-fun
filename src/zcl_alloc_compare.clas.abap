CLASS zcl_alloc_compare DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_line_tab TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    "! <p class="shorttext synchronized">Comparison wired up the way a plain SAP system needs it</p>
    "!
    "!
    "! The settings travel as one structure, for the reason feature 126 gives.
    "!
    "! @parameter is_settings | <p class="shorttext synchronized">The plant's settings, as Customizing has them</p>
    "! @parameter ro_compare | <p class="shorttext synchronized">Ready to use</p>
    CLASS-METHODS create_default
      IMPORTING
        is_settings       TYPE zif_alloc_config=>ty_config
      RETURNING
        VALUE(ro_compare) TYPE REF TO zcl_alloc_compare.

    "! <p class="shorttext synchronized">Comparison, wired up for a plant</p>
    "!
    "! Everything but the question comes from the plant's own settings, read
    "! here rather than by the caller: an answer worked out by different rules
    "! than the run uses is answering a different question in the same words,
    "! and a factory that cannot read them itself is one that will be called
    "! wrongly. Feature 92 is what that looks like when it happens.
    "!
    "! @parameter iv_werks | <p class="shorttext synchronized">Plant</p>
    "! @parameter ro_compare | <p class="shorttext synchronized">Ready to use, as the plant would</p>
    CLASS-METHODS create_for_plant
      IMPORTING
        iv_werks          TYPE mard-werks
      RETURNING
        VALUE(ro_compare) TYPE REF TO zcl_alloc_compare.

    "! <p class="shorttext synchronized">Wire up the comparison</p>
    "!
    "! @parameter io_supply    | <p class="shorttext synchronized">What the plant has to give away</p>
    "! @parameter io_demand    | <p class="shorttext synchronized">What is waiting for it</p>
    "! @parameter io_authority | <p class="shorttext synchronized">Decides who may see a plant</p>
    "! @parameter is_settings  | <p class="shorttext synchronized">The plant's other settings, kept by both</p>
    METHODS constructor
      IMPORTING
        io_supply    TYPE REF TO zif_supply_reader
        io_demand    TYPE REF TO zif_demand_reader
        io_authority TYPE REF TO zif_allocation_authority
        is_settings  TYPE zif_alloc_config=>ty_config OPTIONAL.

    "! <p class="shorttext synchronized">What each distribution rule would confirm</p>
    "!
    "! A plant chooses between priority and fair share once, in Customizing,
    "! and usually without ever seeing what the other one would have done. This
    "! runs both over the same stock and the same demand and puts the two
    "! answers next to each other, which is the only way that choice can be
    "! made on anything but a feeling.
    "!
    "! It allocates nothing, records nothing and reserves nothing.
    "!
    "! @parameter iv_matnr       | <p class="shorttext synchronized">Material number</p>
    "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
    "! @parameter iv_cap_percent | <p class="shorttext synchronized">Most one customer may take, 0 for no cap</p>
    "! @parameter iv_whole_units | <p class="shorttext synchronized">Confirm whole order units only</p>
    "! @parameter iv_quota       | <p class="shorttext synchronized">Hold customers to the quotas they agreed</p>
    "! @parameter rt_line        | <p class="shorttext synchronized">Lines to display</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">Plant may not be seen, or reading failed</p>
    METHODS run
      IMPORTING
        iv_matnr       TYPE mard-matnr
        iv_werks       TYPE mard-werks
        iv_cap_percent TYPE i DEFAULT zcl_alloc_customer_cap=>c_no_cap
        iv_whole_units TYPE abap_bool DEFAULT abap_false
        iv_quota       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab
      RAISING
        zcx_allocation.

  PRIVATE SECTION.

    CONSTANTS c_width_id  TYPE i VALUE 26.
    CONSTANTS c_width_qty TYPE i VALUE 14.

    "! Working out what would happen, not making it happen.
    CONSTANTS c_activity_display TYPE activ_auth VALUE '03'.

    DATA mo_supply    TYPE REF TO zif_supply_reader.
    DATA mo_demand    TYPE REF TO zif_demand_reader.
    DATA mo_authority TYPE REF TO zif_allocation_authority.

    "! Everything the plant is set to do that this report is not comparing:
    "! the bar of feature 141, the firm zone of feature 146, and whatever is
    "! added next. Both answers are worked out with it, or the comparison is
    "! between two rules neither of which the plant would have applied.
    DATA ms_settings TYPE zif_alloc_config=>ty_config.

    METHODS answer_of
      IMPORTING
        io_strategy          TYPE REF TO zif_allocation_strategy
        iv_matnr             TYPE mard-matnr
        iv_werks             TYPE mard-werks
        it_demand            TYPE zif_allocation=>ty_demand_tab
        iv_cap_percent       TYPE i
        iv_whole_units       TYPE abap_bool
        iv_quota             TYPE abap_bool
      RETURNING
        VALUE(rt_allocation) TYPE zif_allocation=>ty_allocation_tab
      RAISING
        zcx_allocation.

    METHODS confirmed_for
      IMPORTING
        it_allocation      TYPE zif_allocation=>ty_allocation_tab
        iv_demand_id       TYPE zif_allocation=>ty_demand_id
      RETURNING
        VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity.

    METHODS whole_lines
      IMPORTING
        it_demand       TYPE zif_allocation=>ty_demand_tab
        it_allocation   TYPE zif_allocation=>ty_allocation_tab
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_compare IMPLEMENTATION.

  METHOD create_default.

    DATA(lo_converter) = NEW zcl_unit_converter( ).

    ro_compare = NEW zcl_alloc_compare(
      io_supply    = zcl_allocation_service=>create_default_supply(
        is_settings  = is_settings
        io_converter = lo_converter )
      io_demand    = zcl_allocation_service=>create_default_open_demand(
        is_settings  = is_settings
        io_converter = lo_converter )
      io_authority = NEW zcl_authority_alloc( c_activity_display )
      is_settings  = is_settings ).

  ENDMETHOD.

  METHOD create_for_plant.

    DATA(ls_settings) = CAST zif_alloc_config( NEW zcl_alloc_config( ) )->for_plant( iv_werks ).

    " the rules the comparison is asking about -- the cap, whole units, the
    " quota -- are arguments of RUN rather than settings here: that is the
    " whole point of the report the comparison serves
    ro_compare = create_default( ls_settings ).

  ENDMETHOD.

  METHOD constructor.

    mo_supply    = io_supply.
    mo_demand    = io_demand.
    mo_authority = io_authority.
    ms_settings  = is_settings.

  ENDMETHOD.

  METHOD run.

    DATA lv_priority_total TYPE zif_allocation=>ty_quantity.
    DATA lv_fair_total     TYPE zif_allocation=>ty_quantity.

    mo_authority->check_plant( iv_werks ).

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

    " the demand is read once and both rules are given the same of it. Reading
    " it twice would let an order arriving between the two reads look like a
    " difference between the rules.
    DATA(lt_demand) = mo_demand->read_open_demand(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    APPEND |Material { iv_matnr } in plant { iv_werks }, rule against rule| TO rt_line.

    IF lt_demand IS INITIAL.
      APPEND `Nothing is waiting for this material` TO rt_line.
      RETURN.
    ENDIF.

    DATA(lt_priority) = answer_of(
      io_strategy    = NEW zcl_alloc_strategy_priority( )
      iv_matnr       = iv_matnr
      iv_werks       = iv_werks
      it_demand      = lt_demand
      iv_cap_percent = iv_cap_percent
      iv_whole_units = iv_whole_units
      iv_quota       = iv_quota ).

    DATA(lt_fair) = answer_of(
      io_strategy    = NEW zcl_alloc_strategy_fairshare( )
      iv_matnr       = iv_matnr
      iv_werks       = iv_werks
      it_demand      = lt_demand
      iv_cap_percent = iv_cap_percent
      iv_whole_units = iv_whole_units
      iv_quota       = iv_quota ).

    APPEND |{ `Demand` WIDTH = c_width_id }| &&
           |{ `Requested` WIDTH = c_width_qty ALIGN = RIGHT }| &&
           |{ `By priority` WIDTH = c_width_qty ALIGN = RIGHT }| &&
           |{ `Fair share` WIDTH = c_width_qty ALIGN = RIGHT }| TO rt_line.

    LOOP AT lt_demand INTO DATA(ls_demand).

      DATA(lv_priority) = confirmed_for(
        it_allocation = lt_priority
        iv_demand_id  = ls_demand-demand_id ).
      DATA(lv_fair)     = confirmed_for(
        it_allocation = lt_fair
        iv_demand_id  = ls_demand-demand_id ).

      lv_priority_total = lv_priority_total + lv_priority.
      lv_fair_total     = lv_fair_total + lv_fair.

      APPEND |{ ls_demand-demand_id WIDTH = c_width_id }| &&
             |{ ls_demand-quantity WIDTH = c_width_qty ALIGN = RIGHT }| &&
             |{ lv_priority WIDTH = c_width_qty ALIGN = RIGHT }| &&
             |{ lv_fair WIDTH = c_width_qty ALIGN = RIGHT }| TO rt_line.

    ENDLOOP.

    APPEND |{ `Total` WIDTH = c_width_id }| &&
           |{ `` WIDTH = c_width_qty }| &&
           |{ lv_priority_total WIDTH = c_width_qty ALIGN = RIGHT }| &&
           |{ lv_fair_total WIDTH = c_width_qty ALIGN = RIGHT }| TO rt_line.

    " the totals are usually the same, because both rules hand out the same
    " stock. What differs is who ends up with a line they can actually ship,
    " and that is the number the choice is really about.
    APPEND || TO rt_line.
    APPEND |Lines served in full: | &&
           |{ whole_lines( it_demand     = lt_demand
                           it_allocation = lt_priority ) } by priority, | &&
           |{ whole_lines( it_demand     = lt_demand
                           it_allocation = lt_fair ) } by fair share| TO rt_line.

  ENDMETHOD.

  METHOD answer_of.

    " the same decorators the run puts around a strategy, from the same place,
    " so that what is compared is the rule and not the wrapping. The three
    " rules this report exists to compare are arguments rather than settings,
    " so they are put into the plant's settings on the way past and everything
    " else the plant is set to do is left exactly as it is: a comparison that
    " quietly drops the rest is comparing two runs the plant would never make.
    DATA(ls_settings) = ms_settings.
    ls_settings-cap_percent = iv_cap_percent.
    ls_settings-whole_units = iv_whole_units.
    ls_settings-quota       = iv_quota.

    DATA(lo_strategy) = zcl_allocation_service=>create_default_strategy(
      is_settings = ls_settings
      io_strategy = io_strategy ).

    rt_allocation = NEW zcl_allocation_engine(
      io_supply_reader = mo_supply
      io_demand_reader = mo_demand
      io_strategy      = lo_strategy )->allocate(
        iv_matnr  = iv_matnr
        iv_werks  = iv_werks
        it_demand = it_demand ).

  ENDMETHOD.

  METHOD confirmed_for.

    READ TABLE it_allocation INTO DATA(ls_allocation)
      WITH KEY demand_id = iv_demand_id.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    rv_quantity = ls_allocation-confirmed.

  ENDMETHOD.

  METHOD whole_lines.

    LOOP AT it_demand INTO DATA(ls_demand).

      READ TABLE it_allocation INTO DATA(ls_allocation)
        WITH KEY demand_id = ls_demand-demand_id.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      IF ls_allocation-confirmed >= ls_demand-quantity
          AND ls_demand-quantity > 0.
        rv_count = rv_count + 1.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
