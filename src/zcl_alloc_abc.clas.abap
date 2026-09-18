CLASS zcl_alloc_abc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             matnr    TYPE matnr,
             quantity TYPE menge_d,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_line,
             matnr     TYPE matnr,
             quantity  TYPE menge_d,
             share_pct TYPE i,
             cum_pct   TYPE i,
             class     TYPE c LENGTH 1,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS classify
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_work,
             matnr    TYPE matnr,
             quantity TYPE menge_d,
           END OF ty_work.
    TYPES ty_work_tt TYPE STANDARD TABLE OF ty_work WITH DEFAULT KEY.

    METHODS class_of
      IMPORTING
        iv_cum_before   TYPE i
      RETURNING
        VALUE(rv_class) TYPE zcl_alloc_abc=>ty_line-class.

ENDCLASS.


CLASS zcl_alloc_abc IMPLEMENTATION.

  METHOD class_of.
    IF iv_cum_before < 80.
      rv_class = 'A'.
    ELSEIF iv_cum_before < 95.
      rv_class = 'B'.
    ELSE.
      rv_class = 'C'.
    ENDIF.
  ENDMETHOD.

  METHOD classify.
    DATA lt_work   TYPE ty_work_tt.
    DATA ls_line   TYPE ty_line.
    DATA lv_total  TYPE menge_d.
    DATA lv_cum    TYPE i.
    DATA lv_share  TYPE i.

    LOOP AT it_items INTO DATA(ls_item).
      APPEND VALUE #( matnr    = ls_item-matnr
                      quantity = ls_item-quantity ) TO lt_work.
      lv_total = lv_total + ls_item-quantity.
    ENDLOOP.

    SORT lt_work BY quantity DESCENDING
                    matnr ASCENDING.

    CLEAR lv_cum.

    LOOP AT lt_work INTO DATA(ls_work).
      CLEAR ls_line.
      ls_line-matnr = ls_work-matnr.
      ls_line-quantity = ls_work-quantity.

      IF lv_total > 0.
        lv_share = ls_work-quantity * 100 DIV lv_total.
      ELSE.
        lv_share = 0.
      ENDIF.

      ls_line-share_pct = lv_share.
      ls_line-class = class_of( lv_cum ).

      lv_cum = lv_cum + lv_share.
      ls_line-cum_pct = lv_cum.

      APPEND ls_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
