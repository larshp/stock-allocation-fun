INTERFACE zif_batch_expiry_reader PUBLIC.
  METHODS get_batch_expiry_exposure_bulk
    IMPORTING
      it_requests              TYPE zcl_stock_service=>ty_batch_expiry_requests
      it_excluded_reservations TYPE
        zif_stock_repository=>ty_reservation_keys OPTIONAL
    RETURNING
      VALUE(rt_results)        TYPE zcl_stock_service=>ty_batch_expiry_results
    RAISING
      zcx_invalid_stock_request.
  METHODS get_expiry_exposure_uom_bulk
    IMPORTING
      it_requests              TYPE zcl_stock_service=>ty_batch_expiry_uom_requests
      it_excluded_reservations TYPE
        zif_stock_repository=>ty_reservation_keys OPTIONAL
    RETURNING
      VALUE(rt_results)        TYPE zcl_stock_service=>ty_batch_expiry_uom_results
    RAISING
      zcx_invalid_stock_request.
ENDINTERFACE.
