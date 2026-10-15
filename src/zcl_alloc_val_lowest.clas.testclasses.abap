CLASS ltcl_alloc_val_lowest DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_val_lowest.

    METHODS setup.

    METHODS picks_lower    FOR TESTING.
    METHODS names_method   FOR TESTING.
    METHODS write_down_rule FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_val_lowest IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_val_lowest( ).
  ENDMETHOD.

  METHOD picks_lower.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( iv_cost = 100 iv_market = 90 ) exp = 90 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( iv_cost = 100 iv_market = 110 ) exp = 100 ).
  ENDMETHOD.

  METHOD names_method.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->method( iv_cost = 100 iv_market = 90 ) exp = 'MARKET' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->method( iv_cost = 100 iv_market = 110 ) exp = 'COST' ).
  ENDMETHOD.

  METHOD write_down_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_written_down( iv_cost = 100 iv_market = 90 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_written_down( iv_cost = 100 iv_market = 110 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
