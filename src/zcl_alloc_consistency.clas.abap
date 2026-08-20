CLASS zcl_alloc_consistency DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_line_tab TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    "! <p class="shorttext synchronized">Check wired up the way a plain SAP system needs it</p>
    "!
    "! @parameter ro_check | <p class="shorttext synchronized">Ready to use check</p>
    CLASS-METHODS create_default
      RETURNING
        VALUE(ro_check) TYPE REF TO zcl_alloc_consistency.

    "! <p class="shorttext synchronized">Wire up the check</p>
    "!
    "! @parameter io_store       | <p class="shorttext synchronized">Where runs are recorded</p>
    "! @parameter io_reservation | <p class="shorttext synchronized">Says what a reservation still holds</p>
    "! @parameter io_authority   | <p class="shorttext synchronized">Decides who may see a plant</p>
    METHODS constructor
      IMPORTING
        io_store       TYPE REF TO zif_allocation_store
        io_reservation TYPE REF TO zif_reservation_reader
        io_authority   TYPE REF TO zif_allocation_authority.

    "! <p class="shorttext synchronized">Where a recorded run and its reservation disagree</p>
    "!
    "! A run says how much it confirmed; its reservation is what holds that
    "! stock back. The two are written in one unit of work and should never
    "! drift apart, but a reservation can be changed or deleted by anybody with
    "! MB22, and the netting believes it. This says where that has happened, so
    "! somebody can decide whether to run the material again.
    "!
    "! It reads and changes nothing.
    "!
    "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
    "! @parameter rt_line        | <p class="shorttext synchronized">Lines to display</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">Plant may not be seen</p>
    METHODS run
      IMPORTING
        iv_werks       TYPE mard-werks
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab
      RAISING
        zcx_allocation.

  PRIVATE SECTION.

    CONSTANTS c_width_run  TYPE i VALUE 24.
    CONSTANTS c_width_qty  TYPE i VALUE 14.

    "! Reading what a run decided and what a reservation holds.
    CONSTANTS c_activity_display TYPE activ_auth VALUE '03'.

    DATA mo_store       TYPE REF TO zif_allocation_store.
    DATA mo_reservation TYPE REF TO zif_reservation_reader.
    DATA mo_authority   TYPE REF TO zif_allocation_authority.

    METHODS confirmed_by
      IMPORTING
        iv_run_id          TYPE zstock_alloc_res-run_id
      RETURNING
        VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity.

    METHODS complaint
      IMPORTING
        is_run         TYPE zif_allocation_store=>ty_run_head
        iv_confirmed   TYPE zif_allocation=>ty_quantity
        iv_held        TYPE zif_allocation=>ty_quantity
      RETURNING
        VALUE(rv_text) TYPE string.

    METHODS everything_recorded
      IMPORTING
        iv_werks      TYPE mard-werks
      RETURNING
        VALUE(rt_run) TYPE zif_allocation_store=>ty_run_head_tab.

ENDCLASS.


CLASS zcl_alloc_consistency IMPLEMENTATION.

  METHOD create_default.

    ro_check = NEW zcl_alloc_consistency(
      io_store       = NEW zcl_allocation_store( )
      io_reservation = NEW zcl_reservation_reader( )
      io_authority   = NEW zcl_authority_plant( c_activity_display ) ).

  ENDMETHOD.

  METHOD constructor.

    mo_store       = io_store.
    mo_reservation = io_reservation.
    mo_authority   = io_authority.

  ENDMETHOD.

  METHOD run.

    DATA lv_checked TYPE i.
    DATA lv_wrong   TYPE i.

    mo_authority->check_plant( iv_werks ).

    APPEND |Plant { iv_werks }, recorded runs against their reservations| TO rt_line.

    LOOP AT everything_recorded( iv_werks ) INTO DATA(ls_run).

      lv_checked = lv_checked + 1.

      DATA(lv_confirmed) = confirmed_by( ls_run-run_id ).
      DATA(lv_held)      = mo_reservation->held_quantity( ls_run-reservation ).

      DATA(lv_text) = complaint(
        is_run       = ls_run
        iv_confirmed = lv_confirmed
        iv_held      = lv_held ).
      IF lv_text IS INITIAL.
        CONTINUE.
      ENDIF.

      lv_wrong = lv_wrong + 1.

      APPEND |{ ls_run-run_id WIDTH = c_width_run }| &&
             |{ ls_run-matnr WIDTH = c_width_run }| &&
             |{ lv_confirmed WIDTH = c_width_qty ALIGN = RIGHT }| &&
             |{ lv_held WIDTH = c_width_qty ALIGN = RIGHT }| &&
             |  { lv_text }| TO rt_line.

    ENDLOOP.

    APPEND || TO rt_line.
    APPEND |{ lv_checked } run(s) checked, { lv_wrong } to look at| TO rt_line.

  ENDMETHOD.

  METHOD complaint.

    " a run that confirmed nothing holds nothing and has nothing to reserve,
    " so the two agreeing on zero is not worth a line
    IF iv_confirmed <= 0.
      RETURN.
    ENDIF.

    " a run whose reservation was rejected is the state feature 37 leaves
    " behind on purpose: there is an answer to look up and retry, and until
    " somebody does, the stock it names is free
    IF is_run-reservation IS INITIAL.
      rv_text = `never reserved, the stock was given to nobody`.
      RETURN.
    ENDIF.

    IF iv_held <= 0.
      rv_text = `reservation is gone, the stock is free again`.
      RETURN.
    ENDIF.

    IF iv_held < iv_confirmed.
      rv_text = `reservation holds less than the run promised`.
      RETURN.
    ENDIF.

    IF iv_held > iv_confirmed.
      rv_text = `reservation holds more than the run promised`.
    ENDIF.

  ENDMETHOD.

  METHOD confirmed_by.

    LOOP AT mo_store->read( iv_run_id ) INTO DATA(ls_line).
      IF ls_line-confirmed > 0.
        rv_quantity = rv_quantity + ls_line-confirmed.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD everything_recorded.

    DATA lv_now TYPE zstock_alloc_res-created_at.

    " everything recorded is everything recorded before this moment, which is
    " what the store already answers for housekeeping. A run written while the
    " check is reading is one the next check will see.
    GET TIME STAMP FIELD lv_now.

    rt_run = mo_store->runs_recorded_before(
      iv_werks      = iv_werks
      iv_created_at = lv_now ).

  ENDMETHOD.

ENDCLASS.
