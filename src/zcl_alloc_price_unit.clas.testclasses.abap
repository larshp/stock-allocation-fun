CLASS ltcl_alloc_price_unit DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_price_unit.

    METHODS setup.

    METHODS counts_units FOR TESTING.
    METHODS scales_price FOR TESTING.
    METHODS bulk_rule    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_price_unit IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_price_unit( ).
  ENDMETHOD.

  METHOD counts_units.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->units_per( iv_price_unit = 100 iv_base_unit = 10 )
      exp = 10 ).
  ENDMETHOD.

  METHOD scales_price.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->scale( iv_price = 250 iv_price_unit = 100
                           iv_base_unit = 10 )
      exp = 25 ).
  ENDMETHOD.

  METHOD bulk_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_bulk( 100 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_bulk( 10 ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
