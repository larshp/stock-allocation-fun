CLASS zcl_alloc_housekeeping DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    "! What a housekeeping run did. DELETED counts the runs that were removed,
    "! or would have been removed in a test run; KEPT counts the ones that are
    "! still needed.
    TYPES:
      BEGIN OF ty_outcome,
        deleted TYPE i,
        kept    TYPE i,
      END OF ty_outcome.

    "! <p class="shorttext synchronized">Housekeeping wired up the way a plain SAP system needs it</p>
    "!
    "! @parameter ro_housekeeping | <p class="shorttext synchronized">Ready to use housekeeping</p>
    CLASS-METHODS create_default
      RETURNING
        VALUE(ro_housekeeping) TYPE REF TO zcl_alloc_housekeeping.

    "! <p class="shorttext synchronized">Wire up the housekeeping</p>
    "!
    "! @parameter io_store       | <p class="shorttext synchronized">Where runs are recorded</p>
    "! @parameter io_reservation | <p class="shorttext synchronized">Tells which reservations are still there</p>
    "! @parameter io_authority   | <p class="shorttext synchronized">Decides who may allocate where</p>
    "! @parameter io_commit      | <p class="shorttext synchronized">Makes each removal durable</p>
    "! @parameter io_log         | <p class="shorttext synchronized">Where the run says what it removed</p>
    METHODS constructor
      IMPORTING
        io_store       TYPE REF TO zif_allocation_store
        io_reservation TYPE REF TO zif_reservation_reader
        io_authority   TYPE REF TO zif_allocation_authority
        io_commit      TYPE REF TO zif_unit_of_work
        io_log         TYPE REF TO zif_allocation_log.

    "! <p class="shorttext synchronized">Remove recorded runs that are not doing any work</p>
    "!
    "! A recorded run is still doing work while its reservation exists: the
    "! demand netting reads it, and deleting it would offer stock that has
    "! already been earmarked to the same demand a second time. Only a run whose
    "! reservation was never created, or is gone, can go, and only once it is
    "! older than IV_KEEP_DAYS, so a rejected reservation can still be looked up
    "! and retried for a while.
    "!
    "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
    "! @parameter iv_keep_days   | <p class="shorttext synchronized">Days of history to keep</p>
    "! @parameter iv_test        | <p class="shorttext synchronized">Count only, delete nothing</p>
    "! @parameter rs_outcome     | <p class="shorttext synchronized">How many runs went and how many stayed</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">Housekeeping could not be carried out</p>
    METHODS run
      IMPORTING
        iv_werks          TYPE mard-werks
        iv_keep_days      TYPE i
        iv_test           TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_outcome) TYPE ty_outcome
      RAISING
        zcx_allocation.

  PRIVATE SECTION.

    "! CREATED_AT is written with GET TIME STAMP, which is UTC, so the cut-off
    "! is worked out in UTC as well rather than in the local time zone.
    CONSTANTS c_time_zone TYPE timezone VALUE 'UTC'.

    "! A run whose reservation number is still initial never earmarked anything.
    CONSTANTS c_no_reservation TYPE zstock_alloc_res-reservation VALUE '0000000000'.

    "! One reservation that is still there, and the material it holds.
    TYPES:
      BEGIN OF ty_live,
        matnr       TYPE mard-matnr,
        werks       TYPE mard-werks,
        reservation TYPE resb-rsnum,
      END OF ty_live.
    TYPES ty_live_tab TYPE STANDARD TABLE OF ty_live WITH EMPTY KEY.

    DATA mo_store       TYPE REF TO zif_allocation_store.
    DATA mo_reservation TYPE REF TO zif_reservation_reader.
    DATA mo_authority   TYPE REF TO zif_allocation_authority.
    DATA mo_commit      TYPE REF TO zif_unit_of_work.
    DATA mo_log         TYPE REF TO zif_allocation_log.

    METHODS cutoff
      IMPORTING
        iv_keep_days     TYPE i
      RETURNING
        VALUE(rv_cutoff) TYPE zstock_alloc_res-created_at.

    METHODS live_by_material
      IMPORTING
        it_run         TYPE zif_allocation_store=>ty_run_head_tab
      RETURNING
        VALUE(rt_live) TYPE ty_live_tab.

    METHODS still_holding
      IMPORTING
        is_run            TYPE zif_allocation_store=>ty_run_head
        it_live           TYPE ty_live_tab
      RETURNING
        VALUE(rv_holding) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_housekeeping IMPLEMENTATION.

  METHOD create_default.

    ro_housekeeping = NEW zcl_alloc_housekeeping(
      io_store       = NEW zcl_allocation_store( )
      io_reservation = NEW zcl_reservation_reader( )
      io_authority   = NEW zcl_authority_plant( )
      io_commit      = NEW zcl_unit_of_work( )
      io_log         = NEW zcl_alloc_log_bal( NEW zcl_unit_of_work( ) ) ).

  ENDMETHOD.

  METHOD constructor.

    mo_store       = io_store.
    mo_reservation = io_reservation.
    mo_authority   = io_authority.
    mo_commit      = io_commit.
    mo_log         = io_log.

  ENDMETHOD.

  METHOD run.

    " removing the record of an allocation is a change to the plant's data, so
    " it is guarded exactly like making one
    mo_authority->check_plant( iv_werks ).

    " a test run keeps no diary, for the reason feature 40 gave: it changes
    " nothing, and saving a log would commit work a run that promises to change
    " nothing has no business committing
    IF iv_test = abap_false.
      mo_log->start( iv_werks ).
    ENDIF.

    DATA(lt_run) = mo_store->runs_recorded_before(
      iv_werks      = iv_werks
      iv_created_at = cutoff( iv_keep_days ) ).

    " asked once per material rather than once per run: a plant that allocates
    " nightly has far more runs on file than materials
    DATA(lt_live) = live_by_material( lt_run ).

    LOOP AT lt_run INTO DATA(ls_run).

      IF still_holding(
          is_run  = ls_run
          it_live = lt_live ) = abap_true.
        rs_outcome-kept = rs_outcome-kept + 1.
        CONTINUE.
      ENDIF.

      " one run at a time, each committed on its own: a reorg of a plant with a
      " year of history behind it is a long job, and one that is stopped half
      " way should leave the runs it did remove removed
      IF iv_test = abap_false.
        mo_store->delete_run( ls_run-run_id ).
        mo_commit->commit( ).
        mo_log->removed( ls_run-run_id ).
      ENDIF.

      rs_outcome-deleted = rs_outcome-deleted + 1.

    ENDLOOP.

    IF iv_test = abap_false.
      mo_log->save( ).
    ENDIF.

  ENDMETHOD.

  METHOD cutoff.

    DATA lv_days TYPE i.
    DATA lv_date TYPE d.

    " keeping a negative number of days would mean deleting runs that have not
    " been recorded yet. Nothing recorded today is ever removed.
    lv_days = iv_keep_days.
    IF lv_days < 0.
      CLEAR lv_days.
    ENDIF.

    lv_date = sy-datum - lv_days.

    CONVERT DATE lv_date TIME '000000'
      INTO TIME STAMP rv_cutoff TIME ZONE c_time_zone.

  ENDMETHOD.

  METHOD live_by_material.

    DATA lt_material TYPE zif_allocation_store=>ty_run_head_tab.

    lt_material = it_run.
    SORT lt_material BY matnr ASCENDING werks ASCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_material COMPARING matnr werks.

    LOOP AT lt_material INTO DATA(ls_material).

      DATA(lt_reservation) = mo_reservation->live_reservations(
        iv_matnr = ls_material-matnr
        iv_werks = ls_material-werks ).

      LOOP AT lt_reservation INTO DATA(lv_reservation).
        APPEND VALUE #(
          matnr       = ls_material-matnr
          werks       = ls_material-werks
          reservation = lv_reservation ) TO rt_live.
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD still_holding.

    " a run that never produced a reservation holds nothing, whatever its age
    IF is_run-reservation IS INITIAL OR is_run-reservation = c_no_reservation.
      RETURN.
    ENDIF.

    rv_holding = xsdbool( line_exists( it_live[ matnr       = is_run-matnr
                                               werks       = is_run-werks
                                               reservation = is_run-reservation ] ) ).

  ENDMETHOD.

ENDCLASS.
