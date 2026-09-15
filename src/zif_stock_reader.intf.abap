INTERFACE zif_stock_reader
  PUBLIC.

  TYPES ty_quantity TYPE menge_d.

  TYPES: BEGIN OF ty_stock,
           matnr            TYPE matnr,
           werks            TYPE werks_d,
           lgort            TYPE lgort_d,
           charg            TYPE c LENGTH 10,
           expiry_date      TYPE d,
           unrestricted_qty TYPE ty_quantity,
           quality_qty      TYPE ty_quantity,
           blocked_qty      TYPE ty_quantity,
           restricted_qty   TYPE ty_quantity,
           in_transit_qty   TYPE ty_quantity,
         END OF ty_stock.

  TYPES ty_stock_tt TYPE STANDARD TABLE OF ty_stock WITH DEFAULT KEY.

  METHODS read_stock
    IMPORTING
      iv_matnr        TYPE matnr
      iv_werks        TYPE werks_d
    RETURNING
      VALUE(rt_stock) TYPE ty_stock_tt.

ENDINTERFACE.
