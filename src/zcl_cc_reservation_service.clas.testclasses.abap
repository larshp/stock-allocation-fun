CLASS lcl_cc_reservation_read_repo DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_cc_reservation_read_repo.
    METHODS set_reservations
      IMPORTING
        it_reservations TYPE zif_cc_reservation_read_repo=>ty_reservations.
    METHODS get_bulk_read_count
      RETURNING
        VALUE(rv_count) TYPE i.
  PRIVATE SECTION.
    DATA mt_reservations TYPE zif_cc_reservation_read_repo=>ty_reservations.
    DATA mv_single_read_count TYPE i.
    DATA mv_bulk_read_count TYPE i.
ENDCLASS.

CLASS lcl_cc_reservation_read_repo IMPLEMENTATION.
  METHOD set_reservations.
    mt_reservations = it_reservations.
  ENDMETHOD.

  METHOD get_bulk_read_count.
    rv_count = mv_bulk_read_count.
  ENDMETHOD.

  METHOD zif_cc_reservation_read_repo~get_open_reservations.
    ADD 1 TO mv_single_read_count.
    rt_reservations = mt_reservations.
  ENDMETHOD.

  METHOD zif_cc_reservation_read_repo~get_open_reservations_bulk.
    ADD 1 TO mv_bulk_read_count.
    LOOP AT mt_reservations INTO DATA(ls_reservation).
      IF line_exists( it_cost_centers[
          table_line = ls_reservation-cost_center ] ).
        APPEND ls_reservation TO rt_reservations.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_cc_reservation_read_repo~get_reservation_item_scopes.
    RETURN.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_cost_center_stock_repo DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_repository.
    METHODS set_location_stocks
      IMPORTING
        it_stock TYPE zif_stock_repository=>ty_location_stocks.
    METHODS set_batch_stocks
      IMPORTING
        it_stock TYPE zif_stock_repository=>ty_batch_stocks.
    METHODS set_unrestricted_stock
      IMPORTING
        iv_quantity TYPE mard-labst.
    METHODS set_date_available_stock
      IMPORTING
        iv_quantity TYPE mard-labst.
    METHODS get_read_count
      RETURNING
        VALUE(rv_count) TYPE i.
  PRIVATE SECTION.
    DATA mt_location_stock TYPE zif_stock_repository=>ty_location_stocks.
    DATA mt_batch_stock TYPE zif_stock_repository=>ty_batch_stocks.
    DATA mv_unrestricted_stock TYPE mard-labst.
    DATA mv_date_available_stock TYPE mard-labst.
    DATA mv_read_count TYPE i.
ENDCLASS.

CLASS lcl_cost_center_stock_repo IMPLEMENTATION.
  METHOD set_location_stocks.
    mt_location_stock = it_stock.
  ENDMETHOD.

  METHOD set_batch_stocks.
    mt_batch_stock = it_stock.
  ENDMETHOD.

  METHOD set_unrestricted_stock.
    mv_unrestricted_stock = iv_quantity.
  ENDMETHOD.

  METHOD set_date_available_stock.
    mv_date_available_stock = iv_quantity.
  ENDMETHOD.

  METHOD get_read_count.
    rv_count = mv_read_count.
  ENDMETHOD.

  METHOD zif_stock_repository~get_unrestricted_stock.
    ADD 1 TO mv_read_count.
    rv_quantity = mv_unrestricted_stock.
  ENDMETHOD.

  METHOD zif_stock_repository~get_available_stock_by_date.
    ADD 1 TO mv_read_count.
    rv_quantity = mv_date_available_stock.
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
  ENDMETHOD.

  METHOD zif_stock_repository~get_safety_stock_bulk.
    ADD 1 TO mv_read_count.
    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        request_id = ls_request-request_id
        material   = ls_request-material
        plant      = ls_request-plant )
        TO rt_status.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_sales_order_reservations.
    ADD 1 TO mv_read_count.
  ENDMETHOD.

  METHOD zif_stock_repository~get_order_reservations_bulk.
    ADD 1 TO mv_read_count.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status.
    ADD 1 TO mv_read_count.
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
    TYPES ty_create_results TYPE STANDARD TABLE OF
      zif_cc_reservation_api=>ty_result WITH EMPTY KEY.
    TYPES ty_delete_results TYPE STANDARD TABLE OF
      zif_cc_reservation_api=>ty_delete_result WITH EMPTY KEY.
    TYPES ty_commit_results TYPE STANDARD TABLE OF
      zif_cc_reservation_api=>ty_commit_result WITH EMPTY KEY.
    METHODS set_create_result
      IMPORTING
        is_result TYPE zif_cc_reservation_api=>ty_result.
    METHODS set_create_results
      IMPORTING
        it_results TYPE ty_create_results.
    METHODS set_commit_result
      IMPORTING
        is_result TYPE zif_cc_reservation_api=>ty_commit_result.
    METHODS set_commit_results
      IMPORTING
        it_results TYPE ty_commit_results.
    METHODS set_delete_result
      IMPORTING
        is_result TYPE zif_cc_reservation_api=>ty_delete_result.
    METHODS set_delete_results
      IMPORTING
        it_results TYPE ty_delete_results.
    METHODS get_request
      RETURNING
        VALUE(rs_request) TYPE zif_cc_reservation_api=>ty_request.
    METHODS get_request_at
      IMPORTING
        iv_index          TYPE i
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
    METHODS get_delete_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_deleted_numbers
      RETURNING
        VALUE(rt_numbers) TYPE
          zif_cc_reservation_api=>ty_reservation_numbers.
    METHODS get_item_delete_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_deleted_item_numbers
      RETURNING
        VALUE(rt_item_numbers) TYPE
          zif_cc_reservation_api=>ty_reservation_item_numbers.
    METHODS get_item_delete_reservation
      RETURNING
        VALUE(rv_reservation) TYPE
          zif_cc_reservation_api=>ty_reservation_number.
    METHODS was_test_run
      RETURNING
        VALUE(rv_test_run) TYPE abap_bool.
    METHODS was_delete_test_run
      RETURNING
        VALUE(rv_test_run) TYPE abap_bool.
  PRIVATE SECTION.
    DATA ms_create_result TYPE zif_cc_reservation_api=>ty_result.
    DATA mt_create_results TYPE ty_create_results.
    DATA ms_commit_result TYPE zif_cc_reservation_api=>ty_commit_result.
    DATA mt_commit_results TYPE ty_commit_results.
    DATA ms_delete_result TYPE zif_cc_reservation_api=>ty_delete_result.
    DATA mt_delete_results TYPE ty_delete_results.
    DATA mt_deleted_numbers TYPE
      zif_cc_reservation_api=>ty_reservation_numbers.
    DATA mt_deleted_item_numbers TYPE
      zif_cc_reservation_api=>ty_reservation_item_numbers.
    DATA ms_request TYPE zif_cc_reservation_api=>ty_request.
    DATA mt_create_requests TYPE STANDARD TABLE OF
      zif_cc_reservation_api=>ty_request WITH EMPTY KEY.
    DATA mv_create_count TYPE i.
    DATA mv_commit_count TYPE i.
    DATA mv_rollback_count TYPE i.
    DATA mv_test_run TYPE abap_bool.
    DATA mv_delete_count TYPE i.
    DATA mv_item_delete_count TYPE i.
    DATA mv_item_delete_reservation TYPE
      zif_cc_reservation_api=>ty_reservation_number.
    DATA mv_delete_test_run TYPE abap_bool.
ENDCLASS.

CLASS lcl_cost_center_res_api IMPLEMENTATION.
  METHOD set_create_result.
    ms_create_result = is_result.
    CLEAR mt_create_results.
  ENDMETHOD.

  METHOD set_create_results.
    mt_create_results = it_results.
  ENDMETHOD.

  METHOD set_commit_result.
    ms_commit_result = is_result.
    CLEAR mt_commit_results.
  ENDMETHOD.

  METHOD set_commit_results.
    mt_commit_results = it_results.
  ENDMETHOD.

  METHOD set_delete_result.
    ms_delete_result = is_result.
    CLEAR mt_delete_results.
  ENDMETHOD.

  METHOD set_delete_results.
    mt_delete_results = it_results.
  ENDMETHOD.

  METHOD get_request.
    rs_request = ms_request.
  ENDMETHOD.

  METHOD get_request_at.
    READ TABLE mt_create_requests INTO rs_request INDEX iv_index.
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

  METHOD get_item_delete_count.
    rv_count = mv_item_delete_count.
  ENDMETHOD.

  METHOD get_deleted_item_numbers.
    rt_item_numbers = mt_deleted_item_numbers.
  ENDMETHOD.

  METHOD get_item_delete_reservation.
    rv_reservation = mv_item_delete_reservation.
  ENDMETHOD.

  METHOD was_test_run.
    rv_test_run = mv_test_run.
  ENDMETHOD.

  METHOD was_delete_test_run.
    rv_test_run = mv_delete_test_run.
  ENDMETHOD.

  METHOD zif_cc_reservation_api~create_reservation.
    ADD 1 TO mv_create_count.
    ms_request = is_request.
    APPEND is_request TO mt_create_requests.
    mv_test_run = iv_test_run.
    IF mt_create_results IS INITIAL.
      rs_result = ms_create_result.
    ELSE.
      READ TABLE mt_create_results INTO rs_result INDEX mv_create_count.
      IF sy-subrc <> 0.
        rs_result = ms_create_result.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD zif_cc_reservation_api~delete_reservations.
    ADD 1 TO mv_delete_count.
    APPEND LINES OF it_reservation_numbers TO mt_deleted_numbers.
    mv_delete_test_run = iv_test_run.
    IF mt_delete_results IS INITIAL.
      rs_result = ms_delete_result.
    ELSE.
      READ TABLE mt_delete_results INTO rs_result INDEX mv_delete_count.
      IF sy-subrc <> 0.
        rs_result = ms_delete_result.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD zif_cc_reservation_api~delete_reservation_items.
    ADD 1 TO mv_item_delete_count.
    mv_item_delete_reservation = iv_reservation_number.
    mt_deleted_item_numbers = it_item_numbers.
    IF mt_delete_results IS INITIAL.
      rs_result = ms_delete_result.
    ELSE.
      READ TABLE mt_delete_results INTO rs_result INDEX mv_item_delete_count.
      IF sy-subrc <> 0.
        rs_result = ms_delete_result.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD zif_cc_reservation_api~commit.
    ADD 1 TO mv_commit_count.
    IF mt_commit_results IS INITIAL.
      rs_result = ms_commit_result.
    ELSE.
      READ TABLE mt_commit_results INTO rs_result INDEX mv_commit_count.
      IF sy-subrc <> 0.
        rs_result = ms_commit_result.
      ENDIF.
    ENDIF.
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
    DATA mo_reservation_reader TYPE REF TO lcl_cc_reservation_read_repo.
    DATA mo_cut TYPE REF TO zcl_cc_reservation_service.
    METHODS setup.
    METHODS prepare_cc_item_delete.
    METHODS reads_open_cc_reservations FOR TESTING.
    METHODS reads_cc_reservations_bulk FOR TESTING.
    METHODS rejects_bad_cc_bulk_input FOR TESTING.
    METHODS rejects_bad_cc_bulk_rows FOR TESTING.
    METHODS empty_cc_reservations_bulk FOR TESTING.
    METHODS rejects_bad_cc_read_row FOR TESTING.
    METHODS rejects_cc_sum_overflow FOR TESTING.
    METHODS rejects_duplicate_cc_items FOR TESTING.
    METHODS rejects_blank_cc_read FOR TESTING.
    METHODS previews_cost_center_demands FOR TESTING.
    METHODS full_quantity_cc_previews FOR TESTING.
    METHODS rejects_bad_cc_demands FOR TESTING.
    METHODS empty_cc_demands_skip_read FOR TESTING.
    METHODS previews_dated_cc_demands FOR TESTING.
    METHODS rejects_bad_dated_cc_demands FOR TESTING.
    METHODS empty_dated_cc_demands_skip FOR TESTING.
    METHODS previews_dated_cc_atp FOR TESTING.
    METHODS rejects_dated_cc_atp_rule FOR TESTING.
    METHODS previews_cc_locations FOR TESTING.
    METHODS prioritizes_cc_location_ranks FOR TESTING.
    METHODS rejects_bad_cc_locs FOR TESTING.
    METHODS empty_cc_locs_skip_read FOR TESTING.
    METHODS previews_cc_batches FOR TESTING.
    METHODS prioritizes_cc_batches FOR TESTING.
    METHODS prioritizes_cc_batch_ranks FOR TESTING.
    METHODS previews_cc_batch_expiry FOR TESTING.
    METHODS rejects_bad_cc_batches FOR TESTING.
    METHODS empty_cc_batches_skip FOR TESTING.
    METHODS previews_cc_fefo_demands FOR TESTING.
    METHODS prioritizes_cc_fefo FOR TESTING.
    METHODS prioritizes_cc_fefo_ranks FOR TESTING.
    METHODS ranks_dated_cc_fefo FOR TESTING.
    METHODS prioritizes_atomic_cc_fefo FOR TESTING.
    METHODS prioritizes_bulk_cc_fefo FOR TESTING.
    METHODS prioritizes_atomic_cc_batches FOR TESTING.
    METHODS prioritizes_bulk_cc_batches FOR TESTING.
    METHODS previews_cc_fefo_dates FOR TESTING.
    METHODS previews_dated_cc_fefo FOR TESTING.
    METHODS full_qty_cc_fefo_rows FOR TESTING.
    METHODS rejects_bad_cc_fefo FOR TESTING.
    METHODS empty_cc_fefo_skip FOR TESTING.
    METHODS previews_cc_fefo_exact_batch FOR TESTING.
    METHODS filters_undated_cc_fefo FOR TESTING.
    METHODS reserves_cost_centers_atomic FOR TESTING.
    METHODS reserves_atomic_cc_loc_rank FOR TESTING.
    METHODS reserves_cost_centers_bulk FOR TESTING.
    METHODS reserves_bulk_cc_loc_rank FOR TESTING.
    METHODS rejects_bad_cc_atomic_ranks FOR TESTING.
    METHODS rejects_bad_cc_bulk_ranks FOR TESTING.
    METHODS continues_cc_bulk_reserve_fail FOR TESTING.
    METHODS continues_cc_bulk_commit_fail FOR TESTING.
    METHODS simulates_cost_center_bulk FOR TESTING.
    METHODS validates_cost_center_bulk FOR TESTING.
    METHODS empty_cost_center_bulk FOR TESTING.
    METHODS reserves_atomic_cc_batches FOR TESTING.
    METHODS rejects_expired_atomic_batch FOR TESTING.
    METHODS reserves_cc_bulk_by_date FOR TESTING.
    METHODS reserves_cc_atomic_by_date FOR TESTING.
    METHODS reserves_atomic_cc_fefo FOR TESTING.
    METHODS reserves_dated_cc_fefo_atomic FOR TESTING.
    METHODS reserves_cc_fefo_date FOR TESTING.
    METHODS res_dated_fefo_atomic_ranks FOR TESTING.
    METHODS reserves_cc_bulk_fefo_date FOR TESTING.
    METHODS reserves_dated_cc_fefo_bulk FOR TESTING.
    METHODS res_dated_fefo_bulk_ranks FOR TESTING.
    METHODS rejects_short_atomic_batch FOR TESTING.
    METHODS rejects_short_atomic_cc FOR TESTING.
    METHODS rolls_back_atomic_cc_create FOR TESTING.
    METHODS rejects_dupe_atomic_numbers FOR TESTING.
    METHODS rolls_back_atomic_cc_commit FOR TESTING.
    METHODS simulates_atomic_cc FOR TESTING.
    METHODS prechecks_atomic_cc_atp FOR TESTING.
    METHODS rejects_short_atomic_cc_atp FOR TESTING.
    METHODS rejects_atomic_cc_atp_opts FOR TESTING.
    METHODS rejects_bad_atomic_cc FOR TESTING.
    METHODS empty_atomic_cc_demands FOR TESTING.
    METHODS deletes_cc_reservations FOR TESTING.
    METHODS simulates_cc_delete FOR TESTING.
    METHODS rolls_back_cc_delete FOR TESTING.
    METHODS rolls_back_cc_delete_commit FOR TESTING.
    METHODS validates_cc_delete FOR TESTING.
    METHODS deletes_cc_bulk FOR TESTING.
    METHODS deletes_selected_cc_items FOR TESTING.
    METHODS rejects_bad_cc_item_delete FOR TESTING.
    METHODS deletes_cc_items_bulk FOR TESTING.
    METHODS continues_cc_items_failure FOR TESTING.
    METHODS prevalidates_cc_items_bulk FOR TESTING.
    METHODS simulates_cc_items_bulk FOR TESTING.
    METHODS empty_cc_items_bulk FOR TESTING.
    METHODS rejects_unscoped_cc_item FOR TESTING.
    METHODS simulates_cc_item_delete FOR TESTING.
    METHODS rolls_back_cc_item_delete FOR TESTING.
    METHODS rolls_back_cc_item_commit FOR TESTING.
    METHODS continues_cc_bulk_failure FOR TESTING.
    METHODS continues_cc_bulk_commit FOR TESTING.
    METHODS simulates_cc_bulk FOR TESTING.
    METHODS validates_cc_bulk FOR TESTING.
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
    METHODS rejects_short_atp_reservation FOR TESTING.
    METHODS rejects_late_atp_reservation FOR TESTING.
    METHODS reserves_atp_confirmed FOR TESTING.
    METHODS rejects_atp_gate_without_check FOR TESTING.
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
    METHODS rejects_batch_min_no_batch FOR TESTING.
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
    mo_reservation_reader = NEW lcl_cc_reservation_read_repo( ).
    mo_res_api->set_create_result(
      is_result = VALUE #(
        reservation_number = '9000000001'
        is_successful      = abap_true ) ).
    mo_res_api->set_create_results(
      it_results = VALUE #(
        ( reservation_number = '9000000001' is_successful = abap_true )
        ( reservation_number = '9000000002' is_successful = abap_true )
        ( reservation_number = '9000000003' is_successful = abap_true )
        ( reservation_number = '9000000004' is_successful = abap_true )
        ( reservation_number = '9000000005' is_successful = abap_true ) ) ).
    mo_res_api->set_commit_result(
      is_result = VALUE #( is_successful = abap_true ) ).
    mo_cut = NEW zcl_cc_reservation_service(
      io_stock_repository          = mo_stock_repo
      io_reservation_api           = mo_res_api
      io_uom_repository            = mo_uom_repo
      io_material_availability_api = mo_atp_api
      io_reservation_reader        = mo_reservation_reader ).
  ENDMETHOD.

  METHOD prepare_cc_item_delete.
    mo_reservation_reader->set_reservations(
      it_reservations = VALUE #(
        ( cost_center        = 'COST-100'
          reservation_number = '9000000001'
          reservation_item   = '0001'
          material           = 'MAT-1'
          plant              = '1000'
          storage_location   = '0001'
          required_date      = '20261020'
          unit               = 'EA'
          required_quantity  = '5.000'
          withdrawn_quantity = '0.000'
          open_quantity      = '5.000' )
        ( cost_center        = 'COST-100'
          reservation_number = '9000000001'
          reservation_item   = '0002'
          material           = 'MAT-2'
          plant              = '1000'
          storage_location   = '0001'
          required_date      = '20261021'
          unit               = 'EA'
          required_quantity  = '3.000'
          withdrawn_quantity = '0.000'
          open_quantity      = '3.000' )
        ( cost_center        = 'COST-100'
          reservation_number = '9000000002'
          reservation_item   = '0001'
          material           = 'MAT-3'
          plant              = '1000'
          storage_location   = '0001'
          required_date      = '20261022'
          unit               = 'EA'
          required_quantity  = '2.000'
          withdrawn_quantity = '0.000'
          open_quantity      = '2.000' ) ) ).
  ENDMETHOD.

  METHOD reads_open_cc_reservations.
    mo_reservation_reader->set_reservations(
      it_reservations = VALUE #(
        ( cost_center        = 'COST-100'
          reservation_number = '0000004711'
          reservation_item   = '0001'
          material           = 'MAT-1'
          plant              = '1000'
          storage_location   = '0001'
          batch              = 'BATCH-1'
          required_date      = '20261020'
          unit               = 'EA'
          required_quantity  = '5.000'
          withdrawn_quantity = '1.000'
          open_quantity      = '4.000' ) ) ).

    DATA(ls_result) = mo_cut->read_cost_center_reservations(
      iv_cost_center = 'COST-100' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'COST-100'
      act = ls_result-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-reservations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711'
      act = ls_result-reservations[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '4.000' )
      act = ls_result-reservations[ 1 ]-open_quantity ).
  ENDMETHOD.

  METHOD reads_cc_reservations_bulk.
    mo_reservation_reader->set_reservations(
      it_reservations = VALUE #(
        ( cost_center        = 'COST-200'
          reservation_number = '0000004722'
          reservation_item   = '0001'
          material           = 'MAT-2'
          plant              = '2000'
          unit               = 'EA'
          required_quantity  = '6.000'
          withdrawn_quantity = '2.000'
          open_quantity      = '4.000' )
        ( cost_center        = 'COST-100'
          reservation_number = '0000004711'
          reservation_item   = '0001'
          material           = 'MAT-1'
          plant              = '1000'
          unit               = 'EA'
          required_quantity  = '5.000'
          withdrawn_quantity = '1.000'
          open_quantity      = '4.000' ) ) ).

    DATA(ls_result) = mo_cut->read_cc_reservations_bulk(
      it_cost_centers = VALUE #( ( 'COST-100' ) ( 'COST-200' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'COST-100'
      act = ls_result-items[ 1 ]-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711'
      act = ls_result-items[ 1 ]-reservations[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'COST-200'
      act = ls_result-items[ 2 ]-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004722'
      act = ls_result-items[ 2 ]-reservations[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reservation_reader->get_bulk_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_cc_bulk_input.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->read_cc_reservations_bulk(
          it_cost_centers = VALUE #( ( 'COST-100' ) ( 'COST-100' ) ) ).
      CATCH zcx_invalid_reservation.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        mo_cut->read_cc_reservations_bulk(
          it_cost_centers = VALUE #( ( 'COST-100' ) ( space ) ) ).
      CATCH zcx_invalid_reservation.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_reader->get_bulk_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_cc_bulk_rows.
    mo_reservation_reader->set_reservations(
      it_reservations = VALUE #(
        ( cost_center        = 'COST-100'
          reservation_number = '0000004711'
          reservation_item   = '0001'
          material           = 'MAT-1'
          plant              = '1000'
          unit               = 'EA'
          required_quantity  = '5.000'
          withdrawn_quantity = '1.000'
          open_quantity      = '4.000' )
        ( cost_center        = 'COST-100'
          reservation_number = '0000004711'
          reservation_item   = '0001'
          material           = 'MAT-1'
          plant              = '1000'
          unit               = 'EA'
          required_quantity  = '5.000'
          withdrawn_quantity = '1.000'
          open_quantity      = '4.000' ) ) ).

    DATA(ls_result) = mo_cut->read_cc_reservations_bulk(
      it_cost_centers = VALUE #( ( 'COST-100' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-items[ 1 ]-is_successful ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-items[ 1 ]-reservations ).
  ENDMETHOD.

  METHOD empty_cc_reservations_bulk.
    DATA(ls_result) = mo_cut->read_cc_reservations_bulk(
      it_cost_centers = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-items ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reservation_reader->get_bulk_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_cc_sum_overflow.
    mo_reservation_reader->set_reservations(
      it_reservations = VALUE #(
        ( cost_center        = 'COST-100'
          reservation_number = '0000004711'
          reservation_item   = '0001'
          material           = 'MAT-1'
          plant              = '1000'
          unit               = 'EA'
          required_quantity  = '9999999999.999'
          withdrawn_quantity = '9999999999.999'
          open_quantity      = '9999999999.999' ) ) ).

    DATA(ls_result) = mo_cut->read_cost_center_reservations(
      iv_cost_center = 'COST-100' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-reservations ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Cost-center reservation reader returned invalid item data'
      act = ls_result-messages[ 1 ]-message ).
  ENDMETHOD.

  METHOD rejects_bad_cc_read_row.
    mo_reservation_reader->set_reservations(
      it_reservations = VALUE #(
        ( cost_center        = 'COST-200'
          reservation_number = '0000004711'
          reservation_item   = '0001'
          material           = 'MAT-1'
          plant              = '1000'
          unit               = 'EA'
          required_quantity  = '5.000'
          withdrawn_quantity = '1.000'
          open_quantity      = '4.000' ) ) ).

    DATA(ls_result) = mo_cut->read_cost_center_reservations(
      iv_cost_center = 'COST-100' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-reservations ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Cost-center reservation reader returned invalid item data'
      act = ls_result-messages[ 1 ]-message ).
  ENDMETHOD.

  METHOD rejects_blank_cc_read.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->read_cost_center_reservations( iv_cost_center = space ).
      CATCH zcx_invalid_reservation.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
  ENDMETHOD.

  METHOD rejects_duplicate_cc_items.
    mo_reservation_reader->set_reservations(
      it_reservations = VALUE #(
        ( cost_center        = 'COST-100'
          reservation_number = '0000004711'
          reservation_item   = '0001'
          material           = 'MAT-1'
          plant              = '1000'
          unit               = 'EA'
          required_quantity  = '5.000'
          withdrawn_quantity = '1.000'
          open_quantity      = '4.000' )
        ( cost_center        = 'COST-100'
          reservation_number = '0000004711'
          reservation_item   = '0001'
          material           = 'MAT-1'
          plant              = '1000'
          unit               = 'EA'
          required_quantity  = '5.000'
          withdrawn_quantity = '1.000'
          open_quantity      = '4.000' ) ) ).

    DATA(ls_result) = mo_cut->read_cost_center_reservations(
      iv_cost_center = 'COST-100' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-reservations ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Cost-center reservation reader returned duplicate items'
      act = ls_result-messages[ 1 ]-message ).
  ENDMETHOD.

  METHOD previews_cost_center_demands.
    mo_stock_repo->set_unrestricted_stock( iv_quantity = '14.000' ).
    mo_uom_repo->set_alt_unit_ratio(
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lt_previews) = mo_cut->preview_cost_center_demands(
      it_demands = VALUE #(
        ( request_id         = 'CC-1'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          requested_quantity = '4.000'
          unit               = 'EA' )
        ( request_id         = 'CC-2'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          requested_quantity = '1.000'
          unit               = 'BOX' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_previews ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-1'
      act = lt_previews[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_previews[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = lt_previews[ 2 ]-allocation-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lt_previews[ 2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_previews[ 2 ]-allocation-allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_stock_repo->get_read_count( ) ).
    DATA(lt_priority_previews) = mo_cut->preview_cost_center_demands(
      it_demands                = VALUE #(
        ( request_id         = 'CC-PRIO-LOW'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-LOW'
          priority           = 1
          requested_quantity = '10.000'
          unit               = 'EA' )
        ( request_id         = 'CC-PRIO-HIGH'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-HIGH'
          priority           = 10
          requested_quantity = '10.000'
          unit               = 'EA' ) )
      iv_prioritize_by_priority = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-PRIO-LOW'
      act = lt_priority_previews[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lt_priority_previews[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_priority_previews[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-PRIO-HIGH'
      act = lt_priority_previews[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lt_priority_previews[ 2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_stock_repo->get_read_count( ) ).
    DATA(lt_row_full_previews) = mo_cut->preview_cost_center_demands(
      it_demands = VALUE #(
        ( request_id            = 'CC-ROW-FULL'
          material              = 'MAT-1'
          plant                 = '1000'
          cost_center           = 'COST-FULL'
          requested_quantity    = '15.000'
          unit                  = 'EA'
          require_full_quantity = abap_true )
        ( request_id         = 'CC-ROW-PARTIAL'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-PARTIAL'
          requested_quantity = '5.000'
          unit               = 'EA' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_row_full_previews[ 1 ]-require_full_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lt_row_full_previews[ 2 ]-require_full_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_row_full_previews[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '15.000' )
      act = lt_row_full_previews[ 1 ]-allocation-allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lt_row_full_previews[ 2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = mo_stock_repo->get_read_count( ) ).
    mo_atp_api->set_result(
      is_result = VALUE #(
        is_fully_available = abap_true
        is_check_relevant  = abap_true ) ).
    DATA(lt_atp_previews) = mo_cut->preview_cost_center_demands(
      it_demands        = VALUE #(
        ( request_id         = 'CC-ATP-EA'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-300'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'CC-ATP-BOX'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-400'
          requested_quantity = '1.000'
          unit               = 'BOX' ) )
      iv_check_atp      = abap_true
      iv_atp_check_rule = 'A'
      iv_atp_check_date = '20261209' ).

    DATA(ls_atp_request) = mo_atp_api->get_request( ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '13.000' )
      act = ls_atp_request-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261209'
      act = ls_atp_request-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_atp_previews[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '13.000' )
      act = lt_atp_previews[ 1 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = lt_atp_previews[ 1 ]-cumulative_base_quantity
      act = lt_atp_previews[ 2 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '13.000' )
      act = lt_atp_previews[ 2 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_atp_previews[ 2 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_atp_previews[ 2 ]-atp_result-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_atp_api->get_check_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = mo_stock_repo->get_read_count( ) ).
    DATA(lt_priority_atp_previews) = mo_cut->preview_cost_center_demands(
      it_demands                = VALUE #(
        ( request_id         = 'CC-ATP-PRIO-LOW'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-LOW'
          priority           = 1
          requested_quantity = '10.000'
          unit               = 'EA' )
        ( request_id         = 'CC-ATP-PRIO-HIGH'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-HIGH'
          priority           = 10
          requested_quantity = '10.000'
          unit               = 'EA' ) )
      iv_check_atp              = abap_true
      iv_atp_check_rule         = 'A'
      iv_atp_check_date         = '20261210'
      iv_prioritize_by_priority = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_priority_atp_previews[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lt_priority_atp_previews[ 2 ]-allocation-allocation-allocated_quantity ).
    DATA(ls_priority_atp_request) = mo_atp_api->get_request( ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261210'
      act = ls_priority_atp_request-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '14.000' )
      act = lt_priority_atp_previews[ 1 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_atp_api->get_check_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = mo_stock_repo->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_cc_demands.
    DATA lv_duplicate_raised TYPE abap_bool.
    DATA lv_blank_raised TYPE abap_bool.
    DATA lv_flag_raised TYPE abap_bool.
    DATA lv_priority_flag_raised TYPE abap_bool.
    DATA lv_full_quantity_flag_raised TYPE abap_bool.
    DATA lv_atp_date_raised TYPE abap_bool.
    DATA lv_rule_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_cost_center_demands(
          it_demands = VALUE #(
            ( request_id         = 'CC-1'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              requested_quantity = '1.000'
              unit               = 'EA' )
            ( request_id         = 'CC-1'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-200'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_duplicate_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_demands(
          it_demands = VALUE #(
            ( request_id         = 'CC-3'
              plant              = '1000'
              cost_center        = 'COST-100'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_blank_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_demands(
          it_demands              = VALUE #(
            ( request_id         = 'CC-4'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_flag_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_demands(
          it_demands = VALUE #(
            ( request_id            = 'CC-BAD-FULL-FLAG'
              material              = 'MAT-1'
              plant                 = '1000'
              cost_center           = 'COST-100'
              requested_quantity    = '1.000'
              unit                  = 'EA'
              require_full_quantity = 'Y' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_full_quantity_flag_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_demands(
          it_demands                = VALUE #( )
          iv_prioritize_by_priority = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_priority_flag_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_demands(
          it_demands        = VALUE #(
            ( request_id         = 'CC-BAD-ATP-DATE'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          iv_check_atp      = abap_true
          iv_atp_check_rule = 'A'
          iv_atp_check_date = '20261335' ).
      CATCH zcx_invalid_stock_request.
        lv_atp_date_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_demands(
          it_demands   = VALUE #(
            ( request_id         = 'CC-ATP-NO-RULE'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          iv_check_atp = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_rule_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_duplicate_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_blank_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_flag_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_priority_flag_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_full_quantity_flag_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_atp_date_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rule_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD empty_cc_demands_skip_read.
    DATA(lt_previews) = mo_cut->preview_cost_center_demands(
      it_demands = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_previews ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD previews_dated_cc_demands.
    mo_stock_repo->set_date_available_stock( iv_quantity = '14.000' ).
    mo_uom_repo->set_alt_unit_ratio(
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lt_previews) = mo_cut->preview_cost_center_by_date(
      it_demands = VALUE #(
        ( request_id         = 'LATE'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = '20261020'
          priority           = 99
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'EARLY-LOW'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          required_date      = '20261001'
          priority           = 0
          requested_quantity = '1.000'
          unit               = 'BOX' )
        ( request_id         = 'EARLY-HIGH'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-300'
          required_date      = '20261001'
          priority           = 10
          requested_quantity = '4.000'
          unit               = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_previews ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LATE'
      act = lt_previews[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 99
      act = lt_previews[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lt_previews[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = lt_previews[ 3 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_previews[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lt_previews[ 2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_previews[ 3 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = lt_previews[ 2 ]-allocation-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_previews[ 2 ]-allocation-allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_stock_repo->get_read_count( ) ).
    DATA(lt_row_full_previews) = mo_cut->preview_cost_center_by_date(
      it_demands = VALUE #(
        ( request_id            = 'CC-DATE-ROW-FULL'
          material              = 'MAT-1'
          plant                 = '1000'
          cost_center           = 'COST-FULL'
          required_date         = '20261001'
          priority              = 1
          requested_quantity    = '15.000'
          unit                  = 'EA'
          require_full_quantity = abap_true )
        ( request_id         = 'CC-DATE-ROW-PARTIAL'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-PARTIAL'
          required_date      = '20261001'
          priority           = 10
          requested_quantity = '5.000'
          unit               = 'EA' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-DATE-ROW-FULL'
      act = lt_row_full_previews[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_row_full_previews[ 1 ]-require_full_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_row_full_previews[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lt_row_full_previews[ 2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD previews_dated_cc_atp.
    mo_stock_repo->set_date_available_stock( iv_quantity = '20.000' ).
    mo_uom_repo->set_alt_unit_ratio(
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    mo_atp_api->set_result(
      is_result = VALUE #(
        is_fully_available = abap_true
        is_check_relevant  = abap_true ) ).

    DATA(lt_previews) = mo_cut->preview_cost_center_by_date(
      it_demands        = VALUE #(
        ( request_id         = 'ATP-LATER'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = '20261020'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'ATP-BOX'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          required_date      = '20261001'
          priority           = 10
          requested_quantity = '1.000'
          unit               = 'BOX' )
        ( request_id         = 'ATP-EARLY'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-300'
          required_date      = '20261001'
          priority           = 0
          requested_quantity = '1.000'
          unit               = 'EA' ) )
      iv_check_atp      = abap_true
      iv_atp_check_rule = 'A' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_previews ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'ATP-LATER'
      act = lt_previews[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lt_previews[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = lt_previews[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_previews[ 1 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_previews[ 1 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_previews[ 2 ]-atp_result-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_previews[ 2 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_previews[ 3 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_previews[ 2 ]-allocation-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_atp_api->get_check_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_dated_cc_atp_rule.
    DATA lv_flag_raised TYPE abap_bool.
    DATA lv_rule_raised TYPE abap_bool.
    DATA lt_demands TYPE zcl_cc_reservation_service=>ty_dated_preview_demands.
    lt_demands = VALUE #(
        ( request_id         = 'ATP-VALIDATION'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = '20261001'
          requested_quantity = '1.000'
          unit               = 'EA' ) ).

    TRY.
        mo_cut->preview_cost_center_by_date(
          it_demands   = lt_demands
          iv_check_atp = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_flag_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_by_date(
          it_demands   = lt_demands
          iv_check_atp = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_rule_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_flag_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rule_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_atp_api->get_check_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_dated_cc_demands.
    DATA lv_duplicate_raised TYPE abap_bool.
    DATA lv_date_raised TYPE abap_bool.
    DATA lv_flag_raised TYPE abap_bool.
    DATA lv_full_quantity_flag_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_cost_center_by_date(
          it_demands = VALUE #(
            ( request_id         = 'DUP'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              required_date      = '20261001'
              requested_quantity = '1.000'
              unit               = 'EA' )
            ( request_id         = 'DUP'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-200'
              required_date      = '20261002'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_duplicate_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_by_date(
          it_demands = VALUE #(
            ( request_id         = 'NO-DATE'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_date_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_by_date(
          it_demands             = VALUE #(
            ( request_id         = 'BAD-FLAG'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              required_date      = '20261001'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          iv_include_po_receipts = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_flag_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_by_date(
          it_demands = VALUE #(
            ( request_id            = 'BAD-FULL-FLAG'
              material              = 'MAT-1'
              plant                 = '1000'
              cost_center           = 'COST-100'
              required_date         = '20261001'
              requested_quantity    = '1.000'
              unit                  = 'EA'
              require_full_quantity = 'Y' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_full_quantity_flag_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_duplicate_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_date_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_flag_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_full_quantity_flag_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD empty_dated_cc_demands_skip.
    DATA(lt_previews) = mo_cut->preview_cost_center_by_date(
      it_demands = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_previews ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD previews_cc_locations.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '3.000' )
        ( storage_location   = '0002'
          available_quantity = '4.000' )
        ( storage_location   = '0003'
          available_quantity = '3.000' ) ) ).
    mo_uom_repo->set_alt_unit_ratio(
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lt_previews) = mo_cut->preview_cost_center_locations(
      it_demands                   = VALUE #(
        ( request_id         = 'CC-LOC-1'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          storage_location   = '0002'
          requested_quantity = '3.000'
          unit               = 'EA' )
        ( request_id                  = 'CC-LOC-2'
          material                    = 'MAT-1'
          plant                       = '1000'
          cost_center                 = 'COST-200'
          storage_location            = '0002'
          fallback_to_other_locations = abap_true
          requested_quantity          = '2.000'
          unit                        = 'BOX' ) )
      it_location_priority         = VALUE #(
        ( '0003' )
        ( '0001' ) )
      it_allowed_storage_locations = VALUE #(
        ( '0002' )
        ( '0003' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_previews ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-LOC-1'
      act = lt_previews[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_previews[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_previews[ 1 ]-storage_allocations[ 1 ]-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_previews[ 2 ]-allocation-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_previews[ 2 ]-allocation-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_previews[ 2 ]-storage_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_previews[ 2 ]-storage_allocations[ 1 ]-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_previews[ 2 ]-storage_allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = lt_previews[ 2 ]-storage_allocations[ 2 ]-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.500' )
      act = lt_previews[ 2 ]-storage_allocations[ 2 ]-allocated_source_quantity ).
    DATA(lt_scoped_previews) = mo_cut->preview_cost_center_locations(
      it_demands           = VALUE #(
        ( request_id         = 'CC-LOC-SCOPE'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-SCOPE'
          requested_quantity = '2.000'
          unit               = 'EA' ) )
      it_request_locations = VALUE #(
        ( request_id = 'CC-LOC-SCOPE' storage_location = '0001' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_scoped_previews[ 1 ]-storage_allocations[ 1 ]-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_scoped_previews[ 1 ]-request_locations[ 1 ]-storage_location ).
    mo_atp_api->set_result(
      is_result = VALUE #(
        available_at_plant_quantity = '7.000'
        confirmed_quantity          = '5.000'
        confirmation_lines          = VALUE #(
          ( confirmed_date     = sy-datum
            confirmed_quantity = '5.000' ) )
        is_fully_available          = abap_false
        is_check_relevant           = abap_true ) ).
    DATA(lt_atp_previews) = mo_cut->preview_cost_center_locations(
      it_demands                   = VALUE #(
        ( request_id         = 'CC-ATP-LOC-1'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-ATP-1'
          storage_location   = '0002'
          requested_quantity = '3.000'
          unit               = 'EA' )
        ( request_id                  = 'CC-ATP-LOC-2'
          material                    = 'MAT-1'
          plant                       = '1000'
          cost_center                 = 'COST-ATP-2'
          storage_location            = '0002'
          fallback_to_other_locations = abap_true
          requested_quantity          = '2.000'
          unit                        = 'BOX' ) )
      it_location_priority         = VALUE #(
        ( '0003' )
        ( '0001' ) )
      it_allowed_storage_locations = VALUE #(
        ( '0002' )
        ( '0003' ) )
      iv_check_atp                 = abap_true
      iv_atp_check_rule            = 'A'
      iv_atp_check_date            = '20261208' ).
    DATA(ls_atp_request) = mo_atp_api->get_request( ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_atp_api->get_check_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261208'
      act = ls_atp_request-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = ls_atp_request-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = lt_atp_previews[ 1 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = lt_atp_previews[ 1 ]-cumulative_base_quantity
      act = lt_atp_previews[ 2 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lt_atp_previews[ 2 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_atp_previews[ 2 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_atp_previews[ 2 ]-atp_result-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = mo_stock_repo->get_read_count( ) ).
    mo_atp_api->set_result(
      is_result = VALUE #(
        is_fully_available = abap_true
        is_check_relevant  = abap_true ) ).
    DATA(lt_dated_previews) = mo_cut->preview_cc_locations_by_date(
      it_demands            = VALUE #(
        ( request_id            = 'CC-DATE-LOC-LATE'
          material              = 'MAT-1'
          plant                 = '1000'
          cost_center           = 'COST-DATE-LATE'
          required_date         = '20261006'
          requested_quantity    = '2.000'
          unit                  = 'EA'
          require_full_quantity = abap_true )
        ( request_id            = 'CC-DATE-LOC-EARLY'
          material              = 'MAT-1'
          plant                 = '1000'
          cost_center           = 'COST-DATE-EARLY'
          required_date         = '20261005'
          requested_quantity    = '1.000'
          unit                  = 'EA'
          require_full_quantity = abap_false ) )
      it_projected_receipts = VALUE #(
        ( material         = 'MAT-1'
          plant            = '1000'
          storage_location = '0004'
          receipt_date     = '20261005'
          base_quantity    = '1.000' )
        ( material         = 'MAT-1'
          plant            = '1000'
          storage_location = '0004'
          receipt_date     = '20261006'
          base_quantity    = '2.000' ) )
      it_request_locations  = VALUE #(
        ( request_id = 'CC-DATE-LOC-LATE' storage_location = '0004' )
        ( request_id = 'CC-DATE-LOC-EARLY' storage_location = '0004' ) )
      iv_check_atp          = abap_true
      iv_atp_check_rule     = 'A' ).
    DATA(ls_dated_atp_request) = mo_atp_api->get_request( ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = mo_atp_api->get_check_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261006'
      act = ls_dated_atp_request-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_dated_atp_request-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-DATE-LOC-LATE'
      act = lt_dated_previews[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_dated_previews[ 1 ]-require_full_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lt_dated_previews[ 2 ]-require_full_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_dated_previews[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_dated_previews[ 2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0004'
      act = lt_dated_previews[ 1 ]-storage_allocations[
        1 ]-storage_split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_dated_previews[ 1 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_dated_previews[ 2 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_dated_previews[ 1 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0004'
      act = lt_dated_previews[ 1 ]-request_locations[
        1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261005'
      act = lt_dated_previews[ 2 ]-atp_result-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = mo_stock_repo->get_read_count( ) ).
    DATA(lt_priority_previews) = mo_cut->preview_cost_center_locations(
      it_demands                = VALUE #(
        ( request_id         = 'CC-LOC-PRIORITY-LOW'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-LOW'
          storage_location   = '0002'
          priority           = 1
          requested_quantity = '3.000'
          unit               = 'EA' )
        ( request_id         = 'CC-LOC-PRIORITY-HIGH'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-HIGH'
          storage_location   = '0002'
          priority           = 10
          requested_quantity = '3.000'
          unit               = 'EA' ) )
      iv_check_atp              = abap_true
      iv_atp_check_rule         = 'A'
      iv_atp_check_date         = '20261211'
      iv_prioritize_by_priority = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-LOC-PRIORITY-LOW'
      act = lt_priority_previews[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lt_priority_previews[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_priority_previews[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-LOC-PRIORITY-HIGH'
      act = lt_priority_previews[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = lt_priority_previews[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_priority_previews[ 2 ]-allocation-allocation-allocated_quantity ).
    DATA(ls_prio_loc_atp_req) = mo_atp_api->get_request( ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261211'
      act = ls_prio_loc_atp_req-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_priority_previews[ 1 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = mo_atp_api->get_check_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = mo_stock_repo->get_read_count( ) ).
    DATA(lt_row_full_previews) = mo_cut->preview_cost_center_locations(
      it_demands = VALUE #(
        ( request_id            = 'CC-LOC-ROW-FULL'
          material              = 'MAT-1'
          plant                 = '1000'
          cost_center           = 'COST-FULL'
          storage_location      = '0002'
          requested_quantity    = '5.000'
          unit                  = 'EA'
          require_full_quantity = abap_true )
        ( request_id         = 'CC-LOC-ROW-PARTIAL'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-PARTIAL'
          storage_location   = '0002'
          requested_quantity = '2.000'
          unit               = 'EA' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_row_full_previews[ 1 ]-require_full_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lt_row_full_previews[ 2 ]-require_full_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_row_full_previews[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_row_full_previews[ 2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 6
      act = mo_stock_repo->get_read_count( ) ).
    DATA(lv_scope_reads_before_error) = mo_stock_repo->get_read_count( ).
    DATA(lv_invalid_scope_rejected) = abap_false.
    TRY.
        mo_cut->preview_cost_center_locations(
          it_demands           = VALUE #(
            ( request_id         = 'CC-LOC-BAD-SCOPE'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-BAD'
              requested_quantity = '1.000'
              unit               = 'BOX' ) )
          it_request_locations = VALUE #(
            ( request_id = 'CC-LOC-BAD-SCOPE' storage_location = '0001' )
            ( request_id = 'CC-LOC-BAD-SCOPE' storage_location = '0001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_invalid_scope_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_invalid_scope_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_scope_reads_before_error
      act = mo_stock_repo->get_read_count( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD prioritizes_cc_location_ranks.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          available_quantity = '2.000' )
        ( storage_location   = '0003'
          available_quantity = '2.000' ) ) ).

    DATA(lt_previews) = mo_cut->preview_cost_center_locations(
      it_demands                     = VALUE #(
        ( request_id         = 'CC-RANK-1'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          requested_quantity = '2.000'
          unit               = 'EA' )
        ( request_id         = 'CC-RANK-2'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          requested_quantity = '2.000'
          unit               = 'EA' ) )
      it_location_priority           = VALUE #(
        ( '0003' )
        ( '0002' )
        ( '0001' ) )
      it_request_location_priorities = VALUE #(
        ( request_id       = 'CC-RANK-1'
          storage_location = '0002'
          priority_rank    = 1 )
        ( request_id       = 'CC-RANK-1'
          storage_location = '0001'
          priority_rank    = 2 )
        ( request_id       = 'CC-RANK-2'
          storage_location = '0001'
          priority_rank    = 1 )
        ( request_id       = 'CC-RANK-2'
          storage_location = '0002'
          priority_rank    = 2 ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_previews[ 1 ]-storage_allocations[
        1 ]-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_previews[ 2 ]-storage_allocations[
        1 ]-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-RANK-1'
      act = lt_previews[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-RANK-2'
      act = lt_previews[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_cc_locs.
    DATA lv_duplicate_raised TYPE abap_bool.
    DATA lv_flag_raised TYPE abap_bool.
    DATA lv_atp_rule_raised TYPE abap_bool.
    DATA lv_priority_flag_raised TYPE abap_bool.
    DATA lv_atp_date_raised TYPE abap_bool.
    DATA lv_full_quantity_flag_raised TYPE abap_bool.
    DATA lv_dated_atp_rule_raised TYPE abap_bool.
    DATA lv_dated_date_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_cost_center_locations(
          it_demands = VALUE #(
            ( request_id         = 'DUP'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              requested_quantity = '1.000'
              unit               = 'EA' )
            ( request_id         = 'DUP'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-200'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_duplicate_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_locations(
          it_demands = VALUE #(
            ( request_id                  = 'BAD-FLAG'
              material                    = 'MAT-1'
              plant                       = '1000'
              cost_center                 = 'COST-100'
              fallback_to_other_locations = 'Y'
              requested_quantity          = '1.000'
              unit                        = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_flag_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_locations(
          it_demands   = VALUE #(
            ( request_id         = 'BAD-ATP-RULE'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          iv_check_atp = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_atp_rule_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_locations(
          it_demands = VALUE #(
            ( request_id            = 'CC-LOC-BAD-FULL-FLAG'
              material              = 'MAT-1'
              plant                 = '1000'
              cost_center           = 'COST-FULL'
              requested_quantity    = '1.000'
              unit                  = 'EA'
              require_full_quantity = 'Y' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_full_quantity_flag_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_locations(
          it_demands                = VALUE #( )
          iv_prioritize_by_priority = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_priority_flag_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_locations(
          it_demands        = VALUE #(
            ( request_id         = 'CC-LOC-BAD-ATP-DATE'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-DATE'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          iv_check_atp      = abap_true
          iv_atp_check_rule = 'A'
          iv_atp_check_date = '20261335' ).
      CATCH zcx_invalid_stock_request.
        lv_atp_date_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cc_locations_by_date(
          it_demands   = VALUE #(
            ( request_id         = 'CC-DATE-LOC-ATP-NO-RULE'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-DATE'
              required_date      = '20261005'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          iv_check_atp = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_dated_atp_rule_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cc_locations_by_date(
          it_demands = VALUE #(
            ( request_id         = 'CC-DATE-LOC-BAD-DATE'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-DATE'
              required_date      = '20261032'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_dated_date_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_duplicate_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_flag_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_atp_rule_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_priority_flag_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_full_quantity_flag_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_atp_date_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_dated_atp_rule_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_dated_date_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_atp_api->get_check_count( ) ).
  ENDMETHOD.

  METHOD empty_cc_locs_skip_read.
    DATA(lt_previews) = mo_cut->preview_cost_center_locations(
      it_demands = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_previews ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD previews_cc_batches.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'BATCH-1'
          expiration_date    = '20270101'
          available_quantity = '3.000' )
        ( storage_location   = '0002'
          batch              = 'BATCH-1'
          expiration_date    = '20270101'
          available_quantity = '4.000' )
        ( storage_location   = '0003'
          batch              = 'BATCH-1'
          expiration_date    = '20270101'
          available_quantity = '2.000' )
        ( storage_location   = '0001'
          batch              = 'BATCH-2'
          expiration_date    = '20280101'
          available_quantity = '20.000' ) ) ).
    mo_uom_repo->set_alt_unit_ratio(
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lt_previews) = mo_cut->preview_cost_center_batches(
      it_demands           = VALUE #(
        ( request_id         = 'CC-BATCH-1'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          batch              = 'BATCH-1'
          storage_location   = '0002'
          requested_quantity = '3.000'
          unit               = 'EA' )
        ( request_id                  = 'CC-BATCH-2'
          material                    = 'MAT-1'
          plant                       = '1000'
          cost_center                 = 'COST-200'
          batch                       = 'BATCH-1'
          storage_location            = '0002'
          fallback_to_other_locations = abap_true
          requested_quantity          = '2.000'
          unit                        = 'BOX' )
        ( request_id         = 'CC-BATCH-3'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-300'
          batch              = 'BATCH-1'
          requested_quantity = '1.000'
          unit               = 'EA' ) )
      it_location_priority = VALUE #(
        ( '0003' )
        ( '0001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_previews ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-BATCH-1'
      act = lt_previews[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BATCH-1'
      act = lt_previews[ 1 ]-selected_batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_previews[ 1 ]-include_undated_batches ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lt_previews[ 1 ]-minimum_shelf_life_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20270101'
      act = lt_previews[ 1 ]-batch_allocations[ 1 ]-batch_allocation-expiration_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_previews[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_previews[ 2 ]-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_previews[ 2 ]-batch_allocations[ 1 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_previews[ 2 ]-batch_allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = lt_previews[ 2 ]-batch_allocations[ 2 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_previews[ 2 ]-batch_allocations[ 2 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_previews[ 2 ]-batch_allocations[ 3 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_previews[ 2 ]-batch_allocations[ 3 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BATCH-1'
      act = lt_previews[ 3 ]-selected_batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_previews[ 3 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_previews[ 3 ]-allocation-allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_previews[ 3 ]-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_previews[ 3 ]-batch_allocations[ 1 ]-batch_allocation-storage_location ).
    DATA(lt_row_full_previews) = mo_cut->preview_cost_center_batches(
      it_demands = VALUE #(
        ( request_id            = 'CC-BATCH-ROW-FULL'
          material              = 'MAT-1'
          plant                 = '1000'
          cost_center           = 'COST-FULL'
          batch                 = 'BATCH-1'
          requested_quantity    = '10.000'
          unit                  = 'EA'
          require_full_quantity = abap_true )
        ( request_id         = 'CC-BATCH-ROW-PARTIAL'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-PARTIAL'
          batch              = 'BATCH-1'
          requested_quantity = '3.000'
          unit               = 'EA' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_row_full_previews[ 1 ]-require_full_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_row_full_previews[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_row_full_previews[ 2 ]-allocation-allocation-allocated_quantity ).
    DATA(lt_scoped_previews) = mo_cut->preview_cost_center_batches(
      it_demands           = VALUE #(
        ( request_id         = 'CC-BATCH-SCOPE'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-SCOPE'
          batch              = 'BATCH-1'
          requested_quantity = '2.000'
          unit               = 'EA' ) )
      it_request_locations = VALUE #(
        ( request_id = 'CC-BATCH-SCOPE' storage_location = '0001' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_scoped_previews[ 1 ]-batch_allocations[ 1 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_scoped_previews[ 1 ]-request_locations[ 1 ]-storage_location ).
    DATA(lt_projected_previews) = mo_cut->preview_cost_center_batches(
      it_demands                  = VALUE #(
        ( request_id         = 'CC-BATCH-PROJECTED'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-PROJECTED'
          batch              = 'BATCH-1'
          required_date      = '20261020'
          requested_quantity = '2.000'
          unit               = 'EA' ) )
      it_request_locations        = VALUE #(
        ( request_id = 'CC-BATCH-PROJECTED' storage_location = '0004' ) )
      it_projected_batch_receipts = VALUE #(
        ( material         = 'MAT-1'
          plant            = '1000'
          storage_location = '0004'
          batch            = 'BATCH-1'
          expiration_date  = '20270101'
          receipt_date     = '20261020'
          base_quantity    = '2.000' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_projected_previews[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0004'
      act = lt_projected_previews[ 1 ]-batch_allocations[ 1 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0004'
      act = lt_projected_previews[ 1 ]-request_locations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = mo_stock_repo->get_read_count( ) ).
    DATA(lt_date_ordered_previews) = mo_cut->preview_cc_batches_by_date(
      it_demands                  = VALUE #(
        ( request_id         = 'CC-BATCH-DATE-LATE-LOW'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'LATE-LOW'
          batch              = 'BATCH-1'
          storage_location   = '0005'
          required_date      = '20261020'
          priority           = 1
          requested_quantity = '2.000'
          unit               = 'EA' )
        ( request_id         = 'CC-BATCH-DATE-EARLY'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'EARLY'
          batch              = 'BATCH-1'
          storage_location   = '0005'
          required_date      = '20261019'
          priority           = 0
          requested_quantity = '2.000'
          unit               = 'EA' )
        ( request_id         = 'CC-BATCH-DATE-LATE-HIGH'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'LATE-HIGH'
          batch              = 'BATCH-1'
          storage_location   = '0005'
          required_date      = '20261020'
          priority           = 99
          requested_quantity = '2.000'
          unit               = 'EA' ) )
      it_request_locations        = VALUE #(
        ( request_id = 'CC-BATCH-DATE-LATE-LOW' storage_location = '0005' )
        ( request_id = 'CC-BATCH-DATE-EARLY' storage_location = '0005' )
        ( request_id = 'CC-BATCH-DATE-LATE-HIGH' storage_location = '0005' ) )
      it_projected_batch_receipts = VALUE #(
        ( material         = 'MAT-1'
          plant            = '1000'
          storage_location = '0005'
          batch            = 'BATCH-1'
          expiration_date  = '20270101'
          receipt_date     = '20261019'
          base_quantity    = '5.000' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-BATCH-DATE-LATE-LOW'
      act = lt_date_ordered_previews[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261020'
      act = lt_date_ordered_previews[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_date_ordered_previews[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-BATCH-DATE-EARLY'
      act = lt_date_ordered_previews[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261019'
      act = lt_date_ordered_previews[ 2 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_date_ordered_previews[ 2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-BATCH-DATE-LATE-HIGH'
      act = lt_date_ordered_previews[ 3 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261020'
      act = lt_date_ordered_previews[ 3 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_date_ordered_previews[ 3 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = mo_stock_repo->get_read_count( ) ).
    DATA(lv_bad_date_reads_before) = mo_stock_repo->get_read_count( ).
    DATA(lv_bad_date_rejected) = abap_false.
    TRY.
        mo_cut->preview_cc_batches_by_date(
          it_demands = VALUE #(
            ( request_id         = 'CC-BATCH-DATE-INVALID'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-BAD-DATE'
              batch              = 'BATCH-1'
              required_date      = '20260230'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_bad_date_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_date_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_bad_date_reads_before
      act = mo_stock_repo->get_read_count( ) ).
    DATA(lv_scope_reads_before_error) = mo_stock_repo->get_read_count( ).
    DATA(lv_invalid_scope_rejected) = abap_false.
    TRY.
        mo_cut->preview_cost_center_batches(
          it_demands           = VALUE #(
            ( request_id         = 'CC-BATCH-BAD-SCOPE'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-BAD'
              batch              = 'BATCH-1'
              requested_quantity = '1.000'
              unit               = 'BOX' ) )
          it_request_locations = VALUE #(
            ( request_id = 'CC-BATCH-BAD-SCOPE' storage_location = '0001' )
            ( request_id = 'CC-BATCH-BAD-SCOPE' storage_location = '0001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_invalid_scope_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_invalid_scope_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_scope_reads_before_error
      act = mo_stock_repo->get_read_count( ) ).

    mo_atp_api->set_result(
      is_result = VALUE #(
        is_fully_available = abap_true
        is_check_relevant  = abap_true ) ).
    DATA(lt_atp_previews) = mo_cut->preview_cost_center_batches(
      it_demands        = VALUE #(
        ( request_id         = 'CC-BATCH-ATP-EA'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-ATP-1'
          batch              = 'BATCH-1'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'CC-BATCH-ATP-BOX'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-ATP-2'
          batch              = 'BATCH-1'
          requested_quantity = '1.000'
          unit               = 'BOX' ) )
      iv_check_atp      = abap_true
      iv_atp_check_rule = 'A' ).
    DATA(ls_atp_request) = mo_atp_api->get_request( ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_atp_api->get_check_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_atp_request-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = sy-datum
      act = ls_atp_request-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_atp_previews[ 1 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = lt_atp_previews[ 1 ]-cumulative_base_quantity
      act = lt_atp_previews[ 2 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_atp_previews[ 2 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_atp_previews[ 2 ]-atp_result-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).

    DATA(lv_batch_atp_count) =
      mo_atp_api->get_check_count( ).
    DATA(lv_batch_atp_expected) =
      lv_batch_atp_count + 1.
    DATA(lt_date_batch_atp_previews) = mo_cut->preview_cc_batches_by_date(
      it_demands                  = VALUE #(
        ( request_id            = 'CC-BATCH-DATE-ATP-LATE'
          material              = 'MAT-1'
          plant                 = '1000'
          cost_center           = 'DATE-ATP-LATE'
          batch                 = 'BATCH-1'
          storage_location      = '0005'
          required_date         = '20261020'
          priority              = 5
          requested_quantity    = '2.000'
          unit                  = 'EA'
          require_full_quantity = abap_true )
        ( request_id         = 'CC-BATCH-DATE-ATP-EARLY'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'DATE-ATP-EARLY'
          batch              = 'BATCH-1'
          storage_location   = '0005'
          required_date      = '20261019'
          requested_quantity = '2.000'
          unit               = 'EA' ) )
      it_projected_batch_receipts = VALUE #(
        ( material         = 'MAT-1'
          plant            = '1000'
          storage_location = '0005'
          batch            = 'BATCH-1'
          expiration_date  = '20270101'
          receipt_date     = '20261019'
          base_quantity    = '3.000' ) )
      iv_check_atp                = abap_true
      iv_atp_check_rule           = 'A'
      iv_require_full_quantity    = abap_false ).
    DATA(ls_date_batch_atp_request) = mo_atp_api->get_request( ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-BATCH-DATE-ATP-LATE'
      act = lt_date_batch_atp_previews[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_date_batch_atp_previews[ 1 ]-require_full_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_date_batch_atp_previews[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-BATCH-DATE-ATP-EARLY'
      act = lt_date_batch_atp_previews[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_date_batch_atp_previews[ 2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_date_batch_atp_previews[ 2 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261019'
      act = lt_date_batch_atp_previews[ 2 ]-atp_result-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_date_batch_atp_request-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261019'
      act = ls_date_batch_atp_request-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_batch_atp_expected
      act = mo_atp_api->get_check_count( ) ).
  ENDMETHOD.

  METHOD prioritizes_cc_batch_ranks.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-RANK'
          expiration_date    = '20270101'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          batch              = 'B-RANK'
          expiration_date    = '20270101'
          available_quantity = '2.000' )
        ( storage_location   = '0003'
          batch              = 'B-RANK'
          expiration_date    = '20270101'
          available_quantity = '2.000' ) ) ).

    DATA(lt_previews) = mo_cut->preview_cost_center_batches(
      it_demands                     = VALUE #(
        ( request_id         = 'CC-BATCH-RANK-1'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          batch              = 'B-RANK'
          requested_quantity = '2.000'
          unit               = 'EA' )
        ( request_id         = 'CC-BATCH-RANK-2'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          batch              = 'B-RANK'
          requested_quantity = '2.000'
          unit               = 'EA' ) )
      it_location_priority           = VALUE #(
        ( '0003' )
        ( '0001' )
        ( '0002' ) )
      it_request_location_priorities = VALUE #(
        ( request_id       = 'CC-BATCH-RANK-1'
          storage_location = '0002'
          priority_rank    = 1 )
        ( request_id       = 'CC-BATCH-RANK-1'
          storage_location = '0001'
          priority_rank    = 2 )
        ( request_id       = 'CC-BATCH-RANK-2'
          storage_location = '0001'
          priority_rank    = 1 )
        ( request_id       = 'CC-BATCH-RANK-2'
          storage_location = '0002'
          priority_rank    = 2 ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_previews[ 1 ]-batch_allocations[
        1 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_previews[ 2 ]-batch_allocations[
        1 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-BATCH-RANK-1'
      act = lt_previews[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-BATCH-RANK-2'
      act = lt_previews[ 2 ]-request_id ).
  ENDMETHOD.

  METHOD previews_cc_batch_expiry.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-BEFORE'
          expiration_date    = '20261004'
          available_quantity = '1.000' )
        ( storage_location   = '0001'
          batch              = 'B-ON-DATE'
          expiration_date    = '20261005'
          available_quantity = '1.000' )
        ( storage_location   = '0001'
          batch              = 'B-SHORT'
          expiration_date    = '20261007'
          available_quantity = '1.000' ) ) ).

    DATA(ls_expired) = mo_cut->preview_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_cost_center        = 'COST-100'
      iv_batch              = 'B-BEFORE'
      iv_required_date      = '20261005'
      iv_requested_quantity = '1.000'
      iv_unit               = 'EA' ).
    DATA(ls_on_date) = mo_cut->preview_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_cost_center        = 'COST-100'
      iv_batch              = 'B-ON-DATE'
      iv_required_date      = '20261005'
      iv_requested_quantity = '1.000'
      iv_unit               = 'EA' ).
    DATA(ls_short_shelf_life) = mo_cut->preview_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_cost_center        = 'COST-100'
      iv_batch              = 'B-SHORT'
      iv_required_date      = '20261005'
      iv_requested_quantity = '1.000'
      iv_unit               = 'EA'
      iv_batch_min_days     = 3 ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_expired-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_expired-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_on_date-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261005'
      act = ls_on_date-batch_allocations[ 1 ]-as_of_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_short_shelf_life-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_short_shelf_life-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD prioritizes_cc_batches.
    DATA lv_bad_flag_rejected TYPE abap_bool.
    TRY.
        mo_cut->preview_cost_center_batches(
          it_demands                = VALUE #( (
            request_id         = 'CC-BATCH-BAD-FLAG'
            material           = 'MAT-1'
            plant              = '1000'
            cost_center        = 'COST-100'
            batch              = 'B-SHARED'
            requested_quantity = '1.000'
            unit               = 'EA' ) )
          iv_prioritize_by_priority = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_bad_flag_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_flag_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).

    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-SHARED'
          expiration_date    = '20261201'
          available_quantity = '3.000' )
        ( storage_location   = '0002'
          batch              = 'B-SHARED'
          expiration_date    = '20261201'
          available_quantity = '5.000' ) ) ).
    DATA(lt_previews) = mo_cut->preview_cost_center_batches(
      it_demands                = VALUE #(
        ( request_id         = 'CC-BATCH-LOW-FIRST'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-LOW-1'
          batch              = 'B-SHARED'
          required_date      = '20261020'
          requested_quantity = '3.000'
          unit               = 'EA'
          priority           = 2 )
        ( request_id         = 'CC-BATCH-HIGH'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-HIGH'
          batch              = 'B-SHARED'
          required_date      = '20261020'
          requested_quantity = '4.000'
          unit               = 'EA'
          priority           = 10 )
        ( request_id         = 'CC-BATCH-LOW-SECOND'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-LOW-2'
          batch              = 'B-SHARED'
          required_date      = '20261020'
          requested_quantity = '3.000'
          unit               = 'EA'
          priority           = 2 ) )
      iv_prioritize_by_priority = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_previews ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-BATCH-LOW-FIRST'
      act = lt_previews[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lt_previews[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_previews[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_previews[ 1 ]-batch_allocations[
        1 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-BATCH-HIGH'
      act = lt_previews[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = lt_previews[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_previews[ 2 ]-batch_allocations[
        1 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-BATCH-LOW-SECOND'
      act = lt_previews[ 3 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lt_previews[ 3 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_previews[ 3 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_cc_batches.
    DATA lv_duplicate_raised TYPE abap_bool.
    DATA lv_batch_raised TYPE abap_bool.
    DATA lv_flag_raised TYPE abap_bool.
    DATA lv_full_quantity_flag_raised TYPE abap_bool.
    DATA lv_date_raised TYPE abap_bool.
    DATA lv_atp_rule_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_cost_center_batches(
          it_demands = VALUE #(
            ( request_id         = 'DUP-BATCH'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              batch              = 'BATCH-1'
              requested_quantity = '1.000'
              unit               = 'EA' )
            ( request_id         = 'DUP-BATCH'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-200'
              batch              = 'BATCH-2'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_duplicate_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_batches(
          it_demands = VALUE #(
            ( request_id         = 'NO-BATCH'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_batch_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_batches(
          it_demands = VALUE #(
            ( request_id                  = 'BAD-FLAG'
              material                    = 'MAT-1'
              plant                       = '1000'
              cost_center                 = 'COST-100'
              batch                       = 'BATCH-1'
              fallback_to_other_locations = 'Y'
              requested_quantity          = '1.000'
              unit                        = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_flag_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_batches(
          it_demands = VALUE #(
            ( request_id            = 'BAD-FULL-FLAG'
              material              = 'MAT-1'
              plant                 = '1000'
              cost_center           = 'COST-100'
              batch                 = 'BATCH-1'
              requested_quantity    = '1.000'
              unit                  = 'EA'
              require_full_quantity = 'Y' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_full_quantity_flag_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_batches(
          it_demands = VALUE #(
            ( request_id         = 'BAD-DATE'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              batch              = 'BATCH-1'
              required_date      = '20261032'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_date_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_batches(
          it_demands   = VALUE #(
            ( request_id         = 'CC-BATCH-ATP-NO-RULE'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-ATP'
              batch              = 'BATCH-1'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          iv_check_atp = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_atp_rule_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_duplicate_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_batch_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_flag_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_full_quantity_flag_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_date_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_atp_rule_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD empty_cc_batches_skip.
    DATA(lt_previews) = mo_cut->preview_cost_center_batches(
      it_demands = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_previews ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD previews_cc_fefo_demands.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-OLD'
          expiration_date    = '20270101'
          available_quantity = '3.000' )
        ( storage_location   = '0003'
          batch              = 'B-OLD'
          expiration_date    = '20270101'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          batch              = 'B-PREF'
          expiration_date    = '20280101'
          available_quantity = '4.000' )
        ( storage_location   = '0001'
          batch              = 'B-SOON'
          expiration_date    = '20261020'
          available_quantity = '10.000' )
        ( storage_location   = '0003'
          batch              = 'B-LAST'
          expiration_date    = '20290101'
          available_quantity = '2.000' ) ) ).
    mo_uom_repo->set_alt_unit_ratio(
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).

    DATA(lt_previews) = mo_cut->preview_cost_center_fefo(
      it_demands           = VALUE #(
        ( request_id                  = 'FEFO-PREF'
          material                    = 'MAT-1'
          plant                       = '1000'
          cost_center                 = 'COST-100'
          storage_location            = '0002'
          fallback_to_other_locations = abap_true
          requested_quantity          = '5.000'
          unit                        = 'EA' )
        ( request_id         = 'FEFO-HARD'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          storage_location   = '0001'
          requested_quantity = '3.000'
          unit               = 'EA' )
        ( request_id         = 'FEFO-BOX'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-300'
          requested_quantity = '1.000'
          unit               = 'BOX' ) )
      it_location_priority = VALUE #(
        ( '0003' )
        ( '0001' )
        ( '0002' ) )
      iv_as_of_date        = '20261011'
      iv_min_days          = 80 ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_previews ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'FEFO-PREF'
      act = lt_previews[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261011'
      act = lt_previews[ 1 ]-as_of_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 80
      act = lt_previews[ 1 ]-minimum_shelf_life_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-PREF'
      act = lt_previews[ 1 ]-batch_allocations[ 1 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_previews[ 1 ]-batch_allocations[ 1 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-OLD'
      act = lt_previews[ 1 ]-batch_allocations[ 2 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = lt_previews[ 1 ]-batch_allocations[ 2 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lt_previews[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_previews[ 2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_previews[ 2 ]-allocation-allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_previews[ 3 ]-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-OLD'
      act = lt_previews[ 3 ]-batch_allocations[ 1 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = lt_previews[ 3 ]-batch_allocations[ 1 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LAST'
      act = lt_previews[ 3 ]-batch_allocations[ 2 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_previews[ 3 ]-batch_allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_previews[ 3 ]-batch_allocations[ 2 ]-allocated_source_quantity ).
    DATA(lt_strict_previews) = mo_cut->preview_cost_center_fefo(
      it_demands    = VALUE #(
        ( request_id              = 'FEFO-STRICT'
          material                = 'MAT-1'
          plant                   = '1000'
          cost_center             = 'COST-400'
          requested_quantity      = '2.000'
          unit                    = 'EA'
          minimum_shelf_life_days = 500 ) )
      iv_as_of_date = '20261011'
      iv_min_days   = 80 ).
    cl_abap_unit_assert=>assert_equals(
      exp = 500
      act = lt_strict_previews[ 1 ]-minimum_shelf_life_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_strict_previews[ 1 ]-allocation-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LAST'
      act = lt_strict_previews[ 1 ]-batch_allocations[ 1 ]-batch_allocation-batch ).

    DATA(lt_scoped_previews) = mo_cut->preview_cost_center_fefo(
      it_demands           = VALUE #(
        ( request_id         = 'FEFO-SCOPED'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-SCOPE'
          requested_quantity = '3.000'
          unit               = 'EA' ) )
      it_request_locations = VALUE #(
        ( request_id = 'FEFO-SCOPED' storage_location = '0001' ) )
      iv_as_of_date        = '20261011'
      iv_min_days          = 80 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_scoped_previews[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_scoped_previews[ 1 ]-batch_allocations[ 1 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_scoped_previews[ 1 ]-request_locations[ 1 ]-storage_location ).

    DATA(lv_scope_reads_before_error) = mo_stock_repo->get_read_count( ).
    DATA(lv_invalid_scope_rejected) = abap_false.
    TRY.
        mo_cut->preview_cost_center_fefo(
          it_demands           = VALUE #(
            ( request_id         = 'FEFO-BAD-SCOPE'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-BAD'
              requested_quantity = '1.000'
              unit               = 'BOX' ) )
          it_request_locations = VALUE #(
            ( request_id = 'FEFO-BAD-SCOPE' storage_location = '0001' )
            ( request_id = 'FEFO-BAD-SCOPE' storage_location = '0001' ) )
          iv_as_of_date        = '20261011' ).
      CATCH zcx_invalid_stock_request.
        lv_invalid_scope_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_invalid_scope_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_scope_reads_before_error
      act = mo_stock_repo->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = mo_stock_repo->get_read_count( ) ).
    mo_atp_api->set_result(
      is_result = VALUE #(
        is_fully_available = abap_true
        is_check_relevant  = abap_true ) ).
    DATA(lt_atp_previews) = mo_cut->preview_cost_center_fefo(
      it_demands        = VALUE #(
        ( request_id         = 'FEFO-ATP-EA'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-ATP-1'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'FEFO-ATP-BOX'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-ATP-2'
          requested_quantity = '1.000'
          unit               = 'BOX' ) )
      iv_as_of_date     = '20261011'
      iv_check_atp      = abap_true
      iv_atp_check_rule = 'A' ).
    DATA(ls_atp_request) = mo_atp_api->get_request( ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_atp_api->get_check_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_atp_request-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261011'
      act = ls_atp_request-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_atp_previews[ 1 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = lt_atp_previews[ 1 ]-cumulative_base_quantity
      act = lt_atp_previews[ 2 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_atp_previews[ 2 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_atp_previews[ 2 ]-atp_result-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = mo_stock_repo->get_read_count( ) ).
    DATA(lt_projected_fefo_previews) = mo_cut->preview_cost_center_fefo(
      it_demands                  = VALUE #(
        ( request_id         = 'FEFO-PROJECTED'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-PROJECTED'
          batch              = 'B-OLD'
          requested_quantity = '7.000'
          unit               = 'EA' ) )
      it_projected_batch_receipts = VALUE #(
        ( material         = 'MAT-1'
          plant            = '1000'
          storage_location = '0004'
          batch            = 'B-OLD'
          expiration_date  = '20270101'
          receipt_date     = '20261006'
          base_quantity    = '2.000' ) )
      iv_as_of_date               = '20261006' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = lt_projected_fefo_previews[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0004'
      act = lt_projected_fefo_previews[ 1 ]-batch_allocations[ 3 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = mo_stock_repo->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD prioritizes_cc_fefo.
    DATA lv_bad_flag_rejected TYPE abap_bool.
    TRY.
        mo_cut->preview_cost_center_fefo(
          it_demands                = VALUE #(
            ( request_id         = 'CC-FEFO-BAD-FLAG'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          iv_prioritize_by_priority = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_bad_flag_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_flag_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).

    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-EARLY'
          expiration_date    = '20261020'
          available_quantity = '3.000' )
        ( storage_location   = '0002'
          batch              = 'B-LATE'
          expiration_date    = '20261031'
          available_quantity = '5.000' ) ) ).
    DATA(lt_previews) = mo_cut->preview_cost_center_fefo(
      it_demands                = VALUE #(
        ( request_id         = 'CC-FEFO-LOW'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          requested_quantity = '4.000'
          unit               = 'EA'
          priority           = 1 )
        ( request_id         = 'CC-FEFO-HIGH'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          requested_quantity = '4.000'
          unit               = 'EA'
          priority           = 10 ) )
      iv_as_of_date             = '20261011'
      iv_prioritize_by_priority = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_previews ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-FEFO-LOW'
      act = lt_previews[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lt_previews[ 1 ]-priority ).
    DATA(ls_low_split) = lt_previews[ 1 ]-batch_allocations[ 1 ].
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATE'
      act = ls_low_split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_low_split-batch_allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-FEFO-HIGH'
      act = lt_previews[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = lt_previews[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_previews[ 2 ]-batch_allocations ) ).
    DATA(ls_high_first_split) = lt_previews[ 2 ]-batch_allocations[ 1 ].
    DATA(ls_high_second_split) = lt_previews[ 2 ]-batch_allocations[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EARLY'
      act = ls_high_first_split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_high_first_split-batch_allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATE'
      act = ls_high_second_split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_high_second_split-batch_allocation-allocated_quantity ).
  ENDMETHOD.

  METHOD prioritizes_cc_fefo_ranks.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-RANK'
          expiration_date    = '20270101'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          batch              = 'B-RANK'
          expiration_date    = '20270101'
          available_quantity = '2.000' )
        ( storage_location   = '0003'
          batch              = 'B-RANK'
          expiration_date    = '20270101'
          available_quantity = '2.000' ) ) ).

    DATA(lt_previews) = mo_cut->preview_cost_center_fefo(
      it_demands                     = VALUE #(
        ( request_id         = 'CC-FEFO-RANK-1'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          requested_quantity = '2.000'
          unit               = 'EA' )
        ( request_id         = 'CC-FEFO-RANK-2'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          requested_quantity = '2.000'
          unit               = 'EA' ) )
      it_location_priority           = VALUE #(
        ( '0003' )
        ( '0001' )
        ( '0002' ) )
      it_request_location_priorities = VALUE #(
        ( request_id       = 'CC-FEFO-RANK-1'
          storage_location = '0002'
          priority_rank    = 1 )
        ( request_id       = 'CC-FEFO-RANK-1'
          storage_location = '0001'
          priority_rank    = 2 )
        ( request_id       = 'CC-FEFO-RANK-2'
          storage_location = '0001'
          priority_rank    = 1 )
        ( request_id       = 'CC-FEFO-RANK-2'
          storage_location = '0002'
          priority_rank    = 2 ) )
      iv_as_of_date                  = '20261001' ).

    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_previews[ 1 ]-batch_allocations[
        1 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_previews[ 2 ]-batch_allocations[
        1 ]-batch_allocation-storage_location ).
  ENDMETHOD.

  METHOD ranks_dated_cc_fefo.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-RANK'
          expiration_date    = '20270101'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          batch              = 'B-RANK'
          expiration_date    = '20270101'
          available_quantity = '2.000' )
        ( storage_location   = '0003'
          batch              = 'B-RANK'
          expiration_date    = '20270101'
          available_quantity = '2.000' ) ) ).

    DATA(lt_previews) = mo_cut->preview_cost_center_fefo_date(
      it_demands                     = VALUE #(
        ( request_id         = 'CC-DATE-RANK-1'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = '20261201'
          requested_quantity = '2.000'
          unit               = 'EA' )
        ( request_id         = 'CC-DATE-RANK-2'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          required_date      = '20261201'
          requested_quantity = '2.000'
          unit               = 'EA' ) )
      it_location_priority           = VALUE #(
        ( '0003' )
        ( '0001' )
        ( '0002' ) )
      it_request_location_priorities = VALUE #(
        ( request_id       = 'CC-DATE-RANK-1'
          storage_location = '0002'
          priority_rank    = 1 )
        ( request_id       = 'CC-DATE-RANK-1'
          storage_location = '0001'
          priority_rank    = 2 )
        ( request_id       = 'CC-DATE-RANK-2'
          storage_location = '0001'
          priority_rank    = 1 )
        ( request_id       = 'CC-DATE-RANK-2'
          storage_location = '0002'
          priority_rank    = 2 ) )
      iv_as_of_date                  = '20261001' ).

    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_previews[ 1 ]-batch_allocations[
        1 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_previews[ 2 ]-batch_allocations[
        1 ]-batch_allocation-storage_location ).
  ENDMETHOD.

  METHOD previews_cc_fefo_exact_batch.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-EXACT'
          expiration_date    = '20261120'
          available_quantity = '2.000' )
        ( storage_location   = '0001'
          batch              = 'B-LATER'
          expiration_date    = '20270101'
          available_quantity = '10.000' ) ) ).

    DATA(lt_previews) = mo_cut->preview_cost_center_fefo(
      it_demands    = VALUE #(
        ( request_id              = 'CC-FEFO-BATCH'
          material                = 'MAT-1'
          plant                   = '1000'
          cost_center             = 'COST-100'
          batch                   = 'B-EXACT'
          requested_quantity      = '3.000'
          unit                    = 'EA'
          minimum_shelf_life_days = 30 ) )
      iv_as_of_date = '20261015'
      iv_min_days   = 30 ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_previews ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_previews[ 1 ]-allocation-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_previews[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_previews[ 1 ]-allocation-allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_previews[ 1 ]-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EXACT'
      act = lt_previews[ 1 ]-batch_allocations[
        1 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD filters_undated_cc_fefo.
    DATA lv_expiration_date TYPE d.
    lv_expiration_date = sy-datum + 60.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-UNKNOWN'
          available_quantity = '5.000' )
        ( storage_location   = '0001'
          batch              = 'B-DATED'
          expiration_date    = lv_expiration_date
          available_quantity = '4.000' ) ) ).

    DATA(lt_inclusive_preview) = mo_cut->preview_cost_center_fefo(
      it_demands    = VALUE #(
        ( request_id         = 'CC-FEFO-INCLUSIVE'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          requested_quantity = '6.000'
          unit               = 'EA' ) )
      iv_as_of_date = sy-datum ).
    DATA(lt_strict_preview) = mo_cut->preview_cost_center_fefo(
      it_demands                 = VALUE #(
        ( request_id         = 'CC-FEFO-STRICT'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          requested_quantity = '6.000'
          unit               = 'EA' ) )
      iv_as_of_date              = sy-datum
      iv_include_undated_batches = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '9.000' )
      act = lt_inclusive_preview[ 1 ]-allocation-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_strict_preview[ 1 ]-allocation-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_strict_preview[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-DATED'
      act = lt_strict_preview[ 1 ]-batch_allocations[
        1 ]-batch_allocation-batch ).

    DATA(lt_row_allow_fefo) = mo_cut->preview_cost_center_fefo(
      it_demands                 = VALUE #(
        ( request_id            = 'CC-FEFO-ROW-ALLOW'
          material              = 'MAT-1'
          plant                 = '1000'
          cost_center           = 'COST-110'
          requested_quantity    = '8.000'
          unit                  = 'EA'
          allow_undated_batches = abap_true ) )
      iv_as_of_date              = sy-datum
      iv_include_undated_batches = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '9.000' )
      act = lt_row_allow_fefo[ 1 ]-allocation-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_row_allow_fefo[ 1 ]-allocation-allocation-allow_undated_batches ).
    cl_abap_unit_assert=>assert_true(
      act = line_exists( lt_row_allow_fefo[ 1 ]-batch_allocations[
        batch_allocation-batch = 'B-UNKNOWN' ] ) ).

    DATA(lt_row_strict_fefo) = mo_cut->preview_cost_center_fefo(
      it_demands                 = VALUE #(
        ( request_id           = 'CC-FEFO-ROW-STRICT'
          material             = 'MAT-1'
          plant                = '1000'
          cost_center          = 'COST-120'
          requested_quantity   = '6.000'
          unit                 = 'EA'
          require_known_expiry = abap_true ) )
      iv_as_of_date              = sy-datum
      iv_include_undated_batches = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_row_strict_fefo[ 1 ]-allocation-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_row_strict_fefo[ 1 ]-allocation-allocation-require_known_expiry ).

    DATA(lt_dated_row_allow) = mo_cut->preview_cost_center_fefo_date(
      it_demands                 = VALUE #(
        ( request_id            = 'CC-DATED-FEFO-ROW-ALLOW'
          material              = 'MAT-1'
          plant                 = '1000'
          cost_center           = 'COST-130'
          required_date         = sy-datum
          requested_quantity    = '8.000'
          unit                  = 'EA'
          allow_undated_batches = abap_true ) )
      iv_as_of_date              = sy-datum
      iv_include_undated_batches = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_dated_row_allow[ 1 ]-allocation-allocation-allow_undated_batches ).
    cl_abap_unit_assert=>assert_true(
      act = line_exists( lt_dated_row_allow[ 1 ]-batch_allocations[
        batch_allocation-batch = 'B-UNKNOWN' ] ) ).

    DATA(lv_reads_before_policy_error) = mo_stock_repo->get_read_count( ).
    DATA(lv_policy_rejected) = abap_false.
    TRY.
        mo_cut->preview_cost_center_fefo(
          it_demands                 = VALUE #(
            ( request_id            = 'CC-FEFO-CONFLICT'
              material              = 'MAT-1'
              plant                 = '1000'
              cost_center           = 'COST-140'
              requested_quantity    = '1.000'
              unit                  = 'EA'
              require_known_expiry  = abap_true
              allow_undated_batches = abap_true ) )
          iv_as_of_date              = sy-datum
          iv_include_undated_batches = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_policy_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_policy_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_reads_before_policy_error
      act = mo_stock_repo->get_read_count( ) ).

    DATA(lt_exact_batch_preview) = mo_cut->preview_cost_center_batches(
      it_demands                 = VALUE #(
        ( request_id              = 'CC-EXACT-UNKNOWN'
          material                = 'MAT-1'
          plant                   = '1000'
          cost_center             = 'COST-100'
          batch                   = 'B-UNKNOWN'
          required_date           = sy-datum
          minimum_shelf_life_days = 7
          requested_quantity      = '3.000'
          unit                    = 'EA' ) )
      iv_include_undated_batches = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_exact_batch_preview[ 1 ]-allocation-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lt_exact_batch_preview[ 1 ]-include_undated_batches ).
    cl_abap_unit_assert=>assert_equals(
      exp = 7
      act = lt_exact_batch_preview[ 1 ]-minimum_shelf_life_days ).

    DATA(lt_exact_row_allow) = mo_cut->preview_cost_center_batches(
      it_demands                 = VALUE #(
        ( request_id            = 'CC-EXACT-ROW-ALLOW'
          material              = 'MAT-1'
          plant                 = '1000'
          cost_center           = 'COST-150'
          batch                 = 'B-UNKNOWN'
          required_date         = sy-datum
          requested_quantity    = '3.000'
          unit                  = 'EA'
          allow_undated_batches = abap_true ) )
      iv_include_undated_batches = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lt_exact_row_allow[ 1 ]-allocation-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_exact_row_allow[ 1 ]-allocation-allocation-allow_undated_batches ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_exact_row_allow[ 1 ]-include_undated_batches ).

    DATA(lt_atomic_demands) = VALUE
      zcl_cc_reservation_service=>ty_atomic_reservation_demands(
        ( request_id         = 'CC-ATOMIC-STRICT'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = sy-datum
          requested_quantity = '4.000'
          unit               = 'EA' ) ).
    DATA(ls_atomic_result) = mo_cut->reserve_cost_centers_atomic(
      it_demands                 = lt_atomic_demands
      iv_use_fefo_batches        = abap_true
      iv_fefo_as_of_date         = sy-datum
      iv_include_undated_batches = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_atomic_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-DATED'
      act = ls_atomic_result-items[ 1 ]-batch_allocations[
        1 ]-batch_allocation-batch ).

    DATA(ls_bulk_result) = mo_cut->reserve_cost_centers_bulk(
      it_demands                 = VALUE #(
        ( request_id         = 'CC-BULK-STRICT'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = sy-datum
          requested_quantity = '4.000'
          unit               = 'EA' ) )
      iv_use_fefo_batches        = abap_true
      iv_fefo_as_of_date         = sy-datum
      iv_include_undated_batches = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-DATED'
      act = ls_bulk_result-items[ 1 ]-batch_allocations[
        1 ]-batch_allocation-batch ).

    DATA(ls_single_reservation) = mo_cut->reserve_for_cost_center(
      iv_material                = 'MAT-1'
      iv_plant                   = '1000'
      iv_cost_center             = 'COST-100'
      iv_requested_quantity      = '4.000'
      iv_unit                    = 'EA'
      iv_required_date           = sy-datum
      iv_use_fefo_batches        = abap_true
      iv_fefo_as_of_date         = sy-datum
      iv_include_undated_batches = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-DATED'
      act = ls_single_reservation-batch_allocations[ 1 ]-batch ).

    DATA(ls_single_preview) = mo_cut->preview_for_cost_center(
      iv_material                = 'MAT-1'
      iv_plant                   = '1000'
      iv_cost_center             = 'COST-100'
      iv_requested_quantity      = '4.000'
      iv_unit                    = 'EA'
      iv_required_date           = sy-datum
      iv_use_fefo_batches        = abap_true
      iv_fefo_as_of_date         = sy-datum
      iv_include_undated_batches = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-DATED'
      act = ls_single_preview-batch_allocations[ 1 ]-batch ).

    DATA(ls_atomic_row_allow) = mo_cut->reserve_cost_centers_atomic(
      it_demands                 = VALUE #(
        ( request_id            = 'CC-ATOMIC-ROW-ALLOW'
          material              = 'MAT-1'
          plant                 = '1000'
          cost_center           = 'COST-160'
          required_date         = sy-datum
          requested_quantity    = '8.000'
          unit                  = 'EA'
          allow_undated_batches = abap_true ) )
      iv_use_fefo_batches        = abap_true
      iv_fefo_as_of_date         = sy-datum
      iv_include_undated_batches = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_atomic_row_allow-is_successful ).
    cl_abap_unit_assert=>assert_true(
      act = line_exists( ls_atomic_row_allow-items[ 1 ]-batch_allocations[
        batch_allocation-batch = 'B-UNKNOWN' ] ) ).

    DATA(ls_bulk_row_allow) = mo_cut->reserve_cost_centers_bulk(
      it_demands                 = VALUE #(
        ( request_id            = 'CC-BULK-ROW-ALLOW'
          material              = 'MAT-1'
          plant                 = '1000'
          cost_center           = 'COST-170'
          required_date         = sy-datum
          requested_quantity    = '8.000'
          unit                  = 'EA'
          allow_undated_batches = abap_true ) )
      iv_use_fefo_batches        = abap_true
      iv_fefo_as_of_date         = sy-datum
      iv_include_undated_batches = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_bulk_row_allow-items[ 1 ]-is_successful ).
    cl_abap_unit_assert=>assert_true(
      act = line_exists( ls_bulk_row_allow-items[ 1 ]-batch_allocations[
        batch_allocation-batch = 'B-UNKNOWN' ] ) ).

    DATA(ls_single_row_allow) = mo_cut->preview_for_cost_center(
      iv_material                = 'MAT-1'
      iv_plant                   = '1000'
      iv_cost_center             = 'COST-180'
      iv_requested_quantity      = '8.000'
      iv_unit                    = 'EA'
      iv_required_date           = sy-datum
      iv_use_fefo_batches        = abap_true
      iv_fefo_as_of_date         = sy-datum
      iv_include_undated_batches = abap_false
      iv_allow_undated_batches   = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_single_row_allow-allow_undated_batches ).
    cl_abap_unit_assert=>assert_true(
      act = line_exists( ls_single_row_allow-batch_allocations[
        batch = 'B-UNKNOWN' ] ) ).
  ENDMETHOD.

  METHOD full_quantity_cc_previews.
    DATA lv_expiration_date TYPE d.
    lv_expiration_date = sy-datum + 60.

    mo_stock_repo->set_unrestricted_stock( iv_quantity = '5.000' ).
    DATA(lt_general) = mo_cut->preview_cost_center_demands(
      it_demands               = VALUE #(
        ( request_id = 'GENERAL-1' material = 'MAT-1' plant = '1000'
          cost_center = 'COST-100' requested_quantity = '3.000' unit = 'EA' )
        ( request_id = 'GENERAL-2' material = 'MAT-1' plant = '1000'
          cost_center = 'COST-200' requested_quantity = '3.000' unit = 'EA' )
        ( request_id = 'GENERAL-3' material = 'MAT-1' plant = '1000'
          cost_center = 'COST-300' requested_quantity = '2.000' unit = 'EA' ) )
      iv_require_full_quantity = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_general[ 1 ]-require_full_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_general[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_general[ 2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_general[ 3 ]-allocation-allocation-allocated_quantity ).

    mo_stock_repo->set_date_available_stock( iv_quantity = '5.000' ).
    DATA(lt_dated) = mo_cut->preview_cost_center_by_date(
      it_demands               = VALUE #(
        ( request_id = 'DATED-1' material = 'MAT-1' plant = '1000'
          cost_center = 'COST-100' required_date = sy-datum
          requested_quantity = '3.000' unit = 'EA' )
        ( request_id = 'DATED-2' material = 'MAT-1' plant = '1000'
          cost_center = 'COST-200' required_date = sy-datum
          requested_quantity = '3.000' unit = 'EA' )
        ( request_id = 'DATED-3' material = 'MAT-1' plant = '1000'
          cost_center = 'COST-300' required_date = sy-datum
          requested_quantity = '2.000' unit = 'EA' ) )
      iv_require_full_quantity = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_dated[ 1 ]-require_full_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_dated[ 2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_dated[ 3 ]-allocation-allocation-allocated_quantity ).

    mo_atp_api->set_result(
      is_result = VALUE #(
        is_fully_available = abap_true
        is_check_relevant  = abap_true ) ).
    DATA(lt_dated_atp) = mo_cut->preview_cost_center_by_date(
      it_demands               = VALUE #(
        ( request_id = 'DATED-ATP-1' material = 'MAT-1' plant = '1000'
          cost_center = 'COST-100' required_date = sy-datum
          requested_quantity = '3.000' unit = 'EA' )
        ( request_id = 'DATED-ATP-2' material = 'MAT-1' plant = '1000'
          cost_center = 'COST-200' required_date = sy-datum
          requested_quantity = '3.000' unit = 'EA' )
        ( request_id = 'DATED-ATP-3' material = 'MAT-1' plant = '1000'
          cost_center = 'COST-300' required_date = sy-datum
          requested_quantity = '2.000' unit = 'EA' ) )
      iv_require_full_quantity = abap_true
      iv_check_atp             = abap_true
      iv_atp_check_rule        = 'A' ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_dated_atp[ 1 ]-require_full_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_dated_atp[ 2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_dated_atp[ 3 ]-allocation-allocation-allocated_quantity ).

    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location = '0001' available_quantity = '5.000' ) ) ).
    DATA(lt_locations) = mo_cut->preview_cost_center_locations(
      it_demands               = VALUE #(
        ( request_id = 'LOCATION-1' material = 'MAT-1' plant = '1000'
          cost_center = 'COST-100' requested_quantity = '3.000' unit = 'EA' )
        ( request_id = 'LOCATION-2' material = 'MAT-1' plant = '1000'
          cost_center = 'COST-200' requested_quantity = '3.000' unit = 'EA' )
        ( request_id = 'LOCATION-3' material = 'MAT-1' plant = '1000'
          cost_center = 'COST-300' requested_quantity = '2.000' unit = 'EA' ) )
      iv_require_full_quantity = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_locations[ 1 ]-require_full_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_locations[ 2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_locations[ 3 ]-allocation-allocation-allocated_quantity ).

    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'BATCH-1'
          expiration_date    = lv_expiration_date
          available_quantity = '5.000' ) ) ).
    DATA(lt_batches) = mo_cut->preview_cost_center_batches(
      it_demands               = VALUE #(
        ( request_id = 'BATCH-1' material = 'MAT-1' plant = '1000'
          cost_center = 'COST-100' batch = 'BATCH-1'
          requested_quantity = '3.000' unit = 'EA' )
        ( request_id = 'BATCH-2' material = 'MAT-1' plant = '1000'
          cost_center = 'COST-200' batch = 'BATCH-1'
          requested_quantity = '3.000' unit = 'EA' )
        ( request_id = 'BATCH-3' material = 'MAT-1' plant = '1000'
          cost_center = 'COST-300' batch = 'BATCH-1'
          requested_quantity = '2.000' unit = 'EA' ) )
      iv_require_full_quantity = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_batches[ 1 ]-require_full_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_batches[ 2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_batches[ 3 ]-allocation-allocation-allocated_quantity ).

    DATA(lt_fefo) = mo_cut->preview_cost_center_fefo(
      it_demands               = VALUE #(
        ( request_id = 'FEFO-1' material = 'MAT-1' plant = '1000'
          cost_center = 'COST-100' requested_quantity = '3.000' unit = 'EA' )
        ( request_id = 'FEFO-2' material = 'MAT-1' plant = '1000'
          cost_center = 'COST-200' requested_quantity = '3.000' unit = 'EA' )
        ( request_id = 'FEFO-3' material = 'MAT-1' plant = '1000'
          cost_center = 'COST-300' requested_quantity = '2.000' unit = 'EA' ) )
      iv_as_of_date            = sy-datum
      iv_require_full_quantity = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_fefo[ 1 ]-require_full_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_fefo[ 2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_fefo[ 3 ]-allocation-allocation-allocated_quantity ).
  ENDMETHOD.

  METHOD prioritizes_atomic_cc_fefo.
    DATA lv_bad_flag_rejected TYPE abap_bool.
    TRY.
        mo_cut->reserve_cost_centers_atomic(
          it_demands                = VALUE #( (
            request_id         = 'ATOMIC-BAD-PRIORITY'
            material           = 'MAT-1'
            plant              = '1000'
            cost_center        = 'COST-100'
            required_date      = '20261020'
            requested_quantity = '1.000'
            unit               = 'EA' ) )
          iv_prioritize_by_priority = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_bad_flag_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_flag_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).

    CLEAR lv_bad_flag_rejected.
    TRY.
        mo_cut->reserve_cost_centers_atomic(
          it_demands                = VALUE #( (
            request_id         = 'ATOMIC-PRIORITY-NO-FEFO'
            material           = 'MAT-1'
            plant              = '1000'
            cost_center        = 'COST-100'
            required_date      = '20261020'
            requested_quantity = '1.000'
            unit               = 'EA' ) )
          iv_prioritize_by_priority = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_bad_flag_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_flag_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).

    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-EARLY'
          expiration_date    = '20261020'
          available_quantity = '3.000' )
        ( storage_location   = '0002'
          batch              = 'B-LATE'
          expiration_date    = '20261031'
          available_quantity = '5.000' ) ) ).
    DATA(ls_result) = mo_cut->reserve_cost_centers_atomic(
      it_demands                = VALUE #(
        ( request_id         = 'ATOMIC-LOW'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-LOW'
          required_date      = '20261020'
          requested_quantity = '4.000'
          unit               = 'EA'
          priority           = 1 )
        ( request_id         = 'ATOMIC-HIGH'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-HIGH'
          required_date      = '20261020'
          requested_quantity = '4.000'
          unit               = 'EA'
          priority           = 10 ) )
      iv_test_run               = abap_true
      iv_use_fefo_batches       = abap_true
      iv_prioritize_by_priority = abap_true
      iv_fefo_as_of_date        = '20261015' ).
    DATA(ls_first_request) = mo_res_api->get_request_at( iv_index = 1 ).
    DATA(ls_second_request) = mo_res_api->get_request_at( iv_index = 2 ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'ATOMIC-LOW'
      act = ls_result-items[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-items[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATE'
      act = ls_result-items[ 1 ]-batch_allocations[
        1 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'ATOMIC-HIGH'
      act = ls_result-items[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_result-items[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EARLY'
      act = ls_result-items[ 2 ]-batch_allocations[
        1 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '9000000002'
      act = ls_result-items[ 1 ]-reservation_result-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '9000000001'
      act = ls_result-items[ 2 ]-reservation_result-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'COST-HIGH'
      act = ls_first_request-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'COST-LOW'
      act = ls_second_request-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_res_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD prioritizes_bulk_cc_fefo.
    DATA lv_bad_flag_rejected TYPE abap_bool.
    TRY.
        mo_cut->reserve_cost_centers_bulk(
          it_demands                = VALUE #( (
            request_id         = 'BULK-BAD-PRIORITY'
            material           = 'MAT-1'
            plant              = '1000'
            cost_center        = 'COST-100'
            required_date      = '20261020'
            requested_quantity = '1.000'
            unit               = 'EA' ) )
          iv_prioritize_by_priority = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_bad_flag_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_flag_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).

    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-EARLY'
          expiration_date    = '20261020'
          available_quantity = '3.000' )
        ( storage_location   = '0002'
          batch              = 'B-LATE'
          expiration_date    = '20261031'
          available_quantity = '5.000' ) ) ).
    mo_res_api->set_create_results(
      it_results = VALUE #(
        ( reservation_number = '9000000011' is_successful = abap_true )
        ( reservation_number = '9000000012' is_successful = abap_true ) ) ).
    DATA(ls_result) = mo_cut->reserve_cost_centers_bulk(
      it_demands                = VALUE #(
        ( request_id         = 'BULK-LOW'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-LOW'
          required_date      = '20261020'
          requested_quantity = '4.000'
          unit               = 'EA'
          priority           = 1 )
        ( request_id         = 'BULK-HIGH'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-HIGH'
          required_date      = '20261020'
          requested_quantity = '4.000'
          unit               = 'EA'
          priority           = 10 ) )
      iv_test_run               = abap_true
      iv_use_fefo_batches       = abap_true
      iv_prioritize_by_priority = abap_true
      iv_fefo_as_of_date        = '20261015' ).
    DATA(ls_first_request) = mo_res_api->get_request_at( iv_index = 1 ).
    DATA(ls_second_request) = mo_res_api->get_request_at( iv_index = 2 ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BULK-LOW'
      act = ls_result-items[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-items[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BULK-HIGH'
      act = ls_result-items[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_result-items[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = '9000000012'
      act = ls_result-items[ 1 ]-reservation_result-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '9000000011'
      act = ls_result-items[ 2 ]-reservation_result-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'COST-HIGH'
      act = ls_first_request-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'COST-LOW'
      act = ls_second_request-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_res_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD prioritizes_atomic_cc_batches.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-SHARED'
          expiration_date    = '20261201'
          available_quantity = '3.000' )
        ( storage_location   = '0002'
          batch              = 'B-SHARED'
          expiration_date    = '20261201'
          available_quantity = '5.000' ) ) ).
    DATA(ls_result) = mo_cut->reserve_cost_centers_atomic(
      it_demands                = VALUE #(
        ( request_id         = 'ATOMIC-BATCH-LOW'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-LOW'
          batch              = 'B-SHARED'
          required_date      = '20261020'
          requested_quantity = '3.000'
          unit               = 'EA'
          priority           = 2 )
        ( request_id         = 'ATOMIC-BATCH-HIGH'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-HIGH'
          batch              = 'B-SHARED'
          required_date      = '20261020'
          requested_quantity = '4.000'
          unit               = 'EA'
          priority           = 10 ) )
      iv_test_run               = abap_true
      iv_prioritize_by_priority = abap_true ).
    DATA(ls_first_request) = mo_res_api->get_request_at( iv_index = 1 ).
    DATA(ls_second_request) = mo_res_api->get_request_at( iv_index = 2 ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'ATOMIC-BATCH-LOW'
      act = ls_result-items[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-items[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-items[ 1 ]-batch_allocations[
        1 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'ATOMIC-BATCH-HIGH'
      act = ls_result-items[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_result-items[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-items[ 2 ]-batch_allocations[
        1 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'COST-HIGH'
      act = ls_first_request-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'COST-LOW'
      act = ls_second_request-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = '9000000002'
      act = ls_result-items[ 1 ]-reservation_result-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '9000000001'
      act = ls_result-items[ 2 ]-reservation_result-reservation_number ).
  ENDMETHOD.

  METHOD prioritizes_bulk_cc_batches.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-SHARED'
          expiration_date    = '20261201'
          available_quantity = '3.000' )
        ( storage_location   = '0002'
          batch              = 'B-SHARED'
          expiration_date    = '20261201'
          available_quantity = '5.000' ) ) ).
    mo_res_api->set_create_results(
      it_results = VALUE #(
        ( reservation_number = '9000000021' is_successful = abap_true )
        ( reservation_number = '9000000022' is_successful = abap_true ) ) ).
    DATA(ls_result) = mo_cut->reserve_cost_centers_bulk(
      it_demands                = VALUE #(
        ( request_id         = 'BULK-BATCH-LOW'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-LOW'
          batch              = 'B-SHARED'
          required_date      = '20261020'
          requested_quantity = '3.000'
          unit               = 'EA'
          priority           = 2 )
        ( request_id         = 'BULK-BATCH-HIGH'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-HIGH'
          batch              = 'B-SHARED'
          required_date      = '20261020'
          requested_quantity = '4.000'
          unit               = 'EA'
          priority           = 10 ) )
      iv_test_run               = abap_true
      iv_prioritize_by_priority = abap_true ).
    DATA(ls_first_request) = mo_res_api->get_request_at( iv_index = 1 ).
    DATA(ls_second_request) = mo_res_api->get_request_at( iv_index = 2 ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BULK-BATCH-LOW'
      act = ls_result-items[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-items[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BULK-BATCH-HIGH'
      act = ls_result-items[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_result-items[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'COST-HIGH'
      act = ls_first_request-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'COST-LOW'
      act = ls_second_request-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = '9000000022'
      act = ls_result-items[ 1 ]-reservation_result-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '9000000021'
      act = ls_result-items[ 2 ]-reservation_result-reservation_number ).
  ENDMETHOD.

  METHOD previews_cc_fefo_dates.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-BEFORE'
          expiration_date    = '20261004'
          available_quantity = '1.000' )
        ( storage_location   = '0001'
          batch              = 'B-AFTER'
          expiration_date    = '20261006'
          available_quantity = '1.000' )
        ( storage_location   = '0001'
          batch              = 'B-LATER'
          expiration_date    = '20261007'
          available_quantity = '1.000' ) ) ).

    DATA(lt_previews) = mo_cut->preview_cost_center_fefo(
      it_demands    = VALUE #(
        ( request_id         = 'CC-FEFO-DATE'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          requested_quantity = '1.000'
          unit               = 'EA'
          fefo_as_of_date    = '20261005' ) )
      iv_as_of_date = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = '20261005'
      act = lt_previews[ 1 ]-as_of_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-AFTER'
      act = lt_previews[ 1 ]-batch_allocations[
        1 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261005'
      act = lt_previews[ 1 ]-batch_allocations[
        1 ]-batch_allocation-as_of_date ).

    DATA(ls_single_preview) = mo_cut->preview_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '1.000'
      iv_unit               = 'EA'
      iv_required_date      = '20261005'
      iv_use_fefo_batches   = abap_true
      iv_fefo_as_of_date    = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = '20261005'
      act = ls_single_preview-fefo_as_of_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-AFTER'
      act = ls_single_preview-batch_allocations[ 1 ]-batch ).
  ENDMETHOD.

  METHOD previews_dated_cc_fefo.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-EARLY'
          expiration_date    = '20261010'
          available_quantity = '2.000' )
        ( storage_location   = '0001'
          batch              = 'B-LATE'
          expiration_date    = '20261020'
          available_quantity = '3.000' ) ) ).
    mo_uom_repo->set_alt_unit_ratio(
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).

    DATA(lt_previews) = mo_cut->preview_cost_center_fefo_date(
      it_demands           = VALUE #(
        ( request_id         = 'CC-FEFO-LATE'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          requested_quantity = '3.000'
          unit               = 'EA'
          required_date      = '20261012'
          priority           = 99 )
        ( request_id         = 'CC-FEFO-EARLY-LOW'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          requested_quantity = '2.000'
          unit               = 'EA'
          required_date      = '20261005'
          priority           = 1 )
        ( request_id         = 'CC-FEFO-EARLY-HIGH'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-300'
          requested_quantity = '4.000'
          unit               = 'EA'
          required_date      = '20261005'
          priority           = 10 ) )
      it_request_locations = VALUE #(
        ( request_id = 'CC-FEFO-LATE' storage_location = '0001' ) )
      iv_as_of_date        = '20261001' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-FEFO-LATE'
      act = lt_previews[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261012'
      act = lt_previews[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 99
      act = lt_previews[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_previews[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-FEFO-EARLY-LOW'
      act = lt_previews[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_previews[ 2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-FEFO-EARLY-HIGH'
      act = lt_previews[ 3 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_previews[ 3 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EARLY'
      act = lt_previews[ 3 ]-batch_allocations[
        1 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATE'
      act = lt_previews[ 3 ]-batch_allocations[
        2 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261005'
      act = lt_previews[ 3 ]-as_of_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_previews[ 1 ]-request_locations[ 1 ]-storage_location ).
    mo_atp_api->set_result(
      is_result = VALUE #(
        is_fully_available = abap_true
        is_check_relevant  = abap_true ) ).
    DATA(lt_atp_previews) = mo_cut->preview_cost_center_fefo_date(
      it_demands        = VALUE #(
        ( request_id         = 'DATED-FEFO-ATP-BOX'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-ATP-BOX'
          requested_quantity = '1.000'
          unit               = 'BOX'
          required_date      = '20261005'
          priority           = 1 )
        ( request_id         = 'DATED-FEFO-ATP-EA'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-ATP-EA'
          requested_quantity = '1.000'
          unit               = 'EA'
          required_date      = '20261005'
          priority           = 10 ) )
      iv_as_of_date     = '20261001'
      iv_check_atp      = abap_true
      iv_atp_check_rule = 'A' ).
    DATA(ls_atp_request) = mo_atp_api->get_request( ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_atp_api->get_check_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_atp_request-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261005'
      act = ls_atp_request-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'DATED-FEFO-ATP-BOX'
      act = lt_atp_previews[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = lt_atp_previews[ 1 ]-cumulative_base_quantity
      act = lt_atp_previews[ 2 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_atp_previews[ 2 ]-confirmed_base_quantity ).
    DATA(lt_projected_date_previews) = mo_cut->preview_cost_center_fefo_date(
      it_demands                  = VALUE #(
        ( request_id         = 'DATED-FEFO-PROJECTED-LATE'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-PROJECTED-LATE'
          requested_quantity = '2.000'
          unit               = 'EA'
          required_date      = '20261012' )
        ( request_id         = 'DATED-FEFO-PROJECTED-EARLY'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-PROJECTED-EARLY'
          requested_quantity = '6.000'
          unit               = 'EA'
          required_date      = '20261005' ) )
      it_projected_batch_receipts = VALUE #(
        ( material         = 'MAT-1'
          plant            = '1000'
          storage_location = '0002'
          batch            = 'B-RECEIPT'
          expiration_date  = '20261030'
          receipt_date     = '20261006'
          base_quantity    = '2.000' ) )
      iv_as_of_date               = '20261001' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'DATED-FEFO-PROJECTED-LATE'
      act = lt_projected_date_previews[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_projected_date_previews[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-RECEIPT'
      act = lt_projected_date_previews[ 1 ]-batch_allocations[ 1 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261012'
      act = lt_projected_date_previews[ 1 ]-batch_allocations[ 1 ]-batch_allocation-as_of_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lt_projected_date_previews[ 2 ]-allocation-allocation-allocated_quantity ).
  ENDMETHOD.

  METHOD full_qty_cc_fefo_rows.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          expiration_date    = '20261231'
          available_quantity = '5.000' ) ) ).

    DATA(lt_previews) = mo_cut->preview_cost_center_fefo(
      it_demands    = VALUE #(
        ( request_id            = 'FULL'
          material              = 'MAT-1'
          plant                 = '1000'
          cost_center           = 'COST-100'
          requested_quantity    = '6.000'
          require_full_quantity = abap_true
          unit                  = 'EA' )
        ( request_id         = 'PARTIAL'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          requested_quantity = '3.000'
          unit               = 'EA' ) )
      iv_as_of_date = '20261001' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_previews[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_previews[ 2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_previews[ 1 ]-require_full_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_previews[ 2 ]-batch_allocations ) ).

    DATA(lt_dated_previews) = mo_cut->preview_cost_center_fefo_date(
      it_demands    = VALUE #(
        ( request_id            = 'DATED-FULL'
          material              = 'MAT-1'
          plant                 = '1000'
          cost_center           = 'COST-300'
          requested_quantity    = '6.000'
          require_full_quantity = abap_true
          unit                  = 'EA'
          required_date         = '20261005'
          priority              = 10 )
        ( request_id         = 'DATED-PARTIAL'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-400'
          requested_quantity = '3.000'
          unit               = 'EA'
          required_date      = '20261005'
          priority           = 5 ) )
      iv_as_of_date = '20261001' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_dated_previews[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_dated_previews[ 2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_dated_previews[ 1 ]-require_full_quantity ).
  ENDMETHOD.

  METHOD rejects_bad_cc_fefo.
    DATA lv_duplicate_raised TYPE abap_bool.
    DATA lv_flag_raised TYPE abap_bool.
    DATA lv_days_raised TYPE abap_bool.
    DATA lv_demand_days_raised TYPE abap_bool.
    DATA lv_demand_date_raised TYPE abap_bool.
    DATA lv_dated_fefo_date_raised TYPE abap_bool.
    DATA lv_bad_demand_fefo_date_raised TYPE abap_bool.
    DATA lv_atomic_date_raised TYPE abap_bool.
    DATA lv_dated_fefo_bulk_date_raised TYPE abap_bool.
    DATA lv_non_fefo_days_raised TYPE abap_bool.
    DATA lv_full_flag_raised TYPE abap_bool.
    DATA lv_dated_full_flag_raised TYPE abap_bool.
    DATA lv_atp_rule_raised TYPE abap_bool.
    DATA lv_dated_atp_rule_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_cost_center_fefo(
          it_demands = VALUE #(
            ( request_id         = 'DUP-FEFO'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              requested_quantity = '1.000'
              unit               = 'EA' )
            ( request_id         = 'DUP-FEFO'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-200'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_duplicate_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_fefo(
          it_demands = VALUE #(
            ( request_id                  = 'BAD-FEFO-FLAG'
              material                    = 'MAT-1'
              plant                       = '1000'
              cost_center                 = 'COST-100'
              fallback_to_other_locations = 'Y'
              requested_quantity          = '1.000'
              unit                        = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_flag_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_fefo(
          it_demands = VALUE #(
            ( request_id            = 'BAD-FEFO-FULL-FLAG'
              material              = 'MAT-1'
              plant                 = '1000'
              cost_center           = 'COST-100'
              requested_quantity    = '1.000'
              require_full_quantity = 'Y'
              unit                  = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_full_flag_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_fefo_date(
          it_demands = VALUE #(
            ( request_id            = 'BAD-DATED-FEFO-FULL-FLAG'
              material              = 'MAT-1'
              plant                 = '1000'
              cost_center           = 'COST-100'
              requested_quantity    = '1.000'
              require_full_quantity = 'Y'
              unit                  = 'EA'
              required_date         = '20261020' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_dated_full_flag_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_fefo(
          it_demands  = VALUE #( )
          iv_min_days = -1 ).
      CATCH zcx_invalid_stock_request.
        lv_days_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_fefo(
          it_demands = VALUE #(
            ( request_id              = 'BAD-FEFO-DAYS'
              material                = 'MAT-1'
              plant                   = '1000'
              cost_center             = 'COST-100'
              requested_quantity      = '1.000'
              unit                    = 'EA'
              minimum_shelf_life_days = -1 ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_demand_days_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_fefo(
          it_demands = VALUE #(
            ( request_id         = 'BAD-FEFO-DATE'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              requested_quantity = '1.000'
              unit               = 'EA'
              fefo_as_of_date    = '20261032' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_demand_date_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_fefo_date(
          it_demands = VALUE #(
            ( request_id         = 'BAD-FEFO-REQUIRED-DATE'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              requested_quantity = '1.000'
              unit               = 'EA'
              required_date      = '20261340' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_dated_fefo_date_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_fefo_date(
          it_demands = VALUE #(
            ( request_id         = 'BAD-FEFO-AS-OF-DATE'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              requested_quantity = '1.000'
              unit               = 'EA'
              required_date      = '20261020'
              fefo_as_of_date    = '20261032' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_bad_demand_fefo_date_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->reserve_cc_fefo_date_atomic(
          it_demands  = VALUE #(
            ( request_id         = 'BAD-FEFO-RESERVATION-DATE'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              requested_quantity = '1.000'
              unit               = 'EA'
              required_date      = '20261340' ) )
          iv_test_run = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_atomic_date_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->reserve_cc_fefo_date_bulk(
          it_demands  = VALUE #(
            ( request_id         = 'BAD-FEFO-BULK-DATE'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              requested_quantity = '1.000'
              unit               = 'EA'
              required_date      = '20261340' ) )
          iv_test_run = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_dated_fefo_bulk_date_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->reserve_cost_centers_atomic(
          it_demands = VALUE #(
            ( request_id              = 'NON-FEFO-DAYS'
              material                = 'MAT-1'
              plant                   = '1000'
              cost_center             = 'COST-100'
              required_date           = '20261020'
              requested_quantity      = '1.000'
              unit                    = 'EA'
              minimum_shelf_life_days = 1 ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_non_fefo_days_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_fefo(
          it_demands    = VALUE #(
            ( request_id         = 'FEFO-ATP-NO-RULE'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-ATP'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          iv_as_of_date = '20261011'
          iv_check_atp  = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_atp_rule_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_fefo_date(
          it_demands   = VALUE #(
            ( request_id         = 'DATED-FEFO-ATP-NO-RULE'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-ATP'
              requested_quantity = '1.000'
              unit               = 'EA'
              required_date      = '20261005' ) )
          iv_check_atp = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_dated_atp_rule_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_duplicate_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_flag_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_full_flag_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_dated_full_flag_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_days_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_demand_days_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_demand_date_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_dated_fefo_date_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_demand_fefo_date_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_atomic_date_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_dated_fefo_bulk_date_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_non_fefo_days_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_atp_rule_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_dated_atp_rule_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD empty_cc_fefo_skip.
    DATA(lt_previews) = mo_cut->preview_cost_center_fefo(
      it_demands = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_previews ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD reserves_cost_centers_atomic.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '3.000' )
        ( storage_location   = '0002'
          available_quantity = '2.000' )
        ( storage_location   = '0003'
          available_quantity = '2.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_cost_centers_atomic(
      it_demands           = VALUE #(
        ( request_id                  = 'ATOMIC-1'
          material                    = 'MAT-1'
          plant                       = '1000'
          cost_center                 = 'COST-100'
          required_date               = '20261020'
          storage_location            = '0001'
          fallback_to_other_locations = abap_true
          requested_quantity          = '2.000'
          unit                        = 'EA' )
        ( request_id         = 'ATOMIC-2'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          required_date      = '20261022'
          requested_quantity = '3.000'
          unit               = 'EA' ) )
      it_location_priority = VALUE #(
        ( '0003' )
        ( '0002' )
        ( '0001' ) ) ).
    DATA(ls_request) = mo_res_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'ATOMIC-2'
      act = ls_result-items[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'COST-200'
      act = ls_request-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261022'
      act = ls_request-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = ls_request-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_request-items[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_request-items[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_res_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD reserves_atomic_cc_loc_rank.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          available_quantity = '2.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_cost_centers_atomic(
      it_demands                     = VALUE #(
        ( request_id         = 'CC-ATOMIC-RANK-1'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = '20261020'
          requested_quantity = '2.000'
          unit               = 'EA' )
        ( request_id         = 'CC-ATOMIC-RANK-2'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          required_date      = '20261021'
          requested_quantity = '2.000'
          unit               = 'EA' ) )
      it_request_location_priorities = VALUE #(
        ( request_id       = 'CC-ATOMIC-RANK-1'
          storage_location = '0002'
          priority_rank    = 1 )
        ( request_id       = 'CC-ATOMIC-RANK-2'
          storage_location = '0001'
          priority_rank    = 1 ) )
      it_request_locations           = VALUE #(
        ( request_id = 'CC-ATOMIC-RANK-1' storage_location = '0002' )
        ( request_id = 'CC-ATOMIC-RANK-2' storage_location = '0001' ) ) ).
    DATA(ls_first_request) = mo_res_api->get_request_at(
      iv_index = 1 ).
    DATA(ls_second_request) = mo_res_api->get_request_at(
      iv_index = 2 ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_first_request-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_second_request-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-items[ 1 ]-request_locations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_committed ).
  ENDMETHOD.

  METHOD reserves_atomic_cc_batches.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          expiration_date    = '20270101'
          available_quantity = '3.000' )
        ( storage_location   = '0002'
          batch              = 'B-1'
          expiration_date    = '20270101'
          available_quantity = '2.000' )
        ( storage_location   = '0001'
          batch              = 'B-OTHER'
          expiration_date    = '20280101'
          available_quantity = '20.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_cost_centers_atomic(
      it_demands           = VALUE #(
        ( request_id                  = 'BATCH-ATOMIC-1'
          material                    = 'MAT-1'
          plant                       = '1000'
          cost_center                 = 'COST-100'
          batch                       = 'B-1'
          required_date               = '20261020'
          storage_location            = '0001'
          fallback_to_other_locations = abap_true
          requested_quantity          = '2.000'
          unit                        = 'EA' )
        ( request_id         = 'BATCH-ATOMIC-2'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          batch              = 'B-1'
          required_date      = '20261022'
          requested_quantity = '3.000'
          unit               = 'EA' ) )
      it_request_locations = VALUE #(
        ( request_id = 'BATCH-ATOMIC-1' storage_location = '0001' )
        ( request_id = 'BATCH-ATOMIC-2' storage_location = '0001' )
        ( request_id = 'BATCH-ATOMIC-2' storage_location = '0002' ) ) ).
    DATA(ls_request) = mo_res_api->get_request( ).
    DATA(ls_selected_batch) =
      ls_result-items[ 2 ]-batch_allocations[ 1 ]-batch_allocation.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-items[ 1 ]-request_locations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-items[ 2 ]-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_selected_batch-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_request-items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_request-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_request-items[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_request-items[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_expired_atomic_batch.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-EXPIRED'
          expiration_date    = '20261004'
          available_quantity = '10.000' )
        ( storage_location   = '0001'
          batch              = 'B-SHORT'
          expiration_date    = '20261007'
          available_quantity = '10.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_cost_centers_atomic(
      it_demands = VALUE #(
        ( request_id         = 'EXPIRED-BATCH'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          batch              = 'B-EXPIRED'
          required_date      = '20261005'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id              = 'SHORT-LIFE-BATCH'
          material                = 'MAT-1'
          plant                   = '1000'
          cost_center             = 'COST-200'
          batch                   = 'B-SHORT'
          required_date           = '20261005'
          requested_quantity      = '1.000'
          unit                    = 'EA'
          minimum_shelf_life_days = 3 ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-items[ 1 ]-allocation-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-items[ 1 ]-allocation-allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-items[ 2 ]-allocation-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-items[ 2 ]-allocation-allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = ls_result-items[ 2 ]-minimum_shelf_life_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD reserves_cc_atomic_by_date.
    DATA(ls_result) = mo_cut->reserve_cc_atomic_by_date(
      it_demands = VALUE #(
        ( request_id         = 'CC-ATOMIC-DATE-LATE-LOW'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'LATE-LOW'
          storage_location   = '0001'
          required_date      = '20261020'
          priority           = 1
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'CC-ATOMIC-DATE-EARLY'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'EARLY'
          storage_location   = '0001'
          required_date      = '20261019'
          priority           = 0
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'CC-ATOMIC-DATE-LATE-HIGH'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'LATE-HIGH'
          storage_location   = '0001'
          required_date      = '20261020'
          priority           = 99
          requested_quantity = '1.000'
          unit               = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-ATOMIC-DATE-LATE-LOW'
      act = ls_result-items[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261020'
      act = ls_result-items[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-ATOMIC-DATE-EARLY'
      act = ls_result-items[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-ATOMIC-DATE-LATE-HIGH'
      act = ls_result-items[ 3 ]-request_id ).

    DATA(ls_first_request) = mo_res_api->get_request_at( iv_index = 1 ).
    DATA(ls_second_request) = mo_res_api->get_request_at( iv_index = 2 ).
    DATA(ls_third_request) = mo_res_api->get_request_at( iv_index = 3 ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY'
      act = ls_first_request-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261019'
      act = ls_first_request-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LATE-HIGH'
      act = ls_second_request-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261020'
      act = ls_second_request-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LATE-LOW'
      act = ls_third_request-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261020'
      act = ls_third_request-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = mo_res_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_commit_count( ) ).

    DATA(lv_bad_date_reads_before) = mo_stock_repo->get_read_count( ).
    DATA(lv_bad_date_rejected) = abap_false.
    TRY.
        mo_cut->reserve_cc_atomic_by_date(
          it_demands = VALUE #(
            ( request_id         = 'CC-ATOMIC-DATE-INVALID'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'BAD-DATE'
              storage_location   = '0001'
              required_date      = '20260230'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_bad_date_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_date_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_bad_date_reads_before
      act = mo_stock_repo->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD reserves_cc_bulk_by_date.
    DATA(ls_result) = mo_cut->reserve_cc_bulk_by_date(
      it_demands = VALUE #(
        ( request_id         = 'CC-BULK-DATE-LATE-LOW'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'LATE-LOW'
          storage_location   = '0001'
          required_date      = '20261020'
          priority           = 1
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'CC-BULK-DATE-EARLY'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'EARLY'
          storage_location   = '0001'
          required_date      = '20261019'
          priority           = 0
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'CC-BULK-DATE-LATE-HIGH'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'LATE-HIGH'
          storage_location   = '0001'
          required_date      = '20261020'
          priority           = 99
          requested_quantity = '1.000'
          unit               = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-BULK-DATE-LATE-LOW'
      act = ls_result-items[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-BULK-DATE-EARLY'
      act = ls_result-items[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-BULK-DATE-LATE-HIGH'
      act = ls_result-items[ 3 ]-request_id ).

    DATA(ls_first_request) = mo_res_api->get_request_at( iv_index = 1 ).
    DATA(ls_second_request) = mo_res_api->get_request_at( iv_index = 2 ).
    DATA(ls_third_request) = mo_res_api->get_request_at( iv_index = 3 ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY'
      act = ls_first_request-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261019'
      act = ls_first_request-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LATE-HIGH'
      act = ls_second_request-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261020'
      act = ls_second_request-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LATE-LOW'
      act = ls_third_request-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261020'
      act = ls_third_request-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = mo_res_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = mo_res_api->get_commit_count( ) ).

    DATA(lv_bad_date_reads_before) = mo_stock_repo->get_read_count( ).
    DATA(lv_bad_date_rejected) = abap_false.
    TRY.
        mo_cut->reserve_cc_bulk_by_date(
          it_demands = VALUE #(
            ( request_id         = 'CC-BULK-DATE-INVALID'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'BAD-DATE'
              storage_location   = '0001'
              required_date      = '20260230'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_bad_date_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_date_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_bad_date_reads_before
      act = mo_stock_repo->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD reserves_atomic_cc_fefo.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-OLD'
          expiration_date    = '20270101'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          batch              = 'B-LATE'
          expiration_date    = '20280101'
          available_quantity = '5.000' )
        ( storage_location   = '0001'
          batch              = 'B-ALT'
          expiration_date    = '20270201'
          available_quantity = '3.000' )
        ( storage_location   = '0001'
          batch              = 'B-SOON'
          expiration_date    = '20261020'
          available_quantity = '9.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_cost_centers_atomic(
      it_demands           = VALUE #(
        ( request_id              = 'FEFO-ATOMIC-1'
          material                = 'MAT-1'
          plant                   = '1000'
          cost_center             = 'COST-100'
          batch                   = 'B-LATE'
          required_date           = '20261020'
          requested_quantity      = '2.000'
          unit                    = 'EA'
          minimum_shelf_life_days = 100 )
        ( request_id         = 'FEFO-ATOMIC-2'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          required_date      = '20261022'
          requested_quantity = '3.000'
          unit               = 'EA' ) )
      iv_use_fefo_batches  = abap_true
      iv_fefo_as_of_date   = '20261011'
      iv_fefo_min_days     = 80
      it_request_locations = VALUE #(
        ( request_id = 'FEFO-ATOMIC-1' storage_location = '0002' )
        ( request_id = 'FEFO-ATOMIC-2' storage_location = '0001' ) ) ).
    DATA(ls_first_request) = mo_res_api->get_request_at(
      iv_index = 1 ).
    DATA(ls_second_request) = mo_res_api->get_request_at(
      iv_index = 2 ).
    DATA(ls_first_fefo_split) =
      ls_result-items[ 1 ]-batch_allocations[ 1 ]-batch_allocation.
    DATA(ls_second_fefo_split) =
      ls_result-items[ 2 ]-batch_allocations[ 1 ]-batch_allocation.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261020'
      act = ls_result-items[ 1 ]-fefo_as_of_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 100
      act = ls_result-items[ 1 ]-minimum_shelf_life_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATE'
      act = ls_first_fefo_split-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-ALT'
      act = ls_second_fefo_split-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-items[ 1 ]-request_locations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-items[ 2 ]-request_locations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261022'
      act = ls_result-items[ 2 ]-fefo_as_of_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATE'
      act = ls_first_request-items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-ALT'
      act = ls_second_request-items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_first_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_first_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_second_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_res_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD reserves_dated_cc_fefo_atomic.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-EARLY'
          expiration_date    = '20261010'
          available_quantity = '2.000' )
        ( storage_location   = '0001'
          batch              = 'B-LATE'
          expiration_date    = '20261020'
          available_quantity = '3.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_cc_fefo_date_atomic(
      it_demands         = VALUE #(
        ( request_id         = 'DATED-LATE'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'CC-LATE'
          requested_quantity = '1.000'
          unit               = 'EA'
          required_date      = '20261012'
          priority           = 99 )
        ( request_id         = 'DATED-EARLY-LOW'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'CC-EARLY-L'
          requested_quantity = '1.000'
          unit               = 'EA'
          required_date      = '20261005'
          priority           = 1 )
        ( request_id         = 'DATED-EARLY-HIGH'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'CC-EARLY-H'
          requested_quantity = '3.000'
          unit               = 'EA'
          required_date      = '20261005'
          priority           = 10 ) )
      iv_test_run        = abap_true
      iv_fefo_as_of_date = '20261001' ).
    DATA(ls_first_request) = mo_res_api->get_request_at(
      iv_index = 1 ).
    DATA(ls_second_request) = mo_res_api->get_request_at(
      iv_index = 2 ).
    DATA(ls_third_request) = mo_res_api->get_request_at(
      iv_index = 3 ).
    DATA(ls_high_batch_split) =
      ls_result-items[ 3 ]-batch_allocations[ 1 ]-batch_allocation.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'DATED-LATE'
      act = ls_result-items[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'DATED-EARLY-LOW'
      act = ls_result-items[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'DATED-EARLY-HIGH'
      act = ls_result-items[ 3 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261005'
      act = ls_result-items[ 3 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_result-items[ 3 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_high_batch_split-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EARLY'
      act = ls_high_batch_split-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-EARLY-H'
      act = ls_first_request-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-EARLY-L'
      act = ls_second_request-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-LATE'
      act = ls_third_request-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = mo_res_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD res_dated_fefo_atomic_ranks.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-RANK'
          expiration_date    = '20270101'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          batch              = 'B-RANK'
          expiration_date    = '20270101'
          available_quantity = '2.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_cc_fefo_date_atomic(
      it_demands                     = VALUE #(
        ( request_id         = 'CC-DATE-ATOMIC-1'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = '20261202'
          requested_quantity = '2.000'
          unit               = 'EA' )
        ( request_id         = 'CC-DATE-ATOMIC-2'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          required_date      = '20261201'
          requested_quantity = '2.000'
          unit               = 'EA' ) )
      iv_fefo_as_of_date             = '20261001'
      it_request_location_priorities = VALUE #(
        ( request_id       = 'CC-DATE-ATOMIC-1'
          storage_location = '0002'
          priority_rank    = 1 )
        ( request_id       = 'CC-DATE-ATOMIC-2'
          storage_location = '0001'
          priority_rank    = 1 ) )
      it_request_locations           = VALUE #(
        ( request_id = 'CC-DATE-ATOMIC-1' storage_location = '0002' )
        ( request_id = 'CC-DATE-ATOMIC-2' storage_location = '0001' ) ) ).
    DATA(ls_first_request) = mo_res_api->get_request_at(
      iv_index = 1 ).
    DATA(ls_second_request) = mo_res_api->get_request_at(
      iv_index = 2 ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'COST-200'
      act = ls_first_request-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_first_request-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'COST-100'
      act = ls_second_request-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_second_request-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-items[ 1 ]-request_locations[ 1 ]-storage_location ).
  ENDMETHOD.

  METHOD reserves_cc_fefo_date.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-BEFORE'
          expiration_date    = '20261004'
          available_quantity = '1.000' )
        ( storage_location   = '0001'
          batch              = 'B-AFTER'
          expiration_date    = '20261006'
          available_quantity = '1.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_cost_centers_atomic(
      it_demands          = VALUE #(
        ( request_id         = 'CC-FEFO-DATE'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = '20261005'
          fefo_as_of_date    = '20261003'
          requested_quantity = '1.000'
          unit               = 'EA' ) )
      iv_use_fefo_batches = abap_true
      iv_fefo_as_of_date  = '20260923' ).
    DATA(ls_request) = mo_res_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261005'
      act = ls_result-items[ 1 ]-fefo_as_of_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-AFTER'
      act = ls_result-items[ 1 ]-batch_allocations[
        1 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261005'
      act = ls_result-items[ 1 ]-batch_allocations[
        1 ]-batch_allocation-as_of_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-AFTER'
      act = ls_request-items[ 1 ]-batch ).
  ENDMETHOD.

  METHOD res_dated_fefo_bulk_ranks.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-RANK'
          expiration_date    = '20270101'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          batch              = 'B-RANK'
          expiration_date    = '20270101'
          available_quantity = '2.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_cc_fefo_date_bulk(
      it_demands                     = VALUE #(
        ( request_id         = 'CC-DATE-BULK-1'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = '20261202'
          requested_quantity = '2.000'
          unit               = 'EA' )
        ( request_id         = 'CC-DATE-BULK-2'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          required_date      = '20261201'
          requested_quantity = '2.000'
          unit               = 'EA' ) )
      iv_fefo_as_of_date             = '20261001'
      it_request_location_priorities = VALUE #(
        ( request_id       = 'CC-DATE-BULK-1'
          storage_location = '0002'
          priority_rank    = 1 )
        ( request_id       = 'CC-DATE-BULK-2'
          storage_location = '0001'
          priority_rank    = 1 ) )
      it_request_locations           = VALUE #(
        ( request_id = 'CC-DATE-BULK-1' storage_location = '0002' )
        ( request_id = 'CC-DATE-BULK-2' storage_location = '0001' ) ) ).
    DATA(ls_first_request) = mo_res_api->get_request_at(
      iv_index = 1 ).
    DATA(ls_second_request) = mo_res_api->get_request_at(
      iv_index = 2 ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'COST-200'
      act = ls_first_request-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-RANK'
      act = ls_first_request-items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_first_request-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'COST-100'
      act = ls_second_request-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-RANK'
      act = ls_second_request-items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_second_request-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-items[ 1 ]-request_locations[ 1 ]-storage_location ).
  ENDMETHOD.

  METHOD reserves_dated_cc_fefo_bulk.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-EARLY'
          expiration_date    = '20261010'
          available_quantity = '2.000' )
        ( storage_location   = '0001'
          batch              = 'B-LATE'
          expiration_date    = '20261020'
          available_quantity = '3.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_cc_fefo_date_bulk(
      it_demands         = VALUE #(
        ( request_id         = 'BULK-DATED-LATE'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'CC-LATE'
          requested_quantity = '1.000'
          unit               = 'EA'
          required_date      = '20261012'
          priority           = 99 )
        ( request_id         = 'BULK-DATED-EARLY-LOW'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'CC-EARLY-L'
          requested_quantity = '1.000'
          unit               = 'EA'
          required_date      = '20261005'
          priority           = 1 )
        ( request_id         = 'BULK-DATED-EARLY-HIGH'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'CC-EARLY-H'
          requested_quantity = '1.000'
          unit               = 'EA'
          required_date      = '20261005'
          priority           = 10 ) )
      iv_fefo_as_of_date = '20261001' ).
    DATA(ls_first_request) = mo_res_api->get_request_at(
      iv_index = 1 ).
    DATA(ls_second_request) = mo_res_api->get_request_at(
      iv_index = 2 ).
    DATA(ls_third_request) = mo_res_api->get_request_at(
      iv_index = 3 ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BULK-DATED-LATE'
      act = ls_result-items[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BULK-DATED-EARLY-LOW'
      act = ls_result-items[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BULK-DATED-EARLY-HIGH'
      act = ls_result-items[ 3 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261005'
      act = ls_result-items[ 3 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_result-items[ 3 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-EARLY-H'
      act = ls_first_request-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-EARLY-L'
      act = ls_second_request-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-LATE'
      act = ls_third_request-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = mo_res_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD reserves_cc_bulk_fefo_date.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-BEFORE'
          expiration_date    = '20261004'
          available_quantity = '1.000' )
        ( storage_location   = '0001'
          batch              = 'B-AFTER'
          expiration_date    = '20261006'
          available_quantity = '1.000' )
        ( storage_location   = '0001'
          batch              = 'B-LATER'
          expiration_date    = '20261007'
          available_quantity = '1.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_cost_centers_bulk(
      it_demands           = VALUE #(
        ( request_id         = 'CC-FEFO-BULK-DATE'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          batch              = 'B-LATER'
          required_date      = '20261005'
          fefo_as_of_date    = '20261003'
          requested_quantity = '1.000'
          unit               = 'EA' ) )
      iv_use_fefo_batches  = abap_true
      iv_fefo_as_of_date   = '20260923'
      it_request_locations = VALUE #(
        ( request_id = 'CC-FEFO-BULK-DATE' storage_location = '0001' ) ) ).
    DATA(ls_request) = mo_res_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261005'
      act = ls_result-items[ 1 ]-fefo_as_of_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_result-items[ 1 ]-batch_allocations[
        1 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-items[ 1 ]-request_locations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_request-items[ 1 ]-batch ).
  ENDMETHOD.

  METHOD rejects_short_atomic_batch.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          expiration_date    = '20270101'
          available_quantity = '1.000' )
        ( storage_location   = '0001'
          batch              = 'B-OTHER'
          expiration_date    = '20280101'
          available_quantity = '20.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_cost_centers_atomic(
      it_demands = VALUE #(
        ( request_id         = 'BATCH-SHORT'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          batch              = 'B-1'
          required_date      = '20261020'
          requested_quantity = '2.000'
          unit               = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-items[ 1 ]-allocation-shortfall_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_short_atomic_cc.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '3.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_cost_centers_atomic(
      it_demands = VALUE #(
        ( request_id         = 'SHORT-1'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = '20261020'
          requested_quantity = '2.000'
          unit               = 'EA' )
        ( request_id         = 'SHORT-2'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          required_date      = '20261022'
          requested_quantity = '2.000'
          unit               = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-items[ 2 ]-allocation-shortfall_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_atomic_cc_create.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '5.000' ) ) ).
    mo_res_api->set_create_result(
      is_result = VALUE #(
        messages = VALUE #(
          ( type = 'E' message = 'Creation failed' ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_cost_centers_atomic(
      it_demands = VALUE #(
        ( request_id         = 'FAIL-1'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = '20261020'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'FAIL-2'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          required_date      = '20261022'
          requested_quantity = '1.000'
          unit               = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rejects_dupe_atomic_numbers.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '5.000' ) ) ).
    mo_res_api->set_create_results(
      it_results = VALUE #(
        ( reservation_number = '9000000001'
          is_successful      = abap_true )
        ( reservation_number = '9000000001'
          is_successful      = abap_true ) ) ).

    DATA(ls_result) = mo_cut->reserve_cost_centers_atomic(
      it_demands = VALUE #(
        ( request_id         = 'DUPLICATE-1'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = '20261020'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'DUPLICATE-2'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          required_date      = '20261022'
          requested_quantity = '1.000'
          unit               = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-items[ 1 ]-reservation_result-reservation_number ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-items[ 2 ]-reservation_result-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Reservation API returned a duplicate reservation number'
      act = ls_result-messages[ type = 'E' ]-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_res_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_atomic_cc_commit.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '5.000' ) ) ).
    mo_res_api->set_commit_result(
      is_result = VALUE #(
        is_successful = abap_false
        message       = VALUE #(
          type    = 'E'
          message = 'Commit failed' ) ) ).

    DATA(ls_result) = mo_cut->reserve_cost_centers_atomic(
      it_demands = VALUE #(
        ( request_id         = 'COMMIT-1'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = '20261020'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'COMMIT-2'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          required_date      = '20261022'
          requested_quantity = '1.000'
          unit               = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-items[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-items[ 1 ]-reservation_result-reservation_number ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-items[ 2 ]-reservation_result-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_res_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD simulates_atomic_cc.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '5.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_cost_centers_atomic(
      it_demands  = VALUE #(
        ( request_id         = 'TEST-ATOMIC'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = '20261020'
          requested_quantity = '1.000'
          unit               = 'EA' ) )
      iv_test_run = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-items[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = mo_res_api->was_test_run( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD prechecks_atomic_cc_atp.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '10.000' ) ) ).
    mo_uom_repo->set_alt_unit_ratio(
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    mo_atp_api->set_result(
      is_result = VALUE #(
        is_fully_available = abap_true
        is_check_relevant  = abap_true ) ).

    DATA(ls_result) = mo_cut->reserve_cost_centers_atomic(
      it_demands        = VALUE #(
        ( request_id         = 'ATP-GROUP-1'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = '20261020'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'ATP-GROUP-2'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          required_date      = '20261020'
          requested_quantity = '1.000'
          unit               = 'BOX' )
        ( request_id         = 'ATP-GROUP-3'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-300'
          required_date      = '20261022'
          requested_quantity = '1.000'
          unit               = 'EA' ) )
      iv_check_atp      = abap_true
      iv_atp_check_rule = 'A' ).
    DATA(ls_atp_request) = mo_atp_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-items[ 1 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-items[ 2 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-items[ 2 ]-allocation-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-items[ 3 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_atp_request-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_atp_api->get_check_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = mo_res_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_short_atomic_cc_atp.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '10.000' ) ) ).
    mo_atp_api->set_result(
      is_result = VALUE #(
        confirmed_date     = '20261020'
        confirmed_quantity = '1.000'
        is_fully_available = abap_false
        is_check_relevant  = abap_true ) ).

    DATA(ls_result) = mo_cut->reserve_cost_centers_atomic(
      it_demands                  = VALUE #(
        ( request_id         = 'ATP-SHORT-1'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = '20261020'
          requested_quantity = '2.000'
          unit               = 'EA' )
        ( request_id         = 'ATP-SHORT-2'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          required_date      = '20261020'
          requested_quantity = '1.000'
          unit               = 'EA' ) )
      iv_check_atp                = abap_true
      iv_atp_check_rule           = 'A'
      iv_require_atp_confirmation = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-items[ 1 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-items[ 2 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-items[ 2 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_atp_api->get_check_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rejects_atomic_cc_atp_opts.
    DATA lv_flag_raised TYPE abap_bool.
    DATA lv_rule_raised TYPE abap_bool.
    DATA lt_demands TYPE zcl_cc_reservation_service=>ty_atomic_reservation_demands.

    lt_demands = VALUE #(
      ( request_id         = 'ATP-OPTIONS'
        material           = 'MAT-1'
        plant              = '1000'
        cost_center        = 'COST-100'
        required_date      = '20261020'
        requested_quantity = '1.000'
        unit               = 'EA' ) ).

    TRY.
        mo_cut->reserve_cost_centers_atomic(
          it_demands   = lt_demands
          iv_check_atp = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_flag_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->reserve_cost_centers_atomic(
          it_demands   = lt_demands
          iv_check_atp = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_rule_raised = abap_true.
    ENDTRY.

    DATA(ls_result) = mo_cut->reserve_cost_centers_atomic(
      it_demands                  = lt_demands
      iv_require_atp_confirmation = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_flag_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rule_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'E'
      act = ls_result-messages[ 1 ]-type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_atp_api->get_check_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_atomic_cc.
    DATA lv_duplicate_raised TYPE abap_bool.
    DATA lv_location_raised TYPE abap_bool.
    DATA lv_flag_raised TYPE abap_bool.
    DATA lv_mixed_batch_raised TYPE abap_bool.
    DATA lv_fefo_flag_raised TYPE abap_bool.
    DATA lv_min_days_raised TYPE abap_bool.
    DATA lv_bad_date_raised TYPE abap_bool.
    DATA lv_bad_bulk_date_raised TYPE abap_bool.
    DATA lt_valid_demands TYPE zcl_cc_reservation_service=>ty_atomic_reservation_demands.

    lt_valid_demands = VALUE #(
      ( request_id         = 'VALID-ATOMIC'
        material           = 'MAT-1'
        plant              = '1000'
        cost_center        = 'COST-100'
        required_date      = '20261020'
        requested_quantity = '1.000'
        unit               = 'EA' ) ).

    TRY.
        mo_cut->reserve_cost_centers_atomic(
          it_demands = VALUE #(
            ( request_id         = 'DUP-ATOMIC'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              required_date      = '20261020'
              requested_quantity = '1.000'
              unit               = 'EA' )
            ( request_id         = 'DUP-ATOMIC'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-200'
              required_date      = '20261022'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_duplicate_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->reserve_cost_centers_atomic(
          it_demands = VALUE #(
            ( request_id                  = 'NO-LOCATION'
              material                    = 'MAT-1'
              plant                       = '1000'
              cost_center                 = 'COST-100'
              required_date               = '20261020'
              fallback_to_other_locations = abap_true
              requested_quantity          = '1.000'
              unit                        = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_location_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->reserve_cost_centers_atomic(
          it_demands = VALUE #(
            ( request_id         = 'MIXED-BATCH-1'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              batch              = 'B-1'
              required_date      = '20261020'
              requested_quantity = '1.000'
              unit               = 'EA' )
            ( request_id         = 'MIXED-BATCH-2'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-200'
              required_date      = '20261022'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_mixed_batch_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->reserve_cost_centers_atomic(
          it_demands          = lt_valid_demands
          iv_use_fefo_batches = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_fefo_flag_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->reserve_cost_centers_atomic(
          it_demands       = lt_valid_demands
          iv_fefo_min_days = -1 ).
      CATCH zcx_invalid_stock_request.
        lv_min_days_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->reserve_cost_centers_atomic(
          it_demands              = VALUE #( )
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_flag_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->reserve_cost_centers_atomic(
          it_demands = VALUE #(
            ( request_id         = 'BAD-REQUIRED-DATE'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              required_date      = '20260230'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_bad_date_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->reserve_cost_centers_bulk(
          it_demands = VALUE #(
            ( request_id         = 'BAD-BULK-REQUIRED-DATE'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              required_date      = '20260230'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_bad_bulk_date_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_duplicate_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_location_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_flag_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_mixed_batch_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_fefo_flag_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_min_days_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_date_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_bulk_date_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD empty_atomic_cc_demands.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->reserve_cost_centers_atomic(
          it_demands = VALUE #( ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
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
          available_quantity = '1.000' )
        ( storage_location   = '0003'
          available_quantity = '2.000' ) ) ).

    DATA(ls_preview) = mo_cut->preview_for_cost_center(
      iv_material                  = 'MAT-1'
      iv_plant                     = '1000'
      iv_storage_location          = '0002'
      iv_allow_fallback            = abap_true
      iv_cost_center               = 'COST-100'
      iv_requested_quantity        = '3.000'
      iv_unit                      = 'EA'
      it_location_priority         = VALUE #(
        ( '0003' )
        ( '0001' ) )
      it_allowed_storage_locations = VALUE #(
        ( '0002' )
        ( '0003' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = ls_preview-storage_allocations[ 2 ]-storage_location ).

    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material                  = 'MAT-1'
      iv_plant                     = '1000'
      iv_storage_location          = '0002'
      iv_allow_fallback            = abap_true
      iv_cost_center               = 'COST-100'
      iv_requested_quantity        = '3.000'
      iv_unit                      = 'EA'
      it_location_priority         = VALUE #(
        ( '0003' )
        ( '0001' ) )
      it_allowed_storage_locations = VALUE #(
        ( '0002' )
        ( '0003' ) ) ).
    DATA(ls_request) = mo_res_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
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
      exp = '0003'
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
        ( storage_location   = '0003'
          batch              = 'BATCH-1'
          available_quantity = '3.000' )
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
      it_location_priority  = VALUE #(
        ( '0003' )
        ( '0001' ) )
      iv_batch              = 'BATCH-1' ).
    DATA(ls_request) = mo_res_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
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
      exp = '0003'
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
      iv_required_date      = '20260923'
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
        ( storage_location   = '0003'
          batch              = 'B-OLD'
          expiration_date    = '20261010'
          available_quantity = '3.000' )
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
      iv_required_date      = '20261001'
      iv_requested_quantity = '3.000'
      iv_unit               = 'EA'
      iv_use_fefo_batches   = abap_true
      iv_fefo_as_of_date    = '20261001'
      it_location_priority  = VALUE #(
        ( '0003' )
        ( '0001' ) ) ).
    DATA(ls_request) = mo_res_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '26.000' )
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
      exp = '0003'
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
      iv_required_date      = '20260923'
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
    DATA(ls_exact_batch_preview) = mo_cut->preview_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_cost_center        = 'COST-200'
      iv_required_date      = '20260923'
      iv_requested_quantity = '8.000'
      iv_unit               = 'EA'
      iv_batch              = 'B-LATER'
      iv_use_fefo_batches   = abap_true
      iv_fefo_as_of_date    = '20260923'
      iv_fefo_min_days      = 7
      iv_batch_min_days     = 10 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_exact_batch_preview-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_exact_batch_preview-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_exact_batch_preview-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_exact_batch_preview-batch_allocations[ 1 ]-batch ).
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
      exp = CONV mard-labst( '12.000' )
      act = ls_result-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-unconfirmed_base_quantity ).
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

  METHOD rejects_short_atp_reservation.
    mo_atp_api->set_result(
      is_result = VALUE #(
        confirmed_date     = '20261001'
        confirmed_quantity = '2.000'
        is_fully_available = abap_false
        is_check_relevant  = abap_true ) ).

    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material                 = 'MAT-1'
      iv_plant                    = '1000'
      iv_storage_location         = '0001'
      iv_cost_center              = 'COST-100'
      iv_requested_quantity       = '4.000'
      iv_unit                     = 'EA'
      iv_required_date            = '20261001'
      iv_test_run                 = abap_true
      iv_require_atp_confirmation = abap_true
      iv_check_atp                = abap_true
      iv_atp_check_rule           = 'A' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-messages ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_atp_api->get_check_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_late_atp_reservation.
    mo_atp_api->set_result(
      is_result = VALUE #(
        confirmed_date     = '20261002'
        confirmed_quantity = '4.000'
        is_fully_available = abap_false
        is_check_relevant  = abap_true ) ).

    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material                 = 'MAT-1'
      iv_plant                    = '1000'
      iv_storage_location         = '0001'
      iv_cost_center              = 'COST-100'
      iv_requested_quantity       = '4.000'
      iv_unit                     = 'EA'
      iv_required_date            = '20261001'
      iv_test_run                 = abap_true
      iv_require_atp_confirmation = abap_true
      iv_check_atp                = abap_true
      iv_atp_check_rule           = 'A' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD reserves_atp_confirmed.
    mo_atp_api->set_result(
      is_result = VALUE #(
        confirmed_date     = '20261001'
        confirmed_quantity = '4.000'
        is_fully_available = abap_true
        is_check_relevant  = abap_true ) ).

    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material                 = 'MAT-1'
      iv_plant                    = '1000'
      iv_storage_location         = '0001'
      iv_cost_center              = 'COST-100'
      iv_requested_quantity       = '4.000'
      iv_unit                     = 'EA'
      iv_required_date            = '20261001'
      iv_test_run                 = abap_true
      iv_require_atp_confirmation = abap_true
      iv_check_atp                = abap_true
      iv_atp_check_rule           = 'A' ).
    DATA(ls_request) = mo_res_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_atp_gate_without_check.
    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material                 = 'MAT-1'
      iv_plant                    = '1000'
      iv_cost_center              = 'COST-100'
      iv_requested_quantity       = '2.000'
      iv_unit                     = 'EA'
      iv_require_atp_confirmation = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-messages ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).

    DATA lv_exception_raised TYPE abap_bool.
    TRY.
        mo_cut->reserve_for_cost_center(
          iv_material                 = 'MAT-1'
          iv_plant                    = '1000'
          iv_cost_center              = 'COST-100'
          iv_requested_quantity       = '2.000'
          iv_unit                     = 'EA'
          iv_require_atp_confirmation = 'Y' ).
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

    CLEAR lv_exception_raised.
    TRY.
        mo_cut->reserve_for_cost_center(
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
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
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

  METHOD rejects_batch_min_no_batch.
    DATA lv_rejected TYPE abap_bool.
    TRY.
        mo_cut->reserve_for_cost_center(
          iv_material           = 'MAT-1'
          iv_plant              = '1000'
          iv_storage_location   = '0001'
          iv_cost_center        = 'COST-100'
          iv_requested_quantity = '4.000'
          iv_unit               = 'EA'
          iv_batch_min_days     = 1 ).
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

  METHOD reserves_cost_centers_bulk.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '6.000' ) ) ).
    mo_res_api->set_create_results(
      it_results = VALUE #(
        ( reservation_number = '9000000011' is_successful = abap_true )
        ( reservation_number = '9000000012' is_successful = abap_true ) ) ).

    DATA(ls_result) = mo_cut->reserve_cost_centers_bulk(
      it_demands           = VALUE #(
        ( request_id         = 'BULK-1'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = '20261020'
          requested_quantity = '2.000'
          unit               = 'EA' )
        ( request_id         = 'BULK-2'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          required_date      = '20261021'
          requested_quantity = '2.000'
          unit               = 'EA' ) )
      it_request_locations = VALUE #(
        ( request_id = 'BULK-1' storage_location = '0001' )
        ( request_id = 'BULK-2' storage_location = '0001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BULK-1'
      act = ls_result-items[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '9000000011'
      act = ls_result-items[ 1 ]-reservation_result-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BULK-2'
      act = ls_result-items[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '9000000012'
      act = ls_result-items[ 2 ]-reservation_result-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-items[ 1 ]-request_locations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD reserves_bulk_cc_loc_rank.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          available_quantity = '2.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_cost_centers_bulk(
      it_demands                     = VALUE #(
        ( request_id         = 'CC-BULK-RANK-1'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = '20261020'
          requested_quantity = '2.000'
          unit               = 'EA' )
        ( request_id         = 'CC-BULK-RANK-2'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          required_date      = '20261021'
          requested_quantity = '2.000'
          unit               = 'EA' ) )
      it_request_location_priorities = VALUE #(
        ( request_id       = 'CC-BULK-RANK-1'
          storage_location = '0002'
          priority_rank    = 1 )
        ( request_id       = 'CC-BULK-RANK-2'
          storage_location = '0001'
          priority_rank    = 1 ) )
      it_request_locations           = VALUE #(
        ( request_id = 'CC-BULK-RANK-1' storage_location = '0002' )
        ( request_id = 'CC-BULK-RANK-2' storage_location = '0001' ) ) ).
    DATA(ls_first_request) = mo_res_api->get_request_at(
      iv_index = 1 ).
    DATA(ls_second_request) = mo_res_api->get_request_at(
      iv_index = 2 ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_first_request-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_second_request-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-items[ 1 ]-request_locations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_committed ).
  ENDMETHOD.

  METHOD rejects_bad_cc_atomic_ranks.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '2.000' ) ) ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->reserve_cost_centers_atomic(
          it_demands                     = VALUE #( (
            request_id         = 'CC-ATOMIC-RANK-VALID'
            material           = 'MAT-1'
            plant              = '1000'
            cost_center        = 'COST-100'
            required_date      = '20261020'
            requested_quantity = '1.000'
            unit               = 'EA' ) )
          it_request_location_priorities = VALUE #( (
            request_id       = 'CC-ATOMIC-RANK-MISSING'
            storage_location = '0001'
            priority_rank    = 1 ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_cc_bulk_ranks.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '2.000' ) ) ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->reserve_cost_centers_bulk(
          it_demands                     = VALUE #( (
            request_id         = 'CC-BULK-RANK-VALID'
            material           = 'MAT-1'
            plant              = '1000'
            cost_center        = 'COST-100'
            required_date      = '20261020'
            requested_quantity = '1.000'
            unit               = 'EA' ) )
          it_request_location_priorities = VALUE #( (
            request_id       = 'CC-BULK-RANK-MISSING'
            storage_location = '0001'
            priority_rank    = 1 ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD continues_cc_bulk_reserve_fail.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '6.000' ) ) ).
    mo_res_api->set_create_results(
      it_results = VALUE #(
        ( is_successful = abap_false
          messages      = VALUE #(
            ( type = 'E' message = 'Reservation rejected' ) ) )
        ( reservation_number = '9000000012' is_successful = abap_true ) ) ).

    DATA(ls_result) = mo_cut->reserve_cost_centers_bulk(
      it_demands = VALUE #(
        ( request_id         = 'BULK-FAIL'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = '20261020'
          requested_quantity = '2.000'
          unit               = 'EA' )
        ( request_id         = 'BULK-OK'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          required_date      = '20261021'
          requested_quantity = '2.000'
          unit               = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-items[ 1 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Reservation rejected'
      act = ls_result-items[ 1 ]-reservation_result-messages[ 1 ]-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_res_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD continues_cc_bulk_commit_fail.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '6.000' ) ) ).
    mo_res_api->set_create_results(
      it_results = VALUE #(
        ( reservation_number = '9000000021' is_successful = abap_true )
        ( reservation_number = '9000000022' is_successful = abap_true ) ) ).
    mo_res_api->set_commit_results(
      it_results = VALUE #(
        ( is_successful = abap_false
          message       = VALUE #(
            type    = 'E'
            message = 'Commit failed' ) )
        ( is_successful = abap_true ) ) ).

    DATA(ls_result) = mo_cut->reserve_cost_centers_bulk(
      it_demands = VALUE #(
        ( request_id         = 'COMMIT-FAIL'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = '20261020'
          requested_quantity = '2.000'
          unit               = 'EA' )
        ( request_id         = 'COMMIT-OK'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          required_date      = '20261021'
          requested_quantity = '2.000'
          unit               = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-items[ 1 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-was_rolled_back ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-items[ 1 ]-reservation_result-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Commit failed'
      act = ls_result-items[ 1 ]-reservation_result-messages[ 1 ]-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_res_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD simulates_cost_center_bulk.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '6.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_cost_centers_bulk(
      it_demands  = VALUE #(
        ( request_id         = 'BULK-TEST-1'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = '20261020'
          requested_quantity = '2.000'
          unit               = 'EA' )
        ( request_id         = 'BULK-TEST-2'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          required_date      = '20261021'
          requested_quantity = '2.000'
          unit               = 'EA' ) )
      iv_test_run = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-items[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-items[ 2 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD validates_cost_center_bulk.
    DATA lv_rejected TYPE abap_bool.
    TRY.
        mo_cut->reserve_cost_centers_bulk(
          it_demands = VALUE #(
            ( request_id         = 'DUP-BULK'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              required_date      = '20261020'
              requested_quantity = '1.000'
              unit               = 'EA' )
            ( request_id         = 'DUP-BULK'
              material           = 'MAT-2'
              plant              = '1000'
              cost_center        = 'COST-200'
              required_date      = '20261021'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD empty_cost_center_bulk.
    DATA(ls_result) = mo_cut->reserve_cost_centers_bulk(
      it_demands = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-items ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD deletes_cc_reservations.
    mo_res_api->set_delete_result(
      is_result = VALUE #( is_successful = abap_true ) ).
    DATA(lt_numbers) = VALUE zif_cc_reservation_api=>ty_reservation_numbers(
      ( '9000000001' )
      ( '9000000002' ) ).

    DATA(ls_result) = mo_cut->delete_reservations(
      it_reservation_numbers = lt_numbers ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = lt_numbers
      act = ls_result-reservation_numbers ).
    cl_abap_unit_assert=>assert_equals(
      exp = lt_numbers
      act = mo_res_api->get_deleted_numbers( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_delete_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD simulates_cc_delete.
    mo_res_api->set_delete_result(
      is_result = VALUE #( is_successful = abap_true ) ).

    DATA(ls_result) = mo_cut->delete_reservations(
      it_reservation_numbers = VALUE #( ( '9000000001' ) )
      iv_test_run            = abap_true ).

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
      act = mo_res_api->was_delete_test_run( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_cc_delete.
    mo_res_api->set_delete_result(
      is_result = VALUE #(
        is_successful = abap_false
        messages      = VALUE #(
          ( type = 'E' message = 'Reservation is already issued' ) ) ) ).

    DATA(ls_result) = mo_cut->delete_reservations(
      it_reservation_numbers = VALUE #( ( '9000000001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_cc_delete_commit.
    mo_res_api->set_delete_result(
      is_result = VALUE #( is_successful = abap_true ) ).
    mo_res_api->set_commit_result(
      is_result = VALUE #(
        is_successful = abap_false
        message       = VALUE #(
          type    = 'E'
          message = 'Commit failed' ) ) ).

    DATA(ls_result) = mo_cut->delete_reservations(
      it_reservation_numbers = VALUE #( ( '9000000001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD validates_cc_delete.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->delete_reservations( VALUE #( ) ).
      CATCH zcx_invalid_reservation.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        mo_cut->delete_reservations(
          VALUE #( ( '9000000001' ) ( '9000000001' ) ) ).
      CATCH zcx_invalid_reservation.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        mo_cut->delete_reservations(
          VALUE #( ( '' ) ) ).
      CATCH zcx_invalid_reservation.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        mo_cut->delete_reservations(
          it_reservation_numbers = VALUE #( ( '9000000001' ) )
          iv_test_run            = 'Y' ).
      CATCH zcx_invalid_reservation.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_delete_count( ) ).
  ENDMETHOD.

  METHOD deletes_cc_bulk.
    mo_res_api->set_delete_result(
      is_result = VALUE #( is_successful = abap_true ) ).
    DATA(ls_result) = mo_cut->delete_reservations_bulk(
      it_reservation_numbers = VALUE #( ( '9000000001' ) ( '9000000002' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_res_api->get_delete_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD deletes_selected_cc_items.
    prepare_cc_item_delete( ).
    mo_res_api->set_delete_result(
      is_result = VALUE #( is_successful = abap_true ) ).

    DATA(ls_result) = mo_cut->delete_cc_reservation_items(
      iv_cost_center        = 'COST-100'
      iv_reservation_number = '9000000001'
      it_item_numbers       = VALUE #( ( '0001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '9000000001'
      act = mo_res_api->get_item_delete_reservation( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_item_delete_count( ) ).
    DATA(lt_deleted_items) = mo_res_api->get_deleted_item_numbers( ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_deleted_items[ 1 ] ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_unscoped_cc_item.
    prepare_cc_item_delete( ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->delete_cc_reservation_items(
          iv_cost_center        = 'COST-100'
          iv_reservation_number = '9000000001'
          it_item_numbers       = VALUE #( ( '0003' ) ) ).
      CATCH zcx_invalid_reservation.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_item_delete_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_cc_item_delete.
    prepare_cc_item_delete( ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->delete_cc_reservation_items(
          iv_cost_center        = 'COST-100'
          iv_reservation_number = '9000000001'
          it_item_numbers       = VALUE #( ) ).
      CATCH zcx_invalid_reservation.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        mo_cut->delete_cc_reservation_items(
          iv_cost_center        = 'COST-100'
          iv_reservation_number = '9000000001'
          it_item_numbers       = VALUE #( ( '0001' ) ( '0001' ) ) ).
      CATCH zcx_invalid_reservation.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        mo_cut->delete_cc_reservation_items(
          iv_cost_center        = 'COST-100'
          iv_reservation_number = '9000000001'
          it_item_numbers       = VALUE #( ( space ) ) ).
      CATCH zcx_invalid_reservation.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        mo_cut->delete_cc_reservation_items(
          iv_cost_center        = 'COST-100'
          iv_reservation_number = '9000000001'
          it_item_numbers       = VALUE #( ( '0001' ) )
          iv_test_run           = 'Y' ).
      CATCH zcx_invalid_reservation.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_item_delete_count( ) ).
  ENDMETHOD.

  METHOD simulates_cc_item_delete.
    prepare_cc_item_delete( ).

    DATA(ls_result) = mo_cut->delete_cc_reservation_items(
      iv_cost_center        = 'COST-100'
      iv_reservation_number = '9000000001'
      it_item_numbers       = VALUE #( ( '0001' ) )
      iv_test_run           = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_item_delete_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_cc_item_delete.
    prepare_cc_item_delete( ).
    mo_res_api->set_delete_result(
      is_result = VALUE #(
        is_successful = abap_false
        messages      = VALUE #(
          ( type = 'E' message = 'Reservation item cannot be deleted' ) ) ) ).

    DATA(ls_result) = mo_cut->delete_cc_reservation_items(
      iv_cost_center        = 'COST-100'
      iv_reservation_number = '9000000001'
      it_item_numbers       = VALUE #( ( '0001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_cc_item_commit.
    prepare_cc_item_delete( ).
    mo_res_api->set_delete_result(
      is_result = VALUE #( is_successful = abap_true ) ).
    mo_res_api->set_commit_result(
      is_result = VALUE #(
        is_successful = abap_false
        message       = VALUE #(
          type    = 'E'
          message = 'Commit failed' ) ) ).

    DATA(ls_result) = mo_cut->delete_cc_reservation_items(
      iv_cost_center        = 'COST-100'
      iv_reservation_number = '9000000001'
      it_item_numbers       = VALUE #( ( '0001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD deletes_cc_items_bulk.
    prepare_cc_item_delete( ).
    mo_res_api->set_delete_result(
      is_result = VALUE #( is_successful = abap_true ) ).

    DATA(ls_result) = mo_cut->delete_reservation_items_bulk(
      it_requests = VALUE #(
        ( cost_center        = 'COST-100'
          reservation_number = '9000000001'
          item_numbers       = VALUE #( ( '0001' ) ) )
        ( cost_center        = 'COST-100'
          reservation_number = '9000000002'
          item_numbers       = VALUE #( ( '0001' ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_res_api->get_item_delete_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD continues_cc_items_failure.
    prepare_cc_item_delete( ).
    mo_res_api->set_delete_results(
      it_results = VALUE #(
        ( is_successful = abap_false
          messages      = VALUE #(
            ( type = 'E' message = 'Reservation item cannot be deleted' ) ) )
        ( is_successful = abap_true ) ) ).

    DATA(ls_result) = mo_cut->delete_reservation_items_bulk(
      it_requests = VALUE #(
        ( cost_center        = 'COST-100'
          reservation_number = '9000000001'
          item_numbers       = VALUE #( ( '0001' ) ) )
        ( cost_center        = 'COST-100'
          reservation_number = '9000000002'
          item_numbers       = VALUE #( ( '0001' ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-items[ 1 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD prevalidates_cc_items_bulk.
    prepare_cc_item_delete( ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->delete_reservation_items_bulk(
          it_requests = VALUE #(
            ( cost_center        = 'COST-100'
              reservation_number = '9000000001'
              item_numbers       = VALUE #( ( '0001' ) ) )
            ( cost_center        = 'COST-100'
              reservation_number = '9000000001'
              item_numbers       = VALUE #( ( '0002' ) ) ) ) ).
      CATCH zcx_invalid_reservation.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_item_delete_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD simulates_cc_items_bulk.
    prepare_cc_item_delete( ).

    DATA(ls_result) = mo_cut->delete_reservation_items_bulk(
      it_requests = VALUE #(
        ( cost_center        = 'COST-100'
          reservation_number = '9000000001'
          item_numbers       = VALUE #( ( '0001' ) ) )
        ( cost_center        = 'COST-100'
          reservation_number = '9000000002'
          item_numbers       = VALUE #( ( '0001' ) ) ) )
      iv_test_run = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_item_delete_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD empty_cc_items_bulk.
    DATA(ls_result) = mo_cut->delete_reservation_items_bulk(
      it_requests = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-items ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_item_delete_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD continues_cc_bulk_failure.
    mo_res_api->set_delete_results(
      it_results = VALUE #(
        ( is_successful = abap_false
          messages      = VALUE #(
            ( type = 'E' message = 'Reservation is already issued' ) ) )
        ( is_successful = abap_true ) ) ).
    DATA(ls_result) = mo_cut->delete_reservations_bulk(
      it_reservation_numbers = VALUE #( ( '9000000001' ) ( '9000000002' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-items[ 1 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Reservation is already issued'
      act = ls_result-items[ 1 ]-messages[ 1 ]-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_res_api->get_delete_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD continues_cc_bulk_commit.
    mo_res_api->set_delete_result(
      is_result = VALUE #( is_successful = abap_true ) ).
    mo_res_api->set_commit_results(
      it_results = VALUE #(
        ( is_successful = abap_false
          message       = VALUE #(
            type    = 'E'
            message = 'Commit failed' ) )
        ( is_successful = abap_true ) ) ).
    DATA(ls_result) = mo_cut->delete_reservations_bulk(
      it_reservation_numbers = VALUE #( ( '9000000001' ) ( '9000000002' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-items[ 1 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Commit failed'
      act = ls_result-items[ 1 ]-messages[ 1 ]-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_res_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD simulates_cc_bulk.
    mo_res_api->set_delete_result(
      is_result = VALUE #( is_successful = abap_true ) ).
    DATA(ls_result) = mo_cut->delete_reservations_bulk(
      it_reservation_numbers = VALUE #( ( '9000000001' ) ( '9000000002' ) )
      iv_test_run            = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_res_api->get_delete_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = mo_res_api->was_delete_test_run( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD validates_cc_bulk.
    DATA(ls_empty_result) = mo_cut->delete_reservations_bulk(
      it_reservation_numbers = VALUE #( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_empty_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_empty_result-items ) ).

    DATA lv_rejected TYPE abap_bool.
    TRY.
        mo_cut->delete_reservations_bulk(
          it_reservation_numbers = VALUE #(
            ( '9000000001' ) ( '9000000001' ) ) ).
      CATCH zcx_invalid_reservation.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        mo_cut->delete_reservations_bulk(
          it_reservation_numbers = VALUE #( ( '' ) ) ).
      CATCH zcx_invalid_reservation.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        mo_cut->delete_reservations_bulk(
          it_reservation_numbers = VALUE #( ( '9000000001' ) )
          iv_test_run            = 'Y' ).
      CATCH zcx_invalid_reservation.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_delete_count( ) ).
  ENDMETHOD.
ENDCLASS.
