REPORT zstock_allocation.

"! Stock allocation report
"! Selects a material/plant, runs the allocation engine, posts the results
"! and displays an allocation log.
TABLES: mara.

SELECT-OPTIONS: s_matnr FOR mara-matnr OBLIGATORY.
PARAMETERS: p_werks TYPE werks_d OBLIGATORY,
            p_post  TYPE abap_bool AS CHECKBOX DEFAULT abap_false,
            p_test  TYPE abap_bool AS CHECKBOX DEFAULT abap_true.

START-OF-SELECTION.
  PERFORM run_allocation USING s_matnr[] p_werks p_post.

FORM run_allocation USING lt_matnr LIKE s_matnr[]
                          lv_werks TYPE werks_d
                          lv_post TYPE abap_bool.
  DATA lt_allocations TYPE zcl_stock_allocator=>tt_allocations.
  DATA lt_messages TYPE zcl_stub_message=>tt_message.
  DATA lv_total_shortage TYPE kwmeng.

  LOOP AT lt_matnr INTO DATA(ls_matnr).
    DATA(ls_result) = zcl_stock_allocator=>allocate_material(
        iv_matnr = ls_matnr-low
        iv_werks = lv_werks ).
    APPEND LINES OF ls_result-allocations TO lt_allocations.
    APPEND LINES OF ls_result-messages TO lt_messages.
    lv_total_shortage = lv_total_shortage + ls_result-qty_shortage.
  ENDLOOP.

  IF lv_post = abap_true.
    IF zcl_stock_allocator=>post_allocations(
          it_allocations = lt_allocations ) = abap_true.
      WRITE: / 'Posting completed successfully'.
    ELSE.
      WRITE: / 'Posting failed'.
    ENDIF.
    SKIP.
  ENDIF.

  PERFORM display_results USING lt_allocations lt_messages lv_total_shortage.
ENDFORM.

FORM display_results USING lt_allocations TYPE zcl_stock_allocator=>tt_allocations
                           lt_messages TYPE zcl_stub_message=>tt_message
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
  LOOP AT lt_messages ASSIGNING FIELD-SYMBOL(<ls_msg>).
    WRITE: / <ls_msg>-msgty, <ls_msg>-msgid, <ls_msg>-msgno,
             <ls_msg>-msgv1, <ls_msg>-msgv2.
  ENDLOOP.
  SKIP.
  WRITE: / 'Total shortage:', lv_total_shortage.
ENDFORM.
