CLASS zcl_salloc_transaction_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_salloc_transaction.
ENDCLASS.

CLASS zcl_salloc_transaction_sap IMPLEMENTATION.
  METHOD zif_salloc_transaction~begin.
    " SAP starts the logical unit of work implicitly.
  ENDMETHOD.

  METHOD zif_salloc_transaction~commit.
    COMMIT WORK AND WAIT.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_salloc_integration
        EXPORTING
          iv_operation = `COMMIT`
          iv_reason = `SAP update task failed`.
    ENDIF.
  ENDMETHOD.

  METHOD zif_salloc_transaction~rollback.
    ROLLBACK WORK.
  ENDMETHOD.
ENDCLASS.
