CLASS zcl_stock_lock_gateway_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_stock_lock_gateway.
ENDCLASS.

CLASS zcl_stock_lock_gateway_sap IMPLEMENTATION.
  METHOD zif_stock_lock_gateway~acquire.
    IF iv_wait_for_lock <> abap_false AND iv_wait_for_lock <> abap_true.
      rs_result-acquired = abap_false.
      rs_result-message = 'Stock lock wait flag must be X or blank'.
      RETURN.
    ENDIF.

    IF iv_material IS INITIAL OR iv_plant IS INITIAL.
      rs_result-acquired = abap_false.
      rs_result-message = 'Stock lock material and plant are required'.
      RETURN.
    ENDIF.

    CALL FUNCTION 'ENQUEUE_EZSTOCK_POOL'
      EXPORTING
        matnr          = iv_material
        werks          = iv_plant
        lgort          = space
        x_lgort        = abap_false
        _scope         = '3'
        _wait          = iv_wait_for_lock
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      rs_result-acquired = abap_false.
      rs_result-message = 'Stock plant is locked by another process'.
      RETURN.
    ENDIF.

    rs_result-acquired = abap_true.
  ENDMETHOD.

  METHOD zif_stock_lock_gateway~release.
    IF iv_material IS INITIAL OR iv_plant IS INITIAL.
      RETURN.
    ENDIF.

    CALL FUNCTION 'DEQUEUE_EZSTOCK_POOL'
      EXPORTING
        matnr   = iv_material
        werks   = iv_plant
        lgort   = space
        x_lgort = abap_false
        _scope  = '3'.
  ENDMETHOD.
ENDCLASS.
