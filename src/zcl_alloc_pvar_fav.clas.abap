CLASS zcl_alloc_pvar_fav DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             item   TYPE string,
             amount TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS is_favourable
      IMPORTING
        iv_amount    TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS amount
      IMPORTING
        it_lines         TYPE ty_line_tt
      RETURNING
        VALUE(rv_amount) TYPE i.

    METHODS count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_pvar_fav IMPLEMENTATION.

  METHOD is_favourable.
    " A variance is favourable once it comes in below plan.
    rv_ok = xsdbool( iv_amount < 0 ).
  ENDMETHOD.

  METHOD amount.
    DATA lv_magnitude TYPE i.

    " The total favourable variance, held as a positive amount.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-amount < 0.
        lv_magnitude = ls_line-amount * -1.
        rv_amount = rv_amount + lv_magnitude.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD count.
    " The count gathers the favourable lines.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-amount < 0.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
