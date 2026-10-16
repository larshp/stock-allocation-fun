CLASS zcl_alloc_location_rank DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             lgort    TYPE lgort_d,
             quantity TYPE menge_d,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_line,
             rank     TYPE i,
             lgort    TYPE lgort_d,
             quantity TYPE menge_d,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS rank
      IMPORTING
        it_stock        TYPE ty_item_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

ENDCLASS.


CLASS zcl_alloc_location_rank IMPLEMENTATION.

  METHOD rank.
    DATA lt_work TYPE ty_item_tt.
    DATA ls_line TYPE ty_line.

    lt_work = it_stock.
    SORT lt_work BY quantity DESCENDING
                    lgort ASCENDING.

    LOOP AT lt_work INTO DATA(ls_item).
      CLEAR ls_line.
      ls_line-rank = sy-tabix.
      ls_line-lgort = ls_item-lgort.
      ls_line-quantity = ls_item-quantity.
      APPEND ls_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
