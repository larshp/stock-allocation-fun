CLASS lcl_fail_result_write_auth DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_read_authority.
    INTERFACES zif_allocation_write_authority.
ENDCLASS.

CLASS lcl_fail_result_write_auth IMPLEMENTATION.
  METHOD zif_allocation_read_authority~check_audit.
  ENDMETHOD.

  METHOD zif_allocation_read_authority~check_results.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = 'Result read authorization test failure'.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.

  METHOD zif_allocation_write_authority~check_audit_write.
  ENDMETHOD.

  METHOD zif_allocation_write_authority~check_result_write.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = 'Result write authorization test failure'.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.

  METHOD zif_allocation_write_authority~check_result_delete.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_blank_result_authority DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_read_authority.
    INTERFACES zif_allocation_write_authority.
ENDCLASS.

CLASS lcl_blank_result_authority IMPLEMENTATION.
  METHOD zif_allocation_read_authority~check_audit.
  ENDMETHOD.

  METHOD zif_allocation_read_authority~check_results.
    RAISE EXCEPTION TYPE zcx_stock_allocation.
  ENDMETHOD.

  METHOD zif_allocation_write_authority~check_audit_write.
  ENDMETHOD.

  METHOD zif_allocation_write_authority~check_result_write.
    RAISE EXCEPTION TYPE zcx_stock_allocation.
  ENDMETHOD.

  METHOD zif_allocation_write_authority~check_result_delete.
    RAISE EXCEPTION TYPE zcx_stock_allocation.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_allocation_sink_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS persists_allocation FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_invalid_movement_type FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS fallback_authority_messages FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_missing_reservation FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_corrupt_read FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_mixed_run_read FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_orphan_read FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_invalid_run_status FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_invalid_run_strategy FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_alloc_unit_mismatch FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_alloc_run_mismatch FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_strategy_mismatch FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_date_mismatch FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_unknown_run FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_inconsistent_run FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_finalized_run FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS filters_by_run_and_status FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS accepts_lowercase_units FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS accepts_lowercase_status FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_bad_mvt_filter FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS filters_by_shortage_percentage FOR TESTING
      RAISING zcx_stock_allocation.
ENDCLASS.

CLASS ltcl_allocation_sink_sap IMPLEMENTATION.
  METHOD filters_by_shortage_percentage.
    DATA lo_cut TYPE REF TO zif_allocation_sink.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_cut TYPE zcl_allocation_sink_sap.
    lt_demands = lo_cut->get_allocations(
      iv_material          = 'MATERIAL-FILTER'
      iv_plant             = '1000'
      iv_storage_location  = '0001'
      iv_shortage_pct_from = 100
      iv_shortage_pct_to   = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'FILTER-UNALLOCATED' ).

    lt_demands = lo_cut->get_allocations(
      iv_material          = 'MATERIAL-FILTER'
      iv_plant             = '1000'
      iv_storage_location  = '0001'
      iv_coverage_from     = 0
      iv_coverage_to       = 100
      iv_shortage_pct_from = 100
      iv_shortage_pct_to   = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'FILTER-UNALLOCATED' ).

    lt_demands = lo_cut->get_allocations(
      iv_material          = 'MATERIAL-FILTER'
      iv_plant             = '1000'
      iv_storage_location  = '0001'
      iv_shortage_pct_from = 0
      iv_shortage_pct_to   = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'FILTER-FULL' ).

    lt_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_sort_by_shrt_pct = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'FILTER-UNALLOCATED' ).

    lt_demands = lo_cut->get_allocations(
      iv_material                 = 'MATERIAL-FILTER'
      iv_plant                    = '1000'
      iv_storage_location         = '0001'
      iv_allocation_movement_type = '202'
      iv_min_shelf_life           = 7 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'FILTER-FULL' ).

    CLEAR lv_raised.
    TRY.
        lo_cut->get_allocations(
          iv_material          = 'MATERIAL-FILTER'
          iv_plant             = '1000'
          iv_storage_location  = '0001'
          iv_shortage_pct_from = 101 ).
      CATCH zcx_stock_allocation INTO DATA(lo_shortage_pct_bound_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_shortage_pct_bound_error->message
          exp = 'Allocation result shortage percentage range is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    TRY.
        lo_cut->get_allocations(
          iv_material          = 'MATERIAL-FILTER'
          iv_plant             = '1000'
          iv_storage_location  = '0001'
          iv_shortage_pct_from = 80
          iv_shortage_pct_to   = 20 ).
      CATCH zcx_stock_allocation INTO DATA(lo_shortage_pct_order_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_shortage_pct_order_error->message
          exp = 'Allocation result shortage percentage range is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD filters_by_run_and_status.
    DATA lo_cut TYPE REF TO zif_allocation_sink.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA ls_run TYPE zstockalloc_run.
    DATA ls_allocation TYPE zstockalloc.
    DATA lv_raised TYPE abap_bool.
    DATA lv_overdue_date TYPE d.
    DATA lv_future_date TYPE d.
    DATA lv_future_window TYPE d.
    DATA lv_total_rows TYPE i.
    DATA lv_run_fragment TYPE zif_stock_allocation=>ty_run_id.

    CREATE OBJECT lo_cut TYPE zcl_allocation_sink_sap.
    lv_overdue_date = sy-datum - 1.
    lv_future_date = sy-datum + 1.
    lv_future_window = sy-datum + 2.

    CLEAR ls_run.
    ls_run-mandt = sy-mandt.
    ls_run-run_id = 'RUN-FILTER-U'.
    ls_run-matnr = 'MATERIAL-FILTER'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0001'.
    ls_run-unit = 'EA'.
    ls_run-start_date = sy-datum - 2.
    ls_run-start_time = sy-uzeit.
    ls_run-finish_date = sy-datum.
    ls_run-finish_time = sy-uzeit.
    ls_run-status = 'S'.
    ls_run-movement_type = '201'.
    ls_run-min_shelf_life = 5.
    ls_run-requested_on_from = lv_overdue_date.
    ls_run-available = 0.
    ls_run-demand_count = 1.
    ls_run-shortage = 5.
    INSERT zstockalloc_run FROM @ls_run.

    CLEAR ls_run.
    ls_run-mandt = sy-mandt.
    ls_run-run_id = 'RUN-FILTER-F'.
    ls_run-matnr = 'MATERIAL-FILTER'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0001'.
    ls_run-unit = 'BOX'.
    ls_run-strategy = 'F'.
    ls_run-movement_type = '202'.
    ls_run-min_shelf_life = 7.
    ls_run-start_date = sy-datum.
    ls_run-start_time = sy-uzeit.
    ls_run-finish_date = sy-datum.
    ls_run-finish_time = sy-uzeit.
    ls_run-status = 'P'.
    ls_run-available = 1.
    ls_run-demand_count = 3.
    ls_run-allocated = 1.
    INSERT zstockalloc_run FROM @ls_run.

    CLEAR ls_allocation.
    ls_allocation-mandt = sy-mandt.
    ls_allocation-matnr = 'MATERIAL-FILTER'.
    ls_allocation-werks = '1000'.
    ls_allocation-lgort = '0001'.
    ls_allocation-run_id = 'RUN-FILTER-U'.
    ls_allocation-allocation_unit = 'EA'.
    ls_allocation-order_id = 'FILTER-UNALLOCATED'.
    ls_allocation-requested_on = lv_overdue_date.
    ls_allocation-priority = 42.
    ls_allocation-requested = 5.
    ls_allocation-shortage = 5.
    ls_allocation-allocation_status = 'U'.
    INSERT zstockalloc FROM @ls_allocation.

    CLEAR ls_allocation.
    ls_allocation-mandt = sy-mandt.
    ls_allocation-matnr = 'MATERIAL-FILTER'.
    ls_allocation-werks = '1000'.
    ls_allocation-lgort = '0001'.
    ls_allocation-run_id = 'RUN-FILTER-F'.
    ls_allocation-allocation_unit = 'BOX'.
    ls_allocation-sales_document = '5000000001'.
    ls_allocation-sales_document_type = 'OR'.
    ls_allocation-sales_item = '000010'.
    ls_allocation-schedule_line = '0001'.
    ls_allocation-order_unit = 'EA'.
    ls_allocation-order_id = 'FILTER-FULL'.
    ls_allocation-requested_on = lv_future_date.
    ls_allocation-priority = 1.
    ls_allocation-requested = 1.
    ls_allocation-allocated = 1.
    ls_allocation-allocation_status = 'F'.
    ls_allocation-reservation_id = 'FILTER-RES'.
    ls_allocation-reservation_date = sy-datum.
    ls_allocation-reservation_movement_type = '201'.
    ls_allocation-reservation_unit = 'BOX'.
    INSERT zstockalloc FROM @ls_allocation.

    lt_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 2 ).
    lt_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_offset           = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'FILTER-UNALLOCATED' ).
    cl_abap_unit_assert=>assert_initial(
      lt_demands[ 1 ]-allocation_strategy ).

    lt_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_strategy         = 'f' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'FILTER-FULL' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-allocation_strategy
      exp = 'F' ).

    lt_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_run_status       = 's' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-allocation_run_id
      exp = 'RUN-FILTER-U' ).

    CLEAR lv_raised.
    TRY.
        lo_cut->get_allocations(
          iv_material         = 'MATERIAL-FILTER'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_run_status       = 'X' ).
      CATCH zcx_stock_allocation INTO DATA(lo_audit_status_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_audit_status_error->message
          exp = 'Allocation audit status is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    lt_demands = lo_cut->get_allocations(
      iv_material                 = 'MATERIAL-FILTER'
      iv_plant                    = '1000'
      iv_storage_location         = '0001'
      iv_allocation_movement_type = '202' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'FILTER-FULL' ).

    lt_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_min_shelf_life   = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'FILTER-UNALLOCATED' ).

    CLEAR lv_raised.
    TRY.
        lo_cut->get_allocations(
          iv_material         = 'MATERIAL-FILTER'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_min_shelf_life   = -1 ).
      CATCH zcx_stock_allocation INTO DATA(lo_shelf_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_shelf_error->message
          exp = 'Allocation result minimum shelf-life is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    lt_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_legacy_strategy  = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'FILTER-UNALLOCATED' ).

    lt_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_run_id           = 'RUN-FILTER-F' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'FILTER-FULL' ).

    lt_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_run_id_contains  = 'RUN-FILTER-U' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'FILTER-UNALLOCATED' ).

    lt_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_overdue_only     = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'FILTER-UNALLOCATED' ).

    CLEAR ls_run.
    ls_run-mandt = sy-mandt.
    ls_run-run_id = 'RUN-FILTER-HORIZON'.
    ls_run-matnr = 'MATERIAL-FILTER'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0001'.
    ls_run-unit = 'EA'.
    ls_run-start_date = sy-datum.
    ls_run-start_time = sy-uzeit.
    ls_run-finish_date = sy-datum.
    ls_run-finish_time = sy-uzeit.
    ls_run-status = 'S'.
    ls_run-requested_on_from = lv_overdue_date.
    ls_run-requested_on_to = lv_future_date.
    INSERT zstockalloc_run FROM @ls_run.
    CLEAR ls_allocation.
    ls_allocation-mandt = sy-mandt.
    ls_allocation-matnr = 'MATERIAL-FILTER'.
    ls_allocation-werks = '1000'.
    ls_allocation-lgort = '0001'.
    ls_allocation-run_id = 'RUN-FILTER-HORIZON'.
    ls_allocation-allocation_unit = 'EA'.
    ls_allocation-order_id = 'FILTER-HORIZON'.
    ls_allocation-requested_on = lv_future_date.
    ls_allocation-requested = 1.
    ls_allocation-allocated = 1.
    ls_allocation-allocation_status = 'F'.
    ls_allocation-reservation_id = 'FILTER-HORIZON-RES'.
    ls_allocation-reservation_date = sy-datum.
    ls_allocation-reservation_movement_type = '201'.
    ls_allocation-reservation_unit = 'EA'.
    INSERT zstockalloc FROM @ls_allocation.
    lt_demands = lo_cut->get_allocations(
      iv_material              = 'MATERIAL-FILTER'
      iv_plant                 = '1000'
      iv_storage_location      = '0001'
      iv_run_requested_on_from = lv_overdue_date
      iv_run_requested_on_to   = lv_future_date ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-allocation_run_id
      exp = 'RUN-FILTER-HORIZON' ).
    DELETE FROM zstockalloc
      WHERE run_id = 'RUN-FILTER-HORIZON'.
    DELETE FROM zstockalloc_run
      WHERE run_id = 'RUN-FILTER-HORIZON'.

    lt_demands = lo_cut->get_allocations(
      iv_material              = 'MATERIAL-FILTER'
      iv_plant                 = '1000'
      iv_storage_location      = '0001'
      iv_run_requested_on_from = lv_overdue_date ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-allocation_run_id
      exp = 'RUN-FILTER-U' ).

    lt_demands = lo_cut->get_allocations(
      iv_material              = 'MATERIAL-FILTER'
      iv_plant                 = '1000'
      iv_storage_location      = '0001'
      iv_run_deadline_age_from = 3
      iv_run_deadline_age_to   = 4
      iv_run_deadline_age_date = lv_future_window ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-allocation_run_id
      exp = 'RUN-FILTER-U' ).

    lt_demands = lo_cut->get_allocations(
      iv_material          = 'MATERIAL-FILTER'
      iv_plant             = '1000'
      iv_storage_location  = '0001'
      iv_run_deadline_from = lv_overdue_date
      iv_run_deadline_to   = lv_overdue_date ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-allocation_run_id
      exp = 'RUN-FILTER-U' ).

    lt_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_deadline_only    = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'FILTER-UNALLOCATED' ).

    lt_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_overdue_only     = abap_true
      iv_overdue_date     = lv_future_window ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 2 ).

    lv_run_fragment = 'run-filter-u'.
    lt_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_run_id_contains  = lv_run_fragment ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-allocation_run_id
      exp = 'RUN-FILTER-U' ).

    lt_demands = lo_cut->get_allocations(
      iv_material              = 'MATERIAL-FILTER'
      iv_plant                 = '1000'
      iv_storage_location      = '0001'
      iv_reservation_date_from = sy-datum
      iv_reservation_date_to   = sy-datum ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'FILTER-FULL' ).

    lt_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_movement_type    = '201' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-reservation_movement_type
      exp = '201' ).

    lt_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_reservation_unit = 'BOX' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-reservation_unit
      exp = 'BOX' ).

    lt_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_unreserved_only  = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'FILTER-UNALLOCATED' ).

    CLEAR lv_raised.
    TRY.
        lo_cut->get_allocations(
          iv_material         = 'MATERIAL-FILTER'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_reserved_only    = abap_true
          iv_unreserved_only  = abap_true ).
      CATCH zcx_stock_allocation INTO DATA(lo_reservation_filter_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_reservation_filter_error->message
          exp = 'Allocation result reservation filters conflict' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      act = lv_raised
      exp = abap_true ).

    lt_demands = lo_cut->get_allocations(
      iv_material            = 'MATERIAL-FILTER'
      iv_plant               = '1000'
      iv_storage_location    = '0001'
      iv_sales_document      = '5000000001'
      iv_sales_document_type = 'OR'
      iv_sales_item          = '000010'
      iv_schedule_line       = '0001'
      iv_order_unit          = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-sales_document
      exp = '5000000001' ).

    lt_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_order_unit       = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_unit
      exp = 'EA' ).

    lt_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_reserved_only    = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_not_initial(
      lt_demands[ 1 ]-reservation_id ).

    lt_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_priority_from    = 40
      iv_priority_to      = 50 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-priority
      exp = 42 ).

    lt_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_reservation_id   = 'FILTER-RES' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'FILTER-FULL' ).

    lt_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_status           = 'u' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'FILTER-UNALLOCATED' ).
    lt_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_sort_by_coverage = abap_true
      iv_max_rows         = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'FILTER-UNALLOCATED' ).
    lt_demands = lo_cut->get_allocations(
      iv_material                   = 'MATERIAL-FILTER'
      iv_plant                      = '1000'
      iv_storage_location           = '0001'
      iv_sort_by_requested_quantity = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'FILTER-UNALLOCATED' ).
    lt_demands = lo_cut->get_allocations(
      iv_material                   = 'MATERIAL-FILTER'
      iv_plant                      = '1000'
      iv_storage_location           = '0001'
      iv_sort_by_allocated_quantity = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'FILTER-FULL' ).

    lt_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_shortage_from    = 5
      iv_shortage_to      = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-shortage
      exp = 5 ).

    lt_demands = lo_cut->get_allocations(
      EXPORTING
        iv_material         = 'MATERIAL-FILTER'
        iv_plant            = '1000'
        iv_storage_location = '0001'
        iv_max_rows         = 1
        iv_offset           = 1
      IMPORTING
        ev_total_rows       = lv_total_rows ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_total_rows
      exp = 2 ).

    lt_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_sort_by_coverage = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'FILTER-UNALLOCATED' ).

    lt_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_shortage_only    = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'FILTER-UNALLOCATED' ).

    lt_demands = lo_cut->get_allocations(
      iv_material                = 'MATERIAL-FILTER'
      iv_plant                   = '1000'
      iv_storage_location        = '0001'
      iv_requested_quantity_from = 1
      iv_requested_quantity_to   = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-requested
      exp = 1 ).

    lt_demands = lo_cut->get_allocations(
      iv_material                = 'MATERIAL-FILTER'
      iv_plant                   = '1000'
      iv_storage_location        = '0001'
      iv_allocated_quantity_from = 1
      iv_allocated_quantity_to   = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-allocated
      exp = 1 ).

    lt_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_coverage_from    = 100
      iv_coverage_to      = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'FILTER-FULL' ).

    lt_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_sort_by_priority = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-priority
      exp = 1 ).

    lt_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_sort_by_status   = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-allocation_status
      exp = 'U' ).

    lt_demands = lo_cut->get_allocations(
      iv_material             = 'MATERIAL-FILTER'
      iv_plant                = '1000'
      iv_storage_location     = '0001'
      iv_sort_by_deadline_age = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-allocation_run_id
      exp = 'RUN-FILTER-U' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 2 ]-allocation_run_id
      exp = 'RUN-FILTER-F' ).

    lt_demands = lo_cut->get_allocations(
      iv_material                   = 'MATERIAL-FILTER'
      iv_plant                      = '1000'
      iv_storage_location           = '0001'
      iv_sort_by_requested_deadline = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-allocation_run_id
      exp = 'RUN-FILTER-U' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 2 ]-allocation_run_id
      exp = 'RUN-FILTER-F' ).

    lt_demands = lo_cut->get_allocations(
      iv_material               = 'MATERIAL-FILTER'
      iv_plant                  = '1000'
      iv_storage_location       = '0001'
      iv_sort_by_requested_date = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-requested_on
      exp = lv_overdue_date ).

    lt_demands = lo_cut->get_allocations(
      iv_material                 = 'MATERIAL-FILTER'
      iv_plant                    = '1000'
      iv_storage_location         = '0001'
      iv_sort_by_reservation_date = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'FILTER-UNALLOCATED' ).

    lt_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_sort_by_shortage = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-shortage
      exp = 5 ).

    lt_demands = lo_cut->get_allocations(
      iv_material             = 'MATERIAL-FILTER'
      iv_plant                = '1000'
      iv_storage_location     = '0001'
      iv_sort_by_shortage     = abap_true
      iv_sort_by_demand_count = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-allocation_run_id
      exp = 'RUN-FILTER-F' ).

    lt_demands = lo_cut->get_allocations(
      iv_material               = 'MATERIAL-FILTER'
      iv_plant                  = '1000'
      iv_storage_location       = '0001'
      iv_sort_by_audit_duration = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-allocation_run_id
      exp = 'RUN-FILTER-U' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 2 ]-allocation_run_id
      exp = 'RUN-FILTER-F' ).

    lt_demands = lo_cut->get_allocations(
      iv_material               = 'MATERIAL-FILTER'
      iv_plant                  = '1000'
      iv_storage_location       = '0001'
      iv_sort_by_demand_count   = abap_true
      iv_sort_by_audit_duration = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-allocation_run_id
      exp = 'RUN-FILTER-F' ).

    lt_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-FILTER'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_order_id         = 'FILTER-FULL' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-allocation_run_id
      exp = 'RUN-FILTER-F' ).

    lt_demands = lo_cut->get_allocations(
      iv_material          = 'MATERIAL-FILTER'
      iv_plant             = '1000'
      iv_storage_location  = '0001'
      iv_requested_on_from = sy-datum
      iv_requested_on_to   = lv_future_window ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'FILTER-FULL' ).

    lt_demands = lo_cut->get_allocations(
      iv_material             = 'MATERIAL-FILTER'
      iv_plant                = '1000'
      iv_storage_location     = '0001'
      iv_reservation_age_from = 1 ).
    cl_abap_unit_assert=>assert_initial( lt_demands ).

    TRY.
        lt_demands = lo_cut->get_allocations(
          iv_material         = 'MATERIAL-FILTER'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_status           = 'X' ).
      CATCH zcx_stock_allocation INTO DATA(lo_status_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_status_error->message
          exp = 'Allocation snapshot status is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    TRY.
        lt_demands = lo_cut->get_allocations(
          iv_material         = 'MATERIAL-FILTER'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_strategy         = 'X' ).
      CATCH zcx_stock_allocation INTO DATA(lo_strategy_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_strategy_error->message
          exp = 'Allocation snapshot strategy is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    TRY.
        lt_demands = lo_cut->get_allocations(
          iv_material         = 'MATERIAL-FILTER'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_strategy         = 'F'
          iv_legacy_strategy  = abap_true ).
      CATCH zcx_stock_allocation INTO DATA(lo_strategy_conflict_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_strategy_conflict_error->message
          exp = 'Allocation result strategy filters conflict' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    TRY.
        lt_demands = lo_cut->get_allocations(
          iv_material             = 'MATERIAL-FILTER'
          iv_plant                = '1000'
          iv_storage_location     = '0001'
          iv_reservation_age_from = -1 ).
      CATCH zcx_stock_allocation INTO DATA(lo_reservation_age_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_reservation_age_error->message
          exp = 'Allocation result reservation age is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    TRY.
        lt_demands = lo_cut->get_allocations(
          iv_material         = 'MATERIAL-FILTER'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_offset           = -1 ).
      CATCH zcx_stock_allocation INTO DATA(lo_row_offset_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_row_offset_error->message
          exp = 'Allocation result row offset is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    TRY.
        lt_demands = lo_cut->get_allocations(
          iv_material         = 'MATERIAL-FILTER'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_max_rows         = -1 ).
      CATCH zcx_stock_allocation INTO DATA(lo_row_limit_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_row_limit_error->message
          exp = 'Allocation result row limit is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    TRY.
        lt_demands = lo_cut->get_allocations(
          iv_material         = 'MATERIAL-FILTER'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_coverage_from    = 101
          iv_coverage_to      = 100 ).
      CATCH zcx_stock_allocation INTO DATA(lo_coverage_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_coverage_error->message
          exp = 'Allocation result coverage range is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    TRY.
        lt_demands = lo_cut->get_allocations(
          iv_material                = 'MATERIAL-FILTER'
          iv_plant                   = '1000'
          iv_storage_location        = '0001'
          iv_allocated_quantity_from = 6
          iv_allocated_quantity_to   = 5 ).
      CATCH zcx_stock_allocation INTO DATA(lo_allocated_quantity_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_allocated_quantity_error->message
          exp = 'Allocation result allocated quantity range is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    TRY.
        lt_demands = lo_cut->get_allocations(
          iv_material                = 'MATERIAL-FILTER'
          iv_plant                   = '1000'
          iv_storage_location        = '0001'
          iv_requested_quantity_from = 6
          iv_requested_quantity_to   = 5 ).
      CATCH zcx_stock_allocation INTO DATA(lo_requested_quantity_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_requested_quantity_error->message
          exp = 'Allocation result requested quantity range is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    TRY.
        lt_demands = lo_cut->get_allocations(
          iv_material         = 'MATERIAL-FILTER'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_shortage_from    = 6
          iv_shortage_to      = 5 ).
      CATCH zcx_stock_allocation INTO DATA(lo_shortage_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_shortage_error->message
          exp = 'Allocation result shortage range is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    TRY.
        lt_demands = lo_cut->get_allocations(
          iv_material              = 'MATERIAL-FILTER'
          iv_plant                 = '1000'
          iv_storage_location      = '0001'
          iv_reservation_date_from = '20260821'
          iv_reservation_date_to   = '20260816' ).
      CATCH zcx_stock_allocation INTO DATA(lo_reservation_date_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_reservation_date_error->message
          exp = 'Allocation result reservation date range is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    TRY.
        lt_demands = lo_cut->get_allocations(
          iv_material          = 'MATERIAL-FILTER'
          iv_plant             = '1000'
          iv_storage_location  = '0001'
          iv_requested_on_from = '20260821'
          iv_requested_on_to   = '20260816' ).
      CATCH zcx_stock_allocation INTO DATA(lo_date_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_date_error->message
          exp = 'Allocation result date range is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    TRY.
        lt_demands = lo_cut->get_allocations(
          iv_material              = 'MATERIAL-FILTER'
          iv_plant                 = '1000'
          iv_storage_location      = '0001'
          iv_run_deadline_age_from = 4
          iv_run_deadline_age_to   = 3 ).
      CATCH zcx_stock_allocation INTO DATA(lo_deadline_age_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_deadline_age_error->message
          exp = 'Allocation result deadline age range is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    TRY.
        lt_demands = lo_cut->get_allocations(
          iv_material              = 'MATERIAL-FILTER'
          iv_plant                 = '1000'
          iv_storage_location      = '0001'
          iv_run_deadline_age_date = lv_future_window ).
      CATCH zcx_stock_allocation INTO DATA(lo_deadline_age_date_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_deadline_age_date_error->message
          exp = 'Allocation result deadline age date requires an age range' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    TRY.
        lt_demands = lo_cut->get_allocations(
          iv_material          = 'MATERIAL-FILTER'
          iv_plant             = '1000'
          iv_storage_location  = '0001'
          iv_run_deadline_from = lv_future_date
          iv_run_deadline_to   = lv_overdue_date ).
      CATCH zcx_stock_allocation INTO DATA(lo_deadline_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_deadline_error->message
          exp = 'Allocation result requested deadline range is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    TRY.
        lt_demands = lo_cut->get_allocations(
          iv_material              = 'MATERIAL-FILTER'
          iv_plant                 = '1000'
          iv_storage_location      = '0001'
          iv_run_requested_on_from = lv_future_date
          iv_run_requested_on_to   = lv_overdue_date ).
      CATCH zcx_stock_allocation INTO DATA(lo_run_horizon_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_run_horizon_error->message
          exp = 'Allocation result requested horizon range is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    TRY.
        lt_demands = lo_cut->get_allocations(
          iv_material         = 'MATERIAL-FILTER'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_priority_from    = 50
          iv_priority_to      = 40 ).
      CATCH zcx_stock_allocation INTO DATA(lo_priority_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_priority_error->message
          exp = 'Allocation result priority range is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD rejects_missing_reservation.
    DATA lo_cut TYPE REF TO zif_allocation_sink.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_cut TYPE zcl_allocation_sink_sap.
    APPEND VALUE #( order_id          = 'NO-RESERVATION'
                    requested         = '1'
                    allocated         = '1'
                    allocation_status = 'F' ) TO lt_demands.
    TRY.
        lo_cut->save_allocations(
          iv_material         = 'MATERIAL-NO-RESERVATION'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_run_id           = 'RUN-NO-RESERVATION'
          iv_unit             = 'EA'
          it_demands          = lt_demands ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Allocation snapshot demand is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR: lt_demands, lv_raised.
    APPEND VALUE #( order_id          = 'NO-RESERVATION-DATE'
                    requested         = '1'
                    allocated         = '1'
                    allocation_status = 'F'
                    reservation_id    = 'RES-WITHOUT-DATE' ) TO lt_demands.
    TRY.
        lo_cut->save_allocations(
          iv_material         = 'MATERIAL-NO-RESERVATION-DATE'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_run_id           = 'RUN-NO-RESERVATION-DATE'
          iv_unit             = 'EA'
          it_demands          = lt_demands ).
      CATCH zcx_stock_allocation INTO DATA(lo_metadata_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_metadata_error->message
          exp = 'Allocation snapshot demand is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR: lt_demands, lv_raised.
    APPEND VALUE #( order_id          = 'UNALLOCATED-WITH-RESERVATION'
                    requested         = '1'
                    allocated         = '0'
                    shortage          = '1'
                    allocation_status = 'U'
                    reservation_id    = 'RES-STALE' ) TO lt_demands.
    TRY.
        lo_cut->save_allocations(
          iv_material         = 'MATERIAL-STALE-RESERVATION'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_run_id           = 'RUN-STALE-RESERVATION'
          iv_unit             = 'EA'
          it_demands          = lt_demands ).
      CATCH zcx_stock_allocation INTO DATA(lo_stale_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_stale_error->message
          exp = 'Allocation snapshot demand is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD rejects_corrupt_read.
    DATA lo_cut TYPE REF TO zif_allocation_sink.
    DATA ls_corrupt TYPE zstockalloc.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_cut TYPE zcl_allocation_sink_sap.
    ls_corrupt-mandt = sy-mandt.
    ls_corrupt-matnr = 'MATERIAL-CORRUPT'.
    ls_corrupt-werks = '1000'.
    ls_corrupt-lgort = '0001'.
    ls_corrupt-run_id = 'RUN-CORRUPT'.
    ls_corrupt-allocation_unit = 'EA'.
    ls_corrupt-order_id = 'CORRUPT-ROW'.
    ls_corrupt-requested = '1'.
    ls_corrupt-allocated = '1'.
    ls_corrupt-shortage = '0'.
    ls_corrupt-allocation_status = 'F'.
    ls_corrupt-reservation_id = 'RES-CORRUPT'.
    ls_corrupt-reservation_date = '20260101'.
    ls_corrupt-reservation_movement_type = '201'.
    ls_corrupt-reservation_unit = 'BOX'.
    INSERT zstockalloc FROM @ls_corrupt.

    TRY.
        lo_cut->get_allocations(
          iv_material         = 'MATERIAL-CORRUPT'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Allocation snapshot demand is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    DELETE FROM zstockalloc
      WHERE matnr = 'MATERIAL-CORRUPT'
        AND werks = '1000'
        AND lgort = '0001'.
  ENDMETHOD.

  METHOD rejects_mixed_run_read.
    DATA lo_cut TYPE REF TO zif_allocation_sink.
    DATA ls_first TYPE zstockalloc.
    DATA ls_second TYPE zstockalloc.
    DATA ls_third TYPE zstockalloc.
    DATA ls_run TYPE zstockalloc_run.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_cut TYPE zcl_allocation_sink_sap.
    ls_run-mandt = sy-mandt.
    ls_run-run_id = 'RUN-MIXED-ONE'.
    ls_run-matnr = 'MATERIAL-MIXED-RUN'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0001'.
    ls_run-unit = 'EA'.
    ls_run-start_date = sy-datum.
    ls_run-start_time = sy-uzeit.
    ls_run-status = 'R'.
    ls_run-available = 1.
    ls_run-demand_count = 1.
    INSERT zstockalloc_run FROM @ls_run.
    ls_run-run_id = 'RUN-MIXED-TWO'.
    INSERT zstockalloc_run FROM @ls_run.
    ls_first-mandt = sy-mandt.
    ls_first-matnr = 'MATERIAL-MIXED-RUN'.
    ls_first-werks = '1000'.
    ls_first-lgort = '0001'.
    ls_first-run_id = 'RUN-MIXED-ONE'.
    ls_first-allocation_unit = 'EA'.
    ls_first-order_id = 'MIXED-ONE'.
    ls_first-requested = '1'.
    ls_first-allocated = '1'.
    ls_first-allocation_status = 'F'.
    ls_first-reservation_id = 'RES-MIXED-ONE'.
    ls_first-reservation_date = '20260101'.
    ls_first-reservation_movement_type = '201'.
    ls_first-reservation_unit = 'EA'.
    ls_second = ls_first.
    ls_second-run_id = 'RUN-MIXED-TWO'.
    ls_second-order_id = 'MIXED-TWO'.
    ls_second-reservation_id = 'RES-MIXED-TWO'.
    INSERT zstockalloc FROM @ls_first.
    INSERT zstockalloc FROM @ls_second.

    TRY.
        lo_cut->get_allocations(
          iv_material         = 'MATERIAL-MIXED-RUN'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Allocation snapshot provenance is inconsistent' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    DELETE FROM zstockalloc
      WHERE matnr = 'MATERIAL-MIXED-RUN'
        AND werks = '1000'
        AND lgort = '0001'.
    DELETE FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-MIXED-RUN'.

    CLEAR ls_run.
    ls_run-mandt = sy-mandt.
    ls_run-run_id = 'RUN-INTERLEAVED-ONE'.
    ls_run-matnr = 'MATERIAL-MIXED-RUN'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0001'.
    ls_run-unit = 'EA'.
    ls_run-start_date = sy-datum.
    ls_run-start_time = sy-uzeit.
    ls_run-status = 'R'.
    ls_run-available = 1.
    ls_run-demand_count = 1.
    INSERT zstockalloc_run FROM @ls_run.
    ls_run-run_id = 'RUN-INTERLEAVED-BOX'.
    ls_run-unit = 'BOX'.
    INSERT zstockalloc_run FROM @ls_run.
    ls_run-run_id = 'RUN-INTERLEAVED-TWO'.
    ls_run-unit = 'EA'.
    INSERT zstockalloc_run FROM @ls_run.

    CLEAR ls_first.
    ls_first-mandt = sy-mandt.
    ls_first-matnr = 'MATERIAL-MIXED-RUN'.
    ls_first-werks = '1000'.
    ls_first-lgort = '0001'.
    ls_first-run_id = 'RUN-INTERLEAVED-ONE'.
    ls_first-allocation_unit = 'EA'.
    ls_first-requested_on = '20260101'.
    ls_first-order_id = 'INTERLEAVED-ONE'.
    ls_first-requested = 1.
    ls_first-allocated = 1.
    ls_first-allocation_status = 'F'.
    ls_first-reservation_id = 'RES-INTERLEAVED-ONE'.
    ls_first-reservation_date = '20260101'.
    ls_first-reservation_movement_type = '201'.
    ls_first-reservation_unit = 'EA'.
    ls_second = ls_first.
    ls_second-run_id = 'RUN-INTERLEAVED-BOX'.
    ls_second-allocation_unit = 'BOX'.
    ls_second-requested_on = '20260102'.
    ls_second-order_id = 'INTERLEAVED-BOX'.
    ls_second-reservation_id = 'RES-INTERLEAVED-BOX'.
    ls_second-reservation_unit = 'BOX'.
    ls_third = ls_first.
    ls_third-run_id = 'RUN-INTERLEAVED-TWO'.
    ls_third-requested_on = '20260103'.
    ls_third-order_id = 'INTERLEAVED-TWO'.
    ls_third-reservation_id = 'RES-INTERLEAVED-TWO'.
    INSERT zstockalloc FROM @ls_first.
    INSERT zstockalloc FROM @ls_second.
    INSERT zstockalloc FROM @ls_third.
    CLEAR lv_raised.
    TRY.
        lo_cut->get_allocations(
          iv_material               = 'MATERIAL-MIXED-RUN'
          iv_plant                  = '1000'
          iv_storage_location       = '0001'
          iv_sort_by_requested_date = abap_true ).
      CATCH zcx_stock_allocation INTO DATA(lo_interleaved_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_interleaved_error->message
          exp = 'Allocation snapshot provenance is inconsistent' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    DELETE FROM zstockalloc
      WHERE matnr = 'MATERIAL-MIXED-RUN'
        AND werks = '1000'
        AND lgort = '0001'.
    DELETE FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-MIXED-RUN'.

    ls_first-run_id = 'RUN-DUPLICATE'.
    ls_first-order_id = 'DUPLICATE-ONE'.
    ls_first-reservation_id = 'RES-DUPLICATE'.
    ls_second = ls_first.
    ls_second-order_id = 'DUPLICATE-TWO'.
    CLEAR ls_run.
    ls_run-mandt = sy-mandt.
    ls_run-run_id = 'RUN-DUPLICATE'.
    ls_run-matnr = 'MATERIAL-MIXED-RUN'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0001'.
    ls_run-unit = 'EA'.
    ls_run-start_date = sy-datum.
    ls_run-start_time = sy-uzeit.
    ls_run-status = 'R'.
    ls_run-available = 2.
    ls_run-demand_count = 2.
    INSERT zstockalloc_run FROM @ls_run.
    INSERT zstockalloc FROM @ls_first.
    INSERT zstockalloc FROM @ls_second.
    CLEAR lv_raised.
    TRY.
        lo_cut->get_allocations(
          iv_material         = 'MATERIAL-MIXED-RUN'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_duplicate_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_duplicate_error->message
          exp = 'Allocation snapshot reservation correlation is duplicated' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    DELETE FROM zstockalloc
      WHERE matnr = 'MATERIAL-MIXED-RUN'
        AND werks = '1000'
        AND lgort = '0001'.
    DELETE FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-MIXED-RUN'.

  ENDMETHOD.

  METHOD rejects_orphan_read.
    DATA lo_cut TYPE REF TO zif_allocation_sink.
    DATA ls_allocation TYPE zstockalloc.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_cut TYPE zcl_allocation_sink_sap.
    ls_allocation-mandt = sy-mandt.
    ls_allocation-matnr = 'MATERIAL-ORPHAN-READ'.
    ls_allocation-werks = '1000'.
    ls_allocation-lgort = '0001'.
    ls_allocation-run_id = 'RUN-ORPHAN-READ'.
    ls_allocation-allocation_unit = 'EA'.
    ls_allocation-order_id = 'ORPHAN-READ'.
    ls_allocation-requested = 1.
    ls_allocation-allocated = 1.
    ls_allocation-allocation_status = 'F'.
    ls_allocation-reservation_id = 'RES-ORPHAN-READ'.
    ls_allocation-reservation_date = '20260101'.
    ls_allocation-reservation_movement_type = '201'.
    ls_allocation-reservation_unit = 'EA'.
    INSERT zstockalloc FROM @ls_allocation.

    TRY.
        lo_cut->get_allocations(
          iv_material         = 'MATERIAL-ORPHAN-READ'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Allocation snapshot run was not found' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    DELETE FROM zstockalloc
      WHERE matnr = 'MATERIAL-ORPHAN-READ'
        AND werks = '1000'
        AND lgort = '0001'.
  ENDMETHOD.

  METHOD rejects_bad_mvt_filter.
    DATA lo_cut TYPE REF TO zif_allocation_sink.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_cut TYPE zcl_allocation_sink_sap.
    TRY.
        lo_cut->get_allocations(
          iv_material                 = 'MATERIAL-FILTER'
          iv_plant                    = '1000'
          iv_storage_location         = '0001'
          iv_allocation_movement_type = '2A1' ).
      CATCH zcx_stock_allocation INTO DATA(lo_allocation_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_allocation_error->message
          exp = 'Allocation result movement type is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.

    TRY.
        lo_cut->get_allocations(
          iv_material         = 'MATERIAL-FILTER'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '2A1' ).
      CATCH zcx_stock_allocation INTO DATA(lo_reservation_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_reservation_error->message
          exp = 'Allocation result movement type is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD accepts_lowercase_units.
    DATA lo_cut TYPE REF TO zif_allocation_sink.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.

    CREATE OBJECT lo_cut TYPE zcl_allocation_sink_sap.
    lt_demands = lo_cut->get_allocations(
          iv_material         = 'MATERIAL-FILTER'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_unit             = 'ea' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-allocation_unit
      exp = 'EA' ).

    lt_demands = lo_cut->get_allocations(
          iv_material         = 'MATERIAL-FILTER'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_order_unit       = 'ea' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'FILTER-FULL' ).

    lt_demands = lo_cut->get_allocations(
          iv_material         = 'MATERIAL-FILTER'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_reservation_unit = 'box' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'FILTER-FULL' ).
  ENDMETHOD.

  METHOD accepts_lowercase_status.
    DATA lo_cut TYPE REF TO zif_allocation_sink.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lt_saved_demands TYPE zif_stock_allocation=>tt_demands.
    DATA ls_run TYPE zstockalloc_run.
    DATA ls_allocation TYPE zstockalloc.

    ls_run-mandt = sy-mandt.
    ls_run-run_id = 'RUN-LOWERCASE-STATUS'.
    ls_run-matnr = 'MATERIAL-LOWERCASE-STATUS'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0001'.
    ls_run-unit = 'ea'.
    ls_run-strategy = 'p'.
    ls_run-start_date = sy-datum.
    ls_run-start_time = sy-uzeit.
    ls_run-status = 'r'.
    ls_run-available = 1.
    ls_run-demand_count = 1.
    INSERT zstockalloc_run FROM @ls_run.

    APPEND VALUE #( order_id                  = 'LOWERCASE-STATUS'
                    requested                 = '1'
                    allocated                 = '1'
                    shortage                  = '0'
                    allocation_strategy       = 'p'
                    allocation_status         = 'f'
                    reservation_id            = 'RES-LOWERCASE-STATUS'
                    reservation_date          = '20260101'
                    reservation_movement_type = '201'
                    reservation_unit          = 'ea' ) TO lt_demands.

    CREATE OBJECT lo_cut TYPE zcl_allocation_sink_sap.
    lo_cut->save_allocations(
      iv_material         = 'MATERIAL-LOWERCASE-STATUS'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_run_id           = 'RUN-LOWERCASE-STATUS'
      iv_unit             = 'ea'
      it_demands          = lt_demands ).

    lt_saved_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-LOWERCASE-STATUS'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_run_id           = 'RUN-LOWERCASE-STATUS'
      iv_unit             = 'EA'
      iv_strategy         = 'p' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_saved_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_saved_demands[ 1 ]-allocation_status
      exp = 'F' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_saved_demands[ 1 ]-allocation_strategy
      exp = 'P' ).

    DELETE FROM zstockalloc
      WHERE matnr = 'MATERIAL-LOWERCASE-STATUS'
        AND werks = '1000'
        AND lgort = '0001'.
    ls_allocation-mandt = sy-mandt.
    ls_allocation-matnr = 'MATERIAL-LOWERCASE-STATUS'.
    ls_allocation-werks = '1000'.
    ls_allocation-lgort = '0001'.
    ls_allocation-run_id = 'RUN-LOWERCASE-STATUS'.
    ls_allocation-allocation_unit = 'ea'.
    ls_allocation-order_id = 'LOWERCASE-LEGACY'.
    ls_allocation-requested = 1.
    ls_allocation-allocated = 1.
    ls_allocation-allocation_status = 'f'.
    ls_allocation-reservation_id = 'RES-LOWERCASE-LEGACY'.
    ls_allocation-reservation_date = '20260101'.
    ls_allocation-reservation_movement_type = '201'.
    ls_allocation-reservation_unit = 'ea'.
    INSERT zstockalloc FROM @ls_allocation.

    lt_saved_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-LOWERCASE-STATUS'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_run_id           = 'RUN-LOWERCASE-STATUS'
      iv_strategy         = 'P' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_saved_demands[ 1 ]-allocation_status
      exp = 'F' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_saved_demands[ 1 ]-allocation_unit
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_saved_demands[ 1 ]-reservation_unit
      exp = 'EA' ).

    DELETE FROM zstockalloc
      WHERE matnr = 'MATERIAL-LOWERCASE-STATUS'
        AND werks = '1000'
        AND lgort = '0001'.
    DELETE FROM zstockalloc_run
      WHERE run_id = 'RUN-LOWERCASE-STATUS'.
  ENDMETHOD.

  METHOD rejects_invalid_run_status.
    DATA lo_cut TYPE REF TO zif_allocation_sink.
    DATA ls_allocation TYPE zstockalloc.
    DATA ls_run TYPE zstockalloc_run.
    DATA lv_raised TYPE abap_bool.

    ls_run-mandt = sy-mandt.
    ls_run-run_id = 'RUN-INVALID-STATUS-READ'.
    ls_run-matnr = 'MATERIAL-INVALID-STATUS'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0001'.
    ls_run-unit = 'EA'.
    ls_run-start_date = sy-datum.
    ls_run-start_time = sy-uzeit.
    ls_run-status = 'X'.
    ls_run-available = 1.
    ls_run-demand_count = 1.
    INSERT zstockalloc_run FROM @ls_run.

    ls_allocation-mandt = sy-mandt.
    ls_allocation-matnr = 'MATERIAL-INVALID-STATUS'.
    ls_allocation-werks = '1000'.
    ls_allocation-lgort = '0001'.
    ls_allocation-run_id = 'RUN-INVALID-STATUS-READ'.
    ls_allocation-allocation_unit = 'EA'.
    ls_allocation-order_id = 'INVALID-STATUS-READ'.
    ls_allocation-requested = 1.
    ls_allocation-allocated = 1.
    ls_allocation-allocation_status = 'F'.
    ls_allocation-reservation_id = 'RES-INVALID-STATUS'.
    ls_allocation-reservation_date = '20260101'.
    ls_allocation-reservation_movement_type = '201'.
    ls_allocation-reservation_unit = 'EA'.
    INSERT zstockalloc FROM @ls_allocation.

    CREATE OBJECT lo_cut TYPE zcl_allocation_sink_sap.
    TRY.
        lo_cut->get_allocations(
          iv_material         = 'MATERIAL-INVALID-STATUS'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Allocation snapshot run status is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    DELETE FROM zstockalloc
      WHERE matnr = 'MATERIAL-INVALID-STATUS'
        AND werks = '1000'
        AND lgort = '0001'.
    DELETE FROM zstockalloc_run
      WHERE run_id = 'RUN-INVALID-STATUS-READ'.
  ENDMETHOD.

  METHOD rejects_invalid_run_strategy.
    DATA lo_cut TYPE REF TO zif_allocation_sink.
    DATA ls_allocation TYPE zstockalloc.
    DATA ls_run TYPE zstockalloc_run.
    DATA lv_raised TYPE abap_bool.

    ls_run-mandt = sy-mandt.
    ls_run-run_id = 'RUN-INVALID-STRATEGY-READ'.
    ls_run-matnr = 'MATERIAL-INVALID-STRATEGY'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0001'.
    ls_run-unit = 'EA'.
    ls_run-strategy = 'X'.
    ls_run-start_date = sy-datum.
    ls_run-start_time = sy-uzeit.
    ls_run-status = 'R'.
    ls_run-available = 1.
    ls_run-demand_count = 1.
    INSERT zstockalloc_run FROM @ls_run.

    ls_allocation-mandt = sy-mandt.
    ls_allocation-matnr = 'MATERIAL-INVALID-STRATEGY'.
    ls_allocation-werks = '1000'.
    ls_allocation-lgort = '0001'.
    ls_allocation-run_id = 'RUN-INVALID-STRATEGY-READ'.
    ls_allocation-allocation_unit = 'EA'.
    ls_allocation-order_id = 'INVALID-STRATEGY-READ'.
    ls_allocation-requested = 1.
    ls_allocation-allocated = 1.
    ls_allocation-allocation_status = 'F'.
    ls_allocation-reservation_id = 'RES-INVALID-STRATEGY'.
    ls_allocation-reservation_date = '20260101'.
    ls_allocation-reservation_movement_type = '201'.
    ls_allocation-reservation_unit = 'EA'.
    INSERT zstockalloc FROM @ls_allocation.

    CREATE OBJECT lo_cut TYPE zcl_allocation_sink_sap.
    TRY.
        lo_cut->get_allocations(
          iv_material         = 'MATERIAL-INVALID-STRATEGY'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Allocation snapshot run strategy is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    DELETE FROM zstockalloc
      WHERE matnr = 'MATERIAL-INVALID-STRATEGY'
        AND werks = '1000'
        AND lgort = '0001'.
    DELETE FROM zstockalloc_run
      WHERE run_id = 'RUN-INVALID-STRATEGY-READ'.
  ENDMETHOD.

  METHOD rejects_alloc_unit_mismatch.
    DATA lo_cut TYPE REF TO zif_allocation_sink.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_cut TYPE zcl_allocation_sink_sap.
    APPEND VALUE #( allocation_unit           = 'BOX'
                    order_id                  = 'MISMATCHED-UNIT'
                    requested                 = '1'
                    allocated                 = '1'
                    allocation_status         = 'F'
                    reservation_id            = 'RES-MISMATCHED-UNIT'
                    reservation_date          = '20260101'
                    reservation_movement_type = '201'
                    reservation_unit          = 'EA' ) TO lt_demands.
    TRY.
        lo_cut->save_allocations(
          iv_material         = 'MATERIAL-MISMATCHED-UNIT'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_run_id           = 'RUN-MISMATCHED-UNIT'
          iv_unit             = 'EA'
          it_demands          = lt_demands ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Allocation snapshot demand is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD rejects_alloc_run_mismatch.
    DATA lo_cut TYPE REF TO zif_allocation_sink.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lv_raised TYPE abap_bool.
    DATA lv_saved_count TYPE i.

    CREATE OBJECT lo_cut TYPE zcl_allocation_sink_sap.
    APPEND VALUE #( allocation_run_id         = 'RUN-PAYLOAD'
                    order_id                  = 'MISMATCHED-RUN'
                    requested                 = '1'
                    allocated                 = '1'
                    allocation_status         = 'F'
                    reservation_id            = 'RES-MISMATCHED-RUN'
                    reservation_date          = '20260101'
                    reservation_movement_type = '201'
                    reservation_unit          = 'EA' ) TO lt_demands.
    TRY.
        lo_cut->save_allocations(
          iv_material         = 'MATERIAL-MISMATCHED-RUN'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_run_id           = 'RUN-SCOPE'
          iv_unit             = 'EA'
          it_demands          = lt_demands ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Allocation snapshot demand is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT COUNT( * )
      FROM zstockalloc
      INTO @lv_saved_count
      WHERE matnr = 'MATERIAL-MISMATCHED-RUN'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_saved_count
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_strategy_mismatch.
    DATA lo_cut TYPE REF TO zif_allocation_sink.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA ls_run TYPE zstockalloc_run.
    DATA lv_raised TYPE abap_bool.
    DATA lv_saved_count TYPE i.

    ls_run-mandt = sy-mandt.
    ls_run-run_id = 'RUN-STRATEGY-SCOPE'.
    ls_run-matnr = 'MATERIAL-STRATEGY'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0001'.
    ls_run-unit = 'EA'.
    ls_run-strategy = 'F'.
    ls_run-start_date = sy-datum.
    ls_run-start_time = sy-uzeit.
    ls_run-status = 'R'.
    ls_run-available = 1.
    ls_run-demand_count = 1.
    INSERT zstockalloc_run FROM @ls_run.

    CREATE OBJECT lo_cut TYPE zcl_allocation_sink_sap.
    APPEND VALUE #( allocation_run_id         = 'RUN-STRATEGY-SCOPE'
                    allocation_strategy       = 'P'
                    order_id                  = 'MISMATCHED-STRATEGY'
                    requested                 = '1'
                    allocated                 = '1'
                    allocation_status         = 'F'
                    reservation_id            = 'RES-MISMATCHED-STRATEGY'
                    reservation_date          = '20260101'
                    reservation_movement_type = '201'
                    reservation_unit          = 'EA' ) TO lt_demands.
    TRY.
        lo_cut->save_allocations(
          iv_material         = 'MATERIAL-STRATEGY'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_run_id           = 'RUN-STRATEGY-SCOPE'
          iv_unit             = 'EA'
          it_demands          = lt_demands ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Allocation snapshot run strategy is inconsistent' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT COUNT( * )
      FROM zstockalloc
      INTO @lv_saved_count
      WHERE matnr = 'MATERIAL-STRATEGY'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_saved_count
      exp = 0 ).
    DELETE FROM zstockalloc_run
      WHERE run_id = 'RUN-STRATEGY-SCOPE'.
  ENDMETHOD.

  METHOD rejects_date_mismatch.
    DATA lo_cut TYPE REF TO zif_allocation_sink.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA ls_run TYPE zstockalloc_run.
    DATA ls_allocation TYPE zstockalloc.
    DATA lv_raised TYPE abap_bool.
    DATA lv_saved_count TYPE i.

    ls_run-mandt = sy-mandt.
    ls_run-run_id = 'RUN-DATE-SCOPE'.
    ls_run-matnr = 'MATERIAL-DATE'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0001'.
    ls_run-unit = 'EA'.
    ls_run-requested_on_from = '20260801'.
    ls_run-requested_on_to = '20260807'.
    ls_run-start_date = sy-datum.
    ls_run-start_time = sy-uzeit.
    ls_run-status = 'R'.
    ls_run-available = 1.
    ls_run-demand_count = 1.
    INSERT zstockalloc_run FROM @ls_run.

    CREATE OBJECT lo_cut TYPE zcl_allocation_sink_sap.
    APPEND VALUE #( allocation_run_id = 'RUN-DATE-SCOPE'
                    requested_on      = '20260808'
                    order_id          = 'MISMATCHED-DATE'
                    requested         = '1'
                    allocated         = '0'
                    shortage          = '1'
                    allocation_status = 'U' ) TO lt_demands.
    TRY.
        lo_cut->save_allocations(
          iv_material         = 'MATERIAL-DATE'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_run_id           = 'RUN-DATE-SCOPE'
          iv_unit             = 'EA'
          it_demands          = lt_demands ).
      CATCH zcx_stock_allocation INTO DATA(lo_write_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_write_error->message
          exp = 'Allocation snapshot requested date is inconsistent' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT COUNT( * )
      FROM zstockalloc
      INTO @lv_saved_count
      WHERE matnr = 'MATERIAL-DATE'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_saved_count
      exp = 0 ).

    ls_allocation-mandt = sy-mandt.
    ls_allocation-matnr = 'MATERIAL-DATE'.
    ls_allocation-werks = '1000'.
    ls_allocation-lgort = '0001'.
    ls_allocation-run_id = 'RUN-DATE-SCOPE'.
    ls_allocation-allocation_unit = 'EA'.
    ls_allocation-requested_on = '20260808'.
    ls_allocation-order_id = 'MISMATCHED-DATE'.
    ls_allocation-requested = 1.
    ls_allocation-allocation_status = 'U'.
    ls_allocation-shortage = 1.
    INSERT zstockalloc FROM @ls_allocation.

    CLEAR lv_raised.
    TRY.
        lo_cut->get_allocations(
          iv_material         = 'MATERIAL-DATE'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
      CATCH zcx_stock_allocation INTO DATA(lo_read_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_read_error->message
          exp = 'Allocation snapshot requested date is inconsistent' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    DELETE FROM zstockalloc
      WHERE matnr = 'MATERIAL-DATE'
        AND werks = '1000'
        AND lgort = '0001'.
    DELETE FROM zstockalloc_run
      WHERE run_id = 'RUN-DATE-SCOPE'.
  ENDMETHOD.

  METHOD rejects_unknown_run.
    DATA lo_cut TYPE REF TO zif_allocation_sink.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_cut TYPE zcl_allocation_sink_sap.
    APPEND VALUE #( order_id                  = 'UNKNOWN-RUN'
                    requested                 = '1'
                    allocated                 = '1'
                    allocation_status         = 'F'
                    reservation_id            = 'RES-UNKNOWN-RUN'
                    reservation_date          = '20260101'
                    reservation_movement_type = '201'
                    reservation_unit          = 'EA' ) TO lt_demands.
    TRY.
        lo_cut->save_allocations(
          iv_material         = 'MATERIAL-UNKNOWN-RUN'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_run_id           = 'RUN-UNKNOWN'
          iv_unit             = 'EA'
          it_demands          = lt_demands ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Allocation snapshot run was not found' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD rejects_inconsistent_run.
    DATA lo_cut TYPE REF TO zif_allocation_sink.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA ls_run TYPE zstockalloc_run.
    DATA lv_raised TYPE abap_bool.

    ls_run-mandt = sy-mandt.
    ls_run-run_id = 'RUN-INCONSISTENT-SCOPE'.
    ls_run-matnr = 'MATERIAL-INCONSISTENT-RUN'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0001'.
    ls_run-unit = 'EA'.
    ls_run-start_date = sy-datum.
    ls_run-start_time = sy-uzeit.
    ls_run-status = 'R'.
    ls_run-available = 1.
    ls_run-demand_count = 1.
    INSERT zstockalloc_run FROM @ls_run.

    CREATE OBJECT lo_cut TYPE zcl_allocation_sink_sap.
    APPEND VALUE #( order_id                  = 'INCONSISTENT-RUN'
                    requested                 = '1'
                    allocated                 = '1'
                    allocation_status         = 'F'
                    reservation_id            = 'RES-INCONSISTENT-RUN'
                    reservation_date          = '20260101'
                    reservation_movement_type = '201'
                    reservation_unit          = 'BOX' ) TO lt_demands.
    TRY.
        lo_cut->save_allocations(
          iv_material         = 'MATERIAL-INCONSISTENT-RUN'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_run_id           = 'RUN-INCONSISTENT-SCOPE'
          iv_unit             = 'BOX'
          it_demands          = lt_demands ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Allocation snapshot run scope is inconsistent' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    DELETE FROM zstockalloc_run
      WHERE run_id = 'RUN-INCONSISTENT-SCOPE'.
  ENDMETHOD.

  METHOD rejects_finalized_run.
    DATA lo_cut TYPE REF TO zif_allocation_sink.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA ls_run TYPE zstockalloc_run.
    DATA lv_raised TYPE abap_bool.

    ls_run-mandt = sy-mandt.
    ls_run-run_id = 'RUN-FINALIZED-SNAPSHOT'.
    ls_run-matnr = 'MATERIAL-FINALIZED-RUN'.
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

    CREATE OBJECT lo_cut TYPE zcl_allocation_sink_sap.
    APPEND VALUE #( order_id                  = 'FINALIZED-RUN'
                    requested                 = '1'
                    allocated                 = '1'
                    allocation_status         = 'F'
                    reservation_id            = 'RES-FINALIZED-RUN'
                    reservation_date          = '20260101'
                    reservation_movement_type = '201'
                    reservation_unit          = 'EA' ) TO lt_demands.
    TRY.
        lo_cut->save_allocations(
          iv_material         = 'MATERIAL-FINALIZED-RUN'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_run_id           = 'RUN-FINALIZED-SNAPSHOT'
          iv_unit             = 'EA'
          it_demands          = lt_demands ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Allocation snapshot run is not active' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    DELETE FROM zstockalloc_run
      WHERE run_id = 'RUN-FINALIZED-SNAPSHOT'.
  ENDMETHOD.

  METHOD fallback_authority_messages.
    DATA lo_authority TYPE REF TO lcl_blank_result_authority.
    DATA lo_sink TYPE REF TO zif_allocation_sink.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_authority.
    CREATE OBJECT lo_sink TYPE zcl_allocation_sink_sap
      EXPORTING
        io_read_authority = lo_authority.
    TRY.
        lo_sink->get_allocations(
          iv_material         = 'MATERIAL-DB-FALLBACK'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
      CATCH zcx_stock_allocation INTO DATA(lo_read_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_read_error->message
          exp = 'Allocation result read authorization failed' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    APPEND VALUE #( order_id                  = 'FALLBACK'
                    requested                 = '1'
                    allocated                 = '1'
                    allocation_status         = 'F'
                    reservation_id            = 'RES-FALLBACK'
                    reservation_date          = '20260101'
                    reservation_movement_type = '201'
                    reservation_unit          = 'EA' ) TO lt_demands.
    CLEAR lv_raised.
    CREATE OBJECT lo_sink TYPE zcl_allocation_sink_sap
      EXPORTING
        io_write_authority = lo_authority.
    TRY.
        lo_sink->save_allocations(
          iv_material         = 'MATERIAL-DB-FALLBACK'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_run_id           = 'RUN-FALLBACK'
          iv_unit             = 'EA'
          it_demands          = lt_demands ).
      CATCH zcx_stock_allocation INTO DATA(lo_write_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_write_error->message
          exp = 'Allocation result write authorization failed' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD persists_allocation.
    DATA lo_cut TYPE REF TO zif_allocation_sink.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lv_order_id TYPE c LENGTH 20.
    DATA lv_reservation_id TYPE c LENGTH 20.
    DATA lv_allocation_status TYPE c LENGTH 1.
    DATA lv_sales_document TYPE c LENGTH 10.
    DATA lv_sales_document_type TYPE c LENGTH 4.
    DATA lv_sales_item TYPE n LENGTH 6.
    DATA lv_schedule_line TYPE n LENGTH 4.
    DATA lv_order_unit TYPE c LENGTH 3.
    DATA lv_reservation_unit TYPE c LENGTH 3.
    DATA lv_requested_on TYPE d.
    DATA lv_allocation_unit TYPE c LENGTH 3.
    DATA lv_priority TYPE i.
    DATA lv_batch TYPE c LENGTH 10.
    DATA lv_run_id TYPE c LENGTH 32.
    DATA lt_saved_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lt_guard_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lv_raised TYPE abap_bool.
    DATA lo_write_authority TYPE REF TO lcl_fail_result_write_auth.
    DATA lo_guarded_sink TYPE REF TO zif_allocation_sink.
    DATA ls_run TYPE zstockalloc_run.

    CREATE OBJECT lo_cut TYPE zcl_allocation_sink_sap.
    CREATE OBJECT lo_write_authority.
    CREATE OBJECT lo_guarded_sink TYPE zcl_allocation_sink_sap
      EXPORTING
        io_read_authority = lo_write_authority.
    TRY.
        lo_guarded_sink->get_allocations(
          iv_material         = 'MATERIAL-DB'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
      CATCH zcx_stock_allocation INTO DATA(lo_read_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_read_error->message
          exp = 'Result read authorization test failure' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.

    CREATE OBJECT lo_guarded_sink TYPE zcl_allocation_sink_sap
      EXPORTING
        io_write_authority = lo_write_authority.
    APPEND VALUE #( order_id                  = 'AUTHORITY'
                    requested                 = '1'
                    allocated                 = '1'
                    allocation_status         = 'F'
                    reservation_id            = 'RES-AUTHORITY'
                    reservation_date          = '20260101'
                    reservation_movement_type = '201'
                    reservation_unit          = 'EA' ) TO lt_guard_demands.
    TRY.
        lo_guarded_sink->save_allocations(
          iv_material         = 'MATERIAL-DB'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_run_id           = 'RUN-AUTHORITY'
          iv_unit             = 'EA'
          it_demands          = lt_guard_demands ).
      CATCH zcx_stock_allocation INTO DATA(lo_authority_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_authority_error->message
          exp = 'Result write authorization test failure' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.

    TRY.
        lt_saved_demands = lo_cut->get_allocations(
          iv_material         = ''
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
      CATCH zcx_stock_allocation INTO DATA(lo_scope_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_scope_error->message
          exp = 'Allocation snapshot scope is incomplete' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.

    APPEND VALUE #( order_id                  = 'STALE'
                    requested                 = '1'
                    allocated                 = '1'
                    allocation_status         = 'F'
                    reservation_id            = 'RES-STALE'
                    reservation_date          = '20260101'
                    reservation_movement_type = '201'
                    reservation_unit          = 'EA' ) TO lt_demands.
    ls_run-mandt = sy-mandt.
    ls_run-run_id = 'RUN-STALE'.
    ls_run-matnr = 'MATERIAL-DB'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0001'.
    ls_run-batch = 'BATCH-001'.
    ls_run-unit = 'EA'.
    ls_run-start_date = sy-datum.
    ls_run-start_time = sy-uzeit.
    ls_run-status = 'R'.
    ls_run-available = 1.
    ls_run-demand_count = 1.
    INSERT zstockalloc_run FROM @ls_run.
    lo_cut->save_allocations(
      iv_material         = 'MATERIAL-DB'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_batch            = 'BATCH-001'
      iv_run_id           = 'RUN-STALE'
      iv_unit             = 'EA'
      it_demands          = lt_demands ).

    CLEAR lt_demands.
    APPEND VALUE #( order_id                  = 'OTHER-LOC'
                    requested                 = '2'
                    allocated                 = '2'
                    allocation_status         = 'F'
                    reservation_id            = 'RES-OTHER'
                    reservation_date          = '20260101'
                    reservation_movement_type = '201'
                    reservation_unit          = 'EA' ) TO lt_demands.
    CLEAR ls_run.
    ls_run-mandt = sy-mandt.
    ls_run-run_id = 'RUN-OTHER'.
    ls_run-matnr = 'MATERIAL-DB'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0002'.
    ls_run-unit = 'EA'.
    ls_run-start_date = sy-datum.
    ls_run-start_time = sy-uzeit.
    ls_run-status = 'R'.
    ls_run-available = 2.
    ls_run-demand_count = 1.
    INSERT zstockalloc_run FROM @ls_run.
    lo_cut->save_allocations(
      iv_material         = 'MATERIAL-DB'
      iv_plant            = '1000'
      iv_storage_location = '0002'
      iv_run_id           = 'RUN-OTHER'
      iv_unit             = 'EA'
      it_demands          = lt_demands ).

    CLEAR lt_demands.
    APPEND VALUE #( sales_document            = 'ORDER-DB01'
                    sales_document_type       = 'OR'
                    sales_item                = '000010'
                    schedule_line             = '0001'
                    order_unit                = 'ea'
                    requested_on              = '20260115'
                    order_id                  = 'ORDER-DB'
                    priority                  = 42
                    requested                 = '5'
                    allocated                 = '4'
                    shortage                  = '1'
                    allocation_status         = 'P'
                    reservation_id            = 'RES-DB'
                    reservation_date          = '20260101'
                    reservation_movement_type = '201'
                    reservation_unit          = 'EA' ) TO lt_demands.
    APPEND VALUE #( sales_document            = 'ORDER-DB01'
                    sales_document_type       = 'OR'
                    sales_item                = '000020'
                    schedule_line             = '0001'
                    order_unit                = 'ea'
                    requested_on              = '20260116'
                    order_id                  = 'ORDER-DB-2'
                    priority                  = 43
                    requested                 = '1'
                    allocated                 = '1'
                    allocation_status         = 'F'
                    reservation_id            = 'RES-DB-2'
                    reservation_date          = '20260101'
                    reservation_movement_type = '201'
                    reservation_unit          = 'EA' ) TO lt_demands.

    CLEAR ls_run.
    ls_run-mandt = sy-mandt.
    ls_run-run_id = 'RUN-DB'.
    ls_run-matnr = 'MATERIAL-DB'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0001'.
    ls_run-batch = 'BATCH-001'.
    ls_run-unit = 'EA'.
    ls_run-start_date = sy-datum.
    ls_run-start_time = sy-uzeit.
    ls_run-status = 'R'.
    ls_run-available = 6.
    ls_run-demand_count = 2.
    ls_run-requested_on_from = '20260101'.
    ls_run-requested_on_to = '20260131'.
    INSERT zstockalloc_run FROM @ls_run.

    lo_cut->save_allocations(
      iv_material         = 'MATERIAL-DB'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_batch            = 'BATCH-001'
      iv_run_id           = 'RUN-DB'
      iv_unit             = 'ea'
      it_demands          = lt_demands ).

    SELECT SINGLE run_id, batch, allocation_unit, priority, sales_document, sales_document_type,
                  sales_item, schedule_line, order_unit, reservation_unit, requested_on,
      order_id, reservation_id, allocation_status
      FROM zstockalloc
      INTO (@lv_run_id, @lv_batch, @lv_allocation_unit, @lv_priority, @lv_sales_document, @lv_sales_document_type,
            @lv_sales_item, @lv_schedule_line, @lv_order_unit, @lv_reservation_unit, @lv_requested_on,
            @lv_order_id, @lv_reservation_id, @lv_allocation_status)
      WHERE matnr = 'MATERIAL-DB'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-001'
        AND order_id = 'ORDER-DB'.

    cl_abap_unit_assert=>assert_equals(
      act = lv_run_id
      exp = 'RUN-DB' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_batch
      exp = 'BATCH-001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_allocation_unit
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_priority
      exp = 42 ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_order_unit
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_reservation_unit
      exp = 'EA' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_order_id
      exp = 'ORDER-DB' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_sales_document
      exp = 'ORDER-DB01' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_sales_document_type
      exp = 'OR' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_sales_item
      exp = '000010' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_schedule_line
      exp = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_order_unit
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_requested_on
      exp = '20260115' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_reservation_id
      exp = 'RES-DB' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_allocation_status
      exp = 'P' ).

    TRY.
        lt_saved_demands = lo_cut->get_allocations(
          iv_material         = 'MATERIAL-DB'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_batch            = 'BATCH-001'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_initial_read_error).
        cl_abap_unit_assert=>fail( msg = lo_initial_read_error->message ).
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      act = lt_saved_demands[ 1 ]-allocation_run_id
      exp = 'RUN-DB' ).

    CLEAR lt_demands.
    APPEND VALUE #( order_id                  = 'ORDER-DB'
                    requested                 = '3'
                    allocated                 = '3'
                    allocation_status         = 'F'
                    reservation_id            = 'RES-BOX'
                    reservation_date          = '20260101'
                    reservation_movement_type = '201'
                    reservation_unit          = 'BOX' ) TO lt_demands.
    CLEAR ls_run.
    ls_run-mandt = sy-mandt.
    ls_run-run_id = 'RUN-BOX'.
    ls_run-matnr = 'MATERIAL-DB'.
    ls_run-werks = '1000'.
    ls_run-lgort = '0001'.
    ls_run-batch = 'BATCH-001'.
    ls_run-unit = 'BOX'.
    ls_run-start_date = sy-datum.
    ls_run-start_time = sy-uzeit.
    ls_run-status = 'R'.
    ls_run-available = 3.
    ls_run-demand_count = 1.
    INSERT zstockalloc_run FROM @ls_run.
    lo_cut->save_allocations(
      iv_material         = 'MATERIAL-DB'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_batch            = 'BATCH-001'
      iv_run_id           = 'RUN-BOX'
      iv_unit             = 'BOX'
      it_demands          = lt_demands ).

    SELECT COUNT( * )
      FROM zstockalloc
      INTO @DATA(lv_unit_count)
      WHERE matnr = 'MATERIAL-DB'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-001'
        AND order_id = 'ORDER-DB'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_unit_count
      exp = 2 ).

    SELECT COUNT( * )
      FROM zstockalloc
      INTO @DATA(lv_stale_count)
      WHERE matnr = 'MATERIAL-DB'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-001'
        AND order_id = 'STALE'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_stale_count
      exp = 0 ).

    SELECT COUNT( * )
      FROM zstockalloc
      INTO @DATA(lv_other_location_count)
      WHERE matnr = 'MATERIAL-DB'
        AND werks = '1000'
        AND lgort = '0002'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_other_location_count
      exp = 1 ).

    TRY.
        lt_saved_demands = lo_cut->get_allocations(
          iv_material         = 'MATERIAL-DB'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_batch            = 'BATCH-001' ).
      CATCH zcx_stock_allocation INTO DATA(lo_combined_read_error).
        cl_abap_unit_assert=>fail( msg = lo_combined_read_error->message ).
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_saved_demands )
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_saved_demands[ allocation_unit = 'BOX' ]-allocated
      exp = '3' ).

    CLEAR lt_demands.
    APPEND VALUE #( order_id          = 'INVALID-QUANTITY'
                    requested         = '0'
                    allocation_status = 'F' ) TO lt_demands.
    TRY.
        lo_cut->save_allocations(
          iv_material         = 'MATERIAL-DB'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_batch            = 'BATCH-001'
          iv_run_id           = 'RUN-INVALID-QUANTITY'
          iv_unit             = 'EA'
          it_demands          = lt_demands ).
      CATCH zcx_stock_allocation INTO DATA(lo_quantity_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_quantity_error->message
          exp = 'Allocation snapshot demand is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.

    CLEAR lt_demands.
    APPEND VALUE #( order_id          = 'INVALID-STATUS'
                    requested         = '1'
                    allocation_status = 'X' ) TO lt_demands.
    TRY.
        lo_cut->save_allocations(
          iv_material         = 'MATERIAL-DB'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_batch            = 'BATCH-001'
          iv_run_id           = 'RUN-INVALID-STATUS'
          iv_unit             = 'EA'
          it_demands          = lt_demands ).
      CATCH zcx_stock_allocation INTO DATA(lo_status_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_status_error->message
          exp = 'Allocation snapshot demand is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.

    CLEAR lt_demands.
    APPEND VALUE #( order_id          = 'INCONSISTENT'
                    requested         = '5'
                    allocated         = '4'
                    shortage          = '0'
                    allocation_status = 'P' ) TO lt_demands.
    TRY.
        lo_cut->save_allocations(
          iv_material         = 'MATERIAL-DB'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_batch            = 'BATCH-001'
          iv_run_id           = 'RUN-INCONSISTENT'
          iv_unit             = 'EA'
          it_demands          = lt_demands ).
      CATCH zcx_stock_allocation INTO DATA(lo_consistency_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_consistency_error->message
          exp = 'Allocation snapshot demand is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.

    CLEAR lt_demands.
    APPEND VALUE #( order_id                  = 'DUPLICATE'
                    requested                 = '1'
                    allocated                 = '1'
                    allocation_status         = 'F'
                    reservation_id            = 'RES-DUPLICATE-1'
                    reservation_date          = '20260101'
                    reservation_movement_type = '201'
                    reservation_unit          = 'EA' ) TO lt_demands.
    APPEND VALUE #( order_id                  = 'DUPLICATE'
                    requested                 = '1'
                    allocated                 = '1'
                    allocation_status         = 'F'
                    reservation_id            = 'RES-DUPLICATE-2'
                    reservation_date          = '20260101'
                    reservation_movement_type = '201'
                    reservation_unit          = 'EA' ) TO lt_demands.
    TRY.
        lo_cut->save_allocations(
          iv_material         = 'MATERIAL-DB'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_batch            = 'BATCH-001'
          iv_run_id           = 'RUN-DUPLICATE'
          iv_unit             = 'EA'
          it_demands          = lt_demands ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Allocation snapshot contains duplicate demand keys' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT COUNT( * )
      FROM zstockalloc
      INTO @DATA(lv_ea_count)
      WHERE matnr = 'MATERIAL-DB'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-001'
        AND allocation_unit = 'EA'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_ea_count
      exp = 2 ).
  ENDMETHOD.

  METHOD rejects_invalid_movement_type.
    DATA lo_cut TYPE REF TO zif_allocation_sink.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    APPEND VALUE #( order_id                  = 'INVALID-MVT'
                    requested                 = '1'
                    allocated                 = '1'
                    shortage                  = '0'
                    allocation_status         = 'F'
                    reservation_id            = 'RES-INVALID'
                    reservation_date          = '20260101'
                    reservation_movement_type = '2A1'
                    reservation_unit          = 'ea' ) TO lt_demands.
    CREATE OBJECT lo_cut TYPE zcl_allocation_sink_sap.
    TRY.
        lo_cut->save_allocations(
          iv_material         = 'MATERIAL-DB'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_run_id           = 'RUN-INVALID-MVT'
          iv_unit             = 'EA'
          it_demands          = lt_demands ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Allocation snapshot demand is invalid' ).
  ENDMETHOD.
ENDCLASS.
