CLASS ltcl_alloc_var_trend DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_var_trend.

    METHODS setup.

    METHODS reads_direction FOR TESTING.
    METHODS improving_rule  FOR TESTING.
    METHODS computes_delta  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_var_trend IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_var_trend( ).
  ENDMETHOD.

  METHOD reads_direction.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( iv_previous = 200 iv_current = 150 )
      exp = 'IMPROVING' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( iv_previous = 150 iv_current = 200 )
      exp = 'WORSENING' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( iv_previous = 150 iv_current = 150 )
      exp = 'FLAT' ).
  ENDMETHOD.

  METHOD improving_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_improving( iv_previous = 200 iv_current = 150 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_improving( iv_previous = 150 iv_current = 200 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_delta.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->delta( iv_previous = 200 iv_current = 150 )
      exp = -50 ).
  ENDMETHOD.

ENDCLASS.
