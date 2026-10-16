CLASS ltcl_alloc_disposal_auth DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_disposal_auth.

    METHODS setup.

    METHODS manager_any   FOR TESTING.
    METHODS clerk_limit   FOR TESTING.
    METHODS no_role       FOR TESTING.
    METHODS reasons       FOR TESTING.
    METHODS second_rule   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_disposal_auth IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_disposal_auth( ).
  ENDMETHOD.

  METHOD manager_any.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_authorised( iv_role         = 'MANAGER'
                                   iv_hazard_class = 'HAZ_6' )
      exp = abap_true ).
  ENDMETHOD.

  METHOD clerk_limit.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_authorised( iv_role         = 'CLERK'
                                   iv_hazard_class = 'HAZ_6' )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_authorised( iv_role         = 'CLERK'
                                   iv_hazard_class = 'NONE' )
      exp = abap_true ).
  ENDMETHOD.

  METHOD no_role.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_authorised( iv_role         = ''
                                   iv_hazard_class = 'NONE' )
      exp = abap_false ).
  ENDMETHOD.

  METHOD reasons.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( iv_role = '' iv_hazard_class = 'NONE' )
      exp = 'NO_ROLE' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( iv_role = 'CLERK' iv_hazard_class = 'HAZ_6' )
      exp = 'NOT_AUTHORISED' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( iv_role = 'MANAGER' iv_hazard_class = 'HAZ_6' )
      exp = 'OK' ).
  ENDMETHOD.

  METHOD second_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->needs_second( 'HAZ_6' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->needs_second( 'NONE' ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
