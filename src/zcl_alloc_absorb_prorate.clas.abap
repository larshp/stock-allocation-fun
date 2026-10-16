CLASS zcl_alloc_absorb_prorate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             name TYPE string,
             base TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_share,
             name   TYPE string,
             amount TYPE i,
           END OF ty_share.
    TYPES ty_share_tt TYPE STANDARD TABLE OF ty_share WITH DEFAULT KEY.

    METHODS prorate
      IMPORTING
        it_lines         TYPE ty_line_tt
        iv_amount        TYPE i
      RETURNING
        VALUE(rt_shares) TYPE ty_share_tt.

    METHODS share
      IMPORTING
        iv_base         TYPE i
        iv_total_base   TYPE i
        iv_amount       TYPE i
      RETURNING
        VALUE(rv_share) TYPE i.

    METHODS total
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_absorb_prorate IMPLEMENTATION.

  METHOD share.
    " A share is the base at the amount over the whole base.
    IF iv_total_base = 0.
      RETURN.
    ENDIF.

    rv_share = iv_base * iv_amount DIV iv_total_base.
  ENDMETHOD.

  METHOD total.
    " The total adds the bases that the amount is spread over.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_total = rv_total + ls_line-base.
    ENDLOOP.
  ENDMETHOD.

  METHOD prorate.
    DATA lv_total TYPE i.
    DATA ls_share TYPE ty_share.

    " The amount is spread over every base in proportion to it.
    lv_total = total( it_lines ).

    LOOP AT it_lines INTO DATA(ls_line).
      CLEAR ls_share.
      ls_share-name = ls_line-name.
      ls_share-amount = share(
        iv_base       = ls_line-base
        iv_total_base = lv_total
        iv_amount     = iv_amount ).
      APPEND ls_share TO rt_shares.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
