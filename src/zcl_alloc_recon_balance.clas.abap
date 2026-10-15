CLASS zcl_alloc_recon_balance DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             key    TYPE string,
             amount TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS balance
      IMPORTING
        it_left           TYPE ty_line_tt
        it_right          TYPE ty_line_tt
      RETURNING
        VALUE(rv_balance) TYPE i.

    METHODS is_balanced
      IMPORTING
        it_left      TYPE ty_line_tt
        it_right     TYPE ty_line_tt
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS residual
      IMPORTING
        iv_balance         TYPE i
      RETURNING
        VALUE(rv_residual) TYPE i.

ENDCLASS.


CLASS zcl_alloc_recon_balance IMPLEMENTATION.

  METHOD balance.
    DATA lv_left TYPE i.
    DATA lv_right TYPE i.

    " The balance is one side's total less the other's.
    LOOP AT it_left INTO DATA(ls_left).
      lv_left = lv_left + ls_left-amount.
    ENDLOOP.

    LOOP AT it_right INTO DATA(ls_right).
      lv_right = lv_right + ls_right-amount.
    ENDLOOP.

    rv_balance = lv_left - lv_right.
  ENDMETHOD.

  METHOD is_balanced.
    " The two sides are balanced when their totals agree.
    rv_ok = xsdbool(
      balance( it_left = it_left it_right = it_right ) = 0 ).
  ENDMETHOD.

  METHOD residual.
    " The residual is the size of the balance, however it leans.
    rv_residual = iv_balance.
    IF rv_residual < 0.
      rv_residual = -1 * rv_residual.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
