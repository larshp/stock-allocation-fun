REPORT zstock_alloc_goods_issue.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_location OBLIGATORY.
PARAMETERS p_bwart TYPE zif_stock_allocation=>ty_movement_type OBLIGATORY.
PARAMETERS p_meins TYPE zif_stock_allocation=>ty_unit OBLIGATORY.
PARAMETERS p_charg TYPE zif_stock_allocation=>ty_batch.
PARAMETERS p_qty TYPE zif_stock_allocation=>ty_quantity OBLIGATORY.
PARAMETERS p_exec AS CHECKBOX.

START-OF-SELECTION.
  DATA lo_movement TYPE REF TO zif_stock_movement.
  DATA lo_authority TYPE REF TO zif_stock_movement_authority.
  DATA lv_document TYPE zif_stock_allocation=>ty_order_id.

  IF p_exec <> abap_true.
    WRITE: / 'No goods issue posted. Select P_EXEC to execute the update.'.
    RETURN.
  ENDIF.

  CREATE OBJECT lo_authority TYPE zcl_stock_movement_authority_sap.
  CREATE OBJECT lo_movement TYPE zcl_stock_movement_sap
    EXPORTING
      io_authority = lo_authority.
  TRY.
      lv_document = lo_movement->post_goods_issue(
        iv_material         = p_matnr
        iv_plant            = p_werks
        iv_storage_location = p_lgort
        iv_movement_type    = p_bwart
        iv_quantity         = p_qty
        iv_unit             = p_meins
        iv_batch            = p_charg ).
    CATCH zcx_stock_allocation INTO DATA(lo_error).
      IF lo_error->message IS INITIAL.
        WRITE: / 'Goods issue failed.'.
      ELSE.
        WRITE: / 'Goods issue failed:', lo_error->message.
      ENDIF.
      RETURN.
  ENDTRY.

  WRITE: / 'Goods issue posted. Material document:', lv_document.
