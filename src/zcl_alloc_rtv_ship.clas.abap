CLASS zcl_alloc_rtv_ship DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material  TYPE matnr,
             quantity  TYPE i,
             unit_cost TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_line,
             material TYPE matnr,
             quantity TYPE i,
             value    TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS total
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS line_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_rtv_ship IMPLEMENTATION.

  METHOD build.
    DATA ls_line TYPE ty_line.

    " A return-to-vendor shipment values each line at cost; an empty or
    " valueless line is left off the shipment.
    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-quantity <= 0 OR ls_item-unit_cost <= 0.
        CONTINUE.
      ENDIF.

      CLEAR ls_line.
      ls_line-material = ls_item-material.
      ls_line-quantity = ls_item-quantity.
      ls_line-value = ls_item-quantity * ls_item-unit_cost.
      APPEND ls_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

  METHOD total.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_total = rv_total + ls_line-value.
    ENDLOOP.
  ENDMETHOD.

  METHOD line_count.
    rv_count = lines( it_lines ).
  ENDMETHOD.

ENDCLASS.
