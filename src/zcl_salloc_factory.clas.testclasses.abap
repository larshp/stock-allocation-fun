CLASS ltcl_factory DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS creates_sap_service FOR TESTING.
    METHODS creates_sap_reconciler FOR TESTING.
ENDCLASS.

CLASS ltcl_factory IMPLEMENTATION.
  METHOD creates_sap_service.
    DATA(service) = zcl_salloc_factory=>create_sap_service( ).
    cl_abap_unit_assert=>assert_bound( service ).
  ENDMETHOD.

  METHOD creates_sap_reconciler.
    DATA(reconciler) = zcl_salloc_factory=>create_sap_reconciler( ).
    cl_abap_unit_assert=>assert_bound( reconciler ).
  ENDMETHOD.
ENDCLASS.
