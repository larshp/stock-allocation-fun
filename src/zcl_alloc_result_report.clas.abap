CLASS zcl_alloc_result_report DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_line_tab TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    "! <p class="shorttext synchronized">Result display wired up the way a plain SAP system needs it</p>
    "!
    "! @parameter ro_report | <p class="shorttext synchronized">Ready to use display</p>
    CLASS-METHODS create_default
      RETURNING
        VALUE(ro_report) TYPE REF TO zcl_alloc_result_report.

    "! <p class="shorttext synchronized">Wire up the display</p>
    "!
    "! @parameter io_store     | <p class="shorttext synchronized">Where runs are recorded</p>
    "! @parameter io_authority | <p class="shorttext synchronized">Decides who may see a plant</p>
    METHODS constructor
      IMPORTING
        io_store     TYPE REF TO zif_allocation_store
        io_authority TYPE REF TO zif_allocation_authority.

    "! <p class="shorttext synchronized">Lay out what the last run decided for a plant</p>
    "!
    "! Reads the recorded result rather than allocating anything, so it can be
    "! run at any time and changes nothing. Returns the lines instead of writing
    "! them, so what a person ends up reading can be asserted in a test.
    "!
    "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
    "! @parameter iv_matnr       | <p class="shorttext synchronized">Material, every one if empty</p>
    "! @parameter iv_short_only  | <p class="shorttext synchronized">Only lines that did not get everything</p>
    "! @parameter iv_dispo       | <p class="shorttext synchronized">MRP controller, every one if empty</p>
    "! @parameter iv_kunnr       | <p class="shorttext synchronized">Customer, every one if empty</p>
    "! @parameter rt_line        | <p class="shorttext synchronized">Lines to display</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">Plant may not be displayed</p>
    METHODS run
      IMPORTING
        iv_werks       TYPE mard-werks
        iv_matnr       TYPE mard-matnr OPTIONAL
        iv_short_only  TYPE abap_bool DEFAULT abap_false
        iv_dispo       TYPE marc-dispo OPTIONAL
        iv_kunnr       TYPE vbak-kunnr OPTIONAL
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab
      RAISING
        zcx_allocation.

  PRIVATE SECTION.

    DATA mo_converter TYPE REF TO zif_unit_converter.

    CONSTANTS c_width_id  TYPE i VALUE 26.
    CONSTANTS c_width_kunnr TYPE i VALUE 12.
    CONSTANTS c_width_qty TYPE i VALUE 14.
    CONSTANTS c_width_why TYPE i VALUE 22.

    "! Displaying stock figures, not changing them.
    CONSTANTS c_activity_display TYPE activ_auth VALUE '03'.

    DATA mo_store     TYPE REF TO zif_allocation_store.
    DATA mo_authority TYPE REF TO zif_allocation_authority.

    METHODS unit_of
      IMPORTING
        iv_matnr      TYPE mard-matnr
      RETURNING
        VALUE(rv_uom) TYPE string.

    METHODS format_row
      IMPORTING
        iv_id          TYPE string
        iv_kunnr       TYPE string
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


CLASS zcl_alloc_result_report IMPLEMENTATION.

  METHOD create_default.

    ro_report = NEW zcl_alloc_result_report(
      io_store     = NEW zcl_allocation_store( )
      io_authority = NEW zcl_authority_alloc( c_activity_display ) ).

  ENDMETHOD.

  METHOD constructor.

    mo_store     = io_store.
    mo_converter = NEW zcl_unit_converter( ).
    mo_authority = io_authority.

  ENDMETHOD.

  METHOD run.

    DATA lv_matnr     TYPE mard-matnr.
    DATA lt_dispo     TYPE zcl_alloc_owned_by=>ty_dispo_tab.
    DATA lv_requested TYPE zif_allocation=>ty_quantity.
    DATA lv_confirmed TYPE zif_allocation=>ty_quantity.
    DATA lv_shortfall TYPE zif_allocation=>ty_quantity.

    mo_authority->check_plant( iv_werks ).

    DATA(lt_recorded) = mo_store->latest_per_material(
      iv_werks = iv_werks
      iv_matnr = iv_matnr ).

    " a planner asking for their own materials means the ones they look after,
    " which is a question about the material master rather than about the run
    IF iv_dispo IS NOT INITIAL.
      APPEND iv_dispo TO lt_dispo.
    ENDIF.

    DATA(lt_owned) = zcl_alloc_owned_by=>materials(
      iv_werks = iv_werks
      it_dispo = lt_dispo ).

    APPEND |Plant { iv_werks }, last recorded run per material| TO rt_line.

    IF lt_recorded IS INITIAL.
      APPEND `Nothing has been allocated here yet` TO rt_line.
      RETURN.
    ENDIF.

    LOOP AT lt_recorded INTO DATA(ls_recorded).

      IF iv_short_only = abap_true AND ls_recorded-shortfall <= 0.
        CONTINUE.
      ENDIF.

      IF zcl_alloc_owned_by=>is_owned(
          iv_matnr = ls_recorded-matnr
          it_owned = lt_owned
          it_dispo = lt_dispo ) = abap_false.
        CONTINUE.
      ENDIF.

      " somebody asking about one customer is asking what to tell them
      IF iv_kunnr IS NOT INITIAL
          AND ls_recorded-customer <> iv_kunnr.
        CONTINUE.
      ENDIF.

      " one block per material, headed by the run that decided it
      IF ls_recorded-matnr <> lv_matnr.
        lv_matnr = ls_recorded-matnr.
        APPEND || TO rt_line.
        APPEND |Material { ls_recorded-matnr }| &&
               COND string( WHEN unit_of( ls_recorded-matnr ) IS NOT INITIAL
                            THEN |, quantities in { unit_of( ls_recorded-matnr ) }| ) TO rt_line.
        APPEND |Run         { ls_recorded-run_id }| TO rt_line.
        APPEND |Reservation { ls_recorded-reservation }| TO rt_line.
        APPEND format_row(
          iv_id        = `Demand`
          iv_kunnr     = `Customer`
          iv_requested = `Requested`
          iv_confirmed = `Confirmed`
          iv_shortfall = `Shortfall`
          iv_available = `Available`
          iv_reason    = `Why` ) TO rt_line.
      ENDIF.

      lv_requested = lv_requested + ls_recorded-requested.
      lv_confirmed = lv_confirmed + ls_recorded-confirmed.
      lv_shortfall = lv_shortfall + ls_recorded-shortfall.

      APPEND format_row(
        iv_id        = |{ ls_recorded-demand_id }|
        iv_kunnr     = |{ ls_recorded-customer }|
        iv_requested = |{ ls_recorded-requested }|
        iv_confirmed = |{ ls_recorded-confirmed }|
        iv_shortfall = |{ ls_recorded-shortfall }|
        iv_available = available_text(
          iv_avail_date = ls_recorded-avail_date
          iv_confirmed  = ls_recorded-confirmed )
        iv_reason    = zcl_alloc_reason_text=>text( ls_recorded-reason ) ) TO rt_line.

    ENDLOOP.

    " the totals are over the whole display, which is the number somebody
    " reading a plant after a night's run is looking for
    APPEND || TO rt_line.
    APPEND format_row(
      iv_id        = `Total`
      iv_kunnr     = ``
      iv_requested = |{ lv_requested }|
      iv_confirmed = |{ lv_confirmed }|
      iv_shortfall = |{ lv_shortfall }|
      iv_available = ``
      iv_reason    = `` ) TO rt_line.

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

  METHOD format_row.

    rv_line = |{ iv_id WIDTH = c_width_id }|
           && |{ iv_kunnr WIDTH = c_width_kunnr }|
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
