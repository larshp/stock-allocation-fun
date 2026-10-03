CLASS zcl_stock_transfer_repository DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_stock_transfer_repository.
ENDCLASS.

CLASS zcl_stock_transfer_repository IMPLEMENTATION.

  METHOD zif_stock_transfer_repository~get_stock_in_transfer.
    DATA lv_plant_quantity TYPE marc-umlmc.
    DATA lv_location_quantity TYPE mard-umlme.

    SELECT SUM( umlmc )
      FROM marc
      WHERE matnr = @iv_material
        AND werks = @iv_plant
      INTO @lv_plant_quantity.

    IF iv_storage_location IS INITIAL.
      SELECT SUM( umlme )
        FROM mard
        WHERE matnr = @iv_material
          AND werks = @iv_plant
        INTO @lv_location_quantity.
    ELSE.
      SELECT SINGLE umlme
        FROM mard
        WHERE matnr = @iv_material
          AND werks = @iv_plant
          AND lgort = @iv_storage_location
        INTO @lv_location_quantity.
    ENDIF.

    rs_balance-plant_transfer_quantity = lv_plant_quantity.
    rs_balance-sloc_transfer_quantity = lv_location_quantity.
  ENDMETHOD.

  METHOD zif_stock_transfer_repository~get_stock_in_transfer_by_batch.
    SELECT lgort AS storage_location,
           charg AS batch,
           cumlm AS transfer_quantity
      FROM mchb
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND cumlm <> 0
      ORDER BY lgort, charg
      INTO TABLE @rt_balances.
  ENDMETHOD.

ENDCLASS.
