CLASS ltcl_alloc_var_cause DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_var_cause.

    METHODS setup.

    METHODS reads_cause   FOR TESTING.
    METHODS price_rule    FOR TESTING.
    METHODS computes_share FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_var_cause IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_var_cause( ).
  ENDMETHOD.

  METHOD reads_cause.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cause( iv_price_variance = 200 iv_qty_variance = 100 )
      exp = 'PRICE' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cause( iv_price_variance = 100 iv_qty_variance = 200 )
      exp = 'QUANTITY' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cause( iv_price_variance = -100 iv_qty_variance = 50 )
      exp = 'PRICE' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cause( iv_price_variance = 0 iv_qty_variance = 0 )
      exp = 'NONE' ).
  ENDMETHOD.

  METHOD price_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_price( iv_price_variance = 200 iv_qty_variance = 100 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_price( iv_price_variance = 100 iv_qty_variance = 200 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_share.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->share( iv_part = 200 iv_whole = 300 ) exp = 66 ).
  ENDMETHOD.

ENDCLASS.
