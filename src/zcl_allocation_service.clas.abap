CLASS zcl_allocation_service DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_allocation_service.

    "! <p class="shorttext synchronized">Service wired up the way a plain SAP system needs it</p>
    "!
    "! @parameter io_strategy | <p class="shorttext synchronized">Distribution rule, priority by default</p>
    "! @parameter ro_service  | <p class="shorttext synchronized">Ready to use service</p>
    CLASS-METHODS create_default
      IMPORTING
        io_strategy       TYPE REF TO zif_allocation_strategy OPTIONAL
      RETURNING
        VALUE(ro_service) TYPE REF TO zif_allocation_service.

    "! <p class="shorttext synchronized">Wire up the service</p>
    "!
    "! @parameter io_engine      | <p class="shorttext synchronized">Calculates the allocation</p>
    "! @parameter io_store       | <p class="shorttext synchronized">Records the result</p>
    "! @parameter io_run_id      | <p class="shorttext synchronized">Identifies the run</p>
    "! @parameter io_reservation | <p class="shorttext synchronized">Earmarks the confirmed stock</p>
    "! @parameter io_authority   | <p class="shorttext synchronized">Decides who may allocate where</p>
    "! @parameter io_lock        | <p class="shorttext synchronized">Keeps two runs off the same material</p>
    METHODS constructor
      IMPORTING
        io_engine      TYPE REF TO zcl_allocation_engine
        io_store       TYPE REF TO zif_allocation_store
        io_run_id      TYPE REF TO zif_run_id_supplier
        io_reservation TYPE REF TO zif_reservation_writer
        io_authority   TYPE REF TO zif_allocation_authority
        io_lock        TYPE REF TO zif_allocation_lock.

  PRIVATE SECTION.
    DATA mo_engine      TYPE REF TO zcl_allocation_engine.
    DATA mo_store       TYPE REF TO zif_allocation_store.
    DATA mo_run_id      TYPE REF TO zif_run_id_supplier.
    DATA mo_reservation TYPE REF TO zif_reservation_writer.
    DATA mo_authority   TYPE REF TO zif_allocation_authority.
    DATA mo_lock        TYPE REF TO zif_allocation_lock.

    METHODS allocate_and_record
      IMPORTING
        iv_matnr      TYPE mard-matnr
        iv_werks      TYPE mard-werks
      RETURNING
        VALUE(rs_run) TYPE zif_allocation_service=>ty_run
      RAISING
        zcx_allocation.

ENDCLASS.


CLASS zcl_allocation_service IMPLEMENTATION.

  METHOD create_default.

    DATA lo_strategy TYPE REF TO zif_allocation_strategy.

    lo_strategy = io_strategy.
    IF lo_strategy IS NOT BOUND.
      lo_strategy = NEW zcl_alloc_strategy_priority( ).
    ENDIF.

    ro_service = NEW zcl_allocation_service(
      io_engine      = NEW zcl_allocation_engine(
        io_stock_reader  = NEW zcl_stock_reader_net(
          io_stock     = NEW zcl_stock_reader( )
          it_deduction = VALUE #(
            ( NEW zcl_deduct_reservations( ) )
            ( NEW zcl_deduct_safety_stock( ) ) ) )
        io_demand_reader = NEW zcl_demand_reader_net(
          NEW zcl_so_demand_reader( NEW zcl_unit_converter( ) ) )
        io_strategy      = lo_strategy )
      io_store       = NEW zcl_allocation_store( )
      io_run_id      = NEW zcl_run_id_uuid( )
      io_reservation = NEW zcl_reservation_writer( )
      io_authority   = NEW zcl_authority_plant( )
      io_lock        = NEW zcl_lock_material( ) ).

  ENDMETHOD.

  METHOD constructor.

    mo_engine      = io_engine.
    mo_store       = io_store.
    mo_run_id      = io_run_id.
    mo_reservation = io_reservation.
    mo_authority   = io_authority.
    mo_lock        = io_lock.

  ENDMETHOD.

  METHOD zif_allocation_service~run.

    " nothing is read, written or reserved before the user has been checked
    mo_authority->check_plant( iv_werks ).

    " and nothing is read before this run owns the material, otherwise a
    " second run would work from the same available stock and give it away too
    mo_lock->acquire(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    " CATCH and re-raise rather than CLEANUP: the transpiler drops the body of
    " a CLEANUP block, so the lock would never come back. See ANOMALIES.md.
    TRY.
        rs_run = allocate_and_record(
          iv_matnr = iv_matnr
          iv_werks = iv_werks ).
      CATCH zcx_allocation INTO DATA(lx_error).
        mo_lock->release(
          iv_matnr = iv_matnr
          iv_werks = iv_werks ).
        RAISE EXCEPTION lx_error.
    ENDTRY.

    mo_lock->release(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

  ENDMETHOD.

  METHOD allocate_and_record.

    " the result is written down before the stock is reserved. If the
    " reservation is then rejected there is still a record of what was decided,
    " which can be looked up and retried. The other order would risk stock being
    " earmarked with nothing to show for it.
    rs_run-run_id     = mo_run_id->next( ).
    rs_run-allocation = mo_engine->allocate_open_demand(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    mo_store->save(
      iv_run_id     = rs_run-run_id
      iv_matnr      = iv_matnr
      iv_werks      = iv_werks
      it_allocation = rs_run-allocation ).

    rs_run-reservation = mo_reservation->reserve(
      iv_matnr      = iv_matnr
      iv_werks      = iv_werks
      it_allocation = rs_run-allocation ).

    IF rs_run-reservation IS NOT INITIAL.
      mo_store->record_reservation(
        iv_run_id      = rs_run-run_id
        iv_reservation = rs_run-reservation ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
