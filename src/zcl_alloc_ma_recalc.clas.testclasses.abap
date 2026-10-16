CLASS ltcl_alloc_ma_recalc DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_ma_recalc.

    METHODS setup.

    METHODS recalculates FOR TESTING.
    METHODS rise_rule     FOR TESTING.
    METHODS computes_delta FOR TESTING.
    METHODS guards_zero   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_ma_recalc IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_ma_recalc( ).
  ENDMETHOD.

  METHOD recalculates.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->recalc( iv_old_price = 10 iv_old_qty = 100
                            iv_new_price = 20 iv_new_qty = 100 )
      exp = 15 ).
  ENDMETHOD.

  METHOD rise_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_rise( iv_old_price = 10 iv_new_price = 20 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_rise( iv_old_price = 20 iv_new_price = 10 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_delta.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->delta( iv_old_price = 10 iv_new_price = 20 ) exp = 10 ).
  ENDMETHOD.

  METHOD guards_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->recalc( iv_old_price = 10 iv_old_qty = 0
                            iv_new_price = 20 iv_new_qty = 0 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
