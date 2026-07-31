CLASS ltcl_stock_allocation_lock_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS acquires_and_releases FOR TESTING.
    METHODS rejects_enqueue_failure FOR TESTING.
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
ENDCLASS.
