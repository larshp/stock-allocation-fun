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
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.

    CALL FUNCTION 'ENQUEUE_EZSTOCKALLOC'
      EXPORTING
        matnr = iv_material
        werks = iv_plant
        lgort = iv_storage_location
        charg = iv_batch.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_allocation_lock~release.
    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_storage_location IS INITIAL.
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.

    CALL FUNCTION 'DEQUEUE_EZSTOCKALLOC'
      EXPORTING
        matnr = iv_material
        werks = iv_plant
        lgort = iv_storage_location
        charg = iv_batch.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
