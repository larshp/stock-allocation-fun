CLASS zcl_alloc_disposal_cost DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             quantity  TYPE i,
             unit_cost TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS cost
      IMPORTING
        iv_quantity    TYPE i
        iv_unit_cost   TYPE i
      RETURNING
        VALUE(rv_cost) TYPE i.

    METHODS cost_of
      IMPORTING
        is_line        TYPE ty_line
      RETURNING
        VALUE(rv_cost) TYPE i.

    METHODS total
      IMPORTING
        it_lines       TYPE ty_line_tt
      RETURNING
        VALUE(rv_cost) TYPE i.

ENDCLASS.


CLASS zcl_alloc_disposal_cost IMPLEMENTATION.

  METHOD cost.
    " A disposal costs a unit rate per item; a bad input costs nothing.
    IF iv_quantity <= 0 OR iv_unit_cost <= 0.
      RETURN.
    ENDIF.

    rv_cost = iv_quantity * iv_unit_cost.
  ENDMETHOD.

  METHOD cost_of.
    rv_cost = cost( iv_quantity  = is_line-quantity
                    iv_unit_cost = is_line-unit_cost ).
  ENDMETHOD.

  METHOD total.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_cost = rv_cost + cost_of( ls_line ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
