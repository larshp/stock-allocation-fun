CLASS zcl_alloc_yield_health DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             order_id TYPE string,
             good     TYPE i,
             total    TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS is_healthy
      IMPORTING
        it_lines       TYPE ty_line_tt
        iv_min_percent TYPE i
      RETURNING
        VALUE(rv_ok)   TYPE abap_bool.

    METHODS issue_count
      IMPORTING
        it_lines        TYPE ty_line_tt
        iv_min_percent  TYPE i
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS score
      IMPORTING
        it_lines        TYPE ty_line_tt
        iv_min_percent  TYPE i
      RETURNING
        VALUE(rv_score) TYPE i.

ENDCLASS.


CLASS zcl_alloc_yield_health IMPLEMENTATION.

  METHOD issue_count.
    DATA lv_percent TYPE i.

    " An order is an issue once its yield falls short of the minimum.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-total <= 0.
        CONTINUE.
      ENDIF.

      lv_percent = ls_line-good * 100 DIV ls_line-total.
      IF lv_percent < iv_min_percent.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_healthy.
    DATA lv_issues TYPE i.

    " The set is healthy while every order meets the minimum.
    lv_issues = issue_count( it_lines = it_lines
      iv_min_percent                  = iv_min_percent ).
    rv_ok = xsdbool( lv_issues = 0 ).
  ENDMETHOD.

  METHOD score.
    DATA lv_total TYPE i.
    DATA lv_issues TYPE i.
    DATA lv_within TYPE i.

    " The score is the share of orders meeting the minimum.
    lv_total = lines( it_lines ).
    IF lv_total = 0.
      rv_score = 100.
      RETURN.
    ENDIF.

    lv_issues = issue_count( it_lines = it_lines
      iv_min_percent                  = iv_min_percent ).
    lv_within = lv_total - lv_issues.
    rv_score = lv_within * 100 DIV lv_total.
  ENDMETHOD.

ENDCLASS.
