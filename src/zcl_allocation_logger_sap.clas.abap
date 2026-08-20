CLASS zcl_allocation_logger_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_allocation_logger.

    METHODS constructor
      IMPORTING
        io_store TYPE REF TO zif_allocation_log_store.

  PRIVATE SECTION.
    DATA mo_store TYPE REF TO zif_allocation_log_store.
ENDCLASS.

CLASS zcl_allocation_logger_sap IMPLEMENTATION.
  METHOD constructor.
    mo_store = io_store.
  ENDMETHOD.

  METHOD zif_allocation_logger~write.
    DATA(lv_run_mode) = COND #(
      WHEN iv_simulation = abap_true
      THEN 'S'
      WHEN iv_simulation = abap_false
      THEN 'P'
      ELSE 'I' ).
    DATA lt_log_entries TYPE zif_allocation_log_store=>ty_current_entries.
    DATA lt_log_history TYPE zif_allocation_log_store=>ty_history_entries.

    LOOP AT it_allocations INTO DATA(ls_allocation).
      APPEND VALUE #(
        request_id           = ls_allocation-request_id
        run_mode             = lv_run_mode
        run_id               = iv_run_id
        material             = ls_allocation-material
        plant                = ls_allocation-plant
        storage_location     = ls_allocation-storage_location
        movement_type        = ls_allocation-movement_type
        requirement_date     = ls_allocation-requirement_date
        minimum_fill_pct     = ls_allocation-minimum_fill_pct
        priority             = ls_allocation-priority
        allow_partial        = ls_allocation-allow_partial
        allocation_strategy  = iv_strategy
        horizon_date         = iv_horizon_date
        require_full_batch   = iv_require_full_batch
        cost_center          = ls_allocation-cost_center
        order_id             = ls_allocation-order_id
        wbs_element          = ls_allocation-wbs_element
        sales_order          = ls_allocation-sales_order
        sales_order_item     = ls_allocation-sales_order_item
        asset_number         = ls_allocation-asset_number
        asset_subnumber      = ls_allocation-asset_subnumber
        network_id           = ls_allocation-network_id
        network_activity     = ls_allocation-network_activity
        allocation_status    = ls_allocation-status
        decision_code        = ls_allocation-decision_code
        posting_status       = ls_allocation-posting_status
        availability_checked = ls_allocation-availability_checked
        available_qty        = ls_allocation-available_qty
        source_requested_qty = ls_allocation-source_requested_qty
        source_unit          = ls_allocation-source_unit_of_measure
        requested_qty        = ls_allocation-requested_qty
        allocated_qty        = ls_allocation-allocated_qty
        shortfall_qty        = ls_allocation-shortfall_qty
        fill_pct             = ls_allocation-fill_pct
        unit_of_measure      = ls_allocation-unit_of_measure
        reservation_id       = ls_allocation-document_id
        prior_reservation_id = ls_allocation-replaced_document_id
        log_message          = ls_allocation-posting_message
        logged_on            = sy-datum
        logged_at            = sy-uzeit
        logged_by            = sy-uname ) TO lt_log_entries.
      APPEND VALUE #(
        log_uuid             = cl_system_uuid=>create_uuid_x16_static( )
        run_id               = iv_run_id
        request_id           = ls_allocation-request_id
        run_mode             = lv_run_mode
        material             = ls_allocation-material
        plant                = ls_allocation-plant
        storage_location     = ls_allocation-storage_location
        movement_type        = ls_allocation-movement_type
        requirement_date     = ls_allocation-requirement_date
        minimum_fill_pct     = ls_allocation-minimum_fill_pct
        priority             = ls_allocation-priority
        allow_partial        = ls_allocation-allow_partial
        allocation_strategy  = iv_strategy
        horizon_date         = iv_horizon_date
        require_full_batch   = iv_require_full_batch
        cost_center          = ls_allocation-cost_center
        order_id             = ls_allocation-order_id
        wbs_element          = ls_allocation-wbs_element
        sales_order          = ls_allocation-sales_order
        sales_order_item     = ls_allocation-sales_order_item
        asset_number         = ls_allocation-asset_number
        asset_subnumber      = ls_allocation-asset_subnumber
        network_id           = ls_allocation-network_id
        network_activity     = ls_allocation-network_activity
        allocation_status    = ls_allocation-status
        decision_code        = ls_allocation-decision_code
        posting_status       = ls_allocation-posting_status
        availability_checked = ls_allocation-availability_checked
        available_qty        = ls_allocation-available_qty
        source_requested_qty = ls_allocation-source_requested_qty
        source_unit          = ls_allocation-source_unit_of_measure
        requested_qty        = ls_allocation-requested_qty
        allocated_qty        = ls_allocation-allocated_qty
        shortfall_qty        = ls_allocation-shortfall_qty
        fill_pct             = ls_allocation-fill_pct
        unit_of_measure      = ls_allocation-unit_of_measure
        reservation_id       = ls_allocation-document_id
        prior_reservation_id = ls_allocation-replaced_document_id
        log_message          = ls_allocation-posting_message
        logged_on            = sy-datum
        logged_at            = sy-uzeit
        logged_by            = sy-uname ) TO lt_log_history.
    ENDLOOP.

    DATA(lv_saved) = mo_store->save(
      it_current = lt_log_entries
      it_history = lt_log_history ).
    rv_saved = xsdbool( lv_saved = abap_true ).
  ENDMETHOD.
ENDCLASS.
