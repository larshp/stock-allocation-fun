CLASS ltcl_alloc_recon_diff DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_recon_diff.

    METHODS setup.

    METHODS computes_difference FOR TESTING.
    METHODS balanced_rule     FOR TESTING.
    METHODS reads_magnitude   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_recon_diff IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_recon_diff( ).
  ENDMETHOD.

  METHOD computes_difference.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->difference( iv_left = 900 iv_right = 800 )
      exp = 100 ).
  ENDMETHOD.

  METHOD balanced_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_balanced( iv_left = 800 iv_right = 800 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_balanced( iv_left = 900 iv_right = 800 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD reads_magnitude.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->magnitude( iv_left = 800 iv_right = 900 )
      exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->magnitude( iv_left = 900 iv_right = 800 )
      exp = 100 ).
  ENDMETHOD.

ENDCLASS.
