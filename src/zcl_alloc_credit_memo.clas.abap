CLASS zcl_alloc_credit_memo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material TYPE matnr,
             net      TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_line,
             material TYPE matnr,
             net      TYPE i,
             tax      TYPE i,
             gross    TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_items        TYPE ty_item_tt
        iv_tax_percent  TYPE i
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS total
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS tax
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_credit_memo IMPLEMENTATION.

  METHOD build.
    DATA ls_line TYPE ty_line.

    " A negative tax rate is treated as no tax; the gross is always net plus tax.
    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-net <= 0.
        CONTINUE.
      ENDIF.

      CLEAR ls_line.
      ls_line-material = ls_item-material.
      ls_line-net = ls_item-net.

      IF iv_tax_percent > 0.
        ls_line-tax = ls_item-net * iv_tax_percent DIV 100.
      ENDIF.

      ls_line-gross = ls_line-net + ls_line-tax.
      APPEND ls_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

  METHOD total.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_total = rv_total + ls_line-gross.
    ENDLOOP.
  ENDMETHOD.

  METHOD tax.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_total = rv_total + ls_line-tax.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
