CLASS zcl_allocation_service DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_run,
        run_id     TYPE zstock_alloc_res-run_id,
        allocation TYPE zif_allocation=>ty_allocation_tab,
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
    "! @parameter io_engine | <p class="shorttext synchronized">Calculates the allocation</p>
    "! @parameter io_store  | <p class="shorttext synchronized">Records the result</p>
    "! @parameter io_run_id | <p class="shorttext synchronized">Identifies the run</p>
    METHODS constructor
      IMPORTING
        io_engine TYPE REF TO zcl_allocation_engine
        io_store  TYPE REF TO zif_allocation_store
        io_run_id TYPE REF TO zif_run_id_supplier.

    "! <p class="shorttext synchronized">Allocate the stock of a material and record the outcome</p>
    "!
    "! The result is stored before it is returned, so the caller always has a
    "! run id that can be looked up again later.
    "!
    "! @parameter iv_matnr       | <p class="shorttext synchronized">Material number</p>
    "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
    "! @parameter rs_run         | <p class="shorttext synchronized">Run id and the confirmed quantities</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">Run could not be identified or recorded</p>
    METHODS run
      IMPORTING
        iv_matnr      TYPE mard-matnr
        iv_werks      TYPE mard-werks
      RETURNING
        VALUE(rs_run) TYPE ty_run
      RAISING
        zcx_allocation.

  PRIVATE SECTION.
    DATA mo_engine TYPE REF TO zcl_allocation_engine.
    DATA mo_store  TYPE REF TO zif_allocation_store.
    DATA mo_run_id TYPE REF TO zif_run_id_supplier.

ENDCLASS.


CLASS zcl_allocation_service IMPLEMENTATION.

  METHOD create_default.

    DATA lo_strategy TYPE REF TO zif_allocation_strategy.

    lo_strategy = io_strategy.
    IF lo_strategy IS NOT BOUND.
      lo_strategy = NEW zcl_alloc_strategy_priority( ).
    ENDIF.

    ro_service = NEW #(
      io_engine = NEW zcl_allocation_engine(
        io_stock_reader  = NEW zcl_stock_reader( )
        io_demand_reader = NEW zcl_so_demand_reader( )
        io_strategy      = lo_strategy )
      io_store  = NEW zcl_allocation_store( )
      io_run_id = NEW zcl_run_id_uuid( ) ).

  ENDMETHOD.

  METHOD constructor.

    mo_engine = io_engine.
    mo_store  = io_store.
    mo_run_id = io_run_id.

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

  ENDMETHOD.

ENDCLASS.
