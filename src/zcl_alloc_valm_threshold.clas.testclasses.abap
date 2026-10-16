CLASS ltcl_alloc_valm_threshold DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_valm_threshold.

    METHODS setup.

    METHODS over_rule     FOR TESTING.
    METHODS computes_breach FOR TESTING.
    METHODS reads_level   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_valm_threshold IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_valm_threshold( ).
  ENDMETHOD.

  METHOD over_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_over( iv_value = 1500 iv_threshold = 1000 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_over( iv_value = 800 iv_threshold = 1000 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_breach.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->breach( iv_value = 1500 iv_threshold = 1000 )
      exp = 500 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->breach( iv_value = 800 iv_threshold = 1000 )
      exp = 0 ).
  ENDMETHOD.

  METHOD reads_level.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->level( iv_value = 2500 iv_threshold = 1000 )
      exp = 'HIGH' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->level( iv_value = 1500 iv_threshold = 1000 )
      exp = 'MEDIUM' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->level( iv_value = 800 iv_threshold = 1000 )
      exp = 'NONE' ).
  ENDMETHOD.

ENDCLASS.
