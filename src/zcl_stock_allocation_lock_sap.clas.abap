CLASS zcl_stock_allocation_lock_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_stock_allocation_lock.
ENDCLASS.

CLASS zcl_stock_allocation_lock_sap IMPLEMENTATION.
  METHOD zif_stock_allocation_lock~acquire.
    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
      OR iv_storage_location IS INITIAL.
      DATA lo_input_error TYPE REF TO zcx_stock_allocation.
      CREATE OBJECT lo_input_error.
      lo_input_error->message = 'Allocation lock input is incomplete'.
      RAISE EXCEPTION lo_input_error.
    ENDIF.

    "MARD aggregate stock overlaps every batch-specific MCHB scope.
    CALL FUNCTION 'ENQUEUE_EZSTOCKALLOC'
      EXPORTING
        mandt          = sy-mandt
        matnr          = iv_material
        werks          = iv_plant
        lgort          = iv_storage_location
        _scope         = '1'
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc = 1.
      DATA lo_conflict_error TYPE REF TO zcx_stock_allocation.
      CREATE OBJECT lo_conflict_error.
      lo_conflict_error->message =
        'Allocation scope is locked by another run'.
      RAISE EXCEPTION lo_conflict_error.
    ELSEIF sy-subrc <> 0.
      DATA lo_acquire_error TYPE REF TO zcx_stock_allocation.
      CREATE OBJECT lo_acquire_error.
      lo_acquire_error->message = 'Allocation lock acquisition failed'.
      RAISE EXCEPTION lo_acquire_error.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_allocation_lock~release.
    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
      OR iv_storage_location IS INITIAL.
      DATA lo_release_input_error TYPE REF TO zcx_stock_allocation.
      CREATE OBJECT lo_release_input_error.
      lo_release_input_error->message = 'Allocation lock release input is incomplete'.
      RAISE EXCEPTION lo_release_input_error.
    ENDIF.

    "Release the same material/plant/storage lock used by acquire.
    CALL FUNCTION 'DEQUEUE_EZSTOCKALLOC'
      EXPORTING
        mandt  = sy-mandt
        matnr  = iv_material
        werks  = iv_plant
        lgort  = iv_storage_location
        _scope = '1'
      EXCEPTIONS
        OTHERS = 1.
    IF sy-subrc <> 0.
      DATA lo_release_error TYPE REF TO zcx_stock_allocation.
      CREATE OBJECT lo_release_error.
      lo_release_error->message = 'Allocation lock release failed'.
      RAISE EXCEPTION lo_release_error.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
