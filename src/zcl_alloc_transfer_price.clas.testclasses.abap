CLASS ltcl_alloc_transfer_price DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_transfer_price.

    METHODS setup.

    METHODS builds_price  FOR TESTING.
    METHODS strips_markup FOR TESTING.
    METHODS at_cost_rule  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_transfer_price IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_transfer_price( ).
  ENDMETHOD.

  METHOD builds_price.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->price( iv_cost = 1000 iv_markup_percent = 10 )
      exp = 1100 ).
  ENDMETHOD.

  METHOD strips_markup.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->from_cost( iv_price = 1100 iv_markup_percent = 10 )
      exp = 1000 ).
  ENDMETHOD.

  METHOD at_cost_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_at_cost( 0 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_at_cost( 10 ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
