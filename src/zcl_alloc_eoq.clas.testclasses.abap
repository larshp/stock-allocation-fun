CLASS ltcl_alloc_eoq DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_eoq.

    METHODS setup.

    METHODS input
      IMPORTING
        iv_annual     TYPE menge_d
        iv_order      TYPE menge_d
        iv_holding    TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_eoq=>ty_input.

    METHODS textbook_case   FOR TESTING.
    METHODS perfect_square  FOR TESTING.
    METHODS zero_holding    FOR TESTING.
    METHODS zero_demand     FOR TESTING.
    METHODS larger_cost     FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_eoq IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_eoq( ).
  ENDMETHOD.

  METHOD input.
    rs_row-annual_demand = iv_annual.
    rs_row-order_cost = iv_order.
    rs_row-holding_cost = iv_holding.
  ENDMETHOD.

  METHOD textbook_case.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( input( iv_annual  = '1200'
                                      iv_order   = '25'
                                      iv_holding = '1' ) )
      exp = '244' ).
  ENDMETHOD.

  METHOD perfect_square.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( input( iv_annual  = '100'
                                      iv_order   = '2'
                                      iv_holding = '1' ) )
      exp = '20' ).
  ENDMETHOD.

  METHOD zero_holding.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( input( iv_annual  = '100'
                                      iv_order   = '2'
                                      iv_holding = '0' ) )
      exp = '0' ).
  ENDMETHOD.

  METHOD zero_demand.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( input( iv_annual  = '0'
                                      iv_order   = '2'
                                      iv_holding = '1' ) )
      exp = '0' ).
  ENDMETHOD.

  METHOD larger_cost.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( input( iv_annual  = '10000'
                                      iv_order   = '50'
                                      iv_holding = '4' ) )
      exp = '500' ).
  ENDMETHOD.

ENDCLASS.
