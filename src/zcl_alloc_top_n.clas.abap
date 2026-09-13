CLASS zcl_alloc_top_n DEFINITION
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
             rank      TYPE i,
             matnr     TYPE matnr,
             quantity  TYPE menge_d,
             share_pct TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS top
      IMPORTING
        it_items        TYPE ty_item_tt
        iv_n            TYPE i DEFAULT 0
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

ENDCLASS.


CLASS zcl_alloc_top_n IMPLEMENTATION.

  METHOD top.
    DATA lt_work  TYPE ty_item_tt.
    DATA ls_line  TYPE ty_line.
    DATA lv_total TYPE menge_d.
    DATA lv_rank  TYPE i.
    DATA lv_limit TYPE i.

    lt_work = it_items.
    SORT lt_work BY quantity DESCENDING
                    matnr ASCENDING.

    LOOP AT lt_work INTO DATA(ls_item).
      lv_total = lv_total + ls_item-quantity.
    ENDLOOP.

    IF iv_n > 0.
      lv_limit = iv_n.
    ELSE.
      lv_limit = lines( lt_work ).
    ENDIF.

    LOOP AT lt_work INTO DATA(ls_work).
      lv_rank = lv_rank + 1.
      IF lv_rank > lv_limit.
        EXIT.
      ENDIF.

      CLEAR ls_line.
      ls_line-rank = lv_rank.
      ls_line-matnr = ls_work-matnr.
      ls_line-quantity = ls_work-quantity.
      IF lv_total > 0.
        ls_line-share_pct = ls_work-quantity * 100 DIV lv_total.
      ENDIF.

      APPEND ls_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
