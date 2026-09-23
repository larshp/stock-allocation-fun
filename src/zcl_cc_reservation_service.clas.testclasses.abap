CLASS lcl_cost_center_stock_repo DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_repository.
    METHODS set_location_stocks
      IMPORTING
        it_stock TYPE zif_stock_repository=>ty_location_stocks.
    METHODS set_batch_stocks
      IMPORTING
        it_stock TYPE zif_stock_repository=>ty_batch_stocks.
    METHODS get_read_count
      RETURNING
        VALUE(rv_count) TYPE i.
  PRIVATE SECTION.
    DATA mt_location_stock TYPE zif_stock_repository=>ty_location_stocks.
    DATA mt_batch_stock TYPE zif_stock_repository=>ty_batch_stocks.
    DATA mv_read_count TYPE i.
ENDCLASS.

CLASS lcl_cost_center_stock_repo IMPLEMENTATION.
  METHOD set_location_stocks.
    mt_location_stock = it_stock.
  ENDMETHOD.

  METHOD set_batch_stocks.
    mt_batch_stock = it_stock.
  ENDMETHOD.

  METHOD get_read_count.
    rv_count = mv_read_count.
  ENDMETHOD.

  METHOD zif_stock_repository~get_unrestricted_stock.
    ADD 1 TO mv_read_count.
  ENDMETHOD.

  METHOD zif_stock_repository~get_available_stock_by_date.
    ADD 1 TO mv_read_count.
  ENDMETHOD.

  METHOD zif_stock_repository~get_safety_stock.
    ADD 1 TO mv_read_count.
  ENDMETHOD.

  METHOD zif_stock_repository~get_sales_order_reservations.
    ADD 1 TO mv_read_count.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status.
    ADD 1 TO mv_read_count.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status_by_location.
    ADD 1 TO mv_read_count.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status_by_batch.
    ADD 1 TO mv_read_count.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_by_location.
    ADD 1 TO mv_read_count.
    rt_stock = mt_location_stock.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_by_batch.
    ADD 1 TO mv_read_count.
    rt_stock = mt_batch_stock.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_cost_center_uom_repo DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_material_uom_repository.
    METHODS set_base_unit
      IMPORTING
        iv_base_unit TYPE mara-meins.
    METHODS set_alt_unit_ratio
      IMPORTING
        iv_alternative_unit TYPE marm-meinh
        iv_numerator        TYPE marm-umrez
        iv_denominator      TYPE marm-umren.
  PRIVATE SECTION.
    DATA mv_base_unit TYPE mara-meins.
    DATA mv_alternative_unit TYPE marm-meinh.
    DATA ms_ratio TYPE zif_material_uom_repository=>ty_alt_unit_ratio.
ENDCLASS.

CLASS lcl_cost_center_uom_repo IMPLEMENTATION.
  METHOD set_base_unit.
    mv_base_unit = iv_base_unit.
  ENDMETHOD.

  METHOD set_alt_unit_ratio.
    mv_alternative_unit = iv_alternative_unit.
    ms_ratio-numerator = iv_numerator.
    ms_ratio-denominator = iv_denominator.
  ENDMETHOD.

  METHOD zif_material_uom_repository~get_base_unit.
    rv_base_unit = mv_base_unit.
  ENDMETHOD.

  METHOD zif_material_uom_repository~get_alt_unit_ratio.
    IF iv_alternative_unit = mv_alternative_unit.
      rs_ratio = ms_ratio.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_cost_center_res_api DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_cc_reservation_api.
    METHODS set_create_result
      IMPORTING
        is_result TYPE zif_cc_reservation_api=>ty_result.
    METHODS set_commit_result
      IMPORTING
        is_result TYPE zif_cc_reservation_api=>ty_commit_result.
    METHODS get_request
      RETURNING
        VALUE(rs_request) TYPE zif_cc_reservation_api=>ty_request.
    METHODS get_create_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_commit_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_rollback_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS was_test_run
      RETURNING
        VALUE(rv_test_run) TYPE abap_bool.
  PRIVATE SECTION.
    DATA ms_create_result TYPE zif_cc_reservation_api=>ty_result.
    DATA ms_commit_result TYPE zif_cc_reservation_api=>ty_commit_result.
    DATA ms_request TYPE zif_cc_reservation_api=>ty_request.
    DATA mv_create_count TYPE i.
    DATA mv_commit_count TYPE i.
    DATA mv_rollback_count TYPE i.
    DATA mv_test_run TYPE abap_bool.
ENDCLASS.

CLASS lcl_cost_center_res_api IMPLEMENTATION.
  METHOD set_create_result.
    ms_create_result = is_result.
  ENDMETHOD.

  METHOD set_commit_result.
    ms_commit_result = is_result.
  ENDMETHOD.

  METHOD get_request.
    rs_request = ms_request.
  ENDMETHOD.

  METHOD get_create_count.
    rv_count = mv_create_count.
  ENDMETHOD.

  METHOD get_commit_count.
    rv_count = mv_commit_count.
  ENDMETHOD.

  METHOD get_rollback_count.
    rv_count = mv_rollback_count.
  ENDMETHOD.

  METHOD was_test_run.
    rv_test_run = mv_test_run.
  ENDMETHOD.

  METHOD zif_cc_reservation_api~create_reservation.
    ADD 1 TO mv_create_count.
    ms_request = is_request.
    mv_test_run = iv_test_run.
    rs_result = ms_create_result.
  ENDMETHOD.

  METHOD zif_cc_reservation_api~commit.
    ADD 1 TO mv_commit_count.
    rs_result = ms_commit_result.
  ENDMETHOD.

  METHOD zif_cc_reservation_api~rollback.
    ADD 1 TO mv_rollback_count.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_cc_atp_api_double DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_material_availability_api.
    METHODS set_result
      IMPORTING
        is_result TYPE zif_material_availability_api=>ty_result.
    METHODS get_request
      RETURNING
        VALUE(rs_request) TYPE zif_material_availability_api=>ty_request.
    METHODS get_check_count
      RETURNING
        VALUE(rv_count) TYPE i.
  PRIVATE SECTION.
    DATA ms_result TYPE zif_material_availability_api=>ty_result.
    DATA ms_request TYPE zif_material_availability_api=>ty_request.
    DATA mv_check_count TYPE i.
ENDCLASS.

CLASS lcl_cc_atp_api_double IMPLEMENTATION.
  METHOD set_result.
    ms_result = is_result.
  ENDMETHOD.

  METHOD get_request.
    rs_request = ms_request.
  ENDMETHOD.

  METHOD get_check_count.
    rv_count = mv_check_count.
  ENDMETHOD.

  METHOD zif_material_availability_api~check_availability.
    ADD 1 TO mv_check_count.
    ms_request = is_request.
    rs_result = ms_result.
    rs_result-material = is_request-material.
    rs_result-plant = is_request-plant.
    rs_result-unit = is_request-unit.
    rs_result-check_rule = is_request-check_rule.
    rs_result-required_date = is_request-required_date.
    rs_result-requested_quantity = is_request-requested_quantity.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_cost_center_reservation DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_stock_repo TYPE REF TO lcl_cost_center_stock_repo.
    DATA mo_uom_repo TYPE REF TO lcl_cost_center_uom_repo.
    DATA mo_res_api TYPE REF TO lcl_cost_center_res_api.
    DATA mo_atp_api TYPE REF TO lcl_cc_atp_api_double.
    DATA mo_cut TYPE REF TO zcl_cc_reservation_service.
    METHODS setup.
    METHODS commits_partial_res FOR TESTING.
    METHODS converts_alt_unit_res FOR TESTING.
    METHODS allocates_across_locations FOR TESTING.
    METHODS prefers_location_first FOR TESTING.
    METHODS splits_batch_by_location FOR TESTING.
    METHODS falls_back_for_batch FOR TESTING.
    METHODS reserves_fefo_batches FOR TESTING.
    METHODS falls_back_for_fefo FOR TESTING.
    METHODS previews_fefo_without_bapi FOR TESTING.
    METHODS previews_cost_center_atp FOR TESTING.
    METHODS rejects_atp_without_rule FOR TESTING.
    METHODS previews_short_full_req FOR TESTING.
    METHODS selects_exact_batch FOR TESTING.
    METHODS requires_full_stock FOR TESTING.
    METHODS simulates_without_commit FOR TESTING.
    METHODS rolls_back_create_error FOR TESTING.
    METHODS rolls_back_commit_error FOR TESTING.
    METHODS skips_empty_stock FOR TESTING.
    METHODS rejects_blank_location FOR TESTING.
    METHODS rejects_fallback_no_loc FOR TESTING.
    METHODS rejects_unknown_unit FOR TESTING.
    METHODS rejects_zero_base_qty FOR TESTING.
    METHODS rejects_fefo_with_batch FOR TESTING.
    METHODS rejects_min_days_without_fefo FOR TESTING.
    METHODS rejects_negative_fefo_days FOR TESTING.
ENDCLASS.

CLASS ltcl_cost_center_reservation IMPLEMENTATION.
  METHOD setup.
    mo_stock_repo = NEW lcl_cost_center_stock_repo( ).
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '6.000' ) ) ).
    mo_uom_repo = NEW lcl_cost_center_uom_repo( ).
    mo_uom_repo->set_base_unit( iv_base_unit = 'EA' ).
    mo_res_api = NEW lcl_cost_center_res_api( ).
    mo_atp_api = NEW lcl_cc_atp_api_double( ).
    mo_res_api->set_create_result(
      is_result = VALUE #(
        reservation_number = '9000000001'
        is_successful      = abap_true ) ).
    mo_res_api->set_commit_result(
      is_result = VALUE #( is_successful = abap_true ) ).
    mo_cut = NEW zcl_cc_reservation_service(
      io_stock_repository          = mo_stock_repo
      io_reservation_api           = mo_res_api
      io_uom_repository            = mo_uom_repo
      io_material_availability_api = mo_atp_api ).
  ENDMETHOD.

  METHOD commits_partial_res.
    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_storage_location   = '0001'
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '10.000'
      iv_unit               = 'EA'
      iv_required_date      = '20261001' ).
    DATA(ls_request) = mo_res_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '9000000001'
      act = ls_result-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MAT-1'
      act = ls_request-material ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = ls_request-plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_request-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'COST-100'
      act = ls_request-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261001'
      act = ls_request-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD converts_alt_unit_res.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '18.000' ) ) ).
    mo_uom_repo->set_alt_unit_ratio(
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).

    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_storage_location   = '0001'
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '2.000'
      iv_unit               = 'BOX' ).
    DATA(ls_request) = mo_res_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = ls_result-source_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '24.000' )
      act = ls_result-base_requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '18.000' )
      act = ls_result-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_request-items[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '18.000' )
      act = ls_request-items[ 1 ]-quantity ).
  ENDMETHOD.

  METHOD allocates_across_locations.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0002'
          available_quantity = '5.000' )
        ( storage_location   = '0001'
          available_quantity = '3.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '6.000'
      iv_unit               = 'EA' ).
    DATA(ls_request) = mo_res_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-storage_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_request-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_request-items[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_request-items[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD prefers_location_first.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '5.000' )
        ( storage_location   = '0002'
          available_quantity = '1.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_storage_location   = '0002'
      iv_allow_fallback     = abap_true
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '3.000'
      iv_unit               = 'EA' ).
    DATA(ls_request) = mo_res_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_request-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_request-items[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_request-items[ 2 ]-quantity ).
  ENDMETHOD.

  METHOD selects_exact_batch.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'BATCH-1'
          available_quantity = '3.000' )
        ( storage_location   = '0001'
          batch              = 'BATCH-2'
          available_quantity = '8.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_storage_location   = '0001'
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '5.000'
      iv_unit               = 'EA'
      iv_batch              = 'BATCH-1'
      iv_required_date      = '20261001' ).
    DATA(ls_request) = mo_res_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BATCH-1'
      act = ls_request-items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_request-items[ 1 ]-quantity ).
  ENDMETHOD.

  METHOD splits_batch_by_location.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0002'
          batch              = 'BATCH-1'
          available_quantity = '5.000' )
        ( storage_location   = '0001'
          batch              = 'BATCH-1'
          available_quantity = '3.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '6.000'
      iv_unit               = 'EA'
      iv_batch              = 'BATCH-1' ).
    DATA(ls_request) = mo_res_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_request-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BATCH-1'
      act = ls_request-items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_request-items[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BATCH-1'
      act = ls_request-items[ 2 ]-batch ).
  ENDMETHOD.

  METHOD falls_back_for_batch.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'BATCH-1'
          available_quantity = '4.000' )
        ( storage_location   = '0002'
          batch              = 'BATCH-1'
          available_quantity = '1.000' )
        ( storage_location   = '0002'
          batch              = 'BATCH-2'
          available_quantity = '9.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_storage_location   = '0002'
      iv_allow_fallback     = abap_true
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '3.000'
      iv_unit               = 'EA'
      iv_batch              = 'BATCH-1' ).
    DATA(ls_request) = mo_res_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_request-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BATCH-1'
      act = ls_request-items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_request-items[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BATCH-1'
      act = ls_request-items[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_request-items[ 2 ]-quantity ).
  ENDMETHOD.

  METHOD reserves_fefo_batches.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-OLD'
          expiration_date    = '20260920'
          available_quantity = '10.000' )
        ( storage_location   = '0001'
          batch              = 'B-SHORT'
          expiration_date    = '20260925'
          available_quantity = '4.000' )
        ( storage_location   = '0002'
          batch              = 'B-BOUND'
          expiration_date    = '20260930'
          available_quantity = '2.000' )
        ( storage_location   = '0001'
          batch              = 'B-LATER'
          expiration_date    = '20261010'
          available_quantity = '5.000' )
        ( storage_location   = '0002'
          batch              = 'B-UNDATED'
          available_quantity = '4.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '4.000'
      iv_unit               = 'EA'
      iv_use_fefo_batches   = abap_true
      iv_fefo_as_of_date    = '20260923'
      iv_fefo_min_days      = 7 ).
    DATA(ls_request) = mo_res_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = ls_result-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-BOUND'
      act = ls_request-items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_request-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_request-items[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_request-items[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_request-items[ 2 ]-quantity ).
  ENDMETHOD.

  METHOD falls_back_for_fefo.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-OLD'
          expiration_date    = '20261010'
          available_quantity = '2.000' )
        ( storage_location   = '0001'
          batch              = 'B-LATER'
          expiration_date    = '20261015'
          available_quantity = '20.000' )
        ( storage_location   = '0002'
          batch              = 'B-PREF'
          expiration_date    = '20261101'
          available_quantity = '1.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_storage_location   = '0002'
      iv_allow_fallback     = abap_true
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '3.000'
      iv_unit               = 'EA'
      iv_use_fefo_batches   = abap_true
      iv_fefo_as_of_date    = '20261001' ).
    DATA(ls_request) = mo_res_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '23.000' )
      act = ls_result-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-PREF'
      act = ls_request-items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_request-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-OLD'
      act = ls_request-items[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_request-items[ 2 ]-storage_location ).
  ENDMETHOD.

  METHOD previews_fefo_without_bapi.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-OLD'
          expiration_date    = '20260920'
          available_quantity = '10.000' )
        ( storage_location   = '0002'
          batch              = 'B-BOUND'
          expiration_date    = '20260930'
          available_quantity = '2.000' )
        ( storage_location   = '0001'
          batch              = 'B-LATER'
          expiration_date    = '20261010'
          available_quantity = '5.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '4.000'
      iv_unit               = 'EA'
      iv_use_fefo_batches   = abap_true
      iv_fefo_as_of_date    = '20260923'
      iv_fefo_min_days      = 7 ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = ls_result-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_atp_api->get_check_count( ) ).
  ENDMETHOD.

  METHOD previews_cost_center_atp.
    mo_uom_repo->set_alt_unit_ratio(
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    mo_atp_api->set_result(
      is_result = VALUE #(
        available_at_plant_quantity = '20.000'
        confirmed_date              = '20261001'
        confirmed_quantity          = '12.000'
        is_fully_available          = abap_true
        is_check_relevant           = abap_true ) ).

    DATA(ls_result) = mo_cut->preview_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '1.000'
      iv_unit               = 'BOX'
      iv_required_date      = '20261001'
      iv_require_full_alloc = abap_true
      iv_check_atp          = abap_true
      iv_atp_check_rule     = 'A' ).
    DATA(ls_atp_request) = mo_atp_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-atp_result-is_fully_available ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '20.000' )
      act = ls_result-atp_result-available_at_plant_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-atp_result-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'A'
      act = ls_result-atp_result-check_rule ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261001'
      act = ls_result-atp_result-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-atp_result-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_atp_request-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_atp_request-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_atp_api->get_check_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_atp_without_rule.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_for_cost_center(
          iv_material           = 'MAT-1'
          iv_plant              = '1000'
          iv_cost_center        = 'COST-100'
          iv_requested_quantity = '2.000'
          iv_unit               = 'EA'
          iv_check_atp          = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_atp_api->get_check_count( ) ).
  ENDMETHOD.

  METHOD previews_short_full_req.
    DATA(ls_result) = mo_cut->preview_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_storage_location   = '0001'
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '10.000'
      iv_unit               = 'EA'
      iv_require_full_alloc = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD requires_full_stock.
    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_storage_location   = '0001'
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '10.000'
      iv_unit               = 'EA'
      iv_require_full_alloc = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD simulates_without_commit.
    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_storage_location   = '0001'
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '4.000'
      iv_unit               = 'EA'
      iv_test_run           = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = mo_res_api->was_test_run( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_create_error.
    mo_res_api->set_create_result(
      is_result = VALUE #(
        messages = VALUE #(
          ( type = 'E' message = 'Reservation rejected' ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_storage_location   = '0001'
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '4.000'
      iv_unit               = 'EA' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-reservation_number ).
  ENDMETHOD.

  METHOD rolls_back_commit_error.
    mo_res_api->set_commit_result(
      is_result = VALUE #(
        is_successful = abap_false
        message       = VALUE #(
          type    = 'E'
          message = 'Commit rejected' ) ) ).

    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_storage_location   = '0001'
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '4.000'
      iv_unit               = 'EA' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-reservation_number ).
  ENDMETHOD.

  METHOD skips_empty_stock.
    mo_stock_repo->set_location_stocks( it_stock = VALUE #( ) ).

    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_storage_location   = '0001'
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '4.000'
      iv_unit               = 'EA' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_unknown_unit.
    DATA lv_rejected TYPE abap_bool.
    TRY.
        mo_cut->reserve_for_cost_center(
          iv_material           = 'MAT-1'
          iv_plant              = '1000'
          iv_storage_location   = '0001'
          iv_cost_center        = 'COST-100'
          iv_requested_quantity = '4.000'
          iv_unit               = 'KG' ).
      CATCH zcx_invalid_reservation.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_blank_location.
    DATA lv_rejected TYPE abap_bool.
    TRY.
        mo_cut->reserve_for_cost_center(
          iv_material           = 'MAT-1'
          iv_plant              = '1000'
          iv_storage_location   = space
          iv_cost_center        = 'COST-100'
          iv_requested_quantity = '4.000'
          iv_unit               = 'EA' ).
      CATCH zcx_invalid_reservation.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_fallback_no_loc.
    DATA lv_rejected TYPE abap_bool.
    TRY.
        mo_cut->preview_for_cost_center(
          iv_material           = 'MAT-1'
          iv_plant              = '1000'
          iv_allow_fallback     = abap_true
          iv_cost_center        = 'COST-100'
          iv_requested_quantity = '4.000'
          iv_unit               = 'EA' ).
      CATCH zcx_invalid_reservation.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_zero_base_qty.
    mo_uom_repo->set_alt_unit_ratio(
      iv_alternative_unit = 'BOX'
      iv_numerator        = 1
      iv_denominator      = 99999 ).
    DATA lv_rejected TYPE abap_bool.
    TRY.
        mo_cut->reserve_for_cost_center(
          iv_material           = 'MAT-1'
          iv_plant              = '1000'
          iv_storage_location   = '0001'
          iv_cost_center        = 'COST-100'
          iv_requested_quantity = '0.001'
          iv_unit               = 'BOX' ).
      CATCH zcx_invalid_reservation.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_fefo_with_batch.
    DATA lv_rejected TYPE abap_bool.
    TRY.
        mo_cut->reserve_for_cost_center(
          iv_material           = 'MAT-1'
          iv_plant              = '1000'
          iv_storage_location   = '0001'
          iv_cost_center        = 'COST-100'
          iv_requested_quantity = '4.000'
          iv_unit               = 'EA'
          iv_batch              = 'BATCH-1'
          iv_use_fefo_batches   = abap_true ).
      CATCH zcx_invalid_reservation.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_min_days_without_fefo.
    DATA lv_rejected TYPE abap_bool.
    TRY.
        mo_cut->reserve_for_cost_center(
          iv_material           = 'MAT-1'
          iv_plant              = '1000'
          iv_storage_location   = '0001'
          iv_cost_center        = 'COST-100'
          iv_requested_quantity = '4.000'
          iv_unit               = 'EA'
          iv_fefo_min_days      = 1 ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_negative_fefo_days.
    DATA lv_rejected TYPE abap_bool.
    TRY.
        mo_cut->reserve_for_cost_center(
          iv_material           = 'MAT-1'
          iv_plant              = '1000'
          iv_storage_location   = '0001'
          iv_cost_center        = 'COST-100'
          iv_requested_quantity = '4.000'
          iv_unit               = 'EA'
          iv_use_fefo_batches   = abap_true
          iv_fefo_min_days      = -1 ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.
ENDCLASS.
