INTERFACE zif_uom_converter
  PUBLIC.

  METHODS to_base_qty
    IMPORTING
      iv_matnr           TYPE matnr
      iv_meinh           TYPE marm-meinh
      iv_qty             TYPE menge_d
    RETURNING
      VALUE(rv_base_qty) TYPE menge_d.

ENDINTERFACE.
