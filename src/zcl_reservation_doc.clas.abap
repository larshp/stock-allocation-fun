CLASS zcl_reservation_doc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_resv_tt TYPE STANDARD TABLE OF zstockresv WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_summary,
             doc_id      TYPE zstock_run_id,
             positions   TYPE i,
             materials   TYPE i,
             quantity    TYPE menge_d,
             created_dat TYPE d,
           END OF ty_summary.

    METHODS constructor
      IMPORTING
        io_commitment TYPE REF TO zcl_stock_commitment OPTIONAL.

    METHODS create
      IMPORTING
        iv_doc_id         TYPE zstock_run_id
        iv_matnr          TYPE matnr
        iv_werks          TYPE werks_d
        it_result         TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rv_written) TYPE i.

    METHODS items
      IMPORTING
        iv_doc_id      TYPE zstock_run_id
      RETURNING
        VALUE(rt_resv) TYPE ty_resv_tt.

    METHODS summarize
      IMPORTING
        iv_doc_id         TYPE zstock_run_id
      RETURNING
        VALUE(rs_summary) TYPE ty_summary.

    METHODS release
      IMPORTING
        iv_doc_id TYPE zstock_run_id.

  PRIVATE SECTION.
    DATA mo_commitment TYPE REF TO zcl_stock_commitment.

ENDCLASS.


CLASS zcl_reservation_doc IMPLEMENTATION.

  METHOD constructor.
    IF io_commitment IS SUPPLIED.
      mo_commitment = io_commitment.
    ENDIF.
    IF mo_commitment IS NOT BOUND.
      mo_commitment = NEW zcl_stock_commitment( ).
    ENDIF.
  ENDMETHOD.

  METHOD create.
    rv_written = mo_commitment->commit( iv_run_id = iv_doc_id
                                        iv_matnr  = iv_matnr
                                        iv_werks  = iv_werks
                                        it_result = it_result ).
  ENDMETHOD.

  METHOD items.
    SELECT * FROM zstockresv INTO TABLE @rt_resv
      WHERE run_id = @iv_doc_id
      ORDER BY matnr, lgort, req_id.
  ENDMETHOD.

  METHOD summarize.
    DATA ls_last_matnr TYPE matnr.

    rs_summary-doc_id = iv_doc_id.

    LOOP AT items( iv_doc_id ) INTO DATA(ls_resv).
      IF ls_resv-matnr <> ls_last_matnr.
        rs_summary-materials = rs_summary-materials + 1.
        ls_last_matnr = ls_resv-matnr.
      ENDIF.

      rs_summary-positions = rs_summary-positions + 1.
      rs_summary-quantity = rs_summary-quantity + ls_resv-qty.

      IF rs_summary-created_dat IS INITIAL
          OR ls_resv-created_dat < rs_summary-created_dat.
        rs_summary-created_dat = ls_resv-created_dat.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD release.
    mo_commitment->release_run( iv_doc_id ).
  ENDMETHOD.

ENDCLASS.
