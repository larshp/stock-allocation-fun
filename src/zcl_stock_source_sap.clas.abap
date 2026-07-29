CLASS zcl_stock_source_sap DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_stock_source.
ENDCLASS.

CLASS zcl_stock_source_sap IMPLEMENTATION.
  METHOD zif_stock_source~get_available.
    SELECT SINGLE labst
      FROM mard
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND lgort = @iv_storage_location
      INTO @rs_stock-quantity.

    SELECT SINGLE meins
      FROM mara
      WHERE matnr = @iv_material
      INTO @rs_stock-unit.
  ENDMETHOD.
ENDCLASS.
