CLASS zcl_allocation_transaction_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_allocation_transaction.
  PRIVATE SECTION.
    METHODS raise_error
      IMPORTING
        iv_message TYPE zif_allocation_audit=>ty_message
      RAISING
        zcx_stock_allocation.
ENDCLASS.

CLASS zcl_allocation_transaction_sap IMPLEMENTATION.
  METHOD zif_allocation_transaction~commit.
    DATA lv_rollback_subrc TYPE sy-subrc.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.
    IF sy-subrc <> 0.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      lv_rollback_subrc = sy-subrc.
      IF lv_rollback_subrc <> 0.
        raise_error( iv_message = 'Allocation transaction commit failed; Transaction rollback failed' ).
      ENDIF.
      raise_error( iv_message = 'Allocation transaction commit failed' ).
    ENDIF.
  ENDMETHOD.

  METHOD zif_allocation_transaction~rollback.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    IF sy-subrc <> 0.
      raise_error( iv_message = 'Allocation transaction rollback failed' ).
    ENDIF.
  ENDMETHOD.

  METHOD raise_error.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = iv_message.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.
ENDCLASS.
