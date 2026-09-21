CLASS zcl_stock_snapshot_netting DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_result,
        deduction_quantity TYPE zif_stock_allocation=>ty_quantity,
        overflow_quantity  TYPE zif_stock_allocation=>ty_quantity,
        overflow           TYPE abap_bool,
      END OF ty_result.
    CLASS-METHODS calculate
      IMPORTING
        iv_unbacked_quantity TYPE zif_stock_allocation=>ty_quantity
        iv_stock_quantity    TYPE zif_stock_allocation=>ty_quantity
      RETURNING
        VALUE(rs_result)     TYPE ty_result
      RAISING
        zcx_stock_allocation.
  PRIVATE SECTION.
    CLASS-METHODS raise_error
      IMPORTING
        iv_message TYPE zif_allocation_audit=>ty_message
      RAISING
        zcx_stock_allocation.
ENDCLASS.

CLASS zcl_stock_snapshot_netting IMPLEMENTATION.
  METHOD calculate.
    IF iv_unbacked_quantity < 0 OR iv_stock_quantity < 0.
      raise_error( iv_message = 'Snapshot netting quantity is invalid' ).
    ENDIF.

    rs_result-deduction_quantity = iv_unbacked_quantity.
    IF iv_unbacked_quantity > iv_stock_quantity.
      rs_result-deduction_quantity = iv_stock_quantity.
      rs_result-overflow_quantity = iv_unbacked_quantity - iv_stock_quantity.
      rs_result-overflow = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD raise_error.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = iv_message.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.
ENDCLASS.
