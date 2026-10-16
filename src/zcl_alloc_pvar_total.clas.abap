CLASS zcl_alloc_pvar_total DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             item   TYPE string,
             amount TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS total
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS is_zero
      IMPORTING
        iv_total     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_pvar_total IMPLEMENTATION.

  METHOD total.
    " The variance total is the sum of the signed amounts.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_total = rv_total + ls_line-amount.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_zero.
    " The variance is nil once it nets out.
    rv_ok = xsdbool( iv_total = 0 ).
  ENDMETHOD.

  METHOD count.
    rv_count = lines( it_lines ).
  ENDMETHOD.

ENDCLASS.
