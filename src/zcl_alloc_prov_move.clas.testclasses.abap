CLASS ltcl_alloc_prov_move DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_prov_move.

    METHODS setup.

    METHODS signed_movement FOR TESTING.
    METHODS increase_rule   FOR TESTING.
    METHODS size_of_move    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_prov_move IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_prov_move( ).
  ENDMETHOD.

  METHOD signed_movement.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->movement( iv_old_provision = 300 iv_new_provision = 400 )
      exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->movement( iv_old_provision = 400 iv_new_provision = 300 )
      exp = -100 ).
  ENDMETHOD.

  METHOD increase_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_increase( iv_old_provision = 300 iv_new_provision = 400 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_increase( iv_old_provision = 400 iv_new_provision = 300 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD size_of_move.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->delta( iv_old_provision = 400 iv_new_provision = 300 )
      exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->delta( iv_old_provision = 300 iv_new_provision = 400 )
      exp = 100 ).
  ENDMETHOD.

ENDCLASS.
