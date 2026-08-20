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
    METHODS returns_unique_run_ids FOR TESTING.
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
      ( request_id     = 'REQUEST-1'
        status         = zcl_stock_allocator=>gc_status_allocated
        posting_status = zcl_stock_allocator=>gc_posting_simulated ) ).
    DATA(lt_requests) = VALUE zcl_stock_allocator=>ty_requests(
      ( request_id = 'REQUEST-1' ) ).

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
  ENDMETHOD.

  METHOD normalizes_invalid_log_state.
    mo_logger->mv_saved = 'Y'.

    DATA(ls_result) = mo_cut->run(
      it_requests   = VALUE #( )
      iv_simulation = abap_true ).

    cl_abap_unit_assert=>assert_false( ls_result-log_saved ).
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

  METHOD creates_sap_composition.
    DATA(lo_app) = zcl_stock_allocation_app=>create_sap( ).

    cl_abap_unit_assert=>assert_bound( lo_app ).
  ENDMETHOD.
ENDCLASS.
