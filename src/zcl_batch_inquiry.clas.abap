CLASS zcl_batch_inquiry DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_batch,
             matnr       TYPE matnr,
             lgort       TYPE lgort_d,
             charg       TYPE c LENGTH 10,
             expiry_date TYPE d,
             quantity    TYPE menge_d,
           END OF ty_batch.
    TYPES ty_batch_tt TYPE STANDARD TABLE OF ty_batch WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_summary,
             batches         TYPE i,
             quantity        TYPE menge_d,
             earliest_expiry TYPE d,
           END OF ty_summary.

    TYPES: BEGIN OF ty_result,
             batches TYPE ty_batch_tt,
             summary TYPE ty_summary,
           END OF ty_result.

    METHODS constructor
      IMPORTING
        io_stock_reader TYPE REF TO zif_stock_reader.

    METHODS inquiry
      IMPORTING
        iv_matnr         TYPE matnr
        iv_werks         TYPE werks_d
      RETURNING
        VALUE(rs_result) TYPE ty_result.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_work,
             lgort       TYPE lgort_d,
             charg       TYPE c LENGTH 10,
             expiry_date TYPE d,
             sort_date   TYPE d,
             quantity    TYPE menge_d,
           END OF ty_work.
    TYPES ty_work_tt TYPE STANDARD TABLE OF ty_work WITH DEFAULT KEY.

    DATA mo_stock_reader TYPE REF TO zif_stock_reader.

ENDCLASS.


CLASS zcl_batch_inquiry IMPLEMENTATION.

  METHOD constructor.
    mo_stock_reader = io_stock_reader.
  ENDMETHOD.

  METHOD inquiry.
    DATA lt_stock TYPE zif_stock_reader=>ty_stock_tt.
    DATA lt_work  TYPE ty_work_tt.
    DATA lv_date  TYPE d.
    DATA ls_batch TYPE ty_batch.

    lt_stock = mo_stock_reader->read_stock( iv_matnr = iv_matnr
                                            iv_werks = iv_werks ).

    LOOP AT lt_stock INTO DATA(ls_stock).
      lv_date = ls_stock-expiry_date.
      IF lv_date IS INITIAL.
        lv_date = '99991231'.
      ENDIF.

      APPEND VALUE #( lgort       = ls_stock-lgort
                      charg       = ls_stock-charg
                      expiry_date = ls_stock-expiry_date
                      sort_date   = lv_date
                      quantity    = ls_stock-unrestricted_qty ) TO lt_work.
    ENDLOOP.

    " first expiry first, batches without a date last
    SORT lt_work BY sort_date ASCENDING
                    lgort ASCENDING
                    charg ASCENDING.

    LOOP AT lt_work INTO DATA(ls_work).
      CLEAR ls_batch.
      ls_batch-matnr = iv_matnr.
      ls_batch-lgort = ls_work-lgort.
      ls_batch-charg = ls_work-charg.
      ls_batch-expiry_date = ls_work-expiry_date.
      ls_batch-quantity = ls_work-quantity.
      APPEND ls_batch TO rs_result-batches.

      rs_result-summary-batches = rs_result-summary-batches + 1.
      rs_result-summary-quantity = rs_result-summary-quantity
        + ls_work-quantity.

      IF ls_work-expiry_date IS NOT INITIAL
          AND ( rs_result-summary-earliest_expiry IS INITIAL
             OR ls_work-expiry_date < rs_result-summary-earliest_expiry ).
        rs_result-summary-earliest_expiry = ls_work-expiry_date.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
