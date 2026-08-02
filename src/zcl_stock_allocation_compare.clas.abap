CLASS zcl_stock_allocation_compare DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_stock_allocation_compare.
  PRIVATE SECTION.
    METHODS raise_error
      IMPORTING
        iv_message TYPE zif_allocation_audit=>ty_message
      RAISING
        zcx_stock_allocation.
    METHODS append_reason
      IMPORTING
        iv_reason  TYPE string
      CHANGING
        cv_reasons TYPE string.
    METHODS has_reason
      IMPORTING
        iv_reason       TYPE zif_stock_allocation_compare=>ty_change_reason
        iv_reasons      TYPE string
      RETURNING
        VALUE(rv_match) TYPE abap_bool.
ENDCLASS.

CLASS zcl_stock_allocation_compare IMPLEMENTATION.
  METHOD zif_stock_allocation_compare~compare.
    TYPES:
      BEGIN OF ty_key,
        allocation_unit TYPE zif_stock_allocation=>ty_unit,
        order_id        TYPE zif_stock_allocation=>ty_order_id,
      END OF ty_key.
    TYPES tt_indexed_demands TYPE HASHED TABLE OF
      zif_stock_allocation=>ty_demand
      WITH UNIQUE KEY allocation_unit order_id.
    TYPES tt_keys TYPE SORTED TABLE OF ty_key
      WITH UNIQUE KEY allocation_unit order_id.
    DATA lt_old TYPE tt_indexed_demands.
    DATA lt_new TYPE tt_indexed_demands.
    DATA lt_keys TYPE tt_keys.
    DATA lt_all_changes TYPE zif_stock_allocation_compare=>tt_changes.
    DATA ls_change TYPE zif_stock_allocation_compare=>ty_change.
    DATA lv_limit_start TYPE i.
    FIELD-SYMBOLS <ls_demand> TYPE zif_stock_allocation=>ty_demand.
    FIELD-SYMBOLS <ls_old> TYPE zif_stock_allocation=>ty_demand.
    FIELD-SYMBOLS <ls_new> TYPE zif_stock_allocation=>ty_demand.
    FIELD-SYMBOLS <ls_key> TYPE ty_key.

    CLEAR: es_summary, ev_total_rows.
    IF iv_change_type IS NOT INITIAL
        AND iv_change_type <> 'A'
        AND iv_change_type <> 'R'
        AND iv_change_type <> 'C'
        AND iv_change_type <> 'U'.
      raise_error( iv_message = 'Comparison change type is invalid' ).
    ENDIF.
    IF iv_offset < 0 OR iv_max_rows < 0.
      raise_error( iv_message = 'Comparison pagination is invalid' ).
    ENDIF.
    IF iv_reason IS NOT INITIAL
        AND iv_reason <> 'added'
        AND iv_reason <> 'removed'
        AND iv_reason <> 'requested_on'
        AND iv_reason <> 'allocation_strategy'
        AND iv_reason <> 'sales_document'
        AND iv_reason <> 'sales_document_type'
        AND iv_reason <> 'sales_item'
        AND iv_reason <> 'schedule_line'
        AND iv_reason <> 'order_unit'
        AND iv_reason <> 'priority'
        AND iv_reason <> 'status'
        AND iv_reason <> 'requested'
        AND iv_reason <> 'allocated'
        AND iv_reason <> 'shortage'
        AND iv_reason <> 'reservation_id'
        AND iv_reason <> 'reservation_date'
        AND iv_reason <> 'reservation_movement_type'
        AND iv_reason <> 'reservation_unit'.
      raise_error( iv_message = 'Comparison change reason is invalid' ).
    ENDIF.

    LOOP AT it_old ASSIGNING <ls_demand>.
      INSERT <ls_demand> INTO TABLE lt_old.
      IF sy-subrc <> 0.
        raise_error( iv_message = 'Comparison old snapshot has duplicate keys' ).
      ENDIF.
      INSERT VALUE #(
        allocation_unit = <ls_demand>-allocation_unit
        order_id        = <ls_demand>-order_id ) INTO TABLE lt_keys.
    ENDLOOP.
    LOOP AT it_new ASSIGNING <ls_demand>.
      INSERT <ls_demand> INTO TABLE lt_new.
      IF sy-subrc <> 0.
        raise_error( iv_message = 'Comparison new snapshot has duplicate keys' ).
      ENDIF.
      INSERT VALUE #(
        allocation_unit = <ls_demand>-allocation_unit
        order_id        = <ls_demand>-order_id ) INTO TABLE lt_keys.
    ENDLOOP.

    LOOP AT lt_keys ASSIGNING <ls_key>.
      UNASSIGN: <ls_old>, <ls_new>.
      READ TABLE lt_old ASSIGNING <ls_old>
        WITH TABLE KEY allocation_unit = <ls_key>-allocation_unit
                       order_id        = <ls_key>-order_id.
      READ TABLE lt_new ASSIGNING <ls_new>
        WITH TABLE KEY allocation_unit = <ls_key>-allocation_unit
                       order_id        = <ls_key>-order_id.
      CLEAR ls_change.
      ls_change-allocation_unit = <ls_key>-allocation_unit.
      ls_change-order_id = <ls_key>-order_id.

      IF <ls_old> IS NOT ASSIGNED.
        ls_change-change_type = 'A'.
        ls_change-change_reasons = 'added'.
      ELSEIF <ls_new> IS NOT ASSIGNED.
        ls_change-change_type = 'R'.
        ls_change-change_reasons = 'removed'.
      ELSE.
        IF <ls_old>-requested_on <> <ls_new>-requested_on.
          append_reason( EXPORTING iv_reason = 'requested_on'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF <ls_old>-allocation_strategy <> <ls_new>-allocation_strategy.
          append_reason( EXPORTING iv_reason = 'allocation_strategy'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF <ls_old>-sales_document <> <ls_new>-sales_document.
          append_reason( EXPORTING iv_reason = 'sales_document'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF <ls_old>-sales_document_type <> <ls_new>-sales_document_type.
          append_reason( EXPORTING iv_reason = 'sales_document_type'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF <ls_old>-sales_item <> <ls_new>-sales_item.
          append_reason( EXPORTING iv_reason = 'sales_item'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF <ls_old>-schedule_line <> <ls_new>-schedule_line.
          append_reason( EXPORTING iv_reason = 'schedule_line'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF <ls_old>-order_unit <> <ls_new>-order_unit.
          append_reason( EXPORTING iv_reason = 'order_unit'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF <ls_old>-priority <> <ls_new>-priority.
          append_reason( EXPORTING iv_reason = 'priority'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF <ls_old>-allocation_status <> <ls_new>-allocation_status.
          append_reason( EXPORTING iv_reason = 'status'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF <ls_old>-requested <> <ls_new>-requested.
          append_reason( EXPORTING iv_reason = 'requested'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF <ls_old>-allocated <> <ls_new>-allocated.
          append_reason( EXPORTING iv_reason = 'allocated'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF <ls_old>-shortage <> <ls_new>-shortage.
          append_reason( EXPORTING iv_reason = 'shortage'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF <ls_old>-reservation_id <> <ls_new>-reservation_id.
          append_reason( EXPORTING iv_reason = 'reservation_id'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF <ls_old>-reservation_date <> <ls_new>-reservation_date.
          append_reason( EXPORTING iv_reason = 'reservation_date'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF <ls_old>-reservation_movement_type
            <> <ls_new>-reservation_movement_type.
          append_reason( EXPORTING iv_reason = 'reservation_movement_type'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF <ls_old>-reservation_unit <> <ls_new>-reservation_unit.
          append_reason( EXPORTING iv_reason = 'reservation_unit'
                       CHANGING cv_reasons   = ls_change-change_reasons ).
        ENDIF.
        IF ls_change-change_reasons IS NOT INITIAL.
          ls_change-change_type = 'C'.
        ELSEIF iv_include_unchanged = abap_true.
          ls_change-change_type = 'U'.
        ELSE.
          CONTINUE.
        ENDIF.
      ENDIF.

      IF <ls_old> IS ASSIGNED.
        ls_change-old_allocation_strategy = <ls_old>-allocation_strategy.
        ls_change-old_sales_document = <ls_old>-sales_document.
        ls_change-old_sales_document_type = <ls_old>-sales_document_type.
        ls_change-old_sales_item = <ls_old>-sales_item.
        ls_change-old_schedule_line = <ls_old>-schedule_line.
        ls_change-old_order_unit = <ls_old>-order_unit.
        ls_change-old_requested_on = <ls_old>-requested_on.
        ls_change-old_priority = <ls_old>-priority.
        ls_change-old_status = <ls_old>-allocation_status.
        ls_change-old_requested = <ls_old>-requested.
        ls_change-old_allocated = <ls_old>-allocated.
        ls_change-old_shortage = <ls_old>-shortage.
        ls_change-old_reservation_id = <ls_old>-reservation_id.
        ls_change-old_reservation_date = <ls_old>-reservation_date.
        ls_change-old_reservation_movement_type =
          <ls_old>-reservation_movement_type.
        ls_change-old_reservation_unit = <ls_old>-reservation_unit.
      ENDIF.
      IF <ls_new> IS ASSIGNED.
        ls_change-new_allocation_strategy = <ls_new>-allocation_strategy.
        ls_change-new_sales_document = <ls_new>-sales_document.
        ls_change-new_sales_document_type = <ls_new>-sales_document_type.
        ls_change-new_sales_item = <ls_new>-sales_item.
        ls_change-new_schedule_line = <ls_new>-schedule_line.
        ls_change-new_order_unit = <ls_new>-order_unit.
        ls_change-new_requested_on = <ls_new>-requested_on.
        ls_change-new_priority = <ls_new>-priority.
        ls_change-new_status = <ls_new>-allocation_status.
        ls_change-new_requested = <ls_new>-requested.
        ls_change-new_allocated = <ls_new>-allocated.
        ls_change-new_shortage = <ls_new>-shortage.
        ls_change-new_reservation_id = <ls_new>-reservation_id.
        ls_change-new_reservation_date = <ls_new>-reservation_date.
        ls_change-new_reservation_movement_type =
          <ls_new>-reservation_movement_type.
        ls_change-new_reservation_unit = <ls_new>-reservation_unit.
      ENDIF.
      ls_change-delta_requested = ls_change-new_requested
        - ls_change-old_requested.
      ls_change-delta_allocated = ls_change-new_allocated
        - ls_change-old_allocated.
      ls_change-delta_shortage = ls_change-new_shortage
        - ls_change-old_shortage.
      IF ( iv_change_type IS INITIAL
          OR ls_change-change_type = iv_change_type )
          AND ( iv_reason IS INITIAL
          OR has_reason(
            iv_reason  = iv_reason
            iv_reasons = ls_change-change_reasons ) = abap_true ).
        APPEND ls_change TO lt_all_changes.
        es_summary-total_rows = es_summary-total_rows + 1.
        CASE ls_change-change_type.
          WHEN 'A'.
            es_summary-added_rows = es_summary-added_rows + 1.
          WHEN 'R'.
            es_summary-removed_rows = es_summary-removed_rows + 1.
          WHEN 'C'.
            es_summary-changed_rows = es_summary-changed_rows + 1.
          WHEN 'U'.
            es_summary-unchanged_rows = es_summary-unchanged_rows + 1.
        ENDCASE.
        IF es_summary-unit IS INITIAL.
          es_summary-unit = ls_change-allocation_unit.
        ELSEIF es_summary-unit <> ls_change-allocation_unit.
          es_summary-mixed_units = abap_true.
          CLEAR es_summary-unit.
          CLEAR: es_summary-old_requested,
                 es_summary-new_requested,
                 es_summary-delta_requested,
                 es_summary-old_allocated,
                 es_summary-new_allocated,
                 es_summary-delta_allocated,
                 es_summary-old_shortage,
                 es_summary-new_shortage,
                 es_summary-delta_shortage.
        ENDIF.
        IF es_summary-mixed_units = abap_false.
          es_summary-old_requested = es_summary-old_requested
            + ls_change-old_requested.
          es_summary-new_requested = es_summary-new_requested
            + ls_change-new_requested.
          es_summary-delta_requested = es_summary-delta_requested
            + ls_change-delta_requested.
          es_summary-old_allocated = es_summary-old_allocated
            + ls_change-old_allocated.
          es_summary-new_allocated = es_summary-new_allocated
            + ls_change-new_allocated.
          es_summary-delta_allocated = es_summary-delta_allocated
            + ls_change-delta_allocated.
          es_summary-old_shortage = es_summary-old_shortage
            + ls_change-old_shortage.
          es_summary-new_shortage = es_summary-new_shortage
            + ls_change-new_shortage.
          es_summary-delta_shortage = es_summary-delta_shortage
            + ls_change-delta_shortage.
        ENDIF.
      ENDIF.
    ENDLOOP.
    ev_total_rows = es_summary-total_rows.
    rt_changes = lt_all_changes.
    IF iv_offset > 0.
      IF iv_offset >= lines( rt_changes ).
        CLEAR rt_changes.
      ELSE.
        DELETE rt_changes FROM 1 TO iv_offset.
      ENDIF.
    ENDIF.
    IF iv_max_rows > 0 AND lines( rt_changes ) > iv_max_rows.
      lv_limit_start = iv_max_rows + 1.
      DELETE rt_changes FROM lv_limit_start.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_allocation_compare~reconcile.
    FIELD-SYMBOLS <ls_snapshot> TYPE zif_stock_allocation=>ty_demand.

    CLEAR rs_reconciliation.
    LOOP AT it_snapshot ASSIGNING <ls_snapshot>.
      rs_reconciliation-snapshot_rows =
        rs_reconciliation-snapshot_rows + 1.
      CASE <ls_snapshot>-allocation_status.
        WHEN 'F'.
          rs_reconciliation-snapshot_full_count =
            rs_reconciliation-snapshot_full_count + 1.
        WHEN 'P'.
          rs_reconciliation-snapshot_partial_count =
            rs_reconciliation-snapshot_partial_count + 1.
        WHEN 'U'.
          rs_reconciliation-snapshot_unallocated_count =
            rs_reconciliation-snapshot_unallocated_count + 1.
      ENDCASE.
      rs_reconciliation-snapshot_requested =
        rs_reconciliation-snapshot_requested + <ls_snapshot>-requested.
      rs_reconciliation-snapshot_allocated =
        rs_reconciliation-snapshot_allocated + <ls_snapshot>-allocated.
      rs_reconciliation-snapshot_shortage =
        rs_reconciliation-snapshot_shortage + <ls_snapshot>-shortage.
    ENDLOOP.

    IF rs_reconciliation-snapshot_rows <> is_audit-demand_count.
      append_reason( EXPORTING iv_reason = 'demand_count'
                   CHANGING cv_reasons   = rs_reconciliation-mismatch_fields ).
    ENDIF.
    IF rs_reconciliation-snapshot_full_count <> is_audit-full_count.
      append_reason( EXPORTING iv_reason = 'full_count'
                   CHANGING cv_reasons   = rs_reconciliation-mismatch_fields ).
    ENDIF.
    IF rs_reconciliation-snapshot_partial_count <> is_audit-partial_count.
      append_reason( EXPORTING iv_reason = 'partial_count'
                   CHANGING cv_reasons   = rs_reconciliation-mismatch_fields ).
    ENDIF.
    IF rs_reconciliation-snapshot_unallocated_count
        <> is_audit-unallocated_count.
      append_reason( EXPORTING iv_reason = 'unallocated_count'
                   CHANGING cv_reasons   = rs_reconciliation-mismatch_fields ).
    ENDIF.
    IF rs_reconciliation-snapshot_requested <> is_audit-requested.
      append_reason( EXPORTING iv_reason = 'requested'
                   CHANGING cv_reasons   = rs_reconciliation-mismatch_fields ).
    ENDIF.
    IF rs_reconciliation-snapshot_allocated <> is_audit-allocated.
      append_reason( EXPORTING iv_reason = 'allocated'
                   CHANGING cv_reasons   = rs_reconciliation-mismatch_fields ).
    ENDIF.
    IF rs_reconciliation-snapshot_shortage <> is_audit-shortage.
      append_reason( EXPORTING iv_reason = 'shortage'
                   CHANGING cv_reasons   = rs_reconciliation-mismatch_fields ).
    ENDIF.
    IF rs_reconciliation-mismatch_fields IS INITIAL.
      rs_reconciliation-status = 'OK'.
    ELSE.
      rs_reconciliation-status = 'MISMATCH'.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_allocation_compare~get_reconciliation_transition.
    IF iv_old_status = 'OK' AND iv_new_status = 'OK'.
      rv_transition = 'both_ok'.
    ELSEIF iv_old_status = 'MISMATCH'
        AND iv_new_status = 'OK'.
      rv_transition = 'recovered'.
    ELSEIF iv_old_status = 'OK'
        AND iv_new_status = 'MISMATCH'.
      rv_transition = 'regressed'.
    ELSEIF iv_old_status = 'MISMATCH'
        AND iv_new_status = 'MISMATCH'.
      rv_transition = 'both_mismatch'.
    ELSE.
      rv_transition = 'unavailable'.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_allocation_compare~get_running_age.
    DATA lv_seconds TYPE i.

    CLEAR rs_age.
    IF is_run-status <> 'R'
        OR is_run-finish_date IS NOT INITIAL
        OR is_run-start_date IS INITIAL
        OR is_run-start_time IS INITIAL.
      RETURN.
    ENDIF.

    cl_abap_tstmp=>td_subtract(
      EXPORTING
        date1    = sy-datum
        time1    = sy-uzeit
        date2    = is_run-start_date
        time2    = is_run-start_time
      IMPORTING
        res_secs = lv_seconds ).
    IF lv_seconds < 0.
      RETURN.
    ENDIF.

    rs_age-available = abap_true.
    rs_age-seconds = lv_seconds.
  ENDMETHOD.

  METHOD zif_stock_allocation_compare~get_running_age_trend.
    rv_trend = 'unavailable'.
    IF is_old_age-available = abap_false
        OR is_new_age-available = abap_false.
      RETURN.
    ENDIF.
    IF is_new_age-seconds > is_old_age-seconds.
      rv_trend = 'older'.
    ELSEIF is_new_age-seconds < is_old_age-seconds.
      rv_trend = 'younger'.
    ELSE.
      rv_trend = 'unchanged'.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_allocation_compare~get_audit_metadata_reasons.
    IF iv_old_run-status <> iv_new_run-status.
      append_reason( EXPORTING iv_reason = 'status'
                   CHANGING cv_reasons   = rv_reasons ).
    ENDIF.
    IF iv_old_run-strategy <> iv_new_run-strategy.
      append_reason( EXPORTING iv_reason = 'strategy'
                   CHANGING cv_reasons   = rv_reasons ).
    ENDIF.
    IF iv_old_run-unit <> iv_new_run-unit.
      append_reason( EXPORTING iv_reason = 'unit'
                   CHANGING cv_reasons   = rv_reasons ).
    ENDIF.
    IF iv_old_run-requested_on_from <> iv_new_run-requested_on_from
        OR iv_old_run-requested_on_to <> iv_new_run-requested_on_to.
      append_reason( EXPORTING iv_reason = 'horizon'
                   CHANGING cv_reasons   = rv_reasons ).
    ENDIF.
    IF iv_old_run-start_date <> iv_new_run-start_date
        OR iv_old_run-start_time <> iv_new_run-start_time
        OR iv_old_run-finish_date <> iv_new_run-finish_date
        OR iv_old_run-finish_time <> iv_new_run-finish_time.
      append_reason( EXPORTING iv_reason = 'timestamps'
                   CHANGING cv_reasons   = rv_reasons ).
    ENDIF.
    IF iv_old_run-message <> iv_new_run-message.
      append_reason( EXPORTING iv_reason = 'message'
                   CHANGING cv_reasons   = rv_reasons ).
    ENDIF.
  ENDMETHOD.

  METHOD raise_error.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = iv_message.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.

  METHOD append_reason.
    IF cv_reasons IS INITIAL.
      cv_reasons = iv_reason.
    ELSE.
      CONCATENATE cv_reasons iv_reason INTO cv_reasons SEPARATED BY '|'.
    ENDIF.
  ENDMETHOD.

  METHOD has_reason.
    DATA lv_needle TYPE string.
    DATA lv_reasons TYPE string.

    CONCATENATE '|' iv_reason '|' INTO lv_needle.
    CONCATENATE '|' iv_reasons '|' INTO lv_reasons.
    IF lv_reasons CS lv_needle.
      rv_match = abap_true.
    ELSE.
      rv_match = abap_false.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
