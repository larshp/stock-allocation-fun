REPORT zstock_allocation.

"! Stock allocation report
"! Selects materials/plant, runs the multi-material allocation engine
"! (optionally as simulation), posts the results and displays a log.
TABLES: mara.

SELECT-OPTIONS: s_matnr FOR mara-matnr OBLIGATORY.
PARAMETERS: p_werks TYPE werks_d OBLIGATORY,
            p_sim   TYPE abap_bool AS CHECKBOX DEFAULT abap_false.

START-OF-SELECTION.
  PERFORM run_allocation USING s_matnr[] p_werks p_sim.

FORM run_allocation USING lt_matnr LIKE s_matnr[]
                          lv_werks TYPE werks_d
                          lv_sim TYPE abap_bool.
  DATA lt_materials TYPE zcl_stock_alloc_run=>tt_materials.

  LOOP AT lt_matnr INTO DATA(ls_matnr).
    APPEND VALUE zcl_stock_alloc_run=>ty_material( matnr = ls_matnr-low )
        TO lt_materials.
  ENDLOOP.

  DATA(ls_result) = zcl_stock_alloc_run=>run(
      it_materials = lt_materials
      iv_werks     = lv_werks
      iv_simulate  = lv_sim ).

  PERFORM display_results USING ls_result.
ENDFORM.

FORM display_results USING ls_result TYPE zcl_stock_alloc_run=>ty_run_result.
  WRITE: / 'Stock Allocation Results'.
  IF ls_result-allocations IS NOT INITIAL AND ls_result-messages IS NOT INITIAL.
    READ TABLE ls_result-messages INDEX 1 INTO DATA(ls_first_msg).
    IF ls_first_msg-msgv1 = 'SIMULATION'.
      WRITE: '(simulation - nothing posted)'.
    ENDIF.
  ENDIF.
  WRITE: / '======================='.
  SKIP.
  LOOP AT ls_result-allocations ASSIGNING FIELD-SYMBOL(<ls_alloc>).
    WRITE: / <ls_alloc>-vbeln,
             <ls_alloc>-posnr,
             <ls_alloc>-matnr,
             <ls_alloc>-lprio,
             <ls_alloc>-lgort,
             <ls_alloc>-qty_req,
             <ls_alloc>-qty_alloc.
  ENDLOOP.
  SKIP.
  LOOP AT ls_result-messages ASSIGNING FIELD-SYMBOL(<ls_msg>).
    WRITE: / <ls_msg>-msgty, <ls_msg>-msgid, <ls_msg>-msgno,
             <ls_msg>-msgv1, <ls_msg>-msgv2.
  ENDLOOP.
  SKIP.
  WRITE: / 'Total shortage:', ls_result-qty_shortage.
  SKIP.
  WRITE: / 'Statistics:'.
  WRITE: / '  Items processed :', ls_result-stats-items_total.
  WRITE: / '  Fully allocated :', ls_result-stats-items_full.
  WRITE: / '  Partially alloc.:', ls_result-stats-items_partial.
  WRITE: / '  Not allocated   :', ls_result-stats-items_none.
  WRITE: / '  Qty requested   :', ls_result-stats-qty_requested.
  WRITE: / '  Qty allocated   :', ls_result-stats-qty_allocated.
ENDFORM.
