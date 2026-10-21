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

  METHOD zif_sales_order_api~read_orders.
    LOOP AT it_sales_documents INTO DATA(lv_sales_document).
      APPEND VALUE #(
        sales_document = lv_sales_document
        read_result    = zif_sales_order_api~read_order(
          lv_sales_document ) )
        TO rt_results.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_sales_order_api~create_order.
  ENDMETHOD.

  METHOD zif_sales_order_api~change_order.
  ENDMETHOD.

  METHOD zif_sales_order_api~delete_order_items.
    rs_result-sales_document = iv_sales_document.
    rs_result-is_successful = abap_true.
  ENDMETHOD.

  METHOD zif_sales_order_api~reject_order_items.
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
    METHODS set_pr_receipt_quantity
      IMPORTING
        iv_quantity TYPE mard-labst.
    METHODS set_sto_pr_receipt_quantity
      IMPORTING
        iv_quantity TYPE mard-labst.
    METHODS set_planned_receipt_quantity
      IMPORTING
        iv_quantity TYPE mard-labst.
    METHODS set_sched_agmt_receipt_qty
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
    DATA mv_pr_receipt_quantity TYPE mard-labst.
    DATA mv_sto_pr_receipt_quantity TYPE mard-labst.
    DATA mv_planned_receipt_quantity TYPE mard-labst.
    DATA mv_sched_agmt_receipt_quantity TYPE mard-labst.
    DATA mv_safety_stock TYPE marc-eisbe.
    DATA mv_read_count TYPE i.
    DATA mt_location_stock TYPE zif_stock_repository=>ty_location_stocks.
    DATA mt_batch_stock TYPE zif_stock_repository=>ty_batch_stocks.
    DATA mt_sales_order_reservations TYPE
      zif_stock_repository=>ty_sales_order_reservations.
ENDCLASS.

CLASS lcl_sales_stock_repo_double DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_so_stock_repository.
    DATA material_units TYPE zif_so_stock_repository=>ty_material_units.
    DATA order_items TYPE zif_so_stock_repository=>ty_order_items.
    DATA stock_rows TYPE zif_so_stock_repository=>ty_stock_rows.
    DATA reservation_rows TYPE zif_so_stock_repository=>ty_reservation_rows.
ENDCLASS.

CLASS lcl_sales_stock_repo_double IMPLEMENTATION.
  METHOD zif_so_stock_repository~read_base_units_bulk.
    rt_units = material_units.
  ENDMETHOD.

  METHOD zif_so_stock_repository~read_order_items_bulk.
    rt_items = order_items.
  ENDMETHOD.

  METHOD zif_so_stock_repository~read_stock_bulk.
    rt_rows = stock_rows.
  ENDMETHOD.

  METHOD zif_so_stock_repository~read_reservations_bulk.
    rt_rows = reservation_rows.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_sales_uom_repo_double DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_material_uom_repository.
ENDCLASS.

CLASS lcl_sales_uom_repo_double IMPLEMENTATION.
  METHOD zif_material_uom_repository~get_base_unit.
    IF iv_material = 'MAT-1'.
      rv_base_unit = 'EA'.
    ENDIF.
  ENDMETHOD.

  METHOD zif_material_uom_repository~get_alt_unit_ratio.
    IF iv_material = 'MAT-1' AND iv_alternative_unit = 'BOX'.
      rs_ratio-numerator = 2.
      rs_ratio-denominator = 1.
    ENDIF.
  ENDMETHOD.
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

  METHOD set_pr_receipt_quantity.
    mv_pr_receipt_quantity = iv_quantity.
  ENDMETHOD.

  METHOD set_sto_pr_receipt_quantity.
    mv_sto_pr_receipt_quantity = iv_quantity.
  ENDMETHOD.

  METHOD set_planned_receipt_quantity.
    mv_planned_receipt_quantity = iv_quantity.
  ENDMETHOD.

  METHOD set_sched_agmt_receipt_qty.
    mv_sched_agmt_receipt_quantity = iv_quantity.
  ENDMETHOD.

  METHOD zif_stock_repository~get_available_stock_by_date.
    ADD 1 TO mv_read_count.
    rv_quantity = mv_quantity.
    IF iv_include_pr_receipts = abap_true.
      rv_quantity = rv_quantity + mv_pr_receipt_quantity.
    ENDIF.
    IF iv_include_sto_pr_receipts = abap_true.
      rv_quantity = rv_quantity + mv_sto_pr_receipt_quantity.
    ENDIF.
    IF iv_include_planned_receipts = abap_true.
      rv_quantity = rv_quantity + mv_planned_receipt_quantity.
    ENDIF.
    IF iv_include_sched_agmt_receipts = abap_true.
      rv_quantity = rv_quantity + mv_sched_agmt_receipt_quantity.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_repository~get_available_stock_date_bulk.
    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        request_id         = ls_request-request_id
        material           = ls_request-material
        plant              = ls_request-plant
        required_date      = ls_request-required_date
        available_quantity =
          zif_stock_repository~get_available_stock_by_date(
            iv_material                    = ls_request-material
            iv_plant                       = ls_request-plant
            iv_required_date               = ls_request-required_date
            it_excluded_reservations       = it_excluded_reservations
            iv_include_po_receipts         = iv_include_po_receipts
            iv_include_sto_in_transit      = iv_include_sto_in_transit
            iv_include_unissued_sto        = iv_include_unissued_sto
            iv_subtract_unissued_sto       = iv_subtract_unissued_sto
            iv_include_prod_receipts       = iv_include_prod_receipts
            iv_include_pr_receipts         = iv_include_pr_receipts
            iv_include_sto_pr_receipts     = iv_include_sto_pr_receipts
            iv_include_planned_receipts    = iv_include_planned_receipts
            iv_include_fixed_planned       = iv_include_fixed_planned
            iv_include_sched_agmt_receipts =
              iv_include_sched_agmt_receipts ) )
        TO rt_results.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_projected_receipts.
  ENDMETHOD.

  METHOD zif_stock_repository~get_projected_receipts_bulk.
    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        request_id   = ls_request-request_id
        material     = ls_request-material
        plant        = ls_request-plant
        through_date = ls_request-through_date ) TO rt_results.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_po_confirmed_receipts.
  ENDMETHOD.

  METHOD zif_stock_repository~get_po_confirmed_receipts_bulk.
    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        request_id   = ls_request-request_id
        material     = ls_request-material
        plant        = ls_request-plant
        through_date = ls_request-through_date ) TO rt_results.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_safety_stock.
    ADD 1 TO mv_read_count.
    rv_quantity = mv_safety_stock.
  ENDMETHOD.

  METHOD zif_stock_repository~get_safety_stock_bulk.
    ADD 1 TO mv_read_count.
    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        request_id = ls_request-request_id
        material   = ls_request-material
        plant      = ls_request-plant
        quantity   = mv_safety_stock )
        TO rt_status.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_sales_order_reservations.
    ADD 1 TO mv_read_count.
    rt_reservations = mt_sales_order_reservations.
  ENDMETHOD.

  METHOD zif_stock_repository~get_order_reservations_bulk.
    ADD 1 TO mv_read_count.
    rt_reservations = mt_sales_order_reservations.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status.
    ADD 1 TO mv_read_count.
    CLEAR rs_status.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status_bulk.
    ADD 1 TO mv_read_count.
    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        request_id = ls_request-request_id
        material   = ls_request-material
        plant      = ls_request-plant )
        TO rt_status.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status_by_location.
    ADD 1 TO mv_read_count.
    CLEAR rt_status.
  ENDMETHOD.

  METHOD zif_stock_repository~get_location_stock_status_bulk.
    ADD 1 TO mv_read_count.
    LOOP AT it_requests INTO DATA(ls_request).
      DATA(ls_result) = VALUE
        zif_stock_repository=>ty_stock_location_bulk_result(
        request_id = ls_request-request_id
        material   = ls_request-material
        plant      = ls_request-plant ).
      LOOP AT mt_location_stock INTO DATA(ls_location_stock).
        APPEND VALUE #(
          storage_location           = ls_location_stock-storage_location
          unrestricted_quantity      = ls_location_stock-available_quantity
          available_unrestricted_qty = ls_location_stock-available_quantity )
          TO ls_result-locations.
      ENDLOOP.
      APPEND ls_result TO rt_status.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status_by_batch.
    ADD 1 TO mv_read_count.
    CLEAR rt_status.
  ENDMETHOD.

  METHOD zif_stock_repository~get_batch_stock_status_bulk.
    ADD 1 TO mv_read_count.
    DATA lt_batch_status TYPE zif_stock_repository=>ty_batch_stock_statuses.
    LOOP AT mt_batch_stock INTO DATA(ls_batch_stock).
      APPEND VALUE #(
        storage_location      = ls_batch_stock-storage_location
        batch                 = ls_batch_stock-batch
        expiration_date       = ls_batch_stock-expiration_date
        unrestricted_quantity = ls_batch_stock-available_quantity
        available_quantity    = ls_batch_stock-available_quantity )
        TO lt_batch_status.
    ENDLOOP.
    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        request_id = ls_request-request_id
        material   = ls_request-material
        plant      = ls_request-plant
        batches    = lt_batch_status )
        TO rt_status.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_by_location.
    ADD 1 TO mv_read_count.
    rt_stock = mt_location_stock.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_by_batch.
    ADD 1 TO mv_read_count.
    rt_stock = mt_batch_stock.
  ENDMETHOD.

  METHOD zif_stock_repository~get_open_stock_reservations.
    ADD 1 TO mv_read_count.
  ENDMETHOD.

  METHOD zif_stock_repository~get_open_stock_res_bulk.
    ADD 1 TO mv_read_count.
    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        request_id = ls_request-request_id
        material   = ls_request-material
        plant      = ls_request-plant )
        TO rt_status.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_reservation_api_double DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_so_reservation_api.
    METHODS set_create_result
      IMPORTING
        is_result TYPE zif_so_reservation_api=>ty_result.
    METHODS set_create_failure_call
      IMPORTING
        iv_call    TYPE i
        is_message TYPE zif_so_reservation_api=>ty_message.
    METHODS set_commit_result
      IMPORTING
        is_result TYPE zif_so_reservation_api=>ty_commit_result.
    METHODS set_commit_failure_call
      IMPORTING
        iv_call   TYPE i
        is_result TYPE zif_so_reservation_api=>ty_commit_result.
    METHODS set_delete_result
      IMPORTING
        is_result TYPE zif_so_reservation_api=>ty_delete_result.
    METHODS get_create_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_commit_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_rollback_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_delete_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_deleted_numbers
      RETURNING
        VALUE(rt_numbers) TYPE zif_so_reservation_api=>ty_reservation_numbers.
    METHODS get_requests
      RETURNING
        VALUE(rt_requests) TYPE zif_so_reservation_api=>ty_requests.
    METHODS was_test_run
      RETURNING
        VALUE(rv_test_run) TYPE abap_bool.
    METHODS was_delete_test_run
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
    DATA mv_fail_create_call TYPE i.
    DATA ms_create_failure_message TYPE zif_so_reservation_api=>ty_message.
    DATA mv_fail_commit_call TYPE i.
    DATA ms_commit_failure_result TYPE zif_so_reservation_api=>ty_commit_result.
    DATA ms_delete_result TYPE zif_so_reservation_api=>ty_delete_result.
    DATA mt_deleted_numbers TYPE zif_so_reservation_api=>ty_reservation_numbers.
    DATA mv_use_create_result TYPE abap_bool.
    DATA mv_use_commit_result TYPE abap_bool.
    DATA mv_use_delete_result TYPE abap_bool.
    DATA mv_delete_count TYPE i.
    DATA mv_delete_test_run TYPE abap_bool.
ENDCLASS.

CLASS lcl_reservation_api_double IMPLEMENTATION.
  METHOD set_create_result.
    ms_create_result = is_result.
    mv_use_create_result = abap_true.
  ENDMETHOD.

  METHOD set_create_failure_call.
    mv_fail_create_call = iv_call.
    ms_create_failure_message = is_message.
  ENDMETHOD.

  METHOD set_commit_result.
    ms_commit_result = is_result.
    mv_use_commit_result = abap_true.
  ENDMETHOD.

  METHOD set_commit_failure_call.
    mv_fail_commit_call = iv_call.
    ms_commit_failure_result = is_result.
  ENDMETHOD.

  METHOD set_delete_result.
    ms_delete_result = is_result.
    mv_use_delete_result = abap_true.
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

  METHOD get_delete_count.
    rv_count = mv_delete_count.
  ENDMETHOD.

  METHOD get_deleted_numbers.
    rt_numbers = mt_deleted_numbers.
  ENDMETHOD.

  METHOD get_requests.
    rt_requests = mt_requests.
  ENDMETHOD.

  METHOD was_test_run.
    rv_test_run = mv_test_run.
  ENDMETHOD.

  METHOD was_delete_test_run.
    rv_test_run = mv_delete_test_run.
  ENDMETHOD.

  METHOD zif_so_reservation_api~create_reservations.
    ADD 1 TO mv_create_count.
    mt_requests = it_requests.
    mv_test_run = iv_test_run.
    IF mv_create_count = mv_fail_create_call.
      rs_result-is_successful = abap_false.
      APPEND ms_create_failure_message TO rs_result-messages.
      RETURN.
    ENDIF.
    IF mv_use_create_result = abap_true.
      rs_result = ms_create_result.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        request_id         = ls_request-request_id
        reservation_number = sy-tabix
        storage_location   = ls_request-storage_location
        batch              = ls_request-batch
        required_date      = ls_request-required_date
        quantity           = ls_request-quantity )
        TO rs_result-reservations.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_so_reservation_api~commit.
    ADD 1 TO mv_commit_count.
    IF mv_commit_count = mv_fail_commit_call.
      rs_result = ms_commit_failure_result.
      RETURN.
    ENDIF.
    IF mv_use_commit_result = abap_true.
      rs_result = ms_commit_result.
    ELSE.
      rs_result-is_successful = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD zif_so_reservation_api~delete_reservations.
    ADD 1 TO mv_delete_count.
    mt_deleted_numbers = it_reservation_numbers.
    mv_delete_test_run = iv_test_run.
    IF mv_use_delete_result = abap_true.
      rs_result = ms_delete_result.
    ELSE.
      rs_result-is_successful = abap_true.
    ENDIF.
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
    DATA mo_sales_stock_repository TYPE REF TO lcl_sales_stock_repo_double.
    DATA mo_cut TYPE REF TO zcl_sales_order_alloc_service.
    METHODS setup.
    METHODS get_so_fefo_reserve_preview
      RETURNING
        VALUE(rs_result) TYPE zcl_so_stock_service=>ty_fefo_issue_result.
    METHODS get_multi_cutoff_res_preview
      RETURNING
        VALUE(rs_result) TYPE zcl_so_stock_service=>ty_fefo_issue_result.
    METHODS get_two_item_fefo_preview
      RETURNING
        VALUE(rs_result) TYPE zcl_so_stock_service=>ty_fefo_issue_result.
    METHODS reserves_so_stock_fefo FOR TESTING.
    METHODS reserves_so_fefo_fallback FOR TESTING.
    METHODS rejects_so_fefo_location FOR TESTING.
    METHODS rejects_so_fefo_request_scope FOR TESTING.
    METHODS reserves_selected_so_fefo FOR TESTING.
    METHODS rejects_bad_so_fefo_selection FOR TESTING.
    METHODS reserves_rechecked_so_fefo FOR TESTING.
    METHODS reserves_selected_fefo_recheck FOR TESTING.
    METHODS rejects_changed_fefo_resv FOR TESTING.
    METHODS rejects_changed_fefo_scope FOR TESTING.
    METHODS reserves_fefo_demands_direct FOR TESTING.
    METHODS reserves_fefo_allowed_locs FOR TESTING.
    METHODS reserves_selected_direct_fefo FOR TESTING.
    METHODS reserves_fefo_demands_uom FOR TESTING.
    METHODS rejects_short_fefo_demands FOR TESTING.
    METHODS reserves_demand_fefo_recheck FOR TESTING.
    METHODS reserves_selected_demand_rechk FOR TESTING.
    METHODS rejects_changed_demand_rechk FOR TESTING.
    METHODS reserves_uom_fefo_recheck FOR TESTING.
    METHODS releases_fefo_reservations FOR TESTING.
    METHODS releases_one_fefo_split FOR TESTING.
    METHODS releases_selected_fefo_res FOR TESTING.
    METHODS simulates_fefo_release FOR TESTING.
    METHODS rejects_uncommitted_fefo_del FOR TESTING.
    METHODS rejects_bad_fefo_release_rows FOR TESTING.
    METHODS rolls_back_fefo_delete_error FOR TESTING.
    METHODS rolls_back_fefo_release_commit FOR TESTING.
    METHODS simulates_so_stock_fefo FOR TESTING.
    METHODS rejects_short_so_stock_fefo FOR TESTING.
    METHODS rejects_fefo_sum_overflow FOR TESTING.
    METHODS rejects_expired_fefo_resv FOR TESTING.
    METHODS rolls_back_so_fefo_reservation FOR TESTING.
    METHODS rolls_back_so_fefo_commit FOR TESTING.
    METHODS previews_multi_orders_date FOR TESTING.
    METHODS previews_mbd_dates FOR TESTING.
    METHODS rejects_missing_mbd_date FOR TESTING.
    METHODS rejects_bad_mbd_flag FOR TESTING.
    METHODS previews_single_mbd FOR TESTING.
    METHODS previews_mbd_without_edatu FOR TESTING.
    METHODS reserves_single_mbd FOR TESTING.
    METHODS rejects_missing_single_mbd FOR TESTING.
    METHODS rejects_bad_single_mbd FOR TESTING.
    METHODS prioritizes_multi_order FOR TESTING.
    METHODS rejects_bad_demand_priority FOR TESTING.
    METHODS previews_multi_order_pr_supply FOR TESTING.
    METHODS previews_multi_sto_supply FOR TESTING.
    METHODS previews_multi_planned_supply FOR TESTING.
    METHODS previews_sched_agmt_supply FOR TESTING.
    METHODS previews_multi_existing_res FOR TESTING.
    METHODS previews_multi_confirmed_qty FOR TESTING.
    METHODS reserves_multi_orders_by_date FOR TESTING.
    METHODS reserves_multi_orders_bulk FOR TESTING.
    METHODS rolls_back_bulk_commit FOR TESTING.
    METHODS simulates_multi_res_bulk FOR TESTING.
    METHODS reserves_mbd_dates FOR TESTING.
    METHODS reserves_by_order_priority FOR TESTING.
    METHODS orders_priority_reservations FOR TESTING.
    METHODS reserves_sched_agmt_supply FOR TESTING.
    METHODS reserves_multi_due_first FOR TESTING.
    METHODS simulates_multi_order_res FOR TESTING.
    METHODS rejects_short_multi_reserve FOR TESTING.
    METHODS rejects_short_multi_atp FOR TESTING.
    METHODS reserves_multi_atp_confirmed FOR TESTING.
    METHODS rejects_late_multi_atp FOR TESTING.
    METHODS rolls_back_multi_order_res FOR TESTING.
    METHODS rolls_back_multi_commit_err FOR TESTING.
    METHODS rejects_bad_multi_res_result FOR TESTING.
    METHODS prepare_multi_res_fixture.
    METHODS maps_open_items_to_allocation FOR TESTING.
    METHODS reports_order_floor_trace FOR TESTING.
    METHODS summarizes_document_outcomes FOR TESTING.
    METHODS summarizes_outcome_percentages FOR TESTING.
    METHODS previews_order_lines_with_atp FOR TESTING.
    METHODS previews_priority_atp FOR TESTING.
    METHODS rejects_atp_without_rule FOR TESTING.
    METHODS rejects_invalid_atp_gate FOR TESTING.
    METHODS rejects_atp_without_date FOR TESTING.
    METHODS rejects_order_atp_overflow FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_multi_atp_overflow FOR TESTING
      RAISING cx_static_check.
    METHODS previews_confirmed_open_qty FOR TESTING.
    METHODS reserves_confirmed_open_qty FOR TESTING.
    METHODS rejects_confirmed_no_schedule FOR TESTING.
    METHODS returns_sales_unit_order_alloc FOR TESTING.
    METHODS rejects_sales_uom_limits FOR TESTING.
    METHODS prioritizes_demand_by_date FOR TESTING.
    METHODS subtracts_order_reservations FOR TESTING.
    METHODS skips_fully_reserved_order FOR TESTING.
    METHODS protects_order_safety_stock FOR TESTING.
    METHODS rejects_failed_order_read FOR TESTING.
    METHODS rejects_incomplete_open_item FOR TESTING.
    METHODS rejects_missing_sales_ratio FOR TESTING.
    METHODS rejects_bad_schedule_date FOR TESTING.
    METHODS reserves_allocated_quantities FOR TESTING.
    METHODS reserves_due_items_first FOR TESTING.
    METHODS rejects_short_full_reservation FOR TESTING.
    METHODS reserves_strict_full_order FOR TESTING.
    METHODS splits_reservation_by_location FOR TESTING.
    METHODS reserves_schedule_dates FOR TESTING.
    METHODS rejects_missing_schedule_date FOR TESTING.
    METHODS reserves_selected_batch FOR TESTING.
    METHODS rejects_expired_selected_batch FOR TESTING.
    METHODS allows_batch_expiring_on_date FOR TESTING.
    METHODS applies_batch_minimum FOR TESTING.
    METHODS rejects_bad_batch_minimum FOR TESTING.
    METHODS rejects_bad_selection_flags FOR TESTING.
    METHODS reserves_preferred_batch_loc FOR TESTING.
    METHODS previews_order_fefo_batches FOR TESTING.
    METHODS previews_order_min_shelf_life FOR TESTING.
    METHODS applies_fefo_demand_minimums FOR TESTING.
    METHODS uses_required_date_for_fefo FOR TESTING.
    METHODS rejects_bad_fefo_date_flag FOR TESTING.
    METHODS rejects_min_days_without_fefo FOR TESTING.
    METHODS rejects_bad_fefo_minimums FOR TESTING.
    METHODS rejects_unknown_fefo_min_key FOR TESTING.
    METHODS reserves_order_fefo_batches FOR TESTING.
    METHODS reserves_order_min_shelf_life FOR TESTING.
    METHODS previews_fefo_batch_filter FOR TESTING.
    METHODS reserves_order_priorities FOR TESTING.
    METHODS rejects_short_order_atp FOR TESTING.
    METHODS rejects_future_order_atp FOR TESTING.
    METHODS rejects_order_priorities FOR TESTING.
    METHODS rejects_priority_without_date FOR TESTING.
    METHODS prepare_mbd_schedule_fixture.
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
    mo_sales_stock_repository = NEW lcl_sales_stock_repo_double( ).
    mo_sales_stock_repository->material_units = VALUE #(
      ( material = 'MAT-1' base_unit = 'EA' ) ).
    mo_sales_stock_repository->order_items = VALUE #(
      ( sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000' ) ).
    mo_sales_stock_repository->stock_rows = VALUE #(
      ( sales_document   = '0000001000'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        batch            = 'B-OLD'
        expiration_date  = '20261030'
        base_unit        = 'EA'
        quantity         = '1.000' )
      ( sales_document   = '0000001000'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0002'
        batch            = 'B-NEW'
        expiration_date  = '20261231'
        base_unit        = 'EA'
        quantity         = '2.000' ) ).
    DATA(lo_sales_stock_service) = NEW zcl_so_stock_service(
      io_repository = mo_sales_stock_repository ).
    mo_cut = NEW zcl_sales_order_alloc_service(
      io_sales_order_api           = mo_order_api
      io_stock_repository          = mo_stock_repository
      io_reservation_api           = mo_reservation_api
      io_sales_stock_service       = lo_sales_stock_service
      io_material_availability_api = mo_availability_api ).
  ENDMETHOD.

  METHOD get_so_fefo_reserve_preview.
    rs_result = VALUE #(
      allocations       = VALUE #(
        ( request_id               = 'SO-RES-FEFO-1'
          sales_document           = '0000001000'
          item_number              = '000010'
          reservation_through_date = '20261031'
          material                 = 'MAT-1'
          plant                    = '1000'
          requested_quantity       = '3.000'
          requested_unit           = 'EA'
          requested_base_quantity  = '3.000'
          available_quantity       = '3.000'
          available_base_quantity  = '3.000'
          covered_quantity         = '3.000'
          covered_base_quantity    = '3.000'
          shortfall_quantity       = '0.000'
          shortfall_base_quantity  = '0.000'
          base_unit                = 'EA'
          as_of_date               = '20261014'
          minimum_shelf_life_days  = 0
          include_undated_batches  = abap_true
          is_sufficient            = abap_true
          stock_snapshot           = VALUE #(
            request_id               = 'SO-RES-FEFO-1'
            sales_document           = '0000001000'
            item_number              = '000010'
            reservation_through_date = '20261031'
            material                 = 'MAT-1'
            plant                    = '1000'
            base_unit                = 'EA'
            available_quantity       = '3.000' ) ) )
      batch_allocations = VALUE #(
        ( request_id              = 'SO-RES-FEFO-1'
          sales_document          = '0000001000'
          item_number             = '000010'
          material                = 'MAT-1'
          plant                   = '1000'
          storage_location        = '0001'
          batch                   = 'B-OLD'
          expiration_date         = '20261030'
          as_of_date              = '20261014'
          minimum_shelf_life_days = 0
          include_undated_batches = abap_true
          base_unit               = 'EA'
          allocated_base_quantity = '1.000'
          requested_unit          = 'EA'
          allocated_quantity      = '1.000' )
        ( request_id              = 'SO-RES-FEFO-1'
          sales_document          = '0000001000'
          item_number             = '000010'
          material                = 'MAT-1'
          plant                   = '1000'
          storage_location        = '0002'
          batch                   = 'B-NEW'
          expiration_date         = '20261231'
          as_of_date              = '20261014'
          minimum_shelf_life_days = 0
          include_undated_batches = abap_true
          base_unit               = 'EA'
          allocated_base_quantity = '2.000'
          requested_unit          = 'EA'
          allocated_quantity      = '2.000' ) ) ).
  ENDMETHOD.

  METHOD get_multi_cutoff_res_preview.
    rs_result = get_so_fefo_reserve_preview( ).
    DATA(ls_summary) = rs_result-allocations[ 1 ].
    ls_summary-request_id = 'SO-RES-FEFO-2'.
    ls_summary-reservation_through_date = '20261020'.
    ls_summary-stock_snapshot-request_id = 'SO-RES-FEFO-2'.
    ls_summary-stock_snapshot-reservation_through_date = '20261020'.
    APPEND ls_summary TO rs_result-allocations.

    DATA(lt_original_splits) = rs_result-batch_allocations.
    LOOP AT lt_original_splits INTO DATA(ls_split).
      ls_split-request_id = 'SO-RES-FEFO-2'.
      APPEND ls_split TO rs_result-batch_allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_two_item_fefo_preview.
    rs_result = get_so_fefo_reserve_preview( ).
    DATA(ls_summary) = rs_result-allocations[ 1 ].
    ls_summary-request_id = 'SO-RES-FEFO-2'.
    ls_summary-item_number = '000020'.
    ls_summary-stock_snapshot-request_id = 'SO-RES-FEFO-2'.
    ls_summary-stock_snapshot-item_number = '000020'.
    APPEND ls_summary TO rs_result-allocations.

    DATA(lt_original_splits) = rs_result-batch_allocations.
    LOOP AT lt_original_splits INTO DATA(ls_split).
      ls_split-request_id = 'SO-RES-FEFO-2'.
      ls_split-item_number = '000020'.
      APPEND ls_split TO rs_result-batch_allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD reserves_so_stock_fefo.
    DATA(ls_result) = mo_cut->reserve_so_stock_fefo(
      is_allocation    = get_so_fefo_reserve_preview( )
      iv_required_date = '20261020' ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001000'
      act = lt_requests[ 1 ]-sales_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = '000010'
      act = lt_requests[ 1 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-OLD'
      act = lt_requests[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261020'
      act = lt_requests[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reservation_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD reserves_so_fefo_fallback.
    DATA(ls_preview) = get_so_fefo_reserve_preview( ).
    ls_preview-allocations[ 1 ]-selected_storage_location = '0002'.
    ls_preview-allocations[ 1 ]-allow_location_fallback = abap_true.
    LOOP AT ls_preview-batch_allocations
        ASSIGNING FIELD-SYMBOL(<ls_split>).
      <ls_split>-selected_storage_location = '0002'.
      <ls_split>-allow_location_fallback = abap_true.
    ENDLOOP.

    DATA(ls_result) = mo_cut->reserve_so_stock_fefo(
      is_allocation    = ls_preview
      iv_required_date = '20261020' ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_requests[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_requests[ 2 ]-storage_location ).
  ENDMETHOD.

  METHOD rejects_so_fefo_location.
    DATA(ls_preview) = get_so_fefo_reserve_preview( ).
    ls_preview-allocations[ 1 ]-selected_storage_location = '0002'.
    LOOP AT ls_preview-batch_allocations
        ASSIGNING FIELD-SYMBOL(<ls_split>).
      <ls_split>-selected_storage_location = '0002'.
    ENDLOOP.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->reserve_so_stock_fefo( is_allocation = ls_preview ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_so_fefo_request_scope.
    DATA(ls_preview) = get_so_fefo_reserve_preview( ).
    ls_preview-location_allowlist = VALUE #( ( '0001' ) ( '0002' ) ).
    ls_preview-request_locations = VALUE #(
      ( request_id = 'SO-RES-FEFO-1' storage_location = '0001' ) ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->reserve_so_stock_fefo( is_allocation = ls_preview ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD reserves_selected_so_fefo.
    DATA(ls_preview) = get_multi_cutoff_res_preview( ).
    ls_preview-location_allowlist = VALUE #( ( '0001' ) ( '0002' ) ).
    ls_preview-request_locations = VALUE #(
      ( request_id = 'SO-RES-FEFO-1' storage_location = '0001' )
      ( request_id = 'SO-RES-FEFO-2' storage_location = '0001' )
      ( request_id = 'SO-RES-FEFO-2' storage_location = '0002' ) ).
    DATA(ls_result) = mo_cut->reserve_so_stock_fefo_selected(
      is_allocation    = ls_preview
      it_request_ids   = VALUE #( ( 'SO-RES-FEFO-2' ) )
      iv_required_date = '20261020' ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-preview-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SO-RES-FEFO-2'
      act = ls_result-preview-allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-preview-location_allowlist ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-preview-request_locations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SO-RES-FEFO-2'
      act = ls_result-preview-request_locations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SO-RES-FEFO-2'
      act = ls_result-preview-request_locations[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SO-RES-FEFO-2'
      act = lt_requests[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reservation_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_so_fefo_selection.
    DATA(ls_preview) = get_multi_cutoff_res_preview( ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->reserve_so_stock_fefo_selected(
          is_allocation  = ls_preview
          it_request_ids = VALUE #( ( 'UNKNOWN' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        mo_cut->reserve_so_stock_fefo_selected(
          is_allocation  = ls_preview
          it_request_ids = VALUE #(
            ( 'SO-RES-FEFO-1' )
            ( 'SO-RES-FEFO-1' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD reserves_rechecked_so_fefo.
    DATA(ls_preview) = get_so_fefo_reserve_preview( ).
    DATA(ls_rechecked) = ls_preview.
    DATA(ls_result) = mo_cut->reserve_so_fefo_rechecked(
      is_allocation           = ls_preview
      is_rechecked_allocation = ls_rechecked ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-reservations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reservation_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD reserves_selected_fefo_recheck.
    DATA(ls_preview) = get_multi_cutoff_res_preview( ).
    DATA(ls_rechecked) = ls_preview.
    DATA(ls_result) = mo_cut->reserve_so_fefo_rechecked(
      is_allocation           = ls_preview
      is_rechecked_allocation = ls_rechecked
      it_request_ids          = VALUE #( ( 'SO-RES-FEFO-2' ) ) ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-preview-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SO-RES-FEFO-2'
      act = ls_result-preview-allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SO-RES-FEFO-2'
      act = lt_requests[ 1 ]-request_id ).
  ENDMETHOD.

  METHOD rejects_changed_fefo_resv.
    DATA(ls_preview) = get_so_fefo_reserve_preview( ).
    DATA(ls_rechecked) = ls_preview.
    ls_rechecked-allocations[ 1 ]-stock_snapshot-available_quantity =
      '4.000'.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->reserve_so_fefo_rechecked(
          is_allocation           = ls_preview
          is_rechecked_allocation = ls_rechecked ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_changed_fefo_scope.
    DATA(ls_preview) = get_so_fefo_reserve_preview( ).
    ls_preview-request_locations = VALUE #(
      ( request_id = 'SO-RES-FEFO-1' storage_location = '0001' )
      ( request_id = 'SO-RES-FEFO-1' storage_location = '0002' ) ).
    DATA(ls_rechecked) = ls_preview.
    DELETE ls_rechecked-request_locations INDEX 2.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->reserve_so_fefo_rechecked(
          is_allocation           = ls_preview
          is_rechecked_allocation = ls_rechecked ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD reserves_fefo_demands_direct.
    mo_sales_stock_repository->stock_rows[ 1 ]-batch = 'B-SAME'.
    mo_sales_stock_repository->stock_rows[ 1 ]-expiration_date =
      '20261231'.
    mo_sales_stock_repository->stock_rows[ 2 ]-batch = 'B-SAME'.
    mo_sales_stock_repository->stock_rows[ 2 ]-expiration_date =
      '20261231'.
    APPEND VALUE #(
      sales_document   = '0000001000'
      item_number      = '000010'
      material         = 'MAT-1'
      plant            = '1000'
      storage_location = '0003'
      batch            = 'B-UNKNOWN'
      base_unit        = 'EA'
      quantity         = '2.000' )
      TO mo_sales_stock_repository->stock_rows.
    DATA(ls_result) = mo_cut->reserve_so_fefo_demands(
      it_requests                    = VALUE #(
        ( request_id            = 'SO-DIRECT-1'
          sales_document        = '0000001000'
          item_number           = '000010'
          requested_quantity    = '4.000'
          allow_undated_batches = abap_true ) )
      iv_as_of_date                  = '20261014'
      iv_include_undated_batches     = abap_false
      iv_required_date               = '20261020'
      it_storage_location_priority   = VALUE #( ( '0001' ) ( '0002' ) )
      it_request_location_priorities = VALUE #(
        ( request_id = 'SO-DIRECT-1' storage_location = '0002'
          priority_rank = 1 ) ) ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-preview-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-preview-batch_allocations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-SAME'
      act = ls_result-preview-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-UNKNOWN'
      act = ls_result-preview-batch_allocations[ 3 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-preview-allocations[ 1 ]-allow_undated_batches ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-preview-allocations[ 1 ]-include_undated_batches ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261020'
      act = lt_requests[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reservation_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD reserves_fefo_allowed_locs.
    APPEND VALUE #(
      sales_document   = '0000001000'
      item_number      = '000010'
      material         = 'MAT-1'
      plant            = '1000'
      storage_location = '0003'
      batch            = 'B-EARLY'
      expiration_date  = '20261020'
      base_unit        = 'EA'
      quantity         = '5.000' ) TO mo_sales_stock_repository->stock_rows.

    DATA(ls_result) = mo_cut->reserve_so_fefo_demands(
      it_requests          = VALUE #(
        ( request_id         = 'SO-ALLOWLIST'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '3.000' ) )
      iv_as_of_date        = '20261014'
      it_request_locations = VALUE #(
        ( request_id = 'SO-ALLOWLIST' storage_location = '0001' )
        ( request_id = 'SO-ALLOWLIST' storage_location = '0002' ) ) ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '3.000' )
      act = ls_result-preview-allocations[ 1 ]-available_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-preview-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-preview-request_locations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_requests ) ).
    LOOP AT ls_result-preview-batch_allocations
        INTO DATA(ls_split).
      cl_abap_unit_assert=>assert_true(
        act = xsdbool( ls_split-storage_location <> '0003' ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD reserves_selected_direct_fefo.
    DATA(ls_result) = mo_cut->reserve_so_fefo_demands(
      it_requests    = VALUE #(
        ( request_id               = 'SO-DIRECT-1'
          sales_document           = '0000001000'
          item_number              = '000010'
          requested_quantity       = '3.000'
          reservation_through_date = '20261031' )
        ( request_id               = 'SO-DIRECT-2'
          sales_document           = '0000001000'
          item_number              = '000010'
          requested_quantity       = '3.000'
          reservation_through_date = '20261020' ) )
      it_request_ids = VALUE #( ( 'SO-DIRECT-2' ) )
      iv_as_of_date  = '20261014' ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-preview-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SO-DIRECT-2'
      act = ls_result-preview-allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SO-DIRECT-2'
      act = lt_requests[ 1 ]-request_id ).
  ENDMETHOD.

  METHOD reserves_fefo_demands_uom.
    mo_sales_stock_repository->stock_rows[ 1 ]-batch = 'B-SAME'.
    mo_sales_stock_repository->stock_rows[ 1 ]-expiration_date =
      '20261231'.
    mo_sales_stock_repository->stock_rows[ 2 ]-batch = 'B-SAME'.
    mo_sales_stock_repository->stock_rows[ 2 ]-expiration_date =
      '20261231'.
    DATA(lo_uom_stock_service) = NEW zcl_so_stock_service(
      io_repository     = mo_sales_stock_repository
      io_uom_repository = NEW lcl_sales_uom_repo_double( ) ).
    DATA(lo_uom_cut) = NEW zcl_sales_order_alloc_service(
      io_sales_order_api           = mo_order_api
      io_stock_repository          = mo_stock_repository
      io_reservation_api           = mo_reservation_api
      io_sales_stock_service       = lo_uom_stock_service
      io_material_availability_api = mo_availability_api ).
    DATA(ls_result) = lo_uom_cut->reserve_so_fefo_demands_uom(
      it_requests                    = VALUE #(
        ( request_id         = 'SO-DIRECT-UOM'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '1.500'
          requested_unit     = 'BOX' ) )
      iv_as_of_date                  = '20261014'
      it_storage_location_priority   = VALUE #( ( '0001' ) ( '0002' ) )
      it_request_location_priorities = VALUE #(
        ( request_id = 'SO-DIRECT-UOM' storage_location = '0002'
          priority_rank = 1 ) ) ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = ls_result-preview-allocations[ 1 ]-requested_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_requests[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2.000'
      act = lt_requests[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1.000'
      act = lt_requests[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_requests[ 1 ]-storage_location ).
  ENDMETHOD.

  METHOD rejects_short_fefo_demands.
    DATA(ls_result) = mo_cut->reserve_so_fefo_demands(
      it_requests   = VALUE #(
        ( request_id         = 'SO-DIRECT-1'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '4.000' ) )
      iv_as_of_date = '20261014' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD reserves_demand_fefo_recheck.
    mo_sales_stock_repository->stock_rows[ 1 ]-batch = 'B-SAME'.
    mo_sales_stock_repository->stock_rows[ 1 ]-expiration_date =
      '20261231'.
    mo_sales_stock_repository->stock_rows[ 2 ]-batch = 'B-SAME'.
    mo_sales_stock_repository->stock_rows[ 2 ]-expiration_date =
      '20261231'.
    DATA(lt_demands) = VALUE zcl_so_stock_service=>ty_fefo_issue_requests(
      ( request_id         = 'SO-RECHECK-1'
        sales_document     = '0000001000'
        item_number        = '000010'
        requested_quantity = '3.000' ) ).
    DATA(lt_location_priorities) = VALUE
      zcl_so_stock_service=>ty_fefo_request_location_priorities(
        ( request_id = 'SO-RECHECK-1' storage_location = '0002'
          priority_rank = 1 ) ).
    DATA(lo_preview_service) = NEW zcl_so_stock_service(
      io_repository = mo_sales_stock_repository ).
    DATA(ls_preview) = lo_preview_service->preview_issue_demands_by_fefo(
      it_requests                    = lt_demands
      iv_as_of_date                  = '20261014'
      it_storage_location_priority   = VALUE #( ( '0001' ) ( '0002' ) )
      it_request_location_priorities = lt_location_priorities ).
    DATA(ls_result) = mo_cut->reserve_so_fefo_recheck(
      is_allocation                  = ls_preview
      it_requests                    = lt_demands
      iv_as_of_date                  = '20261014'
      iv_required_date               = '20261020'
      it_storage_location_priority   = VALUE #( ( '0001' ) ( '0002' ) )
      it_request_location_priorities = lt_location_priorities ).
    DATA(lt_reservation_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-reservations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_reservation_requests[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_reservation_requests[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reservation_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD reserves_selected_demand_rechk.
    DATA(lt_demands) = VALUE zcl_so_stock_service=>ty_fefo_issue_requests(
      ( request_id               = 'SO-RECHECK-1'
        sales_document           = '0000001000'
        item_number              = '000010'
        requested_quantity       = '3.000'
        reservation_through_date = '20261031' )
      ( request_id               = 'SO-RECHECK-2'
        sales_document           = '0000001000'
        item_number              = '000010'
        requested_quantity       = '3.000'
        reservation_through_date = '20261020' ) ).
    DATA(lo_preview_service) = NEW zcl_so_stock_service(
      io_repository = mo_sales_stock_repository ).
    DATA(ls_preview) = lo_preview_service->preview_issue_demands_by_fefo(
      it_requests   = lt_demands
      iv_as_of_date = '20261014' ).
    DATA(ls_result) = mo_cut->reserve_so_fefo_recheck(
      is_allocation  = ls_preview
      it_requests    = lt_demands
      it_request_ids = VALUE #( ( 'SO-RECHECK-2' ) )
      iv_as_of_date  = '20261014' ).
    DATA(lt_reservation_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-preview-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SO-RECHECK-2'
      act = ls_result-preview-allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SO-RECHECK-2'
      act = lt_reservation_requests[ 1 ]-request_id ).
  ENDMETHOD.

  METHOD rejects_changed_demand_rechk.
    DATA(lt_demands) = VALUE zcl_so_stock_service=>ty_fefo_issue_requests(
      ( request_id         = 'SO-RECHECK-1'
        sales_document     = '0000001000'
        item_number        = '000010'
        requested_quantity = '3.000' ) ).
    DATA(lo_preview_service) = NEW zcl_so_stock_service(
      io_repository = mo_sales_stock_repository ).
    DATA(ls_preview) = lo_preview_service->preview_issue_demands_by_fefo(
      it_requests   = lt_demands
      iv_as_of_date = '20261014' ).
    mo_sales_stock_repository->stock_rows[ 2 ]-quantity = '1.000'.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->reserve_so_fefo_recheck(
          is_allocation = ls_preview
          it_requests   = lt_demands
          iv_as_of_date = '20261014' ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD reserves_uom_fefo_recheck.
    mo_sales_stock_repository->stock_rows[ 1 ]-batch = 'B-SAME'.
    mo_sales_stock_repository->stock_rows[ 1 ]-expiration_date =
      '20261231'.
    mo_sales_stock_repository->stock_rows[ 2 ]-batch = 'B-SAME'.
    mo_sales_stock_repository->stock_rows[ 2 ]-expiration_date =
      '20261231'.
    DATA(lt_demands) = VALUE
      zcl_so_stock_service=>ty_fefo_issue_unit_requests(
        ( request_id         = 'SO-RECHECK-UOM'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '1.500'
          requested_unit     = 'BOX' ) ).
    DATA(lt_location_priorities) = VALUE
      zcl_so_stock_service=>ty_fefo_request_location_priorities(
        ( request_id = 'SO-RECHECK-UOM' storage_location = '0002'
          priority_rank = 1 ) ).
    DATA(lo_uom_service) = NEW zcl_so_stock_service(
      io_repository     = mo_sales_stock_repository
      io_uom_repository = NEW lcl_sales_uom_repo_double( ) ).
    DATA(ls_preview) = lo_uom_service->preview_issue_fefo_uom(
      it_requests                    = lt_demands
      iv_as_of_date                  = '20261014'
      it_storage_location_priority   = VALUE #( ( '0001' ) ( '0002' ) )
      it_request_location_priorities = lt_location_priorities ).
    DATA(lo_uom_cut) = NEW zcl_sales_order_alloc_service(
      io_sales_order_api           = mo_order_api
      io_stock_repository          = mo_stock_repository
      io_reservation_api           = mo_reservation_api
      io_sales_stock_service       = lo_uom_service
      io_material_availability_api = mo_availability_api ).
    DATA(ls_result) = lo_uom_cut->reserve_so_fefo_uom_recheck(
      is_allocation                  = ls_preview
      it_requests                    = lt_demands
      iv_as_of_date                  = '20261014'
      it_storage_location_priority   = VALUE #( ( '0001' ) ( '0002' ) )
      it_request_location_priorities = lt_location_priorities ).
    DATA(lt_reservation_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_reservation_requests[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1.000'
      act = lt_reservation_requests[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_reservation_requests[ 1 ]-storage_location ).
  ENDMETHOD.

  METHOD releases_fefo_reservations.
    DATA(ls_reservation_result) = mo_cut->reserve_so_stock_fefo(
      is_allocation = get_so_fefo_reserve_preview( ) ).
    DATA(ls_result) = mo_cut->release_so_fefo_reservations(
      is_reservation_result = ls_reservation_result ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-reservation_numbers ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reservation_api->get_delete_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_reservation_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD releases_one_fefo_split.
    DATA(ls_reservation_result) = mo_cut->reserve_so_stock_fefo(
      is_allocation = get_so_fefo_reserve_preview( ) ).
    DATA(lv_reservation_number) =
      ls_reservation_result-reservations[ 1 ]-reservation_number.
    DATA(ls_result) = mo_cut->release_so_fefo_reservations(
      is_reservation_result  = ls_reservation_result
      it_reservation_numbers = VALUE #(
        ( lv_reservation_number ) ) ).
    DATA(lt_deleted_numbers) = mo_reservation_api->get_deleted_numbers( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-reservation_numbers ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_reservation_number
      act = ls_result-reservation_numbers[ 1 ] ).
    cl_abap_unit_assert=>assert_equals(
      exp = VALUE zif_so_reservation_api=>ty_reservation_numbers(
        ( lv_reservation_number ) )
      act = lt_deleted_numbers ).

    DATA lv_rejected TYPE abap_bool.
    TRY.
        mo_cut->release_so_fefo_reservations(
          is_reservation_result  = ls_reservation_result
          it_reservation_numbers = VALUE #(
            ( lv_reservation_number )
            ( lv_reservation_number ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    CLEAR lv_rejected.
    TRY.
        mo_cut->release_so_fefo_reservations(
          is_reservation_result  = ls_reservation_result
          it_request_ids         = VALUE #(
            ( 'SO-RES-FEFO-1' ) )
          it_reservation_numbers = VALUE #(
            ( lv_reservation_number ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    CLEAR lv_rejected.
    TRY.
        mo_cut->release_so_fefo_reservations(
          is_reservation_result  = ls_reservation_result
          it_reservation_numbers = VALUE #(
            ( '9999999999' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reservation_api->get_delete_count( ) ).
  ENDMETHOD.

  METHOD releases_selected_fefo_res.
    DATA(ls_reservation_result) = mo_cut->reserve_so_stock_fefo(
      is_allocation = get_two_item_fefo_preview( ) ).
    DATA(ls_result) = mo_cut->release_so_fefo_reservations(
      is_reservation_result = ls_reservation_result
      it_request_ids        = VALUE #(
        ( 'SO-RES-FEFO-2' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-reservation_numbers ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = ls_reservation_result-reservations[ 3 ]-reservation_number
      act = ls_result-reservation_numbers[ 1 ] ).
    cl_abap_unit_assert=>assert_equals(
      exp = ls_reservation_result-reservations[ 4 ]-reservation_number
      act = ls_result-reservation_numbers[ 2 ] ).

    DATA lv_rejected TYPE abap_bool.
    TRY.
        mo_cut->release_so_fefo_reservations(
          is_reservation_result = ls_reservation_result
          it_request_ids        = VALUE #(
            ( 'SO-RES-FEFO-2' )
            ( 'SO-RES-FEFO-2' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    CLEAR lv_rejected.
    TRY.
        mo_cut->release_so_fefo_reservations(
          is_reservation_result = ls_reservation_result
          it_request_ids        = VALUE #(
            ( 'UNKNOWN-FEFO-ID' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reservation_api->get_delete_count( ) ).
  ENDMETHOD.

  METHOD simulates_fefo_release.
    DATA(ls_reservation_result) = mo_cut->reserve_so_stock_fefo(
      is_allocation = get_so_fefo_reserve_preview( ) ).
    DATA(ls_result) = mo_cut->release_so_fefo_reservations(
      is_reservation_result = ls_reservation_result
      iv_test_run           = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = mo_reservation_api->was_delete_test_run( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reservation_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_uncommitted_fefo_del.
    DATA(ls_reservation_result) = mo_cut->reserve_so_stock_fefo(
      is_allocation = get_so_fefo_reserve_preview( )
      iv_test_run   = abap_true ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->release_so_fefo_reservations(
          is_reservation_result = ls_reservation_result ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_delete_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_fefo_release_rows.
    DATA(ls_reservation_result) = mo_cut->reserve_so_stock_fefo(
      is_allocation = get_so_fefo_reserve_preview( ) ).
    DATA(ls_tampered_result) = ls_reservation_result.
    ls_tampered_result-reservations[ 2 ]-reservation_number =
      ls_tampered_result-reservations[ 1 ]-reservation_number.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->release_so_fefo_reservations(
          is_reservation_result = ls_tampered_result ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    ls_tampered_result = ls_reservation_result.
    ls_tampered_result-reservations[ 2 ]-quantity = '1.000'.
    CLEAR lv_rejected.
    TRY.
        mo_cut->release_so_fefo_reservations(
          is_reservation_result = ls_tampered_result ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    ls_tampered_result = ls_reservation_result.
    ls_tampered_result-preview-batch_allocations[ 2 ]-storage_location =
      ls_tampered_result-preview-batch_allocations[ 1 ]-storage_location.
    ls_tampered_result-preview-batch_allocations[ 2 ]-batch =
      ls_tampered_result-preview-batch_allocations[ 1 ]-batch.
    ls_tampered_result-preview-batch_allocations[ 2 ]-allocated_base_quantity =
      ls_tampered_result-preview-batch_allocations[ 1 ]-allocated_base_quantity.
    ls_tampered_result-reservations[ 2 ]-storage_location =
      ls_tampered_result-reservations[ 1 ]-storage_location.
    ls_tampered_result-reservations[ 2 ]-batch =
      ls_tampered_result-reservations[ 1 ]-batch.
    ls_tampered_result-reservations[ 2 ]-quantity =
      ls_tampered_result-reservations[ 1 ]-quantity.
    CLEAR lv_rejected.
    TRY.
        mo_cut->release_so_fefo_reservations(
          is_reservation_result = ls_tampered_result ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_delete_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_fefo_delete_error.
    DATA(ls_reservation_result) = mo_cut->reserve_so_stock_fefo(
      is_allocation = get_so_fefo_reserve_preview( ) ).
    mo_reservation_api->set_delete_result(
      is_result = VALUE #(
        is_successful = abap_false
        messages      = VALUE #(
          ( type = 'E' message = 'Reservation release failed' ) ) ) ).

    DATA(ls_result) = mo_cut->release_so_fefo_reservations(
      is_reservation_result = ls_reservation_result ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reservation_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reservation_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_fefo_release_commit.
    DATA(ls_reservation_result) = mo_cut->reserve_so_stock_fefo(
      is_allocation = get_so_fefo_reserve_preview( ) ).
    mo_reservation_api->set_commit_failure_call(
      iv_call   = 2
      is_result = VALUE #(
        is_successful = abap_false
        message       = VALUE #(
          type    = 'E'
          message = 'Release commit failed' ) ) ).

    DATA(ls_result) = mo_cut->release_so_fefo_reservations(
      is_reservation_result = ls_reservation_result ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reservation_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD simulates_so_stock_fefo.
    DATA(ls_result) = mo_cut->reserve_so_stock_fefo(
      is_allocation = get_so_fefo_reserve_preview( )
      iv_test_run   = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_short_so_stock_fefo.
    DATA(ls_preview) = get_so_fefo_reserve_preview( ).
    READ TABLE ls_preview-allocations ASSIGNING FIELD-SYMBOL(<ls_summary>)
      INDEX 1.
    <ls_summary>-requested_quantity = '4.000'.
    <ls_summary>-requested_base_quantity = '4.000'.
    <ls_summary>-shortfall_quantity = '1.000'.
    <ls_summary>-shortfall_base_quantity = '1.000'.
    <ls_summary>-is_sufficient = abap_false.

    DATA(ls_result) = mo_cut->reserve_so_stock_fefo(
      is_allocation = ls_preview ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-messages ) ).
  ENDMETHOD.

  METHOD rejects_fefo_sum_overflow.
    DATA(ls_preview) = get_so_fefo_reserve_preview( ).
    DATA lv_rejected TYPE abap_bool.
    READ TABLE ls_preview-allocations ASSIGNING FIELD-SYMBOL(<ls_summary>)
      INDEX 1.
    <ls_summary>-requested_base_quantity = '9999999999.999'.
    <ls_summary>-available_base_quantity = '9999999999.999'.
    <ls_summary>-covered_base_quantity = '9999999999.999'.
    <ls_summary>-shortfall_base_quantity = '9999999999.999'.
    <ls_summary>-stock_snapshot-available_quantity = '9999999999.999'.
    <ls_summary>-is_sufficient = abap_false.

    TRY.
        mo_cut->reserve_so_stock_fefo(
          is_allocation = ls_preview ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_expired_fefo_resv.
    DATA(ls_preview) = get_so_fefo_reserve_preview( ).
    ls_preview-batch_allocations[ 1 ]-expiration_date = '20261013'.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->reserve_so_stock_fefo(
          is_allocation = ls_preview ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_so_fefo_reservation.
    mo_reservation_api->set_create_failure_call(
      iv_call    = 1
      is_message = VALUE #(
        type    = 'E'
        message = 'Reservation create failed' ) ).
    DATA(ls_result) = mo_cut->reserve_so_stock_fefo(
      is_allocation = get_so_fefo_reserve_preview( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reservation_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-reservations ).
  ENDMETHOD.

  METHOD rolls_back_so_fefo_commit.
    mo_reservation_api->set_commit_failure_call(
      iv_call   = 1
      is_result = VALUE #(
        is_successful = abap_false
        message       = VALUE #(
          type    = 'E'
          message = 'Reservation commit failed' ) ) ).
    DATA(ls_result) = mo_cut->reserve_so_stock_fefo(
      is_allocation = get_so_fefo_reserve_preview( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reservation_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-reservations ).
  ENDMETHOD.

  METHOD previews_multi_orders_date.
    mo_stock_repository->set_stock( iv_quantity = '20.000' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number            = '000010'
              schedule_line          = '0001'
              material               = 'MAT-1'
              plant                  = '1000'
              entry_unit             = 'BOX'
              sales_unit_numerator   = 12
              sales_unit_denominator = 1
              base_unit              = 'EA'
              requested_date         = '20261005'
              open_base_quantity     = '12.000' )
            ( item_number        = '000020'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261015'
              open_base_quantity = '12.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->preview_orders_by_date(
      it_sales_documents = VALUE #(
        ( '0000004711' )
        ( '0000004712' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( ls_result-sales_unit_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711'
      act = ls_result-sales_unit_allocations[ 1 ]-sales_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-sales_unit_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-sales_unit_allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004712'
      act = ls_result-sales_unit_allocations[ 3 ]-sales_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_result-sales_unit_allocations[ 3 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.667' )
      act = ls_result-sales_unit_allocations[ 3 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.333' )
      act = ls_result-sales_unit_allocations[ 3 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '000020'
      act = ls_result-sales_unit_allocations[ 4 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-material_summaries ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-material_summaries[ 1 ]-sales_document_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = ls_result-material_summaries[ 1 ]-dated_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '48.000' )
      act = ls_result-material_summaries[ 1 ]-requested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '20.000' )
      act = ls_result-material_summaries[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '28.000' )
      act = ls_result-material_summaries[ 1 ]-shortfall_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261005'
      act = ls_result-material_summaries[ 1 ]-first_required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261015'
      act = ls_result-material_summaries[ 1 ]-last_required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-material_summaries[ 1 ]-first_allocation_sequence ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = ls_result-material_summaries[ 1 ]-last_allocation_sequence ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_sales_order_alloc_service=>c_sequence_scope_multi_order
      act = ls_result-material_summaries[ 1 ]-allocation_sequence_scope ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-order_summaries[ 1 ]-dated_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261005'
      act = ls_result-order_summaries[ 1 ]-first_required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261015'
      act = ls_result-order_summaries[ 1 ]-last_required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-order_summaries[ 1 ]-first_allocation_sequence ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = ls_result-order_summaries[ 1 ]-last_allocation_sequence ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_sales_order_alloc_service=>c_sequence_scope_multi_order
      act = ls_result-order_summaries[ 1 ]-allocation_sequence_scope ).
    cl_abap_unit_assert=>assert_equals(
      exp = zif_stock_repository=>c_allocation_outcome_partial
      act = ls_result-material_summaries[ 1 ]-allocation_outcome ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '41.67' )
      act = ls_result-material_summaries[ 1 ]-allocation_coverage_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-material_summaries[ 1 ]-fully_allocated_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-material_summaries[ 1 ]-partially_allocated_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-material_summaries[ 1 ]-unallocated_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '25.00' )
      act = ls_result-material_summaries[ 1 ]-fully_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '25.00' )
      act = ls_result-material_summaries[ 1 ]-partially_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '50.00' )
      act = ls_result-material_summaries[ 1 ]-unallocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = mo_stock_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD prepare_mbd_schedule_fixture.
    mo_stock_repository->set_stock( iv_quantity = '3.000' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number                = '000010'
              schedule_line              = '0001'
              material                   = 'MAT-1'
              plant                      = '1000'
              entry_unit                 = 'EA'
              base_unit                  = 'EA'
              requested_date             = '20261015'
              material_availability_date = '20261001'
              open_base_quantity         = '3.000' )
            ( item_number                = '000010'
              schedule_line              = '0002'
              material                   = 'MAT-1'
              plant                      = '1000'
              entry_unit                 = 'EA'
              base_unit                  = 'EA'
              requested_date             = '20261005'
              material_availability_date = '20261015'
              open_base_quantity         = '3.000' ) ) ) ) ).
  ENDMETHOD.

  METHOD previews_mbd_dates.
    prepare_mbd_schedule_fixture( ).

    DATA(ls_result) = mo_cut->preview_orders_by_date(
      it_sales_documents         = VALUE #( ( '0000004711' ) )
      iv_use_material_avail_date = abap_true
      iv_check_atp               = abap_true
      iv_atp_check_rule          = 'A' ).
    READ TABLE ls_result-sales_unit_allocations
      INTO DATA(ls_first_allocation)
      WITH KEY schedule_line = '0001'.
    READ TABLE ls_result-sales_unit_allocations
      INTO DATA(ls_second_allocation)
      WITH KEY schedule_line = '0002'.
    READ TABLE ls_result-atp_checks
      INTO DATA(ls_first_atp)
      WITH KEY schedule_line = '0001'.
    READ TABLE ls_result-atp_checks
      INTO DATA(ls_second_atp)
      WITH KEY schedule_line = '0002'.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261001'
      act = ls_first_allocation-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_first_allocation-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261015'
      act = ls_second_allocation-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = ls_second_allocation-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261001'
      act = ls_first_atp-result-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261015'
      act = ls_second_atp-result-required_date ).
  ENDMETHOD.

  METHOD previews_single_mbd.
    prepare_mbd_schedule_fixture( ).

    DATA(ls_result) = mo_cut->preview_order(
      iv_sales_document          = '0000004711'
      iv_prioritize_by_date      = abap_true
      iv_use_material_avail_date = abap_true
      iv_check_atp               = abap_true
      iv_atp_check_rule          = 'A' ).
    READ TABLE ls_result-sales_unit_allocations
      INTO DATA(ls_first_allocation)
      WITH KEY schedule_line = '0001'.
    READ TABLE ls_result-sales_unit_allocations
      INTO DATA(ls_second_allocation)
      WITH KEY schedule_line = '0002'.
    READ TABLE ls_result-atp_checks
      INTO DATA(ls_first_atp)
      WITH KEY schedule_line = '0001'.
    READ TABLE ls_result-atp_checks
      INTO DATA(ls_second_atp)
      WITH KEY schedule_line = '0002'.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261001'
      act = ls_first_allocation-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_first_allocation-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261015'
      act = ls_second_allocation-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = ls_second_allocation-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261001'
      act = ls_first_atp-result-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261015'
      act = ls_second_atp-result-required_date ).
  ENDMETHOD.

  METHOD previews_mbd_without_edatu.
    mo_stock_repository->set_stock( iv_quantity = '3.000' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number                = '000010'
              schedule_line              = '0001'
              material                   = 'MAT-1'
              plant                      = '1000'
              entry_unit                 = 'EA'
              base_unit                  = 'EA'
              material_availability_date = '20261001'
              open_base_quantity         = '3.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->preview_order(
      iv_sales_document          = '0000004711'
      iv_use_material_avail_date = abap_true
      iv_check_atp               = abap_true
      iv_atp_check_rule          = 'A' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261001'
      act = ls_result-sales_unit_allocations[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261001'
      act = ls_result-atp_checks[ 1 ]-result-required_date ).
  ENDMETHOD.

  METHOD reserves_single_mbd.
    prepare_mbd_schedule_fixture( ).

    DATA(ls_result) = mo_cut->reserve_order(
      iv_sales_document          = '0000004711'
      iv_prioritize_by_date      = abap_true
      iv_use_material_avail_date = abap_true ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711/000010/0001'
      act = lt_requests[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261001'
      act = lt_requests[ 1 ]-required_date ).
  ENDMETHOD.

  METHOD rejects_missing_single_mbd.
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261005'
              open_base_quantity = '3.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->preview_order(
      iv_sales_document          = '0000004711'
      iv_use_material_avail_date = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Material availability date mode requires a dated schedule line for every open item'
      act = ls_result-messages[ 1 ]-message ).
  ENDMETHOD.

  METHOD rejects_bad_single_mbd.
    DATA lv_rejected TYPE abap_bool.
    TRY.
        mo_cut->preview_order(
          iv_sales_document          = '0000004711'
          iv_use_material_avail_date = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
  ENDMETHOD.

  METHOD rejects_missing_mbd_date.
    mo_stock_repository->set_stock( iv_quantity = '3.000' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261005'
              open_base_quantity = '3.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->preview_orders_by_date(
      it_sales_documents         = VALUE #( ( '0000004711' ) )
      iv_use_material_avail_date = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_result-sales_unit_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Material availability date mode requires a dated schedule line for every open item'
      act = ls_result-messages[ 1 ]-message ).
  ENDMETHOD.

  METHOD rejects_bad_mbd_flag.
    DATA lv_rejected TYPE abap_bool.
    TRY.
        mo_cut->preview_orders_by_date(
          it_sales_documents         = VALUE #( ( '0000004711' ) )
          iv_use_material_avail_date = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
  ENDMETHOD.

  METHOD prioritizes_multi_order.
    mo_stock_repository->set_stock( iv_quantity = '3.000' ).
    mo_availability_api->set_result(
      is_result = VALUE #(
        available_at_plant_quantity = '3.000'
        confirmed_date              = '20261005'
        confirmed_quantity          = '3.000'
        confirmation_lines          = VALUE #(
          ( confirmed_quantity = '3.000' ) )
        dialog_flag                 = 'X'
        is_fully_available          = abap_true
        is_check_relevant           = abap_true ) ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261005'
              open_base_quantity = '3.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->preview_orders_by_date(
      it_sales_documents   = VALUE #(
        ( '0000004711' )
        ( '0000004712' ) )
      it_demand_priorities = VALUE #(
        ( sales_document = '0000004711'
          item_number    = '000010'
          schedule_line  = '0001'
          priority       = 1 )
        ( sales_document = '0000004712'
          item_number    = '000010'
          schedule_line  = '0001'
          priority       = 5 ) )
      iv_check_atp         = abap_true
      iv_atp_check_rule    = 'A' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_result-sales_unit_allocations[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-sales_unit_allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-sales_unit_allocations[ 2 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = ls_result-sales_unit_allocations[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-atp_checks[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = ls_result-atp_checks[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-atp_checks[ 1 ]-cumulative_requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-atp_checks[ 2 ]-cumulative_requested_quantity ).
  ENDMETHOD.

  METHOD rejects_bad_demand_priority.
    mo_stock_repository->set_stock( iv_quantity = '3.000' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261005'
              open_base_quantity = '3.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->preview_orders_by_date(
      it_sales_documents   = VALUE #( ( '0000004711' ) )
      it_demand_priorities = VALUE #(
        ( sales_document = '0000004712'
          item_number    = '000010'
          schedule_line  = '0001'
          priority       = 5 ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-messages ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD previews_multi_order_pr_supply.
    mo_stock_repository->set_stock( iv_quantity = 0 ).
    mo_stock_repository->set_pr_receipt_quantity( iv_quantity = '12.000' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261005'
              open_base_quantity = '12.000' ) ) ) ) ).

    DATA(ls_local) = mo_cut->preview_orders_by_date(
      it_sales_documents = VALUE #( ( '0000004711' ) ) ).
    DATA(ls_projected) = mo_cut->preview_orders_by_date(
      it_sales_documents     = VALUE #( ( '0000004711' ) )
      iv_include_pr_receipts = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = ls_local-sales_unit_allocations[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_projected-sales_unit_allocations[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = ls_projected-sales_unit_allocations[ 1 ]-shortfall_base_quantity ).
  ENDMETHOD.

  METHOD previews_multi_sto_supply.
    mo_stock_repository->set_stock( iv_quantity = 0 ).
    mo_stock_repository->set_sto_pr_receipt_quantity(
      iv_quantity = '12.000' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261005'
              open_base_quantity = '12.000' ) ) ) ) ).

    DATA(ls_local) = mo_cut->preview_orders_by_date(
      it_sales_documents = VALUE #( ( '0000004711' ) ) ).
    DATA(ls_projected) = mo_cut->preview_orders_by_date(
      it_sales_documents         = VALUE #( ( '0000004711' ) )
      iv_include_sto_pr_receipts = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = ls_local-sales_unit_allocations[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_projected-sales_unit_allocations[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = ls_projected-sales_unit_allocations[ 1 ]-shortfall_base_quantity ).
  ENDMETHOD.

  METHOD previews_multi_planned_supply.
    mo_stock_repository->set_stock( iv_quantity = 0 ).
    mo_stock_repository->set_planned_receipt_quantity(
      iv_quantity = '12.000' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261005'
              open_base_quantity = '12.000' ) ) ) ) ).

    DATA(ls_local) = mo_cut->preview_orders_by_date(
      it_sales_documents = VALUE #( ( '0000004711' ) ) ).
    DATA(ls_projected) = mo_cut->preview_orders_by_date(
      it_sales_documents          = VALUE #( ( '0000004711' ) )
      iv_include_planned_receipts = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = ls_local-sales_unit_allocations[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_projected-sales_unit_allocations[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = ls_projected-sales_unit_allocations[ 1 ]-shortfall_base_quantity ).
  ENDMETHOD.

  METHOD previews_sched_agmt_supply.
    mo_stock_repository->set_stock( iv_quantity = 0 ).
    mo_stock_repository->set_sched_agmt_receipt_qty(
      iv_quantity = '12.000' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261005'
              open_base_quantity = '12.000' ) ) ) ) ).

    DATA(ls_local) = mo_cut->preview_orders_by_date(
      it_sales_documents = VALUE #( ( '0000004711' ) ) ).
    DATA(ls_projected) = mo_cut->preview_orders_by_date(
      it_sales_documents             = VALUE #( ( '0000004711' ) )
      iv_include_sched_agmt_receipts = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = ls_local-sales_unit_allocations[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_projected-sales_unit_allocations[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = ls_projected-sales_unit_allocations[ 1 ]-shortfall_base_quantity ).
  ENDMETHOD.

  METHOD previews_multi_existing_res.
    mo_stock_repository->set_stock( iv_quantity = '6.000' ).
    mo_stock_repository->set_sales_order_reservations(
      it_reservations = VALUE #(
        ( reservation_number = '0000008001'
          reservation_item   = '0001'
          sales_document     = '0000004711'
          material           = 'MAT-1'
          plant              = '1000'
          item_number        = '000010'
          schedule_line      = '0001'
          requirement_date   = '20261005'
          open_quantity      = '4.000' ) ) ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261005'
              open_base_quantity = '6.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->preview_orders_by_date(
      it_sales_documents = VALUE #(
        ( '0000004711' )
        ( '0000004712' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-sales_unit_allocations[ 1 ]-requested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-sales_unit_allocations[ 2 ]-requested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-sales_unit_allocations[ 2 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_stock_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD previews_multi_confirmed_qty.
    mo_stock_repository->set_stock( iv_quantity = '10.000' ).
    mo_availability_api->set_result(
      is_result = VALUE #(
        available_at_plant_quantity = '4.000'
        confirmed_date              = '20261005'
        confirmed_quantity          = '4.000'
        is_fully_available          = abap_false
        is_check_relevant           = abap_true ) ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number                  = '000010'
              schedule_line                = '0001'
              has_confirmed_quantity       = abap_true
              material                     = 'MAT-1'
              plant                        = '1000'
              entry_unit                   = 'EA'
              base_unit                    = 'EA'
              requested_date               = '20261005'
              open_quantity                = '12.000'
              open_base_quantity           = '12.000'
              confirmed_quantity           = '6.000'
              open_confirmed_quantity      = '6.000'
              confirmed_base_quantity      = '6.000'
              open_confirmed_base_quantity = '6.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->preview_orders_by_date(
      it_sales_documents   = VALUE #(
        ( '0000004711' )
        ( '0000004712' ) )
      iv_use_confirmed_qty = abap_true
      iv_check_atp         = abap_true
      iv_atp_check_rule    = 'A' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-sales_unit_allocations[ 1 ]-requested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-sales_unit_allocations[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-sales_unit_allocations[ 2 ]-requested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-sales_unit_allocations[ 2 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-atp_checks[ 1 ]-line_requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-atp_checks[ 1 ]-cumulative_requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-atp_checks[ 1 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_result-atp_checks[ 1 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-atp_checks[ 2 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_result-atp_checks[ 2 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-atp_checks[ 2 ]-result-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_availability_api->get_check_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-document_summaries ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = zif_stock_repository=>c_allocation_outcome_full
      act = ls_result-document_summaries[ 1 ]-allocation_outcome ).
    cl_abap_unit_assert=>assert_equals(
      exp = zif_stock_repository=>c_allocation_outcome_partial
      act = ls_result-document_summaries[ 2 ]-allocation_outcome ).
  ENDMETHOD.

  METHOD prepare_multi_res_fixture.
    mo_stock_repository->set_stock( iv_quantity = '10.000' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261005'
              open_base_quantity = '6.000' ) ) ) ) ).
  ENDMETHOD.

  METHOD reserves_multi_orders_by_date.
    mo_availability_api->set_result(
      is_result = VALUE #(
        confirmed_quantity = '3.000'
        confirmed_date     = '20261005'
        is_fully_available = abap_false
        is_check_relevant  = abap_true ) ).
    prepare_multi_res_fixture( ).

    DATA(ls_result) = mo_cut->reserve_orders_by_date(
      it_sales_documents = VALUE #(
        ( '0000004711' )
        ( '0000004712' ) )
      iv_check_atp       = abap_true
      iv_atp_check_rule  = 'A' ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711'
      act = lt_requests[ 1 ]-sales_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = lt_requests[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004712'
      act = lt_requests[ 2 ]-sales_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_requests[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261005'
      act = lt_requests[ 2 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reservation_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-reservations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-document_summaries ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = zif_stock_repository=>c_allocation_outcome_full
      act = ls_result-document_summaries[ 1 ]-allocation_outcome ).
    cl_abap_unit_assert=>assert_equals(
      exp = zif_stock_repository=>c_allocation_outcome_partial
      act = ls_result-document_summaries[ 2 ]-allocation_outcome ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-material_summaries ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-material_summaries[ 1 ]-sales_document_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-material_summaries[ 1 ]-requested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_result-material_summaries[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-material_summaries[ 1 ]-shortfall_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261005'
      act = ls_result-material_summaries[ 1 ]-first_required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261005'
      act = ls_result-material_summaries[ 1 ]-last_required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-material_summaries[ 1 ]-dated_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-material_summaries[ 1 ]-first_allocation_sequence ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-material_summaries[ 1 ]-last_allocation_sequence ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_sales_order_alloc_service=>c_sequence_scope_multi_order
      act = ls_result-material_summaries[ 1 ]-allocation_sequence_scope ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '83.33' )
      act = ls_result-material_summaries[ 1 ]-allocation_coverage_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-atp_checks[ 2 ]-cumulative_requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-atp_checks[ 1 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '9.000' )
      act = ls_result-atp_checks[ 1 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-atp_checks[ 2 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '9.000' )
      act = ls_result-atp_checks[ 2 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_availability_api->get_check_count( ) ).
  ENDMETHOD.

  METHOD reserves_multi_orders_bulk.
    mo_stock_repository->set_stock( iv_quantity = '3.000' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261005'
              open_base_quantity = '1.000' ) ) ) ) ).
    mo_reservation_api->set_create_failure_call(
      iv_call    = 2
      is_message = VALUE #(
        type    = 'E'
        message = 'Simulated reservation failure' ) ).

    DATA(ls_result) = mo_cut->reserve_orders_by_date_bulk(
      it_sales_documents = VALUE #(
        ( '0000004711' )
        ( '0000004712' )
        ( '0000004713' ) ) ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-order_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-document_summaries ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = zif_stock_repository=>c_allocation_outcome_full
      act = ls_result-document_summaries[ 1 ]-allocation_outcome ).
    cl_abap_unit_assert=>assert_equals(
      exp = zif_stock_repository=>c_allocation_outcome_full
      act = ls_result-document_summaries[ 2 ]-allocation_outcome ).
    cl_abap_unit_assert=>assert_equals(
      exp = zif_stock_repository=>c_allocation_outcome_full
      act = ls_result-document_summaries[ 3 ]-allocation_outcome ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-material_summaries ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = ls_result-material_summaries[ 1 ]-sales_document_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = ls_result-material_summaries[ 1 ]-fully_allocated_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = zif_stock_repository=>c_allocation_outcome_full
      act = ls_result-order_results[ 1 ]-document_summary-allocation_outcome ).
    cl_abap_unit_assert=>assert_equals(
      exp = zif_stock_repository=>c_allocation_outcome_full
      act = ls_result-order_results[ 2 ]-document_summary-allocation_outcome ).
    cl_abap_unit_assert=>assert_equals(
      exp = zif_stock_repository=>c_allocation_outcome_full
      act = ls_result-order_results[ 3 ]-document_summary-allocation_outcome ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-order_results[ 2 ]-document_summary-dated_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261005'
      act = ls_result-order_results[ 2 ]-document_summary-first_required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-order_results[ 2 ]-document_summary-first_allocation_sequence ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_sales_order_alloc_service=>c_sequence_scope_multi_order
      act = ls_result-order_results[ 2 ]-document_summary-allocation_sequence_scope ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '100.00' )
      act = ls_result-order_results[ 2 ]-document_summary-fully_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '0.00' )
      act = ls_result-order_results[ 2 ]-document_summary-partially_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '0.00' )
      act = ls_result-order_results[ 2 ]-document_summary-unallocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-order_results[ 1 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-order_results[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 2 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Simulated reservation failure'
      act = ls_result-order_results[ 2 ]-messages[ 1 ]-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-order_results[ 3 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-order_results[ 3 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = mo_reservation_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_reservation_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reservation_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-reservations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004713'
      act = lt_requests[ 1 ]-sales_document ).
  ENDMETHOD.

  METHOD rolls_back_bulk_commit.
    mo_stock_repository->set_stock( iv_quantity = '3.000' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261005'
              open_base_quantity = '1.000' ) ) ) ) ).
    mo_reservation_api->set_commit_failure_call(
      iv_call   = 2
      is_result = VALUE #(
        is_successful = abap_false
        message       = VALUE #(
          type    = 'E'
          message = 'Simulated commit failure' ) ) ).

    DATA(ls_result) = mo_cut->reserve_orders_by_date_bulk(
      it_sales_documents = VALUE #(
        ( '0000004711' )
        ( '0000004712' )
        ( '0000004713' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-order_results[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 2 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Simulated commit failure'
      act = ls_result-order_results[ 2 ]-messages[ 1 ]-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-order_results[ 3 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = mo_reservation_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = mo_reservation_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reservation_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-reservations ) ).
  ENDMETHOD.

  METHOD simulates_multi_res_bulk.
    mo_stock_repository->set_stock( iv_quantity = '2.000' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261005'
              open_base_quantity = '1.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_orders_by_date_bulk(
      it_sales_documents = VALUE #(
        ( '0000004711' )
        ( '0000004712' ) )
      iv_test_run        = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-reservations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-order_results[ 1 ]-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = mo_reservation_api->was_test_run( ) ).
  ENDMETHOD.

  METHOD reserves_mbd_dates.
    prepare_mbd_schedule_fixture( ).

    DATA(ls_result) = mo_cut->reserve_orders_by_date(
      it_sales_documents         = VALUE #( ( '0000004711' ) )
      iv_use_material_avail_date = abap_true ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711/000010/0001'
      act = lt_requests[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261001'
      act = lt_requests[ 1 ]-required_date ).
  ENDMETHOD.

  METHOD reserves_by_order_priority.
    mo_stock_repository->set_stock( iv_quantity = '3.000' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261005'
              open_base_quantity = '3.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_orders_by_date(
      it_sales_documents   = VALUE #(
        ( '0000004711' )
        ( '0000004712' ) )
      it_demand_priorities = VALUE #(
        ( sales_document = '0000004711'
          item_number    = '000010'
          schedule_line  = '0001'
          priority       = 1 )
        ( sales_document = '0000004712'
          item_number    = '000010'
          schedule_line  = '0001'
          priority       = 5 ) ) ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004712/000010/0001'
      act = lt_requests[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = ls_result-sales_unit_allocations[ 2 ]-priority ).
  ENDMETHOD.

  METHOD orders_priority_reservations.
    mo_stock_repository->set_stock( iv_quantity = '6.000' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261005'
              open_base_quantity = '3.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_orders_by_date(
      it_sales_documents   = VALUE #(
        ( '0000004711' )
        ( '0000004712' ) )
      it_demand_priorities = VALUE #(
        ( sales_document = '0000004711'
          item_number    = '000010'
          schedule_line  = '0001'
          priority       = 1 )
        ( sales_document = '0000004712'
          item_number    = '000010'
          schedule_line  = '0001'
          priority       = 5 ) ) ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004712/000010/0001'
      act = lt_requests[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711/000010/0001'
      act = lt_requests[ 2 ]-request_id ).
  ENDMETHOD.

  METHOD reserves_sched_agmt_supply.
    mo_stock_repository->set_stock( iv_quantity = 0 ).
    mo_stock_repository->set_sched_agmt_receipt_qty(
      iv_quantity = '12.000' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261005'
              open_base_quantity = '12.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_orders_by_date(
      it_sales_documents             = VALUE #( ( '0000004711' ) )
      iv_test_run                    = abap_true
      iv_include_sched_agmt_receipts = abap_true ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = lt_requests[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = mo_reservation_api->was_test_run( ) ).
  ENDMETHOD.

  METHOD reserves_multi_due_first.
    mo_stock_repository->set_stock( iv_quantity = '14.000' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261015'
              open_base_quantity = '6.000' )
            ( item_number        = '000010'
              schedule_line      = '0002'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261005'
              open_base_quantity = '6.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_orders_by_date(
      it_sales_documents = VALUE #(
        ( '0000004711' )
        ( '0000004712' ) ) ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261005'
      act = lt_requests[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711'
      act = lt_requests[ 1 ]-sales_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261005'
      act = lt_requests[ 2 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004712'
      act = lt_requests[ 2 ]-sales_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261015'
      act = lt_requests[ 3 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711'
      act = lt_requests[ 3 ]-sales_document ).
  ENDMETHOD.

  METHOD simulates_multi_order_res.
    prepare_multi_res_fixture( ).

    DATA(ls_result) = mo_cut->reserve_orders_by_date(
      it_sales_documents = VALUE #(
        ( '0000004711' )
        ( '0000004712' ) )
      iv_test_run        = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = mo_reservation_api->was_test_run( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-reservations ) ).
  ENDMETHOD.

  METHOD rejects_short_multi_reserve.
    prepare_multi_res_fixture( ).

    DATA(ls_result) = mo_cut->reserve_orders_by_date(
      it_sales_documents         = VALUE #(
        ( '0000004711' )
        ( '0000004712' ) )
      iv_require_full_allocation = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-messages ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_short_multi_atp.
    prepare_multi_res_fixture( ).
    mo_stock_repository->set_stock( iv_quantity = '12.000' ).
    mo_availability_api->set_result(
      is_result = VALUE #(
        confirmed_date     = '20261005'
        confirmed_quantity = '3.000'
        is_fully_available = abap_false
        is_check_relevant  = abap_true ) ).

    DATA(ls_result) = mo_cut->reserve_orders_by_date(
      it_sales_documents          = VALUE #(
        ( '0000004711' )
        ( '0000004712' ) )
      iv_test_run                 = abap_true
      iv_require_atp_confirmation = abap_true
      iv_check_atp                = abap_true
      iv_atp_check_rule           = 'A' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-atp_checks[ 1 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-atp_checks[ 1 ]-cumulative_requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-messages ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD reserves_multi_atp_confirmed.
    prepare_multi_res_fixture( ).
    mo_stock_repository->set_stock( iv_quantity = '12.000' ).
    mo_availability_api->set_result(
      is_result = VALUE #(
        confirmed_date     = '20261005'
        confirmed_quantity = '12.000'
        is_fully_available = abap_true
        is_check_relevant  = abap_true ) ).

    DATA(ls_result) = mo_cut->reserve_orders_by_date(
      it_sales_documents          = VALUE #(
        ( '0000004711' )
        ( '0000004712' ) )
      iv_test_run                 = abap_true
      iv_require_atp_confirmation = abap_true
      iv_check_atp                = abap_true
      iv_atp_check_rule           = 'A' ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-atp_checks[ 1 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = ls_result-atp_checks[ 1 ]-cumulative_requested_quantity
      act = ls_result-atp_checks[ 1 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = ls_result-atp_checks[ 2 ]-cumulative_requested_quantity
      act = ls_result-atp_checks[ 2 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reservation_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_late_multi_atp.
    prepare_multi_res_fixture( ).
    mo_stock_repository->set_stock( iv_quantity = '12.000' ).
    mo_availability_api->set_result(
      is_result = VALUE #(
        confirmed_date     = '20261006'
        confirmed_quantity = '12.000'
        is_fully_available = abap_false
        is_check_relevant  = abap_true ) ).

    DATA(ls_result) = mo_cut->reserve_orders_by_date(
      it_sales_documents          = VALUE #(
        ( '0000004711' )
        ( '0000004712' ) )
      iv_test_run                 = abap_true
      iv_require_atp_confirmation = abap_true
      iv_check_atp                = abap_true
      iv_atp_check_rule           = 'A' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-atp_checks[ 1 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-atp_checks[ 1 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_multi_order_res.
    prepare_multi_res_fixture( ).
    mo_reservation_api->set_create_result(
      is_result = VALUE #(
        is_successful = abap_false
        messages      = VALUE #(
          ( type = 'E' message = 'Reservation creation failed' ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_orders_by_date(
      it_sales_documents = VALUE #(
        ( '0000004711' )
        ( '0000004712' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reservation_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_result-reservations ) ).
  ENDMETHOD.

  METHOD rolls_back_multi_commit_err.
    prepare_multi_res_fixture( ).
    mo_reservation_api->set_commit_result(
      is_result = VALUE #(
        is_successful = abap_false
        message       = VALUE #(
          type    = 'E'
          message = 'Commit failed' ) ) ).

    DATA(ls_result) = mo_cut->reserve_orders_by_date(
      it_sales_documents = VALUE #(
        ( '0000004711' )
        ( '0000004712' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reservation_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reservation_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_result-reservations ) ).
  ENDMETHOD.

  METHOD rejects_bad_multi_res_result.
    prepare_multi_res_fixture( ).
    mo_reservation_api->set_create_result(
      is_result = VALUE #(
        is_successful = abap_true
        reservations  = VALUE #(
          ( request_id         = 'UNMATCHED'
            reservation_number = '9000000001'
            required_date      = '20261005'
            quantity           = '6.000' )
          ( request_id         = '0000004712/000010/0001'
            reservation_number = '9000000002'
            required_date      = '20261005'
            quantity           = '4.000' ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_orders_by_date(
      it_sales_documents = VALUE #(
        ( '0000004711' )
        ( '0000004712' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reservation_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_result-reservations ) ).
  ENDMETHOD.

  METHOD reports_order_floor_trace.
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
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261020'
              open_base_quantity = '10.000' )
            ( item_number        = '000020'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261001'
              open_base_quantity = '5.000' )
            ( item_number        = '000030'
              material           = 'MAT-1'
              plant              = '2000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261021'
              open_base_quantity = '10.000' )
            ( item_number        = '000040'
              material           = 'MAT-2'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261022'
              open_base_quantity = '5.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->preview_order(
      iv_sales_document          = '0000004711'
      it_allocation_requirements = VALUE #(
        ( sales_document       = '0000004711'
          item_number          = '000010'
          minimum_coverage_pct = '80.00' )
        ( sales_document       = '0000004711'
          item_number          = '000030'
          minimum_coverage_pct = '80.00' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-order_summaries ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = zif_stock_repository=>c_allocation_outcome_partial
      act = ls_result-order_summaries[ 1 ]-allocation_outcome ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '33.33' )
      act = ls_result-order_summaries[ 1 ]-allocation_coverage_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-order_summaries[ 1 ]-fully_allocated_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-order_summaries[ 1 ]-unallocated_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-order_summaries[ 1 ]-floor_rejected_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '50.00' )
      act = ls_result-order_summaries[ 1 ]-floor_rejected_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '50.00' )
      act = ls_result-order_summaries[ 1 ]-fully_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '0.00' )
      act = ls_result-order_summaries[ 1 ]-partially_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '50.00' )
      act = ls_result-order_summaries[ 1 ]-unallocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = zif_stock_repository=>c_allocation_outcome_none
      act = ls_result-order_summaries[ 2 ]-allocation_outcome ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '0.00' )
      act = ls_result-order_summaries[ 2 ]-allocation_coverage_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-order_summaries[ 2 ]-unallocated_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-order_summaries[ 2 ]-floor_rejected_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '100.00' )
      act = ls_result-order_summaries[ 2 ]-floor_rejected_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '0.00' )
      act = ls_result-order_summaries[ 2 ]-fully_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '0.00' )
      act = ls_result-order_summaries[ 2 ]-partially_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '100.00' )
      act = ls_result-order_summaries[ 2 ]-unallocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = zif_stock_repository=>c_allocation_outcome_full
      act = ls_result-order_summaries[ 3 ]-allocation_outcome ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '100.00' )
      act = ls_result-order_summaries[ 3 ]-allocation_coverage_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-order_summaries[ 3 ]-fully_allocated_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_result-order_summaries[ 3 ]-floor_rejected_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '0.00' )
      act = ls_result-order_summaries[ 3 ]-floor_rejected_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '100.00' )
      act = ls_result-order_summaries[ 3 ]-fully_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '0.00' )
      act = ls_result-order_summaries[ 3 ]-partially_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '0.00' )
      act = ls_result-order_summaries[ 3 ]-unallocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-document_summaries ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = zif_stock_repository=>c_allocation_outcome_partial
      act = ls_result-document_summaries[ 1 ]-allocation_outcome ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = ls_result-document_summaries[ 1 ]-demand_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-document_summaries[ 1 ]-fully_allocated_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-document_summaries[ 1 ]-unallocated_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-document_summaries[ 1 ]-floor_rejected_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '50.00' )
      act = ls_result-document_summaries[ 1 ]-floor_rejected_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '50.00' )
      act = ls_result-document_summaries[ 1 ]-fully_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '0.00' )
      act = ls_result-document_summaries[ 1 ]-partially_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '50.00' )
      act = ls_result-document_summaries[ 1 ]-unallocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = ls_result-document_summaries[ 1 ]-dated_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261001'
      act = ls_result-document_summaries[ 1 ]-first_required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261022'
      act = ls_result-document_summaries[ 1 ]-last_required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-document_summaries[ 1 ]-first_allocation_sequence ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = ls_result-document_summaries[ 1 ]-last_allocation_sequence ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_sales_order_alloc_service=>c_sequence_scope_single_order
      act = ls_result-document_summaries[ 1 ]-allocation_sequence_scope ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-allocations[ 1 ]-minimum_coverage_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-sales_unit_allocations[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-sales_unit_allocations[ 1 ]-minimum_coverage_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-sales_unit_allocations[ 2 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-sales_unit_allocations[ 2 ]-minimum_coverage_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-allocations[ 1 ]-allocation_sequence ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-sales_unit_allocations[ 1 ]-allocation_sequence ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_sales_order_alloc_service=>c_sequence_scope_single_order
      act = ls_result-sales_unit_allocations[ 1 ]-allocation_sequence_scope ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-sales_unit_allocations[ 2 ]-allocation_sequence ).

    DATA(ls_single_date_result) = mo_cut->preview_order(
      iv_sales_document          = '0000004711'
      it_allocation_requirements = VALUE #(
        ( sales_document       = '0000004711'
          item_number          = '000010'
          minimum_coverage_pct = '80.00' )
        ( sales_document       = '0000004711'
          item_number          = '000030'
          minimum_coverage_pct = '80.00' ) )
      iv_prioritize_by_date      = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = '000020'
      act = ls_single_date_result-sales_unit_allocations[ 1 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_single_date_result-allocations[ 1 ]-allocation_sequence ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_single_date_result-sales_unit_allocations[ 1 ]-allocation_sequence ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_sales_order_alloc_service=>c_sequence_scope_single_order
      act = ls_single_date_result-sales_unit_allocations[ 1 ]-allocation_sequence_scope ).
    cl_abap_unit_assert=>assert_equals(
      exp = '000010'
      act = ls_single_date_result-sales_unit_allocations[ 2 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_single_date_result-sales_unit_allocations[ 2 ]-allocation_sequence ).

    DATA(ls_multi_result) = mo_cut->preview_orders_by_date(
      it_sales_documents         = VALUE #( ( '0000004711' ) )
      it_allocation_requirements = VALUE #(
        ( sales_document       = '0000004711'
          item_number          = '000010'
          minimum_coverage_pct = '80.00' )
        ( sales_document       = '0000004711'
          item_number          = '000030'
          minimum_coverage_pct = '80.00' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_multi_result-order_summaries ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = zif_stock_repository=>c_allocation_outcome_partial
      act = ls_multi_result-order_summaries[ 1 ]-allocation_outcome ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '33.33' )
      act = ls_multi_result-order_summaries[ 1 ]-allocation_coverage_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_multi_result-order_summaries[ 1 ]-fully_allocated_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_multi_result-order_summaries[ 1 ]-unallocated_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_multi_result-order_summaries[ 1 ]-floor_rejected_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '50.00' )
      act = ls_multi_result-order_summaries[ 1 ]-floor_rejected_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '50.00' )
      act = ls_multi_result-order_summaries[ 1 ]-fully_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '0.00' )
      act = ls_multi_result-order_summaries[ 1 ]-partially_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '50.00' )
      act = ls_multi_result-order_summaries[ 1 ]-unallocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = zif_stock_repository=>c_allocation_outcome_none
      act = ls_multi_result-order_summaries[ 2 ]-allocation_outcome ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '0.00' )
      act = ls_multi_result-order_summaries[ 2 ]-allocation_coverage_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_multi_result-order_summaries[ 2 ]-unallocated_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_multi_result-order_summaries[ 2 ]-floor_rejected_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '100.00' )
      act = ls_multi_result-order_summaries[ 2 ]-floor_rejected_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '0.00' )
      act = ls_multi_result-order_summaries[ 2 ]-fully_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '0.00' )
      act = ls_multi_result-order_summaries[ 2 ]-partially_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '100.00' )
      act = ls_multi_result-order_summaries[ 2 ]-unallocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = zif_stock_repository=>c_allocation_outcome_full
      act = ls_multi_result-order_summaries[ 3 ]-allocation_outcome ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '100.00' )
      act = ls_multi_result-order_summaries[ 3 ]-allocation_coverage_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_multi_result-order_summaries[ 3 ]-fully_allocated_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_multi_result-order_summaries[ 3 ]-floor_rejected_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '0.00' )
      act = ls_multi_result-order_summaries[ 3 ]-floor_rejected_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '100.00' )
      act = ls_multi_result-order_summaries[ 3 ]-fully_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '0.00' )
      act = ls_multi_result-order_summaries[ 3 ]-partially_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '0.00' )
      act = ls_multi_result-order_summaries[ 3 ]-unallocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '50.00' )
      act = ls_multi_result-material_summaries[ 1 ]-floor_rejected_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '50.00' )
      act = ls_multi_result-material_summaries[ 1 ]-fully_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '0.00' )
      act = ls_multi_result-material_summaries[ 1 ]-partially_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '50.00' )
      act = ls_multi_result-material_summaries[ 1 ]-unallocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '100.00' )
      act = ls_multi_result-material_summaries[ 2 ]-floor_rejected_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '0.00' )
      act = ls_multi_result-material_summaries[ 2 ]-fully_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '0.00' )
      act = ls_multi_result-material_summaries[ 2 ]-partially_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '100.00' )
      act = ls_multi_result-material_summaries[ 2 ]-unallocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '0.00' )
      act = ls_multi_result-material_summaries[ 3 ]-floor_rejected_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '100.00' )
      act = ls_multi_result-material_summaries[ 3 ]-fully_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '0.00' )
      act = ls_multi_result-material_summaries[ 3 ]-partially_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '0.00' )
      act = ls_multi_result-material_summaries[ 3 ]-unallocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = zif_stock_repository=>c_allocation_outcome_partial
      act = ls_multi_result-document_summaries[ 1 ]-allocation_outcome ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '50.00' )
      act = ls_multi_result-document_summaries[ 1 ]-fully_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '0.00' )
      act = ls_multi_result-document_summaries[ 1 ]-partially_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '50.00' )
      act = ls_multi_result-document_summaries[ 1 ]-unallocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = ls_multi_result-document_summaries[ 1 ]-dated_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261001'
      act = ls_multi_result-document_summaries[ 1 ]-first_required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261022'
      act = ls_multi_result-document_summaries[ 1 ]-last_required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_multi_result-document_summaries[ 1 ]-first_allocation_sequence ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = ls_multi_result-document_summaries[ 1 ]-last_allocation_sequence ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_sales_order_alloc_service=>c_sequence_scope_multi_order
      act = ls_multi_result-document_summaries[ 1 ]-allocation_sequence_scope ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_multi_result-sales_unit_allocations[ 1 ]-minimum_coverage_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_multi_result-sales_unit_allocations[ 2 ]-minimum_coverage_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_multi_result-sales_unit_allocations[ 1 ]-allocation_sequence ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_sales_order_alloc_service=>c_sequence_scope_multi_order
      act = ls_multi_result-sales_unit_allocations[ 1 ]-allocation_sequence_scope ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_multi_result-sales_unit_allocations[ 2 ]-allocation_sequence ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_sales_order_alloc_service=>c_sequence_scope_multi_order
      act = ls_multi_result-sales_unit_allocations[ 2 ]-allocation_sequence_scope ).
  ENDMETHOD.

  METHOD summarizes_document_outcomes.
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
              open_base_quantity = '5.000' ) ) ) ) ).

    mo_stock_repository->set_stock( iv_quantity = '5.000' ).
    DATA(ls_full_result) = mo_cut->preview_order( '0000004711' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_full_result-document_summaries ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = zif_stock_repository=>c_allocation_outcome_full
      act = ls_full_result-document_summaries[ 1 ]-allocation_outcome ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_full_result-document_summaries[ 1 ]-fully_allocated_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '100.00' )
      act = ls_full_result-document_summaries[ 1 ]-fully_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_full_result-document_summaries[ 1 ]-dated_line_count ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_full_result-document_summaries[ 1 ]-first_required_date ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_full_result-document_summaries[ 1 ]-last_required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_sales_order_alloc_service=>c_sequence_scope_single_order
      act = ls_full_result-document_summaries[ 1 ]-allocation_sequence_scope ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '0.00' )
      act = ls_full_result-document_summaries[ 1 ]-floor_rejected_line_pct ).

    mo_stock_repository->set_stock( iv_quantity = '0.000' ).
    DATA(ls_none_result) = mo_cut->preview_order( '0000004711' ).
    cl_abap_unit_assert=>assert_equals(
      exp = zif_stock_repository=>c_allocation_outcome_none
      act = ls_none_result-document_summaries[ 1 ]-allocation_outcome ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_none_result-document_summaries[ 1 ]-unallocated_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '100.00' )
      act = ls_none_result-document_summaries[ 1 ]-unallocated_line_pct ).

    mo_stock_repository->set_stock( iv_quantity = '3.000' ).
    DATA(ls_partial_result) = mo_cut->preview_order( '0000004711' ).
    cl_abap_unit_assert=>assert_equals(
      exp = zif_stock_repository=>c_allocation_outcome_partial
      act = ls_partial_result-document_summaries[ 1 ]-allocation_outcome ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_partial_result-document_summaries[ 1 ]-partially_allocated_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '100.00' )
      act = ls_partial_result-document_summaries[ 1 ]-partially_allocated_line_pct ).
  ENDMETHOD.

  METHOD summarizes_outcome_percentages.
    mo_stock_repository->set_stock( iv_quantity = '6.000' ).
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
              requested_date     = '20261001'
              open_base_quantity = '4.000' )
            ( item_number        = '000020'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261001'
              open_base_quantity = '4.000' )
            ( item_number        = '000030'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261001'
              open_base_quantity = '4.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->preview_order( '0000004711' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-order_summaries[ 1 ]-fully_allocated_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-order_summaries[ 1 ]-partially_allocated_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-order_summaries[ 1 ]-unallocated_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '33.33' )
      act = ls_result-order_summaries[ 1 ]-fully_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '33.33' )
      act = ls_result-order_summaries[ 1 ]-partially_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '33.33' )
      act = ls_result-order_summaries[ 1 ]-unallocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '33.33' )
      act = ls_result-document_summaries[ 1 ]-fully_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '33.33' )
      act = ls_result-document_summaries[ 1 ]-partially_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '33.33' )
      act = ls_result-document_summaries[ 1 ]-unallocated_line_pct ).

    DATA(ls_multi_result) = mo_cut->preview_orders_by_date(
      it_sales_documents = VALUE #( ( '0000004711' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_multi_result-material_summaries[ 1 ]-fully_allocated_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_multi_result-material_summaries[ 1 ]-partially_allocated_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_multi_result-material_summaries[ 1 ]-unallocated_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '33.33' )
      act = ls_multi_result-material_summaries[ 1 ]-fully_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '33.33' )
      act = ls_multi_result-material_summaries[ 1 ]-partially_allocated_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV zcl_stock_service=>ty_allocation_coverage_pct( '33.33' )
      act = ls_multi_result-material_summaries[ 1 ]-unallocated_line_pct ).
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
              entry_unit         = 'EA'
              base_unit          = 'EA'
              open_base_quantity = '4.000' )
            ( item_number        = '000020'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              open_base_quantity = '3.000' )
            ( item_number        = '000030'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
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
      exp = 0
      act = ls_result-order_summaries[ 1 ]-dated_line_count ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-order_summaries[ 1 ]-first_required_date ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-order_summaries[ 1 ]-last_required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-order_summaries[ 1 ]-first_allocation_sequence ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-order_summaries[ 1 ]-last_allocation_sequence ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_sales_order_alloc_service=>c_sequence_scope_single_order
      act = ls_result-order_summaries[ 1 ]-allocation_sequence_scope ).
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
        confirmed_quantity          = '1.000'
        confirmation_lines          = VALUE #(
          ( confirmed_date = '20261001' confirmed_quantity = '1.000' )
          ( confirmed_date = '20261001' confirmed_quantity = '1.000' ) )
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
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 1 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-atp_checks[ 1 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_result-atp_checks[ 1 ]-result-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
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
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 2 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 2 ]-unconfirmed_base_quantity ).
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

  METHOD previews_priority_atp.
    mo_availability_api->set_result(
      is_result = VALUE #(
        available_at_plant_quantity = '4.000'
        confirmed_date              = '20261005'
        confirmed_quantity          = '4.000'
        confirmation_lines          = VALUE #(
          ( confirmed_date = '20261005' confirmed_quantity = '4.000' ) )
        dialog_flag                 = 'X'
        is_fully_available          = abap_false
        is_check_relevant           = abap_true ) ).
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
              requested_date     = '20261005'
              open_base_quantity = '3.000' )
            ( item_number        = '000010'
              schedule_line      = '0002'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              requested_date     = '20261005'
              open_base_quantity = '3.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->preview_order(
      iv_sales_document     = '0000004711'
      iv_prioritize_by_date = abap_true
      it_item_priorities    = VALUE #(
        ( item_number   = '000010'
          schedule_line = '0001'
          priority      = 1 )
        ( item_number   = '000010'
          schedule_line = '0002'
          priority      = 7 ) )
      iv_check_atp          = abap_true
      iv_atp_check_rule     = 'A' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711/000010/0002'
      act = ls_result-atp_checks[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 7
      act = ls_result-atp_checks[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-atp_checks[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-atp_checks[ 1 ]-cumulative_requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-atp_checks[ 2 ]-cumulative_requested_quantity ).
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

    CLEAR lv_exception_raised.
    TRY.
        mo_cut->reserve_order(
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

    DATA(ls_required_atp) = mo_cut->reserve_order(
      iv_sales_document           = '0000004711'
      iv_require_atp_confirmation = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_required_atp-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_required_atp-messages ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_invalid_atp_gate.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->reserve_order(
          iv_sales_document           = '0000004711'
          iv_require_atp_confirmation = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repository->get_read_count( ) ).

    CLEAR lv_exception_raised.
    TRY.
        mo_cut->reserve_orders_by_date(
          it_sales_documents          = VALUE #( ( '0000004711' ) )
          iv_require_atp_confirmation = 'Y' ).
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
      act = mo_reservation_api->get_create_count( ) ).
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

  METHOD rejects_order_atp_overflow.
    mo_stock_repository->set_stock(
      iv_quantity = '9999999999.999' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261020'
              open_base_quantity = '9999999999.999' )
            ( item_number        = '000020'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261020'
              open_base_quantity = '9999999999.999' ) ) ) ) ).
    DATA lv_rejected TYPE abap_bool.
    DATA ls_result TYPE zcl_sales_order_alloc_service=>ty_result.

    TRY.
        ls_result = mo_cut->preview_order(
          iv_sales_document = '0000004711'
          iv_check_atp      = abap_true
          iv_atp_check_rule = 'A' ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_availability_api->get_check_count( ) ).
  ENDMETHOD.

  METHOD rejects_multi_atp_overflow.
    mo_stock_repository->set_stock(
      iv_quantity = '9999999999.999' ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261020'
              open_base_quantity = '9999999999.999' )
            ( item_number        = '000020'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261020'
              open_base_quantity = '9999999999.999' ) ) ) ) ).
    DATA lv_rejected TYPE abap_bool.
    DATA ls_result TYPE zcl_sales_order_alloc_service=>ty_result.

    TRY.
        ls_result = mo_cut->preview_orders_by_date(
          it_sales_documents = VALUE #( ( '0000004711' ) )
          iv_check_atp       = abap_true
          iv_atp_check_rule  = 'A' ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_rejected ).
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

  METHOD rejects_sales_uom_limits.
    DATA lv_exception_raised TYPE abap_bool.
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          sales_document = '0000004711'
          items          = VALUE #(
            ( item_number            = '000010'
              material               = 'MAT-1'
              plant                  = '1000'
              quantity               = '9999999.999'
              entry_unit             = 'BOX'
              sales_unit_numerator   = 1
              sales_unit_denominator = 99999
              base_quantity          = '9999999.999'
              open_quantity          = '9999999.999'
              open_base_quantity     = '9999999.999'
              base_unit              = 'EA' ) ) ) ) ).

    TRY.
        mo_cut->preview_order( '0000004711' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).

    CLEAR lv_exception_raised.
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          sales_document = '0000004711'
          items          = VALUE #(
            ( item_number            = '000010'
              material               = 'MAT-1'
              plant                  = '1000'
              quantity               = '1.000'
              entry_unit             = 'BOX'
              sales_unit_numerator   = 99999
              sales_unit_denominator = 1
              base_quantity          = '1.000'
              open_quantity          = '1.000'
              open_base_quantity     = '1.000'
              base_unit              = 'EA' ) ) ) ) ).

    TRY.
        mo_cut->preview_order( '0000004711' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
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
              entry_unit         = 'EA'
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
      iv_prioritize_by_date = abap_true
      it_item_priorities    = VALUE #(
        ( item_number   = '000020'
          schedule_line = '0001'
          priority      = 1 )
        ( item_number   = '000015'
          schedule_line = '0003'
          priority      = 5 ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_date_result-is_successful ).
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
      exp = '0000004711/000015/0003'
      act = ls_date_result-allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_date_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = ls_date_result-sales_unit_allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711/000020/0001'
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

  METHOD reserves_order_priorities.
    mo_stock_repository->set_stock( iv_quantity = '6.000' ).
    mo_availability_api->set_result(
      is_result = VALUE #(
        available_at_plant_quantity = '6.000'
        confirmed_date              = '20261005'
        confirmed_quantity          = '6.000'
        confirmation_lines          = VALUE #(
          ( confirmed_quantity = '6.000' ) )
        dialog_flag                 = 'X'
        is_fully_available          = abap_true
        is_check_relevant           = abap_true ) ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261005'
              open_base_quantity = '3.000' )
            ( item_number        = '000020'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261005'
              open_base_quantity = '3.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_order(
      iv_sales_document           = '0000004711'
      iv_test_run                 = abap_true
      iv_prioritize_by_date       = abap_true
      iv_check_atp                = abap_true
      iv_require_atp_confirmation = abap_true
      iv_atp_check_rule           = 'A'
      it_item_priorities          = VALUE #(
        ( item_number = '000010' schedule_line = '0001' priority = 1 )
        ( item_number = '000020' schedule_line = '0001' priority = 9 ) ) ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711/000020/0001'
      act = lt_requests[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711/000010/0001'
      act = lt_requests[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 9
      act = ls_result-sales_unit_allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 9
      act = ls_result-atp_checks[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-atp_checks[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_availability_api->get_check_count( ) ).
  ENDMETHOD.

  METHOD rejects_short_order_atp.
    mo_stock_repository->set_stock( iv_quantity = '6.000' ).
    mo_availability_api->set_result(
      is_result = VALUE #(
        confirmed_date     = '20261005'
        confirmed_quantity = '3.000'
        is_fully_available = abap_false
        is_check_relevant  = abap_true ) ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261005'
              open_base_quantity = '3.000' )
            ( item_number        = '000020'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261005'
              open_base_quantity = '3.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_order(
      iv_sales_document           = '0000004711'
      iv_test_run                 = abap_true
      iv_require_atp_confirmation = abap_true
      iv_check_atp                = abap_true
      iv_atp_check_rule           = 'A' ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-atp_checks[ 1 ]-cumulative_requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-atp_checks[ 1 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-messages ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_requests ) ).
  ENDMETHOD.

  METHOD rejects_future_order_atp.
    mo_stock_repository->set_stock( iv_quantity = '3.000' ).
    mo_availability_api->set_result(
      is_result = VALUE #(
        confirmed_date     = '20261006'
        confirmed_quantity = '3.000'
        is_fully_available = abap_false
        is_check_relevant  = abap_true ) ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
              base_unit          = 'EA'
              requested_date     = '20261005'
              open_base_quantity = '3.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_order(
      iv_sales_document           = '0000004711'
      iv_test_run                 = abap_true
      iv_require_atp_confirmation = abap_true
      iv_check_atp                = abap_true
      iv_atp_check_rule           = 'A' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-atp_checks[ 1 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-atp_checks[ 1 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_order_priorities.
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
              requested_date     = '20261005'
              open_base_quantity = '3.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->preview_order(
      iv_sales_document     = '0000004711'
      iv_prioritize_by_date = abap_true
      it_item_priorities    = VALUE #(
        ( item_number   = '000010'
          schedule_line = '0002'
          priority      = 5 ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-messages ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_priority_without_date.
    DATA(ls_result) = mo_cut->preview_order(
      iv_sales_document  = '0000004711'
      it_item_priorities = VALUE #(
        ( item_number   = '000010'
          schedule_line = '0001'
          priority      = 5 ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-messages ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD subtracts_order_reservations.
    mo_stock_repository->set_stock( iv_quantity = '10.000' ).
    mo_stock_repository->set_sales_order_reservations(
      it_reservations = VALUE #(
        ( reservation_number = '0000008101'
          reservation_item   = '0001'
          sales_document     = '0000004711'
          material           = 'MAT-1'
          plant              = '1000'
          item_number        = '000010'
          schedule_line      = '0001'
          requirement_date   = '20261001'
          open_quantity      = '1.000' )
        ( reservation_number = '0000008102'
          reservation_item   = '0002'
          sales_document     = '0000004711'
          material           = 'MAT-1'
          plant              = '1000'
          item_number        = '000010'
          requirement_date   = '20261008'
          open_quantity      = '2.000' ) ) ).
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
        ( reservation_number = '0000008201'
          reservation_item   = '0001'
          sales_document     = '0000004711'
          material           = 'MAT-1'
          plant              = '1000'
          item_number        = '000010'
          requirement_date   = '20261001'
          open_quantity      = '5.000' ) ) ).
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
              entry_unit         = 'EA'
              base_unit          = 'EA'
              open_base_quantity = '3.000' )
            ( item_number        = '000020'
              material           = 'MAT-1'
              plant              = '1000'
              entry_unit         = 'EA'
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
    cl_abap_unit_assert=>assert_equals(
      exp = zif_stock_repository=>c_allocation_outcome_partial
      act = ls_result-document_summaries[ 1 ]-allocation_outcome ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-document_summaries[ 1 ]-fully_allocated_line_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-document_summaries[ 1 ]-partially_allocated_line_count ).
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

  METHOD rejects_bad_schedule_date.
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #( (
            item_number        = '000010'
            schedule_line      = '0001'
            material           = 'MAT-1'
            plant              = '1000'
            entry_unit         = 'EA'
            base_unit          = 'EA'
            requested_date     = '20260230'
            open_base_quantity = '1.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->preview_order( '0000004711' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Sales-order schedule date is not a valid Gregorian date'
      act = ls_result-messages[ 1 ]-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_availability_api->get_check_count( ) ).
    DATA(ls_reserve_result) = mo_cut->reserve_order( '0000004711' ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_reserve_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_api->get_create_count( ) ).

    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #( (
            item_number                = '000010'
            schedule_line              = '0001'
            material                   = 'MAT-1'
            plant                      = '1000'
            entry_unit                 = 'EA'
            base_unit                  = 'EA'
            requested_date             = '20261101'
            material_availability_date = '20260230'
            open_base_quantity         = '1.000' ) ) ) ) ).
    CLEAR ls_result.
    ls_result = mo_cut->preview_order(
      iv_sales_document          = '0000004711'
      iv_use_material_avail_date = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Sales-order schedule date is not a valid Gregorian date'
      act = ls_result-messages[ 1 ]-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repository->get_read_count( ) ).

    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #( (
            item_number        = '000010'
            schedule_line      = '0001'
            material           = 'MAT-1'
            plant              = '1000'
            entry_unit         = 'EA'
            base_unit          = 'EA'
            requested_date     = '20260230'
            open_base_quantity = '1.000' ) ) ) ) ).
    DATA(ls_multi_result) = mo_cut->preview_orders_by_date(
      it_sales_documents = VALUE #( ( '0000004711' ) )
      iv_check_atp       = abap_true
      iv_atp_check_rule  = 'A' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_multi_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Sales-order schedule date is not a valid Gregorian date'
      act = ls_multi_result-messages[ 1 ]-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_stock_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_availability_api->get_check_count( ) ).
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

  METHOD rejects_expired_selected_batch.
    mo_stock_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          expiration_date    = '20261014'
          available_quantity = '2.000' ) ) ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              requested_date     = '20261015'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '2.000' ) ) ) ) ).

    DATA(ls_preview) = mo_cut->preview_order(
      iv_sales_document   = '0000004711'
      it_batch_selections = VALUE #(
        ( item_number   = '000010'
          schedule_line = '0001'
          batch         = 'B-1' ) ) ).
    DATA(ls_result) = mo_cut->reserve_order(
      iv_sales_document          = '0000004711'
      it_batch_selections        = VALUE #(
        ( item_number   = '000010'
          schedule_line = '0001'
          batch         = 'B-1' ) )
      iv_require_full_allocation = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_preview-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_preview-allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( mo_reservation_api->get_requests( ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_result-reservations ) ).
  ENDMETHOD.

  METHOD allows_batch_expiring_on_date.
    mo_stock_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          expiration_date    = '20261015'
          available_quantity = '2.000' ) ) ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
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
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261015'
      act = ls_result-batch_allocations[ 1 ]-as_of_date ).
  ENDMETHOD.

  METHOD applies_batch_minimum.
    mo_stock_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          expiration_date    = '20261022'
          available_quantity = '2.000' ) ) ).
    mo_order_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          items = VALUE #(
            ( item_number        = '000010'
              schedule_line      = '0001'
              requested_date     = '20261015'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '2.000' ) ) ) ) ).

    DATA(ls_boundary) = mo_cut->preview_order(
      iv_sales_document   = '0000004711'
      it_batch_selections = VALUE #(
        ( item_number             = '000010'
          schedule_line           = '0001'
          batch                   = 'B-1'
          minimum_shelf_life_days = 7 ) ) ).
    DATA(ls_short) = mo_cut->preview_order(
      iv_sales_document   = '0000004711'
      it_batch_selections = VALUE #(
        ( item_number             = '000010'
          schedule_line           = '0001'
          batch                   = 'B-1'
          minimum_shelf_life_days = 8 ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_boundary-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_short-allocations[ 1 ]-shortfall_quantity ).

    mo_stock_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          available_quantity = '2.000' ) ) ).
    DATA(ls_unknown) = mo_cut->preview_order(
      iv_sales_document   = '0000004711'
      it_batch_selections = VALUE #(
        ( item_number             = '000010'
          schedule_line           = '0001'
          batch                   = 'B-1'
          minimum_shelf_life_days = 1 ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_unknown-allocations[ 1 ]-shortfall_quantity ).
  ENDMETHOD.

  METHOD rejects_bad_batch_minimum.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_order(
          iv_sales_document   = '0000004711'
          it_batch_selections = VALUE #(
            ( item_number             = '000010'
              batch                   = 'B-1'
              minimum_shelf_life_days = -1 ) ) ).
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

  METHOD rejects_bad_selection_flags.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_order(
          iv_sales_document   = '0000004711'
          it_batch_selections = VALUE #(
            ( item_number    = '000010'
              batch          = 'B-1'
              allow_fallback = 'Y' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repository->get_read_count( ) ).

    CLEAR lv_exception_raised.
    TRY.
        mo_cut->preview_order(
          iv_sales_document      = '0000004711'
          it_location_selections = VALUE #(
            ( item_number      = '000010'
              storage_location = '0001'
              allow_fallback   = 'Y' ) ) ).
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

  METHOD applies_fefo_demand_minimums.
    mo_stock_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-7-DAYS'
          expiration_date    = '20260930'
          available_quantity = '1.000' )
        ( storage_location   = '0001'
          batch              = 'B-12-DAYS'
          expiration_date    = '20261005'
          available_quantity = '1.000' ) ) ).
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
              open_base_quantity = '1.000' )
            ( item_number        = '000010'
              schedule_line      = '0002'
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              requested_date     = '20261008'
              open_base_quantity = '1.000' ) ) ) ) ).

    DATA lt_fefo_minimums TYPE
      zcl_sales_order_alloc_service=>ty_fefo_minimums.
    lt_fefo_minimums = VALUE #(
        ( item_number             = '000010'
          minimum_shelf_life_days = 3 )
        ( item_number             = '000010'
          schedule_line           = '0001'
          minimum_shelf_life_days = 10 ) ).
    DATA(ls_preview) = mo_cut->preview_order(
      iv_sales_document   = '0000004711'
      it_fefo_minimums    = lt_fefo_minimums
      iv_use_fefo_batches = abap_true
      iv_fefo_as_of_date  = '20260923'
      iv_fefo_min_days    = 5 ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_preview-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-12-DAYS'
      act = ls_preview-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_preview-batch_allocations[ 1 ]-minimum_shelf_life_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-7-DAYS'
      act = ls_preview-batch_allocations[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = ls_preview-batch_allocations[ 2 ]-minimum_shelf_life_days ).

    DATA(ls_reserve) = mo_cut->reserve_order(
      iv_sales_document   = '0000004711'
      it_fefo_minimums    = lt_fefo_minimums
      iv_use_fefo_batches = abap_true
      iv_fefo_as_of_date  = '20260923'
      iv_fefo_min_days    = 5 ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_reserve-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-12-DAYS'
      act = lt_requests[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711/000010/0001'
      act = lt_requests[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-7-DAYS'
      act = lt_requests[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711/000010/0002'
      act = lt_requests[ 2 ]-request_id ).
  ENDMETHOD.

  METHOD uses_required_date_for_fefo.
    mo_stock_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-BEFORE'
          expiration_date    = '20261004'
          available_quantity = '2.000' )
        ( storage_location   = '0001'
          batch              = 'B-VALID'
          expiration_date    = '20261006'
          available_quantity = '1.000' ) ) ).
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
              requested_date     = '20261005'
              open_base_quantity = '1.000' ) ) ) ) ).

    DATA(ls_current_date_preview) = mo_cut->preview_order(
      iv_sales_document   = '0000004711'
      iv_use_fefo_batches = abap_true
      iv_fefo_as_of_date  = '20260923' ).
    DATA(ls_required_date_preview) = mo_cut->preview_order(
      iv_sales_document             = '0000004711'
      iv_use_fefo_batches           = abap_true
      iv_fefo_as_of_date            = '20260923'
      iv_use_required_date_for_fefo = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'B-BEFORE'
      act = ls_current_date_preview-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-VALID'
      act = ls_required_date_preview-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261005'
      act = ls_required_date_preview-batch_allocations[ 1 ]-as_of_date ).

    DATA(ls_reserve) = mo_cut->reserve_order(
      iv_sales_document             = '0000004711'
      iv_use_fefo_batches           = abap_true
      iv_fefo_as_of_date            = '20260923'
      iv_use_required_date_for_fefo = abap_true ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_reserve-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-VALID'
      act = lt_requests[ 1 ]-batch ).
  ENDMETHOD.

  METHOD rejects_bad_fefo_date_flag.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_order(
          iv_sales_document             = '0000004711'
          iv_use_required_date_for_fefo = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).

    CLEAR lv_exception_raised.
    TRY.
        mo_cut->preview_order(
          iv_sales_document             = '0000004711'
          iv_use_fefo_batches           = abap_true
          iv_use_required_date_for_fefo = 'Y' ).
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

  METHOD rejects_bad_fefo_minimums.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_order(
          iv_sales_document   = '0000004711'
          iv_use_fefo_batches = abap_true
          it_fefo_minimums    = VALUE #(
            ( item_number             = '000010'
              minimum_shelf_life_days = -1 ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).

    CLEAR lv_exception_raised.
    TRY.
        mo_cut->preview_order(
          iv_sales_document = '0000004711'
          it_fefo_minimums  = VALUE #(
            ( item_number             = '000010'
              minimum_shelf_life_days = 1 ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).

    DATA(ls_duplicate) = mo_cut->preview_order(
      iv_sales_document   = '0000004711'
      iv_use_fefo_batches = abap_true
      it_fefo_minimums    = VALUE #(
        ( item_number             = '000010'
          minimum_shelf_life_days = 1 )
        ( item_number             = '000010'
          minimum_shelf_life_days = 2 ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_duplicate-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_duplicate-messages ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_unknown_fefo_min_key.
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
              open_base_quantity = '1.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->preview_order(
      iv_sales_document   = '0000004711'
      iv_use_fefo_batches = abap_true
      it_fefo_minimums    = VALUE #(
        ( item_number             = '000010'
          schedule_line           = '0002'
          minimum_shelf_life_days = 5 ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-messages ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_result-batch_allocations ) ).
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

  METHOD previews_fefo_batch_filter.
    mo_stock_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-SOON'
          expiration_date    = '20260930'
          available_quantity = '3.000' )
        ( storage_location   = '0001'
          batch              = 'B-LATER'
          expiration_date    = '20261010'
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
              material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              open_base_quantity = '3.000' ) ) ) ) ).

    DATA(ls_result) = mo_cut->preview_order(
      iv_sales_document   = '0000004711'
      it_batch_selections = VALUE #(
        ( item_number = '000010'
          batch       = 'B-LATER' ) )
      iv_use_fefo_batches = abap_true
      iv_fefo_as_of_date  = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-SOON'
      act = ls_result-batch_allocations[ 2 ]-batch ).
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
      exp = 0
      act = mo_stock_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD reserves_schedule_locations.
    mo_stock_repository->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '3.000' )
        ( storage_location   = '0002'
          available_quantity = '2.000' )
        ( storage_location   = '0003'
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
          available_quantity = '2.000' )
        ( storage_location   = '0003'
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

    DATA(ls_preview) = mo_cut->preview_order(
      iv_sales_document            = '0000004711'
      it_location_selections       = VALUE #(
        ( item_number      = '000010'
          storage_location = '0002'
          allow_fallback   = abap_true ) )
      it_location_priority         = VALUE #(
        ( '0003' )
        ( '0001' ) )
      it_allowed_storage_locations = VALUE #(
        ( '0002' )
        ( '0003' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = ls_preview-storage_allocations[ 2 ]-storage_location ).

    DATA(ls_result) = mo_cut->reserve_order(
      iv_sales_document            = '0000004711'
      it_location_selections       = VALUE #(
        ( item_number      = '000010'
          storage_location = '0002'
          allow_fallback   = abap_true ) )
      it_location_priority         = VALUE #(
        ( '0003' )
        ( '0001' ) )
      it_allowed_storage_locations = VALUE #(
        ( '0002' )
        ( '0003' ) ) ).
    DATA(lt_requests) = mo_reservation_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_requests[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_requests[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
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
