CLASS ltcl_alloc_excess_stock DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_excess_stock.

    METHODS setup.

    METHODS excess_rule   FOR TESTING.
    METHODS computes_qty  FOR TESTING.
    METHODS computes_value FOR TESTING.
    METHODS guards_target FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_excess_stock IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_excess_stock( ).
  ENDMETHOD.

  METHOD excess_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_excess( iv_stock = 150 iv_target = 100 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_excess( iv_stock = 80 iv_target = 100 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_qty.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->excess_qty( iv_stock = 150 iv_target = 100 )
      exp = 50 ).
  ENDMETHOD.

  METHOD computes_value.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->excess_value( iv_stock = 150 iv_target = 100
                                  iv_unit_cost = 3 )
      exp = 150 ).
  ENDMETHOD.

  METHOD guards_target.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->excess_qty( iv_stock = 80 iv_target = 100 )
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->excess_value( iv_stock = 80 iv_target = 100
                                  iv_unit_cost = 3 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
