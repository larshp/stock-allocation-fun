CLASS zcl_alloc_history DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_line_tab TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    "! <p class="shorttext synchronized">History wired up the way a plain SAP system needs it</p>
    "!
    "! @parameter ro_history | <p class="shorttext synchronized">Ready to use history</p>
    CLASS-METHODS create_default
      RETURNING
        VALUE(ro_history) TYPE REF TO zcl_alloc_history.

    "! <p class="shorttext synchronized">Wire up the history</p>
    "!
    "! @parameter io_authority | <p class="shorttext synchronized">Decides who may see a plant</p>
    METHODS constructor
      IMPORTING
        io_authority TYPE REF TO zif_allocation_authority.

    "! <p class="shorttext synchronized">What every run so far decided about one order</p>
    "!
    "! The display shows what the last run decided and the shortage list shows
    "! what is short tonight. Neither answers the question a customer actually
    "! asks, which is "what has been happening to my order": a line short every
    "! night for three weeks and a line short for the first time this morning
    "! look exactly the same in both of them, and they are not the same thing
    "! at all. Since feature 87 they are not treated the same either.
    "!
    "! One row per recorded run, oldest first, so the trail reads in the order
    "! it happened.
    "!
    "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
    "! @parameter iv_vbeln       | <p class="shorttext synchronized">Sales document</p>
    "! @parameter iv_posnr       | <p class="shorttext synchronized">Item, every one if empty</p>
    "! @parameter rt_line        | <p class="shorttext synchronized">Lines to display</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">Plant may not be seen</p>
    METHODS run
      IMPORTING
        iv_werks       TYPE mard-werks
        iv_vbeln       TYPE vbap-vbeln
        iv_posnr       TYPE vbap-posnr OPTIONAL
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab
      RAISING
        zcx_allocation.

  PRIVATE SECTION.

    CONSTANTS c_width_date   TYPE i VALUE 12.
    CONSTANTS c_width_id     TYPE i VALUE 26.
    CONSTANTS c_width_qty    TYPE i VALUE 14.
    CONSTANTS c_width_reason TYPE i VALUE 22.

    "! Reading what was decided, not deciding anything.
    CONSTANTS c_activity_display TYPE activ_auth VALUE '03'.

    "! The recorded runs are stamped in UTC, as they are written.
    CONSTANTS c_time_zone TYPE timezone VALUE 'UTC'.

    "! One recorded line. Declared explicitly rather than inferred with
    "! INTO TABLE @DATA(), see ANOMALIES.md.
    TYPES:
      BEGIN OF ty_row,
        demand_id  TYPE zstock_alloc_res-demand_id,
        created_at TYPE zstock_alloc_res-created_at,
        run_id     TYPE zstock_alloc_res-run_id,
        matnr      TYPE zstock_alloc_res-matnr,
        requested  TYPE zstock_alloc_res-requested,
        confirmed  TYPE zstock_alloc_res-confirmed,
        shortfall  TYPE zstock_alloc_res-shortfall,
        reason     TYPE zstock_alloc_res-reason,
      END OF ty_row.
    TYPES ty_row_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    DATA mo_authority TYPE REF TO zif_allocation_authority.

    METHODS rows_of
      IMPORTING
        iv_werks      TYPE mard-werks
        iv_vbeln      TYPE vbap-vbeln
        iv_posnr      TYPE vbap-posnr
      RETURNING
        VALUE(rt_row) TYPE ty_row_tab.

    METHODS lines_of_demand
      IMPORTING
        it_row         TYPE ty_row_tab
        iv_demand_id   TYPE zstock_alloc_res-demand_id
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab.

    METHODS format_row
      IMPORTING
        iv_when        TYPE string
        iv_run         TYPE string
        iv_requested   TYPE string
        iv_confirmed   TYPE string
        iv_reason      TYPE string
      RETURNING
        VALUE(rv_line) TYPE string.

ENDCLASS.


CLASS zcl_alloc_history IMPLEMENTATION.

  METHOD create_default.

    ro_history = NEW zcl_alloc_history( NEW zcl_authority_alloc( c_activity_display ) ).

  ENDMETHOD.

  METHOD constructor.
    mo_authority = io_authority.
  ENDMETHOD.

  METHOD run.

    DATA lv_demand_id TYPE zstock_alloc_res-demand_id.

    mo_authority->check_plant( iv_werks ).

    APPEND |Plant { iv_werks }, order { iv_vbeln }| &&
           COND string( WHEN iv_posnr IS NOT INITIAL
                        THEN | item { iv_posnr }| ) &&
           |, run by run| TO rt_line.

    DATA(lt_row) = rows_of(
      iv_werks = iv_werks
      iv_vbeln = iv_vbeln
      iv_posnr = iv_posnr ).

    IF lt_row IS INITIAL.
      APPEND `No run has ever decided anything about this order` TO rt_line.
      RETURN.
    ENDIF.

    " one section per schedule line, because that is the level a quantity is
    " wanted on a date and the level a run answers
    LOOP AT lt_row INTO DATA(ls_row).

      IF ls_row-demand_id = lv_demand_id.
        CONTINUE.
      ENDIF.
      lv_demand_id = ls_row-demand_id.

      APPEND || TO rt_line.
      APPEND LINES OF lines_of_demand(
        it_row       = lt_row
        iv_demand_id = lv_demand_id ) TO rt_line.

    ENDLOOP.

  ENDMETHOD.

  METHOD rows_of.

    DATA lv_pattern TYPE string.

    " the demand id of a sales order line is the document, then the item, then
    " the schedule line, as ZCL_SO_DEMAND_READER builds it. An item nobody
    " named matches every item of the document.
    IF iv_posnr IS INITIAL.
      lv_pattern = |{ iv_vbeln }%|.
    ELSE.
      lv_pattern = |{ iv_vbeln }{ iv_posnr }%|.
    ENDIF.

    SELECT demand_id,
           created_at,
           run_id,
           matnr,
           requested,
           confirmed,
           shortfall,
           reason
      FROM zstock_alloc_res
      WHERE werks = @iv_werks
        AND demand_id LIKE @lv_pattern
      ORDER BY demand_id ASCENDING, created_at ASCENDING
      INTO TABLE @rt_row.
    IF sy-subrc <> 0.
      CLEAR rt_row.
    ENDIF.

  ENDMETHOD.

  METHOD lines_of_demand.

    DATA lv_date  TYPE d.
    DATA lv_since TYPE d.
    DATA lv_short TYPE i.
    DATA lv_runs  TYPE i.

    LOOP AT it_row INTO DATA(ls_row)
        WHERE demand_id = iv_demand_id.

      IF lv_runs = 0.
        APPEND |{ ls_row-demand_id }, material { ls_row-matnr }| TO rt_line.
        APPEND format_row(
          iv_when      = `Recorded`
          iv_run       = `Run`
          iv_requested = `Wanted`
          iv_confirmed = `Got`
          iv_reason    = `Why not more` ) TO rt_line.
      ENDIF.

      lv_runs = lv_runs + 1.

      CONVERT TIME STAMP ls_row-created_at TIME ZONE c_time_zone
        INTO DATE lv_date.

      " how long it has been going short without a break, which is what the
      " escalation of feature 87 acts on and what a customer is really asking
      IF ls_row-shortfall > 0.
        lv_short = lv_short + 1.
        IF lv_since IS INITIAL.
          lv_since = lv_date.
        ENDIF.
      ELSE.
        lv_short = 0.
        CLEAR lv_since.
      ENDIF.

      APPEND format_row(
        iv_when      = |{ lv_date DATE = ISO }|
        iv_run       = |{ ls_row-run_id }|
        iv_requested = |{ ls_row-requested }|
        iv_confirmed = |{ ls_row-confirmed }|
        iv_reason    = zcl_alloc_reason_text=>text( ls_row-reason ) ) TO rt_line.

    ENDLOOP.

    IF lv_short = 0.
      APPEND |Served in full by the last of { lv_runs } run(s)| TO rt_line.
      RETURN.
    ENDIF.

    APPEND |Short in the last { lv_short } of { lv_runs } run(s), since { lv_since DATE = ISO }| TO rt_line.

  ENDMETHOD.

  METHOD format_row.

    rv_line = |{ iv_when WIDTH = c_width_date }|
           && |{ iv_run WIDTH = c_width_id }|
           && |{ iv_requested WIDTH = c_width_qty ALIGN = RIGHT }|
           && |{ iv_confirmed WIDTH = c_width_qty ALIGN = RIGHT }|
           && |  { iv_reason WIDTH = c_width_reason }|.

  ENDMETHOD.

ENDCLASS.
