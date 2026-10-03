CLASS ltcl_stock_batch_qty_calc DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS subtracts_exact_batch_res FOR TESTING.
    METHODS spreads_unassigned_batch FOR TESTING.
    METHODS spreads_unassigned_location FOR TESTING.
    METHODS clamps_overreserved_batch FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_batch_qty_calc IMPLEMENTATION.

  METHOD subtracts_exact_batch_res.
    DATA(lo_cut) = NEW zcl_stock_batch_qty_calc( ).
    DATA(lt_result) = lo_cut->calculate(
      it_stock        = VALUE #(
        ( storage_location = '0001' batch = 'B-1' quantity = '5.000' )
        ( storage_location = '0001' batch = 'B-2' quantity = '7.000' ) )
      it_reservations = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          required_quantity  = '3.000'
          withdrawn_quantity = '1.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_result ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '3.000' )
      act = lt_result[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '7.000' )
      act = lt_result[ 2 ]-available_quantity ).
  ENDMETHOD.

  METHOD spreads_unassigned_batch.
    DATA(lo_cut) = NEW zcl_stock_batch_qty_calc( ).
    DATA(lt_result) = lo_cut->calculate(
      it_stock        = VALUE #(
        ( storage_location = '0001' batch = 'B-1' quantity = '5.000' )
        ( storage_location = '0001' batch = 'B-2' quantity = '7.000' ) )
      it_reservations = VALUE #(
        ( storage_location   = '0001'
          required_quantity  = '6.000'
          withdrawn_quantity = '0.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_result ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-2'
      act = lt_result[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '6.000' )
      act = lt_result[ 1 ]-available_quantity ).
  ENDMETHOD.

  METHOD spreads_unassigned_location.
    DATA(lo_cut) = NEW zcl_stock_batch_qty_calc( ).
    DATA(lt_result) = lo_cut->calculate(
      it_stock        = VALUE #(
        ( storage_location = '0001' batch = 'B-1' quantity = '5.000' )
        ( storage_location = '0002' batch = 'B-1' quantity = '4.000' ) )
      it_reservations = VALUE #(
        ( batch              = 'B-1'
          required_quantity  = '6.000'
          withdrawn_quantity = '0.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_result ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_result[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '3.000' )
      act = lt_result[ 1 ]-available_quantity ).
  ENDMETHOD.

  METHOD clamps_overreserved_batch.
    DATA(lo_cut) = NEW zcl_stock_batch_qty_calc( ).
    DATA(lt_result) = lo_cut->calculate(
      it_stock        = VALUE #(
        ( storage_location = '0001' batch = 'B-1' quantity = '2.000' )
        ( storage_location = '0002' batch = 'B-2' quantity = '5.000' ) )
      it_reservations = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          required_quantity  = '10.000'
          withdrawn_quantity = '0.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_result ) ).
  ENDMETHOD.

ENDCLASS.
