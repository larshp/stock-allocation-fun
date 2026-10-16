CLASS ltcl_alloc_days_supply DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_days_supply.

    METHODS setup.

    METHODS input
      IMPORTING
        iv_stock      TYPE menge_d
        iv_demand     TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_days_supply=>ty_input.

    METHODS whole_days      FOR TESTING.
    METHODS floored_days    FOR TESTING.
    METHODS below_one_day   FOR TESTING.
    METHODS zero_demand     FOR TESTING.
    METHODS zero_stock      FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_days_supply IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_days_supply( ).
  ENDMETHOD.

  METHOD input.
    rs_row-stock = iv_stock.
    rs_row-daily_demand = iv_demand.
  ENDMETHOD.

  METHOD whole_days.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( input( iv_stock = '100' iv_demand = '10' ) )
      exp = 10 ).
  ENDMETHOD.

  METHOD floored_days.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( input( iv_stock = '25' iv_demand = '10' ) )
      exp = 2 ).
  ENDMETHOD.

  METHOD below_one_day.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( input( iv_stock = '5' iv_demand = '10' ) )
      exp = 0 ).
  ENDMETHOD.

  METHOD zero_demand.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( input( iv_stock = '5' iv_demand = '0' ) )
      exp = 0 ).
  ENDMETHOD.

  METHOD zero_stock.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( input( iv_stock = '0' iv_demand = '10' ) )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
