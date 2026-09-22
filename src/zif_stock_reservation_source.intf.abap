INTERFACE zif_stock_reservation_source PUBLIC.
  TYPES ty_references TYPE STANDARD TABLE OF zif_stock_alloc_types=>ty_origin WITH DEFAULT KEY.
  " Return current open issue demand for the requested reservation keys only.
  METHODS read
    IMPORTING references      TYPE ty_references
    RETURNING VALUE(requests) TYPE zif_stock_alloc_types=>ty_requests
    RAISING zcx_stock_alloc.
ENDINTERFACE.
