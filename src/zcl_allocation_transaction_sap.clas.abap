CLASS zcl_allocation_transaction_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_allocation_transaction.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_return,
        type    TYPE c LENGTH 1,
        message TYPE c LENGTH 220,
      END OF ty_return.
    METHODS raise_error
      IMPORTING
        iv_message TYPE zif_allocation_audit=>ty_message
      RAISING
        zcx_stock_allocation.
ENDCLASS.

CLASS zcl_allocation_transaction_sap IMPLEMENTATION.
  METHOD zif_allocation_transaction~commit.
    DATA ls_return TYPE ty_return.
    DATA ls_rollback_return TYPE ty_return.
    DATA lv_rollback_subrc TYPE sy-subrc.
    DATA lv_rollback_error TYPE abap_bool.
    DATA lv_commit_error TYPE abap_bool.
    DATA lv_commit_message TYPE zif_allocation_audit=>ty_message.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait   = abap_true
      IMPORTING
        return = ls_return
      EXCEPTIONS
        OTHERS = 1.
    IF ls_return-type IS NOT INITIAL
        AND ls_return-type <> 'S'
        AND ls_return-type <> 'I'
        AND ls_return-type <> 'W'
        AND ls_return-type <> 'E'
        AND ls_return-type <> 'A'
        AND ls_return-type <> 'X'.
      lv_commit_error = abap_true.
      lv_commit_message = 'Allocation transaction commit returned invalid status'.
    ELSEIF ls_return-type = 'E'
        OR ls_return-type = 'A'
        OR ls_return-type = 'X'.
      lv_commit_error = abap_true.
      lv_commit_message = ls_return-message.
    ENDIF.
    IF sy-subrc <> 0.
      lv_commit_error = abap_true.
    ENDIF.
    IF lv_commit_error = abap_true.
      CLEAR: ls_rollback_return,
             lv_rollback_error.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
        IMPORTING
          return = ls_rollback_return
        EXCEPTIONS
          OTHERS = 1.
      lv_rollback_subrc = sy-subrc.
      IF ls_rollback_return-type IS NOT INITIAL
          AND ls_rollback_return-type <> 'S'
          AND ls_rollback_return-type <> 'I'
          AND ls_rollback_return-type <> 'W'
          AND ls_rollback_return-type <> 'E'
          AND ls_rollback_return-type <> 'A'
          AND ls_rollback_return-type <> 'X'.
        lv_rollback_error = abap_true.
      ELSEIF ls_rollback_return-type = 'E'
          OR ls_rollback_return-type = 'A'
          OR ls_rollback_return-type = 'X'.
        lv_rollback_error = abap_true.
      ENDIF.
      IF lv_rollback_subrc <> 0.
        lv_rollback_error = abap_true.
      ENDIF.
      IF lv_commit_message IS INITIAL.
        lv_commit_message = 'Allocation transaction commit failed'.
      ENDIF.
      IF lv_rollback_error = abap_true.
        IF ls_rollback_return-message IS INITIAL.
          CONCATENATE lv_commit_message
                      'Transaction rollback failed'
                 INTO lv_commit_message SEPARATED BY '; ' .
        ELSE.
          CONCATENATE lv_commit_message
                      'Transaction rollback failed:'
                 INTO lv_commit_message SEPARATED BY '; ' .
          CONCATENATE lv_commit_message
                      ls_rollback_return-message
                 INTO lv_commit_message SEPARATED BY space.
        ENDIF.
      ENDIF.
      raise_error( iv_message = lv_commit_message ).
    ENDIF.
  ENDMETHOD.

  METHOD zif_allocation_transaction~rollback.
    DATA ls_return TYPE ty_return.
    DATA lv_rollback_subrc TYPE sy-subrc.
    DATA lv_rollback_error TYPE abap_bool.

    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
      IMPORTING
        return = ls_return
      EXCEPTIONS
        OTHERS = 1.
    lv_rollback_subrc = sy-subrc.
    IF ls_return-type IS NOT INITIAL
        AND ls_return-type <> 'S'
        AND ls_return-type <> 'I'
        AND ls_return-type <> 'W'
        AND ls_return-type <> 'E'
        AND ls_return-type <> 'A'
        AND ls_return-type <> 'X'.
      lv_rollback_error = abap_true.
    ELSEIF ls_return-type = 'E'
        OR ls_return-type = 'A'
        OR ls_return-type = 'X'.
      lv_rollback_error = abap_true.
    ENDIF.
    IF lv_rollback_subrc <> 0.
      lv_rollback_error = abap_true.
    ENDIF.
    IF lv_rollback_error = abap_true.
      IF ls_return-message IS INITIAL.
        raise_error( iv_message = 'Allocation transaction rollback failed' ).
      ELSE.
        raise_error(
          iv_message = |Allocation transaction rollback failed: { ls_return-message }| ).
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD raise_error.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = iv_message.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.
ENDCLASS.
