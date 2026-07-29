REPORT zsalloc_check.

PARAMETERS p_matnr TYPE zif_salloc_types=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_salloc_types=>ty_plant OBLIGATORY.

START-OF-SELECTION.
  TRY.
      DATA(checker) = NEW zcl_salloc_checker(
        NEW zcl_salloc_authorization_sap( ) ).
      DATA(result) = checker->run(
        iv_material = p_matnr
        iv_plant = p_werks ).
      WRITE: / 'Physical stock:', result-physical,
             / 'SAP confirmed:', result-confirmed,
             / 'Stock ledger reserved:', result-reserved,
             / 'Order ledger allocated:', result-order_allocated.
      IF result-quantities_valid <> abap_true.
        WRITE: / 'ERROR: ledger quantities are internally inconsistent'.
        MESSAGE 'Stock allocation quantities are inconsistent' TYPE 'E'.
      ELSEIF result-ledgers_match <> abap_true.
        WRITE: / 'ERROR: stock and order ledgers disagree'.
        MESSAGE 'Stock allocation ledgers disagree' TYPE 'E'.
      ELSEIF result-commitments_fit <> abap_true.
        WRITE: / 'ERROR: commitments exceed physical stock'.
        MESSAGE 'Stock allocation commitments exceed stock' TYPE 'E'.
      ELSE.
        WRITE: / 'OK: ledger totals agree and commitments fit physical stock'.
      ENDIF.
    CATCH zcx_salloc_invalid INTO DATA(invalid).
      WRITE: / 'Invalid request:', invalid->reason.
      MESSAGE 'Stock allocation check request is invalid' TYPE 'E'.
    CATCH zcx_salloc_integration INTO DATA(error).
      WRITE: / 'Check failed:', error->reason.
      MESSAGE 'Stock allocation check failed' TYPE 'E'.
  ENDTRY.
