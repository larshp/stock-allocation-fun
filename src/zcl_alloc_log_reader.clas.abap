CLASS zcl_alloc_log_reader DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_log_tt TYPE STANDARD TABLE OF zstockalloc WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_run_summary,
             run_id        TYPE zstock_run_id,
             materials     TYPE i,
             positions     TYPE i,
             allocated_qty TYPE menge_d,
           END OF ty_run_summary.
    TYPES ty_run_summary_tt TYPE STANDARD TABLE OF ty_run_summary
      WITH DEFAULT KEY.

    METHODS read_run
      IMPORTING
        iv_run_id     TYPE zstock_run_id
      RETURNING
        VALUE(rt_log) TYPE ty_log_tt.

    METHODS summarize_run
      IMPORTING
        iv_run_id         TYPE zstock_run_id
      RETURNING
        VALUE(rs_summary) TYPE ty_run_summary.

    METHODS summarize_all
      RETURNING
        VALUE(rt_summary) TYPE ty_run_summary_tt.

ENDCLASS.


CLASS zcl_alloc_log_reader IMPLEMENTATION.

  METHOD read_run.
    SELECT * FROM zstockalloc INTO TABLE @rt_log
      WHERE run_id = @iv_run_id.
  ENDMETHOD.

  METHOD summarize_run.
    DATA ls_last_matnr TYPE matnr.

    SELECT * FROM zstockalloc INTO TABLE @DATA(lt_log)
      WHERE run_id = @iv_run_id
      ORDER BY matnr.

    rs_summary-run_id = iv_run_id.

    LOOP AT lt_log INTO DATA(ls_log).
      IF ls_log-matnr <> ls_last_matnr.
        rs_summary-materials = rs_summary-materials + 1.
        ls_last_matnr = ls_log-matnr.
      ENDIF.

      rs_summary-positions = rs_summary-positions + 1.
      rs_summary-allocated_qty = rs_summary-allocated_qty + ls_log-alloc_qty.
    ENDLOOP.
  ENDMETHOD.

  METHOD summarize_all.
    DATA ls_summary     TYPE ty_run_summary.
    DATA ls_last_run    TYPE zstock_run_id.
    DATA ls_last_matnr  TYPE matnr.

    SELECT * FROM zstockalloc INTO TABLE @DATA(lt_log)
      ORDER BY run_id, matnr.

    LOOP AT lt_log INTO DATA(ls_log).
      IF ls_log-run_id <> ls_last_run.
        IF ls_summary-run_id IS NOT INITIAL.
          APPEND ls_summary TO rt_summary.
        ENDIF.
        CLEAR ls_summary.
        CLEAR ls_last_matnr.
        ls_summary-run_id = ls_log-run_id.
        ls_last_run = ls_log-run_id.
      ENDIF.

      IF ls_log-matnr <> ls_last_matnr.
        ls_summary-materials = ls_summary-materials + 1.
        ls_last_matnr = ls_log-matnr.
      ENDIF.

      ls_summary-positions = ls_summary-positions + 1.
      ls_summary-allocated_qty = ls_summary-allocated_qty + ls_log-alloc_qty.
    ENDLOOP.

    IF ls_summary-run_id IS NOT INITIAL.
      APPEND ls_summary TO rt_summary.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
