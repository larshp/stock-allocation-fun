CLASS lcl_allocation_history_reader DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_history_reader.
    DATA ms_result TYPE zif_allocation_history_reader=>ty_result.
    DATA mv_from_date TYPE d.
    DATA mv_to_date TYPE d.
    DATA mv_from_time TYPE t.
    DATA mv_to_time TYPE t.
    DATA mv_requirement_from TYPE zstock_algh-requirement_date.
    DATA mv_requirement_to TYPE zstock_algh-requirement_date.
    DATA mv_log_uuid TYPE zstock_algh-log_uuid.
    DATA mv_request_id TYPE zstock_algh-request_id.
    DATA mv_reservation_id TYPE zstock_algh-reservation_id.
    DATA mv_prior_reservation_id TYPE zstock_algh-prior_reservation_id.
    DATA mv_material TYPE zstock_algh-material.
    DATA mv_plant TYPE zstock_algh-plant.
    DATA mv_storage_location TYPE zstock_algh-storage_location.
    DATA mv_movement_type TYPE zstock_algh-movement_type.
    DATA mv_source_unit TYPE zstock_algh-source_unit.
    DATA mv_unit_of_measure TYPE zstock_algh-unit_of_measure.
    DATA mv_allocation_strategy TYPE zstock_algh-allocation_strategy.
    DATA mv_horizon_from TYPE zstock_algh-horizon_date.
    DATA mv_horizon_to TYPE zstock_algh-horizon_date.
    DATA mv_partial_filter
      TYPE zif_allocation_history_reader=>ty_boolean_filter.
    DATA mv_full_batch_filter
      TYPE zif_allocation_history_reader=>ty_boolean_filter.
    DATA mv_availability_filter
      TYPE zif_allocation_history_reader=>ty_boolean_filter.
    DATA mv_stock_filter
      TYPE zif_allocation_history_reader=>ty_boolean_filter.
    DATA mv_shortfall_filter
      TYPE zif_allocation_history_reader=>ty_boolean_filter.
    DATA mv_fill_filter TYPE zif_allocation_history_reader=>ty_fill_filter.
    DATA mv_fill_pct_from TYPE zstock_algh-fill_pct.
    DATA mv_fill_pct_to TYPE zstock_algh-fill_pct.
    DATA mv_min_fill_from TYPE zstock_algh-minimum_fill_pct.
    DATA mv_min_fill_to TYPE zstock_algh-minimum_fill_pct.
    DATA mv_source_qty_from TYPE zstock_algh-source_requested_qty.
    DATA mv_source_qty_to TYPE zstock_algh-source_requested_qty.
    DATA mv_available_qty_from TYPE zstock_algh-available_qty.
    DATA mv_available_qty_to TYPE zstock_algh-available_qty.
    DATA mv_shortfall_qty_from TYPE zstock_algh-shortfall_qty.
    DATA mv_shortfall_qty_to TYPE zstock_algh-shortfall_qty.
    DATA mv_priority_from TYPE zstock_algh-priority.
    DATA mv_priority_to TYPE zstock_algh-priority.
    DATA mv_requested_qty_from TYPE zstock_algh-requested_qty.
    DATA mv_requested_qty_to TYPE zstock_algh-requested_qty.
    DATA mv_allocated_qty_from TYPE zstock_algh-allocated_qty.
    DATA mv_allocated_qty_to TYPE zstock_algh-allocated_qty.
    DATA mv_cost_center TYPE zstock_algh-cost_center.
    DATA mv_order_id TYPE zstock_algh-order_id.
    DATA mv_wbs_element TYPE zstock_algh-wbs_element.
    DATA mv_sales_order TYPE zstock_algh-sales_order.
    DATA mv_sales_order_item TYPE zstock_algh-sales_order_item.
    DATA mv_asset_number TYPE zstock_algh-asset_number.
    DATA mv_asset_subnumber TYPE zstock_algh-asset_subnumber.
    DATA mv_network_id TYPE zstock_algh-network_id.
    DATA mv_network_activity TYPE zstock_algh-network_activity.
    DATA mv_allocation_status TYPE zstock_algh-allocation_status.
    DATA mv_posting_status TYPE zstock_algh-posting_status.
    DATA mv_run_mode TYPE zstock_algh-run_mode.
    DATA mv_run_id TYPE zstock_algh-run_id.
    DATA mv_decision_code TYPE zstock_algh-decision_code.
    DATA mv_log_message TYPE zstock_algh-log_message.
    DATA mv_logged_by TYPE zstock_algh-logged_by.
    DATA mv_max_rows TYPE i.
    DATA mv_calls TYPE i.
ENDCLASS.

CLASS lcl_allocation_history_reader IMPLEMENTATION.
  METHOD zif_allocation_history_reader~read.
    mv_calls = mv_calls + 1.
    mv_from_date = iv_from_date.
    mv_to_date = iv_to_date.
    mv_from_time = iv_from_time.
    mv_to_time = iv_to_time.
    mv_requirement_from = iv_requirement_from.
    mv_requirement_to = iv_requirement_to.
    mv_log_uuid = iv_log_uuid.
    mv_request_id = iv_request_id.
    mv_reservation_id = iv_reservation_id.
    mv_prior_reservation_id = iv_prior_reservation_id.
    mv_material = iv_material.
    mv_plant = iv_plant.
    mv_storage_location = iv_storage_location.
    mv_movement_type = iv_movement_type.
    mv_source_unit = iv_source_unit.
    mv_unit_of_measure = iv_unit_of_measure.
    mv_allocation_strategy = iv_allocation_strategy.
    mv_horizon_from = iv_horizon_from.
    mv_horizon_to = iv_horizon_to.
    mv_partial_filter = iv_partial_filter.
    mv_full_batch_filter = iv_full_batch_filter.
    mv_availability_filter = iv_availability_filter.
    mv_stock_filter = iv_stock_filter.
    mv_shortfall_filter = iv_shortfall_filter.
    mv_fill_filter = iv_fill_filter.
    mv_fill_pct_from = iv_fill_pct_from.
    mv_fill_pct_to = iv_fill_pct_to.
    mv_min_fill_from = iv_min_fill_from.
    mv_min_fill_to = iv_min_fill_to.
    mv_source_qty_from = iv_source_qty_from.
    mv_source_qty_to = iv_source_qty_to.
    mv_available_qty_from = iv_available_qty_from.
    mv_available_qty_to = iv_available_qty_to.
    mv_shortfall_qty_from = iv_shortfall_qty_from.
    mv_shortfall_qty_to = iv_shortfall_qty_to.
    mv_priority_from = iv_priority_from.
    mv_priority_to = iv_priority_to.
    mv_requested_qty_from = iv_requested_qty_from.
    mv_requested_qty_to = iv_requested_qty_to.
    mv_allocated_qty_from = iv_allocated_qty_from.
    mv_allocated_qty_to = iv_allocated_qty_to.
    mv_cost_center = iv_cost_center.
    mv_order_id = iv_order_id.
    mv_wbs_element = iv_wbs_element.
    mv_sales_order = iv_sales_order.
    mv_sales_order_item = iv_sales_order_item.
    mv_asset_number = iv_asset_number.
    mv_asset_subnumber = iv_asset_subnumber.
    mv_network_id = iv_network_id.
    mv_network_activity = iv_network_activity.
    mv_allocation_status = iv_allocation_status.
    mv_posting_status = iv_posting_status.
    mv_run_mode = iv_run_mode.
    mv_run_id = iv_run_id.
    mv_decision_code = iv_decision_code.
    mv_log_message = iv_log_message.
    mv_logged_by = iv_logged_by.
    mv_max_rows = iv_max_rows.
    rs_result = ms_result.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_allocation_log_export DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_reader TYPE REF TO lcl_allocation_history_reader.
    DATA mo_cut TYPE REF TO zcl_allocation_log_export.

    METHODS setup.
    METHODS exports_filtered_csv FOR TESTING.
    METHODS neutralizes_csv_formulas FOR TESTING.
    METHODS supplies_default_dates FOR TESTING.
    METHODS rejects_invalid_range FOR TESTING.
    METHODS rejects_invalid_time_range FOR TESTING.
    METHODS rejects_invalid_req_range FOR TESTING.
    METHODS rejects_invalid_horizon FOR TESTING.
    METHODS rejects_invalid_policy_filter FOR TESTING.
    METHODS rejects_invalid_stock_filter FOR TESTING.
    METHODS rejects_conflicting_stock FOR TESTING.
    METHODS rejects_conflicting_qty FOR TESTING.
    METHODS rejects_bad_shortfall_filter FOR TESTING.
    METHODS rejects_invalid_fill_filter FOR TESTING.
    METHODS rejects_invalid_fill_range FOR TESTING.
    METHODS rejects_invalid_min_fill FOR TESTING.
    METHODS rejects_invalid_qty_range FOR TESTING.
    METHODS rejects_invalid_numeric_range FOR TESTING.
    METHODS rejects_invalid_limit FOR TESTING.
    METHODS rejects_truncated_result FOR TESTING.
    METHODS rejects_invalid_mode FOR TESTING.
    METHODS propagates_read_failure FOR TESTING.
    METHODS rejects_invalid_reader_state FOR TESTING.
    METHODS rejects_reader_date_leak FOR TESTING.
    METHODS rejects_reader_filter_leak FOR TESTING.
    METHODS creates_sap_composition FOR TESTING.
ENDCLASS.

CLASS ltcl_allocation_log_export IMPLEMENTATION.
  METHOD setup.
    mo_reader = NEW #( ).
    mo_reader->ms_result-is_success = abap_true.
    mo_cut = NEW #( mo_reader ).
  ENDMETHOD.

  METHOD exports_filtered_csv.
    DATA(lv_log_uuid) = cl_system_uuid=>create_uuid_x16_static( ).
    mo_reader->ms_result-entries = VALUE #(
      ( logged_on            = '20260801'
        logged_at            = '123456'
        log_uuid             = lv_log_uuid
        run_id               = '00112233445566778899AABBCCDDEEFF'
        request_id           = 'REQ;1'
        run_mode             = 'P'
        material             = 'MAT-1'
        plant                = '1000'
        storage_location     = '0001'
        movement_type        = '201'
        requirement_date     = '20260815'
        minimum_fill_pct     = 75
        priority             = 10
        allow_partial        = abap_true
        allocation_strategy  = 'DUE_PRIORITY'
        horizon_date         = '20260831'
        require_full_batch   = abap_true
        cost_center          = 'CC1000'
        order_id             = 'ORDER-1'
        wbs_element          = 'PROJECT-1'
        sales_order          = '0000123456'
        sales_order_item     = '000010'
        asset_number         = '000000123456'
        asset_subnumber      = '0000'
        network_id           = '000001234567'
        network_activity     = '0010'
        allocation_status    = 'ALLOCATED'
        decision_code        = 'FULLY_ALLOCATED'
        posting_status       = 'POSTED'
        availability_checked = abap_true
        available_qty        = 7
        source_requested_qty = 1
        source_unit          = 'BOX'
        requested_qty        = 5
        allocated_qty        = 5
        shortfall_qty        = 0
        fill_pct             = 100
        unit_of_measure      = 'EA'
        reservation_id       = '0000000001'
        prior_reservation_id = '0000000041'
        log_message          = 'Text "quoted"'
        logged_by            = 'TESTER' ) ).

    DATA(ls_result) = mo_cut->run(
      iv_from_date            = '20260801'
      iv_to_date              = '20260818'
      iv_from_time            = '101500'
      iv_to_time              = '144500'
      iv_requirement_from     = '20260810'
      iv_requirement_to       = '20260820'
      iv_log_uuid             = lv_log_uuid
      iv_request_id           = 'REQ;1'
      iv_reservation_id       = '0000000001'
      iv_prior_reservation_id = '0000000041'
      iv_material             = 'MAT-1'
      iv_plant                = '1000'
      iv_storage_location     = '0001'
      iv_movement_type        = '201'
      iv_source_unit          = 'BOX'
      iv_unit_of_measure      = 'EA'
      iv_allocation_strategy  = 'DUE_PRIORITY'
      iv_horizon_from         = '20260801'
      iv_horizon_to           = '20260831'
      iv_partial_filter       = 'X'
      iv_full_batch_filter    = 'X'
      iv_availability_filter  = 'X'
      iv_stock_filter         = 'X'
      iv_shortfall_filter     = '-'
      iv_fill_filter          = 'F'
      iv_fill_pct_from        = 100
      iv_fill_pct_to          = 100
      iv_min_fill_from        = 60
      iv_min_fill_to          = 80
      iv_source_qty_from      = 1
      iv_source_qty_to        = 2
      iv_available_qty_from   = 4
      iv_available_qty_to     = 8
      iv_shortfall_qty_to     = 6
      iv_priority_from        = 5
      iv_priority_to          = 15
      iv_requested_qty_from   = 4
      iv_requested_qty_to     = 6
      iv_allocated_qty_from   = 3
      iv_allocated_qty_to     = 5
      iv_cost_center          = 'CC1000'
      iv_order_id             = 'ORDER-1'
      iv_wbs_element          = 'PROJECT-1'
      iv_sales_order          = '0000123456'
      iv_sales_order_item     = '000010'
      iv_asset_number         = '000000123456'
      iv_asset_subnumber      = '0000'
      iv_network_id           = '000001234567'
      iv_network_activity     = '0010'
      iv_allocation_status    = 'ALLOCATED'
      iv_posting_status       = 'POSTED'
      iv_run_mode             = 'P'
      iv_run_id               = '00112233445566778899AABBCCDDEEFF'
      iv_decision_code        = 'FULLY_ALLOCATED'
      iv_log_message          = 'Text "quoted"'
      iv_logged_by            = 'TESTER'
      iv_max_rows             = 50 ).

    cl_abap_unit_assert=>assert_true( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-exported_rows
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-lines )
      exp = 2 ).
    FIND FIRST OCCURRENCE OF 'SALES_ORDER_ITEM' IN ls_result-lines[ 1 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF 'ALLOCATION_STRATEGY' IN ls_result-lines[ 1 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF 'DECISION_CODE' IN ls_result-lines[ 1 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF 'AVAILABILITY_CHECKED;AVAILABLE_QTY'
      IN ls_result-lines[ 1 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF
      'ALLOCATED_QTY;SHORTFALL_QTY;FILL_PCT;UNIT_OF_MEASURE'
      IN ls_result-lines[ 1 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF 'RUN_ID' IN ls_result-lines[ 1 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF '"00112233445566778899AABBCCDDEEFF"'
      IN ls_result-lines[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF '"REQ;1"' IN ls_result-lines[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF '"Text ""quoted"""' IN ls_result-lines[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF ';"EA";' IN ls_result-lines[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF ';"BOX";' IN ls_result-lines[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF ';"CC1000";' IN ls_result-lines[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF ';"000010";' IN ls_result-lines[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF ';"000001234567";"0010";' IN ls_result-lines[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF ';"MAT-1";"1000";"0001";"201";'
      IN ls_result-lines[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF ';"0000000001";"0000000041";'
      IN ls_result-lines[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF
      ';"5.000";"5.000";"0.000";"100.000";"EA";'
      IN ls_result-lines[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF
      ';"ALLOCATED";"FULLY_ALLOCATED";"POSTED";"X";"7.000";'
      IN ls_result-lines[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_max_rows
      exp = 51 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_run_id
      exp = '00112233445566778899AABBCCDDEEFF' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_decision_code
      exp = 'FULLY_ALLOCATED' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_from_time
      exp = '101500' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_to_time
      exp = '144500' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_logged_by
      exp = 'TESTER' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_log_uuid
      exp = lv_log_uuid ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_log_message
      exp = 'Text "quoted"' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_requirement_from
      exp = '20260810' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_requirement_to
      exp = '20260820' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_reservation_id
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_prior_reservation_id
      exp = '0000000041' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_material
      exp = 'MAT-1' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_plant
      exp = '1000' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_storage_location
      exp = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_movement_type
      exp = '201' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_source_unit
      exp = 'BOX' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_unit_of_measure
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_allocation_strategy
      exp = 'DUE_PRIORITY' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_horizon_from
      exp = '20260801' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_horizon_to
      exp = '20260831' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_partial_filter
      exp = 'X' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_full_batch_filter
      exp = 'X' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_availability_filter
      exp = 'X' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_stock_filter
      exp = 'X' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_shortfall_filter
      exp = '-' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_fill_filter
      exp = 'F' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_fill_pct_from
      exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_fill_pct_to
      exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_min_fill_from
      exp = 60 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_min_fill_to
      exp = 80 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_source_qty_from
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_source_qty_to
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_available_qty_from
      exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_available_qty_to
      exp = 8 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_shortfall_qty_from
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_shortfall_qty_to
      exp = 6 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_priority_from
      exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_priority_to
      exp = 15 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_requested_qty_from
      exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_requested_qty_to
      exp = 6 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_allocated_qty_from
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_allocated_qty_to
      exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_cost_center
      exp = 'CC1000' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_order_id
      exp = 'ORDER-1' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_wbs_element
      exp = 'PROJECT-1' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_sales_order
      exp = '0000123456' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_sales_order_item
      exp = '000010' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_asset_number
      exp = '000000123456' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_asset_subnumber
      exp = '0000' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_network_id
      exp = '000001234567' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_network_activity
      exp = '0010' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_allocation_status
      exp = 'ALLOCATED' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_posting_status
      exp = 'POSTED' ).
  ENDMETHOD.

  METHOD supplies_default_dates.
    DATA(ls_result) = mo_cut->run( iv_today = '20260818' ).

    cl_abap_unit_assert=>assert_true( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_from_date
      exp = '20260720' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_to_date
      exp = '20260818' ).
    cl_abap_unit_assert=>assert_initial( mo_reader->mv_from_time ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_to_time
      exp = '235959' ).
  ENDMETHOD.

  METHOD rejects_invalid_range.
    DATA(ls_result) = mo_cut->run(
      iv_from_date = '20260818'
      iv_to_date   = '20260801' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_invalid_time_range.
    DATA(ls_result) = mo_cut->run(
      iv_from_date = '20260818'
      iv_to_date   = '20260818'
      iv_from_time = '150000'
      iv_to_time   = '145959' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Export start time must not exceed end time' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD neutralizes_csv_formulas.
    DATA(ls_entry) = VALUE zstock_algh(
      logged_on   = '20260818'
      request_id  = '=2+3'
      material    = '+SUM(A1:A2)'
      order_id    = '-1+1'
      log_message = '@HYPERLINK("https://example.invalid")' ).
    ls_entry-wbs_element =
      cl_abap_char_utilities=>horizontal_tab && '=TAB'.
    ls_entry-cost_center =
      cl_abap_char_utilities=>newline && '=LINE'.
    ls_entry-network_id =
      cl_abap_char_utilities=>cr_lf(1) && '=RETURN'.
    APPEND ls_entry TO mo_reader->ms_result-entries.

    DATA(ls_result) = mo_cut->run( iv_today = '20260818' ).

    cl_abap_unit_assert=>assert_true( ls_result-is_success ).
    FIND FIRST OCCURRENCE OF `"'=2+3"` IN ls_result-lines[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF `"'+SUM(A1:A2)"` IN ls_result-lines[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF `"'-1+1"` IN ls_result-lines[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF `"'@HYPERLINK(""https://example.invalid"")"`
      IN ls_result-lines[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    DATA(lv_tab_value) = `"'`
      && cl_abap_char_utilities=>horizontal_tab && `=TAB"`.
    FIND FIRST OCCURRENCE OF lv_tab_value IN ls_result-lines[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    DATA(lv_newline_value) = `"'`
      && cl_abap_char_utilities=>newline && `=LINE"`.
    FIND FIRST OCCURRENCE OF lv_newline_value IN ls_result-lines[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    DATA(lv_return_value) = `"'`
      && cl_abap_char_utilities=>cr_lf(1) && `=RETURN"`.
    FIND FIRST OCCURRENCE OF lv_return_value IN ls_result-lines[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_invalid_req_range.
    DATA(ls_result) = mo_cut->run(
      iv_requirement_from = '20260820'
      iv_requirement_to   = '20260810'
      iv_today            = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Requirement start date must not exceed end date' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_invalid_horizon.
    DATA(ls_result) = mo_cut->run(
      iv_horizon_from = '20260820'
      iv_horizon_to   = '20260810'
      iv_today        = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Horizon start date must not exceed end date' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_invalid_policy_filter.
    DATA(ls_result) = mo_cut->run(
      iv_partial_filter = 'Y'
      iv_today          = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Policy filters must be blank, X, or -' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_invalid_stock_filter.
    DATA(ls_result) = mo_cut->run(
      iv_stock_filter = 'Y'
      iv_today        = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Policy filters must be blank, X, or -' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_conflicting_stock.
    DATA(ls_result) = mo_cut->run(
      iv_availability_filter = '-'
      iv_stock_filter        = 'X'
      iv_today               = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Availability filters conflict' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_bad_shortfall_filter.
    DATA(ls_result) = mo_cut->run(
      iv_shortfall_filter = 'Y'
      iv_today            = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Policy filters must be blank, X, or -' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_invalid_fill_filter.
    DATA(ls_result) = mo_cut->run(
      iv_fill_filter = 'X'
      iv_today       = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Fill filter must be blank, F, P, or N' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_conflicting_qty.
    DATA(ls_result) = mo_cut->run(
      iv_availability_filter = '-'
      iv_available_qty_from  = 5
      iv_today               = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Availability filters conflict' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_invalid_fill_range.
    DATA(ls_result) = mo_cut->run(
      iv_fill_pct_from = 101
      iv_today         = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Fill percentage range is invalid' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_invalid_min_fill.
    DATA(ls_result) = mo_cut->run(
      iv_min_fill_to = 101
      iv_today       = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Minimum fill range is invalid' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_invalid_qty_range.
    DATA(ls_result) = mo_cut->run(
      iv_source_qty_from = -1
      iv_today           = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Quantity range is invalid' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_invalid_numeric_range.
    DATA(ls_result) = mo_cut->run(
      iv_requested_qty_from = 20
      iv_requested_qty_to   = 10
      iv_today              = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Numeric filters are invalid' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_invalid_limit.
    DATA(ls_result) = mo_cut->run(
      iv_max_rows = zcl_allocation_log_export=>gc_max_rows + 1
      iv_today    = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_truncated_result.
    mo_reader->ms_result-entries = VALUE #(
      ( request_id = 'REQUEST-1' )
      ( request_id = 'REQUEST-2' ) ).

    DATA(ls_result) = mo_cut->run(
      iv_max_rows = 1
      iv_today    = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Export row limit exceeded; narrow the filters' ).
    cl_abap_unit_assert=>assert_initial( ls_result-lines ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_max_rows
      exp = 2 ).
  ENDMETHOD.

  METHOD rejects_invalid_mode.
    DATA(ls_result) = mo_cut->run(
      iv_run_mode = 'X'
      iv_today    = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD propagates_read_failure.
    mo_reader->ms_result-is_success = abap_false.
    mo_reader->ms_result-message = 'Read failed'.

    DATA(ls_result) = mo_cut->run( iv_today = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Read failed' ).
  ENDMETHOD.

  METHOD rejects_invalid_reader_state.
    mo_reader->ms_result-is_success = 'Y'.
    mo_reader->ms_result-message = 'Misleading success'.
    mo_reader->ms_result-entries = VALUE #(
      ( request_id = 'REQUEST-1' ) ).

    DATA(ls_result) = mo_cut->run( iv_today = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Audit history reader returned invalid state' ).
    cl_abap_unit_assert=>assert_initial( ls_result-lines ).
    cl_abap_unit_assert=>assert_initial( ls_result-exported_rows ).
  ENDMETHOD.

  METHOD rejects_reader_date_leak.
    mo_reader->ms_result-entries = VALUE #(
      ( logged_on = '20260701' ) ).

    DATA(ls_result) = mo_cut->run( iv_today = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Audit history reader returned out-of-scope rows' ).
    cl_abap_unit_assert=>assert_initial( ls_result-lines ).
  ENDMETHOD.

  METHOD rejects_reader_filter_leak.
    mo_reader->ms_result-entries = VALUE #(
      ( logged_on = '20260818'
        material  = 'MAT-2' ) ).

    DATA(ls_result) = mo_cut->run(
      iv_material = 'MAT-1'
      iv_today    = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Audit history reader returned out-of-scope rows' ).
    cl_abap_unit_assert=>assert_initial( ls_result-lines ).
  ENDMETHOD.

  METHOD creates_sap_composition.
    DATA(lo_export) = zcl_allocation_log_export=>create_sap( ).

    cl_abap_unit_assert=>assert_bound( lo_export ).
  ENDMETHOD.
ENDCLASS.
