CLASS zcl_alloc_disposal DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material TYPE matnr,
             quantity TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    METHODS propose
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS total
      IMPORTING
        it_lines      TYPE ty_line_tt
      RETURNING
        VALUE(rv_qty) TYPE i.

    METHODS line_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_disposal IMPLEMENTATION.

  METHOD propose.
    " Only materials with a real quantity are proposed for disposal.
    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-quantity <= 0.
        CONTINUE.
      ENDIF.

      APPEND ls_item TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

  METHOD total.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_qty = rv_qty + ls_line-quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD line_count.
    rv_count = lines( it_lines ).
  ENDMETHOD.

ENDCLASS.
