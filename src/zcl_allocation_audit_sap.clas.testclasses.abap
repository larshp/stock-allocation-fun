CLASS lcl_fail_alloc_write_auth DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_read_authority.
    INTERFACES zif_allocation_write_authority.
    INTERFACES zif_alloc_retention_auth.
ENDCLASS.

CLASS lcl_fail_alloc_write_auth IMPLEMENTATION.
  METHOD zif_allocation_read_authority~check_audit.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = 'Audit read authorization test failure'.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.

  METHOD zif_allocation_read_authority~check_results.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = 'Result read authorization test failure'.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.

  METHOD zif_allocation_write_authority~check_audit_write.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = 'Audit write authorization test failure'.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.

  METHOD zif_allocation_write_authority~check_result_write.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = 'Result write authorization test failure'.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.

  METHOD zif_allocation_write_authority~check_result_delete.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = 'Result delete authorization test failure'.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.

  METHOD zif_alloc_retention_auth~check.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = 'Retention authorization test failure'.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_blank_allocation_authority DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_read_authority.
    INTERFACES zif_allocation_write_authority.
    INTERFACES zif_alloc_retention_auth.
ENDCLASS.

CLASS lcl_blank_allocation_authority IMPLEMENTATION.
  METHOD zif_allocation_read_authority~check_audit.
    RAISE EXCEPTION TYPE zcx_stock_allocation.
  ENDMETHOD.

  METHOD zif_allocation_read_authority~check_results.
    RAISE EXCEPTION TYPE zcx_stock_allocation.
  ENDMETHOD.

  METHOD zif_allocation_write_authority~check_audit_write.
    RAISE EXCEPTION TYPE zcx_stock_allocation.
  ENDMETHOD.

  METHOD zif_allocation_write_authority~check_result_write.
    RAISE EXCEPTION TYPE zcx_stock_allocation.
  ENDMETHOD.

  METHOD zif_allocation_write_authority~check_result_delete.
    RAISE EXCEPTION TYPE zcx_stock_allocation.
  ENDMETHOD.

  METHOD zif_alloc_retention_auth~check.
    RAISE EXCEPTION TYPE zcx_stock_allocation.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_failing_audit_transaction DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_transaction.
ENDCLASS.

CLASS lcl_failing_audit_transaction IMPLEMENTATION.
  METHOD zif_allocation_transaction~commit.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = 'Audit transaction test failure'.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_allocation_audit_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS records_completed_run FOR TESTING.
    METHODS rejects_bad_rejection_metric FOR TESTING.
    METHODS rejects_invalid_movement_type FOR TESTING.
    METHODS rejects_corrupt_read FOR TESTING.
    METHODS rejects_inverted_timestamp FOR TESTING.
    METHODS filters_duration_bounds FOR TESTING.
    METHODS accepts_lowercase_unit FOR TESTING.
    METHODS filters_max_running_age FOR TESTING.
    METHODS filters_shortage_percentage FOR TESTING.
    METHODS accepts_largest_strategy FOR TESTING.
    METHODS accepts_best_strategy FOR TESTING.
    METHODS latest_summary_tie_breaker FOR TESTING.
    METHODS reports_completion_running FOR TESTING.
    METHODS reports_running_age FOR TESTING.
    METHODS summarizes_legacy_strategy FOR TESTING.
    METHODS summarizes_policy_context FOR TESTING.
    METHODS summarizes_filtered_runs FOR TESTING.
    METHODS purges_linked_snapshots FOR TESTING.
    METHODS purges_by_policy FOR TESTING.
    METHODS purges_by_status FOR TESTING.
    METHODS purges_by_run_id FOR TESTING.
    METHODS rejects_invalid_purge_status FOR TESTING.
    METHODS rejects_bad_mvt_filter FOR TESTING.
    METHODS rejects_purge_commit_failure FOR TESTING.
    METHODS rejects_finish_commit_failure FOR TESTING.
    METHODS rejects_rejection_commit FOR TESTING.
    METHODS fallback_authority_messages FOR TESTING.
ENDCLASS.

CLASS ltcl_allocation_audit_sap IMPLEMENTATION.
  METHOD accepts_largest_strategy.
    DATA lo_cut TYPE REF TO zif_allocation_audit.
    DATA lv_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lt_runs TYPE zif_allocation_audit=>tt_runs.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.

    CREATE OBJECT lo_cut TYPE zcl_allocation_audit_sap.
    lv_run_id = lo_cut->start_run(
      iv_material         = 'MATERIAL-AUDIT-LARGE'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_unit             = 'ea'
      iv_available        = '10'
      iv_demand_count     = 2
      iv_strategy         = 'l' ).
    lo_cut->finish_run(
      iv_run_id     = lv_run_id
      iv_status     = 's'
      iv_available  = '10'
      iv_allocated  = '10'
      iv_shortage   = '0'
      iv_full_count = 2
      iv_message    = '' ).

    lt_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT-LARGE'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_strategy         = 'l' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_runs )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_runs[ 1 ]-unit
      exp = 'EA' ).
    ls_summary = lo_cut->get_summary(
      iv_material         = 'MATERIAL-AUDIT-LARGE'
      iv_plant            = '1000'
      iv_storage_location = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-largest_runs
      exp = 1 ).
  ENDMETHOD.

  METHOD accepts_best_strategy.
    DATA lo_cut TYPE REF TO zif_allocation_audit.
    DATA lv_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lt_runs TYPE zif_allocation_audit=>tt_runs.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.

    CREATE OBJECT lo_cut TYPE zcl_allocation_audit_sap.
    lv_run_id = lo_cut->start_run(
      iv_material         = 'MATERIAL-AUDIT-BEST'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_unit             = 'EA'
      iv_available        = '10'
      iv_demand_count     = 3
      iv_strategy         = 'B' ).
    lo_cut->finish_run(
      iv_run_id     = lv_run_id
      iv_status     = 'S'
      iv_available  = '10'
      iv_allocated  = '10'
      iv_shortage   = '0'
      iv_full_count = 3
      iv_message    = '' ).

    lt_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT-BEST'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_strategy         = 'B' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_runs )
      exp = 1 ).
    ls_summary = lo_cut->get_summary(
      iv_material         = 'MATERIAL-AUDIT-BEST'
      iv_plant            = '1000'
      iv_storage_location = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-best_runs
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-best_requested
      exp = '10' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-best_allocated
      exp = '10' ).
  ENDMETHOD.

  METHOD latest_summary_tie_breaker.
    DATA lo_cut TYPE REF TO zif_allocation_audit.
    DATA lv_first_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_second_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_expected_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_expected_duration TYPE i.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.

    CREATE OBJECT lo_cut TYPE zcl_allocation_audit_sap.
    lv_first_run_id = lo_cut->start_run(
      iv_material         = 'MATERIAL-AUDIT-TIE'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_unit             = 'EA'
      iv_available        = '1'
      iv_demand_count     = 1 ).
    lo_cut->finish_run(
      iv_run_id    = lv_first_run_id
      iv_status    = 'S'
      iv_available = '1'
      iv_allocated = '1'
      iv_shortage  = '0'
      iv_message   = '' ).
    lv_second_run_id = lo_cut->start_run(
      iv_material         = 'MATERIAL-AUDIT-TIE'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_unit             = 'EA'
      iv_available        = '2'
      iv_demand_count     = 1 ).
    lo_cut->finish_run(
      iv_run_id    = lv_second_run_id
      iv_status    = 'S'
      iv_available = '2'
      iv_allocated = '2'
      iv_shortage  = '0'
      iv_message   = '' ).

    UPDATE zstockalloc_run
      SET start_date  = '20260701',
          start_time  = '010000',
          finish_date = '20260701',
          finish_time = '010001'
      WHERE run_id = @lv_first_run_id.
    UPDATE zstockalloc_run
      SET start_date  = '20260701',
          start_time  = '010000',
          finish_date = '20260701',
          finish_time = '010003'
      WHERE run_id = @lv_second_run_id.

    IF lv_first_run_id > lv_second_run_id.
      lv_expected_run_id = lv_first_run_id.
      lv_expected_duration = 1.
    ELSE.
      lv_expected_run_id = lv_second_run_id.
      lv_expected_duration = 3.
    ENDIF.
    ls_summary = lo_cut->get_summary(
      iv_material         = 'MATERIAL-AUDIT-TIE'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_unit             = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-last_run_id
      exp = lv_expected_run_id ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-last_duration_seconds
      exp = lv_expected_duration ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-average_duration_seconds
      exp = '2.00' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-minimum_duration_seconds
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-maximum_duration_seconds
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-completed_duration_runs
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-completion_pct
      exp = '100.00' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-success_rate_pct
      exp = '100.00' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-partial_rate_pct
      exp = '0.00' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-error_rate_pct
      exp = '0.00' ).
  ENDMETHOD.

  METHOD reports_completion_running.
    DATA lo_cut TYPE REF TO zif_allocation_audit.
    DATA lv_completed_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_running_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_newer_running_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_running_start_date TYPE d.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.

    CREATE OBJECT lo_cut TYPE zcl_allocation_audit_sap.
    lv_completed_run_id = lo_cut->start_run(
      iv_material         = 'MATERIAL-AUDIT-COMPLETION'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_unit             = 'EA'
      iv_available        = '1'
      iv_demand_count     = 1 ).
    lo_cut->finish_run(
      iv_run_id    = lv_completed_run_id
      iv_status    = 'S'
      iv_available = '1'
      iv_allocated = '1'
      iv_shortage  = '0'
      iv_message   = '' ).
    lv_running_run_id = lo_cut->start_run(
      iv_material         = 'MATERIAL-AUDIT-COMPLETION'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_unit             = 'EA'
      iv_available        = '1'
      iv_demand_count     = 1 ).
    lv_running_start_date = sy-datum - 1.
    UPDATE zstockalloc_run
      SET start_date = @lv_running_start_date,
          start_time = '000001'
      WHERE run_id = @lv_running_run_id.
    lv_newer_running_run_id = lo_cut->start_run(
      iv_material         = 'MATERIAL-AUDIT-COMPLETION'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_unit             = 'EA'
      iv_available        = '1'
      iv_demand_count     = 1 ).

    ls_summary = lo_cut->get_summary(
      iv_material         = 'MATERIAL-AUDIT-COMPLETION'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_unit             = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-total_runs
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-running_runs
      exp = 2 ).
    cl_abap_unit_assert=>assert_true(
      xsdbool( ls_summary-oldest_running_age_seconds >= 86399 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-oldest_running_run_id
      exp = lv_running_run_id ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-newest_running_run_id
      exp = lv_newer_running_run_id ).
    cl_abap_unit_assert=>assert_true(
      xsdbool( ls_summary-newest_running_age_seconds
        < ls_summary-oldest_running_age_seconds ) ).
    cl_abap_unit_assert=>assert_not_initial( lv_running_run_id ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-completed_duration_runs
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-completion_pct
      exp = '33.33' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-success_rate_pct
      exp = '100.00' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-partial_rate_pct
      exp = '0.00' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-error_rate_pct
      exp = '0.00' ).
  ENDMETHOD.

  METHOD reports_running_age.
    DATA lo_cut TYPE REF TO zif_allocation_audit.
    DATA ls_run TYPE zif_allocation_audit=>ty_run.
    DATA ls_age TYPE zif_allocation_audit=>ty_running_age.
    DATA lv_reference_date TYPE d.
    DATA lv_reference_time TYPE t.

    CREATE OBJECT lo_cut TYPE zcl_allocation_audit_sap.
    ls_run-status = 'R'.
    ls_run-start_date = sy-datum - 1.
    ls_run-start_time = '000001'.
    ls_age = lo_cut->get_running_age( ls_run ).
    cl_abap_unit_assert=>assert_true( ls_age-available ).
    cl_abap_unit_assert=>assert_true(
      xsdbool( ls_age-seconds >= 86399 ) ).

    ls_run-start_date = '20260101'.
    ls_run-start_time = '120001'.
    lv_reference_date = '20260102'.
    lv_reference_time = '120001'.
    ls_age = lo_cut->get_running_age(
      is_run      = ls_run
      iv_now_date = lv_reference_date
      iv_now_time = lv_reference_time ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_age-seconds
      exp = 86400 ).

    ls_run-finish_date = sy-datum.
    ls_run-finish_time = sy-uzeit.
    ls_age = lo_cut->get_running_age( ls_run ).
    cl_abap_unit_assert=>assert_false( ls_age-available ).
    cl_abap_unit_assert=>assert_initial( ls_age-seconds ).
  ENDMETHOD.

  METHOD summarizes_legacy_strategy.
    DATA lo_cut TYPE REF TO zif_allocation_audit.
    DATA lv_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_cut TYPE zcl_allocation_audit_sap.
    lv_run_id = lo_cut->start_run(
      iv_material         = 'MATERIAL-AUDIT-LEGACY'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_unit             = 'EA'
      iv_available        = '4'
      iv_demand_count     = 1 ).
    lo_cut->finish_run(
      iv_run_id        = lv_run_id
      iv_status        = 'P'
      iv_available     = '4'
      iv_allocated     = '2'
      iv_shortage      = '2'
      iv_partial_count = 1
      iv_message       = 'Legacy strategy test' ).

    ls_summary = lo_cut->get_summary(
      iv_material         = 'MATERIAL-AUDIT-LEGACY'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_legacy_strategy  = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-total_runs
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-legacy_strategy_runs
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-legacy_allocated
      exp = '2' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-legacy_shortage
      exp = '2' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-legacy_requested
      exp = '4' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-coverage
      exp = '50.00' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-legacy_coverage
      exp = '50.00' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-shortage_pct
      exp = '50.00' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-success_rate_pct
      exp = '0.00' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-partial_rate_pct
      exp = '100.00' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-error_rate_pct
      exp = '0.00' ).
    TRY.
        lo_cut->get_summary(
          iv_material         = 'MATERIAL-AUDIT-LEGACY'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_strategy         = 'P'
          iv_legacy_strategy  = abap_true ).
      CATCH zcx_stock_allocation INTO DATA(lo_conflict_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_conflict_error->message
          exp = 'Audit strategy filters conflict' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD summarizes_policy_context.
    DATA lo_cut TYPE REF TO zif_allocation_audit.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA lv_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lt_runs TYPE zif_allocation_audit=>tt_runs.

    CREATE OBJECT lo_cut TYPE zcl_allocation_audit_sap.
    lv_run_id = lo_cut->start_run(
      iv_material          = 'MATERIAL-AUDIT-POLICY'
      iv_plant             = '1000'
      iv_storage_location  = '0001'
      iv_movement_type     = '201'
      iv_min_shelf_life    = 5
      iv_unit              = 'EA'
      iv_available         = '10'
      iv_demand_count      = 1
      iv_requested_on_from = '20260801'
      iv_requested_on_to   = '20260807' ).
    lo_cut->finish_run(
      iv_run_id    = lv_run_id
      iv_status    = 'S'
      iv_available = '10'
      iv_allocated = '1'
      iv_shortage  = '0'
      iv_message   = '' ).

    lv_run_id = lo_cut->start_run(
      iv_material          = 'MATERIAL-AUDIT-POLICY'
      iv_plant             = '1000'
      iv_storage_location  = '0001'
      iv_movement_type     = '202'
      iv_min_shelf_life    = 7
      iv_unit              = 'EA'
      iv_available         = '10'
      iv_demand_count      = 1
      iv_requested_on_from = '20260901'
      iv_requested_on_to   = '20260907' ).
    lo_cut->finish_run(
      iv_run_id    = lv_run_id
      iv_status    = 'S'
      iv_available = '10'
      iv_allocated = '2'
      iv_shortage  = '0'
      iv_message   = '' ).

    ls_summary = lo_cut->get_summary(
      iv_material         = 'MATERIAL-AUDIT-POLICY'
      iv_plant            = '1000'
      iv_storage_location = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-total_runs
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-movement_type_context
      exp = 'mixed' ).
    cl_abap_unit_assert=>assert_true(
      ls_summary-policy_context_available ).
    cl_abap_unit_assert=>assert_true(
      ls_summary-mixed_policies ).
    cl_abap_unit_assert=>assert_initial(
      ls_summary-min_shelf_life_context ).
    lt_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT-POLICY'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_movement_type    = '201' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_runs )
      exp = 1 ).
    lt_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT-POLICY'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_min_shelf_life   = 7 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_runs )
      exp = 1 ).
  ENDMETHOD.

  METHOD summarizes_filtered_runs.
    DATA lo_cut TYPE REF TO zif_allocation_audit.
    DATA lv_success_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_partial_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_fragment TYPE zif_allocation_audit=>ty_run_id.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA lt_runs TYPE zif_allocation_audit=>tt_runs.
    DATA lv_duration TYPE i.

    CREATE OBJECT lo_cut TYPE zcl_allocation_audit_sap.
    lv_success_run_id = lo_cut->start_run(
      iv_material          = 'MATERIAL-AUDIT-SUMMARY-FILTER'
      iv_plant             = '1000'
      iv_storage_location  = '0001'
      iv_unit              = 'EA'
      iv_available         = '10'
      iv_demand_count      = 1
      iv_requested_on_from = '20260801'
      iv_requested_on_to   = '20260807' ).
    lo_cut->finish_run(
      iv_run_id    = lv_success_run_id
      iv_status    = 'S'
      iv_available = '10'
      iv_allocated = '10'
      iv_shortage  = '0'
      iv_message   = '' ).
    lv_partial_run_id = lo_cut->start_run(
      iv_material          = 'MATERIAL-AUDIT-SUMMARY-FILTER'
      iv_plant             = '1000'
      iv_storage_location  = '0001'
      iv_unit              = 'EA'
      iv_available         = '8'
      iv_demand_count      = 2
      iv_requested_on_from = '20260901'
      iv_requested_on_to   = '20260907' ).
    lo_cut->finish_run(
      iv_run_id    = lv_partial_run_id
      iv_status    = 'P'
      iv_available = '8'
      iv_allocated = '5'
      iv_shortage  = '5'
      iv_message   = 'Filtered summary test' ).
    UPDATE zstockalloc_run
      SET start_date  = '20260802',
          start_time  = '010000',
          finish_date = '20260802',
          finish_time = '011000'
      WHERE run_id = @lv_success_run_id.
    UPDATE zstockalloc_run
      SET start_date  = '20260902',
          start_time  = '020000',
          finish_date = '20260902',
          finish_time = '020200'
      WHERE run_id = @lv_partial_run_id.

    lt_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT-SUMMARY-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_run_id           = lv_partial_run_id ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_runs[ 1 ]-start_time
      exp = '020000' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_runs[ 1 ]-finish_time
      exp = '020200' ).
    cl_abap_tstmp=>td_subtract(
      EXPORTING
        date1    = lt_runs[ 1 ]-finish_date
        time1    = lt_runs[ 1 ]-finish_time
        date2    = lt_runs[ 1 ]-start_date
        time2    = lt_runs[ 1 ]-start_time
      IMPORTING
        res_secs = lv_duration ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_duration
      exp = 120 ).
    lt_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT-SUMMARY-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_run_id           = lv_partial_run_id
      iv_duration_from    = 1
      iv_duration_to      = 10000 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_runs )
      exp = 1 ).

    ls_summary = lo_cut->get_summary(
      iv_material         = 'MATERIAL-AUDIT-SUMMARY-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_run_id           = lv_success_run_id
      iv_status           = 's' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-total_runs
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-success_runs
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-demand_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-requested
      exp = '10' ).

    lv_fragment = lv_partial_run_id(8).
    TRANSLATE lv_fragment TO LOWER CASE.
    ls_summary = lo_cut->get_summary(
      iv_material         = 'MATERIAL-AUDIT-SUMMARY-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_run_id_contains  = lv_fragment
      iv_status           = 'p' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-total_runs
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-partial_runs
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-last_run_id
      exp = lv_partial_run_id ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-demand_count
      exp = 2 ).

    ls_summary = lo_cut->get_summary(
      iv_material          = 'MATERIAL-AUDIT-SUMMARY-FILTER'
      iv_plant             = '1000'
      iv_storage_location  = '0001'
      iv_requested_on_from = '20260901'
      iv_requested_on_to   = '20260907'
      iv_start_date_from   = '20260902'
      iv_start_date_to     = '20260902'
      iv_finish_date_from  = '20260902'
      iv_finish_date_to    = '20260902'
      iv_duration_from     = 100
      iv_duration_to       = 200
      iv_coverage_from     = 50
      iv_coverage_to       = 50
      iv_shortage_pct_from = 50
      iv_shortage_pct_to   = 50
      iv_shortage_from     = 5
      iv_shortage_to       = 5
      iv_allocated_from    = 5
      iv_allocated_to      = 5
      iv_available_from    = 8
      iv_available_to      = 8
      iv_requested_from    = 10
      iv_requested_to      = 10
      iv_demand_from       = 2
      iv_demand_to         = 2
      iv_message_contains  = 'FILTERED SUMMARY'
      iv_message_only      = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-total_runs
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-last_run_id
      exp = lv_partial_run_id ).
  ENDMETHOD.

  METHOD rejects_bad_rejection_metric.
    DATA lo_cut TYPE REF TO zif_allocation_audit.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_cut TYPE zcl_allocation_audit_sap.
    TRY.
        lo_cut->record_rejection(
          iv_material         = 'MATERIAL-AUDIT-NEGATIVE'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_unit             = 'EA'
          iv_available        = '-1'
          iv_message          = 'Negative rejection metric' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Audit rejection metrics are invalid' ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD rejects_corrupt_read.
    DATA lo_cut TYPE REF TO zif_allocation_audit.
    DATA lt_runs TYPE zif_allocation_audit=>tt_runs.
    DATA ls_run TYPE zstockalloc_run.
    DATA lv_raised TYPE abap_bool.

    ls_run-mandt = sy-mandt.
    ls_run-run_id = 'RUN-AUDIT-CORRUPT'.
    ls_run-matnr = 'MATERIAL-AUDIT-CORRUPT'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0001'.
    ls_run-unit = 'EA'.
    ls_run-start_date = sy-datum.
    ls_run-start_time = sy-uzeit.
    ls_run-finish_date = sy-datum.
    ls_run-finish_time = sy-uzeit.
    ls_run-status = 'S'.
    ls_run-available = 1.
    ls_run-allocated = 2.
    ls_run-shortage = 0.
    INSERT zstockalloc_run FROM @ls_run.

    CREATE OBJECT lo_cut TYPE zcl_allocation_audit_sap.
    TRY.
        lt_runs = lo_cut->get_runs(
          iv_material         = 'MATERIAL-AUDIT-CORRUPT'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Audit run data is invalid' ).
    ENDTRY.
    DELETE FROM zstockalloc_run
      WHERE run_id = 'RUN-AUDIT-CORRUPT'.
    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD rejects_inverted_timestamp.
    DATA lo_cut TYPE REF TO zif_allocation_audit.
    DATA lt_runs TYPE zif_allocation_audit=>tt_runs.
    DATA ls_run TYPE zstockalloc_run.
    DATA lv_raised TYPE abap_bool.

    ls_run-mandt = sy-mandt.
    ls_run-run_id = 'RUN-AUDIT-TIME'.
    ls_run-matnr = 'MATERIAL-AUDIT-TIME'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0001'.
    ls_run-unit = 'EA'.
    ls_run-start_date = '20260102'.
    ls_run-start_time = '120000'.
    ls_run-finish_date = '20260102'.
    ls_run-finish_time = '110000'.
    ls_run-status = 'S'.
    ls_run-available = 1.
    ls_run-allocated = 1.
    INSERT zstockalloc_run FROM @ls_run.

    CREATE OBJECT lo_cut TYPE zcl_allocation_audit_sap.
    TRY.
        lt_runs = lo_cut->get_runs(
          iv_material         = 'MATERIAL-AUDIT-TIME'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Audit run data is invalid' ).
    ENDTRY.
    DELETE FROM zstockalloc_run
      WHERE run_id = 'RUN-AUDIT-TIME'.
    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD rejects_invalid_movement_type.
    DATA lo_cut TYPE REF TO zif_allocation_audit.
    DATA lv_raised TYPE abap_bool.
    DATA lv_run_id TYPE zif_allocation_audit=>ty_run_id.

    CREATE OBJECT lo_cut TYPE zcl_allocation_audit_sap.
    TRY.
        lv_run_id = lo_cut->start_run(
          iv_material         = 'MATERIAL-AUDIT-MVT'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '2A1'
          iv_unit             = 'EA'
          iv_available        = '1'
          iv_demand_count     = 1 ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Audit movement type is invalid' ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_initial( lv_run_id ).
    SELECT COUNT( * )
      FROM zstockalloc_run
      INTO @DATA(lv_run_count)
      WHERE matnr = 'MATERIAL-AUDIT-MVT'
        AND werks = '1000'
        AND lgort = '0001'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_run_count
      exp = 0 ).
  ENDMETHOD.

  METHOD filters_duration_bounds.
    DATA lo_cut TYPE REF TO zif_allocation_audit.
    DATA ls_run TYPE zstockalloc_run.
    DATA lt_runs TYPE zif_allocation_audit=>tt_runs.
    DATA lv_raised TYPE abap_bool.

    ls_run-mandt = sy-mandt.
    ls_run-run_id = 'RUN-AUDIT-DURATION'.
    ls_run-matnr = 'MATERIAL-AUDIT-DURATION'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0001'.
    ls_run-unit = 'EA'.
    ls_run-start_date = '20260101'.
    ls_run-start_time = '010000'.
    ls_run-finish_date = '20260101'.
    ls_run-finish_time = '010001'.
    ls_run-status = 'S'.
    ls_run-available = 1.
    ls_run-demand_count = 1.
    ls_run-allocated = 1.
    INSERT zstockalloc_run FROM @ls_run.

    CLEAR ls_run.
    ls_run-mandt = sy-mandt.
    ls_run-run_id = 'RUN-AUDIT-STALE'.
    ls_run-matnr = 'MATERIAL-AUDIT-DURATION'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0001'.
    ls_run-unit = 'EA'.
    ls_run-start_date = '20260101'.
    ls_run-start_time = '010000'.
    ls_run-status = 'R'.
    ls_run-available = 1.
    ls_run-demand_count = 1.
    INSERT zstockalloc_run FROM @ls_run.

    CREATE OBJECT lo_cut TYPE zcl_allocation_audit_sap.
    lt_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT-DURATION'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_duration_from    = 1
      iv_duration_to      = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_runs )
      exp = 1 ).

    lt_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT-DURATION'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_stale_seconds    = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_runs )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_runs[ 1 ]-run_id
      exp = 'RUN-AUDIT-STALE' ).
    TRY.
        lo_cut->get_runs(
          iv_material         = 'MATERIAL-AUDIT-DURATION'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_stale_seconds    = -1 ).
      CATCH zcx_stock_allocation INTO DATA(lo_stale_threshold_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_stale_threshold_error->message
          exp = 'Audit stale-running threshold is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.
    TRY.
        lo_cut->get_runs(
          iv_material         = 'MATERIAL-AUDIT-DURATION'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_duration_from    = -1 ).
      CATCH zcx_stock_allocation INTO DATA(lo_negative_duration_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_negative_duration_error->message
          exp = 'Audit duration range is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.
    TRY.
        lo_cut->get_runs(
          iv_material         = 'MATERIAL-AUDIT-DURATION'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_duration_from    = 2
          iv_duration_to      = 1 ).
      CATCH zcx_stock_allocation INTO DATA(lo_reversed_duration_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_reversed_duration_error->message
          exp = 'Audit duration range is invalid' ).
    ENDTRY.
    DELETE FROM zstockalloc_run
      WHERE run_id = 'RUN-AUDIT-DURATION'.
    DELETE FROM zstockalloc_run
      WHERE run_id = 'RUN-AUDIT-STALE'.
    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD accepts_lowercase_unit.
    DATA lo_cut TYPE REF TO zif_allocation_audit.
    DATA lv_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lt_runs TYPE zif_allocation_audit=>tt_runs.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.

    CREATE OBJECT lo_cut TYPE zcl_allocation_audit_sap.
    lv_run_id = lo_cut->start_run(
      iv_material         = 'MATERIAL-AUDIT-UNIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_unit             = 'EA'
      iv_available        = '1'
      iv_demand_count     = 1 ).
    lt_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT-UNIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_unit             = 'ea' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_runs )
      exp = 1 ).
    ls_summary = lo_cut->get_summary(
      iv_material         = 'MATERIAL-AUDIT-UNIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_unit             = 'ea' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-unit
      exp = 'EA' ).
    DELETE FROM zstockalloc_run
      WHERE run_id = @lv_run_id.
  ENDMETHOD.

  METHOD filters_max_running_age.
    DATA lo_cut TYPE REF TO zif_allocation_audit.
    DATA ls_run TYPE zstockalloc_run.
    DATA lt_runs TYPE zif_allocation_audit=>tt_runs.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA lv_raised TYPE abap_bool.

    ls_run-mandt = sy-mandt.
    ls_run-run_id = 'RUN-AUDIT-AGE-OLD'.
    ls_run-matnr = 'MATERIAL-AUDIT-AGE'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0001'.
    ls_run-unit = 'EA'.
    ls_run-start_date = '20260101'.
    ls_run-start_time = '010000'.
    ls_run-status = 'R'.
    ls_run-available = 1.
    ls_run-demand_count = 1.
    INSERT zstockalloc_run FROM @ls_run.

    CLEAR ls_run.
    ls_run-mandt = sy-mandt.
    ls_run-run_id = 'RUN-AUDIT-AGE-NOW'.
    ls_run-matnr = 'MATERIAL-AUDIT-AGE'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0001'.
    ls_run-unit = 'EA'.
    ls_run-start_date = sy-datum.
    ls_run-start_time = sy-uzeit.
    ls_run-status = 'R'.
    ls_run-available = 1.
    ls_run-demand_count = 1.
    INSERT zstockalloc_run FROM @ls_run.

    CREATE OBJECT lo_cut TYPE zcl_allocation_audit_sap.
    lt_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT-AGE'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_running_age_to   = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_runs )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_runs[ 1 ]-run_id
      exp = 'RUN-AUDIT-AGE-NOW' ).
    ls_summary = lo_cut->get_summary(
      iv_material         = 'MATERIAL-AUDIT-AGE'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_running_age_to   = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-total_runs
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-last_run_id
      exp = 'RUN-AUDIT-AGE-NOW' ).
    ls_summary = lo_cut->get_summary(
      iv_material         = 'MATERIAL-AUDIT-AGE'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_stale_seconds    = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-total_runs
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-last_run_id
      exp = 'RUN-AUDIT-AGE-OLD' ).

    TRY.
        lo_cut->get_runs(
          iv_material         = 'MATERIAL-AUDIT-AGE'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_running_age_to   = -1 ).
      CATCH zcx_stock_allocation INTO DATA(lo_age_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_age_error->message
          exp = 'Audit maximum running age is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.
    TRY.
        lo_cut->get_runs(
          iv_material         = 'MATERIAL-AUDIT-AGE'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_stale_seconds    = 10
          iv_running_age_to   = 1 ).
      CATCH zcx_stock_allocation INTO DATA(lo_age_bounds_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_age_bounds_error->message
          exp = 'Audit running age bounds are invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    DELETE FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-AUDIT-AGE'.
  ENDMETHOD.

  METHOD filters_shortage_percentage.
    DATA lo_cut TYPE REF TO zif_allocation_audit.
    DATA ls_run TYPE zstockalloc_run.
    DATA lt_runs TYPE zif_allocation_audit=>tt_runs.
    DATA lv_raised TYPE abap_bool.

    ls_run-mandt = sy-mandt.
    ls_run-run_id = 'RUN-AUDIT-SHORTAGE-PCT-FULL'.
    ls_run-matnr = 'MATERIAL-AUDIT-SHORTAGE-PCT'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0001'.
    ls_run-unit = 'EA'.
    ls_run-start_date = '20260101'.
    ls_run-start_time = '010000'.
    ls_run-finish_date = '20260101'.
    ls_run-finish_time = '010001'.
    ls_run-status = 'S'.
    ls_run-available = 1.
    ls_run-demand_count = 1.
    ls_run-allocated = 1.
    INSERT zstockalloc_run FROM @ls_run.

    CLEAR ls_run.
    ls_run-mandt = sy-mandt.
    ls_run-run_id = 'RUN-AUD-SHPCT-SHORT'.
    ls_run-matnr = 'MATERIAL-AUDIT-SHORTAGE-PCT'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0001'.
    ls_run-unit = 'EA'.
    ls_run-start_date = '20260101'.
    ls_run-start_time = '010000'.
    ls_run-finish_date = '20260101'.
    ls_run-finish_time = '010001'.
    ls_run-status = 'P'.
    ls_run-available = 1.
    ls_run-demand_count = 1.
    ls_run-shortage = 1.
    ls_run-message = 'Shortage test run'.
    INSERT zstockalloc_run FROM @ls_run.

    CREATE OBJECT lo_cut TYPE zcl_allocation_audit_sap.
    lt_runs = lo_cut->get_runs(
      iv_material          = 'MATERIAL-AUDIT-SHORTAGE-PCT'
      iv_plant             = '1000'
      iv_storage_location  = '0001'
      iv_shortage_pct_from = 100
      iv_shortage_pct_to   = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_runs )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_runs[ 1 ]-run_id
      exp = 'RUN-AUD-SHPCT-SHORT' ).

    lt_runs = lo_cut->get_runs(
      iv_material          = 'MATERIAL-AUDIT-SHORTAGE-PCT'
      iv_plant             = '1000'
      iv_storage_location  = '0001'
      iv_coverage_from     = 0
      iv_coverage_to       = 100
      iv_shortage_pct_from = 100
      iv_shortage_pct_to   = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_runs )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_runs[ 1 ]-run_id
      exp = 'RUN-AUD-SHPCT-SHORT' ).

    lt_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT-SHORTAGE-PCT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_sort_by_shrt_pct = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_runs )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_runs[ 1 ]-run_id
      exp = 'RUN-AUD-SHPCT-SHORT' ).

    CLEAR lv_raised.
    TRY.
        lo_cut->get_runs(
          iv_material          = 'MATERIAL-AUDIT-SHORTAGE-PCT'
          iv_plant             = '1000'
          iv_storage_location  = '0001'
          iv_shortage_pct_from = 101 ).
      CATCH zcx_stock_allocation INTO DATA(lo_shortage_pct_bound_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_shortage_pct_bound_error->message
          exp = 'Audit shortage percentage range is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    TRY.
        lo_cut->get_runs(
          iv_material          = 'MATERIAL-AUDIT-SHORTAGE-PCT'
          iv_plant             = '1000'
          iv_storage_location  = '0001'
          iv_shortage_pct_from = 80
          iv_shortage_pct_to   = 20 ).
      CATCH zcx_stock_allocation INTO DATA(lo_shortage_pct_order_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_shortage_pct_order_error->message
          exp = 'Audit shortage percentage range is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    DELETE FROM zstockalloc_run
      WHERE run_id = 'RUN-AUDIT-SHORTAGE-PCT-FULL'.
    DELETE FROM zstockalloc_run
      WHERE run_id = 'RUN-AUD-SHPCT-SHORT'.
  ENDMETHOD.

  METHOD purges_linked_snapshots.
    DATA lo_cut TYPE REF TO zif_allocation_audit.
    DATA ls_run TYPE zstockalloc_run.
    DATA ls_allocation TYPE zstockalloc.
     DATA lv_deleted TYPE i.
     DATA lv_deleted_snapshots TYPE i.
    DATA lv_snapshot_count TYPE i.
    DATA ls_preview TYPE zif_allocation_audit=>ty_purge_preview.

    ls_run-mandt = sy-mandt.
    ls_run-run_id = 'RUN-PURGE-SNAPSHOT'.
    ls_run-matnr = 'MATERIAL-PURGE-SNAPSHOT'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0001'.
    ls_run-unit = 'EA'.
    ls_run-start_date = '20260101'.
    ls_run-start_time = '010000'.
    ls_run-finish_date = '20260101'.
    ls_run-finish_time = '010001'.
    ls_run-status = 'S'.
    ls_run-available = 1.
    ls_run-demand_count = 1.
    ls_run-allocated = 1.
    ls_run-shortage = 0.
     INSERT zstockalloc_run FROM @ls_run.
     ls_run-run_id = 'RUN-PURGE-SNAPSHOT-2'.
     INSERT zstockalloc_run FROM @ls_run.

    ls_allocation-mandt = sy-mandt.
    ls_allocation-matnr = 'MATERIAL-PURGE-SNAPSHOT'.
    ls_allocation-werks = '1000'.
    ls_allocation-lgort = '0001'.
    ls_allocation-run_id = 'RUN-PURGE-SNAPSHOT'.
    ls_allocation-allocation_unit = 'EA'.
    ls_allocation-order_id = 'PURGE-ORDER-001'.
    ls_allocation-requested = 1.
    ls_allocation-allocated = 1.
    ls_allocation-shortage = 0.
    ls_allocation-allocation_status = 'F'.
    INSERT zstockalloc FROM @ls_allocation.
    ls_allocation-order_id = 'PURGE-ORDER-002'.
    INSERT zstockalloc FROM @ls_allocation.
    ls_allocation-run_id = 'RUN-PURGE-SNAPSHOT-2'.
    ls_allocation-order_id = 'PURGE-ORDER-003'.
    INSERT zstockalloc FROM @ls_allocation.

    CLEAR ls_run.
    ls_run-mandt = sy-mandt.
    ls_run-run_id = 'RUN-PURGE-RUNNING'.
    ls_run-matnr = 'MATERIAL-PURGE-SNAPSHOT'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0001'.
    ls_run-unit = 'EA'.
    ls_run-start_date = '20260101'.
    ls_run-start_time = '010000'.
    ls_run-status = 'R'.
    ls_run-available = 1.
    INSERT zstockalloc_run FROM @ls_run.
    CREATE OBJECT lo_cut TYPE zcl_allocation_audit_sap.
    ls_preview = lo_cut->get_purge_preview(
      iv_material         = 'MATERIAL-PURGE-SNAPSHOT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_unit             = 'EA'
      iv_before_date      = sy-datum ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_preview-audit_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_preview-snapshot_count
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_preview-running_count
      exp = 1 ).
    lv_deleted = lo_cut->purge_runs_before(
      EXPORTING
        iv_material          = 'MATERIAL-PURGE-SNAPSHOT'
        iv_plant             = '1000'
        iv_storage_location  = '0001'
        iv_unit              = 'EA'
        iv_before_date       = sy-datum
      IMPORTING
        ev_deleted_snapshots = lv_deleted_snapshots ).

    SELECT COUNT( * )
      FROM zstockalloc
      INTO @lv_snapshot_count
      WHERE matnr = 'MATERIAL-PURGE-SNAPSHOT'
        AND werks = '1000'
        AND lgort = '0001'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_deleted
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_deleted_snapshots
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_snapshot_count
      exp = 0 ).
    SELECT COUNT( * )
      FROM zstockalloc_run
      INTO @DATA(lv_running_count)
      WHERE run_id = 'RUN-PURGE-RUNNING'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_running_count
      exp = 1 ).
    DELETE FROM zstockalloc_run
      WHERE run_id = 'RUN-PURGE-RUNNING'.
  ENDMETHOD.

  METHOD purges_by_policy.
    DATA lo_cut TYPE REF TO zif_allocation_audit.
    DATA ls_run TYPE zstockalloc_run.
    DATA ls_allocation TYPE zstockalloc.
    DATA ls_preview TYPE zif_allocation_audit=>ty_purge_preview.
    DATA lv_deleted TYPE i.
    DATA lv_deleted_snapshots TYPE i.
    DATA lv_count TYPE i.

    ls_run-mandt = sy-mandt.
    ls_run-matnr = 'MATERIAL-PURGE-POLICY'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0001'.
    ls_run-unit = 'EA'.
    ls_run-start_date = '20260101'.
    ls_run-start_time = '010000'.
    ls_run-finish_date = '20260101'.
    ls_run-finish_time = '010001'.
    ls_run-status = 'S'.
    ls_run-available = 1.
    ls_run-demand_count = 1.
    ls_run-allocated = 1.
    ls_run-shortage = 0.
    ls_run-run_id = 'RUN-PURGE-POLICY-MATCH'.
    ls_run-movement_type = '201'.
    ls_run-min_shelf_life = 5.
    INSERT zstockalloc_run FROM @ls_run.
    ls_run-run_id = 'RUN-PURGE-POLICY-OTHER'.
    ls_run-movement_type = '202'.
    ls_run-min_shelf_life = 7.
    INSERT zstockalloc_run FROM @ls_run.

    ls_allocation-mandt = sy-mandt.
    ls_allocation-matnr = 'MATERIAL-PURGE-POLICY'.
    ls_allocation-werks = '1000'.
    ls_allocation-lgort = '0001'.
    ls_allocation-allocation_unit = 'EA'.
    ls_allocation-order_id = 'PURGE-POLICY-ORDER'.
    ls_allocation-requested = 1.
    ls_allocation-allocated = 1.
    ls_allocation-shortage = 0.
    ls_allocation-allocation_status = 'F'.
    ls_allocation-run_id = 'RUN-PURGE-POLICY-MATCH'.
    INSERT zstockalloc FROM @ls_allocation.
    ls_allocation-run_id = 'RUN-PURGE-POLICY-OTHER'.
    INSERT zstockalloc FROM @ls_allocation.

    CLEAR ls_run.
    ls_run-mandt = sy-mandt.
    ls_run-run_id = 'RUN-PURGE-POLICY-RUNNING'.
    ls_run-matnr = 'MATERIAL-PURGE-POLICY'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0001'.
    ls_run-unit = 'EA'.
    ls_run-start_date = '20260101'.
    ls_run-start_time = '010000'.
    ls_run-status = 'R'.
    ls_run-movement_type = '201'.
    ls_run-min_shelf_life = 5.
    ls_run-available = 1.
    INSERT zstockalloc_run FROM @ls_run.

    CREATE OBJECT lo_cut TYPE zcl_allocation_audit_sap.
    ls_preview = lo_cut->get_purge_preview(
      iv_material         = 'MATERIAL-PURGE-POLICY'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_unit             = 'ea'
      iv_movement_type    = '201'
      iv_min_shelf_life   = 5
      iv_before_date      = sy-datum ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_preview-audit_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_preview-snapshot_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_preview-running_count
      exp = 1 ).

    lv_deleted = lo_cut->purge_runs_before(
      EXPORTING
        iv_material          = 'MATERIAL-PURGE-POLICY'
        iv_plant             = '1000'
        iv_storage_location  = '0001'
        iv_unit              = 'ea'
        iv_movement_type     = '201'
        iv_min_shelf_life    = 5
        iv_before_date       = sy-datum
      IMPORTING
        ev_deleted_snapshots = lv_deleted_snapshots ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_deleted
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_deleted_snapshots
      exp = 1 ).
    SELECT COUNT( * )
      FROM zstockalloc_run
      INTO @lv_count
      WHERE run_id = 'RUN-PURGE-POLICY-OTHER'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_count
      exp = 1 ).
    SELECT COUNT( * )
      FROM zstockalloc_run
      INTO @lv_count
      WHERE run_id = 'RUN-PURGE-POLICY-RUNNING'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_count
      exp = 1 ).
    DELETE FROM zstockalloc
      WHERE matnr = 'MATERIAL-PURGE-POLICY'.
    DELETE FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PURGE-POLICY'.
  ENDMETHOD.

  METHOD purges_by_status.
    DATA lo_cut TYPE REF TO zif_allocation_audit.
    DATA ls_run TYPE zstockalloc_run.
    DATA ls_allocation TYPE zstockalloc.
    DATA ls_preview TYPE zif_allocation_audit=>ty_purge_preview.
    DATA lv_deleted TYPE i.
    DATA lv_deleted_snapshots TYPE i.
    DATA lv_deleted_success TYPE i.
    DATA lv_deleted_partial TYPE i.
    DATA lv_deleted_error TYPE i.
    DATA lv_protected_running TYPE i.
    DATA lv_protected_unknown TYPE i.
    DATA lv_count TYPE i.

    ls_run-mandt = sy-mandt.
    ls_run-matnr = 'MATERIAL-PURGE-STATUS'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0001'.
    ls_run-unit = 'EA'.
    ls_run-start_date = '20260101'.
    ls_run-start_time = '010000'.
    ls_run-finish_date = '20260101'.
    ls_run-finish_time = '010001'.
    ls_run-available = 1.
    ls_run-demand_count = 1.
    ls_run-allocated = 1.
    ls_run-shortage = 0.
    ls_run-status = 'S'.
    ls_run-run_id = 'RUN-PURGE-STATUS-SUCCESS'.
    INSERT zstockalloc_run FROM @ls_run.
    ls_run-status = 'P'.
    ls_run-shortage = 1.
    ls_run-allocated = 0.
    ls_run-message = 'Shortage retained for status test'.
    ls_run-run_id = 'RUN-PURGE-STATUS-PARTIAL'.
    INSERT zstockalloc_run FROM @ls_run.

    ls_allocation-mandt = sy-mandt.
    ls_allocation-matnr = 'MATERIAL-PURGE-STATUS'.
    ls_allocation-werks = '1000'.
    ls_allocation-lgort = '0001'.
    ls_allocation-allocation_unit = 'EA'.
    ls_allocation-order_id = 'PURGE-STATUS-ORDER'.
    ls_allocation-requested = 1.
    ls_allocation-allocated = 0.
    ls_allocation-shortage = 1.
    ls_allocation-allocation_status = 'P'.
    ls_allocation-run_id = 'RUN-PURGE-STATUS-PARTIAL'.
    INSERT zstockalloc FROM @ls_allocation.

    CLEAR ls_run.
    ls_run-mandt = sy-mandt.
    ls_run-run_id = 'RUN-PURGE-STATUS-RUNNING'.
    ls_run-matnr = 'MATERIAL-PURGE-STATUS'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0001'.
    ls_run-unit = 'EA'.
    ls_run-start_date = '20260101'.
    ls_run-start_time = '010000'.
    ls_run-status = 'R'.
    ls_run-available = 1.
    INSERT zstockalloc_run FROM @ls_run.
    ls_run-run_id = 'RUN-PURGE-STATUS-UNKNOWN'.
    ls_run-status = 'X'.
    INSERT zstockalloc_run FROM @ls_run.

    CREATE OBJECT lo_cut TYPE zcl_allocation_audit_sap.
    ls_preview = lo_cut->get_purge_preview(
      iv_material         = 'MATERIAL-PURGE-STATUS'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_unit             = 'EA'
      iv_before_date      = sy-datum ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_preview-audit_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_preview-success_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_preview-partial_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_preview-error_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_preview-unknown_count
      exp = 1 ).
    ls_preview = lo_cut->get_purge_preview(
      iv_material         = 'MATERIAL-PURGE-STATUS'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_unit             = 'EA'
      iv_status           = 'p'
      iv_before_date      = sy-datum ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_preview-audit_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_preview-snapshot_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_preview-running_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_initial( ls_preview-unknown_count ).

    lv_deleted = lo_cut->purge_runs_before(
      EXPORTING
        iv_material          = 'MATERIAL-PURGE-STATUS'
        iv_plant             = '1000'
        iv_storage_location  = '0001'
        iv_unit              = 'EA'
        iv_status            = 'p'
        iv_before_date       = sy-datum
      IMPORTING
        ev_deleted_snapshots = lv_deleted_snapshots
        ev_deleted_success   = lv_deleted_success
        ev_deleted_partial   = lv_deleted_partial
        ev_deleted_error     = lv_deleted_error
        ev_protected_running = lv_protected_running
        ev_protected_unknown = lv_protected_unknown ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_deleted
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_deleted_snapshots
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_deleted_success
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_deleted_partial
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_deleted_error
      exp = 0 ).
    lv_deleted = lo_cut->purge_runs_before(
      EXPORTING
        iv_material          = 'MATERIAL-PURGE-STATUS'
        iv_plant             = '1000'
        iv_storage_location  = '0001'
        iv_unit              = 'EA'
        iv_before_date       = sy-datum
      IMPORTING
        ev_deleted_success   = lv_deleted_success
        ev_protected_running = lv_protected_running
        ev_protected_unknown = lv_protected_unknown ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_deleted
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_deleted_success
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_protected_running
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_protected_unknown
      exp = 1 ).
    SELECT COUNT( * )
      FROM zstockalloc_run
      INTO @lv_count
      WHERE run_id = 'RUN-PURGE-STATUS-SUCCESS'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_count
      exp = 0 ).
    SELECT COUNT( * )
      FROM zstockalloc_run
      INTO @lv_count
      WHERE run_id = 'RUN-PURGE-STATUS-RUNNING'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_count
      exp = 1 ).
    SELECT COUNT( * )
      FROM zstockalloc_run
      INTO @lv_count
      WHERE run_id = 'RUN-PURGE-STATUS-UNKNOWN'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_count
      exp = 1 ).
    DELETE FROM zstockalloc
      WHERE matnr = 'MATERIAL-PURGE-STATUS'.
    DELETE FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PURGE-STATUS'.
  ENDMETHOD.

  METHOD rejects_invalid_purge_status.
    DATA lo_cut TYPE REF TO zif_allocation_audit.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_cut TYPE zcl_allocation_audit_sap.
    TRY.
        lo_cut->get_purge_preview(
          iv_material         = 'MATERIAL-PURGE-STATUS-INVALID'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_status           = 'X'
          iv_before_date      = sy-datum ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Audit purge status filter is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD rejects_bad_mvt_filter.
    DATA lo_cut TYPE REF TO zif_allocation_audit.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_cut TYPE zcl_allocation_audit_sap.
    TRY.
        lo_cut->get_runs(
          iv_material         = 'MATERIAL-AUDIT-FILTER'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '2A1' ).
      CATCH zcx_stock_allocation INTO DATA(lo_history_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_history_error->message
          exp = 'Audit movement type is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.

    TRY.
        lo_cut->get_purge_preview(
          iv_material         = 'MATERIAL-AUDIT-FILTER'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '2A1'
          iv_before_date      = sy-datum ).
      CATCH zcx_stock_allocation INTO DATA(lo_preview_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_preview_error->message
          exp = 'Audit movement type is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.

    TRY.
        lo_cut->purge_runs_before(
          iv_material         = 'MATERIAL-AUDIT-FILTER'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '2A1'
          iv_before_date      = sy-datum ).
      CATCH zcx_stock_allocation INTO DATA(lo_purge_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_purge_error->message
          exp = 'Audit movement type is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD purges_by_run_id.
    DATA lo_cut TYPE REF TO zif_allocation_audit.
    DATA ls_run TYPE zstockalloc_run.
    DATA ls_allocation TYPE zstockalloc.
    DATA ls_preview TYPE zif_allocation_audit=>ty_purge_preview.
    DATA lv_deleted TYPE i.
    DATA lv_deleted_snapshots TYPE i.
    DATA lv_protected_running TYPE i.
    DATA lv_protected_unknown TYPE i.
    DATA lv_count TYPE i.

    ls_run-mandt = sy-mandt.
    ls_run-matnr = 'MATERIAL-PURGE-RUN-ID'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0001'.
    ls_run-unit = 'EA'.
    ls_run-start_date = '20260101'.
    ls_run-start_time = '010000'.
    ls_run-finish_date = '20260101'.
    ls_run-finish_time = '010001'.
    ls_run-status = 'S'.
    ls_run-available = 1.
    ls_run-demand_count = 1.
    ls_run-allocated = 1.
    ls_run-run_id = 'RUN-PURGE-RUN-ID-TARGET'.
    INSERT zstockalloc_run FROM @ls_run.
    ls_run-run_id = 'RUN-PURGE-RUN-ID-OTHER'.
    INSERT zstockalloc_run FROM @ls_run.
    ls_run-run_id = 'RUN-PURGE-RUN-ID-RUNNING'.
    CLEAR ls_run-finish_date.
    CLEAR ls_run-finish_time.
    ls_run-status = 'R'.
    INSERT zstockalloc_run FROM @ls_run.
    ls_run-run_id = 'RUN-PURGE-RUN-ID-UNKNOWN'.
    ls_run-status = 'X'.
    INSERT zstockalloc_run FROM @ls_run.

    ls_allocation-mandt = sy-mandt.
    ls_allocation-matnr = 'MATERIAL-PURGE-RUN-ID'.
    ls_allocation-werks = '1000'.
    ls_allocation-lgort = '0001'.
    ls_allocation-allocation_unit = 'EA'.
    ls_allocation-order_id = 'PURGE-RUN-ID-ORDER'.
    ls_allocation-requested = 1.
    ls_allocation-allocated = 1.
    ls_allocation-allocation_status = 'F'.
    ls_allocation-run_id = 'RUN-PURGE-RUN-ID-TARGET'.
    INSERT zstockalloc FROM @ls_allocation.

    CREATE OBJECT lo_cut TYPE zcl_allocation_audit_sap.
    ls_preview = lo_cut->get_purge_preview(
      iv_material         = 'MATERIAL-PURGE-RUN-ID'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_unit             = 'EA'
      iv_run_id           = 'RUN-PURGE-RUN-ID-TARGET'
      iv_before_date      = sy-datum ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_preview-audit_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_preview-snapshot_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_preview-success_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_initial( ls_preview-running_count ).
    cl_abap_unit_assert=>assert_initial( ls_preview-unknown_count ).
    ls_preview = lo_cut->get_purge_preview(
      iv_material         = 'MATERIAL-PURGE-RUN-ID'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_unit             = 'EA'
      iv_run_id           = 'RUN-PURGE-RUN-ID-RUNNING'
      iv_before_date      = sy-datum ).
    cl_abap_unit_assert=>assert_initial( ls_preview-audit_count ).
    cl_abap_unit_assert=>assert_initial( ls_preview-snapshot_count ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_preview-running_count
      exp = 1 ).

    lv_deleted = lo_cut->purge_runs_before(
      EXPORTING
        iv_material          = 'MATERIAL-PURGE-RUN-ID'
        iv_plant             = '1000'
        iv_storage_location  = '0001'
        iv_unit              = 'EA'
        iv_run_id            = 'RUN-PURGE-RUN-ID-TARGET'
        iv_before_date       = sy-datum
      IMPORTING
        ev_deleted_snapshots = lv_deleted_snapshots
        ev_protected_running = lv_protected_running
        ev_protected_unknown = lv_protected_unknown ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_deleted
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_deleted_snapshots
      exp = 1 ).
    cl_abap_unit_assert=>assert_initial( lv_protected_running ).
    cl_abap_unit_assert=>assert_initial( lv_protected_unknown ).
    SELECT COUNT( * )
      FROM zstockalloc_run
      INTO @lv_count
      WHERE run_id = 'RUN-PURGE-RUN-ID-TARGET'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_count
      exp = 0 ).
    SELECT COUNT( * )
      FROM zstockalloc_run
      INTO @lv_count
      WHERE run_id = 'RUN-PURGE-RUN-ID-OTHER'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_count
      exp = 1 ).
    SELECT COUNT( * )
      FROM zstockalloc_run
      INTO @lv_count
      WHERE run_id = 'RUN-PURGE-RUN-ID-RUNNING'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_count
      exp = 1 ).
    SELECT COUNT( * )
      FROM zstockalloc_run
      INTO @lv_count
      WHERE run_id = 'RUN-PURGE-RUN-ID-UNKNOWN'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_count
      exp = 1 ).
    DELETE FROM zstockalloc
      WHERE matnr = 'MATERIAL-PURGE-RUN-ID'.
    DELETE FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PURGE-RUN-ID'.
  ENDMETHOD.

  METHOD rejects_purge_commit_failure.
    DATA lo_cut TYPE REF TO zif_allocation_audit.
    DATA lo_transaction TYPE REF TO lcl_failing_audit_transaction.
    DATA ls_run TYPE zstockalloc_run.
    DATA lv_raised TYPE abap_bool.

    ls_run-mandt = sy-mandt.
    ls_run-run_id = 'RUN-PURGE-COMMIT-FAIL'.
    ls_run-matnr = 'MATERIAL-PURGE-COMMIT'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0001'.
    ls_run-unit = 'EA'.
    ls_run-start_date = '20260101'.
    ls_run-start_time = '010000'.
    ls_run-finish_date = '20260101'.
    ls_run-finish_time = '010001'.
    ls_run-status = 'S'.
    ls_run-available = 0.
    INSERT zstockalloc_run FROM @ls_run.
    CREATE OBJECT lo_transaction.
    CREATE OBJECT lo_cut TYPE zcl_allocation_audit_sap
      EXPORTING
        io_transaction = lo_transaction.
    TRY.
        lo_cut->purge_runs_before(
          iv_material         = 'MATERIAL-PURGE-COMMIT'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_unit             = 'EA'
          iv_before_date      = sy-datum ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Audit transaction test failure' ).
    ENDTRY.
    DELETE FROM zstockalloc_run
      WHERE run_id = 'RUN-PURGE-COMMIT-FAIL'.
    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD rejects_finish_commit_failure.
    DATA lo_cut TYPE REF TO zif_allocation_audit.
    DATA lo_transaction TYPE REF TO lcl_failing_audit_transaction.
    DATA lv_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_transaction.
    CREATE OBJECT lo_cut TYPE zcl_allocation_audit_sap
      EXPORTING
        io_transaction = lo_transaction.
    lv_run_id = lo_cut->start_run(
      iv_material         = 'MATERIAL-FINALIZE-COMMIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_unit             = 'EA'
      iv_available        = 1
      iv_demand_count     = 1 ).
    TRY.
        lo_cut->finish_run(
          iv_run_id    = lv_run_id
          iv_status    = 'S'
          iv_available = 1
          iv_allocated = 1
          iv_shortage  = 0
          iv_message   = '' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Audit transaction test failure' ).
    ENDTRY.
    DELETE FROM zstockalloc_run
      WHERE run_id = @lv_run_id.
    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD rejects_rejection_commit.
    DATA lo_cut TYPE REF TO zif_allocation_audit.
    DATA lo_transaction TYPE REF TO lcl_failing_audit_transaction.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_transaction.
    CREATE OBJECT lo_cut TYPE zcl_allocation_audit_sap
      EXPORTING
        io_transaction = lo_transaction.
    TRY.
        lo_cut->record_rejection(
          iv_material         = 'MATERIAL-REJECTION-COMMIT'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_unit             = 'EA'
          iv_available        = 0
          iv_message          = 'Rejection commit test' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Audit transaction test failure' ).
    ENDTRY.
    DELETE FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-REJECTION-COMMIT'.
    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD fallback_authority_messages.
    DATA lo_authority TYPE REF TO lcl_blank_allocation_authority.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_authority.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap
      EXPORTING
        io_read_authority = lo_authority.
    TRY.
        lo_audit->get_runs(
          iv_material         = 'MATERIAL-AUDIT-FALLBACK'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
      CATCH zcx_stock_allocation INTO DATA(lo_read_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_read_error->message
          exp = 'Audit read authorization failed' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.

    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap
      EXPORTING
        io_write_authority = lo_authority.
    TRY.
        lo_audit->start_run(
          iv_material         = 'MATERIAL-AUDIT-FALLBACK'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_available        = '1'
          iv_demand_count     = 1
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_write_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_write_error->message
          exp = 'Audit write authorization failed' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.

    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap
      EXPORTING
        io_retention_authority = lo_authority.
    TRY.
        lo_audit->purge_runs_before(
          iv_material         = 'MATERIAL-AUDIT-FALLBACK'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_before_date      = sy-datum ).
      CATCH zcx_stock_allocation INTO DATA(lo_retention_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_retention_error->message
          exp = 'Audit retention authorization failed' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD records_completed_run.
    DATA lo_cut TYPE REF TO zif_allocation_audit.
    DATA lv_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_allocated TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_unit TYPE zif_stock_allocation=>ty_unit.
    DATA lv_requested_on_from TYPE d.
    DATA lv_requested_on_to TYPE d.
    DATA lv_message TYPE zif_allocation_audit=>ty_message.
    DATA lt_runs TYPE zif_allocation_audit=>tt_runs.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA lv_deleted TYPE i.
    DATA lv_rejection_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_batch_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lt_batch_runs TYPE zif_allocation_audit=>tt_runs.
    DATA lt_unit_runs TYPE zif_allocation_audit=>tt_runs.
    DATA lt_date_runs TYPE zif_allocation_audit=>tt_runs.
    DATA lt_status_runs TYPE zif_allocation_audit=>tt_runs.
     DATA lt_ordered_runs TYPE zif_allocation_audit=>tt_runs.
     DATA lv_total_rows TYPE i.
    DATA lv_run_fragment TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_old_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_new_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_error_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_purge_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_raised TYPE abap_bool.
    DATA lv_future_date TYPE d.
    DATA lo_write_authority TYPE REF TO lcl_fail_alloc_write_auth.
    DATA lo_guarded_audit TYPE REF TO zif_allocation_audit.

    CREATE OBJECT lo_cut TYPE zcl_allocation_audit_sap.
    TRY.
        lo_cut->record_rejection(
          iv_material         = 'MATERIAL-AUDIT'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_unit             = 'EA'
          iv_available        = '0'
          iv_message          = '' ).
      CATCH zcx_stock_allocation INTO DATA(lo_rejection_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_rejection_error->message
          exp = 'Audit rejection message is required' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.

    lv_rejection_run_id = lo_cut->record_rejection(
      iv_material         = 'MATERIAL-AUDIT-REJECT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_unit             = 'ea'
      iv_requested_on_to  = '20260816'
      iv_available        = 0
      iv_message          = 'Rejected horizon test' ).
    SELECT SINGLE requested_on_to, unit
      FROM zstockalloc_run
      INTO ( @lv_requested_on_to, @lv_unit )
      WHERE run_id = @lv_rejection_run_id.
    cl_abap_unit_assert=>assert_equals(
      act = lv_requested_on_to
      exp = '20260816' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_unit
      exp = 'EA' ).
    DELETE FROM zstockalloc_run
      WHERE run_id = @lv_rejection_run_id.

    CREATE OBJECT lo_write_authority.
    CREATE OBJECT lo_guarded_audit TYPE zcl_allocation_audit_sap
      EXPORTING
        io_read_authority = lo_write_authority.
    TRY.
        lo_guarded_audit->get_runs(
          iv_material         = 'MATERIAL-AUDIT'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
      CATCH zcx_stock_allocation INTO DATA(lo_read_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_read_error->message
          exp = 'Audit read authorization test failure' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.

    CREATE OBJECT lo_guarded_audit TYPE zcl_allocation_audit_sap
      EXPORTING
        io_write_authority = lo_write_authority.
    TRY.
        lo_guarded_audit->start_run(
          iv_material         = 'MATERIAL-AUDIT'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_available        = '1'
          iv_demand_count     = 1
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_write_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_write_error->message
          exp = 'Audit write authorization test failure' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.

    CREATE OBJECT lo_guarded_audit TYPE zcl_allocation_audit_sap
      EXPORTING
        io_retention_authority = lo_write_authority.
    TRY.
        lo_guarded_audit->purge_runs_before(
          iv_material         = 'MATERIAL-AUDIT'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_before_date      = sy-datum ).
      CATCH zcx_stock_allocation INTO DATA(lo_retention_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_retention_error->message
          exp = 'Retention authorization test failure' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.

    TRY.
        lt_runs = lo_cut->get_runs(
          iv_material         = ''
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
      CATCH zcx_stock_allocation INTO DATA(lo_read_scope_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_read_scope_error->message
          exp = 'Audit read scope is incomplete' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.

    TRY.
        lo_cut->start_run(
          iv_material         = ''
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_available        = '10'
          iv_demand_count     = 1
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_scope_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_scope_error->message
          exp = 'Audit run scope is incomplete' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.

    TRY.
        lo_cut->start_run(
          iv_material         = 'MATERIAL-AUDIT'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_available        = '-1'
          iv_demand_count     = 1
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_input_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_input_error->message
          exp = 'Audit run inputs are invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.

    TRY.
        lo_cut->start_run(
          iv_material          = 'MATERIAL-AUDIT'
          iv_plant             = '1000'
          iv_storage_location  = '0001'
          iv_unit              = 'EA'
          iv_requested_on_from = '20260820'
          iv_requested_on_to   = '20260815'
          iv_available         = '1'
          iv_demand_count      = 1 ).
      CATCH zcx_stock_allocation INTO DATA(lo_date_range_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_date_range_error->message
          exp = 'Audit requested date range is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.

    lv_run_id = lo_cut->start_run(
      iv_material          = 'MATERIAL-AUDIT'
      iv_plant             = '1000'
      iv_storage_location  = '0001'
      iv_available         = '10'
      iv_demand_count      = 2
      iv_unit              = 'EA'
      iv_requested_on_from = '20260815'
      iv_requested_on_to   = '20260816'
      iv_strategy          = 'F' ).
    lo_cut->finish_run(
      iv_run_id     = lv_run_id
      iv_status     = 'S'
      iv_available  = '10'
      iv_allocated  = '6'
      iv_shortage   = '0'
      iv_full_count = 2
      iv_message    = '' ).
    lv_purge_run_id = lv_run_id.

    TRY.
        lo_cut->finish_run(
          iv_run_id    = lv_run_id
          iv_status    = 'X'
          iv_available = '10'
          iv_allocated = '6'
          iv_shortage  = '1'
          iv_message   = '' ).
      CATCH zcx_stock_allocation INTO DATA(lo_status_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_status_error->message
          exp = 'Audit final status is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.

    TRY.
        lo_cut->finish_run(
          iv_run_id    = lv_run_id
          iv_status    = 'S'
          iv_available = '10'
          iv_allocated = '-1'
          iv_shortage  = '1'
          iv_message   = '' ).
      CATCH zcx_stock_allocation INTO DATA(lo_metric_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_metric_error->message
          exp = 'Audit final metrics are invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.

    lv_error_run_id = lo_cut->start_run(
      iv_material         = 'MATERIAL-AUDIT-ERROR'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_available        = '1'
      iv_demand_count     = 1
      iv_unit             = 'EA' ).
    TRY.
        lo_cut->finish_run(
          iv_run_id    = lv_error_run_id
          iv_status    = 'E'
          iv_available = '1'
          iv_allocated = '0'
          iv_shortage  = '1'
          iv_message   = '' ).
      CATCH zcx_stock_allocation INTO DATA(lo_message_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_message_error->message
          exp = 'Audit final message is required' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.

    TRY.
        lo_cut->finish_run(
          iv_run_id    = lv_error_run_id
          iv_status    = 'S'
          iv_available = '1'
          iv_allocated = '0'
          iv_shortage  = '1'
          iv_message   = '' ).
      CATCH zcx_stock_allocation INTO DATA(lo_shape_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_shape_error->message
          exp = 'Audit final metrics are invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.

    TRY.
        lo_cut->finish_run(
          iv_run_id    = lv_error_run_id
          iv_status    = 'P'
          iv_available = '1'
          iv_allocated = '1'
          iv_shortage  = '0'
          iv_message   = 'Invalid partial metric test' ).
      CATCH zcx_stock_allocation INTO DATA(lo_partial_shape_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_partial_shape_error->message
          exp = 'Audit final metrics are invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.

    TRY.
        lo_cut->finish_run(
          iv_run_id    = lv_error_run_id
          iv_status    = 'E'
          iv_available = '1'
          iv_allocated = '2'
          iv_shortage  = '0'
          iv_message   = 'Invalid metric test' ).
      CATCH zcx_stock_allocation INTO DATA(lo_available_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_available_error->message
          exp = 'Audit final metrics are invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.

    TRY.
        lo_cut->finish_run(
          iv_run_id    = lv_error_run_id
          iv_status    = 'E'
          iv_available = '2'
          iv_allocated = '0'
          iv_shortage  = '0'
          iv_message   = 'Available mismatch test' ).
      CATCH zcx_stock_allocation INTO DATA(lo_recorded_available_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_recorded_available_error->message
          exp = 'Audit final metrics are invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.

    lo_cut->finish_run(
      iv_run_id    = lv_error_run_id
      iv_status    = 'E'
      iv_available = '1'
      iv_allocated = '0'
      iv_shortage  = '1'
      iv_message   = 'Error test cleanup' ).

    SELECT SINGLE status, allocated, unit, requested_on_from,
                  requested_on_to, message
      FROM zstockalloc_run
      INTO (@lv_status, @lv_allocated, @lv_unit, @lv_requested_on_from,
            @lv_requested_on_to, @lv_message)
      WHERE run_id = @lv_run_id.
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'S' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_allocated
      exp = '6' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_unit
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_requested_on_from
      exp = '20260815' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_requested_on_to
      exp = '20260816' ).
    cl_abap_unit_assert=>assert_initial( lv_message ).

    TRY.
        lo_cut->finish_run(
          iv_run_id    = lv_run_id
          iv_status    = 'P'
          iv_available = '10'
          iv_allocated = '5'
          iv_shortage  = '5'
          iv_message   = 'Duplicate finalization' ).
      CATCH zcx_stock_allocation INTO DATA(lo_finalized_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_finalized_error->message
          exp = 'Audit run is already finalized' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.

    lt_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_runs )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_runs[ 1 ]-status
      exp = 'S' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_runs[ 1 ]-full_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_runs[ 1 ]-partial_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_runs[ 1 ]-unallocated_count
      exp = 0 ).
    lt_status_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_status           = 'S' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_status_runs )
      exp = 1 ).
    lt_status_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_strategy         = 'F' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_status_runs )
      exp = 1 ).
    lt_status_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_strategy         = 'P' ).
    cl_abap_unit_assert=>assert_initial( lt_status_runs ).
    lt_status_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_strategy         = 'S' ).
    cl_abap_unit_assert=>assert_initial( lt_status_runs ).
    lt_status_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_legacy_strategy  = abap_true ).
    cl_abap_unit_assert=>assert_initial( lt_status_runs ).
      TRY.
        lo_cut->get_runs(
          iv_material         = 'MATERIAL-AUDIT'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_strategy         = 'F'
          iv_legacy_strategy  = abap_true ).
      CATCH zcx_stock_allocation INTO DATA(lo_strategy_conflict_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_strategy_conflict_error->message
          exp = 'Audit strategy filters conflict' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.
    TRY.
        lo_cut->get_runs(
          iv_material         = 'MATERIAL-AUDIT'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_strategy         = 'X' ).
      CATCH zcx_stock_allocation INTO DATA(lo_strategy_filter_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_strategy_filter_error->message
          exp = 'Audit strategy is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.
    lt_date_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_requested_on_to  = '20260816' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_date_runs )
      exp = 1 ).
    lt_date_runs = lo_cut->get_runs(
      iv_material          = 'MATERIAL-AUDIT'
      iv_plant             = '1000'
      iv_storage_location  = '0001'
      iv_requested_on_from = '20260815' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_date_runs )
      exp = 1 ).
    TRY.
        lo_cut->get_runs(
          iv_material          = 'MATERIAL-AUDIT'
          iv_plant             = '1000'
          iv_storage_location  = '0001'
          iv_requested_on_from = '20260817'
          iv_requested_on_to   = '20260816' ).
      CATCH zcx_stock_allocation INTO DATA(lo_requested_date_filter_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_requested_date_filter_error->message
          exp = 'Audit requested date range is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.
    lt_date_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_unit             = 'EA'
      iv_finish_date_from = sy-datum
      iv_finish_date_to   = sy-datum ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_date_runs )
      exp = 1 ).
    TRY.
        lo_cut->get_runs(
          iv_material         = 'MATERIAL-AUDIT'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_finish_date_from = '20260817'
          iv_finish_date_to   = '20260816' ).
      CATCH zcx_stock_allocation INTO DATA(lo_finish_date_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_finish_date_error->message
          exp = 'Audit finish date range is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.
    lt_status_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_coverage_from    = '100'
      iv_coverage_to      = '100' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_status_runs )
      exp = 1 ).
    lt_date_runs = lo_cut->get_runs(
      iv_material          = 'MATERIAL-AUDIT'
      iv_plant             = '1000'
      iv_storage_location  = '0001'
      iv_requested_on_from = '20260815'
      iv_requested_on_to   = '20260816' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_date_runs )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_date_runs[ 1 ]-run_id
      exp = lv_run_id ).
    lt_date_runs = lo_cut->get_runs(
      iv_material          = 'MATERIAL-AUDIT'
      iv_plant             = '1000'
      iv_storage_location  = '0001'
      iv_requested_on_from = '20260816'
      iv_requested_on_to   = '20260816' ).
    cl_abap_unit_assert=>assert_initial( lt_date_runs ).
    TRY.
        lo_cut->get_runs(
          iv_material          = 'MATERIAL-AUDIT'
          iv_plant             = '1000'
          iv_storage_location  = '0001'
          iv_requested_on_from = '20260817'
          iv_requested_on_to   = '20260816' ).
      CATCH zcx_stock_allocation INTO DATA(lo_requested_date_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_requested_date_error->message
          exp = 'Audit requested date range is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.
    TRY.
        lo_cut->get_runs(
          iv_material         = 'MATERIAL-AUDIT'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_coverage_from    = '101'
          iv_coverage_to      = '100' ).
      CATCH zcx_stock_allocation INTO DATA(lo_coverage_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_coverage_error->message
          exp = 'Audit coverage range is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.
    lt_status_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_available_from   = '10'
      iv_available_to     = '10' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_status_runs )
      exp = 1 ).
    TRY.
        lo_cut->get_runs(
          iv_material         = 'MATERIAL-AUDIT'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_available_from   = '11'
          iv_available_to     = '10' ).
      CATCH zcx_stock_allocation INTO DATA(lo_available_range_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_available_range_error->message
          exp = 'Audit available range is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.
    lt_status_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_demand_from      = 2
      iv_demand_to        = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_status_runs )
      exp = 1 ).
    TRY.
        lo_cut->get_runs(
          iv_material         = 'MATERIAL-AUDIT'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_demand_from      = 3
          iv_demand_to        = 2 ).
      CATCH zcx_stock_allocation INTO DATA(lo_demand_count_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_demand_count_error->message
          exp = 'Audit demand count range is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.
    lt_status_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_requested_from   = '6'
      iv_requested_to     = '6' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_status_runs )
      exp = 1 ).
    TRY.
        lo_cut->get_runs(
          iv_material         = 'MATERIAL-AUDIT'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_requested_from   = '7'
          iv_requested_to     = '6' ).
      CATCH zcx_stock_allocation INTO DATA(lo_requested_quantity_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_requested_quantity_error->message
          exp = 'Audit requested quantity range is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.
    lt_status_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_allocated_from   = '6'
      iv_allocated_to     = '6' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_status_runs )
      exp = 1 ).
    TRY.
        lo_cut->get_runs(
          iv_material         = 'MATERIAL-AUDIT'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_allocated_from   = '7'
          iv_allocated_to     = '6' ).
      CATCH zcx_stock_allocation INTO DATA(lo_allocated_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_allocated_error->message
          exp = 'Audit allocated range is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.
    lt_status_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_run_id           = lv_run_id ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_status_runs )
      exp = 1 ).
    TRY.
        lo_cut->get_runs(
          iv_material         = 'MATERIAL-AUDIT'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_status           = 'X' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Audit status is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.

    ls_summary = lo_cut->get_summary(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_unit             = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-total_runs
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-success_runs
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-allocated
      exp = '6' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-requested
      exp = '6' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-coverage
      exp = '100.00' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-fifo_allocated
      exp = '6' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-fifo_shortage
      exp = '0' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-fifo_requested
      exp = '6' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-fifo_coverage
      exp = '100.00' ).
    lt_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_unit             = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_runs[ 1 ]-requested
      exp = '6' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_runs[ 1 ]-strategy
      exp = 'F' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-full_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-last_requested_on_to
      exp = '20260816' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-last_requested_on_from
      exp = '20260815' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-unit
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-last_status
      exp = 'S' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-last_strategy
      exp = 'F' ).
    ls_summary = lo_cut->get_summary(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_strategy         = 'F' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-total_runs
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-priority_runs
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-fifo_runs
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-full_only_runs
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-smallest_runs
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-legacy_strategy_runs
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-last_strategy
      exp = 'F' ).
    cl_abap_unit_assert=>assert_not_initial( ls_summary-last_finish_date ).
    cl_abap_unit_assert=>assert_not_initial( ls_summary-last_finish_time ).
    cl_abap_unit_assert=>assert_initial( ls_summary-last_message ).

    lv_batch_run_id = lo_cut->start_run(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_available        = '1'
      iv_demand_count     = 1
      iv_unit             = 'BOX' ).
    lo_cut->finish_run(
      iv_run_id    = lv_batch_run_id
      iv_status    = 'S'
      iv_available = '1'
      iv_allocated = '1'
      iv_shortage  = '0'
      iv_message   = '' ).
    lt_unit_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_unit             = 'BOX' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_unit_runs )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_unit_runs[ 1 ]-unit
      exp = 'BOX' ).

    CLEAR ls_summary.
    ls_summary = lo_cut->get_summary(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-total_runs
      exp = 2 ).
    cl_abap_unit_assert=>assert_true( ls_summary-mixed_units ).
    cl_abap_unit_assert=>assert_initial( ls_summary-unit ).
    cl_abap_unit_assert=>assert_initial( ls_summary-allocated ).
    cl_abap_unit_assert=>assert_initial( ls_summary-shortage ).
    cl_abap_unit_assert=>assert_initial( ls_summary-requested ).
    cl_abap_unit_assert=>assert_initial( ls_summary-coverage ).
    cl_abap_unit_assert=>assert_initial( ls_summary-priority_allocated ).
    cl_abap_unit_assert=>assert_initial( ls_summary-priority_shortage ).
    cl_abap_unit_assert=>assert_initial( ls_summary-priority_requested ).
    cl_abap_unit_assert=>assert_initial( ls_summary-fifo_allocated ).
    cl_abap_unit_assert=>assert_initial( ls_summary-fifo_shortage ).
    cl_abap_unit_assert=>assert_initial( ls_summary-fifo_requested ).
    cl_abap_unit_assert=>assert_initial( ls_summary-full_only_allocated ).
    cl_abap_unit_assert=>assert_initial( ls_summary-full_only_shortage ).
    cl_abap_unit_assert=>assert_initial( ls_summary-full_only_requested ).
    cl_abap_unit_assert=>assert_initial( ls_summary-smallest_allocated ).
    cl_abap_unit_assert=>assert_initial( ls_summary-smallest_shortage ).
    cl_abap_unit_assert=>assert_initial( ls_summary-smallest_requested ).
    cl_abap_unit_assert=>assert_initial( ls_summary-largest_allocated ).
    cl_abap_unit_assert=>assert_initial( ls_summary-largest_shortage ).
    cl_abap_unit_assert=>assert_initial( ls_summary-largest_requested ).
    cl_abap_unit_assert=>assert_initial( ls_summary-priority_coverage ).
    cl_abap_unit_assert=>assert_initial( ls_summary-fifo_coverage ).
    cl_abap_unit_assert=>assert_initial( ls_summary-full_only_coverage ).
    cl_abap_unit_assert=>assert_initial( ls_summary-smallest_coverage ).
    cl_abap_unit_assert=>assert_initial( ls_summary-largest_coverage ).
    cl_abap_unit_assert=>assert_initial( ls_summary-legacy_allocated ).
    cl_abap_unit_assert=>assert_initial( ls_summary-legacy_shortage ).
    cl_abap_unit_assert=>assert_initial( ls_summary-legacy_requested ).
    cl_abap_unit_assert=>assert_initial( ls_summary-legacy_coverage ).

    lt_date_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_start_date_from  = '99991231' ).
    cl_abap_unit_assert=>assert_initial( lt_date_runs ).
    lt_date_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_start_date_to    = '00010101' ).
    cl_abap_unit_assert=>assert_initial( lt_date_runs ).
    TRY.
        lo_cut->get_runs(
          iv_material         = 'MATERIAL-AUDIT'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_start_date_from  = '99991231'
          iv_start_date_to    = '00010101' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    lv_batch_run_id = lo_cut->start_run(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_batch            = 'BATCH-001'
      iv_movement_type    = '201'
      iv_min_shelf_life   = 5
      iv_available        = '4'
      iv_demand_count     = 1
      iv_unit             = 'EA' ).
    lo_cut->finish_run(
      iv_run_id    = lv_batch_run_id
      iv_status    = 'S'
      iv_available = '4'
      iv_allocated = '4'
      iv_shortage  = '0'
      iv_message   = '' ).
    lt_batch_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_batch            = 'BATCH-001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_batch_runs )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_batch_runs[ 1 ]-batch
      exp = 'BATCH-001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_batch_runs[ 1 ]-movement_type
      exp = '201' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_batch_runs[ 1 ]-min_shelf_life
      exp = 5 ).

    lv_run_id = lo_cut->start_run(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_available        = '10'
      iv_demand_count     = 0
      iv_unit             = 'EA' ).
    UPDATE zstockalloc_run
      SET start_date = '20260101'
      WHERE run_id = @lv_purge_run_id.
    lv_deleted = lo_cut->purge_runs_before(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_unit             = 'EA'
      iv_before_date      = sy-datum ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_deleted
      exp = 1 ).
    lt_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_unit             = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_runs )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_runs[ 1 ]-status
      exp = 'R' ).

    lv_future_date = sy-datum + 1.
    TRY.
        lo_cut->purge_runs_before(
          iv_material         = 'MATERIAL-AUDIT'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_unit             = 'EA'
          iv_before_date      = lv_future_date ).
      CATCH zcx_stock_allocation INTO DATA(lo_future_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_future_error->message
          exp = 'Audit purge date cannot be in the future' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.

    TRY.
        lo_cut->purge_runs_before(
          iv_material         = ''
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_unit             = 'EA'
          iv_before_date      = sy-datum ).
      CATCH zcx_stock_allocation INTO DATA(lo_purge_scope_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_purge_scope_error->message
          exp = 'Audit purge scope is incomplete' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.
    lt_unit_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_unit             = 'BOX' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_unit_runs )
      exp = 1 ).

    lv_old_run_id = lo_cut->start_run(
      iv_material         = 'MATERIAL-AUDIT-ORDER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_available        = '1'
      iv_demand_count     = 1
      iv_unit             = 'EA' ).
    lo_cut->finish_run(
      iv_run_id    = lv_old_run_id
      iv_status    = 'S'
      iv_available = '1'
      iv_allocated = '1'
      iv_shortage  = '0'
      iv_message   = '' ).
    lv_new_run_id = lo_cut->start_run(
      iv_material         = 'MATERIAL-AUDIT-ORDER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_available        = '2'
      iv_demand_count     = 1
      iv_unit             = 'EA' ).
    lo_cut->finish_run(
      iv_run_id    = lv_new_run_id
      iv_status    = 'P'
      iv_available = '2'
      iv_allocated = '1'
      iv_shortage  = '1'
      iv_message   = 'Partial run' ).
    UPDATE zstockalloc_run
      SET start_date = '20260701', start_time = '010000'
      WHERE run_id = @lv_old_run_id.
    UPDATE zstockalloc_run
      SET start_date = '20260702', start_time = '010000'
      WHERE run_id = @lv_new_run_id.
    lt_ordered_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT-ORDER'
      iv_plant            = '1000'
      iv_storage_location = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_ordered_runs )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_ordered_runs[ 1 ]-run_id
      exp = lv_new_run_id ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_ordered_runs[ 2 ]-run_id
      exp = lv_old_run_id ).
    lt_ordered_runs = lo_cut->get_runs(
      EXPORTING
        iv_material         = 'MATERIAL-AUDIT-ORDER'
        iv_plant            = '1000'
        iv_storage_location = '0001'
        iv_offset           = 1
      IMPORTING
        ev_total_rows       = lv_total_rows ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_total_rows
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_ordered_runs )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_ordered_runs[ 1 ]-run_id
      exp = lv_old_run_id ).
    lt_ordered_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT-ORDER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_sort_by_status   = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_ordered_runs[ 1 ]-run_id
      exp = lv_new_run_id ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_ordered_runs[ 2 ]-run_id
      exp = lv_old_run_id ).
    UPDATE zstockalloc_run
      SET start_date = '20260702', start_time = '010000'
      WHERE run_id = @lv_old_run_id.
    UPDATE zstockalloc_run
      SET start_date = '20260701', start_time = '010000'
      WHERE run_id = @lv_new_run_id.
    lt_ordered_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT-ORDER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_sort_by_shortage = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_ordered_runs[ 1 ]-run_id
      exp = lv_new_run_id ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_ordered_runs[ 2 ]-run_id
      exp = lv_old_run_id ).
    UPDATE zstockalloc_run
      SET start_date = '20260701', start_time = '010000',
          finish_date = '20260701', finish_time = '010001'
      WHERE run_id = @lv_old_run_id.
    UPDATE zstockalloc_run
      SET start_date = '20260701', start_time = '010000',
          finish_date = '20260701', finish_time = '010010'
      WHERE run_id = @lv_new_run_id.
    lt_ordered_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT-ORDER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_sort_by_duration = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_ordered_runs[ 1 ]-run_id
      exp = lv_new_run_id ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_ordered_runs[ 2 ]-run_id
      exp = lv_old_run_id ).
    lv_run_fragment = lv_new_run_id(8).
    lt_ordered_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT-ORDER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_run_id_contains  = lv_run_fragment ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_ordered_runs )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_ordered_runs[ 1 ]-run_id
      exp = lv_new_run_id ).
    TRANSLATE lv_run_fragment TO LOWER CASE.
    lt_ordered_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT-ORDER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_run_id_contains  = lv_run_fragment ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_ordered_runs )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_ordered_runs[ 1 ]-run_id
      exp = lv_new_run_id ).
    lt_ordered_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT-ORDER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_message_contains = 'partial' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_ordered_runs )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_ordered_runs[ 1 ]-run_id
      exp = lv_new_run_id ).
    lt_ordered_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT-ORDER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_message_contains = 'lock' ).
    cl_abap_unit_assert=>assert_initial( lt_ordered_runs ).
    lt_ordered_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT-ORDER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_message_only     = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_ordered_runs )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_ordered_runs[ 1 ]-run_id
      exp = lv_new_run_id ).
    lt_ordered_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT-ORDER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_sort_by_coverage = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_ordered_runs[ 1 ]-run_id
      exp = lv_new_run_id ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_ordered_runs[ 2 ]-run_id
      exp = lv_old_run_id ).
    lt_ordered_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT-ORDER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_sort_by_coverage = abap_true
      iv_max_rows         = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_ordered_runs )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_ordered_runs[ 1 ]-run_id
      exp = lv_new_run_id ).
    TRY.
        lo_cut->get_runs(
          iv_material         = 'MATERIAL-AUDIT-ORDER'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_max_rows         = -1 ).
      CATCH zcx_stock_allocation INTO DATA(lo_history_limit_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_history_limit_error->message
          exp = 'Audit history row limit is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.
    TRY.
        lo_cut->get_runs(
          iv_material         = 'MATERIAL-AUDIT-ORDER'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_offset           = -1 ).
      CATCH zcx_stock_allocation INTO DATA(lo_history_offset_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_history_offset_error->message
          exp = 'Audit history row offset is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.
ENDCLASS.
