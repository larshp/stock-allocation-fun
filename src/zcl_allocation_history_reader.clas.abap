CLASS zcl_allocation_history_reader DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_allocation_history_reader.
ENDCLASS.

CLASS zcl_allocation_history_reader IMPLEMENTATION.
  METHOD zif_allocation_history_reader~read.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM'
      ID 'TABLE' FIELD 'ZSTOCK_ALGH'
      ID 'ACTVT' FIELD '03'.
    IF sy-subrc <> 0.
      rs_result-is_success = abap_false.
      rs_result-message = 'Not authorized to read allocation audit history'.
      RETURN.
    ENDIF.

    DATA lt_request_ids TYPE RANGE OF zstock_algh-request_id.
    DATA lt_run_modes TYPE RANGE OF zstock_algh-run_mode.
    IF iv_request_id IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = iv_request_id ) TO lt_request_ids.
    ENDIF.
    IF iv_run_mode IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = iv_run_mode ) TO lt_run_modes.
    ENDIF.

    SELECT *
      FROM zstock_algh
      INTO TABLE @rs_result-entries
      UP TO @iv_max_rows ROWS
      WHERE logged_on >= @iv_from_date
        AND logged_on <= @iv_to_date
        AND request_id IN @lt_request_ids
        AND run_mode IN @lt_run_modes
      ORDER BY logged_on ASCENDING,
               logged_at ASCENDING,
               log_uuid ASCENDING.
    IF sy-subrc = 0 OR sy-subrc = 4.
      rs_result-is_success = abap_true.
      rs_result-message = 'Audit history read completed'.
    ELSE.
      rs_result-is_success = abap_false.
      rs_result-message = 'Audit history read failed'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
