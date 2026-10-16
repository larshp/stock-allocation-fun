CLASS zcl_alloc_prod_health DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             order_id TYPE string,
             cost     TYPE i,
             planned  TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS is_healthy
      IMPORTING
        it_lines     TYPE ty_line_tt
        iv_tolerance TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS issue_count
      IMPORTING
        it_lines        TYPE ty_line_tt
        iv_tolerance    TYPE i
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS score
      IMPORTING
        it_lines        TYPE ty_line_tt
        iv_tolerance    TYPE i
      RETURNING
        VALUE(rv_score) TYPE i.

ENDCLASS.


CLASS zcl_alloc_prod_health IMPLEMENTATION.

  METHOD issue_count.
    DATA lv_percent TYPE i.

    " An order is an issue once its cost runs past the tolerance.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-planned <= 0.
        CONTINUE.
      ENDIF.

      lv_percent = ls_line-cost * 100 DIV ls_line-planned.
      lv_percent = lv_percent - 100.
      IF lv_percent > iv_tolerance.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_healthy.
    DATA lv_issues TYPE i.

    " The set is healthy while no order runs past the tolerance.
    lv_issues = issue_count( it_lines = it_lines
      iv_tolerance                    = iv_tolerance ).
    rv_ok = xsdbool( lv_issues = 0 ).
  ENDMETHOD.

  METHOD score.
    DATA lv_total TYPE i.
    DATA lv_issues TYPE i.
    DATA lv_within TYPE i.

    " The score is the share of orders within tolerance.
    lv_total = lines( it_lines ).
    IF lv_total = 0.
      rv_score = 100.
      RETURN.
    ENDIF.

    lv_issues = issue_count( it_lines = it_lines
      iv_tolerance                    = iv_tolerance ).
    lv_within = lv_total - lv_issues.
    rv_score = lv_within * 100 DIV lv_total.
  ENDMETHOD.

ENDCLASS.
