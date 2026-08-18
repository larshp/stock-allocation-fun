CLASS ltcl_stock_alloc_service_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS allocates_sap_vertical_slice FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS allocates_batch_slice FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS previews_zero_stock_batch FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS previews_with_safety_stock FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS previews_with_recon FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_shortage_limit FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_shortage_pct_limit FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_coverage_limit FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_full_line_limit FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_min_full_count FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_max_full_count FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_demand_limit FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_quantity_limit FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_allocation_limit FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_min_alloc_limit FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_min_alloc_line_limit FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_allocation_line_limit FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_unallocated_line_limit FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_partial_line_limit FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_shortage_line_limit FOR TESTING
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
    METHODS rejects_negative_priority FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_high_priority FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_zero_sales_document FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_missing_reservation FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_short_existing_doc FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_short_num_reservation FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_nonnumeric_reservation FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_bad_existing_date FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_partial_existing_id FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS accepts_lowercase_snapshot FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS canonicalizes_stock_unit FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_bad_stock_flags FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_batch_metadata FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_missing_order_unit FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_missing_requested_date FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_partial_sales_identity FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_short_sales_document FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS caps_cross_unit_reservations FOR TESTING
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
    METHODS rejects_negative_safety_stock FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_transaction_failure FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS records_incomplete_cleanup FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_result_delete_auth FOR TESTING
      RAISING zcx_stock_allocation.
ENDCLASS.

CLASS lcl_neg_prio_order_source DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_order_source.
ENDCLASS.

CLASS lcl_neg_prio_order_source IMPLEMENTATION.
  METHOD zif_order_source~get_open_demands.
    APPEND VALUE #( order_id     = 'NEGATIVE-PRIORITY'
                    order_unit   = 'EA'
                    priority     = -1
                    requested_on = sy-datum
                    requested    = 1 ) TO rt_demands.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_high_prio_order_source DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_order_source.
ENDCLASS.

CLASS lcl_high_prio_order_source IMPLEMENTATION.
  METHOD zif_order_source~get_open_demands.
    APPEND VALUE #( order_id     = 'HIGH-PRIORITY'
                    order_unit   = 'EA'
                    priority     = 100
                    requested_on = sy-datum
                    requested    = 1 ) TO rt_demands.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_zero_sales_doc_order_src DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_order_source.
ENDCLASS.

CLASS lcl_zero_sales_doc_order_src IMPLEMENTATION.
  METHOD zif_order_source~get_open_demands.
    APPEND VALUE #( sales_document = '0000000000'
                    order_id       = 'ZERO-SALES-DOCUMENT'
                    order_unit     = 'EA'
                    requested_on   = sy-datum
                    requested      = 1 ) TO rt_demands.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_short_sales_doc_order_src DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_order_source.
ENDCLASS.

CLASS lcl_short_sales_doc_order_src IMPLEMENTATION.
  METHOD zif_order_source~get_open_demands.
    APPEND VALUE #( sales_document = '123'
                    order_id       = 'SHORT-SALES-DOCUMENT'
                    order_unit     = 'EA'
                    requested_on   = sy-datum
                    requested      = 1 ) TO rt_demands.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_overflow_stock_source DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_source.
ENDCLASS.

CLASS lcl_overflow_stock_source IMPLEMENTATION.
  METHOD zif_stock_source~get_available.
    rs_available-quantity = '5'.
    rs_available-unit = 'EA'.
    rs_available-material_found = abap_true.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_lowercase_stock_source DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_source.
ENDCLASS.

CLASS lcl_lowercase_stock_source IMPLEMENTATION.
  METHOD zif_stock_source~get_available.
    rs_available-quantity = 5.
    rs_available-unit = 'ea'.
    rs_available-material_found = abap_true.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_unexpected_conversion DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_unit_conversion.
ENDCLASS.

CLASS lcl_unexpected_conversion IMPLEMENTATION.
  METHOD zif_unit_conversion~convert.
    DATA lo_error TYPE REF TO zcx_stock_allocation.

    CREATE OBJECT lo_error.
    lo_error->message = 'Unexpected unit conversion'.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_bad_stock_flags DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_source.
ENDCLASS.

CLASS lcl_bad_stock_flags IMPLEMENTATION.
  METHOD zif_stock_source~get_available.
    rs_available-quantity = 1.
    rs_available-unit = 'EA'.
    rs_available-material_found = abap_true.
    rs_available-batch_managed = abap_false.
    rs_available-batch_found = abap_false.
    rs_available-batch_restricted = '?'.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_inconsistent_stock_result DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_source.
ENDCLASS.

CLASS lcl_inconsistent_stock_result IMPLEMENTATION.
  METHOD zif_stock_source~get_available.
    rs_available-quantity = 1.
    rs_available-unit = 'EA'.
    rs_available-material_found = abap_true.
    rs_available-batch_managed = abap_false.
    rs_available-batch_found = abap_true.
    rs_available-batch_restricted = abap_false.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_missing_order_unit DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_order_source.
ENDCLASS.

CLASS lcl_missing_order_unit IMPLEMENTATION.
  METHOD zif_order_source~get_open_demands.
    APPEND VALUE #( order_id     = 'MISSING-ORDER-UNIT'
                    requested_on = sy-datum
                    requested    = 1 ) TO rt_demands.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_missing_requested_date DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_order_source.
ENDCLASS.

CLASS lcl_missing_requested_date IMPLEMENTATION.
  METHOD zif_order_source~get_open_demands.
    APPEND VALUE #( order_id   = 'MISSING-REQUESTED-DATE'
                    order_unit = 'EA'
                    requested  = 1 ) TO rt_demands.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_incomplete_sales_identity DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_order_source.
ENDCLASS.

CLASS lcl_incomplete_sales_identity IMPLEMENTATION.
  METHOD zif_order_source~get_open_demands.
    APPEND VALUE #( sales_document = '5000000001'
                    order_id       = 'INCOMPLETE-SALES-IDENTITY'
                    order_unit     = 'EA'
                    requested_on   = sy-datum
                    requested      = 1 ) TO rt_demands.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_overflow_order_source DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_order_source.
ENDCLASS.

CLASS lcl_overflow_order_source IMPLEMENTATION.
  METHOD zif_order_source~get_open_demands.
    APPEND VALUE #( order_id     = 'CURRENT-OVERFLOW'
                    order_unit   = 'EA'
                    requested_on = sy-datum
                    requested    = 1 ) TO rt_demands.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_overflow_sink DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_sink.
ENDCLASS.

CLASS lcl_overflow_sink IMPLEMENTATION.
  METHOD zif_allocation_sink~get_allocations.
    APPEND VALUE #( allocation_run_id         = 'OLD-OVERFLOW-RUN'
                    allocation_unit           = 'BOX'
                    order_id                  = 'OLD-OVERFLOW-01'
                    priority                  = 0
                    requested_on              = sy-datum
                    requested                 = '600000000000'
                    allocated                 = '600000000000'
                    allocation_status         = 'F'
                    reservation_id            = '0000000001'
                    reservation_date          = sy-datum
                    reservation_movement_type = '201'
                    reservation_unit          = 'BOX' ) TO rt_demands.
    APPEND VALUE #( allocation_run_id         = 'OLD-OVERFLOW-RUN'
                    allocation_unit           = 'BOX'
                    order_id                  = 'OLD-OVERFLOW-02'
                    priority                  = 0
                    requested_on              = sy-datum
                    requested                 = '600000000000'
                    allocated                 = '600000000000'
                    allocation_status         = 'F'
                    reservation_id            = '0000000002'
                    reservation_date          = sy-datum
                    reservation_movement_type = '201'
                    reservation_unit          = 'BOX' ) TO rt_demands.
  ENDMETHOD.

  METHOD zif_allocation_sink~save_allocations.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_preview_reconcile_sink DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_sink.
ENDCLASS.

CLASS lcl_preview_reconcile_sink IMPLEMENTATION.
  METHOD zif_allocation_sink~get_allocations.
    APPEND VALUE #( allocation_run_id         = 'OLD-PREVIEW-RECON'
                    allocation_unit           = 'BOX'
                    order_id                  = 'OLD-PREVIEW-RECON-01'
                    priority                  = 0
                    requested_on              = sy-datum
                    requested                 = 2
                    allocated                 = 2
                    shortage                  = 0
                    allocation_status         = 'F'
                    reservation_id            = '0000000101'
                    reservation_date          = sy-datum
                    reservation_movement_type = '201'
                    reservation_unit          = 'BOX' ) TO rt_demands.
  ENDMETHOD.

  METHOD zif_allocation_sink~save_allocations.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_missing_reservation_sink DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_sink.
ENDCLASS.

CLASS lcl_missing_reservation_sink IMPLEMENTATION.
  METHOD zif_allocation_sink~get_allocations.
    APPEND VALUE #( allocation_run_id = 'OLD-MISSING-RESERVATION'
                    allocation_unit   = 'EA'
                    order_id          = 'MISSING-RESERVATION'
                    priority          = 0
                    requested_on      = sy-datum
                    requested         = 1
                    allocated         = 1
                    shortage          = 0
                    allocation_status = 'F' ) TO rt_demands.
  ENDMETHOD.

  METHOD zif_allocation_sink~save_allocations.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_short_existing_doc_sink DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_sink.
ENDCLASS.

CLASS lcl_short_existing_doc_sink IMPLEMENTATION.
  METHOD zif_allocation_sink~get_allocations.
    APPEND VALUE #( allocation_run_id = 'OLD-SHORT-DOCUMENT'
                    allocation_unit   = 'EA'
                    sales_document    = '123'
                    order_id          = 'SHORT-EXISTING-DOC'
                    priority          = 0
                    requested_on      = sy-datum
                    requested         = 1
                    allocated         = 0
                    shortage          = 1
                    allocation_status = 'U' ) TO rt_demands.
  ENDMETHOD.

  METHOD zif_allocation_sink~save_allocations.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_short_num_reservation DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_sink.
ENDCLASS.

CLASS lcl_short_num_reservation IMPLEMENTATION.
  METHOD zif_allocation_sink~get_allocations.
    APPEND VALUE #( allocation_run_id         = 'OLD-SHORT-RESERVATION'
                    allocation_unit           = 'EA'
                    order_id                  = 'SHORT-NUMERIC-RESERVATION'
                    priority                  = 0
                    requested_on              = sy-datum
                    requested                 = 1
                    allocated                 = 1
                    shortage                  = 0
                    allocation_status         = 'F'
                    reservation_id            = '123'
                    reservation_date          = sy-datum
                    reservation_movement_type = '201'
                    reservation_unit          = 'EA' ) TO rt_demands.
  ENDMETHOD.

  METHOD zif_allocation_sink~save_allocations.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_nonnumeric_reservation DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_sink.
ENDCLASS.

CLASS lcl_nonnumeric_reservation IMPLEMENTATION.
  METHOD zif_allocation_sink~get_allocations.
    APPEND VALUE #( allocation_run_id         = 'OLD-NONNUMERIC-RES'
                    allocation_unit           = 'EA'
                    order_id                  = 'NONNUMERIC-RESERVATION'
                    priority                  = 0
                    requested_on              = sy-datum
                    requested                 = 1
                    allocated                 = 1
                    shortage                  = 0
                    allocation_status         = 'F'
                    reservation_id            = 'RESBAD0001'
                    reservation_date          = sy-datum
                    reservation_movement_type = '201'
                    reservation_unit          = 'EA' ) TO rt_demands.
  ENDMETHOD.

  METHOD zif_allocation_sink~save_allocations.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_bad_snapshot_date_sink DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_sink.
ENDCLASS.

CLASS lcl_bad_snapshot_date_sink IMPLEMENTATION.
  METHOD zif_allocation_sink~get_allocations.
    APPEND VALUE #( allocation_run_id         = 'OLD-BAD-DATE'
                    allocation_unit           = 'EA'
                    order_id                  = 'CURRENT-OVERFLOW'
                    priority                  = 0
                    requested_on              = sy-datum
                    requested                 = 1
                    allocated                 = 1
                    shortage                  = 0
                    allocation_status         = 'F'
                    reservation_id            = '0000000001'
                    reservation_date          = '20260230'
                    reservation_movement_type = '201'
                    reservation_unit          = 'EA' ) TO rt_demands.
  ENDMETHOD.

  METHOD zif_allocation_sink~save_allocations.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_partial_existing_sink DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_sink.
ENDCLASS.

CLASS lcl_partial_existing_sink IMPLEMENTATION.
  METHOD zif_allocation_sink~get_allocations.
    APPEND VALUE #( allocation_run_id = 'OLD-PARTIAL-IDENTITY'
                    allocation_unit   = 'EA'
                    sales_document    = '5000000001'
                    order_id          = 'PARTIAL-EXISTING-IDENTITY'
                    priority          = 0
                    requested_on      = sy-datum
                    requested         = 1
                    allocated         = 0
                    shortage          = 1
                    allocation_status = 'U' ) TO rt_demands.
  ENDMETHOD.

  METHOD zif_allocation_sink~save_allocations.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_lowercase_existing_sink DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_sink.
ENDCLASS.

CLASS lcl_lowercase_existing_sink IMPLEMENTATION.
  METHOD zif_allocation_sink~get_allocations.
    APPEND VALUE #( allocation_run_id         = 'OLD-LOWERCASE'
                    allocation_unit           = 'ea'
                    order_unit                = 'ea'
                    order_id                  = 'CURRENT-OVERFLOW'
                    priority                  = 0
                    requested_on              = sy-datum
                    requested                 = 1
                    allocated                 = 1
                    shortage                  = 0
                    allocation_status         = 'f'
                    reservation_id            = '0000000001'
                    reservation_date          = sy-datum
                    reservation_movement_type = '201'
                    reservation_unit          = 'ea' ) TO rt_demands.
  ENDMETHOD.

  METHOD zif_allocation_sink~save_allocations.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_overflow_unit_converter DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_unit_conversion.
ENDCLASS.

CLASS lcl_overflow_unit_converter IMPLEMENTATION.
  METHOD zif_unit_conversion~convert.
    rv_quantity = iv_quantity.
  ENDMETHOD.
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
      rv_document = '0000000001'.
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
    CLEAR lv_raised.
    TRY.
        lo_cut->allocate(
          iv_material          = 'MATERIAL-PRIO'
          iv_plant             = '1000'
          iv_storage_location  = '0001'
          iv_movement_type     = '201'
          iv_unit              = 'EA'
          iv_requested_on_from = '20260230'
          iv_requested_on_to   = '20260301' ).
      CATCH zcx_stock_allocation INTO DATA(lo_invalid_date_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_invalid_date_error->message
          exp = 'Requested delivery date range is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT SINGLE movement_type, min_shelf_life
      FROM zstockalloc_run

      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND requested_on_from = '20260820'
        AND requested_on_to = '20260815'
        AND status = 'E' INTO (@lv_persisted_movement_type, @lv_persisted_min_shelf_life).
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

      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001' INTO @lv_run_count.
    cl_abap_unit_assert=>assert_equals(
      act = lv_run_count
      exp = 1 ).
    SELECT SINGLE status, message
      FROM zstockalloc_run

      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001' INTO (@lv_status, @lv_message).
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

  METHOD rejects_negative_priority.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_message TYPE zif_allocation_audit=>ty_message.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE lcl_neg_prio_order_source.
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
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Open demand priority is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA' INTO (@lv_status, @lv_message).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Open demand priority is invalid' ).
    DELETE FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA'.
  ENDMETHOD.

  METHOD rejects_high_priority.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_message TYPE zif_allocation_audit=>ty_message.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE lcl_high_prio_order_source.
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
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Open demand priority is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA' INTO (@lv_status, @lv_message).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Open demand priority is invalid' ).
    DELETE FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA'.
  ENDMETHOD.

  METHOD rejects_zero_sales_document.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_message TYPE zif_allocation_audit=>ty_message.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE lcl_zero_sales_doc_order_src.
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
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Open demand quantity or key is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA' INTO (@lv_status, @lv_message).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Open demand quantity or key is invalid' ).
    DELETE FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA'.
  ENDMETHOD.

  METHOD rejects_missing_reservation.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_sink TYPE REF TO zif_allocation_sink.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_message TYPE zif_allocation_audit=>ty_message.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE zcl_order_source_sap.
    CREATE OBJECT lo_sink TYPE lcl_missing_reservation_sink.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_audit        = lo_audit.
    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-PRIO'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Allocation snapshot read returned invalid data' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA' INTO (@lv_status, @lv_message).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Allocation snapshot read returned invalid data' ).
    DELETE FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA'.
  ENDMETHOD.

  METHOD rejects_short_existing_doc.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_sink TYPE REF TO zif_allocation_sink.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_message TYPE zif_allocation_audit=>ty_message.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE zcl_order_source_sap.
    CREATE OBJECT lo_sink TYPE lcl_short_existing_doc_sink.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_audit        = lo_audit.
    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-PRIO'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Allocation snapshot read returned invalid data' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA' INTO (@lv_status, @lv_message).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Allocation snapshot read returned invalid data' ).
    DELETE FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA'.
  ENDMETHOD.

  METHOD rejects_short_num_reservation.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_sink TYPE REF TO zif_allocation_sink.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_message TYPE zif_allocation_audit=>ty_message.

    CREATE OBJECT lo_stock_source TYPE lcl_overflow_stock_source.
    CREATE OBJECT lo_order_source TYPE lcl_overflow_order_source.
    CREATE OBJECT lo_sink TYPE lcl_short_num_reservation.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_audit        = lo_audit.
    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-PRIO'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Allocation snapshot read returned invalid data' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA' INTO (@lv_status, @lv_message).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Allocation snapshot read returned invalid data' ).
    DELETE FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA'.
  ENDMETHOD.

  METHOD rejects_nonnumeric_reservation.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_sink TYPE REF TO zif_allocation_sink.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_message TYPE zif_allocation_audit=>ty_message.

    CREATE OBJECT lo_stock_source TYPE lcl_overflow_stock_source.
    CREATE OBJECT lo_order_source TYPE lcl_overflow_order_source.
    CREATE OBJECT lo_sink TYPE lcl_nonnumeric_reservation.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_audit        = lo_audit.
    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-PRIO'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Allocation snapshot read returned invalid data' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA' INTO (@lv_status, @lv_message).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Allocation snapshot read returned invalid data' ).
    DELETE FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA'.
  ENDMETHOD.

  METHOD rejects_bad_existing_date.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_sink TYPE REF TO zif_allocation_sink.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_message TYPE zif_allocation_audit=>ty_message.

    CREATE OBJECT lo_stock_source TYPE lcl_overflow_stock_source.
    CREATE OBJECT lo_order_source TYPE lcl_overflow_order_source.
    CREATE OBJECT lo_sink TYPE lcl_bad_snapshot_date_sink.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_audit        = lo_audit.
    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-PRIO'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Allocation snapshot read returned invalid data' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA' INTO (@lv_status, @lv_message).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Allocation snapshot read returned invalid data' ).
    DELETE FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA'.
  ENDMETHOD.

  METHOD rejects_partial_existing_id.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_sink TYPE REF TO zif_allocation_sink.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_message TYPE zif_allocation_audit=>ty_message.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE zcl_order_source_sap.
    CREATE OBJECT lo_sink TYPE lcl_partial_existing_sink.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_audit        = lo_audit.
    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-PRIO'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Allocation snapshot read returned invalid data' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA' INTO (@lv_status, @lv_message).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Allocation snapshot read returned invalid data' ).
    DELETE FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA'.
  ENDMETHOD.

  METHOD accepts_lowercase_snapshot.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_sink TYPE REF TO zif_allocation_sink.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_remaining TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.

    CREATE OBJECT lo_stock_source TYPE lcl_overflow_stock_source.
    CREATE OBJECT lo_order_source TYPE lcl_overflow_order_source.
    CREATE OBJECT lo_sink TYPE lcl_lowercase_existing_sink.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_audit        = lo_audit.

    lv_remaining = lo_cut->allocate(
      EXPORTING
        iv_material         = 'MATERIAL-LOWERCASE'
        iv_plant            = '1000'
        iv_storage_location = '0001'
        iv_movement_type    = '201'
        iv_unit             = 'EA'
      IMPORTING
        ev_run_id           = lv_run_id ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_remaining
      exp = 4 ).
    cl_abap_unit_assert=>assert_not_initial( lv_run_id ).
    SELECT SINGLE status
      FROM zstockalloc_run
      WHERE run_id = @lv_run_id INTO @lv_status.
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'S' ).
    DELETE FROM zstockalloc_run
      WHERE run_id = @lv_run_id.
  ENDMETHOD.

  METHOD canonicalizes_stock_unit.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_unit_converter TYPE REF TO zif_unit_conversion.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_remaining TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.

    CREATE OBJECT lo_stock_source TYPE lcl_lowercase_stock_source.
    CREATE OBJECT lo_order_source TYPE lcl_overflow_order_source.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_unit_converter TYPE lcl_unexpected_conversion.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source   = lo_stock_source
        io_order_source   = lo_order_source
        io_allocator      = lo_allocator
        io_unit_converter = lo_unit_converter
        io_audit          = lo_audit.

    lv_remaining = lo_cut->allocate(
      EXPORTING
        iv_material         = 'MATERIAL-LOWER-STOCK'
        iv_plant            = '1000'
        iv_storage_location = '0001'
        iv_movement_type    = '201'
        iv_unit             = 'EA'
        iv_preview          = abap_true
      IMPORTING
        ev_run_id           = lv_run_id ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_remaining
      exp = 4 ).
    cl_abap_unit_assert=>assert_not_initial( lv_run_id ).
    SELECT SINGLE status
      FROM zstockalloc_run
      WHERE run_id = @lv_run_id INTO @lv_status.
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'S' ).
    DELETE FROM zstockalloc_run
      WHERE run_id = @lv_run_id.
  ENDMETHOD.

  METHOD rejects_bad_stock_flags.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_message TYPE zif_allocation_audit=>ty_message.

    CREATE OBJECT lo_stock_source TYPE lcl_bad_stock_flags.
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
          iv_preview          = abap_true ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Available stock result is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA' INTO (@lv_status, @lv_message).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Available stock result is invalid' ).
    DELETE FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA'.
  ENDMETHOD.

  METHOD rejects_batch_metadata.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_message TYPE zif_allocation_audit=>ty_message.

    CREATE OBJECT lo_stock_source TYPE lcl_inconsistent_stock_result.
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
          iv_preview          = abap_true ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Available stock result is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA' INTO (@lv_status, @lv_message).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Available stock result is invalid' ).
    DELETE FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA'.
  ENDMETHOD.

  METHOD rejects_missing_order_unit.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_message TYPE zif_allocation_audit=>ty_message.
    DATA lv_preview TYPE abap_bool.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE lcl_missing_order_unit.
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
          iv_preview          = abap_true ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Open demand unit is missing' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT SINGLE status, message, preview
      FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA' INTO (@lv_status, @lv_message, @lv_preview).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Open demand unit is missing' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_preview
      exp = abap_true ).
    DELETE FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA'.
  ENDMETHOD.

  METHOD rejects_missing_requested_date.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_message TYPE zif_allocation_audit=>ty_message.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE lcl_missing_requested_date.
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
          iv_preview          = abap_true ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Open demand requested date is missing' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA' INTO (@lv_status, @lv_message).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Open demand requested date is missing' ).
    DELETE FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA'.
  ENDMETHOD.

  METHOD rejects_partial_sales_identity.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_message TYPE zif_allocation_audit=>ty_message.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE lcl_incomplete_sales_identity.
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
          iv_preview          = abap_true ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Open demand source identity is incomplete' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA' INTO (@lv_status, @lv_message).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Open demand source identity is incomplete' ).
    DELETE FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA'.
  ENDMETHOD.

  METHOD rejects_short_sales_document.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE lcl_short_sales_doc_order_src.
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
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Open demand quantity or key is invalid' ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD caps_cross_unit_reservations.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_sink TYPE REF TO zif_allocation_sink.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_unit_converter TYPE REF TO zif_unit_conversion.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_remaining TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.

    CREATE OBJECT lo_stock_source TYPE lcl_overflow_stock_source.
    CREATE OBJECT lo_order_source TYPE lcl_overflow_order_source.
    CREATE OBJECT lo_sink TYPE lcl_overflow_sink.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_unit_converter TYPE lcl_overflow_unit_converter.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source   = lo_stock_source
        io_order_source   = lo_order_source
        io_sink           = lo_sink
        io_allocator      = lo_allocator
        io_unit_converter = lo_unit_converter
        io_audit          = lo_audit.

    lv_remaining = lo_cut->allocate(
      EXPORTING
        iv_material         = 'MATERIAL-OVERFLOW'
        iv_plant            = '1000'
        iv_storage_location = '0001'
        iv_movement_type    = '201'
        iv_unit             = 'EA'
      IMPORTING
        ev_run_id           = lv_run_id ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_remaining
      exp = 0 ).
    cl_abap_unit_assert=>assert_not_initial( lv_run_id ).
    SELECT SINGLE status
      FROM zstockalloc_run
      WHERE run_id = @lv_run_id INTO @lv_status.
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'P' ).
    DELETE FROM zstockalloc_run
      WHERE run_id = @lv_run_id.
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

      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001' INTO @lv_run_count.
    cl_abap_unit_assert=>assert_equals(
      act = lv_run_count
      exp = 1 ).
    SELECT SINGLE message
      FROM zstockalloc_run

      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001' INTO @lv_message.
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
          iv_movement_type    = '20'
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

      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001' INTO @lv_run_count.
    cl_abap_unit_assert=>assert_equals(
      act = lv_run_count
      exp = 1 ).
    SELECT SINGLE movement_type, message
      FROM zstockalloc_run

      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001' INTO (@lv_persisted_movement_type, @lv_message).
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
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
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
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_allocator    = lo_allocator
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
      WHERE run_id = @lv_run_id
        INTO ( @lv_persisted_movement_type,
               @lv_persisted_min_shelf_life,
               @lv_persisted_strategy ).
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

      WHERE run_id = @lv_run_id INTO @lv_persisted_unit.
    cl_abap_unit_assert=>assert_equals(
      act = lv_persisted_unit
      exp = 'EA' ).
    SELECT SINGLE allocation_unit
      FROM zstockalloc

      WHERE run_id = @lv_run_id INTO @lv_persisted_allocation_unit.
    cl_abap_unit_assert=>assert_equals(
      act = lv_persisted_allocation_unit
      exp = 'EA' ).

    SELECT COUNT( * )
      FROM zstockalloc

      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001' INTO @lv_allocation_count.
    cl_abap_unit_assert=>assert_equals(
      act = lv_allocation_count
      exp = 2 ).

    SELECT SINGLE reservation_id
      FROM zstockalloc

      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND order_id = '10000000010000100001' INTO @lv_reservation_id.
    cl_abap_unit_assert=>assert_not_initial( lv_reservation_id ).
    SELECT SINGLE reservation_id
      FROM zstockalloc

      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND order_id = '10000000010000100002' INTO @lv_second_reservation_id.
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

      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND order_id = '10000000010000100001' INTO @lv_rerun_reservation_id.
    SELECT SINGLE reservation_id
      FROM zstockalloc

      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND order_id = '10000000010000100002' INTO @lv_rerun_second_reservation_id.
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

      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND order_id = '10000000010000100001' INTO @lv_changed_reservation_id.
    SELECT SINGLE reservation_id
      FROM zstockalloc

      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND order_id = '10000000010000100002' INTO @lv_changed_second_id.
    IF lv_changed_reservation_id = lv_reservation_id
        OR lv_changed_second_id = lv_second_reservation_id.
      lv_reservations_differ = abap_false.
    ELSE.
      lv_reservations_differ = abap_true.
    ENDIF.
    cl_abap_unit_assert=>assert_true( lv_reservations_differ ).

    SELECT COUNT( * )
      FROM zstockalloc_run

      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND status = 'P' INTO @lv_run_count.
    cl_abap_unit_assert=>assert_equals(
      act = lv_run_count
      exp = 3 ).

    SELECT SUM( full_count ), SUM( partial_count ), SUM( unallocated_count )
      FROM zstockalloc_run

      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND status = 'P' INTO (@lv_full_count, @lv_partial_count, @lv_unallocated_count).
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

      WHERE matnr = 'MATERIAL-BATCH-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-001' INTO @lv_allocation_count.
    cl_abap_unit_assert=>assert_equals(
      act = lv_allocation_count
      exp = 1 ).
    SELECT SINGLE batch
      FROM zstockalloc

      WHERE matnr = 'MATERIAL-BATCH-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-001' INTO @lv_batch.
    cl_abap_unit_assert=>assert_equals(
      act = lv_batch
      exp = 'BATCH-001' ).
  ENDMETHOD.

  METHOD previews_zero_stock_batch.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_remaining TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_shortage TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_unallocated_count TYPE i.

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

    lv_remaining = lo_cut->allocate(
      iv_material         = 'MATERIAL-BATCH'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_movement_type    = '201'
      iv_unit             = 'EA'
      iv_batch            = 'BATCH-ZERO'
      iv_preview          = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_remaining
      exp = '0' ).
    SELECT SINGLE status, shortage, unallocated_count
      FROM zstockalloc_run

      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO' INTO (@lv_status, @lv_shortage, @lv_unallocated_count).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'P' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_shortage
      exp = '2' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_unallocated_count
      exp = 1 ).
  ENDMETHOD.

  METHOD previews_with_safety_stock.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_remaining TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_shortage TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_safety_stock TYPE zif_stock_allocation=>ty_quantity.

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

    lv_remaining = lo_cut->allocate(
      iv_material         = 'MATERIAL-BATCH'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_movement_type    = '201'
      iv_unit             = 'EA'
      iv_batch            = 'BATCH-ZERO'
      iv_safety_stock     = 1
      iv_preview          = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_remaining
      exp = '0' ).
    SELECT SINGLE status, shortage, safety_stock
      FROM zstockalloc_run

      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO'
        AND safety_stock = 1 INTO (@lv_status, @lv_shortage, @lv_safety_stock).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'P' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_shortage
      exp = '2' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_safety_stock
      exp = '1' ).
  ENDMETHOD.

  METHOD previews_with_recon.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_sink TYPE REF TO zif_allocation_sink.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_unit_converter TYPE REF TO zif_unit_conversion.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_remaining TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_available TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_existing_count TYPE i.
    DATA lv_existing_cross_unit_qty TYPE zif_stock_allocation=>ty_quantity.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE lcl_overflow_order_source.
    CREATE OBJECT lo_sink TYPE lcl_preview_reconcile_sink.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_unit_converter TYPE lcl_overflow_unit_converter.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source   = lo_stock_source
        io_order_source   = lo_order_source
        io_sink           = lo_sink
        io_allocator      = lo_allocator
        io_unit_converter = lo_unit_converter
        io_audit          = lo_audit.

    lv_remaining = lo_cut->allocate(
      EXPORTING
        iv_material                  = 'MATERIAL-PRIO'
        iv_plant                     = '1000'
        iv_storage_location          = '0001'
        iv_movement_type             = '201'
        iv_unit                      = 'EA'
        iv_preview                   = abap_true
        iv_reconcile_existing        = abap_true
      IMPORTING
        ev_run_id                    = lv_run_id
        ev_existing_allocation_count = lv_existing_count
        ev_existing_cross_unit_qty   = lv_existing_cross_unit_qty ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_remaining
      exp = '3' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_existing_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_existing_cross_unit_qty
      exp = '2' ).
    SELECT SINGLE available
      FROM zstockalloc_run
      WHERE run_id = @lv_run_id INTO @lv_available.
    cl_abap_unit_assert=>assert_equals(
      act = lv_available
      exp = '4' ).
    DELETE FROM zstockalloc_run
      WHERE run_id = @lv_run_id.
  ENDMETHOD.

  METHOD rejects_shortage_limit.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_before_count TYPE i.
    DATA lv_after_count TYPE i.
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

    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO' INTO @lv_before_count.

    TRY.
        lo_cut->allocate(
          iv_material              = 'MATERIAL-BATCH'
          iv_plant                 = '1000'
          iv_storage_location      = '0001'
          iv_movement_type         = '201'
          iv_unit                  = 'EA'
          iv_batch                 = 'BATCH-ZERO'
          iv_preview               = abap_true
          iv_shortage_limit_active = abap_true
          iv_max_shortage          = 1 ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Maximum shortage limit exceeded' ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO' INTO @lv_after_count.
    cl_abap_unit_assert=>assert_equals(
      act = lv_after_count
      exp = lv_before_count ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO'
        AND message = 'Maximum shortage limit exceeded'
      INTO (@lv_status, @lv_message).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Maximum shortage limit exceeded' ).
  ENDMETHOD.

  METHOD rejects_shortage_pct_limit.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_before_count TYPE i.
    DATA lv_after_count TYPE i.
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

    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO' INTO @lv_before_count.

    TRY.
        lo_cut->allocate(
          iv_material          = 'MATERIAL-BATCH'
          iv_plant             = '1000'
          iv_storage_location  = '0001'
          iv_movement_type     = '201'
          iv_unit              = 'EA'
          iv_batch             = 'BATCH-ZERO'
          iv_preview           = abap_true
          iv_spct_limit_active = abap_true
          iv_max_shortage_pct  = 50 ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Maximum shortage percentage exceeded' ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO' INTO @lv_after_count.
    cl_abap_unit_assert=>assert_equals(
      act = lv_after_count
      exp = lv_before_count ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO'
        AND message = 'Maximum shortage percentage exceeded'
      INTO (@lv_status, @lv_message).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Maximum shortage percentage exceeded' ).
  ENDMETHOD.

  METHOD rejects_coverage_limit.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_before_count TYPE i.
    DATA lv_after_count TYPE i.
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

    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO' INTO @lv_before_count.

    TRY.
        lo_cut->allocate(
          iv_material              = 'MATERIAL-BATCH'
          iv_plant                 = '1000'
          iv_storage_location      = '0001'
          iv_movement_type         = '201'
          iv_unit                  = 'EA'
          iv_batch                 = 'BATCH-ZERO'
          iv_preview               = abap_true
          iv_coverage_limit_active = abap_true
          iv_min_coverage          = 50 ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Minimum coverage limit not met' ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO' INTO @lv_after_count.
    cl_abap_unit_assert=>assert_equals(
      act = lv_after_count
      exp = lv_before_count ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO'
        AND message = 'Minimum coverage limit not met'
      INTO (@lv_status, @lv_message).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Minimum coverage limit not met' ).
  ENDMETHOD.

  METHOD rejects_full_line_limit.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_before_count TYPE i.
    DATA lv_after_count TYPE i.
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

    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO' INTO @lv_before_count.

    TRY.
        lo_cut->allocate(
          iv_material               = 'MATERIAL-BATCH'
          iv_plant                  = '1000'
          iv_storage_location       = '0001'
          iv_movement_type          = '201'
          iv_unit                   = 'EA'
          iv_batch                  = 'BATCH-ZERO'
          iv_preview                = abap_true
          iv_full_line_limit_active = abap_true
          iv_min_full_line_pct      = 100 ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Minimum full-line percentage not met' ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO' INTO @lv_after_count.
    cl_abap_unit_assert=>assert_equals(
      act = lv_after_count
      exp = lv_before_count ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO'
        AND message = 'Minimum full-line percentage not met'
      INTO (@lv_status, @lv_message).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Minimum full-line percentage not met' ).
  ENDMETHOD.

  METHOD rejects_min_full_count.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_before_count TYPE i.
    DATA lv_after_count TYPE i.
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

    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO' INTO @lv_before_count.

    TRY.
        lo_cut->allocate(
          iv_material                = 'MATERIAL-BATCH'
          iv_plant                   = '1000'
          iv_storage_location        = '0001'
          iv_movement_type           = '201'
          iv_unit                    = 'EA'
          iv_batch                   = 'BATCH-ZERO'
          iv_preview                 = abap_true
          iv_full_count_limit_active = abap_true
          iv_min_full_lines          = 1 ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Minimum full lines not met' ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO' INTO @lv_after_count.
    cl_abap_unit_assert=>assert_equals(
      act = lv_after_count
      exp = lv_before_count ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO'
        AND message = 'Minimum full lines not met'
      INTO (@lv_status, @lv_message).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Minimum full lines not met' ).
  ENDMETHOD.

  METHOD rejects_max_full_count.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_before_count TYPE i.
    DATA lv_after_count TYPE i.
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

    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-001' INTO @lv_before_count.

    TRY.
        lo_cut->allocate(
          iv_material                    = 'MATERIAL-BATCH'
          iv_plant                       = '1000'
          iv_storage_location            = '0001'
          iv_movement_type               = '201'
          iv_unit                        = 'EA'
          iv_batch                       = 'BATCH-001'
          iv_preview                     = abap_true
          iv_max_full_count_limit_active = abap_true
          iv_max_full_lines              = 0 ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Maximum full lines limit exceeded' ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-001' INTO @lv_after_count.
    cl_abap_unit_assert=>assert_equals(
      act = lv_after_count
      exp = lv_before_count ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-001'
        AND message = 'Maximum full lines limit exceeded'
      INTO (@lv_status, @lv_message).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Maximum full lines limit exceeded' ).
  ENDMETHOD.

  METHOD rejects_demand_limit.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_before_count TYPE i.
    DATA lv_after_count TYPE i.
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

    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO' INTO @lv_before_count.

    TRY.
        lo_cut->allocate(
          iv_material            = 'MATERIAL-BATCH'
          iv_plant               = '1000'
          iv_storage_location    = '0001'
          iv_movement_type       = '201'
          iv_unit                = 'EA'
          iv_batch               = 'BATCH-ZERO'
          iv_preview             = abap_true
          iv_demand_limit_active = abap_true
          iv_max_demand_count    = 0 ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Maximum demand count exceeded' ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO' INTO @lv_after_count.
    cl_abap_unit_assert=>assert_equals(
      act = lv_after_count
      exp = lv_before_count ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO'
        AND message = 'Maximum demand count exceeded'
      INTO (@lv_status, @lv_message).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Maximum demand count exceeded' ).
  ENDMETHOD.

  METHOD rejects_quantity_limit.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_before_count TYPE i.
    DATA lv_after_count TYPE i.
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

    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO' INTO @lv_before_count.

    TRY.
        lo_cut->allocate(
          iv_material               = 'MATERIAL-BATCH'
          iv_plant                  = '1000'
          iv_storage_location       = '0001'
          iv_movement_type          = '201'
          iv_unit                   = 'EA'
          iv_batch                  = 'BATCH-ZERO'
          iv_preview                = abap_true
          iv_quantity_limit_active  = abap_true
          iv_max_requested_quantity = 0 ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Maximum requested quantity exceeded' ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO' INTO @lv_after_count.
    cl_abap_unit_assert=>assert_equals(
      act = lv_after_count
      exp = lv_before_count ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO'
        AND message = 'Maximum requested quantity exceeded'
      INTO (@lv_status, @lv_message).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Maximum requested quantity exceeded' ).
  ENDMETHOD.

  METHOD rejects_allocation_limit.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_before_count TYPE i.
    DATA lv_after_count TYPE i.
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

    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001' INTO @lv_before_count.

    TRY.
        lo_cut->allocate(
          iv_material                = 'MATERIAL-PRIO'
          iv_plant                   = '1000'
          iv_storage_location        = '0001'
          iv_movement_type           = '201'
          iv_unit                    = 'EA'
          iv_preview                 = abap_true
          iv_allocation_limit_active = abap_true
          iv_max_allocated_quantity  = 0 ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Maximum allocated quantity exceeded' ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001' INTO @lv_after_count.
    cl_abap_unit_assert=>assert_equals(
      act = lv_after_count
      exp = lv_before_count ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND message = 'Maximum allocated quantity exceeded'
      INTO (@lv_status, @lv_message).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Maximum allocated quantity exceeded' ).
  ENDMETHOD.

  METHOD rejects_min_alloc_limit.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_before_count TYPE i.
    DATA lv_after_count TYPE i.
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

    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO' INTO @lv_before_count.

    TRY.
        lo_cut->allocate(
          iv_material               = 'MATERIAL-BATCH'
          iv_plant                  = '1000'
          iv_storage_location       = '0001'
          iv_movement_type          = '201'
          iv_unit                   = 'EA'
          iv_batch                  = 'BATCH-ZERO'
          iv_preview                = abap_true
          iv_min_alloc_limit_active = abap_true
          iv_min_allocated_quantity = 1 ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Minimum allocated quantity not met' ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO' INTO @lv_after_count.
    cl_abap_unit_assert=>assert_equals(
      act = lv_after_count
      exp = lv_before_count ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO'
        AND message = 'Minimum allocated quantity not met'
      INTO (@lv_status, @lv_message).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Minimum allocated quantity not met' ).
  ENDMETHOD.

  METHOD rejects_min_alloc_line_limit.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_before_count TYPE i.
    DATA lv_after_count TYPE i.
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

    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO' INTO @lv_before_count.

    TRY.
        lo_cut->allocate(
          iv_material              = 'MATERIAL-BATCH'
          iv_plant                 = '1000'
          iv_storage_location      = '0001'
          iv_movement_type         = '201'
          iv_unit                  = 'EA'
          iv_batch                 = 'BATCH-ZERO'
          iv_preview               = abap_true
          iv_min_line_limit_active = abap_true
          iv_min_alloc_lines       = 1 ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Minimum allocated lines not met' ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO' INTO @lv_after_count.
    cl_abap_unit_assert=>assert_equals(
      act = lv_after_count
      exp = lv_before_count ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO'
        AND message = 'Minimum allocated lines not met'
      INTO (@lv_status, @lv_message).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Minimum allocated lines not met' ).
  ENDMETHOD.

  METHOD rejects_allocation_line_limit.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_before_count TYPE i.
    DATA lv_after_count TYPE i.
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

    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001' INTO @lv_before_count.

    TRY.
        lo_cut->allocate(
          iv_material          = 'MATERIAL-PRIO'
          iv_plant             = '1000'
          iv_storage_location  = '0001'
          iv_movement_type     = '201'
          iv_unit              = 'EA'
          iv_preview           = abap_true
          iv_line_limit_active = abap_true
          iv_max_alloc_lines   = 0 ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Maximum allocated lines exceeded' ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001' INTO @lv_after_count.
    cl_abap_unit_assert=>assert_equals(
      act = lv_after_count
      exp = lv_before_count ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND message = 'Maximum allocated lines exceeded'
      INTO (@lv_status, @lv_message).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Maximum allocated lines exceeded' ).
  ENDMETHOD.

  METHOD rejects_unallocated_line_limit.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_before_count TYPE i.
    DATA lv_after_count TYPE i.
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

    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO' INTO @lv_before_count.

    TRY.
        lo_cut->allocate(
          iv_material             = 'MATERIAL-BATCH'
          iv_plant                = '1000'
          iv_storage_location     = '0001'
          iv_movement_type        = '201'
          iv_unit                 = 'EA'
          iv_batch                = 'BATCH-ZERO'
          iv_preview              = abap_true
          iv_unalloc_limit_active = abap_true
          iv_max_unalloc_lines    = 0 ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Maximum unallocated lines exceeded' ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO' INTO @lv_after_count.
    cl_abap_unit_assert=>assert_equals(
      act = lv_after_count
      exp = lv_before_count ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO'
        AND message = 'Maximum unallocated lines exceeded'
      INTO (@lv_status, @lv_message).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Maximum unallocated lines exceeded' ).
  ENDMETHOD.

  METHOD rejects_partial_line_limit.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_before_count TYPE i.
    DATA lv_after_count TYPE i.
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

    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001' INTO @lv_before_count.

    TRY.
        lo_cut->allocate(
          iv_material             = 'MATERIAL-PRIO'
          iv_plant                = '1000'
          iv_storage_location     = '0001'
          iv_movement_type        = '201'
          iv_unit                 = 'EA'
          iv_preview              = abap_true
          iv_partial_limit_active = abap_true
          iv_max_partial_lines    = 0 ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Maximum partial lines exceeded' ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001' INTO @lv_after_count.
    cl_abap_unit_assert=>assert_equals(
      act = lv_after_count
      exp = lv_before_count ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND message = 'Maximum partial lines exceeded'
      INTO (@lv_status, @lv_message).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Maximum partial lines exceeded' ).
  ENDMETHOD.

  METHOD rejects_shortage_line_limit.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_before_count TYPE i.
    DATA lv_after_count TYPE i.
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

    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO' INTO @lv_before_count.

    TRY.
        lo_cut->allocate(
          iv_material            = 'MATERIAL-BATCH'
          iv_plant               = '1000'
          iv_storage_location    = '0001'
          iv_movement_type       = '201'
          iv_unit                = 'EA'
          iv_batch               = 'BATCH-ZERO'
          iv_preview             = abap_true
          iv_shline_limit_active = abap_true
          iv_max_shortage_lines  = 0 ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Maximum shortage lines exceeded' ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO' INTO @lv_after_count.
    cl_abap_unit_assert=>assert_equals(
      act = lv_after_count
      exp = lv_before_count ).
    SELECT SINGLE status, message
      FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-BATCH'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-ZERO'
        AND message = 'Maximum shortage lines exceeded'
      INTO (@lv_status, @lv_message).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Maximum shortage lines exceeded' ).
  ENDMETHOD.

  METHOD previews_without_writes.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_remaining TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_preview TYPE abap_bool.
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

      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND allocation_unit = 'EA' INTO @lv_before_count.

    lv_remaining = lo_cut->allocate(
      EXPORTING
      iv_material         = 'MATERIAL-PRIO'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_movement_type    = '201'
      iv_unit             = 'EA'
      iv_preview          = abap_true
      IMPORTING
        ev_run_id         = lv_run_id ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_remaining
      exp = '0' ).
    SELECT COUNT( * )
      FROM zstockalloc

      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND allocation_unit = 'EA' INTO @lv_after_count.
    cl_abap_unit_assert=>assert_equals(
      act = lv_after_count
      exp = lv_before_count ).
    SELECT SINGLE preview
      FROM zstockalloc_run
      WHERE run_id = @lv_run_id
      INTO @lv_preview.
    cl_abap_unit_assert=>assert_equals(
      act = lv_preview
      exp = abap_true ).
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

      WHERE matnr = 'MATERIAL-MISSING'
        AND werks = '1000'
        AND lgort = '0001' INTO (@lv_status, @lv_message).
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

      WHERE matnr = 'MATERIAL-NO-UNIT'
        AND werks = '1000'
        AND lgort = '0001' INTO (@lv_status, @lv_message).
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

      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'BOX' INTO (@lv_status, @lv_message).
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

      WHERE matnr = 'MATERIAL-DEMAND-FAIL'
        AND werks = '1000'
        AND lgort = '0001' INTO @lv_allocation_count.
    cl_abap_unit_assert=>assert_equals(
      act = lv_allocation_count
      exp = 0 ).
    SELECT SINGLE status, message
      FROM zstockalloc_run

      WHERE matnr = 'MATERIAL-DEMAND-FAIL'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA' INTO (@lv_status, @lv_message).
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

      WHERE matnr = 'MATERIAL-ERROR'
        AND werks = '1000'
        AND lgort = '0001' INTO @lv_allocation_count.
    cl_abap_unit_assert=>assert_equals(
      act = lv_allocation_count
      exp = 0 ).
    SELECT SINGLE status, message
      FROM zstockalloc_run

      WHERE matnr = 'MATERIAL-ERROR'
        AND werks = '1000'
        AND lgort = '0001'
        AND unit = 'EA' INTO (@lv_status, @lv_message).
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

  METHOD rejects_negative_safety_stock.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.
    DATA lv_safety_stock TYPE zif_stock_allocation=>ty_quantity.
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
          iv_safety_stock     = -1 ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Invalid safety stock' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    SELECT SINGLE safety_stock, message
      FROM zstockalloc_run

      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND status = 'E'
        AND message = 'Invalid safety stock' INTO (@lv_safety_stock, @lv_message).
    cl_abap_unit_assert=>assert_equals(
      act = lv_safety_stock
      exp = -1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Invalid safety stock' ).
    DELETE FROM zstockalloc_run
      WHERE matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND message = 'Invalid safety stock'.
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

      WHERE run_id = @lv_run_id INTO @lv_status.
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'E' ).
    DELETE FROM zstockalloc
      WHERE run_id = @lv_run_id.
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

      WHERE run_id = @lv_run_id INTO (@lv_status, @lv_message).
    cl_abap_unit_assert=>assert_equals(
      act = lv_status
      exp = 'P' ).
    IF lv_message CS 'Reservation cleanup incomplete'.
      lv_cleanup_message_seen = abap_true.
    ENDIF.
    cl_abap_unit_assert=>assert_true( lv_cleanup_message_seen ).
    DELETE FROM zstockalloc
      WHERE run_id = @lv_run_id.
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
