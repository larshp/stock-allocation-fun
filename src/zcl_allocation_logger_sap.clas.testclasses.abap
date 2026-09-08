CLASS lcl_allocation_log_store DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_log_store.
    DATA mt_current TYPE zif_allocation_log_store=>ty_current_entries.
    DATA mt_history TYPE zif_allocation_log_store=>ty_history_entries.
    DATA mv_saved TYPE abap_bool VALUE abap_true.
    DATA mv_calls TYPE i.
ENDCLASS.

CLASS lcl_allocation_log_store IMPLEMENTATION.
  METHOD zif_allocation_log_store~save.
    mv_calls = mv_calls + 1.
    mt_current = it_current.
    mt_history = it_history.
    rv_saved = mv_saved.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_allocation_logger_sap DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_store TYPE REF TO lcl_allocation_log_store.
    DATA mo_cut TYPE REF TO zcl_allocation_logger_sap.

    METHODS setup.
    METHODS writes_current_and_history FOR TESTING.
    METHODS propagates_store_failure FOR TESTING.
    METHODS rejects_invalid_store_state FOR TESTING.
    METHODS rejects_initial_run_id FOR TESTING.
    METHODS rejects_nonhex_run_id FOR TESTING.
    METHODS rejects_oversized_batch FOR TESTING.
    METHODS rejects_spurious_batch_limit FOR TESTING.
    METHODS rejects_oversized_quantity FOR TESTING.
    METHODS rejects_imprecise_quantity FOR TESTING.
    METHODS rejects_invalid_outcome FOR TESTING.
    METHODS rejects_orphan_duplicate FOR TESTING.
    METHODS rejects_invalid_stock_request FOR TESTING.
    METHODS rejects_spurious_request_error FOR TESTING.
    METHODS accepts_exact_request_flag FOR TESTING.
    METHODS rejects_stock_account_rule FOR TESTING.
    METHODS rejects_partial_policy FOR TESTING.
    METHODS rejects_minimum_policy FOR TESTING.
    METHODS rejects_aborted_policy FOR TESTING.
    METHODS rejects_wrong_failure FOR TESTING.
    METHODS rejects_nonstock_lineage FOR TESTING.
    METHODS rejects_replay_policy FOR TESTING.
    METHODS rejects_wrong_run_mode FOR TESTING.
    METHODS rejects_simulated_replay_error FOR TESTING.
    METHODS rejects_bad_invalid_mode FOR TESTING.
    METHODS records_invalid_strategy FOR TESTING.
    METHODS rejects_bad_strategy_result FOR TESTING.
    METHODS records_invalid_full_policy FOR TESTING.
    METHODS records_invalid_horizon FOR TESTING.
    METHODS honors_run_error_precedence FOR TESTING.
    METHODS accepts_matching_horizon FOR TESTING.
    METHODS rejects_spurious_horizon FOR TESTING.
    METHODS rejects_spurious_batch_abort FOR TESTING.
    METHODS rejects_incomplete_strict_mix FOR TESTING.
    METHODS rejects_mixed_new_posting FOR TESTING.
    METHODS accepts_replay_with_failed_new FOR TESTING.
    METHODS accepts_max_log_message FOR TESTING.
    METHODS rejects_long_log_message FOR TESTING.
    METHODS records_invalid_run_mode FOR TESTING.
    METHODS rejects_missing_store FOR TESTING.
    METHODS accepts_empty_without_store FOR TESTING.

    METHODS allocations
      IMPORTING
        iv_simulation         TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_allocations) TYPE zcl_stock_allocator=>ty_allocations.
ENDCLASS.

CLASS ltcl_allocation_logger_sap IMPLEMENTATION.
  METHOD setup.
    mo_store = NEW #( ).
    mo_cut = NEW #( mo_store ).
  ENDMETHOD.

  METHOD writes_current_and_history.
    DATA(lt_allocations) = allocations( abap_true ).
    lt_allocations[ 2 ]-allocated_qty = 2.
    CLEAR lt_allocations[ 2 ]-shortfall_qty.
    lt_allocations[ 2 ]-fill_pct = 100.
    lt_allocations[ 2 ]-available_qty = 2.
    lt_allocations[ 2 ]-status =
      zcl_stock_allocator=>gc_status_allocated.
    lt_allocations[ 2 ]-decision_code =
      zcl_stock_allocator=>gc_decision_fully_allocated.
    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations        = lt_allocations
      iv_simulation         = abap_true
      iv_run_id             = '00112233445566778899AABBCCDDEEFF'
      iv_strategy           = zcl_stock_allocator=>gc_strategy_due_priority
      iv_horizon_date       = '20260831'
      iv_require_full_batch = abap_true ).

    cl_abap_unit_assert=>assert_true( lv_saved ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_store->mt_current )
      exp = 6 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_store->mt_history )
      exp = 6 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_current[ 1 ]-run_mode
      exp = 'S' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_current[ 1 ]-run_id
      exp = '00112233445566778899AABBCCDDEEFF' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 2 ]-run_id
      exp = mo_store->mt_current[ 1 ]-run_id ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 1 ]-unit_of_measure
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 1 ]-source_requested_qty
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 1 ]-source_unit
      exp = 'BOX' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 1 ]-requested_qty
      exp = 5 ).
    cl_abap_unit_assert=>assert_initial(
      mo_store->mt_current[ 1 ]-shortfall_qty ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_current[ 1 ]-fill_pct
      exp = 100 ).
    cl_abap_unit_assert=>assert_initial(
      mo_store->mt_history[ 1 ]-shortfall_qty ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 1 ]-fill_pct
      exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 1 ]-cost_center
      exp = 'CC1000' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 2 ]-sales_order_item
      exp = '000010' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 4 ]-network_activity
      exp = '0010' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 3 ]-asset_number
      exp = '000000123456' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 5 ]-order_id
      exp = 'ORDER-1' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 6 ]-wbs_element
      exp = 'PROJECT-1' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 1 ]-material
      exp = 'MAT-1' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 1 ]-storage_location
      exp = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 1 ]-minimum_fill_pct
      exp = 75 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 1 ]-allocation_strategy
      exp = zcl_stock_allocator=>gc_strategy_due_priority ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 1 ]-horizon_date
      exp = '20260831' ).
    cl_abap_unit_assert=>assert_true(
      mo_store->mt_history[ 1 ]-require_full_batch ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 1 ]-prior_reservation_id
      exp = '' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_fully_allocated ).
    cl_abap_unit_assert=>assert_true(
      mo_store->mt_history[ 1 ]-availability_checked ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 1 ]-available_qty
      exp = 9 ).
    cl_abap_unit_assert=>assert_not_initial(
      act = mo_store->mt_history[ 1 ]-log_uuid ).
    cl_abap_unit_assert=>assert_differs(
      act = mo_store->mt_history[ 1 ]-log_uuid
      exp = mo_store->mt_history[ 2 ]-log_uuid ).
  ENDMETHOD.

  METHOD propagates_store_failure.
    mo_store->mv_saved = abap_false.

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = allocations( )
      iv_simulation  = abap_false
      iv_run_id      = 'FFEEDDCCBBAA99887766554433221100'
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_current[ 1 ]-run_mode
      exp = 'P' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 1 ]-prior_reservation_id
      exp = '0000000041' ).
  ENDMETHOD.

  METHOD rejects_invalid_store_state.
    mo_store->mv_saved = 'Y'.

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = allocations( )
      iv_simulation  = abap_false
      iv_run_id      = 'FFEEDDCCBBAA99887766554433221100'
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
  ENDMETHOD.

  METHOD rejects_initial_run_id.
    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = allocations( )
      iv_simulation  = abap_false
      iv_run_id      = ''
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
    cl_abap_unit_assert=>assert_initial( mo_store->mv_calls ).
  ENDMETHOD.

  METHOD rejects_nonhex_run_id.
    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = allocations( )
      iv_simulation  = abap_false
      iv_run_id      = '00112233445566778899AABBCCDDEEFG'
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
    cl_abap_unit_assert=>assert_initial( mo_store->mv_calls ).
  ENDMETHOD.

  METHOD rejects_oversized_batch.
    DATA(lt_allocations) = allocations( ).
    DO 999 TIMES.
      APPEND lt_allocations[ 1 ] TO lt_allocations.
    ENDDO.

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = lt_allocations
      iv_simulation  = abap_false
      iv_run_id      = 'FFEEDDCCBBAA99887766554433221100'
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
    cl_abap_unit_assert=>assert_initial( mo_store->mv_calls ).
  ENDMETHOD.

  METHOD rejects_spurious_batch_limit.
    DATA(lt_allocations) = VALUE zcl_stock_allocator=>ty_allocations(
      ( request_id     = 'LOG-BATCH-LIMIT'
        status         = zcl_stock_allocator=>gc_status_config_error
        decision_code  = zcl_stock_allocator=>gc_decision_batch_too_large
        posting_status =
          zcl_stock_allocator=>gc_posting_not_required ) ).

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = lt_allocations
      iv_simulation  = abap_false
      iv_run_id      = '11223344556677889900AABBCCDDEEFF'
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
    cl_abap_unit_assert=>assert_initial( mo_store->mv_calls ).
  ENDMETHOD.

  METHOD rejects_oversized_quantity.
    DATA(lt_allocations) = allocations( ).
    lt_allocations[ 1 ]-source_requested_qty = '10000000000'.

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = lt_allocations
      iv_simulation  = abap_false
      iv_run_id      = 'FFEEDDCCBBAA99887766554433221100'
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
    cl_abap_unit_assert=>assert_initial( mo_store->mv_calls ).
    cl_abap_unit_assert=>assert_initial( mo_store->mt_current ).
    cl_abap_unit_assert=>assert_initial( mo_store->mt_history ).
  ENDMETHOD.

  METHOD rejects_imprecise_quantity.
    DATA(lt_allocations) = allocations( ).
    lt_allocations[ 1 ]-requested_qty = '1.0001'.

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = lt_allocations
      iv_simulation  = abap_false
      iv_run_id      = 'FFEEDDCCBBAA99887766554433221100'
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
    cl_abap_unit_assert=>assert_initial( mo_store->mv_calls ).
    cl_abap_unit_assert=>assert_initial( mo_store->mt_current ).
    cl_abap_unit_assert=>assert_initial( mo_store->mt_history ).
  ENDMETHOD.

  METHOD rejects_invalid_outcome.
    DATA(lt_allocations) = allocations( ).
    lt_allocations[ 1 ]-shortfall_qty = 1.

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = lt_allocations
      iv_simulation  = abap_false
      iv_run_id      = 'FFEEDDCCBBAA99887766554433221100'
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
    cl_abap_unit_assert=>assert_initial( mo_store->mv_calls ).
  ENDMETHOD.

  METHOD rejects_orphan_duplicate.
    DATA(lt_allocations) = VALUE zcl_stock_allocator=>ty_allocations(
      ( request_id     = 'LOG-DUPLICATE'
        status         = zcl_stock_allocator=>gc_status_invalid
        decision_code  = zcl_stock_allocator=>gc_decision_duplicate_request
        posting_status =
          zcl_stock_allocator=>gc_posting_not_required ) ).

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = lt_allocations
      iv_simulation  = abap_false
      iv_run_id      = '11223344556677889900AABBCCDDEEFF'
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
    cl_abap_unit_assert=>assert_initial( mo_store->mv_calls ).
  ENDMETHOD.

  METHOD rejects_invalid_stock_request.
    DATA(lt_allocations) = allocations( ).
    lt_allocations[ 2 ]-requirement_date = '20260230'.

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = lt_allocations
      iv_simulation  = abap_false
      iv_run_id      = 'FFEEDDCCBBAA99887766554433221100'
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
    cl_abap_unit_assert=>assert_initial( mo_store->mv_calls ).
  ENDMETHOD.

  METHOD rejects_spurious_request_error.
    DATA(lt_allocations) = allocations( ).
    DELETE lt_allocations FROM 2.
    CLEAR lt_allocations[ 1 ]-allocated_qty.
    lt_allocations[ 1 ]-shortfall_qty = 5.
    CLEAR lt_allocations[ 1 ]-fill_pct.
    CLEAR lt_allocations[ 1 ]-availability_checked.
    CLEAR lt_allocations[ 1 ]-available_qty.
    lt_allocations[ 1 ]-status = zcl_stock_allocator=>gc_status_invalid.
    lt_allocations[ 1 ]-decision_code =
      zcl_stock_allocator=>gc_decision_invalid_request.
    lt_allocations[ 1 ]-posting_status =
      zcl_stock_allocator=>gc_posting_not_required.
    CLEAR lt_allocations[ 1 ]-document_id.
    CLEAR lt_allocations[ 1 ]-replaced_document_id.

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = lt_allocations
      iv_simulation  = abap_false
      iv_run_id      = '11223344556677889900AABBCCDDEEFF'
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
    cl_abap_unit_assert=>assert_initial( mo_store->mv_calls ).
  ENDMETHOD.

  METHOD accepts_exact_request_flag.
    DATA(lt_allocations) = allocations( ).
    DELETE lt_allocations FROM 2.
    CLEAR lt_allocations[ 1 ]-allocated_qty.
    lt_allocations[ 1 ]-shortfall_qty = 5.
    CLEAR lt_allocations[ 1 ]-fill_pct.
    CLEAR lt_allocations[ 1 ]-availability_checked.
    CLEAR lt_allocations[ 1 ]-available_qty.
    lt_allocations[ 1 ]-allow_partial = 'Y'.
    lt_allocations[ 1 ]-status = zcl_stock_allocator=>gc_status_invalid.
    lt_allocations[ 1 ]-decision_code =
      zcl_stock_allocator=>gc_decision_bad_request_flag.
    lt_allocations[ 1 ]-posting_status =
      zcl_stock_allocator=>gc_posting_not_required.
    CLEAR lt_allocations[ 1 ]-document_id.
    CLEAR lt_allocations[ 1 ]-replaced_document_id.

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = lt_allocations
      iv_simulation  = abap_false
      iv_run_id      = '11223344556677889900AABBCCDDEEFF'
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_true( lv_saved ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_current[ 1 ]-allow_partial
      exp = 'Y' ).
  ENDMETHOD.

  METHOD rejects_stock_account_rule.
    DATA(lt_allocations) = allocations( ).
    CLEAR lt_allocations[ 2 ]-sales_order.

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = lt_allocations
      iv_simulation  = abap_false
      iv_run_id      = 'FFEEDDCCBBAA99887766554433221100'
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
    cl_abap_unit_assert=>assert_initial( mo_store->mv_calls ).
  ENDMETHOD.

  METHOD rejects_partial_policy.
    DATA(lt_allocations) = allocations( ).
    lt_allocations[ 2 ]-allow_partial = abap_false.

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = lt_allocations
      iv_simulation  = abap_false
      iv_run_id      = 'FFEEDDCCBBAA99887766554433221100'
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
    cl_abap_unit_assert=>assert_initial( mo_store->mv_calls ).
  ENDMETHOD.

  METHOD rejects_minimum_policy.
    DATA(lt_allocations) = allocations( ).
    lt_allocations[ 2 ]-allocated_qty = 0.
    lt_allocations[ 2 ]-shortfall_qty = 2.
    lt_allocations[ 2 ]-fill_pct = 0.
    lt_allocations[ 2 ]-minimum_fill_pct = 50.
    lt_allocations[ 2 ]-status =
      zcl_stock_allocator=>gc_status_rejected.
    lt_allocations[ 2 ]-decision_code =
      zcl_stock_allocator=>gc_decision_below_minimum_fill.
    lt_allocations[ 2 ]-posting_status =
      zcl_stock_allocator=>gc_posting_not_required.
    CLEAR lt_allocations[ 2 ]-document_id.

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = lt_allocations
      iv_simulation  = abap_false
      iv_run_id      = 'FFEEDDCCBBAA99887766554433221100'
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
    cl_abap_unit_assert=>assert_initial( mo_store->mv_calls ).
  ENDMETHOD.

  METHOD rejects_aborted_policy.
    DATA(lt_allocations) = allocations( ).
    lt_allocations[ 2 ]-allocated_qty = 0.
    lt_allocations[ 2 ]-shortfall_qty = 2.
    lt_allocations[ 2 ]-fill_pct = 0.
    lt_allocations[ 2 ]-allow_partial = abap_false.
    lt_allocations[ 2 ]-status = zcl_stock_allocator=>gc_status_aborted.
    lt_allocations[ 2 ]-decision_code =
      zcl_stock_allocator=>gc_decision_full_batch_aborted.
    lt_allocations[ 2 ]-posting_status =
      zcl_stock_allocator=>gc_posting_not_required.
    CLEAR lt_allocations[ 2 ]-document_id.

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = lt_allocations
      iv_simulation  = abap_false
      iv_run_id      = 'FFEEDDCCBBAA99887766554433221100'
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
    cl_abap_unit_assert=>assert_initial( mo_store->mv_calls ).
  ENDMETHOD.

  METHOD rejects_wrong_failure.
    DATA(lt_allocations) = allocations( ).
    lt_allocations[ 1 ]-allocated_qty = 0.
    lt_allocations[ 1 ]-shortfall_qty = 5.
    lt_allocations[ 1 ]-fill_pct = 0.
    lt_allocations[ 1 ]-availability_checked = abap_false.
    lt_allocations[ 1 ]-available_qty = 0.
    lt_allocations[ 1 ]-status = zcl_stock_allocator=>gc_status_invalid.
    lt_allocations[ 1 ]-decision_code =
      zcl_stock_allocator=>gc_decision_invalid_request.
    lt_allocations[ 1 ]-posting_status =
      zcl_stock_allocator=>gc_posting_failed.
    CLEAR lt_allocations[ 1 ]-document_id.
    CLEAR lt_allocations[ 1 ]-replaced_document_id.

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = lt_allocations
      iv_simulation  = abap_false
      iv_run_id      = 'FFEEDDCCBBAA99887766554433221100'
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
    cl_abap_unit_assert=>assert_initial( mo_store->mv_calls ).
  ENDMETHOD.

  METHOD rejects_nonstock_lineage.
    DATA(lt_allocations) = allocations( ).
    lt_allocations[ 1 ]-allocated_qty = 0.
    lt_allocations[ 1 ]-shortfall_qty = 5.
    lt_allocations[ 1 ]-fill_pct = 0.
    lt_allocations[ 1 ]-availability_checked = abap_false.
    lt_allocations[ 1 ]-available_qty = 0.
    lt_allocations[ 1 ]-status = zcl_stock_allocator=>gc_status_invalid.
    lt_allocations[ 1 ]-decision_code =
      zcl_stock_allocator=>gc_decision_invalid_request.
    lt_allocations[ 1 ]-posting_status =
      zcl_stock_allocator=>gc_posting_not_required.
    CLEAR lt_allocations[ 1 ]-document_id.

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = lt_allocations
      iv_simulation  = abap_false
      iv_run_id      = 'FFEEDDCCBBAA99887766554433221100'
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
    cl_abap_unit_assert=>assert_initial( mo_store->mv_calls ).
  ENDMETHOD.

  METHOD rejects_replay_policy.
    DATA(lt_allocations) = allocations( ).
    lt_allocations[ 1 ]-allocated_qty = 4.
    lt_allocations[ 1 ]-shortfall_qty = 1.
    lt_allocations[ 1 ]-fill_pct = 80.
    lt_allocations[ 1 ]-allow_partial = abap_false.
    lt_allocations[ 1 ]-availability_checked = abap_false.
    lt_allocations[ 1 ]-available_qty = 0.
    lt_allocations[ 1 ]-status = zcl_stock_allocator=>gc_status_partial.
    lt_allocations[ 1 ]-decision_code =
      zcl_stock_allocator=>gc_decision_replayed.
    CLEAR lt_allocations[ 1 ]-replaced_document_id.

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = lt_allocations
      iv_simulation  = abap_false
      iv_run_id      = 'FFEEDDCCBBAA99887766554433221100'
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
    cl_abap_unit_assert=>assert_initial( mo_store->mv_calls ).
  ENDMETHOD.

  METHOD rejects_wrong_run_mode.
    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = allocations( abap_true )
      iv_simulation  = abap_false
      iv_run_id      = 'FFEEDDCCBBAA99887766554433221100'
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
    cl_abap_unit_assert=>assert_initial( mo_store->mv_calls ).
  ENDMETHOD.

  METHOD rejects_simulated_replay_error.
    DATA(lt_allocations) = VALUE zcl_stock_allocator=>ty_allocations(
      ( request_id     = 'LOG-SIM-REPLAY'
        status         = zcl_stock_allocator=>gc_status_config_error
        decision_code  = zcl_stock_allocator=>gc_decision_replay_lookup
        posting_status =
          zcl_stock_allocator=>gc_posting_not_required ) ).

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = lt_allocations
      iv_simulation  = abap_true
      iv_run_id      = '11223344556677889900AABBCCDDEEFF'
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
    cl_abap_unit_assert=>assert_initial( mo_store->mv_calls ).
  ENDMETHOD.

  METHOD rejects_bad_invalid_mode.
    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = allocations( )
      iv_simulation  = 'Y'
      iv_run_id      = '11223344556677889900AABBCCDDEEFF'
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
    cl_abap_unit_assert=>assert_initial( mo_store->mv_calls ).
  ENDMETHOD.

  METHOD records_invalid_strategy.
    DATA(lt_allocations) = VALUE zcl_stock_allocator=>ty_allocations(
      ( request_id     = 'LOG-BAD-STRATEGY'
        status         = zcl_stock_allocator=>gc_status_config_error
        decision_code  = zcl_stock_allocator=>gc_decision_bad_strategy
        posting_status =
          zcl_stock_allocator=>gc_posting_not_required ) ).

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = lt_allocations
      iv_simulation  = abap_false
      iv_run_id      = '11223344556677889900AABBCCDDEEFF'
      iv_strategy    = 'CUSTOM' ).

    cl_abap_unit_assert=>assert_true( lv_saved ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_current[ 1 ]-allocation_strategy
      exp = 'CUSTOM' ).
  ENDMETHOD.

  METHOD rejects_bad_strategy_result.
    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = allocations( )
      iv_simulation  = abap_false
      iv_run_id      = '11223344556677889900AABBCCDDEEFF'
      iv_strategy    = 'CUSTOM' ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
    cl_abap_unit_assert=>assert_initial( mo_store->mv_calls ).
  ENDMETHOD.

  METHOD records_invalid_full_policy.
    DATA(lt_allocations) = VALUE zcl_stock_allocator=>ty_allocations(
      ( request_id     = 'LOG-BAD-FULL-POLICY'
        status         = zcl_stock_allocator=>gc_status_config_error
        decision_code  =
          zcl_stock_allocator=>gc_decision_run_policy_invalid
        posting_status =
          zcl_stock_allocator=>gc_posting_not_required ) ).

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations        = lt_allocations
      iv_simulation         = abap_false
      iv_run_id             = '11223344556677889900AABBCCDDEEFF'
      iv_strategy           = zcl_stock_allocator=>gc_strategy_priority_due
      iv_require_full_batch = 'Y' ).

    cl_abap_unit_assert=>assert_true( lv_saved ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_current[ 1 ]-require_full_batch
      exp = 'Y' ).
  ENDMETHOD.

  METHOD records_invalid_horizon.
    DATA(lt_allocations) = VALUE zcl_stock_allocator=>ty_allocations(
      ( request_id     = 'LOG-BAD-HORIZON'
        status         = zcl_stock_allocator=>gc_status_config_error
        decision_code  = zcl_stock_allocator=>gc_decision_horizon_invalid
        posting_status =
          zcl_stock_allocator=>gc_posting_not_required ) ).

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations  = lt_allocations
      iv_simulation   = abap_false
      iv_run_id       = '11223344556677889900AABBCCDDEEFF'
      iv_strategy     = zcl_stock_allocator=>gc_strategy_priority_due
      iv_horizon_date = '20260230' ).

    cl_abap_unit_assert=>assert_true( lv_saved ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_current[ 1 ]-horizon_date
      exp = '20260230' ).
  ENDMETHOD.

  METHOD honors_run_error_precedence.
    DATA(lt_allocations) = VALUE zcl_stock_allocator=>ty_allocations(
      ( request_id     = 'LOG-WRONG-PRECEDENCE'
        status         = zcl_stock_allocator=>gc_status_config_error
        decision_code  = zcl_stock_allocator=>gc_decision_bad_strategy
        posting_status =
          zcl_stock_allocator=>gc_posting_not_required ) ).

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations        = lt_allocations
      iv_simulation         = 'Y'
      iv_run_id             = '11223344556677889900AABBCCDDEEFF'
      iv_strategy           = 'CUSTOM'
      iv_horizon_date       = '20260230'
      iv_require_full_batch = 'Y' ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
    cl_abap_unit_assert=>assert_initial( mo_store->mv_calls ).
  ENDMETHOD.

  METHOD accepts_matching_horizon.
    DATA(lt_allocations) = allocations( abap_true ).
    DELETE lt_allocations FROM 2.
    CLEAR lt_allocations[ 1 ]-allocated_qty.
    lt_allocations[ 1 ]-shortfall_qty = 5.
    CLEAR lt_allocations[ 1 ]-fill_pct.
    CLEAR lt_allocations[ 1 ]-availability_checked.
    CLEAR lt_allocations[ 1 ]-available_qty.
    lt_allocations[ 1 ]-status = zcl_stock_allocator=>gc_status_deferred.
    lt_allocations[ 1 ]-decision_code =
      zcl_stock_allocator=>gc_decision_outside_horizon.
    lt_allocations[ 1 ]-posting_status =
      zcl_stock_allocator=>gc_posting_not_required.
    CLEAR lt_allocations[ 1 ]-document_id.
    CLEAR lt_allocations[ 1 ]-replaced_document_id.

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations  = lt_allocations
      iv_simulation   = abap_true
      iv_run_id       = '11223344556677889900AABBCCDDEEFF'
      iv_strategy     = zcl_stock_allocator=>gc_strategy_priority_due
      iv_horizon_date = '20260817' ).

    cl_abap_unit_assert=>assert_true( lv_saved ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_current[ 1 ]-horizon_date
      exp = '20260817' ).
  ENDMETHOD.

  METHOD rejects_spurious_horizon.
    DATA(lt_allocations) = allocations( abap_true ).
    DELETE lt_allocations FROM 2.
    CLEAR lt_allocations[ 1 ]-allocated_qty.
    lt_allocations[ 1 ]-shortfall_qty = 5.
    CLEAR lt_allocations[ 1 ]-fill_pct.
    CLEAR lt_allocations[ 1 ]-availability_checked.
    CLEAR lt_allocations[ 1 ]-available_qty.
    lt_allocations[ 1 ]-status = zcl_stock_allocator=>gc_status_deferred.
    lt_allocations[ 1 ]-decision_code =
      zcl_stock_allocator=>gc_decision_outside_horizon.
    lt_allocations[ 1 ]-posting_status =
      zcl_stock_allocator=>gc_posting_not_required.
    CLEAR lt_allocations[ 1 ]-document_id.
    CLEAR lt_allocations[ 1 ]-replaced_document_id.

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = lt_allocations
      iv_simulation  = abap_true
      iv_run_id      = '11223344556677889900AABBCCDDEEFF'
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
    cl_abap_unit_assert=>assert_initial( mo_store->mv_calls ).
  ENDMETHOD.

  METHOD rejects_spurious_batch_abort.
    DATA(lt_allocations) = allocations( ).
    DELETE lt_allocations FROM 2.
    CLEAR lt_allocations[ 1 ]-allocated_qty.
    lt_allocations[ 1 ]-shortfall_qty = 5.
    CLEAR lt_allocations[ 1 ]-fill_pct.
    lt_allocations[ 1 ]-status = zcl_stock_allocator=>gc_status_aborted.
    lt_allocations[ 1 ]-decision_code =
      zcl_stock_allocator=>gc_decision_full_batch_aborted.
    lt_allocations[ 1 ]-posting_status =
      zcl_stock_allocator=>gc_posting_not_required.
    CLEAR lt_allocations[ 1 ]-document_id.

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = lt_allocations
      iv_simulation  = abap_false
      iv_run_id      = '11223344556677889900AABBCCDDEEFF'
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
    cl_abap_unit_assert=>assert_initial( mo_store->mv_calls ).
  ENDMETHOD.

  METHOD rejects_incomplete_strict_mix.
    DATA(lt_allocations) = allocations( ).
    DELETE lt_allocations FROM 3.
    CLEAR lt_allocations[ 2 ]-allocated_qty.
    lt_allocations[ 2 ]-shortfall_qty = 2.
    CLEAR lt_allocations[ 2 ]-fill_pct.
    CLEAR lt_allocations[ 2 ]-available_qty.
    lt_allocations[ 2 ]-status = zcl_stock_allocator=>gc_status_rejected.
    lt_allocations[ 2 ]-decision_code =
      zcl_stock_allocator=>gc_decision_no_available_stock.
    lt_allocations[ 2 ]-posting_status =
      zcl_stock_allocator=>gc_posting_not_required.
    CLEAR lt_allocations[ 2 ]-document_id.

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations        = lt_allocations
      iv_simulation         = abap_false
      iv_run_id             = '11223344556677889900AABBCCDDEEFF'
      iv_strategy           = zcl_stock_allocator=>gc_strategy_priority_due
      iv_require_full_batch = abap_true ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
    cl_abap_unit_assert=>assert_initial( mo_store->mv_calls ).
  ENDMETHOD.

  METHOD rejects_mixed_new_posting.
    DATA(lt_allocations) = allocations( ).
    DELETE lt_allocations FROM 3.
    lt_allocations[ 2 ]-posting_status =
      zcl_stock_allocator=>gc_posting_failed.
    CLEAR lt_allocations[ 2 ]-document_id.

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = lt_allocations
      iv_simulation  = abap_false
      iv_run_id      = '11223344556677889900AABBCCDDEEFF'
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
    cl_abap_unit_assert=>assert_initial( mo_store->mv_calls ).
  ENDMETHOD.

  METHOD accepts_replay_with_failed_new.
    DATA(lt_allocations) = allocations( ).
    DELETE lt_allocations FROM 3.
    lt_allocations[ 1 ]-decision_code =
      zcl_stock_allocator=>gc_decision_replayed.
    CLEAR lt_allocations[ 1 ]-availability_checked.
    CLEAR lt_allocations[ 1 ]-available_qty.
    CLEAR lt_allocations[ 1 ]-replaced_document_id.
    lt_allocations[ 2 ]-posting_status =
      zcl_stock_allocator=>gc_posting_failed.
    CLEAR lt_allocations[ 2 ]-document_id.

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = lt_allocations
      iv_simulation  = abap_false
      iv_run_id      = '11223344556677889900AABBCCDDEEFF'
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_true( lv_saved ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_store->mt_current )
      exp = 2 ).
  ENDMETHOD.

  METHOD accepts_max_log_message.
    DATA(lt_allocations) = allocations( ).
    lt_allocations[ 1 ]-posting_message =
      repeat( val = 'X' occ = 220 ).

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = lt_allocations
      iv_simulation  = abap_false
      iv_run_id      = 'FFEEDDCCBBAA99887766554433221100'
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_true( lv_saved ).
    cl_abap_unit_assert=>assert_equals(
      act = strlen( mo_store->mt_current[ 1 ]-log_message )
      exp = 220 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 1 ]-log_message
      exp = mo_store->mt_current[ 1 ]-log_message ).
  ENDMETHOD.

  METHOD rejects_long_log_message.
    DATA(lt_allocations) = allocations( ).
    lt_allocations[ 1 ]-posting_message =
      repeat( val = 'X' occ = 221 ).

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = lt_allocations
      iv_simulation  = abap_false
      iv_run_id      = 'FFEEDDCCBBAA99887766554433221100'
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
    cl_abap_unit_assert=>assert_initial( mo_store->mv_calls ).
  ENDMETHOD.

  METHOD records_invalid_run_mode.
    DATA(lt_allocations) = VALUE zcl_stock_allocator=>ty_allocations(
      ( request_id     = 'LOG-INVALID-MODE'
        status         = zcl_stock_allocator=>gc_status_config_error
        decision_code  =
          zcl_stock_allocator=>gc_decision_run_policy_invalid
        posting_status =
          zcl_stock_allocator=>gc_posting_not_required ) ).
    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = lt_allocations
      iv_simulation  = 'Y'
      iv_run_id      = '11223344556677889900AABBCCDDEEFF'
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_true( lv_saved ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_current[ 1 ]-run_mode
      exp = 'I' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 1 ]-run_mode
      exp = 'I' ).
  ENDMETHOD.

  METHOD rejects_missing_store.
    DATA lo_store TYPE REF TO zif_allocation_log_store.
    mo_cut = NEW #( lo_store ).

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = allocations( )
      iv_simulation  = abap_false
      iv_run_id      = 'FFEEDDCCBBAA99887766554433221100'
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
  ENDMETHOD.

  METHOD accepts_empty_without_store.
    DATA lo_store TYPE REF TO zif_allocation_log_store.
    mo_cut = NEW #( lo_store ).

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = VALUE #( )
      iv_simulation  = abap_false
      iv_run_id      = ''
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_true( lv_saved ).
  ENDMETHOD.

  METHOD allocations.
    rt_allocations = VALUE #(
      ( request_id             = 'LOG-1'
        material               = 'MAT-1'
        plant                  = '1000'
        storage_location       = '0001'
        movement_type          = '201'
        cost_center            = 'CC1000'
        requirement_date       = '20260818'
        minimum_fill_pct       = 75
        priority               = 10
        allow_partial          = abap_true
        allocated_qty          = 5
        requested_qty          = 5
        shortfall_qty          = 0
        fill_pct               = 100
        unit_of_measure        = 'EA'
        source_requested_qty   = 1
        source_unit_of_measure = 'BOX'
        status                 = zcl_stock_allocator=>gc_status_allocated
        decision_code          = zcl_stock_allocator=>gc_decision_fully_allocated
        posting_status         = COND #(
          WHEN iv_simulation = abap_true
          THEN zcl_stock_allocator=>gc_posting_simulated
          ELSE zcl_stock_allocator=>gc_posting_posted )
        availability_checked   = abap_true
        available_qty          = 9
        document_id            = COND #(
          WHEN iv_simulation = abap_false
          THEN '0000000001'
          ELSE '' )
        replaced_document_id   = COND #(
          WHEN iv_simulation = abap_false
          THEN '0000000041'
          ELSE '' ) )
      ( request_id             = 'LOG-2'
        material               = 'MAT-2'
        plant                  = '1000'
        storage_location       = '0001'
        movement_type          = '231'
        sales_order            = '0000123456'
        sales_order_item       = '000010'
        requirement_date       = '20260818'
        minimum_fill_pct       = 40
        priority               = 20
        allow_partial          = abap_true
        allocated_qty          = 1
        requested_qty          = 2
        shortfall_qty          = 1
        fill_pct               = 50
        unit_of_measure        = 'EA'
        source_requested_qty   = 2
        source_unit_of_measure = 'EA'
        status                 = zcl_stock_allocator=>gc_status_partial
        decision_code          = zcl_stock_allocator=>gc_decision_partial
        posting_status         = COND #(
          WHEN iv_simulation = abap_true
          THEN zcl_stock_allocator=>gc_posting_simulated
          ELSE zcl_stock_allocator=>gc_posting_posted )
        availability_checked   = abap_true
        available_qty          = 1
        document_id            = COND #(
          WHEN iv_simulation = abap_false
          THEN '0000000002'
          ELSE '' )
        posting_message        = 'Simulation only' )
      ( request_id             = 'LOG-3'
        material               = 'MAT-3'
        plant                  = '1000'
        storage_location       = '0001'
        movement_type          = '241'
        asset_number           = '000000123456'
        asset_subnumber        = '0000'
        requirement_date       = '20260818'
        priority               = 30
        allocated_qty          = 1
        requested_qty          = 1
        fill_pct               = 100
        unit_of_measure        = 'EA'
        source_requested_qty   = 1
        source_unit_of_measure = 'EA'
        status                 = zcl_stock_allocator=>gc_status_allocated
        decision_code          =
          zcl_stock_allocator=>gc_decision_fully_allocated
        posting_status         = COND #(
          WHEN iv_simulation = abap_true
          THEN zcl_stock_allocator=>gc_posting_simulated
          ELSE zcl_stock_allocator=>gc_posting_posted )
        availability_checked   = abap_true
        available_qty          = 2
        document_id            = COND #(
          WHEN iv_simulation = abap_false
          THEN '0000000003'
          ELSE '' ) )
      ( request_id             = 'LOG-4'
        material               = 'MAT-4'
        plant                  = '1000'
        storage_location       = '0001'
        movement_type          = '281'
        network_id             = '000001234567'
        network_activity       = '0010'
        requirement_date       = '20260818'
        priority               = 40
        allocated_qty          = 1
        requested_qty          = 1
        fill_pct               = 100
        unit_of_measure        = 'EA'
        source_requested_qty   = 1
        source_unit_of_measure = 'EA'
        status                 = zcl_stock_allocator=>gc_status_allocated
        decision_code          =
          zcl_stock_allocator=>gc_decision_fully_allocated
        posting_status         = COND #(
          WHEN iv_simulation = abap_true
          THEN zcl_stock_allocator=>gc_posting_simulated
          ELSE zcl_stock_allocator=>gc_posting_posted )
        availability_checked   = abap_true
        available_qty          = 2
        document_id            = COND #(
          WHEN iv_simulation = abap_false
          THEN '0000000004'
          ELSE '' ) )
      ( request_id             = 'LOG-5'
        material               = 'MAT-5'
        plant                  = '1000'
        storage_location       = '0001'
        movement_type          = '261'
        order_id               = 'ORDER-1'
        requirement_date       = '20260818'
        priority               = 50
        allocated_qty          = 1
        requested_qty          = 1
        fill_pct               = 100
        unit_of_measure        = 'EA'
        source_requested_qty   = 1
        source_unit_of_measure = 'EA'
        status                 = zcl_stock_allocator=>gc_status_allocated
        decision_code          =
          zcl_stock_allocator=>gc_decision_fully_allocated
        posting_status         = COND #(
          WHEN iv_simulation = abap_true
          THEN zcl_stock_allocator=>gc_posting_simulated
          ELSE zcl_stock_allocator=>gc_posting_posted )
        availability_checked   = abap_true
        available_qty          = 2
        document_id            = COND #(
          WHEN iv_simulation = abap_false
          THEN '0000000005'
          ELSE '' ) )
      ( request_id             = 'LOG-6'
        material               = 'MAT-6'
        plant                  = '1000'
        storage_location       = '0001'
        movement_type          = '221'
        wbs_element            = 'PROJECT-1'
        requirement_date       = '20260818'
        priority               = 60
        allocated_qty          = 1
        requested_qty          = 1
        fill_pct               = 100
        unit_of_measure        = 'EA'
        source_requested_qty   = 1
        source_unit_of_measure = 'EA'
        status                 = zcl_stock_allocator=>gc_status_allocated
        decision_code          =
          zcl_stock_allocator=>gc_decision_fully_allocated
        posting_status         = COND #(
          WHEN iv_simulation = abap_true
          THEN zcl_stock_allocator=>gc_posting_simulated
          ELSE zcl_stock_allocator=>gc_posting_posted )
        availability_checked   = abap_true
        available_qty          = 2
        document_id            = COND #(
          WHEN iv_simulation = abap_false
          THEN '0000000006'
          ELSE '' ) ) ).
  ENDMETHOD.
ENDCLASS.
