CLASS zcl_stock_source_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_stock_source.
ENDCLASS.

CLASS zcl_stock_source_sap IMPLEMENTATION.
  METHOD zif_stock_source~get_available.
    SELECT SINGLE labst
      FROM mard
      INTO @rv_available
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND lgort = @iv_storage_location.
    IF sy-subrc <> 0.
      CLEAR rv_available.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
