INTERFACE zif_idempotency_store PUBLIC.
  METHODS claim
    IMPORTING
      iv_request_id      TYPE zcl_stock_allocator=>ty_request_id
    RETURNING
      VALUE(rv_acquired) TYPE abap_bool.

  METHODS set_document
    IMPORTING
      iv_request_id     TYPE zcl_stock_allocator=>ty_request_id
      iv_document_id    TYPE zcl_stock_allocator=>ty_document_id
    RETURNING
      VALUE(rv_updated) TYPE abap_bool.
ENDINTERFACE.
