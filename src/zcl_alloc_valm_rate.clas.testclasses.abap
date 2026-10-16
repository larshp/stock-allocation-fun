CLASS ltcl_alloc_valm_rate DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_valm_rate.

    METHODS setup.

    METHODS computes_rate FOR TESTING.
    METHODS spike_rule    FOR TESTING.
    METHODS reads_direction FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_valm_rate IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_valm_rate( ).
  ENDMETHOD.

  METHOD computes_rate.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rate( iv_previous = 1000 iv_current = 1200 )
      exp = 20 ).
  ENDMETHOD.

  METHOD spike_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_spike( iv_rate_percent = 20 iv_limit_percent = 10 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_spike( iv_rate_percent = -20 iv_limit_percent = 10 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_spike( iv_rate_percent = 5 iv_limit_percent = 10 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD reads_direction.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( iv_previous = 1000 iv_current = 1200 )
      exp = 'UP' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( iv_previous = 1200 iv_current = 1000 )
      exp = 'DOWN' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( iv_previous = 1000 iv_current = 1000 )
      exp = 'FLAT' ).
  ENDMETHOD.

ENDCLASS.
