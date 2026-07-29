REPORT zsalloc_log.

PARAMETERS p_werks TYPE zif_salloc_types=>ty_plant OBLIGATORY.
PARAMETERS p_max TYPE i DEFAULT 100.

START-OF-SELECTION.
  TRY.
      DATA(authorization) = NEW zcl_salloc_authorization_sap( ).
      authorization->zif_salloc_authorization~check_authorization(
        iv_plant = p_werks
        iv_activity = '03' ).
      SELECT *
        FROM zsalloc_log
        WHERE werks = @p_werks
        ORDER BY created_at DESCENDING
        INTO TABLE @DATA(logs)
        UP TO @p_max ROWS.
      WRITE: / 'Timestamp', 28 'User', 42 'Event', 64 'Material', 106 'Quantity'.
      LOOP AT logs ASSIGNING FIELD-SYMBOL(<log>).
        WRITE: / <log>-created_at, 28 <log>-created_by, 42 <log>-event,
                 64 <log>-matnr, 106 <log>-quantity.
      ENDLOOP.
    CATCH zcx_salloc_integration INTO DATA(error).
      WRITE: / 'Authorization failure:', error->reason.
  ENDTRY.
