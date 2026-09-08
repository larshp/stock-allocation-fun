CLASS ltcl_allocation_log_store_sap DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_allocation_log_store_sap.

    METHODS setup.
    METHODS accepts_empty_log_batch FOR TESTING.
    METHODS rejects_orphan_current FOR TESTING.
    METHODS rejects_orphan_history FOR TESTING.
    METHODS rejects_misaligned_log_rows FOR TESTING.
    METHODS rejects_initial_history_uuid FOR TESTING.
    METHODS rejects_duplicate_history_uuid FOR TESTING.
    METHODS rejects_oversized_log_batch FOR TESTING.
    METHODS rejects_spurious_batch_limit FOR TESTING.
    METHODS rejects_invalid_outcome FOR TESTING.
    METHODS rejects_mixed_run_context FOR TESTING.
    METHODS rejects_mixed_run_policy FOR TESTING.
    METHODS rejects_invalid_mode_outcome FOR TESTING.
    METHODS rejects_wrong_run_control FOR TESTING.
    METHODS rejects_simulated_replay_error FOR TESTING.
    METHODS rejects_invalid_log_time FOR TESTING.
    METHODS rejects_invalid_simulation FOR TESTING.
    METHODS rejects_initial_cutoff FOR TESTING.
    METHODS rejects_invalid_cutoff FOR TESTING.
    METHODS rejects_current_cutoff FOR TESTING.

    METHODS current_entry
      RETURNING
        VALUE(rs_entry) TYPE zstock_alog.
ENDCLASS.

CLASS ltcl_allocation_log_store_sap IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD accepts_empty_log_batch.
    DATA(lv_saved) = mo_cut->zif_allocation_log_store~save(
      it_current = VALUE #( )
      it_history = VALUE #( ) ).

    cl_abap_unit_assert=>assert_true( lv_saved ).
  ENDMETHOD.

  METHOD rejects_orphan_current.
    DATA(lv_saved) = mo_cut->zif_allocation_log_store~save(
      it_current = VALUE #( ( request_id = 'ORPHAN-CURRENT' ) )
      it_history = VALUE #( ) ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
  ENDMETHOD.

  METHOD rejects_orphan_history.
    DATA(lv_saved) = mo_cut->zif_allocation_log_store~save(
      it_current = VALUE #( )
      it_history = VALUE #( ( request_id = 'ORPHAN-HISTORY' ) ) ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
  ENDMETHOD.

  METHOD rejects_misaligned_log_rows.
    DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static( ).
    DATA(lv_saved) = mo_cut->zif_allocation_log_store~save(
      it_current = VALUE #( ( request_id = 'CURRENT-REQUEST' ) )
      it_history = VALUE #(
        ( log_uuid   = lv_uuid
          request_id = 'HISTORY-REQUEST' ) ) ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
  ENDMETHOD.

  METHOD rejects_initial_history_uuid.
    DATA(lv_saved) = mo_cut->zif_allocation_log_store~save(
      it_current = VALUE #( ( request_id = 'REQUEST-1' ) )
      it_history = VALUE #( ( request_id = 'REQUEST-1' ) ) ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
  ENDMETHOD.

  METHOD rejects_duplicate_history_uuid.
    DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static( ).
    DATA(lv_saved) = mo_cut->zif_allocation_log_store~save(
      it_current = VALUE #(
        ( request_id = 'REQUEST-1' )
        ( request_id = 'REQUEST-2' ) )
      it_history = VALUE #(
        ( log_uuid   = lv_uuid
          request_id = 'REQUEST-1' )
        ( log_uuid   = lv_uuid
          request_id = 'REQUEST-2' ) ) ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
  ENDMETHOD.

  METHOD rejects_oversized_log_batch.
    DATA lt_current TYPE zif_allocation_log_store=>ty_current_entries.
    DATA lt_history TYPE zif_allocation_log_store=>ty_history_entries.
    DO 1001 TIMES.
      APPEND INITIAL LINE TO lt_current.
      APPEND INITIAL LINE TO lt_history.
    ENDDO.

    DATA(lv_saved) = mo_cut->zif_allocation_log_store~save(
      it_current = lt_current
      it_history = lt_history ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
  ENDMETHOD.

  METHOD rejects_spurious_batch_limit.
    DATA(ls_current) = current_entry( ).
    ls_current-allocation_status =
      zcl_stock_allocator=>gc_status_config_error.
    ls_current-decision_code =
      zcl_stock_allocator=>gc_decision_batch_too_large.
    DATA ls_history TYPE zstock_algh.
    MOVE-CORRESPONDING ls_current TO ls_history.
    ls_history-log_uuid = cl_system_uuid=>create_uuid_x16_static( ).
    DATA lt_current TYPE zif_allocation_log_store=>ty_current_entries.
    DATA lt_history TYPE zif_allocation_log_store=>ty_history_entries.
    APPEND ls_current TO lt_current.
    APPEND ls_history TO lt_history.

    DATA(lv_saved) = mo_cut->zif_allocation_log_store~save(
      it_current = lt_current
      it_history = lt_history ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
  ENDMETHOD.

  METHOD rejects_invalid_outcome.
    DATA(ls_current) = current_entry( ).
    ls_current-shortfall_qty = 1.
    DATA ls_history TYPE zstock_algh.
    MOVE-CORRESPONDING ls_current TO ls_history.
    ls_history-log_uuid = cl_system_uuid=>create_uuid_x16_static( ).
    DATA lt_current TYPE zif_allocation_log_store=>ty_current_entries.
    DATA lt_history TYPE zif_allocation_log_store=>ty_history_entries.
    APPEND ls_current TO lt_current.
    APPEND ls_history TO lt_history.

    DATA(lv_saved) = mo_cut->zif_allocation_log_store~save(
      it_current = lt_current
      it_history = lt_history ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
  ENDMETHOD.

  METHOD rejects_mixed_run_context.
    DATA(ls_first) = current_entry( ).
    DATA(ls_second) = current_entry( ).
    ls_second-request_id = 'STORE-SECOND'.
    ls_second-run_mode = 'S'.
    DATA ls_first_history TYPE zstock_algh.
    DATA ls_second_history TYPE zstock_algh.
    MOVE-CORRESPONDING ls_first TO ls_first_history.
    MOVE-CORRESPONDING ls_second TO ls_second_history.
    ls_first_history-log_uuid = cl_system_uuid=>create_uuid_x16_static( ).
    ls_second_history-log_uuid = cl_system_uuid=>create_uuid_x16_static( ).
    DATA lt_current TYPE zif_allocation_log_store=>ty_current_entries.
    DATA lt_history TYPE zif_allocation_log_store=>ty_history_entries.
    APPEND ls_first TO lt_current.
    APPEND ls_second TO lt_current.
    APPEND ls_first_history TO lt_history.
    APPEND ls_second_history TO lt_history.

    DATA(lv_saved) = mo_cut->zif_allocation_log_store~save(
      it_current = lt_current
      it_history = lt_history ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
  ENDMETHOD.

  METHOD rejects_mixed_run_policy.
    DATA(ls_first) = current_entry( ).
    DATA(ls_second) = current_entry( ).
    ls_second-request_id = 'STORE-SECOND'.
    ls_second-horizon_date = '20260930'.
    DATA ls_first_history TYPE zstock_algh.
    DATA ls_second_history TYPE zstock_algh.
    MOVE-CORRESPONDING ls_first TO ls_first_history.
    MOVE-CORRESPONDING ls_second TO ls_second_history.
    ls_first_history-log_uuid = cl_system_uuid=>create_uuid_x16_static( ).
    ls_second_history-log_uuid = cl_system_uuid=>create_uuid_x16_static( ).
    DATA lt_current TYPE zif_allocation_log_store=>ty_current_entries.
    DATA lt_history TYPE zif_allocation_log_store=>ty_history_entries.
    APPEND ls_first TO lt_current.
    APPEND ls_second TO lt_current.
    APPEND ls_first_history TO lt_history.
    APPEND ls_second_history TO lt_history.

    DATA(lv_saved) = mo_cut->zif_allocation_log_store~save(
      it_current = lt_current
      it_history = lt_history ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
  ENDMETHOD.

  METHOD rejects_invalid_mode_outcome.
    DATA(ls_current) = current_entry( ).
    ls_current-run_mode = 'I'.
    DATA ls_history TYPE zstock_algh.
    MOVE-CORRESPONDING ls_current TO ls_history.
    ls_history-log_uuid = cl_system_uuid=>create_uuid_x16_static( ).
    DATA lt_current TYPE zif_allocation_log_store=>ty_current_entries.
    DATA lt_history TYPE zif_allocation_log_store=>ty_history_entries.
    APPEND ls_current TO lt_current.
    APPEND ls_history TO lt_history.

    DATA(lv_saved) = mo_cut->zif_allocation_log_store~save(
      it_current = lt_current
      it_history = lt_history ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
  ENDMETHOD.

  METHOD rejects_wrong_run_control.
    DATA(ls_current) = current_entry( ).
    ls_current-allocation_strategy = 'CUSTOM'.
    DATA ls_history TYPE zstock_algh.
    MOVE-CORRESPONDING ls_current TO ls_history.
    ls_history-log_uuid = cl_system_uuid=>create_uuid_x16_static( ).
    DATA lt_current TYPE zif_allocation_log_store=>ty_current_entries.
    DATA lt_history TYPE zif_allocation_log_store=>ty_history_entries.
    APPEND ls_current TO lt_current.
    APPEND ls_history TO lt_history.

    DATA(lv_saved) = mo_cut->zif_allocation_log_store~save(
      it_current = lt_current
      it_history = lt_history ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
  ENDMETHOD.

  METHOD rejects_simulated_replay_error.
    DATA(ls_current) = current_entry( ).
    ls_current-run_mode = 'S'.
    ls_current-decision_code =
      zcl_stock_allocator=>gc_decision_replay_conflict.
    DATA ls_history TYPE zstock_algh.
    MOVE-CORRESPONDING ls_current TO ls_history.
    ls_history-log_uuid = cl_system_uuid=>create_uuid_x16_static( ).
    DATA lt_current TYPE zif_allocation_log_store=>ty_current_entries.
    DATA lt_history TYPE zif_allocation_log_store=>ty_history_entries.
    APPEND ls_current TO lt_current.
    APPEND ls_history TO lt_history.

    DATA(lv_saved) = mo_cut->zif_allocation_log_store~save(
      it_current = lt_current
      it_history = lt_history ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
  ENDMETHOD.

  METHOD rejects_invalid_log_time.
    DATA(ls_current) = current_entry( ).
    ls_current-logged_at = '246000'.
    DATA ls_history TYPE zstock_algh.
    MOVE-CORRESPONDING ls_current TO ls_history.
    ls_history-log_uuid = cl_system_uuid=>create_uuid_x16_static( ).
    DATA lt_current TYPE zif_allocation_log_store=>ty_current_entries.
    DATA lt_history TYPE zif_allocation_log_store=>ty_history_entries.
    APPEND ls_current TO lt_current.
    APPEND ls_history TO lt_history.

    DATA(lv_saved) = mo_cut->zif_allocation_log_store~save(
      it_current = lt_current
      it_history = lt_history ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
  ENDMETHOD.

  METHOD rejects_invalid_simulation.
    DATA(ls_result) = mo_cut->zif_allocation_history_store~remove_before(
      iv_cutoff_date = '20260801'
      iv_simulation  = 'Y' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Retention simulation flag must be X or blank' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-affected_rows
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_initial_cutoff.
    DATA(ls_result) = mo_cut->zif_allocation_history_store~remove_before(
      iv_cutoff_date = '00000000'
      iv_simulation  = abap_true ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Retention cutoff date must not be initial' ).
  ENDMETHOD.

  METHOD rejects_invalid_cutoff.
    DATA(ls_result) = mo_cut->zif_allocation_history_store~remove_before(
      iv_cutoff_date = '20260230'
      iv_simulation  = abap_true ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Retention cutoff date is invalid' ).
  ENDMETHOD.

  METHOD rejects_current_cutoff.
    DATA(ls_result) = mo_cut->zif_allocation_history_store~remove_before(
      iv_cutoff_date = sy-datum
      iv_simulation  = abap_true ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Retention cutoff date must be before today' ).
  ENDMETHOD.

  METHOD current_entry.
    rs_entry-request_id = 'STORE-VALID'.
    rs_entry-run_mode = 'P'.
    rs_entry-run_id = '00112233445566778899AABBCCDDEEFF'.
    rs_entry-allocation_strategy =
      zcl_stock_allocator=>gc_strategy_priority_due.
    rs_entry-allocation_status = zcl_stock_allocator=>gc_status_invalid.
    rs_entry-decision_code = zcl_stock_allocator=>gc_decision_invalid_request.
    rs_entry-posting_status =
      zcl_stock_allocator=>gc_posting_not_required.
    rs_entry-logged_on = '20260908'.
    rs_entry-logged_at = '120000'.
  ENDMETHOD.
ENDCLASS.
