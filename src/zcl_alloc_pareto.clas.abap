CLASS zcl_alloc_pareto DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             item_id  TYPE string,
             quantity TYPE menge_d,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_row,
             rank       TYPE i,
             item_id    TYPE string,
             quantity   TYPE menge_d,
             share_x100 TYPE i,
             cumul_x100 TYPE i,
             in_vital   TYPE abap_bool,
           END OF ty_row.
    TYPES ty_row_tt TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_items       TYPE ty_item_tt
      RETURNING
        VALUE(rt_rows) TYPE ty_row_tt.

    METHODS vital_count
      IMPORTING
        it_rows         TYPE ty_row_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS total_of
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rv_total) TYPE menge_d.

  PRIVATE SECTION.
    CONSTANTS c_vital_limit TYPE i VALUE 80.

ENDCLASS.


CLASS zcl_alloc_pareto IMPLEMENTATION.

  METHOD total_of.
    LOOP AT it_items INTO DATA(ls_item).
      rv_total = rv_total + ls_item-quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD build.
    DATA lt_items  TYPE ty_item_tt.
    DATA ls_row    TYPE ty_row.
    DATA lv_total  TYPE menge_d.
    DATA lv_cumul  TYPE menge_d.
    DATA lv_before TYPE i.
    DATA lv_rank   TYPE i.

    lv_total = total_of( it_items ).
    IF lv_total <= 0.
      RETURN.
    ENDIF.

    lt_items = it_items.
    SORT lt_items BY quantity DESCENDING.

    LOOP AT lt_items INTO DATA(ls_item).
      lv_rank = lv_rank + 1.

      " The share reached before this item decides whether it is still vital.
      lv_before = lv_cumul * 100 DIV lv_total.
      lv_cumul = lv_cumul + ls_item-quantity.

      CLEAR ls_row.
      ls_row-rank = lv_rank.
      ls_row-item_id = ls_item-item_id.
      ls_row-quantity = ls_item-quantity.
      ls_row-share_x100 = ls_item-quantity * 100 DIV lv_total.
      ls_row-cumul_x100 = lv_cumul * 100 DIV lv_total.

      IF lv_before < c_vital_limit.
        ls_row-in_vital = abap_true.
      ENDIF.

      APPEND ls_row TO rt_rows.
    ENDLOOP.
  ENDMETHOD.

  METHOD vital_count.
    LOOP AT it_rows INTO DATA(ls_row).
      IF ls_row-in_vital = abap_true.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
