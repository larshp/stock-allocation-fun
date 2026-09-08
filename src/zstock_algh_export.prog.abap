REPORT zstock_algh_export LINE-SIZE 1023 NO STANDARD PAGE HEADING.

PARAMETERS p_from TYPE d.
PARAMETERS p_to TYPE d.
PARAMETERS p_ftime TYPE t.
PARAMETERS p_ttime TYPE t.
PARAMETERS p_rfrom TYPE zstock_algh-requirement_date.
PARAMETERS p_rto TYPE zstock_algh-requirement_date.
PARAMETERS p_uuid TYPE zstock_algh-log_uuid.
PARAMETERS p_req TYPE zstock_algh-request_id.
PARAMETERS p_res TYPE zstock_algh-reservation_id.
PARAMETERS p_prior TYPE zstock_algh-prior_reservation_id.
PARAMETERS p_mat TYPE zstock_algh-material.
PARAMETERS p_plant TYPE zstock_algh-plant.
PARAMETERS p_sloc TYPE zstock_algh-storage_location.
PARAMETERS p_move TYPE zstock_algh-movement_type.
PARAMETERS p_sunit TYPE zstock_algh-source_unit.
PARAMETERS p_unit TYPE zstock_algh-unit_of_measure.
PARAMETERS p_strat TYPE zstock_algh-allocation_strategy.
PARAMETERS p_hfrom TYPE zstock_algh-horizon_date.
PARAMETERS p_hto TYPE zstock_algh-horizon_date.
PARAMETERS p_part TYPE zif_allocation_history_reader=>ty_boolean_filter.
PARAMETERS p_full TYPE zif_allocation_history_reader=>ty_boolean_filter.
PARAMETERS p_avail TYPE zif_allocation_history_reader=>ty_boolean_filter.
PARAMETERS p_stock TYPE zif_allocation_history_reader=>ty_boolean_filter.
PARAMETERS p_short TYPE zif_allocation_history_reader=>ty_boolean_filter.
PARAMETERS p_fill TYPE zif_allocation_history_reader=>ty_fill_filter.
PARAMETERS p_fpfrom TYPE zstock_algh-fill_pct.
PARAMETERS p_fpto TYPE zstock_algh-fill_pct.
PARAMETERS p_mffrom TYPE zstock_algh-minimum_fill_pct.
PARAMETERS p_mfto TYPE zstock_algh-minimum_fill_pct.
PARAMETERS p_sqfrom TYPE zstock_algh-source_requested_qty.
PARAMETERS p_sqto TYPE zstock_algh-source_requested_qty.
PARAMETERS p_vqfrom TYPE zstock_algh-available_qty.
PARAMETERS p_vqto TYPE zstock_algh-available_qty.
PARAMETERS p_shfrom TYPE zstock_algh-shortfall_qty.
PARAMETERS p_shto TYPE zstock_algh-shortfall_qty.
PARAMETERS p_prifrm TYPE zstock_algh-priority.
PARAMETERS p_prito TYPE zstock_algh-priority.
PARAMETERS p_rqfrom TYPE zstock_algh-requested_qty.
PARAMETERS p_rqto TYPE zstock_algh-requested_qty.
PARAMETERS p_aqfrom TYPE zstock_algh-allocated_qty.
PARAMETERS p_aqto TYPE zstock_algh-allocated_qty.
PARAMETERS p_cost TYPE zstock_algh-cost_center.
PARAMETERS p_ord TYPE zstock_algh-order_id.
PARAMETERS p_wbs TYPE zstock_algh-wbs_element.
PARAMETERS p_sales TYPE zstock_algh-sales_order.
PARAMETERS p_sitem TYPE zstock_algh-sales_order_item.
PARAMETERS p_asset TYPE zstock_algh-asset_number.
PARAMETERS p_asub TYPE zstock_algh-asset_subnumber.
PARAMETERS p_net TYPE zstock_algh-network_id.
PARAMETERS p_nact TYPE zstock_algh-network_activity.
PARAMETERS p_astat TYPE zstock_algh-allocation_status.
PARAMETERS p_pstat TYPE zstock_algh-posting_status.
PARAMETERS p_mode TYPE zstock_algh-run_mode.
PARAMETERS p_run TYPE zstock_algh-run_id.
PARAMETERS p_decide TYPE zstock_algh-decision_code.
PARAMETERS p_msg TYPE zstock_algh-log_message.
PARAMETERS p_user TYPE zstock_algh-logged_by.
PARAMETERS p_max TYPE i DEFAULT 1000.

START-OF-SELECTION.
  DATA(lo_export) = zcl_allocation_log_export=>create_sap( ).
  DATA(ls_result) = lo_export->run(
    iv_from_date            = p_from
    iv_to_date              = p_to
    iv_from_time            = p_ftime
    iv_to_time              = p_ttime
    iv_requirement_from     = p_rfrom
    iv_requirement_to       = p_rto
    iv_log_uuid             = p_uuid
    iv_request_id           = p_req
    iv_reservation_id       = p_res
    iv_prior_reservation_id = p_prior
    iv_material             = p_mat
    iv_plant                = p_plant
    iv_storage_location     = p_sloc
    iv_movement_type        = p_move
    iv_source_unit          = p_sunit
    iv_unit_of_measure      = p_unit
    iv_allocation_strategy  = p_strat
    iv_horizon_from         = p_hfrom
    iv_horizon_to           = p_hto
    iv_partial_filter       = p_part
    iv_full_batch_filter    = p_full
    iv_availability_filter  = p_avail
    iv_stock_filter         = p_stock
    iv_shortfall_filter     = p_short
    iv_fill_filter          = p_fill
    iv_fill_pct_from        = p_fpfrom
    iv_fill_pct_to          = p_fpto
    iv_min_fill_from        = p_mffrom
    iv_min_fill_to          = p_mfto
    iv_source_qty_from      = p_sqfrom
    iv_source_qty_to        = p_sqto
    iv_available_qty_from   = p_vqfrom
    iv_available_qty_to     = p_vqto
    iv_shortfall_qty_from   = p_shfrom
    iv_shortfall_qty_to     = p_shto
    iv_priority_from        = p_prifrm
    iv_priority_to          = p_prito
    iv_requested_qty_from   = p_rqfrom
    iv_requested_qty_to     = p_rqto
    iv_allocated_qty_from   = p_aqfrom
    iv_allocated_qty_to     = p_aqto
    iv_cost_center          = p_cost
    iv_order_id             = p_ord
    iv_wbs_element          = p_wbs
    iv_sales_order          = p_sales
    iv_sales_order_item     = p_sitem
    iv_asset_number         = p_asset
    iv_asset_subnumber      = p_asub
    iv_network_id           = p_net
    iv_network_activity     = p_nact
    iv_allocation_status    = p_astat
    iv_posting_status       = p_pstat
    iv_run_mode             = p_mode
    iv_run_id               = p_run
    iv_decision_code        = p_decide
    iv_log_message          = p_msg
    iv_logged_by            = p_user
    iv_max_rows             = p_max ).

  IF ls_result-is_success = abap_false.
    MESSAGE ls_result-message TYPE 'E'.
  ENDIF.

  LOOP AT ls_result-lines INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.
