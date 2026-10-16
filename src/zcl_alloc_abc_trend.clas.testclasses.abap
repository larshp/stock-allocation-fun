CLASS ltcl_alloc_abc_trend DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_abc_trend.

    METHODS setup.

    METHODS reads_direction FOR TESTING.
    METHODS computes_delta  FOR TESTING.
    METHODS rising_rule     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_abc_trend IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_abc_trend( ).
  ENDMETHOD.

  METHOD reads_direction.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( iv_previous = 600 iv_current = 900 )
      exp = 'UP' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( iv_previous = 900 iv_current = 600 )
      exp = 'DOWN' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( iv_previous = 600 iv_current = 600 )
      exp = 'FLAT' ).
  ENDMETHOD.

  METHOD computes_delta.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->delta( iv_previous = 600 iv_current = 900 )
      exp = 300 ).
  ENDMETHOD.

  METHOD rising_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_rising( iv_previous = 600 iv_current = 900 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_rising( iv_previous = 900 iv_current = 600 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
