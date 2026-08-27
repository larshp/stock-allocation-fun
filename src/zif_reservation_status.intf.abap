INTERFACE zif_reservation_status PUBLIC.
  TYPES ty_document_ids TYPE SORTED TABLE OF
    zcl_stock_allocator=>ty_document_id WITH UNIQUE KEY table_line.
  TYPES:
    BEGIN OF ty_result,
      is_success    TYPE abap_bool,
      message       TYPE string,
      cancelled_ids TYPE ty_document_ids,
    END OF ty_result.

  METHODS is_cancelled
    IMPORTING
      iv_document_id         TYPE zcl_stock_allocator=>ty_document_id
    RETURNING
      VALUE(rv_is_cancelled) TYPE abap_bool.

  METHODS find_cancelled
    IMPORTING
      it_document_ids  TYPE ty_document_ids
    RETURNING
      VALUE(rs_result) TYPE ty_result.
ENDINTERFACE.
