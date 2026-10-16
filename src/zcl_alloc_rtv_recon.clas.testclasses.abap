CLASS ltcl_alloc_rtv_recon DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_rtv_recon.

    METHODS setup.

    METHODS signed_diff    FOR TESTING.
    METHODS absolute_diff  FOR TESTING.
    METHODS settles_within FOR TESTING.
    METHODS settled_guard  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_rtv_recon IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_rtv_recon( ).
  ENDMETHOD.

  METHOD signed_diff.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reconcile( iv_expected = 100 iv_actual = 90 )
      exp = -10 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reconcile( iv_expected = 100 iv_actual = 120 )
      exp = 20 ).
  ENDMETHOD.

  METHOD absolute_diff.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->difference( iv_expected = 100 iv_actual = 90 )
      exp = 10 ).
  ENDMETHOD.

  METHOD settles_within.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_settled( iv_expected = 100 iv_actual = 95
                                iv_tolerance = 5 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_settled( iv_expected = 100 iv_actual = 90
                                iv_tolerance = 5 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD settled_guard.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_settled( iv_expected = 100 iv_actual = 100
                                iv_tolerance = -1 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
