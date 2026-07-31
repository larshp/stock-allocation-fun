REPORT zstock_alloc_order_update.

PARAMETERS p_vbeln TYPE zif_order_sink=>ty_sales_document OBLIGATORY.
PARAMETERS p_auart TYPE zif_order_sink=>ty_sales_document_type OBLIGATORY.
PARAMETERS p_posnr TYPE zif_order_sink=>ty_sales_item OBLIGATORY.
PARAMETERS p_etenr TYPE zif_order_sink=>ty_schedule_line OBLIGATORY.
PARAMETERS p_qty TYPE zif_stock_allocation=>ty_quantity OBLIGATORY.
PARAMETERS p_exec AS CHECKBOX.

START-OF-SELECTION.
  DATA lo_sink TYPE REF TO zif_order_sink.
  DATA lo_authority TYPE REF TO zif_order_sink_authority.

  IF p_exec <> abap_true.
    WRITE: / 'No sales-order change made. Select P_EXEC to execute the update.'.
    RETURN.
  ENDIF.

  CREATE OBJECT lo_authority TYPE zcl_order_sink_authority_sap.
  CREATE OBJECT lo_sink TYPE zcl_order_sink_sap
    EXPORTING
      io_authority = lo_authority.
  TRY.
      lo_sink->change_schedule_quantity(
        iv_sales_document      = p_vbeln
        iv_sales_document_type = p_auart
        iv_sales_item          = p_posnr
        iv_schedule_line       = p_etenr
        iv_quantity            = p_qty ).
    CATCH zcx_stock_allocation INTO DATA(lo_error).
      IF lo_error->message IS INITIAL.
        WRITE: / 'Sales-order change failed.'.
      ELSE.
        WRITE: / 'Sales-order change failed:', lo_error->message.
      ENDIF.
      RETURN.
  ENDTRY.

  WRITE: / 'Sales-order schedule quantity changed:',
           p_vbeln, p_posnr, p_etenr.
