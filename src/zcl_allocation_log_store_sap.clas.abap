CLASS zcl_allocation_log_store_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_allocation_log_store.
    INTERFACES zif_allocation_history_store.

  PRIVATE SECTION.
    METHODS audit_batch_is_valid
      IMPORTING
        it_current      TYPE zif_allocation_log_store=>ty_current_entries
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.
ENDCLASS.

CLASS zcl_allocation_log_store_sap IMPLEMENTATION.
  METHOD zif_allocation_log_store~save.
    IF lines( it_current ) <> lines( it_history ).
      rv_saved = abap_false.
      RETURN.
    ENDIF.
    IF lines( it_current ) >
        zcl_stock_allocation_service=>gc_max_batch_size.
      rv_saved = abap_false.
      RETURN.
    ENDIF.

    DATA lt_log_uuids TYPE HASHED TABLE OF zstock_algh-log_uuid
      WITH UNIQUE KEY table_line.
    LOOP AT it_history INTO DATA(ls_history).
      DATA(lv_index) = sy-tabix.
      READ TABLE it_current INTO DATA(ls_current) INDEX lv_index.
      DATA ls_expected_current TYPE zstock_alog.
      MOVE-CORRESPONDING ls_history TO ls_expected_current.
      IF ls_history-log_uuid IS INITIAL
          OR ls_expected_current <> ls_current.
        rv_saved = abap_false.
        RETURN.
      ENDIF.
      INSERT ls_history-log_uuid INTO TABLE lt_log_uuids.
      IF sy-subrc <> 0.
        rv_saved = abap_false.
        RETURN.
      ENDIF.
    ENDLOOP.

    IF audit_batch_is_valid( it_current ) = abap_false.
      rv_saved = abap_false.
      RETURN.
    ENDIF.

    IF it_current IS INITIAL.
      rv_saved = abap_true.
      RETURN.
    ENDIF.

    MODIFY zstock_alog FROM TABLE @it_current.
    IF sy-subrc <> 0.
      ROLLBACK WORK.
      rv_saved = abap_false.
      RETURN.
    ENDIF.

    INSERT zstock_algh FROM TABLE @it_history.
    rv_saved = xsdbool( sy-subrc = 0 ).
    IF rv_saved = abap_false.
      ROLLBACK WORK.
      RETURN.
    ENDIF.

    COMMIT WORK AND WAIT.
  ENDMETHOD.

  METHOD audit_batch_is_valid.
    IF it_current IS INITIAL.
      rv_valid = abap_true.
      RETURN.
    ENDIF.

    DATA lt_allocations TYPE zcl_stock_allocator=>ty_allocations.
    DATA lv_run_id TYPE zif_allocation_logger=>ty_run_id.
    DATA lv_run_mode TYPE c LENGTH 1.
    DATA ls_run_context TYPE zstock_alog.
    LOOP AT it_current INTO DATA(ls_current).
      IF strlen( ls_current-run_id ) <> 32
          OR ls_current-run_id CN '0123456789ABCDEFabcdef'
          OR zcl_stock_allocator=>date_is_valid(
            ls_current-logged_on ) = abap_false
          OR zcl_stock_allocator=>time_is_valid(
            ls_current-logged_at ) = abap_false
          OR ( ls_current-run_mode <> 'P'
            AND ls_current-run_mode <> 'S'
            AND ls_current-run_mode <> 'I' ).
        RETURN.
      ENDIF.
      IF lv_run_id IS INITIAL.
        lv_run_id = ls_current-run_id.
        lv_run_mode = ls_current-run_mode.
        ls_run_context = ls_current.
      ELSEIF lv_run_id <> ls_current-run_id
          OR lv_run_mode <> ls_current-run_mode
          OR ls_run_context-allocation_strategy <>
            ls_current-allocation_strategy
          OR ls_run_context-horizon_date <> ls_current-horizon_date
          OR ls_run_context-require_full_batch <>
            ls_current-require_full_batch
          OR ls_run_context-logged_by <> ls_current-logged_by.
        RETURN.
      ENDIF.

      APPEND VALUE #(
        request_id             = ls_current-request_id
        material               = ls_current-material
        plant                  = ls_current-plant
        storage_location       = ls_current-storage_location
        movement_type          = ls_current-movement_type
        cost_center            = ls_current-cost_center
        order_id               = ls_current-order_id
        wbs_element            = ls_current-wbs_element
        sales_order            = ls_current-sales_order
        sales_order_item       = ls_current-sales_order_item
        asset_number           = ls_current-asset_number
        asset_subnumber        = ls_current-asset_subnumber
        network_id             = ls_current-network_id
        network_activity       = ls_current-network_activity
        unit_of_measure        = ls_current-unit_of_measure
        requirement_date       = ls_current-requirement_date
        requested_qty          = ls_current-requested_qty
        source_requested_qty   = ls_current-source_requested_qty
        source_unit_of_measure = ls_current-source_unit
        minimum_fill_pct       = ls_current-minimum_fill_pct
        priority               = ls_current-priority
        allow_partial          = ls_current-allow_partial
        allocated_qty          = ls_current-allocated_qty
        shortfall_qty          = ls_current-shortfall_qty
        fill_pct               = ls_current-fill_pct
        availability_checked   = ls_current-availability_checked
        available_qty          = ls_current-available_qty
        status                 = ls_current-allocation_status
        decision_code          = ls_current-decision_code
        posting_status         = ls_current-posting_status
        document_id            = ls_current-reservation_id
        replaced_document_id   = ls_current-prior_reservation_id
        posting_message        = ls_current-log_message ) TO lt_allocations.
    ENDLOOP.

    IF zcl_allocation_result_check=>batch_is_valid(
        lt_allocations ) = abap_false.
      RETURN.
    ENDIF.
    DATA(lv_simulation) = COND abap_bool(
      WHEN lv_run_mode = 'S' THEN abap_true
      WHEN lv_run_mode = 'P' THEN abap_false
      ELSE 'Y' ).
    IF zcl_allocation_result_check=>run_context_is_valid(
        it_allocations        = lt_allocations
        iv_simulation         = lv_simulation
        iv_strategy           = ls_run_context-allocation_strategy
        iv_horizon_date       = ls_run_context-horizon_date
        iv_require_full_batch =
          ls_run_context-require_full_batch ) = abap_false.
      RETURN.
    ENDIF.

    rv_valid = abap_true.
  ENDMETHOD.

  METHOD zif_allocation_history_store~remove_before.
    IF iv_simulation <> abap_false AND iv_simulation <> abap_true.
      rs_result-is_success = abap_false.
      rs_result-message = 'Retention simulation flag must be X or blank'.
      RETURN.
    ENDIF.
    IF iv_cutoff_date IS INITIAL.
      rs_result-is_success = abap_false.
      rs_result-message = 'Retention cutoff date must not be initial'.
      RETURN.
    ENDIF.
    IF zcl_stock_allocator=>date_is_valid(
        iv_cutoff_date ) = abap_false.
      rs_result-is_success = abap_false.
      rs_result-message = 'Retention cutoff date is invalid'.
      RETURN.
    ENDIF.
    IF iv_cutoff_date >= sy-datum.
      rs_result-is_success = abap_false.
      rs_result-message = 'Retention cutoff date must be before today'.
      RETURN.
    ENDIF.

    DATA lv_activity TYPE c LENGTH 2.
    lv_activity = COND #( WHEN iv_simulation = abap_true
                           THEN '03'
                           ELSE '06' ).
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM'
      ID 'TABLE' FIELD 'ZSTOCK_ALGH'
      ID 'ACTVT' FIELD lv_activity.
    IF sy-subrc <> 0.
      rs_result-is_success = abap_false.
      rs_result-message = 'Not authorized for allocation audit history'.
      RETURN.
    ENDIF.

    IF iv_simulation = abap_true.
      SELECT COUNT(*)
        FROM zstock_algh
        WHERE logged_on < @iv_cutoff_date
        INTO @rs_result-affected_rows.
      rs_result-is_success = xsdbool( sy-subrc = 0 ).
      IF rs_result-is_success = abap_true.
        rs_result-message = 'Audit history retention simulation completed'.
      ELSE.
        rs_result-message = 'Audit history retention simulation failed'.
      ENDIF.
      RETURN.
    ENDIF.

    DELETE FROM zstock_algh WHERE logged_on < @iv_cutoff_date.
    IF sy-subrc <> 0 AND sy-subrc <> 4.
      ROLLBACK WORK.
      rs_result-is_success = abap_false.
      rs_result-message = 'Audit history retention failed'.
      RETURN.
    ENDIF.

    rs_result-affected_rows = sy-dbcnt.
    COMMIT WORK AND WAIT.
    rs_result-is_success = abap_true.
    rs_result-message = 'Audit history retention completed'.
  ENDMETHOD.
ENDCLASS.
