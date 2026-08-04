CLASS ltcl_stock_alloc_service_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS allocates_sap_vertical_slice FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS allocates_batch_slice FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS previews_without_writes FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_bad_date_window FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_invalid_strategy FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_invalid_preview FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_invalid_movement_type FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_missing_material FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_order_source FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_stock_conversion FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_demand_conversion FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_reservation_failure FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_missing_base_unit FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_missing_batch FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_unknown_batch FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_non_batch_material FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_expired_batch FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_delivery_expiry FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_restricted_batch FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_short_shelf_life FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_transaction_failure FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS records_incomplete_cleanup FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_result_delete_auth FOR TESTING
      RAISING zcx_stock_allocation.
ENDCLASS.

CLASS lcl_fail_alloc_transaction DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_transaction.
    METHODS get_rollback_calls
      RETURNING VALUE(rv_calls) TYPE i.
  PRIVATE SECTION.
    DATA mv_commit_calls TYPE i.
    DATA mv_rollback_calls TYPE i.
ENDCLASS.

CLASS lcl_fail_alloc_transaction IMPLEMENTATION.
  METHOD zif_allocation_transaction~commit.
    mv_commit_calls = mv_commit_calls + 1.
    IF mv_commit_calls <> 2.
      RETURN.
    ENDIF.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = 'Allocation transaction test failure'.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.

  METHOD zif_allocation_transaction~rollback.
    mv_rollback_calls = mv_rollback_calls + 1.
  ENDMETHOD.

  METHOD get_rollback_calls.
    rv_calls = mv_rollback_calls.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_cleanup_fail_reservation DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_reservation.
  PRIVATE SECTION.
    DATA mv_reserve_calls TYPE i.
ENDCLASS.

CLASS lcl_cleanup_fail_reservation IMPLEMENTATION.
  METHOD zif_stock_reservation~reserve.
    DATA lo_error TYPE REF TO zcx_stock_allocation.

    mv_reserve_calls = mv_reserve_calls + 1.
    IF mv_reserve_calls = 1.
      rv_document = 'RES-CLEANUP-FAIL'.
      RETURN.
    ENDIF.
    CREATE OBJECT lo_error.
    lo_error->message = 'Reservation test failure after first document'.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.

  METHOD zif_stock_reservation~cancel.
    DATA lo_error TYPE REF TO zcx_stock_allocation.

    CREATE OBJECT lo_error.
    lo_error->message = 'Reservation cleanup test failure'.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_fail_result_delete_auth DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_write_authority.
ENDCLASS.

CLASS lcl_fail_result_delete_auth IMPLEMENTATION.
  METHOD zif_allocation_write_authority~check_audit_write.
  ENDMETHOD.

  METHOD zif_allocation_write_authority~check_result_write.
  ENDMETHOD.

  METHOD zif_allocation_write_authority~check_result_delete.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = 'Result delete authorization test failure'.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_stock_alloc_service_sap IMPLEMENTATION.
  METHOD rejects_bad_date_window.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_persisted_movement_type TYPE zif_stock_allocation=>ty_movement_type.
    DATA lv_persisted_min_shelf_life TYPE i.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE zcl_order_source_sap.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_allocator    = lo_allocator
        io_audit        = lo_audit.
    TRY.
        lo_cut->allocate(
          iv_material          = 'MATERIAL-PRIO'
          iv_plant             = '1000'
          iv_storage_location  = '0001'
          iv_movement_type     = '201'
          iv_unit              = 'EA'
          iv_min_shelf_life    = 7
          iv_requested_on_from = '20260820'
          iv_requested_on_to   = '20260815' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Requested delivery date range is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT SINGLE movement_type, min_shelf_life
      FROM zstockalloc_run
      INTO (@lv_persisted_movement_type, @lv_persisted_min_shelf_life)
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND requested_on_from = '20260820'
        AND requested_on_to = '20260815'
        AND status = 'E'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_persisted_movement_type
      exp = '201' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_persisted_min_shelf_life
      exp = 7 ).
    DELETE FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'.
  ENDMETHOD.

  METHOD rejects_invalid_strategy.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_run_count TYPE i.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_message TYPE zif_allocation_audit=>ty_message.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE zcl_order_source_sap.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_allocator    = lo_allocator
        io_audit        = lo_audit.
    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-PRIO'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA'
          iv_strategy         = 'X' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Invalid allocation strategy' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT COUNT( * )
      FROM zstockalloc_run
      INTO @lv_run_count
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_run_count
      exp = 1 ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      INTO (@lv_status, @lv_message)
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Invalid allocation strategy' ).
    DELETE FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'.
  ENDMETHOD.

  METHOD rejects_invalid_preview.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_run_count TYPE i.
    DATA lv_message TYPE zif_allocation_audit=>ty_message.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE zcl_order_source_sap.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_allocator    = lo_allocator
        io_audit        = lo_audit.
    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-PRIO'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA'
          iv_preview          = 'Y' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Invalid preview flag' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT COUNT( * )
      FROM zstockalloc_run
      INTO @lv_run_count
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_run_count
      exp = 1 ).
    SELECT SINGLE message
      FROM zstockalloc_run
      INTO @lv_message
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Invalid preview flag' ).
    DELETE FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'.
  ENDMETHOD.

  METHOD rejects_invalid_movement_type.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_run_count TYPE i.
    DATA lv_persisted_movement_type TYPE zif_stock_allocation=>ty_movement_type.
    DATA lv_message TYPE zif_allocation_audit=>ty_message.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE zcl_order_source_sap.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_allocator    = lo_allocator
        io_audit        = lo_audit.
    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-PRIO'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '2A1'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Invalid movement type' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT COUNT( * )
      FROM zstockalloc_run
      INTO @lv_run_count
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_run_count
      exp = 1 ).
    SELECT SINGLE movement_type, message
      FROM zstockalloc_run
      INTO (@lv_persisted_movement_type, @lv_message)
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Invalid movement type' ).
    cl_abap_unit_assert=>assert_initial( lv_persisted_movement_type ).
    DELETE FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'.
  ENDMETHOD.

  METHOD allocates_sap_vertical_slice.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_sink TYPE REF TO zif_allocation_sink.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_reservation TYPE REF TO zif_stock_reservation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_remaining TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_allocation_count TYPE i.
    DATA lv_reservation_id TYPE zif_stock_allocation=>ty_order_id.
    DATA lv_second_reservation_id TYPE zif_stock_allocation=>ty_order_id.
    DATA lv_rerun_reservation_id TYPE zif_stock_allocation=>ty_order_id.
    DATA lv_rerun_second_reservation_id TYPE zif_stock_allocation=>ty_order_id.
    DATA lv_changed_reservation_id TYPE zif_stock_allocation=>ty_order_id.
    DATA lv_changed_second_id TYPE zif_stock_allocation=>ty_order_id.
    DATA lv_reservations_differ TYPE abap_bool.
    DATA lv_run_count TYPE i.
    DATA lv_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_persisted_movement_type TYPE zif_stock_allocation=>ty_movement_type.
    DATA lv_persisted_min_shelf_life TYPE i.
    DATA lv_persisted_strategy TYPE zif_allocation_audit=>ty_strategy.
    DATA lv_persisted_unit TYPE zif_stock_allocation=>ty_unit.
    DATA lv_persisted_allocation_unit TYPE zif_stock_allocation=>ty_unit.
    DATA lv_full_count TYPE i.
    DATA lv_partial_count TYPE i.
    DATA lv_unallocated_count TYPE i.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE zcl_order_source_sap.
    CREATE OBJECT lo_sink TYPE zcl_allocation_sink_sap.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_reservation TYPE zcl_stock_reservation_sap.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_reservation  = lo_reservation
        io_audit        = lo_audit.

    lv_remaining = lo_cut->allocate(
      EXPORTING
        iv_material         = 'MATERIAL-PRIO'
        iv_plant            = '1000'
        iv_storage_location = '0001'
        iv_movement_type    = '201'
        iv_unit             = 'ea'
        iv_strategy         = 'l'
       IMPORTING
        ev_run_id           = lv_run_id ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_remaining
      exp = '0' ).
    cl_abap_unit_assert=>assert_not_initial( lv_run_id ).
    SELECT SINGLE movement_type, min_shelf_life, strategy
      FROM zstockalloc_run
      INTO ( @lv_persisted_movement_type,
             @lv_persisted_min_shelf_life,
             @lv_persisted_strategy )
      WHERE run_id = @lv_run_id.
    cl_abap_unit_assert=>assert_equals(
      act = lv_persisted_movement_type
      exp = '201' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_persisted_min_shelf_life
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_persisted_strategy
      exp = 'L' ).
    SELECT SINGLE unit
      FROM zstockalloc_run
      INTO @lv_persisted_unit
      WHERE run_id = @lv_run_id.
    cl_abap_unit_assert=>assert_equals(
      act = lv_persisted_unit
      exp = 'EA' ).
    SELECT SINGLE allocation_unit
      FROM zstockalloc
      INTO @lv_persisted_allocation_unit
      WHERE run_id = @lv_run_id.
    cl_abap_unit_assert=>assert_equals(
      act = lv_persisted_allocation_unit
      exp = 'EA' ).

    SELECT COUNT( * )
      FROM zstockalloc
      INTO @lv_allocation_count
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_allocation_count
      exp = 2 ).

    SELECT SINGLE reservation_id
      FROM zstockalloc
      INTO @lv_reservation_id
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND order_id = 'PRIO0000010000100001'.
    cl_abap_unit_assert=>assert_not_initial( lv_reservation_id ).
    SELECT SINGLE reservation_id
      FROM zstockalloc
      INTO @lv_second_reservation_id
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND order_id = 'PRIO0000010000100002'.
    cl_abap_unit_assert=>assert_not_initial( lv_second_reservation_id ).
    IF lv_reservation_id <> lv_second_reservation_id.
      lv_reservations_differ = abap_true.
    ENDIF.
    cl_abap_unit_assert=>assert_true( lv_reservations_differ ).

    lv_remaining = lo_cut->allocate(
      iv_material         = 'MATERIAL-PRIO'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_movement_type    = '201'
      iv_unit             = 'EA' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_remaining
      exp = '0' ).
    SELECT SINGLE reservation_id
      FROM zstockalloc
      INTO @lv_rerun_reservation_id
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND order_id = 'PRIO0000010000100001'.
    SELECT SINGLE reservation_id
      FROM zstockalloc
      INTO @lv_rerun_second_reservation_id
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND order_id = 'PRIO0000010000100002'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_rerun_reservation_id
      exp = lv_reservation_id ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_rerun_second_reservation_id
      exp = lv_second_reservation_id ).

    lv_remaining = lo_cut->allocate(
      iv_material         = 'MATERIAL-PRIO'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_movement_type    = '202'
      iv_unit             = 'EA' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_remaining
      exp = '0' ).
    SELECT SINGLE reservation_id
      FROM zstockalloc
      INTO @lv_changed_reservation_id
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND order_id = 'PRIO0000010000100001'.
    SELECT SINGLE reservation_id
      FROM zstockalloc
      INTO @lv_changed_second_id
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND order_id = 'PRIO0000010000100002'.
    IF lv_changed_reservation_id = lv_reservation_id
        OR lv_changed_second_id = lv_second_reservation_id.
      lv_reservations_differ = abap_false.
    ELSE.
      lv_reservations_differ = abap_true.
    ENDIF.
    cl_abap_unit_assert=>assert_true( lv_reservations_differ ).

    SELECT COUNT( * )
      FROM zstockalloc_run
      INTO @lv_run_count
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND status = 'P'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_run_count
      exp = 3 ).

    SELECT SUM( full_count ), SUM( partial_count ), SUM( unallocated_count )
      FROM zstockalloc_run
      INTO (@lv_full_count, @lv_partial_count, @lv_unallocated_count)
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND status = 'P'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_full_count
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_partial_count
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_unallocated_count
      exp = 0 ).
  ENDMETHOD.

  METHOD allocates_batch_slice.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_sink TYPE REF TO zif_allocation_sink.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_reservation TYPE REF TO zif_stock_reservation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_remaining TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_allocation_count TYPE i.
    DATA lv_batch TYPE zif_stock_allocation=>ty_batch.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE zcl_order_source_sap.
    CREATE OBJECT lo_sink TYPE zcl_allocation_sink_sap.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_reservation TYPE zcl_stock_reservation_sap.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_reservation  = lo_reservation
        io_audit        = lo_audit.

    lv_remaining = lo_cut->allocate(
      iv_material         = 'MATERIAL-BATCH-PRIO'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_movement_type    = '201'
      iv_unit             = 'EA'
      iv_batch            = 'BATCH-001' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_remaining
      exp = '0' ).
    SELECT COUNT( * )
      FROM zstockalloc
      INTO @lv_allocation_count
      WHERE matnr = 'MATERIAL-BATCH-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-001'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_allocation_count
      exp = 1 ).
    SELECT SINGLE batch
      FROM zstockalloc
      INTO @lv_batch
      WHERE matnr = 'MATERIAL-BATCH-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-001'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_batch
      exp = 'BATCH-001' ).
  ENDMETHOD.

  METHOD previews_without_writes.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_remaining TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_before_count TYPE i.
    DATA lv_after_count TYPE i.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE zcl_order_source_sap.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_allocator    = lo_allocator
        io_audit        = lo_audit.

    SELECT COUNT( * )
      FROM zstockalloc
      INTO @lv_before_count
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND allocation_unit = 'EA'.

    lv_remaining = lo_cut->allocate(
      iv_material         = 'MATERIAL-PRIO'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_movement_type    = '201'
      iv_unit             = 'EA'
      iv_preview          = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_remaining
      exp = '0' ).
    SELECT COUNT( * )
      FROM zstockalloc
      INTO @lv_after_count
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND allocation_unit = 'EA'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_after_count
      exp = lv_before_count ).
  ENDMETHOD.

  METHOD rejects_missing_material.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_sink TYPE REF TO zif_allocation_sink.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_reservation TYPE REF TO zif_stock_reservation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_message TYPE zif_allocation_audit=>ty_message.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE zcl_order_source_sap.
    CREATE OBJECT lo_sink TYPE zcl_allocation_sink_sap.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_reservation TYPE zcl_stock_reservation_sap.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_reservation  = lo_reservation
        io_audit        = lo_audit.

    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-MISSING'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      INTO (@lv_status, @lv_message)
      WHERE matnr = 'MATERIAL-MISSING'
        AND werks = '1000'
        AND lgort = '0001'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Material does not exist' ).
  ENDMETHOD.

  METHOD rejects_order_source.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_sink TYPE REF TO zif_allocation_sink.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_reservation TYPE REF TO zif_stock_reservation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_message TYPE zif_allocation_audit=>ty_message.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE zcl_order_source_sap.
    CREATE OBJECT lo_sink TYPE zcl_allocation_sink_sap.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_reservation TYPE zcl_stock_reservation_sap.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_reservation  = lo_reservation
        io_audit        = lo_audit.

    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-NO-UNIT'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      INTO (@lv_status, @lv_message)
      WHERE matnr = 'MATERIAL-NO-UNIT'
        AND werks = '1000'
        AND lgort = '0001'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Open demand unit is missing' ).
  ENDMETHOD.

  METHOD rejects_stock_conversion.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_sink TYPE REF TO zif_allocation_sink.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_reservation TYPE REF TO zif_stock_reservation.
    DATA lo_unit_converter TYPE REF TO zif_unit_conversion.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_message TYPE zif_allocation_audit=>ty_message.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE zcl_order_source_sap.
    CREATE OBJECT lo_sink TYPE zcl_allocation_sink_sap.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_reservation TYPE zcl_stock_reservation_sap.
    CREATE OBJECT lo_unit_converter TYPE zcl_unit_conversion_sap.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source   = lo_stock_source
        io_order_source   = lo_order_source
        io_sink           = lo_sink
        io_allocator      = lo_allocator
        io_reservation    = lo_reservation
        io_unit_converter = lo_unit_converter
        io_audit          = lo_audit.

    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-PRIO'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'BOX' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      INTO (@lv_status, @lv_message)
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'BOX'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Unit conversion failed' ).
  ENDMETHOD.

  METHOD rejects_demand_conversion.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_sink TYPE REF TO zif_allocation_sink.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_reservation TYPE REF TO zif_stock_reservation.
    DATA lo_unit_converter TYPE REF TO zif_unit_conversion.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_allocation_count TYPE i.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_message TYPE zif_allocation_audit=>ty_message.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE zcl_order_source_sap.
    CREATE OBJECT lo_sink TYPE zcl_allocation_sink_sap.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_reservation TYPE zcl_stock_reservation_sap.
    CREATE OBJECT lo_unit_converter TYPE zcl_unit_conversion_sap.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source   = lo_stock_source
        io_order_source   = lo_order_source
        io_sink           = lo_sink
        io_allocator      = lo_allocator
        io_reservation    = lo_reservation
        io_unit_converter = lo_unit_converter
        io_audit          = lo_audit.

    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-DEMAND-FAIL'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT COUNT( * )
      FROM zstockalloc
      INTO @lv_allocation_count
      WHERE matnr = 'MATERIAL-DEMAND-FAIL'
        AND werks = '1000'
        AND lgort = '0001'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_allocation_count
      exp = 0 ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      INTO (@lv_status, @lv_message)
      WHERE matnr = 'MATERIAL-DEMAND-FAIL'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Unit conversion failed' ).
  ENDMETHOD.

  METHOD rejects_reservation_failure.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_sink TYPE REF TO zif_allocation_sink.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_reservation TYPE REF TO zif_stock_reservation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_allocation_count TYPE i.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_message TYPE zif_allocation_audit=>ty_message.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE zcl_order_source_sap.
    CREATE OBJECT lo_sink TYPE zcl_allocation_sink_sap.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_reservation TYPE zcl_stock_reservation_sap.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_reservation  = lo_reservation
        io_audit        = lo_audit.

    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-ERROR'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT COUNT( * )
      FROM zstockalloc
      INTO @lv_allocation_count
      WHERE matnr = 'MATERIAL-ERROR'
        AND werks = '1000'
        AND lgort = '0001'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_allocation_count
      exp = 0 ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      INTO (@lv_status, @lv_message)
      WHERE matnr = 'MATERIAL-ERROR'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Reservation rejected by test double' ).
  ENDMETHOD.

  METHOD rejects_missing_base_unit.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_sink TYPE REF TO zif_allocation_sink.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_reservation TYPE REF TO zif_stock_reservation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE zcl_order_source_sap.
    CREATE OBJECT lo_sink TYPE zcl_allocation_sink_sap.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_reservation TYPE zcl_stock_reservation_sap.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_reservation  = lo_reservation
        io_audit        = lo_audit.

    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-NO-BASE'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD rejects_missing_batch.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_sink TYPE REF TO zif_allocation_sink.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_reservation TYPE REF TO zif_stock_reservation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE zcl_order_source_sap.
    CREATE OBJECT lo_sink TYPE zcl_allocation_sink_sap.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_reservation TYPE zcl_stock_reservation_sap.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_reservation  = lo_reservation
        io_audit        = lo_audit.

    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-BATCH'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD rejects_expired_batch.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_sink TYPE REF TO zif_allocation_sink.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_reservation TYPE REF TO zif_stock_reservation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE zcl_order_source_sap.
    CREATE OBJECT lo_sink TYPE zcl_allocation_sink_sap.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_reservation TYPE zcl_stock_reservation_sap.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_reservation  = lo_reservation
        io_audit        = lo_audit.

    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-EXPIRED'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA'
          iv_batch            = 'EXPIRED-01' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD rejects_unknown_batch.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_sink TYPE REF TO zif_allocation_sink.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_reservation TYPE REF TO zif_stock_reservation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE zcl_order_source_sap.
    CREATE OBJECT lo_sink TYPE zcl_allocation_sink_sap.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_reservation TYPE zcl_stock_reservation_sap.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_reservation  = lo_reservation
        io_audit        = lo_audit.

    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-BATCH'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA'
          iv_batch            = 'UNKNOWN-01' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD rejects_non_batch_material.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_sink TYPE REF TO zif_allocation_sink.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_reservation TYPE REF TO zif_stock_reservation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE zcl_order_source_sap.
    CREATE OBJECT lo_sink TYPE zcl_allocation_sink_sap.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_reservation TYPE zcl_stock_reservation_sap.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_reservation  = lo_reservation
        io_audit        = lo_audit.

    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-STOCK'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA'
          iv_batch            = 'BATCH-001' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD rejects_restricted_batch.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_sink TYPE REF TO zif_allocation_sink.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_reservation TYPE REF TO zif_stock_reservation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE zcl_order_source_sap.
    CREATE OBJECT lo_sink TYPE zcl_allocation_sink_sap.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_reservation TYPE zcl_stock_reservation_sap.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_reservation  = lo_reservation
        io_audit        = lo_audit.

    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-RESTRICTED'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA'
          iv_batch            = 'BLOCKED-01' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD rejects_delivery_expiry.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_sink TYPE REF TO zif_allocation_sink.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_reservation TYPE REF TO zif_stock_reservation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE zcl_order_source_sap.
    CREATE OBJECT lo_sink TYPE zcl_allocation_sink_sap.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_reservation TYPE zcl_stock_reservation_sap.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_reservation  = lo_reservation
        io_audit        = lo_audit.

    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-EXPIRING'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA'
          iv_batch            = 'EXPIRE-01' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD rejects_short_shelf_life.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_sink TYPE REF TO zif_allocation_sink.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_reservation TYPE REF TO zif_stock_reservation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE zcl_order_source_sap.
    CREATE OBJECT lo_sink TYPE zcl_allocation_sink_sap.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_reservation TYPE zcl_stock_reservation_sap.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_reservation  = lo_reservation
        io_audit        = lo_audit.

    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-BATCH'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA'
          iv_batch            = 'BATCH-001'
          iv_min_shelf_life   = 200 ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD rejects_transaction_failure.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_sink TYPE REF TO zif_allocation_sink.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_reservation TYPE REF TO zif_stock_reservation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_transaction TYPE REF TO lcl_fail_alloc_transaction.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE zif_allocation_audit=>ty_message.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_rollback_calls TYPE i.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE zcl_order_source_sap.
    CREATE OBJECT lo_sink TYPE zcl_allocation_sink_sap.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_reservation TYPE zcl_stock_reservation_sap.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_transaction TYPE lcl_fail_alloc_transaction.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_reservation  = lo_reservation
        io_transaction  = lo_transaction
        io_audit        = lo_audit.

    TRY.
        lo_cut->allocate(
          EXPORTING
            iv_material         = 'MATERIAL-TXN-FAIL'
            iv_plant            = '1000'
            iv_storage_location = '0001'
            iv_movement_type    = '201'
            iv_unit             = 'EA'
          IMPORTING
            ev_run_id           = lv_run_id ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_not_initial( lv_run_id ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Allocation result was not persisted: Allocation transaction test failure' ).
    lv_rollback_calls = lo_transaction->get_rollback_calls( ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_rollback_calls
      exp = 1 ).
    SELECT SINGLE status
      FROM zstockalloc_run
      INTO @lv_status
      WHERE run_id = @lv_run_id.
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    DELETE FROM zstockalloc
      WHERE allocation_run_id = @lv_run_id.
    DELETE FROM zstockalloc_run
      WHERE run_id = @lv_run_id.
  ENDMETHOD.

  METHOD records_incomplete_cleanup.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_sink TYPE REF TO zif_allocation_sink.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_reservation TYPE REF TO zif_stock_reservation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_message TYPE zif_allocation_audit=>ty_message.
    DATA lv_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_cleanup_message_seen TYPE abap_bool.

    DELETE FROM zstockalloc
      WHERE matnr = 'MATERIAL-PRIO'.
    DELETE FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'.
    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE zcl_order_source_sap.
    CREATE OBJECT lo_sink TYPE zcl_allocation_sink_sap.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_reservation TYPE lcl_cleanup_fail_reservation.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_reservation  = lo_reservation
        io_audit        = lo_audit.

    TRY.
        lo_cut->allocate(
          EXPORTING
            iv_material         = 'MATERIAL-PRIO'
            iv_plant            = '1000'
            iv_storage_location = '0001'
            iv_movement_type    = '201'
            iv_unit             = 'EA'
          IMPORTING
            ev_run_id           = lv_run_id ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_not_initial( lv_run_id ).
    IF lv_message CS 'Reservation cleanup incomplete'.
      lv_cleanup_message_seen = abap_true.
    ENDIF.
    cl_abap_unit_assert=>assert_true( lv_cleanup_message_seen ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      INTO (@lv_status, @lv_message)
      WHERE run_id = @lv_run_id.
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'P' ).
    IF lv_message CS 'Reservation cleanup incomplete'.
      lv_cleanup_message_seen = abap_true.
    ENDIF.
    cl_abap_unit_assert=>assert_true( lv_cleanup_message_seen ).
    DELETE FROM zstockalloc
      WHERE allocation_run_id = @lv_run_id.
    DELETE FROM zstockalloc_run
      WHERE run_id = @lv_run_id.
  ENDMETHOD.

  METHOD rejects_result_delete_auth.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_sink TYPE REF TO zif_allocation_sink.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_reservation TYPE REF TO zif_stock_reservation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_write_authority TYPE REF TO zif_allocation_write_authority.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE zif_allocation_audit=>ty_message.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE zcl_order_source_sap.
    CREATE OBJECT lo_sink TYPE zcl_allocation_sink_sap.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_reservation TYPE zcl_stock_reservation_sap.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_write_authority TYPE lcl_fail_result_delete_auth.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source    = lo_stock_source
        io_order_source    = lo_order_source
        io_sink            = lo_sink
        io_allocator       = lo_allocator
        io_reservation     = lo_reservation
        io_write_authority = lo_write_authority
        io_audit           = lo_audit.

    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-DELETE-AUTH'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Result delete authorization test failure' ).
  ENDMETHOD.
ENDCLASS.
