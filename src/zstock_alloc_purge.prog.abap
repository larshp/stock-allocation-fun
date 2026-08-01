REPORT zstock_alloc_purge.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_location OBLIGATORY.
PARAMETERS p_charg TYPE zif_stock_allocation=>ty_batch.
PARAMETERS p_meins TYPE zif_stock_allocation=>ty_unit.
PARAMETERS p_date TYPE d OBLIGATORY.
PARAMETERS p_exec AS CHECKBOX.

START-OF-SELECTION.
  DATA lo_audit TYPE REF TO zif_allocation_audit.
  DATA lo_authority TYPE REF TO zif_alloc_retention_auth.
  DATA lv_deleted TYPE i.

  IF p_exec <> abap_true.
    WRITE: / 'No rows deleted. Select P_EXEC to execute retention.'.
    RETURN.
  ENDIF.
  IF p_date > sy-datum.
    WRITE: / 'No rows deleted. P_DATE cannot be in the future.'.
    RETURN.
  ENDIF.

  CREATE OBJECT lo_authority TYPE zcl_alloc_retention_auth_sap.
  TRY.
      lo_authority->check( ).
    CATCH zcx_stock_allocation INTO DATA(lo_auth_error).
      IF lo_auth_error->message IS INITIAL.
        WRITE: / 'No rows deleted. Retention authorization is missing.'.
      ELSE.
        WRITE: / 'No rows deleted. Retention authorization failed:',
                 lo_auth_error->message.
      ENDIF.
      RETURN.
  ENDTRY.

  CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap
    EXPORTING
      io_retention_authority = lo_authority.
  TRY.
      lv_deleted = lo_audit->purge_runs_before(
        iv_material         = p_matnr
        iv_plant            = p_werks
        iv_storage_location = p_lgort
        iv_batch            = p_charg
        iv_unit             = p_meins
        iv_before_date      = p_date ).
    CATCH zcx_stock_allocation INTO DATA(lo_error).
      IF lo_error->message IS INITIAL.
        WRITE: / 'No rows deleted. Retention execution failed.'.
      ELSE.
        WRITE: / 'No rows deleted. Retention execution failed:', lo_error->message.
      ENDIF.
      RETURN.
  ENDTRY.

  WRITE: / 'Deleted audit runs:', lv_deleted.
