CLASS zcl_stock_alloc_auth_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_stock_allocation_authority.
ENDCLASS.

CLASS zcl_stock_alloc_auth_sap IMPLEMENTATION.
  METHOD zif_stock_allocation_authority~check.
    AUTHORITY-CHECK OBJECT 'M_MRES_BWA'
      ID 'BWART' FIELD iv_movement_type
      ID 'ACTVT' FIELD '01'.
    IF sy-subrc <> 0.
      DATA lo_error TYPE REF TO zcx_stock_allocation.
      CREATE OBJECT lo_error.
      lo_error->message = 'Reservation authorization failed'.
      RAISE EXCEPTION lo_error.
    ENDIF.
    AUTHORITY-CHECK OBJECT 'M_MRES_WWA'
      ID 'WERKS' FIELD iv_plant
      ID 'ACTVT' FIELD '01'.
    IF sy-subrc <> 0.
      DATA lo_plant_error TYPE REF TO zcx_stock_allocation.
      CREATE OBJECT lo_plant_error.
      lo_plant_error->message = 'Reservation plant authorization failed'.
      RAISE EXCEPTION lo_plant_error.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_allocation_authority~check_cancel.
    AUTHORITY-CHECK OBJECT 'M_MRES_BWA'
      ID 'BWART' FIELD iv_movement_type
      ID 'ACTVT' FIELD '06'.
    IF sy-subrc <> 0.
      DATA lo_error TYPE REF TO zcx_stock_allocation.
      CREATE OBJECT lo_error.
      lo_error->message = 'Reservation cancellation authorization failed'.
      RAISE EXCEPTION lo_error.
    ENDIF.
    AUTHORITY-CHECK OBJECT 'M_MRES_WWA'
      ID 'WERKS' FIELD iv_plant
      ID 'ACTVT' FIELD '06'.
    IF sy-subrc <> 0.
      DATA lo_plant_error TYPE REF TO zcx_stock_allocation.
      CREATE OBJECT lo_plant_error.
      lo_plant_error->message = 'Reservation cancellation plant authorization failed'.
      RAISE EXCEPTION lo_plant_error.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
