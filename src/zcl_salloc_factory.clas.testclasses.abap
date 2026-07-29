CLASS ltcl_factory DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS creates_sap_service FOR TESTING.
ENDCLASS.

CLASS ltcl_factory IMPLEMENTATION.
  METHOD creates_sap_service.
    DATA(service) = zcl_salloc_factory=>create_sap_service( ).
    cl_abap_unit_assert=>assert_bound( service ).
  ENDMETHOD.
ENDCLASS.
