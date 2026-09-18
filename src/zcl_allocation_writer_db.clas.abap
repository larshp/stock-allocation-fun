CLASS zcl_allocation_writer_db DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_allocation_writer.

ENDCLASS.


CLASS zcl_allocation_writer_db IMPLEMENTATION.

  METHOD zif_allocation_writer~write.
    DATA ls_log TYPE zstockalloc.

    ls_log-mandt     = sy-mandt.
    ls_log-run_id    = iv_run_id.
    ls_log-matnr     = iv_matnr.
    ls_log-werks     = iv_werks.
    ls_log-alloc_dat = sy-datum.
    ls_log-alloc_tim = sy-uzeit.
    ls_log-uname     = sy-uname.

    LOOP AT it_result INTO DATA(ls_result).
      LOOP AT ls_result-allocations INTO DATA(ls_allocation).
        ls_log-req_id    = ls_result-requirement_id.
        ls_log-lgort     = ls_allocation-lgort.
        ls_log-alloc_qty = ls_allocation-quantity.

        ls_log-matnr = ls_allocation-matnr.
        IF ls_log-matnr IS INITIAL.
          ls_log-matnr = iv_matnr.
        ENDIF.

        INSERT zstockalloc FROM @ls_log.
        rv_written = rv_written + 1.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
