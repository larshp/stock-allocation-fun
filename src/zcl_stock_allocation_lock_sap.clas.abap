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

    CALL FUNCTION 'ENQUEUE_EZSTOCKALLOC'
      EXPORTING
        matnr  = iv_material
        werks  = iv_plant
        lgort  = iv_storage_location
        charg  = iv_batch
      EXCEPTIONS
        OTHERS = 1.
    IF sy-subrc <> 0.
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

    CALL FUNCTION 'DEQUEUE_EZSTOCKALLOC'
      EXPORTING
        matnr  = iv_material
        werks  = iv_plant
        lgort  = iv_storage_location
        charg  = iv_batch
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
