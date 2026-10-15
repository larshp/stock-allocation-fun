CLASS zcl_alloc_writedown DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material     TYPE matnr,
             book_value   TYPE i,
             market_value TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_writedown,
             material TYPE matnr,
             amount   TYPE i,
           END OF ty_writedown.
    TYPES ty_writedown_tt TYPE STANDARD TABLE OF ty_writedown WITH DEFAULT KEY.

    METHODS amount
      IMPORTING
        iv_book_value    TYPE i
        iv_market_value  TYPE i
      RETURNING
        VALUE(rv_amount) TYPE i.

    METHODS is_needed
      IMPORTING
        iv_book_value   TYPE i
        iv_market_value TYPE i
      RETURNING
        VALUE(rv_ok)    TYPE abap_bool.

    METHODS proposal
      IMPORTING
        it_lines            TYPE ty_line_tt
      RETURNING
        VALUE(rt_writedown) TYPE ty_writedown_tt.

ENDCLASS.


CLASS zcl_alloc_writedown IMPLEMENTATION.

  METHOD amount.
    " The write-down brings the book value down to the market value.
    IF iv_market_value >= iv_book_value.
      RETURN.
    ENDIF.

    rv_amount = iv_book_value - iv_market_value.
  ENDMETHOD.

  METHOD is_needed.
    " A write-down is needed once the market value is below the book value.
    rv_ok = xsdbool( iv_market_value < iv_book_value ).
  ENDMETHOD.

  METHOD proposal.
    DATA ls_writedown TYPE ty_writedown.

    " Every line priced below its book value becomes a write-down.
    LOOP AT it_lines INTO DATA(ls_line).
      IF is_needed( iv_book_value   = ls_line-book_value
                    iv_market_value = ls_line-market_value ) = abap_false.
        CONTINUE.
      ENDIF.

      ls_writedown-material = ls_line-material.
      ls_writedown-amount = amount( iv_book_value   = ls_line-book_value
                                    iv_market_value = ls_line-market_value ).
      APPEND ls_writedown TO rt_writedown.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
