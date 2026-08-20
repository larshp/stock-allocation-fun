INTERFACE zif_reservation_status PUBLIC.
  METHODS is_cancelled
    IMPORTING
      iv_document_id         TYPE zcl_stock_allocator=>ty_document_id
    RETURNING
      VALUE(rv_is_cancelled) TYPE abap_bool.
ENDINTERFACE.
