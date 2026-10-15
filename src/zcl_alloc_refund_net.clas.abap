CLASS zcl_alloc_refund_net DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             value    TYPE i,
             fee      TYPE i,
             shipping TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS net
      IMPORTING
        iv_value      TYPE i
        iv_fee        TYPE i
        iv_shipping   TYPE i
      RETURNING
        VALUE(rv_net) TYPE i.

    METHODS fee_of
      IMPORTING
        iv_value       TYPE i
        iv_fee_percent TYPE i
      RETURNING
        VALUE(rv_fee)  TYPE i.

    METHODS total
      IMPORTING
        it_lines      TYPE ty_line_tt
      RETURNING
        VALUE(rv_net) TYPE i.

ENDCLASS.


CLASS zcl_alloc_refund_net IMPLEMENTATION.

  METHOD net.
    " The net refund never goes below zero: fees and return shipping can offset the
    " whole value but never turn it into a charge.
    IF iv_value <= 0.
      RETURN.
    ENDIF.

    rv_net = iv_value - iv_fee - iv_shipping.
    IF rv_net < 0.
      rv_net = 0.
    ENDIF.
  ENDMETHOD.

  METHOD fee_of.
    IF iv_value <= 0 OR iv_fee_percent <= 0.
      RETURN.
    ENDIF.

    rv_fee = iv_value * iv_fee_percent DIV 100.
  ENDMETHOD.

  METHOD total.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_net = rv_net + net( iv_value    = ls_line-value
                             iv_fee      = ls_line-fee
                             iv_shipping = ls_line-shipping ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
