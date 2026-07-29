CLASS zcx_stock_allocation DEFINITION
    PUBLIC
    INHERITING FROM cx_static_check
    FINAL
    CREATE PUBLIC.
  PUBLIC SECTION.
    CONSTANTS invalid_demand_quantity TYPE string
      VALUE `INVALID_DEMAND_QUANTITY`.
    CONSTANTS invalid_stock_quantity TYPE string
      VALUE `INVALID_STOCK_QUANTITY`.
    CONSTANTS invalid_shelf_life TYPE string
      VALUE `INVALID_SHELF_LIFE`.
    CONSTANTS missing_uom_conversion TYPE string
      VALUE `MISSING_UOM_CONVERSION`.
    CONSTANTS invalid_uom_conversion TYPE string
      VALUE `INVALID_UOM_CONVERSION`.
    CONSTANTS invalid_stock_unit TYPE string
      VALUE `INVALID_STOCK_UNIT`.
    CONSTANTS missing_request_id TYPE string
      VALUE `MISSING_REQUEST_ID`.
    CONSTANTS duplicate_request_id TYPE string
      VALUE `DUPLICATE_REQUEST_ID`.
    CONSTANTS missing_material TYPE string
      VALUE `MISSING_MATERIAL`.
    CONSTANTS missing_plant TYPE string
      VALUE `MISSING_PLANT`.
    CONSTANTS missing_allocation_date TYPE string
      VALUE `MISSING_ALLOCATION_DATE`.
    CONSTANTS missing_sales_document TYPE string
      VALUE `MISSING_SALES_DOCUMENT`.
    CONSTANTS missing_sales_item TYPE string
      VALUE `MISSING_SALES_ITEM`.
    CONSTANTS duplicate_stock_key TYPE string
      VALUE `DUPLICATE_STOCK_KEY`.
    CONSTANTS duplicate_conversion_key TYPE string
      VALUE `DUPLICATE_CONVERSION_KEY`.
    CONSTANTS missing_source_unit TYPE string
      VALUE `MISSING_SOURCE_UNIT`.
    CONSTANTS missing_target_unit TYPE string
      VALUE `MISSING_TARGET_UNIT`.
    CONSTANTS missing_reservation_id TYPE string
      VALUE `MISSING_RESERVATION_ID`.
    CONSTANTS duplicate_reservation_id TYPE string
      VALUE `DUPLICATE_RESERVATION_ID`.
    CONSTANTS invalid_reservation_qty TYPE string
      VALUE `INVALID_RESERVATION_QTY`.
    CONSTANTS invalid_reservation_window TYPE string
      VALUE `INVALID_RESERVATION_WINDOW`.
    CONSTANTS missing_reservation_doc TYPE string
      VALUE `MISSING_RESERVATION_DOC`.
    CONSTANTS missing_reservation_item TYPE string
      VALUE `MISSING_RESERVATION_ITEM`.
    CONSTANTS invalid_batch_strategy TYPE string
      VALUE `INVALID_BATCH_STRATEGY`.
    CONSTANTS duplicate_strategy_override TYPE string
      VALUE `DUPLICATE_STRATEGY_OVERRIDE`.
    CONSTANTS invalid_demand_policy TYPE string
      VALUE `INVALID_DEMAND_POLICY`.

    DATA reason TYPE string READ-ONLY.
    DATA request_id TYPE string READ-ONLY.
    DATA batch TYPE string READ-ONLY.
    DATA material TYPE string READ-ONLY.
    DATA plant TYPE string READ-ONLY.
    DATA source_unit TYPE string READ-ONLY.
    DATA target_unit TYPE string READ-ONLY.
    DATA reservation_id TYPE string READ-ONLY.

    METHODS constructor
      IMPORTING
        reason     TYPE string
        request_id TYPE string OPTIONAL
        batch      TYPE string OPTIONAL
        material   TYPE string OPTIONAL
        plant      TYPE string OPTIONAL
        source_unit TYPE string OPTIONAL
        target_unit TYPE string OPTIONAL
        reservation_id TYPE string OPTIONAL.
ENDCLASS.

CLASS zcx_stock_allocation IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).
    me->reason = reason.
    me->request_id = request_id.
    me->batch = batch.
    me->material = material.
    me->plant = plant.
    me->source_unit = source_unit.
    me->target_unit = target_unit.
    me->reservation_id = reservation_id.
  ENDMETHOD.
ENDCLASS.
