CLASS zcl_allocation_authority_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_allocation_authority.
ENDCLASS.

CLASS zcl_allocation_authority_sap IMPLEMENTATION.
  METHOD zif_allocation_authority~is_authorized.
    IF iv_plant IS INITIAL.
      rv_authorized = abap_false.
      RETURN.
    ENDIF.

    AUTHORITY-CHECK OBJECT 'M_MATE_WRK'
      ID 'ACTVT' FIELD '02'
      ID 'WERKS' FIELD iv_plant.
    rv_authorized = xsdbool( sy-subrc = 0 ).
  ENDMETHOD.
ENDCLASS.
