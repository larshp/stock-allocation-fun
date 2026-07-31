CLASS ltcl_allocation_audit_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS records_completed_run FOR TESTING.
ENDCLASS.

CLASS ltcl_allocation_audit_sap IMPLEMENTATION.
  METHOD records_completed_run.
    DATA lo_cut TYPE REF TO zif_allocation_audit.
    DATA lv_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_allocated TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_message TYPE zif_allocation_audit=>ty_message.
    DATA lt_runs TYPE zif_allocation_audit=>tt_runs.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA lv_deleted TYPE i.

    CREATE OBJECT lo_cut TYPE zcl_allocation_audit_sap.
    lv_run_id = lo_cut->start_run(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_available        = '10'
      iv_demand_count     = 2 ).
    lo_cut->finish_run(
      iv_run_id    = lv_run_id
      iv_status    = 'S'
      iv_available = '10'
      iv_allocated = '6'
      iv_shortage  = '1'
      iv_message   = '' ).

    SELECT SINGLE status, allocated, message
      FROM zstockalloc_run
      INTO (@lv_status, @lv_allocated, @lv_message)
      WHERE mandt = @sy-mandt
        AND run_id = @lv_run_id.
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'S' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_allocated
      exp = '6' ).
    cl_abap_unit_assert=>assert_initial( lv_message ).

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

    ls_summary = lo_cut->get_summary(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-total_runs
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-success_runs
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-allocated
      exp = '6' ).

    lv_run_id = lo_cut->start_run(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_available        = '10'
      iv_demand_count     = 0 ).
    lv_deleted = lo_cut->purge_runs_before(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_before_date      = '20260801' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_deleted
      exp = 1 ).
    lt_runs = lo_cut->get_runs(
      iv_material         = 'MATERIAL-AUDIT'
      iv_plant            = '1000'
      iv_storage_location = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_runs )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_runs[ 1 ]-status
      exp = 'R' ).
  ENDMETHOD.
ENDCLASS.
