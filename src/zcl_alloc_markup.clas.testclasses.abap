CLASS ltcl_alloc_markup DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_markup.

    METHODS setup.

    METHODS computes_markup FOR TESTING.
    METHODS prices_from_cost FOR TESTING.
    METHODS computes_percent FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_markup IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_markup( ).
  ENDMETHOD.

  METHOD computes_markup.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->markup( iv_cost = 1000 iv_price = 1200 )
      exp = 200 ).
  ENDMETHOD.

  METHOD prices_from_cost.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->price_from_cost( iv_cost           = 1000
                                     iv_markup_percent = 20 )
      exp = 1200 ).
  ENDMETHOD.

  METHOD computes_percent.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->percent( iv_cost = 1000 iv_price = 1200 )
      exp = 20 ).
  ENDMETHOD.

ENDCLASS.
