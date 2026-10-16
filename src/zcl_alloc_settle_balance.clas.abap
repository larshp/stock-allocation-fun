CLASS zcl_alloc_settle_balance DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS balance
      IMPORTING
        iv_debit          TYPE i
        iv_credit         TYPE i
      RETURNING
        VALUE(rv_balance) TYPE i.

    METHODS is_balanced
      IMPORTING
        iv_balance   TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS residual
      IMPORTING
        iv_debit           TYPE i
        iv_credit          TYPE i
      RETURNING
        VALUE(rv_residual) TYPE i.

ENDCLASS.


CLASS zcl_alloc_settle_balance IMPLEMENTATION.

  METHOD balance.
    " The balance is the debit less the credit.
    rv_balance = iv_debit - iv_credit.
  ENDMETHOD.

  METHOD is_balanced.
    " The account is balanced once the balance nets out.
    rv_ok = xsdbool( iv_balance = 0 ).
  ENDMETHOD.

  METHOD residual.
    DATA lv_balance TYPE i.

    " The residual is the size of the difference, always positive.
    lv_balance = iv_debit - iv_credit.
    IF lv_balance < 0.
      lv_balance = lv_balance * -1.
    ENDIF.

    rv_residual = lv_balance.
  ENDMETHOD.

ENDCLASS.
