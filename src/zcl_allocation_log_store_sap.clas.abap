CLASS zcl_allocation_log_store_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_allocation_log_store.
    INTERFACES zif_allocation_history_store.
ENDCLASS.

CLASS zcl_allocation_log_store_sap IMPLEMENTATION.
  METHOD zif_allocation_log_store~save.
    IF it_current IS INITIAL.
      rv_saved = abap_true.
      RETURN.
    ENDIF.

    MODIFY zstock_alog FROM TABLE @it_current.
    IF sy-subrc <> 0.
      ROLLBACK WORK.
      rv_saved = abap_false.
      RETURN.
    ENDIF.

    INSERT zstock_algh FROM TABLE @it_history.
    rv_saved = xsdbool( sy-subrc = 0 ).
    IF rv_saved = abap_false.
      ROLLBACK WORK.
      RETURN.
    ENDIF.

    COMMIT WORK AND WAIT.
  ENDMETHOD.

  METHOD zif_allocation_history_store~remove_before.
    IF iv_simulation <> abap_false AND iv_simulation <> abap_true.
      rs_result-is_success = abap_false.
      rs_result-message = 'Retention simulation flag must be X or blank'.
      RETURN.
    ENDIF.
    IF iv_cutoff_date IS INITIAL.
      rs_result-is_success = abap_false.
      rs_result-message = 'Retention cutoff date must not be initial'.
      RETURN.
    ENDIF.
    IF iv_cutoff_date >= sy-datum.
      rs_result-is_success = abap_false.
      rs_result-message = 'Retention cutoff date must be before today'.
      RETURN.
    ENDIF.

    DATA lv_activity TYPE c LENGTH 2.
    lv_activity = COND #( WHEN iv_simulation = abap_true
                           THEN '03'
                           ELSE '06' ).
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM'
      ID 'TABLE' FIELD 'ZSTOCK_ALGH'
      ID 'ACTVT' FIELD lv_activity.
    IF sy-subrc <> 0.
      rs_result-is_success = abap_false.
      rs_result-message = 'Not authorized for allocation audit history'.
      RETURN.
    ENDIF.

    IF iv_simulation = abap_true.
      SELECT COUNT(*)
        FROM zstock_algh
        WHERE logged_on < @iv_cutoff_date
        INTO @rs_result-affected_rows.
      rs_result-is_success = xsdbool( sy-subrc = 0 ).
      IF rs_result-is_success = abap_true.
        rs_result-message = 'Audit history retention simulation completed'.
      ELSE.
        rs_result-message = 'Audit history retention simulation failed'.
      ENDIF.
      RETURN.
    ENDIF.

    DELETE FROM zstock_algh WHERE logged_on < @iv_cutoff_date.
    IF sy-subrc <> 0 AND sy-subrc <> 4.
      ROLLBACK WORK.
      rs_result-is_success = abap_false.
      rs_result-message = 'Audit history retention failed'.
      RETURN.
    ENDIF.

    rs_result-affected_rows = sy-dbcnt.
    COMMIT WORK AND WAIT.
    rs_result-is_success = abap_true.
    rs_result-message = 'Audit history retention completed'.
  ENDMETHOD.
ENDCLASS.
