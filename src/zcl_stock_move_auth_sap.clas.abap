CLASS zcl_stock_move_auth_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_stock_movement_authority.
ENDCLASS.

CLASS zcl_stock_move_auth_sap IMPLEMENTATION.
  METHOD zif_stock_movement_authority~check.
    AUTHORITY-CHECK OBJECT 'M_MSEG_BWA'
      ID 'BWART' FIELD iv_movement_type
      ID 'ACTVT' FIELD '01'.
    IF sy-subrc <> 0.
      DATA lo_error TYPE REF TO zcx_stock_allocation.
      CREATE OBJECT lo_error.
      lo_error->message = 'Goods-movement authorization failed'.
      RAISE EXCEPTION lo_error.
    ENDIF.
    AUTHORITY-CHECK OBJECT 'M_MSEG_WWA'
      ID 'WERKS' FIELD iv_plant
      ID 'ACTVT' FIELD '01'.
    IF sy-subrc <> 0.
      DATA lo_plant_error TYPE REF TO zcx_stock_allocation.
      CREATE OBJECT lo_plant_error.
      lo_plant_error->message = 'Goods-movement plant authorization failed'.
      RAISE EXCEPTION lo_plant_error.
    ENDIF.
    AUTHORITY-CHECK OBJECT 'M_MSEG_LGO'
      ID 'WERKS' FIELD iv_plant
      ID 'LGORT' FIELD iv_storage_location
      ID 'BWART' FIELD iv_movement_type
      ID 'ACTVT' FIELD '01'.
    IF sy-subrc <> 0.
      DATA lo_storage_error TYPE REF TO zcx_stock_allocation.
      CREATE OBJECT lo_storage_error.
      lo_storage_error->message = 'Goods-movement storage authorization failed'.
      RAISE EXCEPTION lo_storage_error.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
