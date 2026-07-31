CLASS lcl_failing_allocation_write_authority DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_read_authority.
    INTERFACES zif_allocation_write_authority.
    INTERFACES zif_allocation_retention_authority.
ENDCLASS.

CLASS lcl_failing_allocation_write_authority IMPLEMENTATION.
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

  METHOD zif_allocation_retention_authority~check.
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
    INTERFACES zif_allocation_retention_authority.
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

  METHOD zif_allocation_retention_authority~check.
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
    METHODS rejects_corrupt_read FOR TESTING.
    METHODS rejects_inverted_timestamp FOR TESTING.
    METHODS purges_linked_snapshots FOR TESTING.
    METHODS rejects_purge_commit_failure FOR TESTING.
    METHODS rejects_finish_commit_failure FOR TESTING.
    METHODS rejects_rejection_commit FOR TESTING.
    METHODS fallback_authority_messages FOR TESTING.
ENDCLASS.

CLASS ltcl_allocation_audit_sap IMPLEMENTATION.
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
      WHERE mandt = @sy-mandt
        AND run_id = 'RUN-AUDIT-CORRUPT'.
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
      WHERE mandt = @sy-mandt
        AND run_id = 'RUN-AUDIT-TIME'.
    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD purges_linked_snapshots.
    DATA lo_cut TYPE REF TO zif_allocation_audit.
    DATA ls_run TYPE zstockalloc_run.
    DATA ls_allocation TYPE zstockalloc.
    DATA lv_deleted TYPE i.
    DATA lv_snapshot_count TYPE i.

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

    CREATE OBJECT lo_cut TYPE zcl_allocation_audit_sap.
    lv_deleted = lo_cut->purge_runs_before(
      iv_material         = 'MATERIAL-PURGE-SNAPSHOT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_unit             = 'EA'
      iv_before_date      = sy-datum ).

    SELECT COUNT( * )
      FROM zstockalloc
      INTO @lv_snapshot_count
      WHERE mandt = @sy-mandt
        AND matnr = 'MATERIAL-PURGE-SNAPSHOT'
        AND werks = '1000'
        AND lgort = '0001'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_deleted
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_snapshot_count
      exp = 0 ).
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
      WHERE mandt = @sy-mandt
        AND run_id = 'RUN-PURGE-COMMIT-FAIL'.
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
      WHERE mandt = @sy-mandt
        AND run_id = @lv_run_id.
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
      WHERE mandt = @sy-mandt
        AND matnr = 'MATERIAL-REJECTION-COMMIT'.
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
    DATA lv_message TYPE zif_allocation_audit=>ty_message.
    DATA lt_runs TYPE zif_allocation_audit=>tt_runs.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA lv_deleted TYPE i.
    DATA lv_batch_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lt_batch_runs TYPE zif_allocation_audit=>tt_runs.
    DATA lt_unit_runs TYPE zif_allocation_audit=>tt_runs.
    DATA lt_date_runs TYPE zif_allocation_audit=>tt_runs.
    DATA lt_status_runs TYPE zif_allocation_audit=>tt_runs.
    DATA lt_ordered_runs TYPE zif_allocation_audit=>tt_runs.
    DATA lv_old_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_new_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_error_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_purge_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_raised TYPE abap_bool.
    DATA lv_future_date TYPE d.
    DATA lo_write_authority TYPE REF TO lcl_failing_allocation_write_authority.
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

    lv_run_id = lo_cut->start_run(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_available        = '10'
      iv_demand_count     = 2
      iv_unit             = 'EA' ).
    lo_cut->finish_run(
      iv_run_id    = lv_run_id
      iv_status    = 'S'
      iv_available = '10'
      iv_allocated = '6'
      iv_shortage  = '0'
      iv_message   = '' ).
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

    SELECT SINGLE status, allocated, unit, message
      FROM zstockalloc_run
      INTO (@lv_status, @lv_allocated, @lv_unit, @lv_message)
      WHERE mandt = @sy-mandt
        AND run_id = @lv_run_id.
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'S' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_allocated
      exp = '6' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_unit
      exp = 'EA' ).
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
    lt_status_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_status           = 'S' ).
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
      act = ls_summary-unit
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-last_status
      exp = 'S' ).
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

    lv_run_id = lo_cut->start_run(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_available        = '10'
      iv_demand_count     = 0
      iv_unit             = 'EA' ).
    UPDATE zstockalloc_run
      SET start_date = '20260101'
      WHERE mandt = @sy-mandt
        AND run_id = @lv_purge_run_id.
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
      WHERE mandt = @sy-mandt
        AND run_id = @lv_old_run_id.
    UPDATE zstockalloc_run
      SET start_date = '20260702', start_time = '010000'
      WHERE mandt = @sy-mandt
        AND run_id = @lv_new_run_id.
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
  ENDMETHOD.
ENDCLASS.
