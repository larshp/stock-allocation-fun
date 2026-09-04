CLASS zcl_alloc_release DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    "! What a release did. FREED counts the reservations that were given back,
    "! or would have been in a test run; HELD counts the quantity that came
    "! back into the pool with them.
    TYPES:
      BEGIN OF ty_outcome,
        freed    TYPE i,
        quantity TYPE zif_allocation=>ty_quantity,
      END OF ty_outcome.

    "! <p class="shorttext synchronized">Release wired up the way a plain SAP system needs it</p>
    "!
    "! @parameter ro_release | <p class="shorttext synchronized">Ready to use release</p>
    CLASS-METHODS create_default
      RETURNING
        VALUE(ro_release) TYPE REF TO zcl_alloc_release.

    "! <p class="shorttext synchronized">Wire up the release</p>
    "!
    "! @parameter io_store       | <p class="shorttext synchronized">Where runs are recorded</p>
    "! @parameter io_writer      | <p class="shorttext synchronized">Cancels the reservation</p>
    "! @parameter io_reader      | <p class="shorttext synchronized">Tells what a reservation still holds</p>
    "! @parameter io_authority   | <p class="shorttext synchronized">Decides who may allocate where</p>
    "! @parameter io_lock        | <p class="shorttext synchronized">Keeps a run off the material meanwhile</p>
    "! @parameter io_commit      | <p class="shorttext synchronized">Makes the release durable</p>
    "! @parameter io_log         | <p class="shorttext synchronized">Where it says what it gave back</p>
    METHODS constructor
      IMPORTING
        io_store     TYPE REF TO zif_allocation_store
        io_writer    TYPE REF TO zif_reservation_writer
        io_reader    TYPE REF TO zif_reservation_reader
        io_authority TYPE REF TO zif_allocation_authority
        io_lock      TYPE REF TO zif_allocation_lock
        io_commit    TYPE REF TO zif_unit_of_work
        io_log       TYPE REF TO zif_allocation_log.

    "! <p class="shorttext synchronized">Give a material's earmarked stock back by hand</p>
    "!
    "! A re-cut gives an allocation back and immediately takes it again, and
    "! housekeeping only touches runs that hold nothing. Neither of them covers
    "! the thing that actually happens on a Tuesday afternoon: a material is
    "! wanted for something the run knows nothing about, and the stock it has
    "! earmarked has to go back into the pool now, without waiting for the
    "! night and without a planner picking reservations apart in MB22.
    "!
    "! The recorded runs stay. They are what was decided at the time, and the
    "! netting stops counting a run the moment its reservation is gone, which
    "! is what makes the stock free again.
    "!
    "! @parameter iv_matnr       | <p class="shorttext synchronized">Material number</p>
    "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
    "! @parameter iv_test        | <p class="shorttext synchronized">Count only, give nothing back</p>
    "! @parameter rs_outcome     | <p class="shorttext synchronized">How much came back into the pool</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">Release could not be carried out</p>
    METHODS run
      IMPORTING
        iv_matnr          TYPE mard-matnr
        iv_werks          TYPE mard-werks
        iv_test           TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_outcome) TYPE ty_outcome
      RAISING
        zcx_allocation.

  PRIVATE SECTION.

    DATA mo_store     TYPE REF TO zif_allocation_store.
    DATA mo_writer    TYPE REF TO zif_reservation_writer.
    DATA mo_reader    TYPE REF TO zif_reservation_reader.
    DATA mo_authority TYPE REF TO zif_allocation_authority.
    DATA mo_lock      TYPE REF TO zif_allocation_lock.
    DATA mo_commit    TYPE REF TO zif_unit_of_work.
    DATA mo_log       TYPE REF TO zif_allocation_log.

    METHODS give_back
      IMPORTING
        iv_matnr          TYPE mard-matnr
        iv_werks          TYPE mard-werks
        iv_test           TYPE abap_bool
      RETURNING
        VALUE(rs_outcome) TYPE ty_outcome
      RAISING
        zcx_allocation.

ENDCLASS.


CLASS zcl_alloc_release IMPLEMENTATION.

  METHOD create_default.

    ro_release = NEW zcl_alloc_release(
      io_store     = NEW zcl_allocation_store( )
      io_writer    = NEW zcl_reservation_writer( )
      io_reader    = NEW zcl_reservation_reader( )
      io_authority = NEW zcl_authority_alloc( )
      io_lock      = NEW zcl_lock_material( )
      io_commit    = NEW zcl_unit_of_work( )
      io_log       = NEW zcl_alloc_log_bal( NEW zcl_unit_of_work( ) ) ).

  ENDMETHOD.

  METHOD constructor.

    mo_store     = io_store.
    mo_writer    = io_writer.
    mo_reader    = io_reader.
    mo_authority = io_authority.
    mo_lock      = io_lock.
    mo_commit    = io_commit.
    mo_log       = io_log.

  ENDMETHOD.

  METHOD run.

    " giving stock back is a change to what the plant has promised, so it is
    " guarded exactly like promising it
    mo_authority->check_plant( iv_werks ).

    " and it happens under the same lock a run takes, because a run reading
    " the material while its reservations are being cancelled would see half
    " of them and allocate on a pool that is neither the old one nor the new
    mo_lock->acquire(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    " CATCH and re-raise rather than CLEANUP, as ZCL_ALLOCATION_SERVICE does
    " and for the same reason: the transpiler drops a CLEANUP body, so the
    " lock would never come back. See ANOMALIES.md.
    TRY.
        rs_outcome = give_back(
          iv_matnr = iv_matnr
          iv_werks = iv_werks
          iv_test  = iv_test ).
      CATCH zcx_allocation INTO DATA(lx_error).
        mo_commit->rollback( ).
        mo_lock->release(
          iv_matnr = iv_matnr
          iv_werks = iv_werks ).
        RAISE EXCEPTION lx_error.
    ENDTRY.

    mo_lock->release(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

  ENDMETHOD.

  METHOD give_back.

    " a test run keeps no diary, for the reason feature 40 gave: it changes
    " nothing, and saving a log would commit work that a run promising to
    " change nothing has no business committing
    IF iv_test = abap_false.
      mo_log->start( iv_werks ).
    ENDIF.

    LOOP AT mo_store->runs_of_material(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ) INTO DATA(ls_run).

      IF ls_run-reservation IS INITIAL.
        CONTINUE.
      ENDIF.

      " what the reservation still holds is read before it is cancelled, and
      " it is also how a reservation somebody has already issued or deleted is
      " told from one that is really holding stock back
      DATA(lv_held) = mo_reader->held_quantity( ls_run-reservation ).
      IF lv_held <= 0.
        CONTINUE.
      ENDIF.

      rs_outcome-freed    = rs_outcome-freed + 1.
      rs_outcome-quantity = rs_outcome-quantity + lv_held.

      IF iv_test = abap_true.
        CONTINUE.
      ENDIF.

      mo_writer->cancel( ls_run-reservation ).

      mo_log->released(
        iv_matnr       = iv_matnr
        iv_reservation = ls_run-reservation ).

    ENDLOOP.

    IF iv_test = abap_true OR rs_outcome-freed = 0.
      RETURN.
    ENDIF.

    mo_log->finished(
      iv_materials = 1
      iv_short     = 0
      iv_failed    = 0 ).
    mo_log->save( ).

    " the cancellations and the log entry are one unit: stock that came back
    " with nothing saying who released it is what a planner finds a week later
    " and cannot account for
    mo_commit->commit( ).

  ENDMETHOD.

ENDCLASS.
