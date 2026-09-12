CLASS zcl_stock_commitment DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_open,
             lgort TYPE lgort_d,
             qty   TYPE menge_d,
           END OF ty_open.
    TYPES ty_open_tt TYPE STANDARD TABLE OF ty_open WITH DEFAULT KEY.

    TYPES ty_resv_tt TYPE STANDARD TABLE OF zstockresv WITH DEFAULT KEY.

    METHODS commit
      IMPORTING
        iv_run_id         TYPE zstock_run_id
        iv_matnr          TYPE matnr
        iv_werks          TYPE werks_d
        it_result         TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rv_written) TYPE i.

    METHODS release_run
      IMPORTING
        iv_run_id TYPE zstock_run_id.

    METHODS read_open
      IMPORTING
        iv_matnr       TYPE matnr
        iv_werks       TYPE werks_d
      RETURNING
        VALUE(rt_open) TYPE ty_open_tt.

    METHODS read_expired
      IMPORTING
        iv_before      TYPE d
      RETURNING
        VALUE(rt_resv) TYPE ty_resv_tt.

    METHODS purge_before
      IMPORTING
        iv_before         TYPE d
      RETURNING
        VALUE(rv_deleted) TYPE i.

    METHODS purge_older_than
      IMPORTING
        iv_retention_days TYPE i
      RETURNING
        VALUE(rv_deleted) TYPE i.

ENDCLASS.


CLASS zcl_stock_commitment IMPLEMENTATION.

  METHOD commit.
    DATA ls_resv  TYPE zstockresv.
    DATA ls_alloc TYPE zcl_stock_allocator=>ty_allocation.

    LOOP AT it_result INTO DATA(ls_result).
      LOOP AT ls_result-allocations INTO ls_alloc.
        CLEAR ls_resv.

        ls_resv-mandt = sy-mandt.
        ls_resv-werks = iv_werks.
        ls_resv-lgort = ls_alloc-lgort.
        ls_resv-run_id = iv_run_id.
        ls_resv-req_id = ls_result-requirement_id.
        ls_resv-qty = ls_alloc-quantity.
        ls_resv-created_by = sy-uname.
        ls_resv-created_dat = sy-datum.

        ls_resv-matnr = ls_alloc-matnr.
        IF ls_resv-matnr IS INITIAL.
          ls_resv-matnr = iv_matnr.
        ENDIF.

        INSERT zstockresv FROM @ls_resv.
        rv_written = rv_written + 1.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD release_run.
    DELETE FROM zstockresv WHERE run_id = @iv_run_id.
  ENDMETHOD.

  METHOD read_open.
    DATA ls_open TYPE ty_open.

    SELECT lgort,
           qty
      FROM zstockresv
      INTO TABLE @DATA(lt_resv)
      WHERE matnr = @iv_matnr
        AND werks = @iv_werks
      ORDER BY lgort.

    LOOP AT lt_resv INTO DATA(ls_resv).
      IF ls_open-lgort IS NOT INITIAL AND ls_resv-lgort <> ls_open-lgort.
        APPEND ls_open TO rt_open.
        CLEAR ls_open.
      ENDIF.

      ls_open-lgort = ls_resv-lgort.
      ls_open-qty = ls_open-qty + ls_resv-qty.
    ENDLOOP.

    IF ls_open-lgort IS NOT INITIAL.
      APPEND ls_open TO rt_open.
    ENDIF.
  ENDMETHOD.

  METHOD read_expired.
    SELECT * FROM zstockresv INTO TABLE @rt_resv
      WHERE created_dat < @iv_before.
  ENDMETHOD.

  METHOD purge_before.
    DELETE FROM zstockresv WHERE created_dat < @iv_before.
    rv_deleted = sy-dbcnt.
  ENDMETHOD.

  METHOD purge_older_than.
    DATA lv_cutoff TYPE d.

    lv_cutoff = sy-datum - iv_retention_days.
    rv_deleted = purge_before( lv_cutoff ).
  ENDMETHOD.

ENDCLASS.
