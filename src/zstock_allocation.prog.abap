REPORT zstock_allocation.

"! Stock allocation report
"! Selects a material/plant, runs the allocation engine and displays results.
TABLES: mara.

SELECT-OPTIONS: s_matnr FOR mara-matnr OBLIGATORY.
PARAMETERS: p_werks TYPE werks_d OBLIGATORY,
            p_test  TYPE abap_bool AS CHECKBOX DEFAULT abap_true.

START-OF-SELECTION.
  PERFORM run_allocation USING s_matnr[] p_werks.

FORM run_allocation USING lt_matnr LIKE s_matnr[]
                          lv_werks TYPE werks_d.
  DATA lt_allocations TYPE zcl_stock_allocator=>tt_allocations.
  DATA lv_total_shortage TYPE kwmeng.

  LOOP AT lt_matnr INTO DATA(ls_matnr).
    DATA(ls_result) = zcl_stock_allocator=>allocate_material(
        iv_matnr = ls_matnr-low
        iv_werks = lv_werks ).
    APPEND LINES OF ls_result-allocations TO lt_allocations.
    lv_total_shortage = lv_total_shortage + ls_result-qty_shortage.
  ENDLOOP.

  PERFORM display_results USING lt_allocations lv_total_shortage.
ENDFORM.

FORM display_results USING lt_allocations TYPE zcl_stock_allocator=>tt_allocations
                           lv_total_shortage TYPE kwmeng.
  WRITE: / 'Stock Allocation Results'.
  WRITE: / '======================='.
  SKIP.
  LOOP AT lt_allocations ASSIGNING FIELD-SYMBOL(<ls_alloc>).
    WRITE: / <ls_alloc>-vbeln,
             <ls_alloc>-posnr,
             <ls_alloc>-matnr,
             <ls_alloc>-lgort,
             <ls_alloc>-qty_req,
             <ls_alloc>-qty_alloc.
  ENDLOOP.
  SKIP.
  WRITE: / 'Total shortage:', lv_total_shortage.
ENDFORM.
