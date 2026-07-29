REPORT zsalloc_check.

PARAMETERS p_matnr TYPE zif_salloc_types=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_salloc_types=>ty_plant OBLIGATORY.

START-OF-SELECTION.
  TRY.
      DATA(authorization) = NEW zcl_salloc_authorization_sap( ).
      authorization->zif_salloc_authorization~check_authorization(
        iv_plant = p_werks
        iv_activity = '03' ).
      SELECT SUM( labst ) FROM mard
        WHERE matnr = @p_matnr AND werks = @p_werks
        INTO @DATA(physical).
      SELECT SINGLE reserved FROM zsalloc_stock
        WHERE matnr = @p_matnr AND werks = @p_werks
        INTO @DATA(reserved).
      IF sy-subrc <> 0.
        CLEAR reserved.
      ENDIF.
      WRITE: / 'Physical stock:', physical,
             / 'Ledger reserved:', reserved.
      IF reserved > physical.
        WRITE: / 'ERROR: reservation invariant violated'.
      ELSE.
        WRITE: / 'OK: reservation does not exceed physical stock'.
      ENDIF.
    CATCH zcx_salloc_integration INTO DATA(error).
      WRITE: / 'Authorization failure:', error->reason.
  ENDTRY.
