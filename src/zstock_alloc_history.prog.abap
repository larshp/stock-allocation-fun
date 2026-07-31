REPORT zstock_alloc_history.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_location OBLIGATORY.
PARAMETERS p_charg TYPE zif_stock_allocation=>ty_batch.
PARAMETERS p_meins TYPE zif_stock_allocation=>ty_unit.

START-OF-SELECTION.
  DATA lo_audit TYPE REF TO zif_allocation_audit.
  DATA lt_runs TYPE zif_allocation_audit=>tt_runs.
  FIELD-SYMBOLS <ls_run> TYPE zif_allocation_audit=>ty_run.

  CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
  lt_runs = lo_audit->get_runs(
    iv_material         = p_matnr
    iv_plant            = p_werks
    iv_storage_location = p_lgort
    iv_batch            = p_charg
    iv_unit             = p_meins ).

  IF lines( lt_runs ) = 0.
    WRITE: / 'No allocation runs found.'.
    RETURN.
  ENDIF.

  WRITE: / 'Run ID', 34 'Status', 42 'Unit', 48 'Allocated',
           62 'Shortage', 76 'Started'.
  LOOP AT lt_runs ASSIGNING <ls_run>.
    WRITE: / <ls_run>-run_id,
             34 <ls_run>-status,
             42 <ls_run>-unit,
             48 <ls_run>-allocated,
             62 <ls_run>-shortage,
             76 <ls_run>-start_date,
             <ls_run>-start_time.
    WRITE: / 'Message:', <ls_run>-message.
  ENDLOOP.
