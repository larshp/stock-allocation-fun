CLASS zcl_stock_source_sap DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_stock_source.
ENDCLASS.

CLASS zcl_stock_source_sap IMPLEMENTATION.
  METHOD zif_stock_source~get_available.
    SELECT labst
      FROM mard
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND lgort = @iv_storage_location
      INTO TABLE @DATA(lt_stock).

    LOOP AT lt_stock INTO DATA(lv_stock).
      rv_quantity = rv_quantity + lv_stock.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

