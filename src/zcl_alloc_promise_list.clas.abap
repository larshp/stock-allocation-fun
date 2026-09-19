CLASS zcl_alloc_promise_list DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_line_tab TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    "! <p class="shorttext synchronized">List wired up the way a plain SAP system needs it</p>
    "!
    "! @parameter ro_list | <p class="shorttext synchronized">Ready to use list</p>
    CLASS-METHODS create_default
      RETURNING
        VALUE(ro_list) TYPE REF TO zcl_alloc_promise_list.

    "! <p class="shorttext synchronized">Wire up the list</p>
    "!
    "! @parameter io_store     | <p class="shorttext synchronized">Where runs are recorded</p>
    "! @parameter io_authority | <p class="shorttext synchronized">Decides who may see a plant</p>
    METHODS constructor
      IMPORTING
        io_store     TYPE REF TO zif_allocation_store
        io_authority TYPE REF TO zif_allocation_authority.

    "! <p class="shorttext synchronized">What has been promised by hand in a plant</p>
    "!
    "! A promise outranks every rule the plant has (feature 104), which makes
    "! a list of them the first thing somebody wants when the rules stop
    "! explaining the answer. It is also the only way to find the ones that
    "! were made for a reason that stopped being true: a promise with no last
    "! day on it is kept for ever, and nothing but a person removes it.
    "!
    "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
    "! @parameter iv_all         | <p class="shorttext synchronized">Show the ones that have run out too</p>
    "! @parameter rt_line        | <p class="shorttext synchronized">Lines to display</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">Plant may not be seen</p>
    METHODS run
      IMPORTING
        iv_werks       TYPE mard-werks
        iv_all         TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab
      RAISING
        zcx_allocation.

  PRIVATE SECTION.

    CONSTANTS c_width_matnr TYPE i VALUE 20.
    CONSTANTS c_width_id    TYPE i VALUE 26.
    CONSTANTS c_width_qty   TYPE i VALUE 13.
    CONSTANTS c_width_until TYPE i VALUE 13.

    "! Reading what was promised, not promising anything.
    CONSTANTS c_activity_display TYPE activ_auth VALUE '03'.

    CONSTANTS c_no_end TYPE d VALUE '00000000'.

    "! One promise. Declared explicitly rather than inferred with
    "! INTO TABLE @DATA(), see ANOMALIES.md.
    TYPES:
      BEGIN OF ty_promise,
        matnr     TYPE zstock_alloc_fix-matnr,
        demand_id TYPE zstock_alloc_fix-demand_id,
        quantity  TYPE zif_allocation=>ty_quantity,
        valid_to  TYPE zstock_alloc_fix-valid_to,
        reason    TYPE zstock_alloc_fix-reason,
      END OF ty_promise.
    TYPES ty_promise_tab TYPE STANDARD TABLE OF ty_promise WITH EMPTY KEY.

    DATA mo_store     TYPE REF TO zif_allocation_store.
    DATA mo_authority TYPE REF TO zif_allocation_authority.

    METHODS promises_of
      IMPORTING
        iv_werks          TYPE mard-werks
      RETURNING
        VALUE(rt_promise) TYPE ty_promise_tab.

    METHODS given_to
      IMPORTING
        it_recorded        TYPE zif_allocation_store=>ty_recorded_tab
        iv_demand_id       TYPE zstock_alloc_fix-demand_id
      RETURNING
        VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity.

    METHODS format_row
      IMPORTING
        iv_matnr       TYPE string
        iv_id          TYPE string
        iv_promised    TYPE string
        iv_given       TYPE string
        iv_until       TYPE string
        iv_reason      TYPE string
      RETURNING
        VALUE(rv_line) TYPE string.

ENDCLASS.


CLASS zcl_alloc_promise_list IMPLEMENTATION.

  METHOD create_default.

    ro_list = NEW zcl_alloc_promise_list(
      io_store     = NEW zcl_allocation_store( )
      io_authority = NEW zcl_authority_alloc( c_activity_display ) ).

  ENDMETHOD.

  METHOD constructor.

    mo_store     = io_store.
    mo_authority = io_authority.

  ENDMETHOD.

  METHOD run.

    DATA lv_shown TYPE i.
    DATA lv_over  TYPE i.

    mo_authority->check_plant( iv_werks ).

    APPEND |Plant { iv_werks }, promised by hand| TO rt_line.

    DATA(lt_promise) = promises_of( iv_werks ).
    IF lt_promise IS INITIAL.
      APPEND `Nothing is promised here` TO rt_line.
      RETURN.
    ENDIF.

    " what the last run of each material gave the line, read once for the
    " plant rather than once per promise
    DATA(lt_recorded) = mo_store->latest_per_material( iv_werks ).

    APPEND format_row(
      iv_matnr    = `Material`
      iv_id       = `Demand`
      iv_promised = `Promised`
      iv_given    = `Got`
      iv_until    = `Until`
      iv_reason   = `Who and why` ) TO rt_line.

    LOOP AT lt_promise INTO DATA(ls_promise).

      DATA(lv_run_out) = xsdbool( ls_promise-valid_to <> c_no_end
                              AND ls_promise-valid_to < sy-datum ).

      IF lv_run_out = abap_true.
        lv_over = lv_over + 1.
        IF iv_all = abap_false.
          CONTINUE.
        ENDIF.
      ENDIF.

      lv_shown = lv_shown + 1.

      APPEND format_row(
        iv_matnr    = |{ ls_promise-matnr }|
        iv_id       = |{ ls_promise-demand_id }|
        iv_promised = |{ ls_promise-quantity }|
        iv_given    = |{ given_to( it_recorded  = lt_recorded
                                   iv_demand_id = ls_promise-demand_id ) }|
        iv_until    = COND string( WHEN ls_promise-valid_to = c_no_end
                                   THEN `no end`
                                   ELSE |{ ls_promise-valid_to DATE = ISO }| )
        iv_reason   = |{ ls_promise-reason }| ) TO rt_line.

    ENDLOOP.

    APPEND || TO rt_line.

    IF lv_shown = 0.
      APPEND |Nothing is promised here now, { lv_over } promise(s) have run out| TO rt_line.
      RETURN.
    ENDIF.

    APPEND |{ lv_shown } promise(s) listed| &&
           COND string( WHEN iv_all = abap_false AND lv_over > 0
                        THEN |, { lv_over } more have run out| ) TO rt_line.

  ENDMETHOD.

  METHOD promises_of.

    SELECT matnr,
           demand_id,
           quantity,
           valid_to,
           reason
      FROM zstock_alloc_fix
      WHERE werks = @iv_werks
      ORDER BY matnr, demand_id
      INTO TABLE @rt_promise.
    IF sy-subrc <> 0.
      CLEAR rt_promise.
    ENDIF.

  ENDMETHOD.

  METHOD given_to.

    LOOP AT it_recorded INTO DATA(ls_recorded)
        WHERE demand_id = iv_demand_id.
      rv_quantity = rv_quantity + ls_recorded-confirmed.
    ENDLOOP.

  ENDMETHOD.

  METHOD format_row.

    rv_line = |{ iv_matnr WIDTH = c_width_matnr }|
           && |{ iv_id WIDTH = c_width_id }|
           && |{ iv_promised WIDTH = c_width_qty ALIGN = RIGHT }|
           && |{ iv_given WIDTH = c_width_qty ALIGN = RIGHT }|
           && |  { iv_until WIDTH = c_width_until }|
           && |{ iv_reason }|.

  ENDMETHOD.

ENDCLASS.
