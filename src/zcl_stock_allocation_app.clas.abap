CLASS zcl_stock_allocation_app DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_result,
        allocations TYPE zcl_stock_allocator=>ty_allocations,
        log_saved   TYPE abap_bool,
      END OF ty_result.

    METHODS constructor
      IMPORTING
        io_service TYPE REF TO zif_stock_allocation_service
        io_logger  TYPE REF TO zif_allocation_logger.

    METHODS run
      IMPORTING
        it_requests      TYPE zcl_stock_allocator=>ty_requests
        iv_simulation    TYPE abap_bool DEFAULT abap_false
        iv_strategy      TYPE zcl_stock_allocator=>ty_strategy
          DEFAULT zcl_stock_allocator=>gc_strategy_priority_due
      RETURNING
        VALUE(rs_result) TYPE ty_result.

    CLASS-METHODS create_sap
      RETURNING
        VALUE(ro_app) TYPE REF TO zcl_stock_allocation_app.

  PRIVATE SECTION.
    DATA mo_service TYPE REF TO zif_stock_allocation_service.
    DATA mo_logger TYPE REF TO zif_allocation_logger.
ENDCLASS.

CLASS zcl_stock_allocation_app IMPLEMENTATION.
  METHOD constructor.
    mo_service = io_service.
    mo_logger = io_logger.
  ENDMETHOD.

  METHOD run.
    rs_result-allocations = mo_service->execute(
      it_requests   = it_requests
      iv_simulation = iv_simulation
      iv_strategy   = iv_strategy ).
    rs_result-log_saved = mo_logger->write(
      it_allocations = rs_result-allocations
      iv_simulation  = iv_simulation ).
  ENDMETHOD.

  METHOD create_sap.
    DATA(lo_stock_reader) = NEW zcl_stock_reader_sap( ).
    DATA(lo_factor_reader) = NEW zcl_unit_factor_reader_sap( ).
    DATA(lo_unit_converter) = NEW zcl_unit_converter( lo_factor_reader ).
    DATA(lo_stock_rechecker) = NEW zcl_stock_rechecker_sap( lo_stock_reader ).
    DATA(lo_stock_lock) = NEW zcl_stock_lock_sap( ).
    DATA(lo_gateway) = NEW zcl_reservation_gateway_sap( ).
    DATA(lo_idempotency_store) = NEW zcl_idempotency_store_sap( ).
    DATA(lo_writer) = NEW zcl_allocation_writer_sap(
      io_gateway           = lo_gateway
      io_idempotency_store = lo_idempotency_store
      io_stock_rechecker   = lo_stock_rechecker
      io_stock_lock        = lo_stock_lock ).
    DATA(lo_service) = NEW zcl_stock_allocation_service(
      io_stock_reader      = lo_stock_reader
      io_allocation_writer = lo_writer
      io_unit_converter    = lo_unit_converter
      io_idempotency_store = lo_idempotency_store ).
    DATA(lo_log_store) = NEW zcl_allocation_log_store_sap( ).
    DATA(lo_logger) = NEW zcl_allocation_logger_sap( lo_log_store ).

    ro_app = NEW #(
      io_service = lo_service
      io_logger  = lo_logger ).
  ENDMETHOD.
ENDCLASS.
