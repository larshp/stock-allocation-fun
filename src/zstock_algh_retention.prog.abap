REPORT zstock_algh_retention.

PARAMETERS p_days TYPE i DEFAULT 365.
PARAMETERS p_test AS CHECKBOX DEFAULT 'X'.

START-OF-SELECTION.
  DATA(lo_retention) = zcl_allocation_log_retention=>create_sap( ).
  DATA(ls_result) = lo_retention->run(
    iv_retention_days = p_days
    iv_simulation     = p_test ).

  WRITE: / ls_result-message,
         / 'Affected history rows:', ls_result-affected_rows.

  IF ls_result-is_success = abap_false.
    MESSAGE ls_result-message TYPE 'E'.
  ENDIF.
