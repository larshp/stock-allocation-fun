CLASS ltcl_alloc_yield_trend DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_yield_trend.

    METHODS setup.

    METHODS reads_direction FOR TESTING.
    METHODS improving_rule  FOR TESTING.
    METHODS computes_delta  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_yield_trend IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_yield_trend( ).
  ENDMETHOD.

  METHOD reads_direction.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( iv_first = 90 iv_last = 95 ) exp = 'UP' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( iv_first = 95 iv_last = 90 ) exp = 'DOWN' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( iv_first = 95 iv_last = 95 ) exp = 'FLAT' ).
  ENDMETHOD.

  METHOD improving_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_improving( iv_first = 90 iv_last = 95 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_improving( iv_first = 95 iv_last = 90 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_delta.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->delta( iv_first = 90 iv_last = 95 ) exp = 5 ).
  ENDMETHOD.

ENDCLASS.
