CLASS zcl_alloc_carton_seq DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material TYPE matnr,
             quantity TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_fill,
             carton_no TYPE i,
             material  TYPE matnr,
             quantity  TYPE i,
           END OF ty_fill.
    TYPES ty_fill_tt TYPE STANDARD TABLE OF ty_fill WITH DEFAULT KEY.

    METHODS pack
      IMPORTING
        it_items        TYPE ty_item_tt
        iv_capacity     TYPE i
      RETURNING
        VALUE(rt_fills) TYPE ty_fill_tt.

    METHODS carton_count
      IMPORTING
        it_fills        TYPE ty_fill_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_carton_seq IMPLEMENTATION.

  METHOD pack.
    DATA ls_fill   TYPE ty_fill.
    DATA lv_carton TYPE i.
    DATA lv_space  TYPE i.
    DATA lv_left   TYPE i.
    DATA lv_put    TYPE i.

    IF iv_capacity <= 0.
      RETURN.
    ENDIF.

    " Cartons are filled in the order the items arrive; an item that does not fit
    " the open carton carries over into the next one.
    LOOP AT it_items INTO DATA(ls_item).
      lv_left = ls_item-quantity.

      WHILE lv_left > 0.
        IF lv_space <= 0.
          lv_carton = lv_carton + 1.
          lv_space = iv_capacity.
        ENDIF.

        IF lv_left < lv_space.
          lv_put = lv_left.
        ELSE.
          lv_put = lv_space.
        ENDIF.

        CLEAR ls_fill.
        ls_fill-carton_no = lv_carton.
        ls_fill-material = ls_item-material.
        ls_fill-quantity = lv_put.
        APPEND ls_fill TO rt_fills.

        lv_left = lv_left - lv_put.
        lv_space = lv_space - lv_put.
      ENDWHILE.
    ENDLOOP.
  ENDMETHOD.

  METHOD carton_count.
    " The fills are appended in carton order, so the last carton number is the
    " highest one.
    LOOP AT it_fills INTO DATA(ls_fill).
      rv_count = ls_fill-carton_no.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
