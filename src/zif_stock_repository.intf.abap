INTERFACE zif_stock_repository PUBLIC.

  METHODS get_unrestricted_stock
    IMPORTING
      iv_material        TYPE mard-matnr
      iv_plant           TYPE mard-werks
    RETURNING
      VALUE(rv_quantity) TYPE mard-labst.

ENDINTERFACE.
