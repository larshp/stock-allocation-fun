CLASS ltcl_alloc_service_factor DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_service_factor.

    METHODS setup.

    METHODS factors       FOR TESTING.
    METHODS reverse_lookup FOR TESTING.
    METHODS high_rule     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_service_factor IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_service_factor( ).
  ENDMETHOD.

  METHOD factors.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->factor( 99 ) exp = 233 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->factor( 90 ) exp = 128 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->factor( 50 ) exp = 0 ).
  ENDMETHOD.

  METHOD reverse_lookup.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->level_of( 233 ) exp = 99 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->level_of( 100 ) exp = 0 ).
  ENDMETHOD.

  METHOD high_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_high( 95 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_high( 90 ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
