REPORT zstock_priority.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_loc OBLIGATORY.
PARAMETERS p_vbeln TYPE zif_stock_allocation=>ty_sales_order OBLIGATORY.
PARAMETERS p_posnr TYPE zif_stock_allocation=>ty_sales_item OBLIGATORY.
PARAMETERS p_prio TYPE zif_stock_allocation=>ty_priority DEFAULT 0.
PARAMETERS p_del AS CHECKBOX DEFAULT abap_false.

START-OF-SELECTION.
  DATA(lo_service) = NEW zcl_priority_service(
    io_authorization = NEW zcl_priority_auth_sap( )
    io_lock = NEW zcl_allocation_lock_sap( )
    io_sink = NEW zcl_priority_sink_sap( )
    io_log = NEW zcl_priority_log_sap( ) ).

  TRY.
      DATA lv_action TYPE string.
      IF p_del = abap_true.
        lo_service->remove_priority(
          iv_material = p_matnr
          iv_plant = p_werks
          iv_storage_location = p_lgort
          iv_sales_order = p_vbeln
          iv_sales_item = p_posnr ).
        lv_action = 'Priority removed'.
      ELSE.
        lo_service->set_priority(
          iv_material = p_matnr
          iv_plant = p_werks
          iv_storage_location = p_lgort
          iv_sales_order = p_vbeln
          iv_sales_item = p_posnr
          iv_priority = p_prio ).
        lv_action = 'Priority saved'.
      ENDIF.
      COMMIT WORK AND WAIT.
      IF sy-subrc <> 0.
        RAISE EXCEPTION NEW zcx_stock_allocation(
            'Synchronous priority commit failed' ).
      ENDIF.
      IF p_del = abap_true.
        WRITE: / lv_action,
                 p_matnr,
                 p_werks,
                 p_lgort,
                 p_vbeln,
                 p_posnr.
      ELSE.
        WRITE: / lv_action,
                 p_matnr,
                 p_werks,
                 p_lgort,
                 p_vbeln,
                 p_posnr,
                 p_prio.
      ENDIF.
    CATCH zcx_stock_allocation INTO DATA(lo_error).
      ROLLBACK WORK.
      MESSAGE lo_error TYPE 'E'.
  ENDTRY.
