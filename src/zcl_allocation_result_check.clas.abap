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

    CLASS-METHODS run_context_is_valid
      IMPORTING
        it_allocations        TYPE zcl_stock_allocator=>ty_allocations
        iv_simulation         TYPE abap_bool
        iv_strategy           TYPE zcl_stock_allocator=>ty_strategy
        iv_horizon_date       TYPE d OPTIONAL
        iv_require_full_batch TYPE abap_bool
      RETURNING
        VALUE(rv_valid)       TYPE abap_bool.

  PRIVATE SECTION.
    TYPES ty_document_ids TYPE SORTED TABLE OF
      zcl_stock_allocator=>ty_document_id WITH UNIQUE KEY table_line.
    TYPES ty_request_ids TYPE SORTED TABLE OF
      zcl_stock_allocator=>ty_request_id WITH UNIQUE KEY table_line.

    CLASS-METHODS decision_matches_status
      IMPORTING
        is_allocation   TYPE zcl_stock_allocator=>ty_allocation
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.

    CLASS-METHODS availability_matches_decision
      IMPORTING
        is_allocation   TYPE zcl_stock_allocator=>ty_allocation
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.

    CLASS-METHODS stock_policy_is_valid
      IMPORTING
        is_allocation   TYPE zcl_stock_allocator=>ty_allocation
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.

    CLASS-METHODS source_request_validation
      IMPORTING
        is_allocation        TYPE zcl_stock_allocator=>ty_allocation
      RETURNING
        VALUE(rs_validation) TYPE zcl_stock_allocator=>ty_validation.

    CLASS-METHODS posting_matches_decision
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
    CASE is_allocation-decision_code.
      WHEN zcl_stock_allocator=>gc_decision_invalid_request
        OR zcl_stock_allocator=>gc_decision_bad_request_flag
        OR zcl_stock_allocator=>gc_decision_rule_invalid.
        DATA(ls_source_validation) = source_request_validation(
          is_allocation ).
        IF ls_source_validation-is_valid = abap_true
            OR ls_source_validation-decision_code <>
              is_allocation-decision_code.
          RETURN.
        ENDIF.
    ENDCASE.
    IF posting_matches_decision( is_allocation ) = abap_false.
      RETURN.
    ENDIF.
    IF availability_matches_decision( is_allocation ) = abap_false.
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
            is_allocation-document_id
          OR is_allocation-availability_checked <> abap_true.
        RETURN.
      ENDIF.
    ENDIF.

    rv_valid = abap_true.
  ENDMETHOD.

  METHOD batch_is_valid.
    DATA lt_document_ids TYPE ty_document_ids.
    DATA lt_nonduplicate_request_ids TYPE ty_request_ids.
    DATA lv_new_posting_status
      TYPE zcl_stock_allocator=>ty_posting_status.
    LOOP AT it_allocations INTO DATA(ls_allocation).
      IF allocation_is_valid( ls_allocation ) = abap_false.
        RETURN.
      ENDIF.
      IF ls_allocation-decision_code =
          zcl_stock_allocator=>gc_decision_fully_allocated
          OR ls_allocation-decision_code =
            zcl_stock_allocator=>gc_decision_partial.
        IF lv_new_posting_status IS INITIAL.
          lv_new_posting_status = ls_allocation-posting_status.
        ELSEIF lv_new_posting_status <> ls_allocation-posting_status.
          RETURN.
        ENDIF.
      ENDIF.
      IF ls_allocation-decision_code <>
          zcl_stock_allocator=>gc_decision_duplicate_request.
        INSERT ls_allocation-request_id
          INTO TABLE lt_nonduplicate_request_ids.
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
    LOOP AT it_allocations INTO ls_allocation
      WHERE decision_code =
        zcl_stock_allocator=>gc_decision_duplicate_request.
      IF NOT line_exists( lt_nonduplicate_request_ids[
          table_line = ls_allocation-request_id ] ).
        RETURN.
      ENDIF.
    ENDLOOP.
    rv_valid = abap_true.
  ENDMETHOD.

  METHOD run_mode_is_valid.
    IF iv_simulation <> abap_false AND iv_simulation <> abap_true.
      LOOP AT it_allocations INTO DATA(ls_invalid_mode_allocation).
        IF ls_invalid_mode_allocation-status <>
            zcl_stock_allocator=>gc_status_config_error
            OR ls_invalid_mode_allocation-decision_code <>
              zcl_stock_allocator=>gc_decision_run_policy_invalid
            OR ls_invalid_mode_allocation-posting_status <>
              zcl_stock_allocator=>gc_posting_not_required.
          RETURN.
        ENDIF.
      ENDLOOP.
      rv_valid = abap_true.
      RETURN.
    ENDIF.
    LOOP AT it_allocations INTO DATA(ls_allocation).
      IF iv_simulation = abap_true.
        CASE ls_allocation-decision_code.
          WHEN zcl_stock_allocator=>gc_decision_replay_version
            OR zcl_stock_allocator=>gc_decision_replay_conflict
            OR zcl_stock_allocator=>gc_decision_replay_missing
            OR zcl_stock_allocator=>gc_decision_replayed
            OR zcl_stock_allocator=>gc_decision_replay_lookup
            OR zcl_stock_allocator=>gc_decision_cancel_lookup
            OR zcl_stock_allocator=>gc_decision_replay_outcome.
            RETURN.
        ENDCASE.
      ENDIF.
      IF iv_simulation = abap_true
          AND ls_allocation-posting_status <>
            zcl_stock_allocator=>gc_posting_simulated
          AND ls_allocation-posting_status <>
            zcl_stock_allocator=>gc_posting_not_required.
        RETURN.
      ELSEIF iv_simulation = abap_true
          AND ls_allocation-replaced_document_id IS NOT INITIAL.
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

  METHOD run_context_is_valid.
    DATA lv_expected_decision TYPE zcl_stock_allocator=>ty_decision_code.
    DATA lv_full_batch_incomplete TYPE abap_bool.
    DATA(lv_batch_oversized) = xsdbool(
      lines( it_allocations ) >
        zcl_stock_allocation_service=>gc_max_batch_size ).
    IF iv_simulation <> abap_false AND iv_simulation <> abap_true.
      lv_expected_decision =
        zcl_stock_allocator=>gc_decision_run_policy_invalid.
    ELSEIF iv_require_full_batch <> abap_false
        AND iv_require_full_batch <> abap_true.
      lv_expected_decision =
        zcl_stock_allocator=>gc_decision_run_policy_invalid.
    ELSEIF iv_strategy <> zcl_stock_allocator=>gc_strategy_priority_due
        AND iv_strategy <> zcl_stock_allocator=>gc_strategy_due_priority
        AND iv_strategy <> zcl_stock_allocator=>gc_strategy_priority_id.
      lv_expected_decision = zcl_stock_allocator=>gc_decision_bad_strategy.
    ELSEIF iv_horizon_date IS NOT INITIAL
        AND zcl_stock_allocator=>date_is_valid(
          iv_horizon_date ) = abap_false.
      lv_expected_decision = zcl_stock_allocator=>gc_decision_horizon_invalid.
    ENDIF.

    LOOP AT it_allocations INTO DATA(ls_allocation).
      IF lv_expected_decision IS INITIAL.
        IF ls_allocation-decision_code =
            zcl_stock_allocator=>gc_decision_run_policy_invalid
            OR ls_allocation-decision_code =
              zcl_stock_allocator=>gc_decision_bad_strategy
            OR ls_allocation-decision_code =
              zcl_stock_allocator=>gc_decision_horizon_invalid.
          RETURN.
        ENDIF.
        IF ls_allocation-decision_code =
            zcl_stock_allocator=>gc_decision_outside_horizon
            AND ( iv_horizon_date IS INITIAL
              OR ls_allocation-requirement_date <= iv_horizon_date ).
          RETURN.
        ENDIF.
        IF ls_allocation-decision_code =
            zcl_stock_allocator=>gc_decision_full_batch_aborted
            AND iv_require_full_batch <> abap_true.
          RETURN.
        ENDIF.
        IF ( lv_batch_oversized = abap_true
              AND ls_allocation-decision_code <>
                zcl_stock_allocator=>gc_decision_batch_too_large )
            OR ( lv_batch_oversized = abap_false
              AND ls_allocation-decision_code =
                zcl_stock_allocator=>gc_decision_batch_too_large ).
          RETURN.
        ENDIF.
        IF iv_require_full_batch = abap_true
            AND ls_allocation-posting_status <>
              zcl_stock_allocator=>gc_posting_posted
            AND ls_allocation-status <>
              zcl_stock_allocator=>gc_status_allocated.
          lv_full_batch_incomplete = abap_true.
        ENDIF.
      ELSEIF ls_allocation-status <>
          zcl_stock_allocator=>gc_status_config_error
          OR ls_allocation-decision_code <> lv_expected_decision
          OR ls_allocation-posting_status <>
            zcl_stock_allocator=>gc_posting_not_required.
        RETURN.
      ENDIF.
    ENDLOOP.

    IF lv_expected_decision IS INITIAL
        AND iv_require_full_batch = abap_true
        AND lv_full_batch_incomplete = abap_true.
      LOOP AT it_allocations TRANSPORTING NO FIELDS
        WHERE decision_code =
            zcl_stock_allocator=>gc_decision_fully_allocated
          OR decision_code = zcl_stock_allocator=>gc_decision_partial.
        RETURN.
      ENDLOOP.
    ENDIF.

    rv_valid = run_mode_is_valid(
      it_allocations = it_allocations
      iv_simulation  = iv_simulation ).
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
        OR zcl_stock_allocator=>gc_decision_below_minimum_fill
        OR zcl_stock_allocator=>gc_decision_stock_not_found.
        rv_valid = xsdbool(
          is_allocation-status = zcl_stock_allocator=>gc_status_rejected ).
      WHEN zcl_stock_allocator=>gc_decision_invalid_request
        OR zcl_stock_allocator=>gc_decision_bad_request_flag
        OR zcl_stock_allocator=>gc_decision_rule_invalid
        OR zcl_stock_allocator=>gc_decision_duplicate_request
        OR zcl_stock_allocator=>gc_decision_replay_version
        OR zcl_stock_allocator=>gc_decision_replay_conflict
        OR zcl_stock_allocator=>gc_decision_replay_missing
        OR zcl_stock_allocator=>gc_decision_base_unit_missing
        OR zcl_stock_allocator=>gc_decision_conversion_failed
        OR zcl_stock_allocator=>gc_decision_canonical_invalid
        OR zcl_stock_allocator=>gc_decision_plant_unauthorized.
        rv_valid = xsdbool(
          is_allocation-status = zcl_stock_allocator=>gc_status_invalid ).
      WHEN zcl_stock_allocator=>gc_decision_replay_outcome.
        rv_valid = xsdbool(
          is_allocation-status = zcl_stock_allocator=>gc_status_invalid
          OR is_allocation-status =
            zcl_stock_allocator=>gc_status_config_error ).
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

  METHOD availability_matches_decision.
    DATA lv_available_pct TYPE zcl_stock_allocator=>ty_quantity.
    CASE is_allocation-decision_code.
      WHEN zcl_stock_allocator=>gc_decision_fully_allocated
        OR zcl_stock_allocator=>gc_decision_partial
        OR zcl_stock_allocator=>gc_decision_no_available_stock
        OR zcl_stock_allocator=>gc_decision_partial_denied
        OR zcl_stock_allocator=>gc_decision_below_minimum_fill
        OR zcl_stock_allocator=>gc_decision_stock_not_found
        OR zcl_stock_allocator=>gc_decision_full_batch_aborted
        OR zcl_stock_allocator=>gc_decision_outside_horizon
        OR zcl_stock_allocator=>gc_decision_replayed.
        IF stock_policy_is_valid( is_allocation ) = abap_false.
          RETURN.
        ENDIF.
    ENDCASE.

    CASE is_allocation-decision_code.
      WHEN zcl_stock_allocator=>gc_decision_fully_allocated.
        rv_valid = xsdbool(
          is_allocation-availability_checked = abap_true
          AND is_allocation-available_qty >= is_allocation-allocated_qty ).
      WHEN zcl_stock_allocator=>gc_decision_partial.
        rv_valid = xsdbool(
          is_allocation-availability_checked = abap_true
          AND is_allocation-available_qty = is_allocation-allocated_qty
          AND is_allocation-allow_partial = abap_true
          AND is_allocation-fill_pct >= is_allocation-minimum_fill_pct ).
      WHEN zcl_stock_allocator=>gc_decision_no_available_stock.
        rv_valid = xsdbool(
          is_allocation-availability_checked = abap_true
          AND is_allocation-available_qty = 0 ).
      WHEN zcl_stock_allocator=>gc_decision_partial_denied
        OR zcl_stock_allocator=>gc_decision_below_minimum_fill.
        lv_available_pct = is_allocation-available_qty * 100 /
          is_allocation-requested_qty.
        rv_valid = xsdbool(
          is_allocation-availability_checked = abap_true
          AND is_allocation-available_qty > 0
          AND is_allocation-available_qty < is_allocation-requested_qty
          AND ( ( is_allocation-decision_code =
                zcl_stock_allocator=>gc_decision_partial_denied
              AND is_allocation-allow_partial = abap_false )
            OR ( is_allocation-decision_code =
                zcl_stock_allocator=>gc_decision_below_minimum_fill
              AND is_allocation-allow_partial = abap_true
              AND lv_available_pct <
                is_allocation-minimum_fill_pct ) ) ).
      WHEN zcl_stock_allocator=>gc_decision_stock_not_found.
        rv_valid = xsdbool(
          is_allocation-availability_checked = abap_false ).
      WHEN zcl_stock_allocator=>gc_decision_replayed.
        rv_valid = xsdbool(
          is_allocation-availability_checked = abap_false
          AND ( is_allocation-status =
                zcl_stock_allocator=>gc_status_allocated
            OR ( is_allocation-allow_partial = abap_true
              AND is_allocation-fill_pct >=
                is_allocation-minimum_fill_pct ) ) ).
      WHEN zcl_stock_allocator=>gc_decision_full_batch_aborted.
        lv_available_pct = is_allocation-available_qty * 100 /
          is_allocation-requested_qty.
        rv_valid = xsdbool(
          is_allocation-availability_checked = abap_true
          AND ( is_allocation-available_qty >=
                is_allocation-requested_qty
            OR ( is_allocation-allow_partial = abap_true
              AND is_allocation-available_qty > 0
              AND lv_available_pct >=
                is_allocation-minimum_fill_pct ) ) ).
      WHEN OTHERS.
        rv_valid = xsdbool(
          is_allocation-availability_checked = abap_false ).
    ENDCASE.
  ENDMETHOD.

  METHOD stock_policy_is_valid.
    DATA(ls_validation) = source_request_validation( is_allocation ).

    rv_valid = xsdbool(
      ls_validation-is_valid = abap_true
      AND is_allocation-unit_of_measure IS NOT INITIAL
      AND is_allocation-requested_qty > 0
      AND zcl_allocation_persistence=>quantity_is_persistable(
        is_allocation-requested_qty ) = abap_true
      ).
  ENDMETHOD.

  METHOD source_request_validation.
    DATA(ls_request) = CORRESPONDING zcl_stock_allocator=>ty_request(
      is_allocation ).
    ls_request-requested_qty = is_allocation-source_requested_qty.
    ls_request-unit_of_measure =
      is_allocation-source_unit_of_measure.
    DATA(lv_account_error) =
      zcl_stock_allocator=>get_account_error( ls_request ).
    DATA(lv_request_flag_invalid) = xsdbool(
      ls_request-allow_partial <> abap_false
      AND ls_request-allow_partial <> abap_true ).
    DATA(lv_structural_invalid) = xsdbool(
      ls_request-request_id IS INITIAL
      OR ls_request-material IS INITIAL
      OR ls_request-plant IS INITIAL
      OR ls_request-storage_location IS INITIAL
      OR ls_request-movement_type IS INITIAL
      OR ls_request-unit_of_measure IS INITIAL
      OR zcl_stock_allocator=>date_is_valid(
        ls_request-requirement_date ) = abap_false ).
    DATA(lv_numeric_invalid) = xsdbool(
      ls_request-requested_qty <= 0
      OR ls_request-requested_qty > zcl_stock_allocator=>gc_max_quantity
      OR zcl_allocation_persistence=>quantity_is_persistable(
        ls_request-requested_qty ) = abap_false
      OR ls_request-minimum_fill_pct < 0
      OR ls_request-minimum_fill_pct > 100
      OR zcl_allocation_persistence=>quantity_is_persistable(
        ls_request-minimum_fill_pct ) = abap_false
      OR ls_request-priority <= 0 ).

    IF lv_structural_invalid = abap_false
        AND lv_numeric_invalid = abap_false
        AND lv_request_flag_invalid = abap_false
        AND lv_account_error IS INITIAL.
      rs_validation-is_valid = abap_true.
      RETURN.
    ENDIF.

    rs_validation-decision_code = COND #(
      WHEN lv_request_flag_invalid = abap_true
      THEN zcl_stock_allocator=>gc_decision_bad_request_flag
      WHEN lv_account_error IS NOT INITIAL
      THEN zcl_stock_allocator=>gc_decision_rule_invalid
      ELSE zcl_stock_allocator=>gc_decision_invalid_request ).
  ENDMETHOD.

  METHOD posting_matches_decision.
    CASE is_allocation-decision_code.
      WHEN zcl_stock_allocator=>gc_decision_fully_allocated
        OR zcl_stock_allocator=>gc_decision_partial.
        rv_valid = abap_true.
      WHEN zcl_stock_allocator=>gc_decision_replayed.
        rv_valid = xsdbool(
          is_allocation-posting_status =
            zcl_stock_allocator=>gc_posting_posted ).
      WHEN zcl_stock_allocator=>gc_decision_replay_missing.
        rv_valid = xsdbool(
          is_allocation-posting_status =
            zcl_stock_allocator=>gc_posting_failed ).
      WHEN OTHERS.
        rv_valid = xsdbool(
          is_allocation-posting_status =
            zcl_stock_allocator=>gc_posting_not_required ).
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
