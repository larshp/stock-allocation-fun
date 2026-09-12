CLASS zcl_alloc_run_header DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS c_status_running TYPE zstockrun-status VALUE 'R'.
    CONSTANTS c_status_done    TYPE zstockrun-status VALUE 'D'.

    TYPES ty_header_tt TYPE STANDARD TABLE OF zstockrun WITH DEFAULT KEY.

    METHODS start_run
      IMPORTING
        iv_run_id         TYPE zstock_run_id
        iv_matnr          TYPE matnr
        iv_werks          TYPE werks_d
      RETURNING
        VALUE(rv_written) TYPE i.

    METHODS finish_run
      IMPORTING
        iv_run_id         TYPE zstock_run_id
        iv_matnr          TYPE matnr
        iv_werks          TYPE werks_d
        it_result         TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rv_written) TYPE i.

    METHODS read_run
      IMPORTING
        iv_run_id        TYPE zstock_run_id
      RETURNING
        VALUE(rt_header) TYPE ty_header_tt.

    METHODS read_all
      RETURNING
        VALUE(rt_header) TYPE ty_header_tt.

ENDCLASS.


CLASS zcl_alloc_run_header IMPLEMENTATION.

  METHOD start_run.
    DATA ls_header TYPE zstockrun.

    ls_header-mandt = sy-mandt.
    ls_header-run_id = iv_run_id.
    ls_header-matnr = iv_matnr.
    ls_header-werks = iv_werks.
    ls_header-status = c_status_running.
    ls_header-created_by = sy-uname.

    INSERT zstockrun FROM @ls_header.
    rv_written = 1.
  ENDMETHOD.

  METHOD finish_run.
    DATA ls_header TYPE zstockrun.

    ls_header-mandt = sy-mandt.
    ls_header-run_id = iv_run_id.
    ls_header-matnr = iv_matnr.
    ls_header-werks = iv_werks.
    ls_header-status = c_status_done.
    ls_header-created_by = sy-uname.

    LOOP AT it_result INTO DATA(ls_result).
      ls_header-req_qty = ls_header-req_qty + ls_result-requested_qty.
      ls_header-alloc_qty = ls_header-alloc_qty + ls_result-allocated_qty.
      ls_header-short_qty = ls_header-short_qty + ls_result-shortage_qty.
      ls_header-item_count = ls_header-item_count + 1.
    ENDLOOP.

    MODIFY zstockrun FROM @ls_header.
    rv_written = 1.
  ENDMETHOD.

  METHOD read_run.
    SELECT * FROM zstockrun INTO TABLE @rt_header
      WHERE run_id = @iv_run_id
      ORDER BY matnr.
  ENDMETHOD.

  METHOD read_all.
    SELECT * FROM zstockrun INTO TABLE @rt_header
      ORDER BY run_id, matnr.
  ENDMETHOD.

ENDCLASS.
