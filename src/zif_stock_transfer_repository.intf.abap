INTERFACE zif_stock_transfer_repository PUBLIC.

  TYPES:
    BEGIN OF ty_balance,
      plant_transfer_quantity TYPE marc-umlmc,
      sloc_transfer_quantity  TYPE mard-umlme,
    END OF ty_balance.
  TYPES:
    BEGIN OF ty_batch_balance,
      storage_location  TYPE mchb-lgort,
      batch             TYPE mchb-charg,
      transfer_quantity TYPE mchb-cumlm,
    END OF ty_batch_balance.
  TYPES ty_batch_balances TYPE STANDARD TABLE OF ty_batch_balance
    WITH EMPTY KEY.

  METHODS get_stock_in_transfer
    IMPORTING
      iv_material         TYPE marc-matnr
      iv_plant            TYPE marc-werks
      iv_storage_location TYPE mard-lgort OPTIONAL
      RETURNING
        VALUE(rs_balance) TYPE ty_balance.

  METHODS get_stock_in_transfer_by_batch
    IMPORTING
      iv_material        TYPE mchb-matnr
      iv_plant           TYPE mchb-werks
    RETURNING
      VALUE(rt_balances) TYPE ty_batch_balances.

ENDINTERFACE.
