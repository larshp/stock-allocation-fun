CLASS zcl_alloc_scrap_value DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material   TYPE matnr,
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

    METHODS value_of
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


CLASS zcl_alloc_scrap_value IMPLEMENTATION.

  METHOD value.
    " A negative quantity or value contributes nothing rather than reducing the
    " total.
    IF iv_quantity <= 0 OR iv_unit_value < 0.
      RETURN.
    ENDIF.

    rv_value = iv_quantity * iv_unit_value.
  ENDMETHOD.

  METHOD value_of.
    rv_value = value( iv_quantity   = is_line-quantity
                      iv_unit_value = is_line-unit_value ).
  ENDMETHOD.

  METHOD total.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_value = rv_value + value_of( ls_line ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
