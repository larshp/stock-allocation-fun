CLASS ltcl_alloc_recon_tolerance DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_recon_tolerance.

    METHODS setup.

    METHODS within_rule    FOR TESTING.
    METHODS reads_tolerance FOR TESTING.
    METHODS tight_rule     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_recon_tolerance IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_recon_tolerance( ).
  ENDMETHOD.

  METHOD within_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->within_tolerance( iv_left = 900 iv_right = 895 iv_tolerance = 10 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->within_tolerance( iv_left = 900 iv_right = 880 iv_tolerance = 10 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD reads_tolerance.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->tolerance( iv_base = 1000 iv_percent = 5 )
      exp = 50 ).
  ENDMETHOD.

  METHOD tight_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_tight( iv_tolerance = 5 iv_limit = 10 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_tight( iv_tolerance = 20 iv_limit = 10 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
