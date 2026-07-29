CLASS zcl_salloc_authorization_sap DEFINITION
  PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_salloc_authorization.
ENDCLASS.

CLASS zcl_salloc_authorization_sap IMPLEMENTATION.
  METHOD zif_salloc_authorization~check_authorization.
    AUTHORITY-CHECK OBJECT 'Z_SALLOC'
      ID 'ACTVT' FIELD iv_activity
      ID 'WERKS' FIELD iv_plant.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_salloc_integration
        EXPORTING
          iv_operation = `AUTHORIZATION`
          iv_reason = `Not authorized for plant and activity`.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
