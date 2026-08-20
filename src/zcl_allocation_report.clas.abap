CLASS zcl_allocation_report DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_line_tab TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    "! <p class="shorttext synchronized">Wire up the report</p>
    "!
    "! @parameter io_mass_run | <p class="shorttext synchronized">Does the allocating</p>
    METHODS constructor
      IMPORTING
        io_mass_run TYPE REF TO zcl_allocation_mass_run.

    "! <p class="shorttext synchronized">Run an allocation and lay the outcome out as text</p>
    "!
    "! Returns the lines rather than writing them, so what the user ends up
    "! reading can be asserted in a test. A material that was rejected shows the
    "! reason in place of its figures; the run as a whole still comes back.
    "!
    "! @parameter iv_werks | <p class="shorttext synchronized">Plant</p>
    "! @parameter it_matnr    | <p class="shorttext synchronized">Materials, everything waiting if empty</p>
    "! @parameter iv_simulate | <p class="shorttext synchronized">Work it out but change nothing</p>
    "! @parameter rt_line     | <p class="shorttext synchronized">Lines to display</p>
    METHODS run
      IMPORTING
        iv_werks       TYPE mard-werks
        it_matnr       TYPE zif_demand_reader=>ty_matnr_tab OPTIONAL
        iv_simulate    TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab.

  PRIVATE SECTION.

    CONSTANTS c_width_id  TYPE i VALUE 26.
    CONSTANTS c_width_qty TYPE i VALUE 14.
    CONSTANTS c_width_why TYPE i VALUE 22.

    DATA mo_mass_run TYPE REF TO zcl_allocation_mass_run.

    METHODS lines_for_run
      IMPORTING
        is_run         TYPE zif_allocation_service=>ty_run
        iv_simulate    TYPE abap_bool
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab.

    METHODS format_row
      IMPORTING
        iv_id          TYPE string
        iv_requested   TYPE string
        iv_confirmed   TYPE string
        iv_shortfall   TYPE string
        iv_available   TYPE string
        iv_reason      TYPE string
      RETURNING
        VALUE(rv_line) TYPE string.

    METHODS available_text
      IMPORTING
        iv_avail_date  TYPE d
        iv_confirmed   TYPE zif_allocation=>ty_quantity
      RETURNING
        VALUE(rv_text) TYPE string.

ENDCLASS.


CLASS zcl_allocation_report IMPLEMENTATION.

  METHOD constructor.
    mo_mass_run = io_mass_run.
  ENDMETHOD.

  METHOD run.

    DATA lv_failed TYPE i.

    DATA(lt_outcome) = mo_mass_run->run(
      iv_werks    = iv_werks
      it_matnr    = it_matnr
      iv_simulate = iv_simulate ).

    APPEND |Plant { iv_werks }| TO rt_line.
    IF iv_simulate = abap_true.
      APPEND `Simulation, nothing was recorded and no stock was reserved` TO rt_line.
    ENDIF.

    LOOP AT lt_outcome INTO DATA(ls_outcome).

      APPEND || TO rt_line.
      APPEND |Material { ls_outcome-matnr }| TO rt_line.

      IF ls_outcome-failed = abap_true.
        lv_failed = lv_failed + 1.
        APPEND |Allocation failed: { ls_outcome-reason }| TO rt_line.
      ELSE.
        APPEND LINES OF lines_for_run(
          is_run      = ls_outcome-run
          iv_simulate = iv_simulate ) TO rt_line.
      ENDIF.

    ENDLOOP.

    APPEND || TO rt_line.
    APPEND |{ lines( lt_outcome ) } materials, { lv_failed } failed| TO rt_line.

  ENDMETHOD.

  METHOD lines_for_run.

    DATA lv_requested TYPE zif_allocation=>ty_quantity.
    DATA lv_confirmed TYPE zif_allocation=>ty_quantity.
    DATA lv_shortfall TYPE zif_allocation=>ty_quantity.

    IF iv_simulate = abap_false.
      APPEND |Run         { is_run-run_id }| TO rt_line.
      APPEND |Reservation { is_run-reservation }| TO rt_line.
    ENDIF.

    APPEND format_row(
      iv_id        = `Demand`
      iv_requested = `Requested`
      iv_confirmed = `Confirmed`
      iv_shortfall = `Shortfall`
      iv_available = `Available`
      iv_reason    = `Why` ) TO rt_line.

    LOOP AT is_run-allocation INTO DATA(ls_allocation).
      lv_requested = lv_requested + ls_allocation-requested.
      lv_confirmed = lv_confirmed + ls_allocation-confirmed.
      lv_shortfall = lv_shortfall + ls_allocation-shortfall.
      APPEND format_row(
        iv_id        = |{ ls_allocation-demand_id }|
        iv_requested = |{ ls_allocation-requested }|
        iv_confirmed = |{ ls_allocation-confirmed }|
        iv_shortfall = |{ ls_allocation-shortfall }|
        iv_available = available_text(
          iv_avail_date = ls_allocation-avail_date
          iv_confirmed  = ls_allocation-confirmed )
        iv_reason    = zcl_alloc_reason_text=>text( ls_allocation-reason ) ) TO rt_line.
    ENDLOOP.

    APPEND format_row(
      iv_id        = `Total`
      iv_requested = |{ lv_requested }|
      iv_confirmed = |{ lv_confirmed }|
      iv_shortfall = |{ lv_shortfall }|
      iv_available = ``
      iv_reason    = `` ) TO rt_line.

  ENDMETHOD.

  METHOD format_row.

    rv_line = |{ iv_id WIDTH = c_width_id }|
           && |{ iv_requested WIDTH = c_width_qty ALIGN = RIGHT }|
           && |{ iv_confirmed WIDTH = c_width_qty ALIGN = RIGHT }|
           && |{ iv_shortfall WIDTH = c_width_qty ALIGN = RIGHT }|
           && |{ iv_available WIDTH = c_width_qty ALIGN = RIGHT }|
           && |  { iv_reason WIDTH = c_width_why }|.

  ENDMETHOD.

  METHOD available_text.

    " a line that got nothing has no day it is there on, and one served off the
    " shelf is there already. The rest say the day the last of their supply
    " arrives, written so it reads as a date rather than eight digits.
    IF iv_confirmed <= 0.
      RETURN.
    ENDIF.
    IF iv_avail_date IS INITIAL.
      rv_text = `now`.
      RETURN.
    ENDIF.

    rv_text = |{ iv_avail_date+0(4) }-{ iv_avail_date+4(2) }-{ iv_avail_date+6(2) }|.

  ENDMETHOD.

ENDCLASS.
