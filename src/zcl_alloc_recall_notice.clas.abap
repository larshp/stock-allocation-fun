CLASS zcl_alloc_recall_notice DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_lot,
             material TYPE matnr,
             batch    TYPE string,
             quantity TYPE i,
           END OF ty_lot.
    TYPES ty_lot_tt TYPE STANDARD TABLE OF ty_lot WITH DEFAULT KEY.

    TYPES ty_recipients_tt TYPE STANDARD TABLE OF matnr WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_lots           TYPE ty_lot_tt
        iv_reason         TYPE string
      RETURNING
        VALUE(rv_message) TYPE string.

    METHODS recipients
      IMPORTING
        it_lots              TYPE ty_lot_tt
      RETURNING
        VALUE(rt_recipients) TYPE ty_recipients_tt.

    METHODS message
      IMPORTING
        iv_reason         TYPE string
        iv_count          TYPE i
      RETURNING
        VALUE(rv_message) TYPE string.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_rec,
             material TYPE matnr,
           END OF ty_rec.
    TYPES ty_rec_tt TYPE SORTED TABLE OF ty_rec WITH UNIQUE KEY material.

ENDCLASS.


CLASS zcl_alloc_recall_notice IMPLEMENTATION.

  METHOD message.
    rv_message = |Recall { iv_reason }: { iv_count } items|.
  ENDMETHOD.

  METHOD build.
    DATA lv_count TYPE i.
    DATA lv_qty   TYPE i.
    DATA lv_base  TYPE string.

    " The notice counts the lots in scope and the units they carry.
    LOOP AT it_lots INTO DATA(ls_lot).
      IF ls_lot-quantity <= 0.
        CONTINUE.
      ENDIF.

      lv_count = lv_count + 1.
      lv_qty = lv_qty + ls_lot-quantity.
    ENDLOOP.

    lv_base = message( iv_reason = iv_reason
                       iv_count  = lv_count ).

    rv_message = |{ lv_base }, { lv_qty } units|.
  ENDMETHOD.

  METHOD recipients.
    DATA lt_rec TYPE ty_rec_tt.
    DATA ls_rec TYPE ty_rec.

    " One notice goes to each material in scope, in material order.
    LOOP AT it_lots INTO DATA(ls_lot).
      IF ls_lot-quantity <= 0.
        CONTINUE.
      ENDIF.

      READ TABLE lt_rec TRANSPORTING NO FIELDS
        WITH KEY material = ls_lot-material.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      CLEAR ls_rec.
      ls_rec-material = ls_lot-material.
      INSERT ls_rec INTO TABLE lt_rec.
    ENDLOOP.

    LOOP AT lt_rec INTO ls_rec.
      APPEND ls_rec-material TO rt_recipients.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
