CLASS ltcl_alloc_cobj_threshold DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cobj_threshold.

    METHODS setup.

    METHODS over_rule      FOR TESTING.
    METHODS computes_breach FOR TESTING.
    METHODS reads_level    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cobj_threshold IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cobj_threshold( ).
  ENDMETHOD.

  METHOD over_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_over( iv_cost = 1000 iv_limit = 900 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_over( iv_cost = 800 iv_limit = 900 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_breach.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->breach( iv_cost = 1000 iv_limit = 900 )
      exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->breach( iv_cost = 800 iv_limit = 900 )
      exp = 0 ).
  ENDMETHOD.

  METHOD reads_level.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->level( iv_cost = 1000 iv_limit = 900 )
      exp = 'OVER' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->level( iv_cost = 800 iv_limit = 900 )
      exp = 'UNDER' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->level( iv_cost = 900 iv_limit = 900 )
      exp = 'ON' ).
  ENDMETHOD.

ENDCLASS.
