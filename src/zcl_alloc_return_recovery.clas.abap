CLASS zcl_alloc_return_recovery DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             value     TYPE i,
             recovered TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS rate
      IMPORTING
        iv_recovered  TYPE i
        iv_total      TYPE i
      RETURNING
        VALUE(rv_pct) TYPE i.

    METHODS recovered_value
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_value) TYPE i.

    METHODS is_good
      IMPORTING
        iv_pct       TYPE i
        iv_target    TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_return_recovery IMPLEMENTATION.

  METHOD rate.
    " The recovery rate is the recovered share of the returned value.
    IF iv_total <= 0 OR iv_recovered <= 0.
      RETURN.
    ENDIF.

    rv_pct = iv_recovered * 100 DIV iv_total.
  ENDMETHOD.

  METHOD recovered_value.
    " A line can never recover more than it is worth, so the recovered part is
    " capped at the value of the line.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-value <= 0 OR ls_line-recovered <= 0.
        CONTINUE.
      ENDIF.

      IF ls_line-recovered > ls_line-value.
        rv_value = rv_value + ls_line-value.
      ELSE.
        rv_value = rv_value + ls_line-recovered.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_good.
    rv_ok = xsdbool( iv_target > 0 AND iv_pct >= iv_target ).
  ENDMETHOD.

ENDCLASS.
