INTERFACE zif_so_reservation_finder PUBLIC.

  TYPES ty_reservation_numbers TYPE
    zif_so_reservation_api=>ty_reservation_numbers.
  TYPES ty_sales_documents TYPE STANDARD TABLE OF resb-kdauf WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_order_reservation,
      sales_document     TYPE resb-kdauf,
      reservation_number TYPE bapi2093_res_key-reserv_no,
    END OF ty_order_reservation.
  TYPES ty_order_reservations TYPE STANDARD TABLE OF ty_order_reservation
    WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_sales_order_item,
      sales_document TYPE resb-kdauf,
      item_number    TYPE resb-kdpos,
    END OF ty_sales_order_item.
  TYPES ty_sales_order_items TYPE STANDARD TABLE OF ty_sales_order_item
    WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_item_reservation,
      sales_document     TYPE resb-kdauf,
      item_number        TYPE resb-kdpos,
      reservation_number TYPE bapi2093_res_key-reserv_no,
    END OF ty_item_reservation.
  TYPES ty_item_reservations TYPE STANDARD TABLE OF ty_item_reservation
    WITH EMPTY KEY.

  METHODS get_open_reservation_numbers
    IMPORTING
      iv_sales_document             TYPE resb-kdauf
      iv_item_number                TYPE resb-kdpos OPTIONAL
    RETURNING
      VALUE(rt_reservation_numbers) TYPE ty_reservation_numbers.

  METHODS get_open_reservations_bulk
    IMPORTING
      it_sales_documents     TYPE ty_sales_documents
      iv_item_number         TYPE resb-kdpos OPTIONAL
    RETURNING
      VALUE(rt_reservations) TYPE ty_order_reservations.

  METHODS get_open_item_reservations
    IMPORTING
      it_sales_order_items   TYPE ty_sales_order_items
    RETURNING
      VALUE(rt_reservations) TYPE ty_item_reservations.

ENDINTERFACE.
