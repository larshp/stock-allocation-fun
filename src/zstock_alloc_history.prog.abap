REPORT zstock_alloc_history.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_location OBLIGATORY.
PARAMETERS p_charg TYPE zif_stock_allocation=>ty_batch.
PARAMETERS p_meins TYPE zif_stock_allocation=>ty_unit.
PARAMETERS p_stat TYPE zif_allocation_audit=>ty_run_status.
PARAMETERS p_from TYPE d.
PARAMETERS p_to TYPE d.

START-OF-SELECTION.
  DATA lo_audit TYPE REF TO zif_allocation_audit.
  DATA lt_runs TYPE zif_allocation_audit=>tt_runs.
  FIELD-SYMBOLS <ls_run> TYPE zif_allocation_audit=>ty_run.

  IF p_stat IS NOT INITIAL
      AND p_stat <> 'R'
      AND p_stat <> 'S'
      AND p_stat <> 'P'
      AND p_stat <> 'E'.
    WRITE: / 'Status must be R, S, P, or E.'.
    RETURN.
  ENDIF.
  IF p_from IS NOT INITIAL AND p_to IS NOT INITIAL AND p_from > p_to.
    WRITE: / 'The start date must not be after the end date.'.
    RETURN.
  ENDIF.

  CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
  TRY.
      lt_runs = lo_audit->get_runs(
        iv_material         = p_matnr
        iv_plant            = p_werks
        iv_storage_location = p_lgort
        iv_batch            = p_charg
        iv_unit             = p_meins
        iv_start_date_from  = p_from
        iv_start_date_to    = p_to
        iv_status           = p_stat ).
    CATCH zcx_stock_allocation.
      WRITE: / 'History is unavailable for the requested scope.'.
      RETURN.
  ENDTRY.

  IF lines( lt_runs ) = 0.
    WRITE: / 'No allocation runs found.'.
    RETURN.
  ENDIF.

  WRITE: / 'Run ID', 34 'Status', 42 'Unit', 48 'Available',
           62 'Allocated', 76 'Shortage', 90 'Demand', 100 'Started'.
  LOOP AT lt_runs ASSIGNING <ls_run>.
    WRITE: / <ls_run>-run_id,
             34 <ls_run>-status,
             42 <ls_run>-unit,
             48 <ls_run>-available,
             62 <ls_run>-allocated,
             76 <ls_run>-shortage,
             90 <ls_run>-demand_count,
             100 <ls_run>-start_date,
             <ls_run>-start_time.
    WRITE: / 'Message:', <ls_run>-message.
  ENDLOOP.
