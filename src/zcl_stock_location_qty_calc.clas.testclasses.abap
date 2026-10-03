CLASS ltcl_stock_location_qty_calc DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS subtracts_loc_reservations FOR TESTING.
    METHODS spreads_plant_reservations FOR TESTING.
    METHODS clamps_overreserved_locations FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_location_qty_calc IMPLEMENTATION.

  METHOD subtracts_loc_reservations.
    DATA(lo_cut) = NEW zcl_stock_location_qty_calc( ).
    DATA(lt_result) = lo_cut->calculate(
      it_stock        = VALUE #(
        ( storage_location = '0001'
          quantity         = '5.000' ) )
      it_reservations = VALUE #(
        ( storage_location   = '0001'
          required_quantity  = '4.000'
          withdrawn_quantity = '1.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_result ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_result[ 1 ]-available_quantity ).
  ENDMETHOD.

  METHOD spreads_plant_reservations.
    DATA(lo_cut) = NEW zcl_stock_location_qty_calc( ).
    DATA(lt_result) = lo_cut->calculate(
      it_stock        = VALUE #(
        ( storage_location = '0002'
          quantity         = '5.000' )
        ( storage_location = '0001'
          quantity         = '4.000' ) )
      it_reservations = VALUE #(
        ( storage_location   = '0002'
          required_quantity  = '3.000'
          withdrawn_quantity = '1.000' )
        ( storage_location   = space
          required_quantity  = '4.000'
          withdrawn_quantity = '1.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_result ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_result[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_result[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_result[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_result[ 2 ]-available_quantity ).
  ENDMETHOD.

  METHOD clamps_overreserved_locations.
    DATA(lo_cut) = NEW zcl_stock_location_qty_calc( ).
    DATA(lt_result) = lo_cut->calculate(
      it_stock        = VALUE #(
        ( storage_location = '0001'
          quantity         = '2.000' )
        ( storage_location = '0002'
          quantity         = '5.000' ) )
      it_reservations = VALUE #(
        ( storage_location   = '0001'
          required_quantity  = '5.000'
          withdrawn_quantity = '0.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_result ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_result[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_result[ 1 ]-available_quantity ).
  ENDMETHOD.

ENDCLASS.
