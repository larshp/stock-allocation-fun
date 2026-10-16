CLASS zcl_alloc_rma DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material TYPE matnr,
             quantity TYPE menge_d,
             reason   TYPE string,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS add
      IMPORTING
        is_line TYPE ty_line.

    METHODS total_quantity
      RETURNING
        VALUE(rv_total) TYPE menge_d.

    METHODS line_count
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS line_list
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS clear.

  PRIVATE SECTION.
    DATA mt_lines TYPE ty_line_tt.

ENDCLASS.


CLASS zcl_alloc_rma IMPLEMENTATION.

  METHOD add.
    APPEND is_line TO mt_lines.
  ENDMETHOD.

  METHOD total_quantity.
    LOOP AT mt_lines INTO DATA(ls_line).
      rv_total = rv_total + ls_line-quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD line_count.
    rv_count = lines( mt_lines ).
  ENDMETHOD.

  METHOD line_list.
    rt_lines = mt_lines.
  ENDMETHOD.

  METHOD clear.
    CLEAR mt_lines.
  ENDMETHOD.

ENDCLASS.
