CLASS zcl_alloc_transfer_audit DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material       TYPE matnr,
             transfer_price TYPE i,
             market_price   TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_violation,
             material TYPE matnr,
             gap      TYPE i,
           END OF ty_violation.
    TYPES ty_violation_tt TYPE STANDARD TABLE OF ty_violation WITH DEFAULT KEY.

    METHODS audit
      IMPORTING
        it_lines             TYPE ty_line_tt
        iv_tolerance_percent TYPE i
      RETURNING
        VALUE(rt_violations) TYPE ty_violation_tt.

    METHODS violation_count
      IMPORTING
        it_lines             TYPE ty_line_tt
        iv_tolerance_percent TYPE i
      RETURNING
        VALUE(rv_count)      TYPE i.

    METHODS worst
      IMPORTING
        it_lines      TYPE ty_line_tt
      RETURNING
        VALUE(rv_gap) TYPE i.

  PRIVATE SECTION.
    METHODS gap_of
      IMPORTING
        iv_transfer_price TYPE i
        iv_market_price   TYPE i
      RETURNING
        VALUE(rv_gap)     TYPE i.

ENDCLASS.


CLASS zcl_alloc_transfer_audit IMPLEMENTATION.

  METHOD gap_of.
    " The gap is how far the transfer price sits from the market.
    rv_gap = iv_transfer_price - iv_market_price.
    IF rv_gap < 0.
      rv_gap = -1 * rv_gap.
    ENDIF.
  ENDMETHOD.

  METHOD audit.
    DATA lv_gap       TYPE i.
    DATA lv_limit     TYPE i.
    DATA ls_violation TYPE ty_violation.

    " A line breaks the rule once it moves past the tolerated band.
    LOOP AT it_lines INTO DATA(ls_line).
      lv_limit = ls_line-market_price * iv_tolerance_percent DIV 100.
      lv_gap = gap_of( iv_transfer_price = ls_line-transfer_price
                       iv_market_price   = ls_line-market_price ).
      IF lv_gap <= lv_limit.
        CONTINUE.
      ENDIF.

      ls_violation-material = ls_line-material.
      ls_violation-gap = lv_gap.
      APPEND ls_violation TO rt_violations.
    ENDLOOP.
  ENDMETHOD.

  METHOD violation_count.
    DATA lt_violations TYPE ty_violation_tt.

    " The count is how many lines came back from the audit.
    lt_violations = audit( it_lines             = it_lines
                           iv_tolerance_percent = iv_tolerance_percent ).
    rv_count = lines( lt_violations ).
  ENDMETHOD.

  METHOD worst.
    DATA lv_gap TYPE i.

    " The worst line is the one that moved the furthest from the market.
    LOOP AT it_lines INTO DATA(ls_line).
      lv_gap = gap_of( iv_transfer_price = ls_line-transfer_price
                       iv_market_price   = ls_line-market_price ).
      IF lv_gap > rv_gap.
        rv_gap = lv_gap.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
