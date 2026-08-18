CLASS zcl_allocation_logger_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_allocation_logger.

  PRIVATE SECTION.
    TYPES ty_log_entries TYPE STANDARD TABLE OF zstock_alog WITH EMPTY KEY.
ENDCLASS.

CLASS zcl_allocation_logger_sap IMPLEMENTATION.
  METHOD zif_allocation_logger~write.
    DATA(lv_run_mode) = COND #( WHEN iv_simulation = abap_true
                                THEN 'S'
                                ELSE 'P' ).
    DATA lt_log_entries TYPE ty_log_entries.

    LOOP AT it_allocations INTO DATA(ls_allocation).
      APPEND VALUE #(
        request_id        = ls_allocation-request_id
        run_mode          = lv_run_mode
        allocation_status = ls_allocation-status
        posting_status    = ls_allocation-posting_status
        allocated_qty     = ls_allocation-allocated_qty
        reservation_id    = ls_allocation-document_id
        log_message       = ls_allocation-posting_message
        logged_on         = sy-datum
        logged_at         = sy-uzeit
        logged_by         = sy-uname ) TO lt_log_entries.
    ENDLOOP.

    IF lt_log_entries IS INITIAL.
      rv_saved = abap_true.
      RETURN.
    ENDIF.

    MODIFY zstock_alog FROM TABLE @lt_log_entries.
    rv_saved = xsdbool( sy-subrc = 0 ).
    IF rv_saved = abap_true.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
