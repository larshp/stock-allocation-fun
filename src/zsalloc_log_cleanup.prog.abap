REPORT zsalloc_log_cleanup.

PARAMETERS p_werks TYPE zif_salloc_types=>ty_plant OBLIGATORY.
PARAMETERS p_before TYPE timestampl OBLIGATORY.
PARAMETERS p_sim AS CHECKBOX DEFAULT 'X'.

START-OF-SELECTION.
  TRY.
      DATA(retention) = NEW zcl_salloc_log_retention(
        io_transaction = NEW zcl_salloc_transaction_sap( )
        io_authorization = NEW zcl_salloc_authorization_sap( )
        io_logger = NEW zcl_salloc_logger_sap( ) ).
      DATA(affected) = retention->run(
        iv_plant = p_werks
        iv_before = p_before
        iv_simulate = p_sim ).
      IF p_sim = abap_true.
        WRITE: / 'Simulation: audit rows eligible for deletion:', affected.
      ELSE.
        WRITE: / 'Audit rows deleted:', affected.
      ENDIF.
    CATCH zcx_salloc_invalid INTO DATA(invalid_error).
      WRITE: / 'Invalid input:', invalid_error->reason.
    CATCH zcx_salloc_integration INTO DATA(integration_error).
      WRITE: / 'Cleanup failed:', integration_error->reason.
  ENDTRY.
