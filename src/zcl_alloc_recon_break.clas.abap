CLASS zcl_alloc_recon_break DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             key  TYPE string,
             diff TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS break_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS is_broken
      IMPORTING
        iv_diff      TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS worst
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_worst) TYPE i.

ENDCLASS.


CLASS zcl_alloc_recon_break IMPLEMENTATION.

  METHOD break_count.
    " Every line that does not agree is a break.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-diff <> 0.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_broken.
    " A line is broken once its difference is not zero.
    rv_ok = xsdbool( iv_diff <> 0 ).
  ENDMETHOD.

  METHOD worst.
    DATA lv_size TYPE i.

    " The worst break is the biggest difference, whichever way it goes.
    LOOP AT it_lines INTO DATA(ls_line).
      lv_size = ls_line-diff.
      IF lv_size < 0.
        lv_size = -1 * lv_size.
      ENDIF.
      IF lv_size > rv_worst.
        rv_worst = lv_size.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
