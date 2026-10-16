CLASS ltcl_alloc_var_sign DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_var_sign.

    METHODS setup.

    METHODS applies_sign   FOR TESTING.
    METHODS back_to_actual FOR TESTING.
    METHODS reads_magnitude FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_var_sign IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_var_sign( ).
  ENDMETHOD.

  METHOD applies_sign.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->apply_sign( iv_amount = 100 iv_is_adverse = abap_true )
      exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->apply_sign( iv_amount = 100 iv_is_adverse = abap_false )
      exp = -100 ).
  ENDMETHOD.

  METHOD back_to_actual.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->to_standard( iv_signed = 200 iv_standard_total = 1000 )
      exp = 1200 ).
  ENDMETHOD.

  METHOD reads_magnitude.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->magnitude( -100 ) exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->magnitude( 100 ) exp = 100 ).
  ENDMETHOD.

ENDCLASS.
