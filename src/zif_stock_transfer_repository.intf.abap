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
  TYPES:
    BEGIN OF ty_transfer_request,
      request_id       TYPE c LENGTH 30,
      material         TYPE marc-matnr,
      plant            TYPE marc-werks,
      storage_location TYPE mard-lgort,
    END OF ty_transfer_request.
  TYPES ty_transfer_requests TYPE STANDARD TABLE OF ty_transfer_request
    WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_transfer_result,
      request_id              TYPE c LENGTH 30,
      material                TYPE marc-matnr,
      plant                   TYPE marc-werks,
      storage_location        TYPE mard-lgort,
      plant_transfer_quantity TYPE marc-umlmc,
      sloc_transfer_quantity  TYPE mard-umlme,
    END OF ty_transfer_result.
  TYPES ty_transfer_results TYPE STANDARD TABLE OF ty_transfer_result
    WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_batch_transfer_request,
      request_id TYPE c LENGTH 30,
      material   TYPE mchb-matnr,
      plant      TYPE mchb-werks,
    END OF ty_batch_transfer_request.
  TYPES ty_batch_transfer_requests TYPE STANDARD TABLE OF
    ty_batch_transfer_request WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_batch_transfer_result,
      request_id        TYPE c LENGTH 30,
      material          TYPE mchb-matnr,
      plant             TYPE mchb-werks,
      storage_location  TYPE mchb-lgort,
      batch             TYPE mchb-charg,
      transfer_quantity TYPE mchb-cumlm,
    END OF ty_batch_transfer_result.
  TYPES ty_batch_transfer_results TYPE STANDARD TABLE OF
    ty_batch_transfer_result WITH EMPTY KEY.

  METHODS get_stock_in_transfer
    IMPORTING
      iv_material         TYPE marc-matnr
      iv_plant            TYPE marc-werks
      iv_storage_location TYPE mard-lgort OPTIONAL
      RETURNING
        VALUE(rs_balance) TYPE ty_balance.

  METHODS get_stock_in_transfer_bulk
    IMPORTING
      it_requests       TYPE ty_transfer_requests
    RETURNING
      VALUE(rt_results) TYPE ty_transfer_results.

  METHODS get_transfer_batches_bulk
    IMPORTING
      it_requests       TYPE ty_batch_transfer_requests
    RETURNING
      VALUE(rt_results) TYPE ty_batch_transfer_results.

  METHODS get_stock_in_transfer_by_batch
    IMPORTING
      iv_material        TYPE mchb-matnr
      iv_plant           TYPE mchb-werks
    RETURNING
      VALUE(rt_balances) TYPE ty_batch_balances.

ENDINTERFACE.
