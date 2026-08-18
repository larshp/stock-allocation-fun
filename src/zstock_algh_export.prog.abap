REPORT zstock_algh_export LINE-SIZE 1023 NO STANDARD PAGE HEADING.

PARAMETERS p_from TYPE d.
PARAMETERS p_to TYPE d.
PARAMETERS p_req TYPE zstock_algh-request_id.
PARAMETERS p_mode TYPE zstock_algh-run_mode.
PARAMETERS p_max TYPE i DEFAULT 1000.

START-OF-SELECTION.
  DATA(lo_export) = zcl_allocation_log_export=>create_sap( ).
  DATA(ls_result) = lo_export->run(
    iv_from_date  = p_from
    iv_to_date    = p_to
    iv_request_id = p_req
    iv_run_mode   = p_mode
    iv_max_rows   = p_max ).

  IF ls_result-is_success = abap_false.
    MESSAGE ls_result-message TYPE 'E'.
  ENDIF.

  LOOP AT ls_result-lines INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.
