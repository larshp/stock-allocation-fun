CLASS zcl_alloc_recycle_split DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material           TYPE matnr,
             quantity           TYPE i,
             recyclable_percent TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_line,
             material   TYPE matnr,
             recyclable TYPE i,
             waste      TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS split
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS recycled
      IMPORTING
        it_lines      TYPE ty_line_tt
      RETURNING
        VALUE(rv_qty) TYPE i.

    METHODS recovery_percent
      IMPORTING
        it_lines      TYPE ty_line_tt
      RETURNING
        VALUE(rv_pct) TYPE i.

ENDCLASS.


CLASS zcl_alloc_recycle_split IMPLEMENTATION.

  METHOD split.
    DATA ls_line TYPE ty_line.
    DATA lv_pct  TYPE i.

    " The recyclable part is a share of the quantity; the rest is waste. The
    " share is held between nothing and everything.
    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-quantity <= 0.
        CONTINUE.
      ENDIF.

      lv_pct = ls_item-recyclable_percent.
      IF lv_pct < 0.
        lv_pct = 0.
      ELSEIF lv_pct > 100.
        lv_pct = 100.
      ENDIF.

      CLEAR ls_line.
      ls_line-material = ls_item-material.
      ls_line-recyclable = ls_item-quantity * lv_pct DIV 100.
      ls_line-waste = ls_item-quantity - ls_line-recyclable.
      APPEND ls_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

  METHOD recycled.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_qty = rv_qty + ls_line-recyclable.
    ENDLOOP.
  ENDMETHOD.

  METHOD recovery_percent.
    DATA lv_total TYPE i.
    DATA lv_rec   TYPE i.

    LOOP AT it_lines INTO DATA(ls_line).
      lv_total = lv_total + ls_line-recyclable + ls_line-waste.
      lv_rec = lv_rec + ls_line-recyclable.
    ENDLOOP.

    IF lv_total <= 0.
      RETURN.
    ENDIF.

    rv_pct = lv_rec * 100 DIV lv_total.
  ENDMETHOD.

ENDCLASS.
