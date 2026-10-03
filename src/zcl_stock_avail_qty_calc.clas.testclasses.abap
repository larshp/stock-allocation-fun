CLASS ltcl_stock_avail_qty_calc DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS subtracts_open_reservations FOR TESTING.
    METHODS clamps_at_zero FOR TESTING.
    METHODS ignores_negative_reservations FOR TESTING.
    METHODS clamps_negative_physical_stock FOR TESTING.
    METHODS subtracts_safety_stock FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_avail_qty_calc IMPLEMENTATION.

  METHOD subtracts_open_reservations.
    DATA(lo_cut) = NEW zcl_stock_avail_qty_calc( ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = lo_cut->calculate(
        iv_unrestricted_quantity = '10.000'
        iv_reserved_quantity     = '4.000' ) ).
  ENDMETHOD.

  METHOD clamps_at_zero.
    DATA(lo_cut) = NEW zcl_stock_avail_qty_calc( ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = lo_cut->calculate(
        iv_unrestricted_quantity = '3.000'
        iv_reserved_quantity     = '5.000' ) ).
  ENDMETHOD.

  METHOD ignores_negative_reservations.
    DATA(lo_cut) = NEW zcl_stock_avail_qty_calc( ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lo_cut->calculate(
        iv_unrestricted_quantity = '3.000'
        iv_reserved_quantity     = '-2.000' ) ).
  ENDMETHOD.

  METHOD clamps_negative_physical_stock.
    DATA(lo_cut) = NEW zcl_stock_avail_qty_calc( ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = lo_cut->calculate(
        iv_unrestricted_quantity = '-2.000'
        iv_reserved_quantity     = '0.000' ) ).
  ENDMETHOD.

  METHOD subtracts_safety_stock.
    DATA(lo_cut) = NEW zcl_stock_avail_qty_calc( ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lo_cut->calculate_with_safety_stock(
        iv_available_quantity    = '8.000'
        iv_safety_stock_quantity = '3.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = lo_cut->calculate_with_safety_stock(
        iv_available_quantity    = '8.000'
        iv_safety_stock_quantity = '10.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = lo_cut->calculate_with_safety_stock(
        iv_available_quantity    = '8.000'
        iv_safety_stock_quantity = '-2.000' ) ).
  ENDMETHOD.

ENDCLASS.
