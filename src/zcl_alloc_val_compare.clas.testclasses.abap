CLASS ltcl_alloc_val_compare DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_val_compare.

    METHODS setup.

    METHODS compares_values FOR TESTING.
    METHODS picks_best     FOR TESTING.
    METHODS computes_delta FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_val_compare IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_val_compare( ).
  ENDMETHOD.

  METHOD compares_values.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->compare( iv_value_a = 100 iv_value_b = 90 ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->compare( iv_value_a = 90 iv_value_b = 100 ) exp = -1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->compare( iv_value_a = 100 iv_value_b = 100 ) exp = 0 ).
  ENDMETHOD.

  METHOD picks_best.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->best_method( iv_value_cost = 100 iv_value_market = 90 )
      exp = 'MARKET' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->best_method( iv_value_cost = 90 iv_value_market = 100 )
      exp = 'COST' ).
  ENDMETHOD.

  METHOD computes_delta.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->delta( iv_value_a = 100 iv_value_b = 90 ) exp = 10 ).
  ENDMETHOD.

ENDCLASS.
