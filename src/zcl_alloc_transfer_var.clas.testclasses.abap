CLASS ltcl_alloc_transfer_var DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_transfer_var.

    METHODS setup.

    METHODS computes_variance FOR TESTING.
    METHODS over_rule         FOR TESTING.
    METHODS computes_percent  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_transfer_var IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_transfer_var( ).
  ENDMETHOD.

  METHOD computes_variance.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->variance( iv_transfer_price = 1100 iv_market_price = 1000 )
      exp = 100 ).
  ENDMETHOD.

  METHOD over_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_over( iv_transfer_price = 1100 iv_market_price = 1000 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_over( iv_transfer_price = 900 iv_market_price = 1000 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_percent.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->percent( iv_transfer_price = 1100 iv_market_price = 1000 )
      exp = 10 ).
  ENDMETHOD.

ENDCLASS.
