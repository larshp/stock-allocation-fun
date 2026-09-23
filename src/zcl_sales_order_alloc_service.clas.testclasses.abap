CLASS lcl_order_api_double DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_sales_order_api.
    METHODS set_read_result
      IMPORTING
        is_result TYPE zif_sales_order_api=>ty_read_result.
  PRIVATE SECTION.
    DATA ms_read_result TYPE zif_sales_order_api=>ty_read_result.
ENDCLASS.

CLASS lcl_order_api_double IMPLEMENTATION.
  METHOD set_read_result.
    ms_read_result = is_result.
  ENDMETHOD.

  METHOD zif_sales_order_api~read_order.
    rs_result = ms_read_result.
    IF rs_result-order-sales_document IS INITIAL.
      rs_result-order-sales_document = iv_sales_document.
    ENDIF.
  ENDMETHOD.

  METHOD zif_sales_order_api~create_order.
  ENDMETHOD.

  METHOD zif_sales_order_api~change_order.
  ENDMETHOD.

  METHOD zif_sales_order_api~commit.
  ENDMETHOD.

  METHOD zif_sales_order_api~rollback.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_alloc_stock_repo DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_repository.
    METHODS set_stock
      IMPORTING
        iv_quantity TYPE mard-labst.
    METHODS set_location_stocks
      IMPORTING
        it_stock TYPE zif_stock_repository=>ty_location_stocks.
    METHODS set_batch_stocks
      IMPORTING
        it_stock TYPE zif_stock_repository=>ty_batch_stocks.
    METHODS set_sales_order_reservations
      IMPORTING
        it_reservations TYPE zif_stock_repository=>ty_sales_order_reservations.
    METHODS set_safety_stock
      IMPORTING
        iv_quantity TYPE marc-eisbe.
    METHODS get_read_count
      RETURNING
        VALUE(rv_count) TYPE i.
  PRIVATE SECTION.
    DATA mv_quantity TYPE mard-labst.
    DATA mv_safety_stock TYPE marc-eisbe.
    DATA mv_read_count TYPE i.
    DATA mt_location_stock TYPE zif_stock_repository=>ty_location_stocks.
    DATA mt_batch_stock TYPE zif_stock_repository=>ty_batch_stocks.
    DATA mt_sales_order_reservations TYPE
      zif_stock_repository=>ty_sales_order_reservations.
ENDCLASS.

CLASS lcl_alloc_stock_repo IMPLEMENTATION.
  METHOD set_stock.
    mv_quantity = iv_quantity.
    mt_location_stock = VALUE #(
      ( storage_location   = '0001'
        available_quantity = iv_quantity ) ).
  ENDMETHOD.

  METHOD set_location_stocks.
    mt_location_stock = it_stock.
    CLEAR mv_quantity.
    LOOP AT it_stock INTO DATA(ls_stock).
      mv_quantity = mv_quantity + ls_stock-available_quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD set_batch_stocks.
    mt_batch_stock = it_stock.
  ENDMETHOD.

  METHOD set_sales_order_reservations.
    mt_sales_order_reservations = it_reservations.
  ENDMETHOD.

  METHOD set_safety_stock.
    mv_safety_stock = iv_quantity.
  ENDMETHOD.

  METHOD get_read_count.
    rv_count = mv_read_count.
  ENDMETHOD.

  METHOD zif_stock_repository~get_unrestricted_stock.
    ADD 1 TO mv_read_count.
    rv_quantity = mv_quantity.
  ENDMETHOD.

  METHOD zif_stock_repository~get_available_stock_by_date.
    ADD 1 TO mv_read_count.
    rv_quantity = mv_quantity.
  ENDMETHOD.

  METHOD zif_stock_repository~get_safety_stock.
    ADD 1 TO mv_read_count.
    rv_quantity = mv_safety_stock.
  ENDMETHOD.

  METHOD zif_stock_repository~get_sales_order_reservations.
    ADD 1 TO mv_read_count.
    rt_reservations = mt_sales_order_reservations.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status.
    ADD 1 TO mv_read_count.
    CLEAR rs_status.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status_by_location.
    ADD 1 TO mv_read_count.
    CLEAR rt_status.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status_by_batch.
    ADD 1 TO mv_read_count.
    CLEAR rt_status.
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

CLASS lcl_reservation_api_double DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_so_reservation_api.
    METHODS set_create_result
      IMPORTING
        is_result TYPE zif_so_reservation_api=>ty_result.
    METHODS set_commit_result
      IMPORTING
        is_result TYPE zif_so_reservation_api=>ty_commit_result.
    METHODS get_create_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_commit_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_rollback_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_requests
      RETURNING
        VALUE(rt_requests) TYPE zif_so_reservation_api=>ty_requests.
    METHODS was_test_run
      RETURNING
        VALUE(rv_test_run) TYPE abap_bool.
  PRIVATE SECTION.
    DATA ms_create_result TYPE zif_so_reservation_api=>ty_result.
    DATA ms_commit_result TYPE zif_so_reservation_api=>ty_commit_result.
    DATA mt_requests TYPE zif_so_reservation_api=>ty_requests.
    DATA mv_create_count TYPE i.
    DATA mv_commit_count TYPE i.
    DATA mv_rollback_count TYPE i.
    DATA mv_test_run TYPE abap_bool.
    DATA mv_use_create_result TYPE abap_bool.
    DATA mv_use_commit_result TYPE abap_bool.
ENDCLASS.

CLASS lcl_reservation_api_double IMPLEMENTATION.
  METHOD set_create_result.
    ms_create_result = is_result.
    mv_use_create_result = abap_true.
  ENDMETHOD.

  METHOD set_commit_result.
    ms_commit_result = is_result.
    mv_use_commit_result = abap_true.
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

  METHOD get_requests.
    rt_requests = mt_requests.
  ENDMETHOD.

  METHOD was_test_run.
    rv_test_run = mv_test_run.
  ENDMETHOD.

  METHOD zif_so_reservation_api~create_reservations.
    ADD 1 TO mv_create_count.
    mt_requests = it_requests.
    mv_test_run = iv_test_run.
    IF mv_use_create_result = abap_true.
      rs_result = ms_create_result.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        request_id         = ls_request-request_id
        reservation_number = '9000000001'
        storage_location   = ls_request-storage_location
        batch              = ls_request-batch
        required_date      = ls_request-required_date
        quantity           = ls_request-quantity )
        TO rs_result-reservations.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_so_reservation_api~commit.
    ADD 1 TO mv_commit_count.
    IF mv_use_commit_result = abap_true.
      rs_result = ms_commit_result.
    ELSE.
      rs_result-is_successful = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD zif_so_reservation_api~delete_reservations.
    rs_result-is_successful = abap_true.
  ENDMETHOD.

  METHOD zif_so_reservation_api~rollback.
    ADD 1 TO mv_rollback_count.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_sales_atp_api_double DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_material_availability_api.
    METHODS set_result
      IMPORTING
        is_result TYPE zif_material_availability_api=>ty_result.
    METHODS get_check_count
      RETURNING
        VALUE(rv_count) TYPE i.
  PRIVATE SECTION.
    DATA ms_result TYPE zif_material_availability_api=>ty_result.
    DATA mv_check_count TYPE i.
ENDCLASS.

CLASS lcl_sales_atp_api_double IMPLEMENTATION.
  METHOD set_result.
    ms_result = is_result.
  ENDMETHOD.

  METHOD get_check_count.
    rv_count = mv_check_count.
  ENDMETHOD.

  METHOD zif_material_availability_api~check_availability.
    ADD 1 TO mv_check_count.
    rs_result = ms_result.
    rs_result-material = is_request-material.
    rs_result-plant = is_request-plant.
    rs_result-unit = is_request-unit.
    rs_result-check_rule = is_request-check_rule.
    rs_result-required_date = is_request-required_date.
    rs_result-requested_quantity = is_request-requested_quantity.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_sales_order_allocation DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_order_api TYPE REF TO lcl_order_api_double.
    DATA mo_stock_repository TYPE REF TO lcl_alloc_stock_repo.
    DATA mo_reservation_api TYPE REF TO lcl_reservation_api_double.
    DATA mo_availability_api TYPE REF TO lcl_sales_atp_api_double.
    DATA mo_cut TYPE REF TO zcl_sales_order_alloc_service.
    METHODS setup.
    METHODS maps_open_items_to_allocation FOR TESTING.
    METHODS previews_order_lines_with_atp FOR TESTING.
    METHODS rejects_atp_without_rule FOR TESTING.
    METHODS rejects_atp_without_date FOR TESTING.
    METHODS previews_confirmed_open_qty FOR TESTING.
    METHODS reserves_confirmed_open_qty FOR TESTING.
    METHODS rejects_confirmed_no_schedule FOR TESTING.
    METHODS returns_sales_unit_order_alloc FOR TESTING.
    METHODS prioritizes_demand_by_date FOR TESTING.
    METHODS subtracts_order_reservations FOR TESTING.
    METHODS skips_fully_reserved_order FOR TESTING.
    METHODS protects_order_safety_stock FOR TESTING.
    METHODS rejects_failed_order_read FOR TESTING.
    METHODS rejects_incomplete_open_item FOR TESTING.
    METHODS rejects_missing_sales_ratio FOR TESTING.
    METHODS reserves_allocated_quantities FOR TESTING.
    METHODS reserves_due_items_first FOR TESTING.
    METHODS rejects_short_full_reservation FOR TESTING.
    METHODS reserves_strict_full_order FOR TESTING.
    METHODS splits_reservation_by_location FOR TESTING.
    METHODS reserves_schedule_dates FOR TESTING.
    METHODS rejects_missing_schedule_date FOR TESTING.
    METHODS reserves_selected_batch FOR TESTING.
    METHODS reserves_preferred_batch_loc FOR TESTING.
    METHODS previews_order_fefo_batches FOR TESTING.
    METHODS previews_order_min_shelf_life FOR TESTING.
    METHODS rejects_min_days_without_fefo FOR TESTING.
    METHODS reserves_order_fefo_batches FOR TESTING.
    METHODS reserves_order_min_shelf_life FOR TESTING.
    METHODS rejects_fefo_batch_choice FOR TESTING.
    METHODS rejects_partial_batch_choice FOR TESTING.
    METHODS reserves_schedule_line_batches FOR TESTING.
    METHODS applies_item_batch_by_line FOR TESTING.
    METHODS rejects_partial_schedule_batch FOR TESTING.
    METHODS rejects_mixed_batch_choices FOR TESTING.
    METHODS reserves_schedule_locations FOR TESTING.
    METHODS applies_item_location_by_line FOR TESTING.
    METHODS short_selected_location FOR TESTING.
    METHODS uses_preferred_location FOR TESTING.
    METHODS rejects_short_location_choice FOR TESTING.
    METHODS rejects_mixed_stock_selections FOR TESTING.
    METHODS rejects_batch_fallback_no_loc FOR TESTING.
    METHODS simulates_order_reservation FOR TESTING.
    METHODS rolls_back_reservation_error FOR TESTING.
    METHODS rolls_back_commit_error FOR TESTING.
    METHODS skips_failed_order_reservation FOR TESTING.
ENDCLASS.

CLASS ltcl_sales_order_allocation IMPLEMENTATION.
  METHOD setup.
    mo_order_api = NEW lcl_order_api_double( ).
    mo_stock_repository = NEW lcl_alloc_stock_repo( ).
    mo_reservation_api = NEW lcl_reservation_api_double( ).
    mo_availability_api = NEW lcl_sales_atp_api_double( ).
    mo_cut = NEW zcl_sales_order_alloc_service(
      io_sales_order_api           = mo_order_api
      io_stock_repository          = mo_stock_repository
      io_reservation_api           = mo_reservation_api
      io_material_availability_api = mo_availability_api ).
  ENDMETHOD.

  METHOD maps_open_items_to_allocation.
    mo_stock_repository->set_stock( iv_quantity = '5.000' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          sales_document = '0000004711'
          items          = VALUE #(
            ( item_number        = '000010'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '4.000' )
            ( item_number        = '000020'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '3.000' )
            ( item_number        = '000030'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '0.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->preview_order( '0000004711' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711/000010'
      act = ls_result-allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 2 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_stock_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_availability_api->get_check_count( ) ).
  ENDMETHOD.

  METHOD previews_order_lines_with_atp.
    mo_stock_repository->set_stock( iv_quantity = '5.000' ).
    mo_availability_api->set_result(
      is_result = VALUE #(
        available_at_plant_quantity = '2.000'
        confirmed_date              = '20261005'
        confirmed_quantity          = '2.000'
        dialog_flag                 = 'X'
        is_fully_available          = abap_false
        is_check_relevant           = abap_true ) ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          sales_document = '0000004711'
          items          = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0002'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              requested_date     = '20261015'
              open_base_quantity = '3.000' )
            ( item_number        = '000010'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              requested_date     = '20261001'
              open_base_quantity = '4.000' )
            ( item_number        = '000010'
              schedule_line      = '0003'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              requested_date     = '20261015'
              open_base_quantity = '1.000' )
            ( item_number        = '000020'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              requested_date     = '20261031'
              open_base_quantity = '0.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->preview_order(
      iv_sales_document = '0000004711'
      iv_check_atp      = abap_true
      iv_atp_check_rule = 'A' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711/000010/0002'
      act = ls_result-atp_checks[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261015'
      act = ls_result-atp_checks[ 1 ]-result-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-atp_checks[ 1 ]-line_requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_result-atp_checks[ 1 ]-cumulative_requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_result-atp_checks[ 1 ]-result-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 1 ]-result-confirmed_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261001'
      act = ls_result-atp_checks[ 2 ]-result-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-atp_checks[ 2 ]-line_requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-atp_checks[ 2 ]-cumulative_requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-atp_checks[ 2 ]-result-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_result-atp_checks[ 3 ]-cumulative_requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261015'
      act = ls_result-atp_checks[ 3 ]-result-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_result-atp_checks[ 3 ]-result-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_availability_api->get_check_count( ) ).
  ENDMETHOD.

  METHOD rejects_atp_without_rule.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_order(
          iv_sales_document = '0000004711'
          iv_check_atp      = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_availability_api->get_check_count( ) ).
  ENDMETHOD.

  METHOD rejects_atp_without_date.
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          sales_document = '0000004711'
          items          = VALUE #(
            ( item_number        = '000010'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '2.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->preview_order(
      iv_sales_document = '0000004711'
      iv_check_atp      = abap_true
      iv_atp_check_rule = 'A' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-messages ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_availability_api->get_check_count( ) ).
  ENDMETHOD.

  METHOD previews_confirmed_open_qty.
    mo_stock_repository->set_stock( iv_quantity = '200.000' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          sales_document = '0000004711'
          items          = VALUE #(
            ( item_number                  = '000010'
              schedule_line                = '0001'
              has_confirmed_quantity       = abap_true
              material                     = 'MAT-1'
              plant                        = '1000'
              entry_unit                   = 'BOX'
              sales_unit_numerator         = 12
              sales_unit_denominator       = 1
              base_unit                    = 'EA'
              requested_date               = '20261001'
              open_quantity                = '10.000'
              open_base_quantity           = '120.000'
              confirmed_quantity           = '6.000'
              open_confirmed_quantity      = '4.000'
              confirmed_base_quantity      = '72.000'
              open_confirmed_base_quantity = '48.000' )
            ( item_number                  = '000010'
              schedule_line                = '0002'
              has_confirmed_quantity       = abap_true
              material                     = 'MAT-1'
              plant                        = '1000'
              entry_unit                   = 'EA'
              base_unit                    = 'EA'
              requested_date               = '20261008'
              open_quantity                = '5.000'
              open_base_quantity           = '5.000'
              confirmed_quantity           = '4.000'
              open_confirmed_quantity      = '3.000'
              confirmed_base_quantity      = '4.000'
              open_confirmed_base_quantity = '3.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->preview_order(
      iv_sales_document    = '0000004711'
      iv_use_confirmed_qty = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-sales_unit_allocations[ 1 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 2 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '48.000' )
      act = ls_result-allocations[ 1 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '48.000' )
      act = ls_result-sales_unit_allocations[ 1 ]-requested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711/000010/0002'
      act = ls_result-allocations[ 2 ]-request_id ).
  ENDMETHOD.

  METHOD reserves_confirmed_open_qty.
    mo_stock_repository->set_stock( iv_quantity = '10.000' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          sales_document = '0000004711'
          items          = VALUE #(
            ( item_number                  = '000010'
              schedule_line                = '0001'
              has_confirmed_quantity       = abap_true
              material                     = 'MAT-1'
              plant                        = '1000'
              entry_unit                   = 'EA'
              base_unit                    = 'EA'
              requested_date               = '20261001'
              open_quantity                = '10.000'
              open_base_quantity           = '10.000'
              confirmed_quantity           = '6.000'
              open_confirmed_quantity      = '4.000'
              confirmed_base_quantity      = '6.000'
              open_confirmed_base_quantity = '4.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_order(
      iv_sales_document    = '0000004711'
      iv_test_run          = abap_true
      iv_use_confirmed_qty = abap_true ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_requests[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261001'
      act = lt_requests[ 1 ]-required_date ).
  ENDMETHOD.

  METHOD rejects_confirmed_no_schedule.
    mo_stock_repository->set_stock( iv_quantity = '10.000' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          sales_document = '0000004711'
          items          = VALUE #(
            ( item_number        = '000010'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              open_quantity      = '5.000'
              open_base_quantity = '5.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->preview_order(
      iv_sales_document    = '0000004711'
      iv_use_confirmed_qty = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Confirmed-quantity mode requires schedule-line confirmation data'
      act = ls_result-messages[ 1 ]-message ).
  ENDMETHOD.

  METHOD returns_sales_unit_order_alloc.
    mo_stock_repository->set_stock( iv_quantity = '24.000' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          sales_document = '0000004711'
          items          = VALUE #(
            ( item_number            = '000010'
              material               = 'MAT-1'
              plant                  = '1000'
              quantity               = '4.000'
              entry_unit             = 'BOX'
              sales_unit_numerator   = 12
              sales_unit_denominator = 1
              base_quantity          = '48.000'
              open_quantity          = '4.000'
              open_base_quantity     = '48.000'
              base_unit              = 'EA' ) ) ) ) ).

    DATA(ls_preview) = mo_cut->preview_order( '0000004711' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_preview-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_preview-sales_unit_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = ls_preview-sales_unit_allocations[ 1 ]-sales_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_preview-sales_unit_allocations[ 1 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '48.000' )
      act = ls_preview-sales_unit_allocations[ 1 ]-requested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_preview-sales_unit_allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '24.000' )
      act = ls_preview-sales_unit_allocations[ 1 ]-available_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_preview-sales_unit_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '24.000' )
      act = ls_preview-sales_unit_allocations[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_preview-sales_unit_allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '24.000' )
      act = ls_preview-sales_unit_allocations[ 1 ]-shortfall_base_quantity ).

    DATA(ls_reservation) = mo_cut->reserve_order(
      iv_sales_document = '0000004711'
      iv_test_run       = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_reservation-sales_unit_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_reservation-sales_unit_allocations[ 1 ]-allocated_quantity ).
  ENDMETHOD.

  METHOD prioritizes_demand_by_date.
    mo_stock_repository->set_stock( iv_quantity = '5.000' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0002'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              requested_date     = '20261001'
              open_base_quantity = '3.000' )
            ( item_number        = '000020'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              requested_date     = '20260925'
              open_base_quantity = '3.000' )
            ( item_number        = '000015'
              schedule_line      = '0003'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              requested_date     = '20260925'
              open_base_quantity = '3.000' )
            ( item_number        = '000030'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '3.000' ) ) ) ) ).

    DATA(ls_default_result) = mo_cut->preview_order(
      iv_sales_document = '0000004711' ).
    DATA(ls_date_result) = mo_cut->preview_order(
      iv_sales_document     = '0000004711'
      iv_prioritize_by_date = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711/000010/0002'
      act = ls_default_result-allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_default_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_default_result-allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711/000020/0001'
      act = ls_date_result-allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_date_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711/000015/0003'
      act = ls_date_result-allocations[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_date_result-allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711/000010/0002'
      act = ls_date_result-allocations[ 3 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_date_result-allocations[ 3 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711/000030'
      act = ls_date_result-allocations[ 4 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_date_result-allocations[ 4 ]-allocated_quantity ).
  ENDMETHOD.

  METHOD subtracts_order_reservations.
    mo_stock_repository->set_stock( iv_quantity = '10.000' ).
    mo_stock_repository->set_sales_order_reservations(
      it_reservations = VALUE #(
        ( material         = 'MAT-1'
          plant            = '1000'
          item_number      = '000010'
          schedule_line    = '0001'
          requirement_date = '20261001'
          open_quantity    = '1.000' )
        ( material         = 'MAT-1'
          plant            = '1000'
          item_number      = '000010'
          requirement_date = '20261008'
          open_quantity    = '2.000' ) ) ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              requested_date     = '20261001'
              open_base_quantity = '5.000' )
            ( item_number        = '000010'
              schedule_line      = '0002'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              requested_date     = '20261008'
              open_base_quantity = '5.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->preview_order( '0000004711' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-allocations[ 1 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 2 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_stock_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD skips_fully_reserved_order.
    mo_stock_repository->set_stock( iv_quantity = '10.000' ).
    mo_stock_repository->set_sales_order_reservations(
      it_reservations = VALUE #(
        ( material         = 'MAT-1'
          plant            = '1000'
          item_number      = '000010'
          requirement_date = '20261001'
          open_quantity    = '5.000' ) ) ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              requested_date     = '20261001'
              open_base_quantity = '5.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_order(
      iv_sales_document = '0000004711' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_stock_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD protects_order_safety_stock.
    mo_stock_repository->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '5.000' ) ) ).
    mo_stock_repository->set_safety_stock( iv_quantity = '2.000' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '5.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_order(
      iv_sales_document       = '0000004711'
      iv_protect_safety_stock = abap_true ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_requests[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = mo_stock_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_failed_order_read.
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_false
        messages      = VALUE #(
          ( type = 'E' message = 'Order read failed' ) ) ) ).

    DATA(ls_result) = mo_cut->preview_order( '0000004711' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_incomplete_open_item.
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items          = VALUE #(
            ( item_number        = '000010'
              material           = 'MAT-1'
              plant              = '1000'
              open_base_quantity = '1.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->preview_order( '0000004711' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_missing_sales_ratio.
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items          = VALUE #(
            ( item_number        = '000010'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'BOX'
              base_unit          = 'EA'
              open_quantity      = '2.000'
              open_base_quantity = '24.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->preview_order( '0000004711' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Open order item lacks a valid sales unit conversion ratio'
      act = ls_result-messages[ 1 ]-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD reserves_allocated_quantities.
    mo_stock_repository->set_stock( iv_quantity = '4.000' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '3.000' )
            ( item_number        = '000020'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '3.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_order( '0000004711' ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-reservations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711/000010'
      act = lt_requests[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_requests[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '000020'
      act = lt_requests[ 2 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_requests[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_requests[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reservation_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD reserves_due_items_first.
    mo_stock_repository->set_stock( iv_quantity = '4.000' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0002'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              requested_date     = '20261001'
              open_base_quantity = '3.000' )
            ( item_number        = '000020'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              requested_date     = '20260925'
              open_base_quantity = '3.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_order(
      iv_sales_document     = '0000004711'
      iv_prioritize_by_date = abap_true ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711/000020/0001'
      act = lt_requests[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_requests[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711/000010/0002'
      act = lt_requests[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_requests[ 2 ]-quantity ).
  ENDMETHOD.

  METHOD rejects_short_full_reservation.
    mo_stock_repository->set_stock( iv_quantity = '4.000' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '3.000' )
            ( item_number        = '000020'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '3.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_order(
      iv_sales_document          = '0000004711'
      iv_require_full_allocation = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 2 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD reserves_strict_full_order.
    mo_stock_repository->set_stock( iv_quantity = '6.000' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '3.000' )
            ( item_number        = '000020'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '3.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_order(
      iv_sales_document          = '0000004711'
      iv_require_full_allocation = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-reservations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reservation_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD splits_reservation_by_location.
    mo_stock_repository->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '1.500' )
        ( storage_location   = '0002'
          available_quantity = '2.500' ) ) ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '3.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_order( '0000004711' ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-storage_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_requests[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.500' )
      act = lt_requests[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_requests[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.500' )
      act = lt_requests[ 2 ]-quantity ).
  ENDMETHOD.

  METHOD reserves_schedule_dates.
    mo_stock_repository->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '3.000' ) ) ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              requested_date     = '20261001'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '2.000' )
            ( item_number        = '000010'
              schedule_line      = '0002'
              requested_date     = '20261015'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '2.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_order( '0000004711' ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711/000010/0001'
      act = ls_result-allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711/000010/0002'
      act = ls_result-allocations[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261001'
      act = lt_requests[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261015'
      act = lt_requests[ 2 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 2 ]-shortfall_quantity ).
  ENDMETHOD.

  METHOD rejects_missing_schedule_date.
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '1.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->preview_order( '0000004711' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD reserves_selected_batch.
    mo_stock_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          available_quantity = '1.500' )
        ( storage_location   = '0002'
          batch              = 'B-1'
          available_quantity = '2.500' )
        ( storage_location   = '0001'
          batch              = 'B-2'
          available_quantity = '9.000' ) ) ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '3.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_order(
      iv_sales_document   = '0000004711'
      it_batch_selections = VALUE #(
        ( item_number = '000010' batch = 'B-1' ) ) ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = lt_requests[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_requests[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.500' )
      act = lt_requests[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-reservations[ 2 ]-batch ).
  ENDMETHOD.

  METHOD reserves_preferred_batch_loc.
    mo_stock_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          available_quantity = '1.500' )
        ( storage_location   = '0002'
          batch              = 'B-1'
          available_quantity = '2.500' )
        ( storage_location   = '0002'
          batch              = 'B-2'
          available_quantity = '9.000' ) ) ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '3.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_order(
      iv_sales_document   = '0000004711'
      it_batch_selections = VALUE #(
        ( item_number      = '000010'
          batch            = 'B-1'
          storage_location = '0002'
          allow_fallback   = abap_true ) ) ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_requests[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.500' )
      act = lt_requests[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_requests[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_requests[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = lt_requests[ 2 ]-batch ).
  ENDMETHOD.

  METHOD previews_order_fefo_batches.
    mo_stock_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-EXPIRED'
          expiration_date    = '20260920'
          available_quantity = '3.000' )
        ( storage_location   = '0001'
          batch              = 'B-LATER'
          expiration_date    = '20261015'
          available_quantity = '3.000' )
        ( storage_location   = '0002'
          batch              = 'B-SOON'
          expiration_date    = '20260930'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          batch              = 'B-NODATE'
          available_quantity = '4.000' ) ) ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '7.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->preview_order(
      iv_sales_document   = '0000004711'
      iv_use_fefo_batches = abap_true
      iv_fefo_as_of_date  = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '9.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-SOON'
      act = ls_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_result-batch_allocations[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-NODATE'
      act = ls_result-batch_allocations[ 3 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-allocations[ 1 ]-shortfall_quantity ).
  ENDMETHOD.

  METHOD previews_order_min_shelf_life.
    mo_stock_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-6-DAYS'
          expiration_date    = '20260929'
          available_quantity = '2.000' )
        ( storage_location   = '0001'
          batch              = 'B-7-DAYS'
          expiration_date    = '20260930'
          available_quantity = '1.000' )
        ( storage_location   = '0001'
          batch              = 'B-12-DAYS'
          expiration_date    = '20261005'
          available_quantity = '2.000' )
        ( storage_location   = '0001'
          batch              = 'B-NO-DATE'
          available_quantity = '5.000' ) ) ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '3.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->preview_order(
      iv_sales_document   = '0000004711'
      iv_use_fefo_batches = abap_true
      iv_fefo_as_of_date  = '20260923'
      iv_fefo_min_days    = 7 ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-7-DAYS'
      act = ls_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-12-DAYS'
      act = ls_result-batch_allocations[ 2 ]-batch ).
  ENDMETHOD.

  METHOD rejects_min_days_without_fefo.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_order(
          iv_sales_document = '0000004711'
          iv_fefo_min_days  = 7 ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD reserves_order_fefo_batches.
    mo_stock_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-EXPIRED'
          expiration_date    = '20260920'
          available_quantity = '5.000' )
        ( storage_location   = '0001'
          batch              = 'B-SOON'
          expiration_date    = '20260930'
          available_quantity = '2.000' )
        ( storage_location   = '0001'
          batch              = 'B-LATER'
          expiration_date    = '20261015'
          available_quantity = '4.000' )
        ( storage_location   = '0002'
          batch              = 'B-EARLIER'
          expiration_date    = '20260925'
          available_quantity = '8.000' ) ) ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '7.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_order(
      iv_sales_document      = '0000004711'
      it_location_selections = VALUE #(
        ( item_number      = '000010'
          storage_location = '0001'
          allow_fallback   = abap_true ) )
      iv_use_fefo_batches    = abap_true
      iv_fefo_as_of_date     = '20260923' ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-SOON'
      act = lt_requests[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_requests[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_requests[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = lt_requests[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_requests[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EARLIER'
      act = lt_requests[ 3 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_requests[ 3 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_requests[ 3 ]-quantity ).
  ENDMETHOD.

  METHOD reserves_order_min_shelf_life.
    mo_stock_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-6-DAYS'
          expiration_date    = '20260929'
          available_quantity = '5.000' )
        ( storage_location   = '0001'
          batch              = 'B-7-DAYS'
          expiration_date    = '20260930'
          available_quantity = '2.000' )
        ( storage_location   = '0001'
          batch              = 'B-12-DAYS'
          expiration_date    = '20261005'
          available_quantity = '4.000' )
        ( storage_location   = '0001'
          batch              = 'B-NO-DATE'
          available_quantity = '6.000' ) ) ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '3.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_order(
      iv_sales_document   = '0000004711'
      iv_use_fefo_batches = abap_true
      iv_fefo_as_of_date  = '20260923'
      iv_fefo_min_days    = 7 ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-7-DAYS'
      act = lt_requests[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-12-DAYS'
      act = lt_requests[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_requests[ 2 ]-quantity ).
  ENDMETHOD.

  METHOD rejects_fefo_batch_choice.
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '1.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->preview_order(
      iv_sales_document   = '0000004711'
      it_batch_selections = VALUE #(
        ( item_number = '000010'
          batch       = 'B-1' ) )
      iv_use_fefo_batches = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_partial_batch_choice.
    mo_stock_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          available_quantity = '5.000' ) ) ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '2.000' )
            ( item_number        = '000020'
              material           = 'MAT-2'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '2.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->preview_order(
      iv_sales_document   = '0000004711'
      it_batch_selections = VALUE #(
        ( item_number = '000010' batch = 'B-1' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_stock_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD reserves_schedule_line_batches.
    mo_stock_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          available_quantity = '2.000' )
        ( storage_location   = '0001'
          batch              = 'B-2'
          available_quantity = '3.000' ) ) ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              requested_date     = '20261001'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '2.000' )
            ( item_number        = '000010'
              schedule_line      = '0002'
              requested_date     = '20261015'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '3.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_order(
      iv_sales_document   = '0000004711'
      it_batch_selections = VALUE #(
        ( item_number   = '000010'
          schedule_line = '0001'
          batch         = 'B-1' )
        ( item_number   = '000010'
          schedule_line = '0002'
          batch         = 'B-2' ) ) ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = lt_requests[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-2'
      act = lt_requests[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711/000010/0002'
      act = lt_requests[ 2 ]-request_id ).
  ENDMETHOD.

  METHOD rejects_partial_schedule_batch.
    mo_stock_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          available_quantity = '5.000' ) ) ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              requested_date     = '20261001'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '2.000' )
            ( item_number        = '000010'
              schedule_line      = '0002'
              requested_date     = '20261015'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '2.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->preview_order(
      iv_sales_document   = '0000004711'
      it_batch_selections = VALUE #(
        ( item_number   = '000010'
          schedule_line = '0001'
          batch         = 'B-1' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_stock_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD applies_item_batch_by_line.
    mo_stock_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          available_quantity = '4.000' ) ) ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              requested_date     = '20261001'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '2.000' )
            ( item_number        = '000010'
              schedule_line      = '0002'
              requested_date     = '20261015'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '2.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_order(
      iv_sales_document   = '0000004711'
      it_batch_selections = VALUE #(
        ( item_number = '000010'
          batch       = 'B-1' ) ) ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = lt_requests[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = lt_requests[ 2 ]-batch ).
  ENDMETHOD.

  METHOD rejects_mixed_batch_choices.
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              requested_date     = '20261001'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '2.000' )
            ( item_number        = '000010'
              schedule_line      = '0002'
              requested_date     = '20261015'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '2.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->preview_order(
      iv_sales_document   = '0000004711'
      it_batch_selections = VALUE #(
        ( item_number = '000010'
          batch       = 'B-1' )
        ( item_number   = '000010'
          schedule_line = '0001'
          batch         = 'B-2' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_stock_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD reserves_schedule_locations.
    mo_stock_repository->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '3.000' )
        ( storage_location   = '0002'
          available_quantity = '2.000' ) ) ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              requested_date     = '20261001'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '2.000' )
            ( item_number        = '000010'
              schedule_line      = '0002'
              requested_date     = '20261015'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '3.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_order(
      iv_sales_document      = '0000004711'
      it_location_selections = VALUE #(
        ( item_number      = '000010'
          schedule_line    = '0001'
          storage_location = '0002' )
        ( item_number      = '000010'
          schedule_line    = '0002'
          storage_location = '0001' ) ) ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_requests[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_requests[ 2 ]-storage_location ).
  ENDMETHOD.

  METHOD applies_item_location_by_line.
    mo_stock_repository->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '9.000' )
        ( storage_location   = '0002'
          available_quantity = '4.000' ) ) ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              requested_date     = '20261001'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '2.000' )
            ( item_number        = '000010'
              schedule_line      = '0002'
              requested_date     = '20261015'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '2.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_order(
      iv_sales_document      = '0000004711'
      it_location_selections = VALUE #(
        ( item_number      = '000010'
          storage_location = '0002' ) ) ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_requests[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_requests[ 2 ]-storage_location ).
  ENDMETHOD.

  METHOD short_selected_location.
    mo_stock_repository->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '5.000' )
        ( storage_location   = '0002'
          available_quantity = '2.000' ) ) ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '3.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_order(
      iv_sales_document      = '0000004711'
      it_location_selections = VALUE #(
        ( item_number      = '000010'
          storage_location = '0002' ) ) ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_requests[ 1 ]-storage_location ).
  ENDMETHOD.

  METHOD uses_preferred_location.
    mo_stock_repository->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '3.000' )
        ( storage_location   = '0002'
          available_quantity = '2.000' ) ) ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '4.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_order(
      iv_sales_document      = '0000004711'
      it_location_selections = VALUE #(
        ( item_number      = '000010'
          storage_location = '0002'
          allow_fallback   = abap_true ) ) ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_requests[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_requests[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_requests[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_requests[ 2 ]-quantity ).
  ENDMETHOD.

  METHOD rejects_short_location_choice.
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              requested_date     = '20261001'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '2.000' )
            ( item_number        = '000010'
              schedule_line      = '0002'
              requested_date     = '20261015'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '2.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->preview_order(
      iv_sales_document      = '0000004711'
      it_location_selections = VALUE #(
        ( item_number      = '000010'
          schedule_line    = '0001'
          storage_location = '0001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_stock_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_mixed_stock_selections.
    DATA(ls_result) = mo_cut->preview_order(
      iv_sales_document      = '0000004711'
      it_batch_selections    = VALUE #(
        ( item_number = '000010'
          batch       = 'B-1' ) )
      it_location_selections = VALUE #(
        ( item_number      = '000010'
          storage_location = '0001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_batch_fallback_no_loc.
    DATA(ls_result) = mo_cut->preview_order(
      iv_sales_document   = '0000004711'
      it_batch_selections = VALUE #(
        ( item_number    = '000010'
          batch          = 'B-1'
          allow_fallback = abap_true ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD simulates_order_reservation.
    mo_stock_repository->set_stock( iv_quantity = '2.000' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '2.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_order(
      iv_sales_document = '0000004711'
      iv_test_run       = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = mo_reservation_api->was_test_run( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_reservation_error.
    mo_stock_repository->set_stock( iv_quantity = '1.000' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '1.000' ) ) ) ) ).
    mo_reservation_api->set_create_result(
      is_result = VALUE #(
        messages = VALUE #(
          ( type = 'E' message = 'ATP check failed' ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_order( '0000004711' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_result-reservations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reservation_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_commit_error.
    mo_stock_repository->set_stock( iv_quantity = '1.000' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '1.000' ) ) ) ) ).
    mo_reservation_api->set_commit_result(
      is_result = VALUE #(
        is_successful = abap_false
        message       = VALUE #(
          type    = 'E'
          message = 'Commit failed' ) ) ).

    DATA(ls_result) = mo_cut->reserve_order( '0000004711' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reservation_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reservation_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD skips_failed_order_reservation.
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_false
        messages      = VALUE #(
          ( type = 'E' message = 'Order read failed' ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_order( '0000004711' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repository->get_read_count( ) ).
  ENDMETHOD.
ENDCLASS.
