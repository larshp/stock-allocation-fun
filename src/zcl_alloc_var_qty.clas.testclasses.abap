CLASS ltcl_alloc_var_qty DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_var_qty.

    METHODS setup.

    METHODS computes_variance FOR TESTING.
    METHODS favourable_rule FOR TESTING.
    METHODS computes_percent  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_var_qty IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_var_qty( ).
  ENDMETHOD.

  METHOD computes_variance.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->variance( iv_standard_qty = 100 iv_actual_qty = 120
                              iv_standard_price = 10 )
      exp = 200 ).
  ENDMETHOD.

  METHOD favourable_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_favourable( iv_standard_qty = 100 iv_actual_qty = 80 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_favourable( iv_standard_qty = 100 iv_actual_qty = 120 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_percent.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->percent( iv_standard_qty = 100 iv_actual_qty = 120 )
      exp = 20 ).
  ENDMETHOD.

ENDCLASS.
