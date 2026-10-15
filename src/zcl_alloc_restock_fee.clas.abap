CLASS zcl_alloc_restock_fee DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS fee
      IMPORTING
        iv_value       TYPE i
        iv_fee_percent TYPE i
      RETURNING
        VALUE(rv_fee)  TYPE i.

    METHODS fee_percent
      IMPORTING
        iv_value      TYPE i
        iv_fee        TYPE i
      RETURNING
        VALUE(rv_pct) TYPE i.

    METHODS applies
      IMPORTING
        iv_reason_class TYPE string
      RETURNING
        VALUE(rv_ok)    TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_restock_fee IMPLEMENTATION.

  METHOD fee.
    " A missing or negative rate means no fee is taken.
    IF iv_value <= 0 OR iv_fee_percent <= 0.
      RETURN.
    ENDIF.

    rv_fee = iv_value * iv_fee_percent DIV 100.
  ENDMETHOD.

  METHOD fee_percent.
    IF iv_value <= 0 OR iv_fee <= 0.
      RETURN.
    ENDIF.

    rv_pct = iv_fee * 100 DIV iv_value.
  ENDMETHOD.

  METHOD applies.
    " Only a change of mind carries a restocking fee; a defect or a logistics
    " mistake is the seller's cost.
    rv_ok = xsdbool( iv_reason_class = 'COMMERCIAL' ).
  ENDMETHOD.

ENDCLASS.
