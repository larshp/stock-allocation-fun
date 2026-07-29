CLASS zcl_allocation_auth_sap DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_allocation_authorization.
ENDCLASS.

CLASS zcl_allocation_auth_sap IMPLEMENTATION.
  METHOD zif_allocation_authorization~is_authorized.
    AUTHORITY-CHECK OBJECT 'ZSTK_RUN'
      ID 'ACTVT' FIELD iv_activity
      ID 'WERKS' FIELD iv_plant
      ID 'LGORT' FIELD iv_storage_location.
    rv_authorized = xsdbool( sy-subrc = 0 ).
  ENDMETHOD.
ENDCLASS.
