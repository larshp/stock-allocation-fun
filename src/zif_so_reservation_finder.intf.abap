INTERFACE zif_so_reservation_finder PUBLIC.

  TYPES ty_reservation_numbers TYPE
    zif_so_reservation_api=>ty_reservation_numbers.

  METHODS get_open_reservation_numbers
    IMPORTING
      iv_sales_document             TYPE resb-kdauf
      iv_item_number                TYPE resb-kdpos OPTIONAL
    RETURNING
      VALUE(rt_reservation_numbers) TYPE ty_reservation_numbers.

ENDINTERFACE.
