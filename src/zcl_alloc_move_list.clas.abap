CLASS zcl_alloc_move_list DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_line_tab TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    "! <p class="shorttext synchronized">List wired up the way a plain SAP system needs it</p>
    "!
    "! @parameter ro_list | <p class="shorttext synchronized">Ready to use list</p>
    CLASS-METHODS create_default
      RETURNING
        VALUE(ro_list) TYPE REF TO zcl_alloc_move_list.

    "! <p class="shorttext synchronized">Wire up the list</p>
    "!
    "! Reading what a plant has decided and changing it are two activities,
    "! so there are two authority objects rather than one used for both: a
    "! display user may read the worklist and may not answer it.
    "!
    "! @parameter io_transfer | <p class="shorttext synchronized">Where proposals are written down</p>
    "! @parameter io_display  | <p class="shorttext synchronized">Decides who may read a plant</p>
    "! @parameter io_change   | <p class="shorttext synchronized">Decides who may answer for a plant</p>
    "! @parameter io_commit   | <p class="shorttext synchronized">Makes an answer durable</p>
    METHODS constructor
      IMPORTING
        io_transfer TYPE REF TO zcl_alloc_transfer
        io_display  TYPE REF TO zif_allocation_authority
        io_change   TYPE REF TO zif_allocation_authority
        io_commit   TYPE REF TO zif_unit_of_work.

    "! <p class="shorttext synchronized">The transfers waiting for an answer</p>
    "!
    "! `ZSTOCK_ALLOC_TRF` writes the proposals down and nothing could read
    "! them back: running it again says what it would propose now, which is
    "! not the same list and does not say who proposed what or what they wrote
    "! on it. This is the worklist itself.
    "!
    "! @parameter iv_werks       | <p class="shorttext synchronized">Plant that is short</p>
    "! @parameter iv_matnr       | <p class="shorttext synchronized">Material, every one if empty</p>
    "! @parameter rt_line        | <p class="shorttext synchronized">Lines to display</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">Plant may not be seen</p>
    METHODS run
      IMPORTING
        iv_werks       TYPE mard-werks
        iv_matnr       TYPE mard-matnr OPTIONAL
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab
      RAISING
        zcx_allocation.

    "! <p class="shorttext synchronized">Say what became of one proposal</p>
    "!
    "! Raised, or decided against. Which of the two it is matters as much as
    "! that it was answered: a proposal nobody acted on is one to think about
    "! again when the plant is short of the same thing next month, and one
    "! that was raised is not.
    "!
    "! The plant is checked before the proposal is read, so somebody cannot
    "! find out what another plant is short of by answering its proposals.
    "!
    "! @parameter iv_werks       | <p class="shorttext synchronized">Plant that is short</p>
    "! @parameter iv_proposal    | <p class="shorttext synchronized">The proposal</p>
    "! @parameter iv_raised      | <p class="shorttext synchronized">True if the transfer was raised</p>
    "! @parameter rt_line        | <p class="shorttext synchronized">Lines to display</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">Plant may not be acted in, or no such proposal</p>
    METHODS answer
      IMPORTING
        iv_werks       TYPE mard-werks
        iv_proposal    TYPE zstock_alloc_trf-proposal
        iv_raised      TYPE abap_bool
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab
      RAISING
        zcx_allocation.

  PRIVATE SECTION.

    CONSTANTS c_width_id    TYPE i VALUE 24.
    CONSTANTS c_width_matnr TYPE i VALUE 20.
    CONSTANTS c_width_werks TYPE i VALUE 8.
    CONSTANTS c_width_qty   TYPE i VALUE 14.
    CONSTANTS c_width_who   TYPE i VALUE 14.
    CONSTANTS c_width_date  TYPE i VALUE 12.

    "! Answering a proposal changes somebody's morning, and reading the list
    "! is reading what a plant has decided. The two are different activities
    "! and the plant is checked for whichever one is being done.
    CONSTANTS c_activity_display TYPE activ_auth VALUE '03'.
    CONSTANTS c_activity_change TYPE activ_auth VALUE '02'.

    DATA mo_transfer TYPE REF TO zcl_alloc_transfer.
    DATA mo_display  TYPE REF TO zif_allocation_authority.
    DATA mo_change   TYPE REF TO zif_allocation_authority.
    DATA mo_commit   TYPE REF TO zif_unit_of_work.

    METHODS format_row
      IMPORTING
        iv_id          TYPE string
        iv_matnr       TYPE string
        iv_from        TYPE string
        iv_quantity    TYPE string
        iv_who         TYPE string
        iv_when        TYPE string
        iv_note        TYPE string
      RETURNING
        VALUE(rv_line) TYPE string.

ENDCLASS.


CLASS zcl_alloc_move_list IMPLEMENTATION.

  METHOD create_default.

    ro_list = NEW zcl_alloc_move_list(
      io_transfer = NEW zcl_alloc_transfer( )
      io_display  = NEW zcl_authority_alloc( c_activity_display )
      io_change   = NEW zcl_authority_alloc( c_activity_change )
      io_commit   = NEW zcl_unit_of_work( ) ).

  ENDMETHOD.

  METHOD constructor.

    mo_transfer = io_transfer.
    mo_display  = io_display.
    mo_change   = io_change.
    mo_commit   = io_commit.

  ENDMETHOD.

  METHOD run.

    mo_display->check_plant( iv_werks ).

    APPEND |Plant { iv_werks }, transfers waiting for an answer| TO rt_line.

    DATA(lt_open) = mo_transfer->open_for(
      iv_werks = iv_werks
      iv_matnr = iv_matnr ).

    IF lt_open IS INITIAL.
      APPEND `Nothing is waiting for an answer` TO rt_line.
      RETURN.
    ENDIF.

    APPEND format_row(
      iv_id       = `Proposal`
      iv_matnr    = `Material`
      iv_from     = `From`
      iv_quantity = `Quantity`
      iv_who      = `Proposed by`
      iv_when     = `On`
      iv_note     = `Note` ) TO rt_line.

    LOOP AT lt_open INTO DATA(ls_open).
      APPEND format_row(
        iv_id       = |{ ls_open-proposal }|
        iv_matnr    = |{ ls_open-matnr }|
        iv_from     = |{ ls_open-from_werks }|
        iv_quantity = |{ ls_open-quantity }|
        iv_who      = |{ ls_open-created_by }|
        iv_when     = |{ zcl_alloc_clock=>date_of( ls_open-created_at ) DATE = ISO }|
        iv_note     = |{ ls_open-note }| ) TO rt_line.
    ENDLOOP.

    APPEND || TO rt_line.
    APPEND |{ lines( lt_open ) } waiting| TO rt_line.

  ENDMETHOD.

  METHOD answer.

    " the plant is checked first, and with the activity that says somebody is
    " about to change something. Reading the proposal to see which plant it
    " belongs to would otherwise tell a user what another plant is short of.
    mo_change->check_plant( iv_werks ).

    " and it has to be this plant's proposal. A proposal id is a UUID, so
    " guessing one is not the risk; answering one from a plant somebody
    " happens to have the number for is.
    DATA(lt_open) = mo_transfer->open_for( iv_werks ).

    IF NOT line_exists( lt_open[ proposal = iv_proposal ] ).
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>save_failed
        mv_message = |{ iv_proposal } { iv_werks }| ).
    ENDIF.

    mo_transfer->answer(
      iv_proposal = iv_proposal
      iv_status   = COND #( WHEN iv_raised = abap_true
                            THEN zcl_alloc_transfer=>c_status-done
                            ELSE zcl_alloc_transfer=>c_status-dropped ) ).

    mo_commit->commit( ).

    APPEND |{ iv_proposal } | &&
           COND string( WHEN iv_raised = abap_true
                        THEN `is raised`
                        ELSE `was decided against` ) TO rt_line.

  ENDMETHOD.

  METHOD format_row.

    rv_line = |{ iv_id WIDTH = c_width_id }|
      && |{ iv_matnr WIDTH = c_width_matnr }|
      && |{ iv_from WIDTH = c_width_werks }|
      && |{ iv_quantity WIDTH = c_width_qty ALIGN = RIGHT }|
      && |  { iv_who WIDTH = c_width_who }|
      && |{ iv_when WIDTH = c_width_date }|
      && |{ iv_note }|.

  ENDMETHOD.

ENDCLASS.
