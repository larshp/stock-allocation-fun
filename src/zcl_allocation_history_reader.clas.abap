CLASS zcl_allocation_history_reader DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_allocation_history_reader.
ENDCLASS.

CLASS zcl_allocation_history_reader IMPLEMENTATION.
  METHOD zif_allocation_history_reader~read.
    DATA(lv_to_time) = COND t(
      WHEN iv_to_time IS INITIAL
      THEN '235959'
      ELSE iv_to_time ).
    IF iv_from_date IS INITIAL
        OR iv_to_date IS INITIAL
        OR iv_from_date > iv_to_date.
      rs_result-message = 'Audit history date range is invalid'.
      RETURN.
    ENDIF.
    IF iv_from_date = iv_to_date AND iv_from_time > lv_to_time.
      rs_result-message = 'Audit history time range is invalid'.
      RETURN.
    ENDIF.
    IF iv_requirement_from IS NOT INITIAL
        AND iv_requirement_to IS NOT INITIAL
        AND iv_requirement_from > iv_requirement_to.
      rs_result-message = 'Audit requirement date range is invalid'.
      RETURN.
    ENDIF.
    IF iv_horizon_from IS NOT INITIAL
        AND iv_horizon_to IS NOT INITIAL
        AND iv_horizon_from > iv_horizon_to.
      rs_result-message = 'Audit horizon date range is invalid'.
      RETURN.
    ENDIF.
    IF ( iv_partial_filter IS NOT INITIAL
          AND iv_partial_filter
            <> zif_allocation_history_reader=>gc_filter_true
          AND iv_partial_filter
            <> zif_allocation_history_reader=>gc_filter_false )
        OR ( iv_full_batch_filter IS NOT INITIAL
          AND iv_full_batch_filter
            <> zif_allocation_history_reader=>gc_filter_true
          AND iv_full_batch_filter
            <> zif_allocation_history_reader=>gc_filter_false )
        OR ( iv_availability_filter IS NOT INITIAL
          AND iv_availability_filter
            <> zif_allocation_history_reader=>gc_filter_true
          AND iv_availability_filter
            <> zif_allocation_history_reader=>gc_filter_false )
        OR ( iv_stock_filter IS NOT INITIAL
          AND iv_stock_filter
            <> zif_allocation_history_reader=>gc_filter_true
          AND iv_stock_filter
            <> zif_allocation_history_reader=>gc_filter_false )
        OR ( iv_shortfall_filter IS NOT INITIAL
          AND iv_shortfall_filter
            <> zif_allocation_history_reader=>gc_filter_true
          AND iv_shortfall_filter
            <> zif_allocation_history_reader=>gc_filter_false ).
      rs_result-message = 'Audit policy filter is invalid'.
      RETURN.
    ENDIF.
    IF iv_stock_filter IS NOT INITIAL
        AND iv_availability_filter
          = zif_allocation_history_reader=>gc_filter_false.
      rs_result-message = 'Audit availability filters conflict'.
      RETURN.
    ENDIF.
    IF iv_fill_filter IS NOT INITIAL
        AND iv_fill_filter
          <> zif_allocation_history_reader=>gc_fill_full
        AND iv_fill_filter
          <> zif_allocation_history_reader=>gc_fill_partial
        AND iv_fill_filter
          <> zif_allocation_history_reader=>gc_fill_none.
      rs_result-message = 'Audit fill filter is invalid'.
      RETURN.
    ENDIF.
    IF iv_max_rows <= 0
        OR iv_max_rows
          > zif_allocation_history_reader=>gc_max_rows_with_sentinel.
      rs_result-message = 'Audit history row limit is invalid'.
      RETURN.
    ENDIF.

    AUTHORITY-CHECK OBJECT 'S_TABU_NAM'
      ID 'TABLE' FIELD 'ZSTOCK_ALGH'
      ID 'ACTVT' FIELD '03'.
    IF sy-subrc <> 0.
      rs_result-is_success = abap_false.
      rs_result-message = 'Not authorized to read allocation audit history'.
      RETURN.
    ENDIF.

    DATA lt_requirement_dates TYPE RANGE OF zstock_algh-requirement_date.
    DATA lt_request_ids TYPE RANGE OF zstock_algh-request_id.
    DATA lt_reservation_ids TYPE RANGE OF zstock_algh-reservation_id.
    DATA lt_prior_reservation_ids
      TYPE RANGE OF zstock_algh-prior_reservation_id.
    DATA lt_materials TYPE RANGE OF zstock_algh-material.
    DATA lt_plants TYPE RANGE OF zstock_algh-plant.
    DATA lt_storage_locations TYPE RANGE OF zstock_algh-storage_location.
    DATA lt_movement_types TYPE RANGE OF zstock_algh-movement_type.
    DATA lt_source_units TYPE RANGE OF zstock_algh-source_unit.
    DATA lt_units_of_measure TYPE RANGE OF zstock_algh-unit_of_measure.
    DATA lt_allocation_strategies
      TYPE RANGE OF zstock_algh-allocation_strategy.
    DATA lt_horizon_dates TYPE RANGE OF zstock_algh-horizon_date.
    DATA lt_allow_partial TYPE RANGE OF zstock_algh-allow_partial.
    DATA lt_require_full_batch TYPE RANGE OF zstock_algh-require_full_batch.
    DATA lt_availability_checked
      TYPE RANGE OF zstock_algh-availability_checked.
    DATA lt_available_quantities TYPE RANGE OF zstock_algh-available_qty.
    DATA lt_shortfall_quantities TYPE RANGE OF zstock_algh-shortfall_qty.
    DATA lt_fill_percentages TYPE RANGE OF zstock_algh-fill_pct.
    DATA lt_cost_centers TYPE RANGE OF zstock_algh-cost_center.
    DATA lt_order_ids TYPE RANGE OF zstock_algh-order_id.
    DATA lt_wbs_elements TYPE RANGE OF zstock_algh-wbs_element.
    DATA lt_sales_orders TYPE RANGE OF zstock_algh-sales_order.
    DATA lt_sales_order_items TYPE RANGE OF zstock_algh-sales_order_item.
    DATA lt_asset_numbers TYPE RANGE OF zstock_algh-asset_number.
    DATA lt_asset_subnumbers TYPE RANGE OF zstock_algh-asset_subnumber.
    DATA lt_network_ids TYPE RANGE OF zstock_algh-network_id.
    DATA lt_network_activities TYPE RANGE OF zstock_algh-network_activity.
    DATA lt_allocation_statuses TYPE RANGE OF zstock_algh-allocation_status.
    DATA lt_posting_statuses TYPE RANGE OF zstock_algh-posting_status.
    DATA lt_run_modes TYPE RANGE OF zstock_algh-run_mode.
    DATA lt_run_ids TYPE RANGE OF zstock_algh-run_id.
    DATA lt_decision_codes TYPE RANGE OF zstock_algh-decision_code.
    DATA lt_logged_by_users TYPE RANGE OF zstock_algh-logged_by.
    IF iv_requirement_from IS NOT INITIAL
        AND iv_requirement_to IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'BT'
        low    = iv_requirement_from
        high   = iv_requirement_to ) TO lt_requirement_dates.
    ELSEIF iv_requirement_from IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'GE'
        low    = iv_requirement_from ) TO lt_requirement_dates.
    ELSEIF iv_requirement_to IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'LE'
        low    = iv_requirement_to ) TO lt_requirement_dates.
    ENDIF.
    IF iv_request_id IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = iv_request_id ) TO lt_request_ids.
    ENDIF.
    IF iv_reservation_id IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = iv_reservation_id ) TO lt_reservation_ids.
    ENDIF.
    IF iv_prior_reservation_id IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = iv_prior_reservation_id ) TO lt_prior_reservation_ids.
    ENDIF.
    IF iv_material IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = iv_material ) TO lt_materials.
    ENDIF.
    IF iv_plant IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = iv_plant ) TO lt_plants.
    ENDIF.
    IF iv_storage_location IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = iv_storage_location ) TO lt_storage_locations.
    ENDIF.
    IF iv_movement_type IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = iv_movement_type ) TO lt_movement_types.
    ENDIF.
    IF iv_source_unit IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = iv_source_unit ) TO lt_source_units.
    ENDIF.
    IF iv_unit_of_measure IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = iv_unit_of_measure ) TO lt_units_of_measure.
    ENDIF.
    IF iv_allocation_strategy IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = iv_allocation_strategy ) TO lt_allocation_strategies.
    ENDIF.
    IF iv_horizon_from IS NOT INITIAL AND iv_horizon_to IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'BT'
        low    = iv_horizon_from
        high   = iv_horizon_to ) TO lt_horizon_dates.
    ELSEIF iv_horizon_from IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'GE'
        low    = iv_horizon_from ) TO lt_horizon_dates.
    ELSEIF iv_horizon_to IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'LE'
        low    = iv_horizon_to ) TO lt_horizon_dates.
    ENDIF.
    IF iv_partial_filter IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = COND #(
          WHEN iv_partial_filter
            = zif_allocation_history_reader=>gc_filter_true
          THEN abap_true
          ELSE abap_false ) ) TO lt_allow_partial.
    ENDIF.
    IF iv_full_batch_filter IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = COND #(
          WHEN iv_full_batch_filter
            = zif_allocation_history_reader=>gc_filter_true
          THEN abap_true
          ELSE abap_false ) ) TO lt_require_full_batch.
    ENDIF.
    IF iv_availability_filter IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = COND #(
          WHEN iv_availability_filter
            = zif_allocation_history_reader=>gc_filter_true
          THEN abap_true
          ELSE abap_false ) ) TO lt_availability_checked.
    ENDIF.
    IF iv_stock_filter IS NOT INITIAL.
      IF iv_availability_filter IS INITIAL.
        APPEND VALUE #(
          sign   = 'I'
          option = 'EQ'
          low    = abap_true ) TO lt_availability_checked.
      ENDIF.
      APPEND VALUE #(
        sign   = 'I'
        option = COND #(
          WHEN iv_stock_filter
            = zif_allocation_history_reader=>gc_filter_true
          THEN 'GT'
          ELSE 'EQ' )
        low    = 0 ) TO lt_available_quantities.
    ENDIF.
    IF iv_shortfall_filter IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = COND #(
          WHEN iv_shortfall_filter
            = zif_allocation_history_reader=>gc_filter_true
          THEN 'GT'
          ELSE 'EQ' )
        low    = 0 ) TO lt_shortfall_quantities.
    ENDIF.
    CASE iv_fill_filter.
      WHEN zif_allocation_history_reader=>gc_fill_full.
        APPEND VALUE #(
          sign   = 'I'
          option = 'EQ'
          low    = 100 ) TO lt_fill_percentages.
      WHEN zif_allocation_history_reader=>gc_fill_partial.
        APPEND VALUE #(
          sign   = 'I'
          option = 'BT'
          low    = '0.001'
          high   = '99.999' ) TO lt_fill_percentages.
      WHEN zif_allocation_history_reader=>gc_fill_none.
        APPEND VALUE #(
          sign   = 'I'
          option = 'EQ'
          low    = 0 ) TO lt_fill_percentages.
    ENDCASE.
    IF iv_cost_center IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = iv_cost_center ) TO lt_cost_centers.
    ENDIF.
    IF iv_order_id IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = iv_order_id ) TO lt_order_ids.
    ENDIF.
    IF iv_wbs_element IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = iv_wbs_element ) TO lt_wbs_elements.
    ENDIF.
    IF iv_sales_order IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = iv_sales_order ) TO lt_sales_orders.
    ENDIF.
    IF iv_sales_order_item IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = iv_sales_order_item ) TO lt_sales_order_items.
    ENDIF.
    IF iv_asset_number IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = iv_asset_number ) TO lt_asset_numbers.
    ENDIF.
    IF iv_asset_subnumber IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = iv_asset_subnumber ) TO lt_asset_subnumbers.
    ENDIF.
    IF iv_network_id IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = iv_network_id ) TO lt_network_ids.
    ENDIF.
    IF iv_network_activity IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = iv_network_activity ) TO lt_network_activities.
    ENDIF.
    IF iv_allocation_status IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = iv_allocation_status ) TO lt_allocation_statuses.
    ENDIF.
    IF iv_posting_status IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = iv_posting_status ) TO lt_posting_statuses.
    ENDIF.
    IF iv_run_mode IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = iv_run_mode ) TO lt_run_modes.
    ENDIF.
    IF iv_run_id IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = iv_run_id ) TO lt_run_ids.
    ENDIF.
    IF iv_decision_code IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = iv_decision_code ) TO lt_decision_codes.
    ENDIF.
    IF iv_logged_by IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = iv_logged_by ) TO lt_logged_by_users.
    ENDIF.

    SELECT *
      FROM zstock_algh
      INTO TABLE @rs_result-entries
      UP TO @iv_max_rows ROWS
      WHERE logged_on >= @iv_from_date
        AND logged_on <= @iv_to_date
        AND ( logged_on > @iv_from_date
          OR logged_at >= @iv_from_time )
        AND ( logged_on < @iv_to_date
          OR logged_at <= @lv_to_time )
        AND requirement_date IN @lt_requirement_dates
        AND request_id IN @lt_request_ids
        AND reservation_id IN @lt_reservation_ids
        AND prior_reservation_id IN @lt_prior_reservation_ids
        AND material IN @lt_materials
        AND plant IN @lt_plants
        AND storage_location IN @lt_storage_locations
        AND movement_type IN @lt_movement_types
        AND source_unit IN @lt_source_units
        AND unit_of_measure IN @lt_units_of_measure
        AND allocation_strategy IN @lt_allocation_strategies
        AND horizon_date IN @lt_horizon_dates
        AND allow_partial IN @lt_allow_partial
        AND require_full_batch IN @lt_require_full_batch
        AND availability_checked IN @lt_availability_checked
        AND available_qty IN @lt_available_quantities
        AND shortfall_qty IN @lt_shortfall_quantities
        AND fill_pct IN @lt_fill_percentages
        AND cost_center IN @lt_cost_centers
        AND order_id IN @lt_order_ids
        AND wbs_element IN @lt_wbs_elements
        AND sales_order IN @lt_sales_orders
        AND sales_order_item IN @lt_sales_order_items
        AND asset_number IN @lt_asset_numbers
        AND asset_subnumber IN @lt_asset_subnumbers
        AND network_id IN @lt_network_ids
        AND network_activity IN @lt_network_activities
        AND allocation_status IN @lt_allocation_statuses
        AND posting_status IN @lt_posting_statuses
        AND run_mode IN @lt_run_modes
        AND run_id IN @lt_run_ids
        AND decision_code IN @lt_decision_codes
        AND logged_by IN @lt_logged_by_users
      ORDER BY logged_on ASCENDING,
               logged_at ASCENDING,
               log_uuid ASCENDING.
    IF sy-subrc = 0 OR sy-subrc = 4.
      rs_result-is_success = abap_true.
      rs_result-message = 'Audit history read completed'.
    ELSE.
      rs_result-is_success = abap_false.
      rs_result-message = 'Audit history read failed'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
