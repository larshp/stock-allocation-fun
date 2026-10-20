CLASS ltcl_stock_batch_qty_calc DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS subtracts_exact_batch_res FOR TESTING.
    METHODS spreads_unassigned_batch FOR TESTING.
    METHODS spreads_unassigned_location FOR TESTING.
    METHODS clamps_overreserved_batch FOR TESTING.
    METHODS nets_negative_batch_stock FOR TESTING.
    METHODS nets_large_negative_batch FOR TESTING.
    METHODS returns_resv_alloc_summaries FOR TESTING.
    METHODS returns_alloc_pass_shares FOR TESTING.
    METHODS preserves_expiry_source FOR TESTING.
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

  METHOD nets_negative_batch_stock.
    DATA(lo_cut) = NEW zcl_stock_batch_qty_calc( ).
    DATA(lt_result) = lo_cut->calculate(
      it_stock        = VALUE #(
        ( storage_location = '0001' batch = 'B-1' quantity = '100.000' )
        ( storage_location = '0001' batch = 'B-9' quantity = '-10.000' ) )
      it_reservations = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_result ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = lt_result[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '90.000' )
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

  METHOD nets_large_negative_batch.
    DATA(lo_cut) = NEW zcl_stock_batch_qty_calc( ).
    DATA(lt_result) = lo_cut->calculate(
      it_stock        = VALUE #(
        ( storage_location = '0001' batch = 'B-1'
          quantity         = '9999999999.999' )
        ( storage_location = '0001' batch = 'B-9'
          quantity         = '-9999999999.999' )
        ( storage_location = '0002' batch = 'B-9'
          quantity         = '-9999999999.999' ) )
      it_reservations = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_result ) ).
  ENDMETHOD.


  METHOD returns_alloc_pass_shares.
    DATA(lo_cut) = NEW zcl_stock_batch_qty_calc( ).
    DATA(ls_result) = lo_cut->calculate_with_summary(
      it_stock        = VALUE #(
        ( storage_location = '0001'
          batch            = 'A'
          quantity         = 2 )
        ( storage_location = '0002'
          batch            = 'B'
          quantity         = 1 ) )
      it_reservations = VALUE #(
        ( reservation_number = '0000000100'
          reservation_item   = '0001'
          storage_location   = '0001'
          batch              = 'A'
          required_quantity  = 3
          withdrawn_quantity = 0 ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '66.67' )
      act = ls_result-resv_allocation_summaries[ 1 ]-matched_share_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '33.33' )
      act = ls_result-resv_allocation_summaries[ 1 ]-fallback_share_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( 100 )
      act = ls_result-resv_allocation_summaries[ 1 ]-matched_share_pct
        + ls_result-resv_allocation_summaries[ 1 ]-fallback_share_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( 100 )
      act = ls_result-resv_allocation_summaries[ 1 ]-allocation_coverage_pct ).
  ENDMETHOD.

  METHOD returns_resv_alloc_summaries.
    DATA(lo_cut) = NEW zcl_stock_batch_qty_calc( ).
    DATA(ls_result) = lo_cut->calculate_with_summary(
      it_stock        = VALUE #(
        ( storage_location = '0001'
          batch            = 'B-1'
          quantity         = 5 ) )
      it_reservations = VALUE #(
        ( reservation_number = '0000000100'
          reservation_item   = '0001'
          storage_location   = '0001'
          batch              = 'B-1'
          required_quantity  = 3
          withdrawn_quantity = 0 )
        ( reservation_number = '0000000200'
          reservation_item   = '0001'
          storage_location   = '0001'
          batch              = 'B-1'
          required_quantity  = 3
          withdrawn_quantity = 0 )
        ( reservation_number = '0000000300'
          reservation_item   = '0001'
          storage_location   = '0001'
          batch              = 'B-1'
          required_quantity  = 1
          withdrawn_quantity = 0 ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-resv_allocation_summaries ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000100'
      act = ls_result-resv_allocation_summaries[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-resv_allocation_summaries[ 1 ]-allocation_sequence ).
    cl_abap_unit_assert=>assert_equals(
      exp = zif_stock_repository=>c_allocation_outcome_full
      act = ls_result-resv_allocation_summaries[ 1 ]-allocation_outcome ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( 3 )
      act = ls_result-resv_allocation_summaries[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( 100 )
      act = ls_result-resv_allocation_summaries[ 1 ]-allocation_coverage_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( 0 )
      act = ls_result-resv_allocation_summaries[ 1 ]-allocation_shortage_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( 100 )
      act = ls_result-resv_allocation_summaries[ 1 ]-matched_share_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( 0 )
      act = ls_result-resv_allocation_summaries[ 1 ]-fallback_share_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000200'
      act = ls_result-resv_allocation_summaries[ 2 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = zif_stock_repository=>c_allocation_outcome_partial
      act = ls_result-resv_allocation_summaries[ 2 ]-allocation_outcome ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( 2 )
      act = ls_result-resv_allocation_summaries[ 2 ]-matched_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( 1 )
      act = ls_result-resv_allocation_summaries[ 2 ]-uncovered_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '66.67' )
      act = ls_result-resv_allocation_summaries[ 2 ]-allocation_coverage_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '33.33' )
      act = ls_result-resv_allocation_summaries[ 2 ]-allocation_shortage_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '66.67' )
      act = ls_result-resv_allocation_summaries[ 2 ]-matched_share_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( 0 )
      act = ls_result-resv_allocation_summaries[ 2 ]-fallback_share_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( 100 )
      act = ls_result-resv_allocation_summaries[ 2 ]-allocation_coverage_pct
        + ls_result-resv_allocation_summaries[ 2 ]-allocation_shortage_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000300'
      act = ls_result-resv_allocation_summaries[ 3 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = zif_stock_repository=>c_allocation_outcome_none
      act = ls_result-resv_allocation_summaries[ 3 ]-allocation_outcome ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( 1 )
      act = ls_result-resv_allocation_summaries[ 3 ]-uncovered_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( 0 )
      act = ls_result-resv_allocation_summaries[ 3 ]-allocation_coverage_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( 100 )
      act = ls_result-resv_allocation_summaries[ 3 ]-allocation_shortage_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( 0 )
      act = ls_result-resv_allocation_summaries[ 3 ]-matched_share_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( 0 )
      act = ls_result-resv_allocation_summaries[ 3 ]-fallback_share_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( 3 )
      act = ls_result-fully_alloc_resv_open_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( 3 )
      act = ls_result-part_alloc_resv_open_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( 1 )
      act = ls_result-unalloc_resv_open_qty ).
  ENDMETHOD.


  METHOD preserves_expiry_source.
    DATA(lo_cut) = NEW zcl_stock_batch_qty_calc( ).
    DATA(ls_result) = lo_cut->calculate_with_summary(
      it_stock        = VALUE #(
        ( storage_location = '0001' batch = 'B-1'
          expiry_source = 'P' quantity = 2 )
        ( storage_location = '0002' batch = 'B-2'
          expiry_source = 'G' quantity = 3 ) )
      it_reservations = VALUE #(
        ( reservation_number = '0000000100'
          reservation_item   = '0001'
          storage_location   = '0001'
          batch              = 'B-1'
          required_quantity  = 5
          withdrawn_quantity = 0 ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocation_details ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'P'
      act = ls_result-allocation_details[ 1 ]-expiration_date_source ).
    cl_abap_unit_assert=>assert_equals(
      exp = zif_stock_repository=>c_allocation_pass_match
      act = ls_result-allocation_details[ 1 ]-allocation_pass ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'G'
      act = ls_result-allocation_details[ 2 ]-expiration_date_source ).
    cl_abap_unit_assert=>assert_equals(
      exp = zif_stock_repository=>c_allocation_pass_fallback
      act = ls_result-allocation_details[ 2 ]-allocation_pass ).
  ENDMETHOD.
ENDCLASS.
