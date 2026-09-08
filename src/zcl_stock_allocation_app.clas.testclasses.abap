CLASS lcl_allocation_service DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_allocation_service.
    DATA mt_result TYPE zcl_stock_allocator=>ty_allocations.
    DATA mt_requests TYPE zcl_stock_allocator=>ty_requests.
    DATA mv_simulation TYPE abap_bool.
    DATA mv_horizon_date TYPE d.
    DATA mv_require_full_batch TYPE abap_bool.
    DATA mv_strategy TYPE zcl_stock_allocator=>ty_strategy.
ENDCLASS.

CLASS lcl_allocation_service IMPLEMENTATION.
  METHOD zif_stock_allocation_service~execute.
    mt_requests = it_requests.
    mv_simulation = iv_simulation.
    mv_horizon_date = iv_horizon_date.
    mv_require_full_batch = iv_require_full_batch.
    mv_strategy = iv_strategy.
    rt_allocations = mt_result.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_allocation_logger DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_logger.
    DATA mt_allocations TYPE zcl_stock_allocator=>ty_allocations.
    DATA mv_simulation TYPE abap_bool.
    DATA mv_run_id TYPE zif_allocation_logger=>ty_run_id.
    DATA mv_strategy TYPE zcl_stock_allocator=>ty_strategy.
    DATA mv_horizon_date TYPE d.
    DATA mv_require_full_batch TYPE abap_bool.
    DATA mv_saved TYPE abap_bool VALUE abap_true.
ENDCLASS.

CLASS lcl_allocation_logger IMPLEMENTATION.
  METHOD zif_allocation_logger~write.
    mt_allocations = it_allocations.
    mv_simulation = iv_simulation.
    mv_run_id = iv_run_id.
    mv_strategy = iv_strategy.
    mv_horizon_date = iv_horizon_date.
    mv_require_full_batch = iv_require_full_batch.
    rv_saved = mv_saved.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_stock_allocation_app DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_service TYPE REF TO lcl_allocation_service.
    DATA mo_logger TYPE REF TO lcl_allocation_logger.
    DATA mo_cut TYPE REF TO zcl_stock_allocation_app.

    METHODS setup.
    METHODS delegates_and_logs FOR TESTING.
    METHODS returns_log_failure FOR TESTING.
    METHODS normalizes_invalid_log_state FOR TESTING.
    METHODS rejects_missing_service FOR TESTING.
    METHODS rejects_missing_logger FOR TESTING.
    METHODS rejects_missing_result_row FOR TESTING.
    METHODS rejects_foreign_result_id FOR TESTING.
    METHODS rejects_mutated_result FOR TESTING.
    METHODS rejects_spurious_request_error FOR TESTING.
    METHODS rejects_unknown_result_state FOR TESTING.
    METHODS rejects_bad_result_pair FOR TESTING.
    METHODS rejects_bad_result_flag FOR TESTING.
    METHODS rejects_bad_result_document FOR TESTING.
    METHODS rejects_blank_decision FOR TESTING.
    METHODS rejects_bad_result_math FOR TESTING.
    METHODS rejects_unchecked_stock FOR TESTING.
    METHODS rejects_wrong_stock_scope FOR TESTING.
    METHODS accepts_missing_stock_result FOR TESTING.
    METHODS accepts_replay_batch_error FOR TESTING.
    METHODS rejects_spurious_run_error FOR TESTING.
    METHODS rejects_spurious_horizon FOR TESTING.
    METHODS rejects_spurious_batch_abort FOR TESTING.
    METHODS rejects_spurious_batch_limit FOR TESTING.
    METHODS accepts_exact_batch_limit FOR TESTING.
    METHODS rejects_reused_result_doc FOR TESTING.
    METHODS rejects_mixed_new_posting FOR TESTING.
    METHODS rejects_bad_decision_pair FOR TESTING.
    METHODS rejects_wrong_run_mode FOR TESTING.
    METHODS rejects_simulated_replay_error FOR TESTING.
    METHODS rejects_orphan_duplicate FOR TESTING.
    METHODS accepts_duplicate_id_counts FOR TESTING.
    METHODS returns_unique_run_ids FOR TESTING.
    METHODS returns_batch_summary FOR TESTING.
    METHODS creates_sap_composition FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_allocation_app IMPLEMENTATION.
  METHOD setup.
    mo_service = NEW #( ).
    mo_logger = NEW #( ).
    mo_cut = NEW #(
      io_service = mo_service
      io_logger  = mo_logger ).
  ENDMETHOD.

  METHOD delegates_and_logs.
    mo_service->mt_result = VALUE #(
      ( request_id             = 'REQUEST-1'
        material               = 'MAT-1'
        plant                  = '1000'
        storage_location       = '0001'
        movement_type          = '201'
        cost_center            = 'CC1000'
        requirement_date       = '20260818'
        priority               = 1
        unit_of_measure        = 'EA'
        requested_qty          = 1
        source_requested_qty   = 1
        source_unit_of_measure = 'EA'
        allocated_qty          = 1
        fill_pct               = 100
        availability_checked   = abap_true
        available_qty          = 1
        status                 = zcl_stock_allocator=>gc_status_allocated
        decision_code          =
          zcl_stock_allocator=>gc_decision_fully_allocated
        posting_status         =
          zcl_stock_allocator=>gc_posting_simulated ) ).
    DATA(lt_requests) = VALUE zcl_stock_allocator=>ty_requests(
      ( request_id       = 'REQUEST-1'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        movement_type    = '201'
        cost_center      = 'CC1000'
        requirement_date = '20260818'
        priority         = 1
        unit_of_measure  = 'EA'
        requested_qty    = 1 ) ).

    DATA(ls_result) = mo_cut->run(
      it_requests           = lt_requests
      iv_simulation         = abap_true
      iv_horizon_date       = '20260831'
      iv_require_full_batch = abap_true
      iv_strategy           = zcl_stock_allocator=>gc_strategy_due_priority ).

    cl_abap_unit_assert=>assert_true( ls_result-log_saved ).
    cl_abap_unit_assert=>assert_not_initial( ls_result-run_id ).
    cl_abap_unit_assert=>assert_equals(
      act = strlen( ls_result-run_id )
      exp = 32 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_logger->mv_run_id
      exp = ls_result-run_id ).
    cl_abap_unit_assert=>assert_true( mo_service->mv_simulation ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_service->mv_horizon_date
      exp = '20260831' ).
    cl_abap_unit_assert=>assert_true( mo_service->mv_require_full_batch ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_service->mv_strategy
      exp = zcl_stock_allocator=>gc_strategy_due_priority ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_logger->mt_allocations[ 1 ]-request_id
      exp = 'REQUEST-1' ).
    cl_abap_unit_assert=>assert_true( mo_logger->mv_simulation ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_logger->mv_strategy
      exp = zcl_stock_allocator=>gc_strategy_due_priority ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_logger->mv_horizon_date
      exp = '20260831' ).
    cl_abap_unit_assert=>assert_true( mo_logger->mv_require_full_batch ).
  ENDMETHOD.

  METHOD returns_log_failure.
    mo_logger->mv_saved = abap_false.

    DATA(ls_result) = mo_cut->run(
      it_requests   = VALUE #( )
      iv_simulation = abap_true ).

    cl_abap_unit_assert=>assert_false( ls_result-log_saved ).
    cl_abap_unit_assert=>assert_not_initial( ls_result-run_id ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Allocation log could not be saved' ).
  ENDMETHOD.

  METHOD normalizes_invalid_log_state.
    mo_logger->mv_saved = 'Y'.

    DATA(ls_result) = mo_cut->run(
      it_requests   = VALUE #( )
      iv_simulation = abap_true ).

    cl_abap_unit_assert=>assert_false( ls_result-log_saved ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Allocation logger returned invalid state' ).
  ENDMETHOD.

  METHOD rejects_missing_service.
    DATA lo_service TYPE REF TO zif_stock_allocation_service.
    mo_cut = NEW #(
      io_service = lo_service
      io_logger  = mo_logger ).

    DATA(ls_result) = mo_cut->run(
      it_requests   = VALUE #( ( request_id = 'REQUEST-1' ) )
      iv_simulation = abap_true ).

    cl_abap_unit_assert=>assert_not_initial( ls_result-run_id ).
    cl_abap_unit_assert=>assert_initial( ls_result-allocations ).
    cl_abap_unit_assert=>assert_false( ls_result-service_result_valid ).
    cl_abap_unit_assert=>assert_false( ls_result-log_saved ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-summary-submitted_requests
      exp = 1 ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-summary-returned_results ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Allocation service is required' ).
    cl_abap_unit_assert=>assert_initial( mo_logger->mv_run_id ).
  ENDMETHOD.

  METHOD rejects_missing_logger.
    mo_service->mt_result = VALUE #(
      ( request_id     = 'REQUEST-1'
        status         = zcl_stock_allocator=>gc_status_invalid
        decision_code  = zcl_stock_allocator=>gc_decision_rule_invalid
        posting_status =
          zcl_stock_allocator=>gc_posting_not_required ) ).
    DATA lo_logger TYPE REF TO zif_allocation_logger.
    mo_cut = NEW #(
      io_service = mo_service
      io_logger  = lo_logger ).

    DATA(ls_result) = mo_cut->run(
      it_requests   = VALUE #( ( request_id = 'REQUEST-1' ) )
      iv_simulation = abap_true ).

    cl_abap_unit_assert=>assert_not_initial( ls_result-run_id ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-allocations[ 1 ]-request_id
      exp = 'REQUEST-1' ).
    cl_abap_unit_assert=>assert_true( ls_result-service_result_valid ).
    cl_abap_unit_assert=>assert_false( ls_result-log_saved ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Allocation logger is required' ).
  ENDMETHOD.

  METHOD rejects_missing_result_row.
    DATA(ls_result) = mo_cut->run(
      it_requests = VALUE #( ( request_id = 'REQUEST-1' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-service_result_valid ).
    cl_abap_unit_assert=>assert_false( ls_result-log_saved ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-summary-submitted_requests
      exp = 1 ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-summary-returned_results ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-summary-total_requests ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Allocation service returned invalid result' ).
    cl_abap_unit_assert=>assert_initial( mo_logger->mv_run_id ).
  ENDMETHOD.

  METHOD rejects_foreign_result_id.
    mo_service->mt_result = VALUE #(
      ( request_id = 'REQUEST-2'
        status     = zcl_stock_allocator=>gc_status_invalid ) ).

    DATA(ls_result) = mo_cut->run(
      it_requests = VALUE #( ( request_id = 'REQUEST-1' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-service_result_valid ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Allocation service returned invalid result' ).
    cl_abap_unit_assert=>assert_initial( mo_logger->mv_run_id ).
  ENDMETHOD.

  METHOD rejects_mutated_result.
    mo_service->mt_result = VALUE #(
      ( request_id             = 'REQUEST-1'
        material               = 'MATERIAL-2'
        source_requested_qty   = 5
        source_unit_of_measure = 'EA'
        status                 = zcl_stock_allocator=>gc_status_invalid ) ).

    DATA(ls_result) = mo_cut->run(
      it_requests = VALUE #(
        ( request_id      = 'REQUEST-1'
          material        = 'MATERIAL-1'
          requested_qty   = 5
          unit_of_measure = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-service_result_valid ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Allocation service returned invalid result' ).
    cl_abap_unit_assert=>assert_initial( mo_logger->mv_run_id ).
  ENDMETHOD.

  METHOD rejects_spurious_request_error.
    mo_service->mt_result = VALUE #(
      ( request_id             = 'REQUEST-1'
        material               = 'MAT-1'
        plant                  = '1000'
        storage_location       = '0001'
        movement_type          = '201'
        cost_center            = 'CC1000'
        requirement_date       = '20260818'
        priority               = 1
        unit_of_measure        = 'EA'
        requested_qty          = 1
        source_requested_qty   = 1
        source_unit_of_measure = 'EA'
        shortfall_qty          = 1
        status                 = zcl_stock_allocator=>gc_status_invalid
        decision_code          =
          zcl_stock_allocator=>gc_decision_invalid_request
        posting_status         =
          zcl_stock_allocator=>gc_posting_not_required ) ).

    DATA(ls_result) = mo_cut->run(
      it_requests = VALUE #(
        ( request_id       = 'REQUEST-1'
          material         = 'MAT-1'
          plant            = '1000'
          storage_location = '0001'
          movement_type    = '201'
          cost_center      = 'CC1000'
          requirement_date = '20260818'
          priority         = 1
          unit_of_measure  = 'EA'
          requested_qty    = 1 ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-service_result_valid ).
    cl_abap_unit_assert=>assert_initial( mo_logger->mv_run_id ).
  ENDMETHOD.

  METHOD rejects_unknown_result_state.
    mo_service->mt_result = VALUE #(
      ( request_id     = 'REQUEST-1'
        status         = 'CUSTOM'
        decision_code  = 'CUSTOM'
        posting_status = 'CUSTOM' ) ).

    DATA(ls_result) = mo_cut->run(
      it_requests = VALUE #( ( request_id = 'REQUEST-1' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-service_result_valid ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-summary-unknown_allocation_status
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-summary-unknown_posting_status
      exp = 1 ).
    cl_abap_unit_assert=>assert_initial( mo_logger->mv_run_id ).
  ENDMETHOD.

  METHOD rejects_bad_result_pair.
    mo_service->mt_result = VALUE #(
      ( request_id     = 'REQUEST-1'
        status         = zcl_stock_allocator=>gc_status_rejected
        decision_code  = zcl_stock_allocator=>gc_decision_no_available_stock
        posting_status = zcl_stock_allocator=>gc_posting_simulated ) ).

    DATA(ls_result) = mo_cut->run(
      it_requests = VALUE #( ( request_id = 'REQUEST-1' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-service_result_valid ).
    cl_abap_unit_assert=>assert_initial( mo_logger->mv_run_id ).
  ENDMETHOD.

  METHOD rejects_bad_result_flag.
    mo_service->mt_result = VALUE #(
      ( request_id           = 'REQUEST-1'
        status               = zcl_stock_allocator=>gc_status_invalid
        decision_code        =
          zcl_stock_allocator=>gc_decision_invalid_request
        posting_status       =
          zcl_stock_allocator=>gc_posting_not_required
        availability_checked = 'Y' ) ).

    DATA(ls_result) = mo_cut->run(
      it_requests = VALUE #( ( request_id = 'REQUEST-1' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-service_result_valid ).
    cl_abap_unit_assert=>assert_initial( mo_logger->mv_run_id ).
  ENDMETHOD.

  METHOD rejects_bad_result_document.
    mo_service->mt_result = VALUE #(
      ( request_id             = 'REQUEST-1'
        unit_of_measure        = 'EA'
        requested_qty          = 1
        source_requested_qty   = 1
        source_unit_of_measure = 'EA'
        allocated_qty          = 1
        fill_pct               = 100
        availability_checked   = abap_true
        available_qty          = 1
        status                 = zcl_stock_allocator=>gc_status_allocated
        decision_code          =
          zcl_stock_allocator=>gc_decision_fully_allocated
        posting_status         = zcl_stock_allocator=>gc_posting_posted
        document_id            = 'BAD-DOC' ) ).

    DATA(ls_result) = mo_cut->run(
      it_requests = VALUE #(
        ( request_id      = 'REQUEST-1'
          unit_of_measure = 'EA'
          requested_qty   = 1 ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-service_result_valid ).
    cl_abap_unit_assert=>assert_initial( mo_logger->mv_run_id ).
  ENDMETHOD.

  METHOD rejects_blank_decision.
    mo_service->mt_result = VALUE #(
      ( request_id     = 'REQUEST-1'
        status         = zcl_stock_allocator=>gc_status_invalid
        posting_status =
          zcl_stock_allocator=>gc_posting_not_required ) ).

    DATA(ls_result) = mo_cut->run(
      it_requests = VALUE #( ( request_id = 'REQUEST-1' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-service_result_valid ).
    cl_abap_unit_assert=>assert_initial( mo_logger->mv_run_id ).
  ENDMETHOD.

  METHOD rejects_bad_result_math.
    mo_service->mt_result = VALUE #(
      ( request_id             = 'REQUEST-1'
        unit_of_measure        = 'EA'
        requested_qty          = 5
        source_requested_qty   = 5
        source_unit_of_measure = 'EA'
        allocated_qty          = 4
        shortfall_qty          = 0
        fill_pct               = 100
        availability_checked   = abap_true
        available_qty          = 4
        status                 = zcl_stock_allocator=>gc_status_allocated
        decision_code          =
          zcl_stock_allocator=>gc_decision_fully_allocated
        posting_status         =
          zcl_stock_allocator=>gc_posting_simulated ) ).

    DATA(ls_result) = mo_cut->run(
      it_requests = VALUE #(
        ( request_id      = 'REQUEST-1'
          unit_of_measure = 'EA'
          requested_qty   = 5 ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-service_result_valid ).
    cl_abap_unit_assert=>assert_initial( mo_logger->mv_run_id ).
  ENDMETHOD.

  METHOD rejects_unchecked_stock.
    mo_service->mt_result = VALUE #(
      ( request_id     = 'REQUEST-1'
        status         = zcl_stock_allocator=>gc_status_invalid
        decision_code  = zcl_stock_allocator=>gc_decision_invalid_request
        posting_status = zcl_stock_allocator=>gc_posting_not_required
        available_qty  = 5 ) ).

    DATA(ls_result) = mo_cut->run(
      it_requests = VALUE #( ( request_id = 'REQUEST-1' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-service_result_valid ).
    cl_abap_unit_assert=>assert_initial( mo_logger->mv_run_id ).
  ENDMETHOD.

  METHOD rejects_wrong_stock_scope.
    mo_service->mt_result = VALUE #(
      ( request_id             = 'REQUEST-1'
        unit_of_measure        = 'EA'
        requested_qty          = 1
        source_requested_qty   = 1
        source_unit_of_measure = 'EA'
        allocated_qty          = 1
        fill_pct               = 100
        status                 = zcl_stock_allocator=>gc_status_allocated
        decision_code          =
          zcl_stock_allocator=>gc_decision_fully_allocated
        posting_status         =
          zcl_stock_allocator=>gc_posting_simulated ) ).

    DATA(ls_result) = mo_cut->run(
      it_requests   = VALUE #(
        ( request_id      = 'REQUEST-1'
          unit_of_measure = 'EA'
          requested_qty   = 1 ) )
      iv_simulation = abap_true ).

    cl_abap_unit_assert=>assert_false( ls_result-service_result_valid ).
    cl_abap_unit_assert=>assert_initial( mo_logger->mv_run_id ).
  ENDMETHOD.

  METHOD accepts_missing_stock_result.
    mo_service->mt_result = VALUE #(
      ( request_id             = 'REQUEST-1'
        material               = 'MAT-1'
        plant                  = '1000'
        storage_location       = '0001'
        movement_type          = '201'
        cost_center            = 'CC1000'
        requirement_date       = '20260818'
        priority               = 1
        unit_of_measure        = 'EA'
        requested_qty          = 2
        source_requested_qty   = 2
        source_unit_of_measure = 'EA'
        shortfall_qty          = 2
        status                 = zcl_stock_allocator=>gc_status_rejected
        decision_code          =
          zcl_stock_allocator=>gc_decision_stock_not_found
        posting_status         =
          zcl_stock_allocator=>gc_posting_not_required ) ).

    DATA(ls_result) = mo_cut->run(
      it_requests   = VALUE #(
        ( request_id       = 'REQUEST-1'
          material         = 'MAT-1'
          plant            = '1000'
          storage_location = '0001'
          movement_type    = '201'
          cost_center      = 'CC1000'
          requirement_date = '20260818'
          priority         = 1
          unit_of_measure  = 'EA'
          requested_qty    = 2 ) )
      iv_simulation = abap_true ).

    cl_abap_unit_assert=>assert_true( ls_result-service_result_valid ).
    cl_abap_unit_assert=>assert_true( ls_result-log_saved ).
    cl_abap_unit_assert=>assert_not_initial( mo_logger->mv_run_id ).
  ENDMETHOD.

  METHOD accepts_replay_batch_error.
    mo_service->mt_result = VALUE #(
      ( request_id     = 'REQUEST-1'
        status         = zcl_stock_allocator=>gc_status_config_error
        decision_code  =
          zcl_stock_allocator=>gc_decision_replay_outcome
        posting_status =
          zcl_stock_allocator=>gc_posting_not_required ) ).

    DATA(ls_result) = mo_cut->run(
      it_requests = VALUE #( ( request_id = 'REQUEST-1' ) ) ).

    cl_abap_unit_assert=>assert_true( ls_result-service_result_valid ).
    cl_abap_unit_assert=>assert_true( ls_result-log_saved ).
    cl_abap_unit_assert=>assert_not_initial( mo_logger->mv_run_id ).
  ENDMETHOD.

  METHOD rejects_spurious_run_error.
    mo_service->mt_result = VALUE #(
      ( request_id     = 'REQUEST-1'
        status         = zcl_stock_allocator=>gc_status_config_error
        decision_code  = zcl_stock_allocator=>gc_decision_bad_strategy
        posting_status =
          zcl_stock_allocator=>gc_posting_not_required ) ).

    DATA(ls_result) = mo_cut->run(
      it_requests = VALUE #( ( request_id = 'REQUEST-1' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-service_result_valid ).
    cl_abap_unit_assert=>assert_initial( mo_logger->mv_run_id ).
  ENDMETHOD.

  METHOD rejects_spurious_horizon.
    mo_service->mt_result = VALUE #(
      ( request_id             = 'REQUEST-1'
        material               = 'MAT-1'
        plant                  = '1000'
        storage_location       = '0001'
        movement_type          = '201'
        cost_center            = 'CC1000'
        requirement_date       = '20260818'
        priority               = 1
        unit_of_measure        = 'EA'
        requested_qty          = 2
        source_requested_qty   = 2
        source_unit_of_measure = 'EA'
        shortfall_qty          = 2
        status                 = zcl_stock_allocator=>gc_status_deferred
        decision_code          =
          zcl_stock_allocator=>gc_decision_outside_horizon
        posting_status         =
          zcl_stock_allocator=>gc_posting_not_required ) ).

    DATA(ls_result) = mo_cut->run(
      it_requests   = VALUE #(
        ( request_id       = 'REQUEST-1'
          material         = 'MAT-1'
          plant            = '1000'
          storage_location = '0001'
          movement_type    = '201'
          cost_center      = 'CC1000'
          requirement_date = '20260818'
          priority         = 1
          unit_of_measure  = 'EA'
          requested_qty    = 2 ) )
      iv_simulation = abap_true ).

    cl_abap_unit_assert=>assert_false( ls_result-service_result_valid ).
    cl_abap_unit_assert=>assert_initial( mo_logger->mv_run_id ).
  ENDMETHOD.

  METHOD rejects_spurious_batch_abort.
    mo_service->mt_result = VALUE #(
      ( request_id             = 'REQUEST-1'
        material               = 'MAT-1'
        plant                  = '1000'
        storage_location       = '0001'
        movement_type          = '201'
        cost_center            = 'CC1000'
        requirement_date       = '20260818'
        priority               = 1
        unit_of_measure        = 'EA'
        requested_qty          = 2
        source_requested_qty   = 2
        source_unit_of_measure = 'EA'
        shortfall_qty          = 2
        availability_checked   = abap_true
        available_qty          = 2
        status                 = zcl_stock_allocator=>gc_status_aborted
        decision_code          =
          zcl_stock_allocator=>gc_decision_full_batch_aborted
        posting_status         =
          zcl_stock_allocator=>gc_posting_not_required ) ).

    DATA(ls_result) = mo_cut->run(
      it_requests   = VALUE #(
        ( request_id       = 'REQUEST-1'
          material         = 'MAT-1'
          plant            = '1000'
          storage_location = '0001'
          movement_type    = '201'
          cost_center      = 'CC1000'
          requirement_date = '20260818'
          priority         = 1
          unit_of_measure  = 'EA'
          requested_qty    = 2 ) )
      iv_simulation = abap_true ).

    cl_abap_unit_assert=>assert_false( ls_result-service_result_valid ).
    cl_abap_unit_assert=>assert_initial( mo_logger->mv_run_id ).
  ENDMETHOD.

  METHOD rejects_spurious_batch_limit.
    mo_service->mt_result = VALUE #(
      ( request_id     = 'REQUEST-1'
        status         = zcl_stock_allocator=>gc_status_config_error
        decision_code  = zcl_stock_allocator=>gc_decision_batch_too_large
        posting_status =
          zcl_stock_allocator=>gc_posting_not_required ) ).

    DATA(ls_result) = mo_cut->run(
      it_requests = VALUE #( ( request_id = 'REQUEST-1' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-service_result_valid ).
    cl_abap_unit_assert=>assert_initial( mo_logger->mv_run_id ).
  ENDMETHOD.

  METHOD accepts_exact_batch_limit.
    DATA lt_requests TYPE zcl_stock_allocator=>ty_requests.
    DO zcl_stock_allocation_service=>gc_max_batch_size + 1 TIMES.
      DATA(lv_request_id) = CONV zcl_stock_allocator=>ty_request_id(
        |BATCH-{ sy-index }| ).
      APPEND VALUE #( request_id = lv_request_id ) TO lt_requests.
      APPEND VALUE #(
        request_id     = lv_request_id
        status         = zcl_stock_allocator=>gc_status_config_error
        decision_code  = zcl_stock_allocator=>gc_decision_batch_too_large
        posting_status = zcl_stock_allocator=>gc_posting_not_required )
        TO mo_service->mt_result.
    ENDDO.

    DATA(ls_result) = mo_cut->run( lt_requests ).

    cl_abap_unit_assert=>assert_true( ls_result-service_result_valid ).
    cl_abap_unit_assert=>assert_true( ls_result-log_saved ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_logger->mt_allocations )
      exp = zcl_stock_allocation_service=>gc_max_batch_size + 1 ).
  ENDMETHOD.

  METHOD rejects_reused_result_doc.
    mo_service->mt_result = VALUE #(
      ( request_id             = 'REQUEST-1'
        unit_of_measure        = 'EA'
        requested_qty          = 1
        source_requested_qty   = 1
        source_unit_of_measure = 'EA'
        allocated_qty          = 1
        fill_pct               = 100
        availability_checked   = abap_true
        available_qty          = 1
        status                 = zcl_stock_allocator=>gc_status_allocated
        decision_code          =
          zcl_stock_allocator=>gc_decision_fully_allocated
        posting_status         = zcl_stock_allocator=>gc_posting_posted
        document_id            = '0000000042' )
      ( request_id             = 'REQUEST-2'
        unit_of_measure        = 'EA'
        requested_qty          = 1
        source_requested_qty   = 1
        source_unit_of_measure = 'EA'
        allocated_qty          = 1
        fill_pct               = 100
        availability_checked   = abap_true
        available_qty          = 1
        status                 = zcl_stock_allocator=>gc_status_allocated
        decision_code          =
          zcl_stock_allocator=>gc_decision_fully_allocated
        posting_status         = zcl_stock_allocator=>gc_posting_posted
        document_id            = '0000000042' ) ).

    DATA(ls_result) = mo_cut->run(
      it_requests = VALUE #(
        ( request_id      = 'REQUEST-1'
          unit_of_measure = 'EA'
          requested_qty   = 1 )
        ( request_id      = 'REQUEST-2'
          unit_of_measure = 'EA'
          requested_qty   = 1 ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-service_result_valid ).
    cl_abap_unit_assert=>assert_initial( mo_logger->mv_run_id ).
  ENDMETHOD.

  METHOD rejects_mixed_new_posting.
    mo_service->mt_result = VALUE #(
      ( request_id             = 'REQUEST-1'
        material               = 'MAT-1'
        plant                  = '1000'
        storage_location       = '0001'
        movement_type          = '201'
        cost_center            = 'CC1000'
        requirement_date       = '20260818'
        priority               = 1
        unit_of_measure        = 'EA'
        requested_qty          = 1
        source_requested_qty   = 1
        source_unit_of_measure = 'EA'
        allocated_qty          = 1
        fill_pct               = 100
        availability_checked   = abap_true
        available_qty          = 1
        status                 = zcl_stock_allocator=>gc_status_allocated
        decision_code          =
          zcl_stock_allocator=>gc_decision_fully_allocated
        posting_status         = zcl_stock_allocator=>gc_posting_posted
        document_id            = '0000000041' )
      ( request_id             = 'REQUEST-2'
        material               = 'MAT-2'
        plant                  = '1000'
        storage_location       = '0001'
        movement_type          = '201'
        cost_center            = 'CC2000'
        requirement_date       = '20260818'
        priority               = 2
        unit_of_measure        = 'EA'
        requested_qty          = 1
        source_requested_qty   = 1
        source_unit_of_measure = 'EA'
        allocated_qty          = 1
        fill_pct               = 100
        availability_checked   = abap_true
        available_qty          = 1
        status                 = zcl_stock_allocator=>gc_status_allocated
        decision_code          =
          zcl_stock_allocator=>gc_decision_fully_allocated
        posting_status         = zcl_stock_allocator=>gc_posting_failed ) ).

    DATA(ls_result) = mo_cut->run(
      it_requests = VALUE #(
        ( request_id       = 'REQUEST-1'
          material         = 'MAT-1'
          plant            = '1000'
          storage_location = '0001'
          movement_type    = '201'
          cost_center      = 'CC1000'
          requirement_date = '20260818'
          priority         = 1
          unit_of_measure  = 'EA'
          requested_qty    = 1 )
        ( request_id       = 'REQUEST-2'
          material         = 'MAT-2'
          plant            = '1000'
          storage_location = '0001'
          movement_type    = '201'
          cost_center      = 'CC2000'
          requirement_date = '20260818'
          priority         = 2
          unit_of_measure  = 'EA'
          requested_qty    = 1 ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-service_result_valid ).
    cl_abap_unit_assert=>assert_initial( mo_logger->mv_run_id ).
  ENDMETHOD.

  METHOD rejects_bad_decision_pair.
    mo_service->mt_result = VALUE #(
      ( request_id             = 'REQUEST-1'
        unit_of_measure        = 'EA'
        requested_qty          = 1
        source_requested_qty   = 1
        source_unit_of_measure = 'EA'
        allocated_qty          = 1
        fill_pct               = 100
        availability_checked   = abap_true
        available_qty          = 1
        status                 = zcl_stock_allocator=>gc_status_allocated
        decision_code          =
          zcl_stock_allocator=>gc_decision_invalid_request
        posting_status         =
          zcl_stock_allocator=>gc_posting_simulated ) ).

    DATA(ls_result) = mo_cut->run(
      it_requests   = VALUE #(
        ( request_id      = 'REQUEST-1'
          unit_of_measure = 'EA'
          requested_qty   = 1 ) )
      iv_simulation = abap_true ).

    cl_abap_unit_assert=>assert_false( ls_result-service_result_valid ).
    cl_abap_unit_assert=>assert_initial( mo_logger->mv_run_id ).
  ENDMETHOD.

  METHOD rejects_wrong_run_mode.
    mo_service->mt_result = VALUE #(
      ( request_id             = 'REQUEST-1'
        unit_of_measure        = 'EA'
        requested_qty          = 1
        source_requested_qty   = 1
        source_unit_of_measure = 'EA'
        allocated_qty          = 1
        fill_pct               = 100
        availability_checked   = abap_true
        available_qty          = 1
        status                 = zcl_stock_allocator=>gc_status_allocated
        decision_code          =
          zcl_stock_allocator=>gc_decision_fully_allocated
        posting_status         = zcl_stock_allocator=>gc_posting_posted
        document_id            = '0000000042' ) ).

    DATA(ls_result) = mo_cut->run(
      it_requests   = VALUE #(
        ( request_id      = 'REQUEST-1'
          unit_of_measure = 'EA'
          requested_qty   = 1 ) )
      iv_simulation = abap_true ).

    cl_abap_unit_assert=>assert_false( ls_result-service_result_valid ).
    cl_abap_unit_assert=>assert_initial( mo_logger->mv_run_id ).
  ENDMETHOD.

  METHOD rejects_simulated_replay_error.
    mo_service->mt_result = VALUE #(
      ( request_id     = 'REQUEST-1'
        status         = zcl_stock_allocator=>gc_status_invalid
        decision_code  = zcl_stock_allocator=>gc_decision_replay_conflict
        posting_status =
          zcl_stock_allocator=>gc_posting_not_required ) ).

    DATA(ls_result) = mo_cut->run(
      it_requests   = VALUE #( ( request_id = 'REQUEST-1' ) )
      iv_simulation = abap_true ).

    cl_abap_unit_assert=>assert_false( ls_result-service_result_valid ).
    cl_abap_unit_assert=>assert_initial( mo_logger->mv_run_id ).
  ENDMETHOD.

  METHOD rejects_orphan_duplicate.
    mo_service->mt_result = VALUE #(
      ( request_id     = 'DUPLICATE'
        status         = zcl_stock_allocator=>gc_status_invalid
        decision_code  = zcl_stock_allocator=>gc_decision_duplicate_request
        posting_status =
          zcl_stock_allocator=>gc_posting_not_required ) ).

    DATA(ls_result) = mo_cut->run(
      it_requests = VALUE #( ( request_id = 'DUPLICATE' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-service_result_valid ).
    cl_abap_unit_assert=>assert_initial( mo_logger->mv_run_id ).
  ENDMETHOD.

  METHOD accepts_duplicate_id_counts.
    mo_service->mt_result = VALUE #(
      ( request_id             = 'DUPLICATE'
        material               = 'MAT-1'
        plant                  = '1000'
        storage_location       = '0001'
        movement_type          = '201'
        cost_center            = 'CC1000'
        requirement_date       = '20260818'
        priority               = 1
        unit_of_measure        = 'EA'
        requested_qty          = 1
        source_requested_qty   = 1
        source_unit_of_measure = 'EA'
        allocated_qty          = 1
        fill_pct               = 100
        availability_checked   = abap_true
        available_qty          = 2
        status                 = zcl_stock_allocator=>gc_status_allocated
        decision_code          =
          zcl_stock_allocator=>gc_decision_fully_allocated
        posting_status         = zcl_stock_allocator=>gc_posting_simulated )
      ( request_id             = 'DUPLICATE'
        material               = 'MAT-1'
        plant                  = '1000'
        storage_location       = '0001'
        movement_type          = '201'
        cost_center            = 'CC1000'
        requirement_date       = '20260818'
        priority               = 1
        unit_of_measure        = 'EA'
        requested_qty          = 1
        source_requested_qty   = 1
        source_unit_of_measure = 'EA'
        shortfall_qty          = 1
        status                 = zcl_stock_allocator=>gc_status_invalid
        decision_code          = zcl_stock_allocator=>gc_decision_duplicate_request
        posting_status         =
          zcl_stock_allocator=>gc_posting_not_required ) ).

    DATA(ls_result) = mo_cut->run(
      it_requests   = VALUE #(
        ( request_id       = 'DUPLICATE'
          material         = 'MAT-1'
          plant            = '1000'
          storage_location = '0001'
          movement_type    = '201'
          cost_center      = 'CC1000'
          requirement_date = '20260818'
          priority         = 1
          unit_of_measure  = 'EA'
          requested_qty    = 1 )
        ( request_id       = 'DUPLICATE'
          material         = 'MAT-1'
          plant            = '1000'
          storage_location = '0001'
          movement_type    = '201'
          cost_center      = 'CC1000'
          requirement_date = '20260818'
          priority         = 1
          unit_of_measure  = 'EA'
          requested_qty    = 1 ) )
      iv_simulation = abap_true ).

    cl_abap_unit_assert=>assert_true( ls_result-service_result_valid ).
    cl_abap_unit_assert=>assert_true( ls_result-log_saved ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_logger->mt_allocations )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-summary-fully_allocated
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-summary-invalid
      exp = 1 ).
  ENDMETHOD.

  METHOD returns_unique_run_ids.
    DATA(ls_first) = mo_cut->run(
      it_requests   = VALUE #( )
      iv_simulation = abap_true ).
    DATA(ls_second) = mo_cut->run(
      it_requests   = VALUE #( )
      iv_simulation = abap_true ).

    cl_abap_unit_assert=>assert_differs(
      act = ls_first-run_id
      exp = ls_second-run_id ).
  ENDMETHOD.

  METHOD returns_batch_summary.
    mo_service->mt_result = VALUE #(
      ( request_id     = 'REQUEST-1'
        status         = zcl_stock_allocator=>gc_status_allocated
        decision_code  = zcl_stock_allocator=>gc_decision_replayed
        posting_status = zcl_stock_allocator=>gc_posting_posted
        document_id    = '0000000001' )
      ( request_id           = 'REQUEST-2'
        status               = zcl_stock_allocator=>gc_status_partial
        availability_checked = abap_true
        posting_status       = zcl_stock_allocator=>gc_posting_simulated )
      ( request_id           = 'REQUEST-3'
        status               = zcl_stock_allocator=>gc_status_rejected
        availability_checked = abap_true
        posting_status       =
          zcl_stock_allocator=>gc_posting_not_required )
      ( request_id     = 'REQUEST-4'
        status         = zcl_stock_allocator=>gc_status_invalid
        posting_status = zcl_stock_allocator=>gc_posting_failed )
      ( request_id     = 'REQUEST-5'
        status         = zcl_stock_allocator=>gc_status_deferred
        posting_status = zcl_stock_allocator=>gc_posting_pending )
      ( request_id     = 'REQUEST-6'
        status         = zcl_stock_allocator=>gc_status_aborted
        posting_status = zcl_stock_allocator=>gc_posting_not_required )
      ( request_id     = 'REQUEST-7'
        status         = zcl_stock_allocator=>gc_status_config_error
        posting_status = zcl_stock_allocator=>gc_posting_not_required )
      ( request_id           = 'REQUEST-8'
        status               = 'CUSTOM'
        posting_status       = 'CUSTOM'
        replaced_document_id = '0000000002' )
      ( request_id           = 'REQUEST-9'
        status               = zcl_stock_allocator=>gc_status_allocated
        decision_code        =
          zcl_stock_allocator=>gc_decision_fully_allocated
        availability_checked = abap_true
        posting_status       = zcl_stock_allocator=>gc_posting_posted
        document_id          = '0000000003'
        replaced_document_id = '0000000004' ) ).

    DATA(ls_result) = mo_cut->run(
      it_requests   = VALUE #(
        ( request_id = 'REQUEST-1' )
        ( request_id = 'REQUEST-2' )
        ( request_id = 'REQUEST-3' )
        ( request_id = 'REQUEST-4' )
        ( request_id = 'REQUEST-5' )
        ( request_id = 'REQUEST-6' )
        ( request_id = 'REQUEST-7' )
        ( request_id = 'REQUEST-8' )
        ( request_id = 'REQUEST-9' ) )
      iv_simulation = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-summary-submitted_requests
      exp = 9 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-summary-returned_results
      exp = 9 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-summary-total_requests
      exp = 9 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-summary-fully_allocated
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-summary-partially_allocated
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-summary-rejected
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-summary-invalid
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-summary-deferred
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-summary-aborted
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-summary-configuration_errors
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-summary-unknown_allocation_status
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-summary-posting_not_required
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-summary-unknown_posting_status
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-summary-availability_evaluated
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-summary-reservation_documents
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-summary-idempotent_replays
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-summary-new_reservations
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-summary-replacement_attempts
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-summary-replacement_posted
      exp = 1 ).
  ENDMETHOD.

  METHOD creates_sap_composition.
    DATA(lo_app) = zcl_stock_allocation_app=>create_sap( ).

    cl_abap_unit_assert=>assert_bound( lo_app ).
  ENDMETHOD.
ENDCLASS.
