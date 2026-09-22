CLASS zcl_mard_stock_repository DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_stock_repository.
ENDCLASS.

CLASS zcl_mard_stock_repository IMPLEMENTATION.

  METHOD zif_stock_repository~get_unrestricted_stock.
    SELECT SUM( labst )
      FROM mard
      WHERE matnr = @iv_material
        AND werks = @iv_plant
      INTO @rv_quantity.
  ENDMETHOD.

ENDCLASS.
