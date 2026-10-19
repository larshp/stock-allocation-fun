CLASS zcl_stock_expiry_reader DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_batch_expiry_reader.
    METHODS constructor
      IMPORTING
        io_stock_service TYPE REF TO zcl_stock_service.

  PRIVATE SECTION.
    DATA mo_stock_service TYPE REF TO zcl_stock_service.
ENDCLASS.

CLASS zcl_stock_expiry_reader IMPLEMENTATION.
  METHOD constructor.
    mo_stock_service = io_stock_service.
  ENDMETHOD.

  METHOD zif_batch_expiry_reader~get_batch_expiry_exposure_bulk.
    IF mo_stock_service IS NOT BOUND.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    rt_results = mo_stock_service->get_batch_expiry_exposure_bulk(
      it_requests              = it_requests
      it_excluded_reservations = it_excluded_reservations ).
  ENDMETHOD.

  METHOD zif_batch_expiry_reader~get_expiry_exposure_uom_bulk.
    IF mo_stock_service IS NOT BOUND.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    rt_results = mo_stock_service->get_expiry_exposure_uom_bulk(
      it_requests              = it_requests
      it_excluded_reservations = it_excluded_reservations ).
  ENDMETHOD.
ENDCLASS.
