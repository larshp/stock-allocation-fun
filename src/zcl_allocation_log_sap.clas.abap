CLASS zcl_allocation_log_sap DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_allocation_log.
ENDCLASS.

CLASS zcl_allocation_log_sap IMPLEMENTATION.
  METHOD zif_allocation_log~record_run.
    DATA lv_shortage TYPE zif_stock_allocation=>ty_quantity.

    LOOP AT it_allocations INTO DATA(ls_allocation).
      lv_shortage = lv_shortage + ls_allocation-shortage_qty.
    ENDLOOP.

    DATA(ls_header) = VALUE bal_s_log(
      object = 'ZSTOCKALLOC'
      subobject = 'RUN'
      extnumber = |{ iv_material }/{ iv_plant }/{ iv_storage_location }|
      aldate = sy-datum
      altime = sy-uzeit
      aluser = sy-uname ).
    DATA lv_handle TYPE balloghndl.

    CALL FUNCTION 'BAL_LOG_CREATE'
      EXPORTING
        i_s_log                 = ls_header
      IMPORTING
        e_log_handle            = lv_handle
      EXCEPTIONS
        log_header_inconsistent = 1
        OTHERS                  = 2.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    DATA(lv_text) = |Allocated { lines( it_allocations ) } demands; shortage { lv_shortage }|.
    CALL FUNCTION 'BAL_LOG_MSG_ADD_FREE_TEXT'
      EXPORTING
        i_log_handle = lv_handle
        i_msgty      = 'S'
        i_text       = lv_text
      EXCEPTIONS
        OTHERS       = 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    DATA lt_handles TYPE bal_t_logh.
    APPEND lv_handle TO lt_handles.
    CALL FUNCTION 'BAL_DB_SAVE'
      EXPORTING
        i_t_log_handle   = lt_handles
      EXCEPTIONS
        log_not_found    = 1
        save_not_allowed = 2
        numbering_error  = 3
        OTHERS           = 4.
    rv_recorded = xsdbool( sy-subrc = 0 ).
  ENDMETHOD.
ENDCLASS.
