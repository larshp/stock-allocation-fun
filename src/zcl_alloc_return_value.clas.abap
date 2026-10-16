CLASS zcl_alloc_return_value DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             quantity   TYPE i,
             unit_value TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS value
      IMPORTING
        iv_quantity     TYPE i
        iv_unit_value   TYPE i
      RETURNING
        VALUE(rv_value) TYPE i.

    METHODS total
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_value) TYPE i.

    METHODS per_unit
      IMPORTING
        iv_total       TYPE i
        iv_quantity    TYPE i
      RETURNING
        VALUE(rv_unit) TYPE i.

ENDCLASS.


CLASS zcl_alloc_return_value IMPLEMENTATION.

  METHOD value.
    " Returned stock is valued at the unit value; a bad input is worth nothing.
    IF iv_quantity <= 0 OR iv_unit_value <= 0.
      RETURN.
    ENDIF.

    rv_value = iv_quantity * iv_unit_value.
  ENDMETHOD.

  METHOD total.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_value = rv_value + value( iv_quantity   = ls_line-quantity
                                   iv_unit_value = ls_line-unit_value ).
    ENDLOOP.
  ENDMETHOD.

  METHOD per_unit.
    IF iv_total <= 0 OR iv_quantity <= 0.
      RETURN.
    ENDIF.

    rv_unit = iv_total DIV iv_quantity.
  ENDMETHOD.

ENDCLASS.
