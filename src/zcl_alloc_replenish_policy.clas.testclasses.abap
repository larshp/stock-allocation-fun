CLASS ltcl_alloc_replenish_policy DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_replenish_policy.

    METHODS setup.

    METHODS reads_target_days  FOR TESTING.
    METHODS reads_service_level FOR TESTING.
    METHODS names_preset       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_replenish_policy IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_replenish_policy( ).
  ENDMETHOD.

  METHOD reads_target_days.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->target_days( 'LEAN' ) exp = 7 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->target_days( 'SAFE' ) exp = 30 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->target_days( 'OTHER' ) exp = 14 ).
  ENDMETHOD.

  METHOD reads_service_level.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->service_level( 'SAFE' ) exp = 99 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->service_level( 'OTHER' ) exp = 95 ).
  ENDMETHOD.

  METHOD names_preset.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->preset( iv_target_days = 7 iv_service_level = 90 )
      exp = 'LEAN' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->preset( iv_target_days = 1 iv_service_level = 1 )
      exp = 'CUSTOM' ).
  ENDMETHOD.

ENDCLASS.
