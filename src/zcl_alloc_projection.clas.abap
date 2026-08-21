CLASS zcl_alloc_projection DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_line_tab TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    "! One period of the projection: what comes in, what goes out, and what is
    "! left at the end of it.
    TYPES:
      BEGIN OF ty_bucket,
        from    TYPE d,
        to      TYPE d,
        supply  TYPE zif_allocation=>ty_quantity,
        demand  TYPE zif_allocation=>ty_quantity,
        balance TYPE zif_allocation=>ty_quantity,
      END OF ty_bucket.
    TYPES ty_bucket_tab TYPE STANDARD TABLE OF ty_bucket WITH EMPTY KEY.

    CONSTANTS c_default_days    TYPE i VALUE 7.
    CONSTANTS c_default_buckets TYPE i VALUE 8.

    "! <p class="shorttext synchronized">Projection wired up the way a plain SAP system needs it</p>
    "!
    "! @parameter iv_lgort      | <p class="shorttext synchronized">Location to count, all if empty</p>
    "! @parameter iv_planned    | <p class="shorttext synchronized">Planned orders count as supply too</p>
    "! @parameter iv_horizon_days | <p class="shorttext synchronized">Days ahead to look, 0 for no limit</p>
    "! @parameter iv_ship_days  | <p class="shorttext synchronized">Days between the goods being ready and gone</p>
    "! @parameter iv_age_days   | <p class="shorttext synchronized">Wait that earns a line a place, 0 for none</p>
    "! @parameter iv_work_days | <p class="shorttext synchronized">Shipping time counts working days only</p>
    "! @parameter iv_sto_priority | <p class="shorttext synchronized">Where a transfer stands against an order</p>
    "! @parameter ro_projection | <p class="shorttext synchronized">Ready to use projection</p>
    CLASS-METHODS create_default
      IMPORTING
        iv_lgort             TYPE mard-lgort OPTIONAL
        iv_planned           TYPE abap_bool DEFAULT abap_false
        iv_horizon_days      TYPE i DEFAULT zcl_demand_within_horizon=>c_no_horizon
        iv_ship_days         TYPE i DEFAULT 0
        iv_age_days          TYPE i DEFAULT zcl_demand_aging=>c_never
        iv_work_days         TYPE abap_bool DEFAULT abap_false
        iv_sto_priority      TYPE zif_allocation=>ty_priority DEFAULT zcl_sto_demand_reader=>c_default_priority
      RETURNING
        VALUE(ro_projection) TYPE REF TO zcl_alloc_projection.

    "! <p class="shorttext synchronized">Projection, wired up for a plant</p>
    "!
    "! Everything but the question comes from the plant's own settings, read
    "! here rather than by the caller: an answer worked out by different rules
    "! than the run uses is answering a different question in the same words,
    "! and a factory that cannot read them itself is one that will be called
    "! wrongly. Feature 92 is what that looks like when it happens.
    "!
    "! @parameter iv_werks | <p class="shorttext synchronized">Plant</p>
    "! @parameter ro_projection | <p class="shorttext synchronized">Ready to use, as the plant would</p>
    CLASS-METHODS create_for_plant
      IMPORTING
        iv_werks             TYPE mard-werks
      RETURNING
        VALUE(ro_projection) TYPE REF TO zcl_alloc_projection.

    "! <p class="shorttext synchronized">Wire up the projection</p>
    "!
    "! @parameter io_supply    | <p class="shorttext synchronized">What the plant has to give away</p>
    "! @parameter io_demand    | <p class="shorttext synchronized">What is waiting for it</p>
    "! @parameter io_authority | <p class="shorttext synchronized">Decides who may see a plant</p>
    "! @parameter iv_today     | <p class="shorttext synchronized">Day to project from, today if empty</p>
    METHODS constructor
      IMPORTING
        io_supply    TYPE REF TO zif_supply_reader
        io_demand    TYPE REF TO zif_demand_reader
        io_authority TYPE REF TO zif_allocation_authority
        iv_today     TYPE d OPTIONAL.

    "! <p class="shorttext synchronized">How a material stands week by week, and when it runs out</p>
    "!
    "! The allocation answers "who gets what today". This answers the question
    "! a planner asks before that one: is there going to be enough, and if not,
    "! from when. Every day of supply and every requirement, put into periods
    "! and added up, with the balance carried from one to the next.
    "!
    "! @parameter iv_matnr       | <p class="shorttext synchronized">Material number</p>
    "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
    "! @parameter iv_days        | <p class="shorttext synchronized">Days in a period, a week by default</p>
    "! @parameter iv_buckets     | <p class="shorttext synchronized">How many periods to show</p>
    "! @parameter rt_bucket      | <p class="shorttext synchronized">One entry per period, earliest first</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">Plant may not be seen, or reading failed</p>
    METHODS periods
      IMPORTING
        iv_matnr         TYPE mard-matnr
        iv_werks         TYPE mard-werks
        iv_days          TYPE i DEFAULT c_default_days
        iv_buckets       TYPE i DEFAULT c_default_buckets
      RETURNING
        VALUE(rt_bucket) TYPE ty_bucket_tab
      RAISING
        zcx_allocation.

    "! <p class="shorttext synchronized">The same, laid out to be read</p>
    "!
    "! @parameter iv_matnr       | <p class="shorttext synchronized">Material number</p>
    "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
    "! @parameter iv_days        | <p class="shorttext synchronized">Days in a period, a week by default</p>
    "! @parameter iv_buckets     | <p class="shorttext synchronized">How many periods to show</p>
    "! @parameter rt_line        | <p class="shorttext synchronized">Lines to display</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">Plant may not be seen, or reading failed</p>
    METHODS run
      IMPORTING
        iv_matnr       TYPE mard-matnr
        iv_werks       TYPE mard-werks
        iv_days        TYPE i DEFAULT c_default_days
        iv_buckets     TYPE i DEFAULT c_default_buckets
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab
      RAISING
        zcx_allocation.

  PRIVATE SECTION.

    CONSTANTS c_width_date TYPE i VALUE 12.
    CONSTANTS c_width_qty  TYPE i VALUE 14.

    "! Reading a situation, not changing it.
    CONSTANTS c_activity_display TYPE activ_auth VALUE '03'.

    DATA mo_supply    TYPE REF TO zif_supply_reader.
    DATA mo_demand    TYPE REF TO zif_demand_reader.
    DATA mo_authority TYPE REF TO zif_allocation_authority.
    DATA mv_today     TYPE d.

    METHODS empty_periods
      IMPORTING
        iv_days          TYPE i
        iv_buckets       TYPE i
      RETURNING
        VALUE(rt_bucket) TYPE ty_bucket_tab.

    METHODS date_text
      IMPORTING
        iv_date        TYPE d
      RETURNING
        VALUE(rv_text) TYPE string.

ENDCLASS.


CLASS zcl_alloc_projection IMPLEMENTATION.

  METHOD create_default.

    DATA(lo_converter) = NEW zcl_unit_converter( ).

    ro_projection = NEW zcl_alloc_projection(
      io_supply    = zcl_allocation_service=>create_default_supply(
        io_converter = lo_converter
        iv_lgort     = iv_lgort
        iv_planned   = iv_planned )
      io_demand    = zcl_allocation_service=>create_default_open_demand(
        io_converter    = lo_converter
        iv_horizon_days = iv_horizon_days
        iv_ship_days    = iv_ship_days
        iv_age_days     = iv_age_days
        iv_work_days    = iv_work_days
        iv_sto_priority = iv_sto_priority )
      io_authority = NEW zcl_authority_alloc( c_activity_display ) ).

  ENDMETHOD.

  METHOD create_for_plant.

    DATA(ls_settings) = CAST zif_alloc_config( NEW zcl_alloc_config( ) )->for_plant( iv_werks ).

    ro_projection = create_default(
      iv_lgort        = ls_settings-lgort
      iv_planned      = ls_settings-planned
      iv_horizon_days = ls_settings-horizon_days
      iv_ship_days    = ls_settings-ship_days
      iv_age_days     = ls_settings-age_days
      iv_work_days    = ls_settings-work_days
      iv_sto_priority = ls_settings-sto_priority ).

  ENDMETHOD.

  METHOD constructor.

    mo_supply    = io_supply.
    mo_demand    = io_demand.
    mo_authority = io_authority.

    " the day is handed in so a test can say what today is
    mv_today = iv_today.
    IF mv_today IS INITIAL.
      mv_today = sy-datum.
    ENDIF.

  ENDMETHOD.

  METHOD periods.

    DATA lv_balance TYPE zif_allocation=>ty_quantity.

    mo_authority->check_plant( iv_werks ).

    rt_bucket = empty_periods(
      iv_days    = iv_days
      iv_buckets = iv_buckets ).

    " stock on the shelf carries no date and belongs in the first period, and
    " so does a receipt that was due before today: both are there now
    LOOP AT mo_supply->read_supply(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ) INTO DATA(ls_supply).

      LOOP AT rt_bucket ASSIGNING FIELD-SYMBOL(<ls_bucket>).
        IF ls_supply-avail_date <= <ls_bucket>-to.
          <ls_bucket>-supply = <ls_bucket>-supply + ls_supply-quantity.
          EXIT.
        ENDIF.
      ENDLOOP.

    ENDLOOP.

    " a requirement with no date is wanted now, which is the first period, and
    " an overdue one is wanted now whatever its date says
    LOOP AT mo_demand->read_open_demand(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ) INTO DATA(ls_demand).

      " the period a requirement belongs in is the one the stock has to be
      " there in, not the one the customer wants it in: the run matches on the
      " same day and a projection that disagreed with it would be worse than
      " none
      DATA(lv_needed) = ls_demand-ready_by.
      IF lv_needed IS INITIAL.
        lv_needed = ls_demand-req_date.
      ENDIF.

      LOOP AT rt_bucket ASSIGNING <ls_bucket>.
        IF lv_needed <= <ls_bucket>-to.
          <ls_bucket>-demand = <ls_bucket>-demand + ls_demand-quantity.
          EXIT.
        ENDIF.
      ENDLOOP.

    ENDLOOP.

    " what is left at the end of one period is what the next one starts with,
    " which is the whole point of putting it in periods at all
    LOOP AT rt_bucket ASSIGNING <ls_bucket>.
      lv_balance          = lv_balance + <ls_bucket>-supply - <ls_bucket>-demand.
      <ls_bucket>-balance = lv_balance.
    ENDLOOP.

  ENDMETHOD.

  METHOD run.

    DATA lv_short TYPE abap_bool.

    DATA(lt_bucket) = periods(
      iv_matnr   = iv_matnr
      iv_werks   = iv_werks
      iv_days    = iv_days
      iv_buckets = iv_buckets ).

    APPEND |Material { iv_matnr } in plant { iv_werks }, | &&
           |{ iv_buckets } period(s) of { iv_days } day(s)| TO rt_line.

    APPEND |{ `From` WIDTH = c_width_date }| &&
           |{ `To` WIDTH = c_width_date }| &&
           |{ `In` WIDTH = c_width_qty ALIGN = RIGHT }| &&
           |{ `Out` WIDTH = c_width_qty ALIGN = RIGHT }| &&
           |{ `Left` WIDTH = c_width_qty ALIGN = RIGHT }| TO rt_line.

    LOOP AT lt_bucket INTO DATA(ls_bucket).

      APPEND |{ date_text( ls_bucket-from ) WIDTH = c_width_date }| &&
             |{ date_text( ls_bucket-to ) WIDTH = c_width_date }| &&
             |{ ls_bucket-supply WIDTH = c_width_qty ALIGN = RIGHT }| &&
             |{ ls_bucket-demand WIDTH = c_width_qty ALIGN = RIGHT }| &&
             |{ ls_bucket-balance WIDTH = c_width_qty ALIGN = RIGHT }| TO rt_line.

      " the first period the balance goes under is the answer somebody came
      " for, so it is said in words rather than left to be spotted in a column
      IF lv_short = abap_false AND ls_bucket-balance < 0.
        lv_short = abap_true.
        APPEND |  short from { date_text( ls_bucket-from ) }| TO rt_line.
      ENDIF.

    ENDLOOP.

    IF lv_short = abap_false.
      APPEND || TO rt_line.
      APPEND `Enough for every period shown` TO rt_line.
    ENDIF.

  ENDMETHOD.

  METHOD empty_periods.

    DATA lv_from    TYPE d.
    DATA lv_days    TYPE i.
    DATA lv_buckets TYPE i.

    " a number nobody set is the default rather than an empty answer: a
    " projection of no periods would print a heading, no rows, and the words
    " "enough for every period shown", which is true and useless
    lv_buckets = iv_buckets.
    IF lv_buckets <= 0.
      lv_buckets = c_default_buckets.
    ENDIF.

    " a period of no days would put everything in the first one and call it a
    " day, which is not a projection
    lv_days = iv_days.
    IF lv_days <= 0.
      lv_days = c_default_days.
    ENDIF.

    lv_from = mv_today.

    DO lv_buckets TIMES.
      APPEND VALUE #(
        from = lv_from
        to   = lv_from + lv_days - 1 ) TO rt_bucket.
      lv_from = lv_from + lv_days.
    ENDDO.

    " everything beyond the last period lands in one final one, so the columns
    " add up to what the material really has rather than to what fitted
    APPEND VALUE #(
      from = lv_from
      to   = '99991231' ) TO rt_bucket.

  ENDMETHOD.

  METHOD date_text.

    IF iv_date = '99991231'.
      rv_text = `later`.
      RETURN.
    ENDIF.

    rv_text = |{ iv_date+0(4) }-{ iv_date+4(2) }-{ iv_date+6(2) }|.

  ENDMETHOD.

ENDCLASS.
