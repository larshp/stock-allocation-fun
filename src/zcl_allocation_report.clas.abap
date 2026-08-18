CLASS zcl_allocation_report DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_line_tab TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    "! <p class="shorttext synchronized">Wire up the report</p>
    "!
    "! @parameter io_service | <p class="shorttext synchronized">Service that does the allocating</p>
    METHODS constructor
      IMPORTING
        io_service TYPE REF TO zif_allocation_service.

    "! <p class="shorttext synchronized">Run an allocation and lay the outcome out as text</p>
    "!
    "! Returns the lines rather than writing them, so what the user ends up
    "! reading can be asserted in a test. A rejected run comes back as a line
    "! saying so instead of an exception; the report has nowhere to throw to.
    "!
    "! @parameter iv_matnr | <p class="shorttext synchronized">Material number</p>
    "! @parameter iv_werks | <p class="shorttext synchronized">Plant</p>
    "! @parameter rt_line  | <p class="shorttext synchronized">Lines to display</p>
    METHODS run
      IMPORTING
        iv_matnr       TYPE mard-matnr
        iv_werks       TYPE mard-werks
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab.

  PRIVATE SECTION.

    CONSTANTS c_width_id  TYPE i VALUE 18.
    CONSTANTS c_width_qty TYPE i VALUE 14.

    DATA mo_service TYPE REF TO zif_allocation_service.

    METHODS format_row
      IMPORTING
        iv_id          TYPE string
        iv_requested   TYPE string
        iv_confirmed   TYPE string
        iv_shortfall   TYPE string
      RETURNING
        VALUE(rv_line) TYPE string.

ENDCLASS.


CLASS zcl_allocation_report IMPLEMENTATION.

  METHOD constructor.
    mo_service = io_service.
  ENDMETHOD.

  METHOD run.

    DATA lv_requested TYPE zif_allocation=>ty_quantity.
    DATA lv_confirmed TYPE zif_allocation=>ty_quantity.
    DATA lv_shortfall TYPE zif_allocation=>ty_quantity.

    TRY.
        DATA(ls_run) = mo_service->run(
          iv_matnr = iv_matnr
          iv_werks = iv_werks ).
      CATCH zcx_allocation INTO DATA(lx_error).
        APPEND |Allocation failed: { lx_error->get_text( ) }| TO rt_line.
        RETURN.
    ENDTRY.

    APPEND |Material    { iv_matnr } plant { iv_werks }| TO rt_line.
    APPEND |Run         { ls_run-run_id }| TO rt_line.
    APPEND |Reservation { ls_run-reservation }| TO rt_line.
    APPEND || TO rt_line.

    APPEND format_row(
      iv_id        = `Demand`
      iv_requested = `Requested`
      iv_confirmed = `Confirmed`
      iv_shortfall = `Shortfall` ) TO rt_line.

    LOOP AT ls_run-allocation INTO DATA(ls_allocation).
      lv_requested = lv_requested + ls_allocation-requested.
      lv_confirmed = lv_confirmed + ls_allocation-confirmed.
      lv_shortfall = lv_shortfall + ls_allocation-shortfall.
      APPEND format_row(
        iv_id        = |{ ls_allocation-demand_id }|
        iv_requested = |{ ls_allocation-requested }|
        iv_confirmed = |{ ls_allocation-confirmed }|
        iv_shortfall = |{ ls_allocation-shortfall }| ) TO rt_line.
    ENDLOOP.

    APPEND format_row(
      iv_id        = `Total`
      iv_requested = |{ lv_requested }|
      iv_confirmed = |{ lv_confirmed }|
      iv_shortfall = |{ lv_shortfall }| ) TO rt_line.

  ENDMETHOD.

  METHOD format_row.

    rv_line = |{ iv_id WIDTH = c_width_id }|
           && |{ iv_requested WIDTH = c_width_qty ALIGN = RIGHT }|
           && |{ iv_confirmed WIDTH = c_width_qty ALIGN = RIGHT }|
           && |{ iv_shortfall WIDTH = c_width_qty ALIGN = RIGHT }|.

  ENDMETHOD.

ENDCLASS.
