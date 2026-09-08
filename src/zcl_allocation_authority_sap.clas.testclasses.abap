CLASS ltcl_allocation_authority_sap DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    METHODS grants_open_abap_user FOR TESTING.
    METHODS rejects_missing_plant FOR TESTING.
ENDCLASS.

CLASS ltcl_allocation_authority_sap IMPLEMENTATION.
  METHOD grants_open_abap_user.
    DATA(lo_cut) = NEW zcl_allocation_authority_sap( ).

    cl_abap_unit_assert=>assert_true(
      lo_cut->zif_allocation_authority~is_authorized( '1000' ) ).
  ENDMETHOD.

  METHOD rejects_missing_plant.
    DATA(lo_cut) = NEW zcl_allocation_authority_sap( ).

    cl_abap_unit_assert=>assert_false(
      lo_cut->zif_allocation_authority~is_authorized( space ) ).
  ENDMETHOD.
ENDCLASS.
