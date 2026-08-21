CLASS zcl_alloc_orphans DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    "! What a sweep did. FREED counts the reservations given back, or the ones
    "! that would have been in a test run.
    TYPES:
      BEGIN OF ty_outcome,
        looked_at TYPE i,
        freed     TYPE i,
      END OF ty_outcome.

    TYPES ty_line_tab TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    "! <p class="shorttext synchronized">Sweep wired up the way a plain SAP system needs it</p>
    "!
    "! @parameter iv_werks   | <p class="shorttext synchronized">Plant</p>
    "! @parameter ro_orphans | <p class="shorttext synchronized">Ready to use sweep</p>
    CLASS-METHODS create_for_plant
      IMPORTING
        iv_werks          TYPE mard-werks
      RETURNING
        VALUE(ro_orphans) TYPE REF TO zcl_alloc_orphans.

    "! <p class="shorttext synchronized">Wire up the sweep</p>
    "!
    "! @parameter io_store     | <p class="shorttext synchronized">Where runs are recorded</p>
    "! @parameter io_demand    | <p class="shorttext synchronized">What the documents still ask for</p>
    "! @parameter io_writer    | <p class="shorttext synchronized">Cancels the reservation</p>
    "! @parameter io_reader    | <p class="shorttext synchronized">Tells what a reservation still holds</p>
    "! @parameter io_authority | <p class="shorttext synchronized">Decides who may allocate where</p>
    "! @parameter io_lock      | <p class="shorttext synchronized">Keeps a run off the material meanwhile</p>
    "! @parameter io_commit    | <p class="shorttext synchronized">Makes the release durable</p>
    "! @parameter io_log       | <p class="shorttext synchronized">Where it says what it gave back</p>
    METHODS constructor
      IMPORTING
        io_store     TYPE REF TO zif_allocation_store
        io_demand    TYPE REF TO zif_demand_reader
        io_writer    TYPE REF TO zif_reservation_writer
        io_reader    TYPE REF TO zif_reservation_reader
        io_authority TYPE REF TO zif_allocation_authority
        io_lock      TYPE REF TO zif_allocation_lock
        io_commit    TYPE REF TO zif_unit_of_work
        io_log       TYPE REF TO zif_allocation_log.

    "! <p class="shorttext synchronized">Give back stock earmarked for demand that is gone</p>
    "!
    "! An order is deleted, an item is rejected, a schedule line is moved out
    "! of the horizon. The demand readers stop returning it the same night --
    "! and the reservation an earlier run made for it stays exactly where it
    "! is, holding stock for a line that no longer exists. Nothing takes it
    "! back: a re-cut would, but only for a material it happens to allocate,
    "! and housekeeping only removes records of runs that hold nothing.
    "!
    "! This is the sweep for that: every recorded run of the plant whose lines
    "! have all gone from the documents gives its reservation back.
    "!
    "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
    "! @parameter iv_test        | <p class="shorttext synchronized">Count only, give nothing back</p>
    "! @parameter rt_line        | <p class="shorttext synchronized">Lines to display</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">Sweep could not be carried out</p>
    METHODS run
      IMPORTING
        iv_werks       TYPE mard-werks
        iv_test        TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab
      RAISING
        zcx_allocation.

  PRIVATE SECTION.

    DATA mo_store     TYPE REF TO zif_allocation_store.
    DATA mo_demand    TYPE REF TO zif_demand_reader.
    DATA mo_writer    TYPE REF TO zif_reservation_writer.
    DATA mo_reader    TYPE REF TO zif_reservation_reader.
    DATA mo_authority TYPE REF TO zif_allocation_authority.
    DATA mo_lock      TYPE REF TO zif_allocation_lock.
    DATA mo_commit    TYPE REF TO zif_unit_of_work.
    DATA mo_log       TYPE REF TO zif_allocation_log.

    METHODS is_orphaned
      IMPORTING
        iv_run_id          TYPE zstock_alloc_res-run_id
        iv_matnr           TYPE mard-matnr
        iv_werks           TYPE mard-werks
      RETURNING
        VALUE(rv_orphaned) TYPE abap_bool
      RAISING
        zcx_allocation.

    METHODS free_it
      IMPORTING
        iv_matnr       TYPE mard-matnr
        iv_werks       TYPE mard-werks
        iv_reservation TYPE rkpf-rsnum
      RAISING
        zcx_allocation.

ENDCLASS.


CLASS zcl_alloc_orphans IMPLEMENTATION.

  METHOD create_for_plant.

    DATA(ls_settings) = CAST zif_alloc_config( NEW zcl_alloc_config( ) )->for_plant( iv_werks ).

    " the demand as the documents have it, before the netting: what is being
    " asked is whether the line still exists at all, not whether it is still
    " waiting for anything
    ro_orphans = NEW zcl_alloc_orphans(
      io_store     = NEW zcl_allocation_store( )
      io_demand    = zcl_allocation_service=>create_default_demand(
        iv_sto_priority = ls_settings-sto_priority
        iv_ship_days    = ls_settings-ship_days
        iv_age_days     = ls_settings-age_days
        iv_work_days    = ls_settings-work_days )
      io_writer    = NEW zcl_reservation_writer( ls_settings-move_type )
      io_reader    = NEW zcl_reservation_reader( )
      io_authority = NEW zcl_authority_alloc( )
      io_lock      = NEW zcl_lock_material( )
      io_commit    = NEW zcl_unit_of_work( )
      io_log       = NEW zcl_alloc_log_bal( NEW zcl_unit_of_work( ) ) ).

  ENDMETHOD.

  METHOD constructor.

    mo_store     = io_store.
    mo_demand    = io_demand.
    mo_writer    = io_writer.
    mo_reader    = io_reader.
    mo_authority = io_authority.
    mo_lock      = io_lock.
    mo_commit    = io_commit.
    mo_log       = io_log.

  ENDMETHOD.

  METHOD run.

    DATA ls_outcome  TYPE ty_outcome.
    DATA lv_tomorrow TYPE d.

    " giving stock back is a change to what the plant has promised, guarded
    " exactly like promising it
    mo_authority->check_plant( iv_werks ).

    IF iv_test = abap_false.
      mo_log->start( iv_werks ).
    ENDIF.

    APPEND |Plant { iv_werks }, stock held for demand that is gone| TO rt_line.

    " everything recorded up to and including today, which is every run there
    " is: the cut-off exists for housekeeping, and here it is only the way in
    lv_tomorrow = sy-datum + 1.

    LOOP AT mo_store->runs_recorded_before(
        iv_werks      = iv_werks
        iv_created_at = zcl_alloc_clock=>stamp_of( lv_tomorrow ) ) INTO DATA(ls_run).

      IF ls_run-reservation IS INITIAL.
        CONTINUE.
      ENDIF.

      IF mo_reader->held_quantity( ls_run-reservation ) <= 0.
        CONTINUE.
      ENDIF.

      ls_outcome-looked_at = ls_outcome-looked_at + 1.

      IF is_orphaned(
          iv_run_id = ls_run-run_id
          iv_matnr  = ls_run-matnr
          iv_werks  = iv_werks ) = abap_false.
        CONTINUE.
      ENDIF.

      ls_outcome-freed = ls_outcome-freed + 1.
      APPEND |{ ls_run-matnr }: reservation { ls_run-reservation } holds stock | &&
             |for lines that are no longer on the books| TO rt_line.

      IF iv_test = abap_true.
        CONTINUE.
      ENDIF.

      free_it(
        iv_matnr       = ls_run-matnr
        iv_werks       = iv_werks
        iv_reservation = ls_run-reservation ).

    ENDLOOP.

    APPEND || TO rt_line.
    APPEND |{ ls_outcome-looked_at } reservation(s) looked at, | &&
           COND string( WHEN iv_test = abap_true
                        THEN |{ ls_outcome-freed } would be given back|
                        ELSE |{ ls_outcome-freed } given back| ) TO rt_line.

    IF iv_test = abap_false AND ls_outcome-freed > 0.
      mo_log->finished(
        iv_materials = ls_outcome-freed
        iv_short     = 0
        iv_failed    = 0 ).
      mo_log->save( ).
      mo_commit->commit( ).
    ENDIF.

  ENDMETHOD.

  METHOD is_orphaned.

    " what the documents still ask for, and what this run decided: a run every
    " one of whose lines has gone is holding stock for nobody. A run some of
    " whose lines are still there is left alone -- the reservation is one
    " object and giving it back would take the stock from the lines that
    " remain, which the next run has not been asked to do yet.
    DATA(lt_demand) = mo_demand->read_open_demand(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    rv_orphaned = abap_true.

    LOOP AT mo_store->read( iv_run_id ) INTO DATA(ls_line).

      IF ls_line-confirmed <= 0.
        CONTINUE.
      ENDIF.

      IF line_exists( lt_demand[ demand_id = ls_line-demand_id ] ).
        rv_orphaned = abap_false.
        RETURN.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD free_it.

    " under the same lock a run takes: a run reading the material while its
    " reservation is being cancelled would allocate against a pool that is
    " neither the old one nor the new one
    mo_lock->acquire(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    " CATCH and re-raise rather than CLEANUP, as everywhere else here: the
    " transpiler drops a CLEANUP body, see ANOMALIES.md
    TRY.
        mo_writer->cancel( iv_reservation ).

        mo_log->released(
          iv_matnr       = iv_matnr
          iv_reservation = iv_reservation ).
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

ENDCLASS.
