INTERFACE zif_stock_transfer_repository PUBLIC.

  TYPES:
    BEGIN OF ty_balance,
      plant_transfer_quantity TYPE marc-umlmc,
      sloc_transfer_quantity  TYPE mard-umlme,
    END OF ty_balance.

  METHODS get_stock_in_transfer
    IMPORTING
      iv_material         TYPE marc-matnr
      iv_plant            TYPE marc-werks
      iv_storage_location TYPE mard-lgort OPTIONAL
    RETURNING
      VALUE(rs_balance)   TYPE ty_balance.

ENDINTERFACE.
