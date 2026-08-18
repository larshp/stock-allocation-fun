INTERFACE zif_reservation_gateway PUBLIC.
  TYPES ty_message_type TYPE c LENGTH 1.

  TYPES:
    BEGIN OF ty_request,
      request_id       TYPE zcl_stock_allocator=>ty_request_id,
      material         TYPE zcl_stock_allocator=>ty_material,
      plant            TYPE zcl_stock_allocator=>ty_plant,
      storage_location TYPE zcl_stock_allocator=>ty_storage_location,
      movement_type    TYPE zcl_stock_allocator=>ty_movement_type,
      requirement_date TYPE d,
      quantity         TYPE zcl_stock_allocator=>ty_quantity,
    END OF ty_request.

  TYPES:
    BEGIN OF ty_message,
      type    TYPE ty_message_type,
      message TYPE string,
    END OF ty_message.
  TYPES ty_messages TYPE STANDARD TABLE OF ty_message WITH EMPTY KEY.

  METHODS create_reservation
    IMPORTING
      is_request     TYPE ty_request
    EXPORTING
      ev_document_id TYPE zcl_stock_allocator=>ty_document_id
      et_messages    TYPE ty_messages.

  METHODS commit
    RETURNING
      VALUE(rt_messages) TYPE ty_messages.

  METHODS rollback.
ENDINTERFACE.
