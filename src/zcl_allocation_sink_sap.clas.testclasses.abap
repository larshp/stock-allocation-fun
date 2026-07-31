CLASS lcl_failing_result_write_authority DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_read_authority.
    INTERFACES zif_allocation_write_authority.
ENDCLASS.

CLASS lcl_failing_result_write_authority IMPLEMENTATION.
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
    METHODS persists_allocation FOR TESTING.
    METHODS fallback_authority_messages FOR TESTING.
    METHODS rejects_missing_reservation FOR TESTING.
    METHODS rejects_corrupt_read FOR TESTING.
    METHODS rejects_mixed_run_read FOR TESTING.
    METHODS rejects_unknown_run FOR TESTING.
    METHODS rejects_inconsistent_run FOR TESTING.
    METHODS rejects_finalized_run FOR TESTING.
ENDCLASS.

CLASS ltcl_allocation_sink_sap IMPLEMENTATION.
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
      WHERE mandt = @sy-mandt
        AND matnr = 'MATERIAL-CORRUPT'
        AND werks = '1000'
        AND lgort = '0001'.
  ENDMETHOD.

  METHOD rejects_mixed_run_read.
    DATA lo_cut TYPE REF TO zif_allocation_sink.
    DATA ls_first TYPE zstockalloc.
    DATA ls_second TYPE zstockalloc.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_cut TYPE zcl_allocation_sink_sap.
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
      WHERE mandt = @sy-mandt
        AND matnr = 'MATERIAL-MIXED-RUN'
        AND werks = '1000'
        AND lgort = '0001'.

    ls_first-run_id = 'RUN-DUPLICATE'.
    ls_first-order_id = 'DUPLICATE-ONE'.
    ls_first-reservation_id = 'RES-DUPLICATE'.
    ls_second = ls_first.
    ls_second-order_id = 'DUPLICATE-TWO'.
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
      WHERE mandt = @sy-mandt
        AND matnr = 'MATERIAL-MIXED-RUN'
        AND werks = '1000'
        AND lgort = '0001'.

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
      WHERE mandt = @sy-mandt
        AND run_id = 'RUN-INCONSISTENT-SCOPE'.
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
      WHERE mandt = @sy-mandt
        AND run_id = 'RUN-FINALIZED-SNAPSHOT'.
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
    DATA lv_allocation_unit TYPE c LENGTH 3.
    DATA lv_batch TYPE c LENGTH 10.
    DATA lv_run_id TYPE c LENGTH 32.
    DATA lt_saved_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lt_guard_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lv_raised TYPE abap_bool.
    DATA lo_write_authority TYPE REF TO lcl_failing_result_write_authority.
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
                    order_unit                = 'EA'
                    order_id                  = 'ORDER-DB'
                    requested                 = '5'
                    allocated                 = '4'
                    shortage                  = '1'
                    allocation_status         = 'P'
                    reservation_id            = 'RES-DB'
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
    ls_run-available = 5.
    ls_run-demand_count = 1.
    INSERT zstockalloc_run FROM @ls_run.

    lo_cut->save_allocations(
      iv_material         = 'MATERIAL-DB'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_batch            = 'BATCH-001'
      iv_run_id           = 'RUN-DB'
      iv_unit             = 'EA'
      it_demands          = lt_demands ).

    SELECT SINGLE run_id, batch, allocation_unit, sales_document, sales_document_type,
                  sales_item, schedule_line, order_unit,
                  order_id, reservation_id, allocation_status
      FROM zstockalloc
      INTO (@lv_run_id, @lv_batch, @lv_allocation_unit, @lv_sales_document, @lv_sales_document_type,
            @lv_sales_item, @lv_schedule_line, @lv_order_unit,
            @lv_order_id, @lv_reservation_id, @lv_allocation_status)
      WHERE matnr = 'MATERIAL-DB'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-001'.

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
      act = lv_reservation_id
      exp = 'RES-DB' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_allocation_status
      exp = 'P' ).

    lt_saved_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-DB'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_batch            = 'BATCH-001'
      iv_unit             = 'EA' ).
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
      WHERE mandt = @sy-mandt
        AND matnr = 'MATERIAL-DB'
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
      WHERE mandt = @sy-mandt
        AND matnr = 'MATERIAL-DB'
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
      WHERE mandt = @sy-mandt
        AND matnr = 'MATERIAL-DB'
        AND werks = '1000'
        AND lgort = '0002'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_other_location_count
      exp = 1 ).

    lt_saved_demands = lo_cut->get_allocations(
      iv_material         = 'MATERIAL-DB'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_batch            = 'BATCH-001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_saved_demands )
      exp = 2 ).
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
      WHERE mandt = @sy-mandt
        AND matnr = 'MATERIAL-DB'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-001'
        AND allocation_unit = 'EA'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_ea_count
      exp = 1 ).
  ENDMETHOD.
ENDCLASS.
