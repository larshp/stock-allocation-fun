CLASS ltcl_alloc_fill_rate DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_fill_rate.

    METHODS setup.

    METHODS computes_rate    FOR TESTING.
    METHODS computes_percent FOR TESTING.
    METHODS met_rule         FOR TESTING.
    METHODS guards_zero      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_fill_rate IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_fill_rate( ).
  ENDMETHOD.

  METHOD computes_rate.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rate( iv_delivered = 950 iv_demanded = 1000 )
      exp = 950 ).
  ENDMETHOD.

  METHOD computes_percent.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rate_percent( iv_delivered = 950 iv_demanded = 1000 )
      exp = 95 ).
  ENDMETHOD.

  METHOD met_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_met( iv_rate_percent = 95 iv_target = 95 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_met( iv_rate_percent = 90 iv_target = 95 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD guards_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rate( iv_delivered = 950 iv_demanded = 0 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
