CLASS zcl_alloc_refund DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material   TYPE matnr,
             quantity   TYPE i,
             unit_price TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS value
      IMPORTING
        iv_quantity     TYPE i
        iv_unit_price   TYPE i
      RETURNING
        VALUE(rv_value) TYPE i.

    METHODS for_line
      IMPORTING
        is_line         TYPE ty_line
      RETURNING
        VALUE(rv_value) TYPE i.

    METHODS total
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_value) TYPE i.

ENDCLASS.


CLASS zcl_alloc_refund IMPLEMENTATION.

  METHOD value.
    " A refund is never negative: a bad quantity or price contributes nothing.
    IF iv_quantity <= 0 OR iv_unit_price <= 0.
      RETURN.
    ENDIF.

    rv_value = iv_quantity * iv_unit_price.
  ENDMETHOD.

  METHOD for_line.
    rv_value = value( iv_quantity   = is_line-quantity
                      iv_unit_price = is_line-unit_price ).
  ENDMETHOD.

  METHOD total.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_value = rv_value + for_line( ls_line ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
