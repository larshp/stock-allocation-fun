CLASS zcl_alloc_drv_weight DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             name   TYPE string,
             value  TYPE i,
             weight TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS weight_of
      IMPORTING
        iv_value       TYPE i
        iv_weight      TYPE i
      RETURNING
        VALUE(rv_part) TYPE i.

    METHODS weighted
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS total_weight
      IMPORTING
        it_lines         TYPE ty_line_tt
      RETURNING
        VALUE(rv_weight) TYPE i.

ENDCLASS.


CLASS zcl_alloc_drv_weight IMPLEMENTATION.

  METHOD weight_of.
    " A driver is taken at the share of its weight.
    rv_part = iv_value * iv_weight DIV 100.
  ENDMETHOD.

  METHOD weighted.
    " The weighted total adds every driver at its own weight.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_total = rv_total + ls_line-value * ls_line-weight DIV 100.
    ENDLOOP.
  ENDMETHOD.

  METHOD total_weight.
    " The weights add up to how the drivers are spread.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_weight = rv_weight + ls_line-weight.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
