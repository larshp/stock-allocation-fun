CLASS ltcl_alloc_replenish_fill DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_replenish_fill.

    METHODS setup.

    METHODS computes_rate      FOR TESTING.
    METHODS met_rule           FOR TESTING.
    METHODS computes_shortfall FOR TESTING.
    METHODS guards_zero        FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_replenish_fill IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_replenish_fill( ).
  ENDMETHOD.

  METHOD computes_rate.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rate( iv_delivered = 80 iv_requested = 100 )
      exp = 80 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rate( iv_delivered = 120 iv_requested = 100 )
      exp = 100 ).
  ENDMETHOD.

  METHOD met_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_met( iv_rate = 80 iv_target = 75 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_met( iv_rate = 60 iv_target = 75 ) exp = abap_false ).
  ENDMETHOD.

  METHOD computes_shortfall.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->shortfall( iv_delivered = 80 iv_requested = 100 )
      exp = 20 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->shortfall( iv_delivered = 120 iv_requested = 100 )
      exp = 0 ).
  ENDMETHOD.

  METHOD guards_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rate( iv_delivered = 10 iv_requested = 0 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
