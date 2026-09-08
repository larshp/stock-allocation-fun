CLASS zcl_allocation_result_check DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    CLASS-METHODS allocation_is_valid
      IMPORTING
        is_allocation   TYPE zcl_stock_allocator=>ty_allocation
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.

    CLASS-METHODS batch_is_valid
      IMPORTING
        it_allocations  TYPE zcl_stock_allocator=>ty_allocations
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.

    CLASS-METHODS run_mode_is_valid
      IMPORTING
        it_allocations  TYPE zcl_stock_allocator=>ty_allocations
        iv_simulation   TYPE abap_bool
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.

  PRIVATE SECTION.
    TYPES ty_document_ids TYPE SORTED TABLE OF
      zcl_stock_allocator=>ty_document_id WITH UNIQUE KEY table_line.

    CLASS-METHODS decision_matches_status
      IMPORTING
        is_allocation   TYPE zcl_stock_allocator=>ty_allocation
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.
ENDCLASS.

CLASS zcl_allocation_result_check IMPLEMENTATION.
  METHOD allocation_is_valid.
    IF is_allocation-availability_checked <> abap_false
        AND is_allocation-availability_checked <> abap_true.
      RETURN.
    ENDIF.
    DATA lv_expected_shortfall TYPE zcl_stock_allocator=>ty_quantity.
    lv_expected_shortfall =
      is_allocation-requested_qty - is_allocation-allocated_qty.
    IF is_allocation-decision_code IS INITIAL
        OR is_allocation-allocated_qty < 0
        OR is_allocation-allocated_qty >
          zcl_stock_allocator=>gc_max_quantity
        OR is_allocation-fill_pct < 0
        OR is_allocation-fill_pct > 100
        OR is_allocation-shortfall_qty <> lv_expected_shortfall.
      RETURN.
    ENDIF.
    IF is_allocation-availability_checked = abap_false.
      IF is_allocation-available_qty <> 0.
        RETURN.
      ENDIF.
    ELSEIF is_allocation-available_qty < 0
        OR is_allocation-available_qty >
          zcl_stock_allocator=>gc_max_quantity.
      RETURN.
    ENDIF.
    IF is_allocation-allocated_qty = 0.
      IF is_allocation-fill_pct <> 0.
        RETURN.
      ENDIF.
    ELSE.
      IF is_allocation-requested_qty <= 0.
        RETURN.
      ENDIF.
    ENDIF.

    CASE is_allocation-status.
      WHEN zcl_stock_allocator=>gc_status_allocated
        OR zcl_stock_allocator=>gc_status_partial.
        IF is_allocation-status = zcl_stock_allocator=>gc_status_allocated
            AND ( is_allocation-allocated_qty <= 0
              OR is_allocation-allocated_qty <>
                is_allocation-requested_qty
              OR is_allocation-fill_pct <> 100 ).
          RETURN.
        ELSEIF is_allocation-status = zcl_stock_allocator=>gc_status_partial
            AND ( is_allocation-allocated_qty <= 0
              OR is_allocation-allocated_qty >=
                is_allocation-requested_qty
              OR is_allocation-fill_pct <= 0
              OR is_allocation-fill_pct >= 100 ).
          RETURN.
        ENDIF.
        IF is_allocation-status = zcl_stock_allocator=>gc_status_partial.
          DATA lv_expected_fill TYPE zcl_stock_allocator=>ty_quantity.
          lv_expected_fill = is_allocation-allocated_qty * 100 /
            is_allocation-requested_qty.
          IF is_allocation-fill_pct <> lv_expected_fill.
            RETURN.
          ENDIF.
        ENDIF.
        IF is_allocation-posting_status <>
            zcl_stock_allocator=>gc_posting_pending
            AND is_allocation-posting_status <>
              zcl_stock_allocator=>gc_posting_posted
            AND is_allocation-posting_status <>
              zcl_stock_allocator=>gc_posting_failed
            AND is_allocation-posting_status <>
              zcl_stock_allocator=>gc_posting_simulated.
          RETURN.
        ENDIF.
      WHEN zcl_stock_allocator=>gc_status_invalid.
        IF is_allocation-allocated_qty <> 0.
          RETURN.
        ENDIF.
        IF is_allocation-posting_status <>
            zcl_stock_allocator=>gc_posting_not_required
            AND is_allocation-posting_status <>
              zcl_stock_allocator=>gc_posting_failed.
          RETURN.
        ENDIF.
      WHEN zcl_stock_allocator=>gc_status_rejected
        OR zcl_stock_allocator=>gc_status_deferred
        OR zcl_stock_allocator=>gc_status_aborted
        OR zcl_stock_allocator=>gc_status_config_error.
        IF is_allocation-allocated_qty <> 0
            OR is_allocation-posting_status <>
            zcl_stock_allocator=>gc_posting_not_required.
          RETURN.
        ENDIF.
      WHEN OTHERS.
        RETURN.
    ENDCASE.
    IF decision_matches_status( is_allocation ) = abap_false.
      RETURN.
    ENDIF.

    IF is_allocation-posting_status =
        zcl_stock_allocator=>gc_posting_posted.
      IF zcl_allocation_persistence=>document_id_is_valid(
          is_allocation-document_id ) = abap_false.
        RETURN.
      ENDIF.
    ELSEIF is_allocation-document_id IS NOT INITIAL.
      RETURN.
    ENDIF.

    IF is_allocation-replaced_document_id IS NOT INITIAL.
      IF zcl_allocation_persistence=>document_id_is_valid(
          is_allocation-replaced_document_id ) = abap_false
          OR is_allocation-replaced_document_id =
            is_allocation-document_id.
        RETURN.
      ENDIF.
    ENDIF.

    rv_valid = abap_true.
  ENDMETHOD.

  METHOD batch_is_valid.
    DATA lt_document_ids TYPE ty_document_ids.
    LOOP AT it_allocations INTO DATA(ls_allocation).
      IF allocation_is_valid( ls_allocation ) = abap_false.
        RETURN.
      ENDIF.
      IF ls_allocation-document_id IS NOT INITIAL.
        INSERT ls_allocation-document_id INTO TABLE lt_document_ids.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.
      ENDIF.
      IF ls_allocation-replaced_document_id IS NOT INITIAL.
        INSERT ls_allocation-replaced_document_id INTO TABLE lt_document_ids.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.
      ENDIF.
    ENDLOOP.
    rv_valid = abap_true.
  ENDMETHOD.

  METHOD run_mode_is_valid.
    IF iv_simulation <> abap_false AND iv_simulation <> abap_true.
      rv_valid = abap_true.
      RETURN.
    ENDIF.
    LOOP AT it_allocations INTO DATA(ls_allocation).
      IF iv_simulation = abap_true
          AND ls_allocation-posting_status <>
            zcl_stock_allocator=>gc_posting_simulated
          AND ls_allocation-posting_status <>
            zcl_stock_allocator=>gc_posting_not_required.
        RETURN.
      ELSEIF iv_simulation = abap_false
          AND ( ls_allocation-posting_status =
              zcl_stock_allocator=>gc_posting_simulated
            OR ls_allocation-posting_status =
              zcl_stock_allocator=>gc_posting_pending ).
        RETURN.
      ENDIF.
    ENDLOOP.
    rv_valid = abap_true.
  ENDMETHOD.

  METHOD decision_matches_status.
    CASE is_allocation-decision_code.
      WHEN zcl_stock_allocator=>gc_decision_fully_allocated.
        rv_valid = xsdbool(
          is_allocation-status = zcl_stock_allocator=>gc_status_allocated ).
      WHEN zcl_stock_allocator=>gc_decision_partial.
        rv_valid = xsdbool(
          is_allocation-status = zcl_stock_allocator=>gc_status_partial ).
      WHEN zcl_stock_allocator=>gc_decision_replayed.
        rv_valid = xsdbool(
          is_allocation-status = zcl_stock_allocator=>gc_status_allocated
          OR is_allocation-status = zcl_stock_allocator=>gc_status_partial ).
      WHEN zcl_stock_allocator=>gc_decision_no_available_stock
        OR zcl_stock_allocator=>gc_decision_partial_denied
        OR zcl_stock_allocator=>gc_decision_below_minimum_fill.
        rv_valid = xsdbool(
          is_allocation-status = zcl_stock_allocator=>gc_status_rejected ).
      WHEN zcl_stock_allocator=>gc_decision_invalid_request
        OR zcl_stock_allocator=>gc_decision_bad_request_flag
        OR zcl_stock_allocator=>gc_decision_rule_invalid
        OR zcl_stock_allocator=>gc_decision_duplicate_request
        OR zcl_stock_allocator=>gc_decision_replay_version
        OR zcl_stock_allocator=>gc_decision_replay_conflict
        OR zcl_stock_allocator=>gc_decision_replay_missing
        OR zcl_stock_allocator=>gc_decision_replay_outcome
        OR zcl_stock_allocator=>gc_decision_base_unit_missing
        OR zcl_stock_allocator=>gc_decision_conversion_failed
        OR zcl_stock_allocator=>gc_decision_canonical_invalid
        OR zcl_stock_allocator=>gc_decision_plant_unauthorized.
        rv_valid = xsdbool(
          is_allocation-status = zcl_stock_allocator=>gc_status_invalid ).
      WHEN zcl_stock_allocator=>gc_decision_run_policy_invalid
        OR zcl_stock_allocator=>gc_decision_bad_strategy
        OR zcl_stock_allocator=>gc_decision_replay_lookup
        OR zcl_stock_allocator=>gc_decision_cancel_lookup
        OR zcl_stock_allocator=>gc_decision_stock_read
        OR zcl_stock_allocator=>gc_decision_stock_snapshot
        OR zcl_stock_allocator=>gc_decision_authority_invalid
        OR zcl_stock_allocator=>gc_decision_batch_too_large
        OR zcl_stock_allocator=>gc_decision_horizon_invalid.
        rv_valid = xsdbool(
          is_allocation-status =
            zcl_stock_allocator=>gc_status_config_error ).
      WHEN zcl_stock_allocator=>gc_decision_outside_horizon.
        rv_valid = xsdbool(
          is_allocation-status = zcl_stock_allocator=>gc_status_deferred ).
      WHEN zcl_stock_allocator=>gc_decision_full_batch_aborted.
        rv_valid = xsdbool(
          is_allocation-status = zcl_stock_allocator=>gc_status_aborted ).
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
