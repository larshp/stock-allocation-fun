CLASS zcl_alloc_settle_carry DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             item   TYPE string,
             amount TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS carry
      IMPORTING
        iv_closing      TYPE i
        iv_settled      TYPE i
      RETURNING
        VALUE(rv_carry) TYPE i.

    METHODS is_carried
      IMPORTING
        iv_carry     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS amount
      IMPORTING
        it_lines         TYPE ty_line_tt
      RETURNING
        VALUE(rv_amount) TYPE i.

ENDCLASS.


CLASS zcl_alloc_settle_carry IMPLEMENTATION.

  METHOD carry.
    " The carry-forward is what is left of the closing balance.
    IF iv_settled >= iv_closing.
      RETURN.
    ENDIF.

    rv_carry = iv_closing - iv_settled.
  ENDMETHOD.

  METHOD is_carried.
    " A balance is carried once anything is left over.
    rv_ok = xsdbool( iv_carry > 0 ).
  ENDMETHOD.

  METHOD amount.
    " The amount adds the carry-forward of every line.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_amount = rv_amount + ls_line-amount.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
