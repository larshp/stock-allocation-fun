CLASS ltcl_stock_allocation_lock_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS acquires_and_releases FOR TESTING.
    METHODS serializes_batch_scopes FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_enqueue_failure FOR TESTING.
    METHODS rejects_dequeue_failure FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_allocation_lock_sap IMPLEMENTATION.
  METHOD acquires_and_releases.
    DATA lo_cut TYPE REF TO zif_stock_allocation_lock.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocation_lock_sap.
    TRY.
        lo_cut->acquire(
          iv_material         = 'MATERIAL-LOCK'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_batch            = 'BATCH-001' ).
        lo_cut->release(
          iv_material         = 'MATERIAL-LOCK'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_batch            = 'BATCH-001' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_false( lv_raised ).
  ENDMETHOD.

  METHOD rejects_enqueue_failure.
    DATA lo_cut TYPE REF TO zif_stock_allocation_lock.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocation_lock_sap.
    TRY.
        lo_cut->acquire(
          iv_material         = 'MATERIAL-LOCK-ERROR'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD serializes_batch_scopes.
    DATA lo_cut TYPE REF TO zif_stock_allocation_lock.
    DATA lv_second_acquired TYPE abap_bool.
    DATA lv_second_rejected TYPE abap_bool.
    DATA lv_second_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocation_lock_sap.
    lo_cut->acquire(
      iv_material         = 'MATERIAL-LOCK-COARSE'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_batch            = 'BATCH-001' ).
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait   = abap_true
      EXCEPTIONS
        OTHERS = 1.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    TRY.
        lo_cut->acquire(
          iv_material         = 'MATERIAL-LOCK-COARSE'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_batch            = 'BATCH-002' ).
        lv_second_acquired = abap_true.
      CATCH zcx_stock_allocation INTO DATA(lo_second_error).
        lv_second_rejected = abap_true.
        lv_second_message = lo_second_error->message.
    ENDTRY.
    IF lv_second_acquired = abap_true.
      lo_cut->release(
        iv_material         = 'MATERIAL-LOCK-COARSE'
        iv_plant            = '1000'
        iv_storage_location = '0001'
        iv_batch            = 'BATCH-002' ).
    ENDIF.
    lo_cut->release(
      iv_material         = 'MATERIAL-LOCK-COARSE'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_batch            = 'BATCH-001' ).
    cl_abap_unit_assert=>assert_true( lv_second_rejected ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_second_message
      exp = 'Allocation scope is locked by another run' ).

    lo_cut->acquire(
      iv_material         = 'MATERIAL-LOCK-COARSE'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_batch            = 'BATCH-002' ).
    lo_cut->release(
      iv_material         = 'MATERIAL-LOCK-COARSE'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_batch            = 'BATCH-002' ).
  ENDMETHOD.

  METHOD rejects_dequeue_failure.
    DATA lo_cut TYPE REF TO zif_stock_allocation_lock.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocation_lock_sap.
    TRY.
        lo_cut->release(
          iv_material         = 'MATERIAL-UNLOCK-ERROR'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.
ENDCLASS.
