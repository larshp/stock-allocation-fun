CLASS zcl_allocation_service DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_run,
        run_id      TYPE zstock_alloc_res-run_id,
        reservation TYPE zstock_alloc_res-reservation,
        allocation  TYPE zif_allocation=>ty_allocation_tab,
      END OF ty_run.

    "! <p class="shorttext synchronized">Service wired up the way a plain SAP system needs it</p>
    "!
    "! @parameter io_strategy | <p class="shorttext synchronized">Distribution rule, priority by default</p>
    "! @parameter ro_service  | <p class="shorttext synchronized">Ready to use service</p>
    CLASS-METHODS create_default
      IMPORTING
        io_strategy       TYPE REF TO zif_allocation_strategy OPTIONAL
      RETURNING
        VALUE(ro_service) TYPE REF TO zcl_allocation_service.

    "! <p class="shorttext synchronized">Wire up the service</p>
    "!
    "! @parameter io_engine      | <p class="shorttext synchronized">Calculates the allocation</p>
    "! @parameter io_store       | <p class="shorttext synchronized">Records the result</p>
    "! @parameter io_run_id      | <p class="shorttext synchronized">Identifies the run</p>
    "! @parameter io_reservation | <p class="shorttext synchronized">Earmarks the confirmed stock</p>
    METHODS constructor
      IMPORTING
        io_engine      TYPE REF TO zcl_allocation_engine
        io_store       TYPE REF TO zif_allocation_store
        io_run_id      TYPE REF TO zif_run_id_supplier
        io_reservation TYPE REF TO zif_reservation_writer.

    "! <p class="shorttext synchronized">Allocate the stock of a material, record it and earmark it</p>
    "!
    "! The result is written down before the stock is reserved. If the
    "! reservation is then rejected there is still a record of what was decided,
    "! which can be looked up and retried. The other order would risk stock
    "! being earmarked with nothing to show for it.
    "!
    "! Use ZCL_ALLOCATION_ENGINE directly to work out an allocation without
    "! recording or reserving anything.
    "!
    "! @parameter iv_matnr       | <p class="shorttext synchronized">Material number</p>
    "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
    "! @parameter rs_run         | <p class="shorttext synchronized">Run id, reservation and confirmed quantities</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">Run could not be recorded or reserved</p>
    METHODS run
      IMPORTING
        iv_matnr      TYPE mard-matnr
        iv_werks      TYPE mard-werks
      RETURNING
        VALUE(rs_run) TYPE ty_run
      RAISING
        zcx_allocation.

  PRIVATE SECTION.
    DATA mo_engine      TYPE REF TO zcl_allocation_engine.
    DATA mo_store       TYPE REF TO zif_allocation_store.
    DATA mo_run_id      TYPE REF TO zif_run_id_supplier.
    DATA mo_reservation TYPE REF TO zif_reservation_writer.

ENDCLASS.


CLASS zcl_allocation_service IMPLEMENTATION.

  METHOD create_default.

    DATA lo_strategy TYPE REF TO zif_allocation_strategy.

    lo_strategy = io_strategy.
    IF lo_strategy IS NOT BOUND.
      lo_strategy = NEW zcl_alloc_strategy_priority( ).
    ENDIF.

    ro_service = NEW #(
      io_engine      = NEW zcl_allocation_engine(
        io_stock_reader  = NEW zcl_stock_reader_net( NEW zcl_stock_reader( ) )
        io_demand_reader = NEW zcl_so_demand_reader( )
        io_strategy      = lo_strategy )
      io_store       = NEW zcl_allocation_store( )
      io_run_id      = NEW zcl_run_id_uuid( )
      io_reservation = NEW zcl_reservation_writer( ) ).

  ENDMETHOD.

  METHOD constructor.

    mo_engine      = io_engine.
    mo_store       = io_store.
    mo_run_id      = io_run_id.
    mo_reservation = io_reservation.

  ENDMETHOD.

  METHOD run.

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
