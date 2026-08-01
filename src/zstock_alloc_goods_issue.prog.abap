REPORT zstock_alloc_goods_issue.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_location OBLIGATORY.
PARAMETERS p_bwart TYPE zif_stock_allocation=>ty_movement_type OBLIGATORY.
PARAMETERS p_meins TYPE zif_stock_allocation=>ty_unit OBLIGATORY.
PARAMETERS p_charg TYPE zif_stock_allocation=>ty_batch.
PARAMETERS p_qty TYPE zif_stock_allocation=>ty_quantity OBLIGATORY.
PARAMETERS p_exec AS CHECKBOX.
PARAMETERS p_json AS CHECKBOX.

START-OF-SELECTION.
  DATA lo_movement TYPE REF TO zif_stock_movement.
  DATA lo_authority TYPE REF TO zif_stock_movement_authority.
  DATA ls_document TYPE zif_stock_movement=>ty_document.
  DATA lv_json_line TYPE string.
  DATA lv_error_message TYPE string.
  DATA lt_json_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.

  IF p_exec <> abap_true.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Select P_EXEC to execute the goods issue' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'No goods issue posted. Select P_EXEC to execute the update.'.
    RETURN.
  ENDIF.

  CREATE OBJECT lo_authority TYPE zcl_stock_move_auth_sap.
  CREATE OBJECT lo_movement TYPE zcl_stock_movement_sap
    EXPORTING
      io_authority = lo_authority.
  TRY.
      ls_document = lo_movement->post_goods_issue(
        iv_material         = p_matnr
        iv_plant            = p_werks
        iv_storage_location = p_lgort
        iv_movement_type    = p_bwart
        iv_quantity         = p_qty
        iv_unit             = p_meins
        iv_batch            = p_charg ).
    CATCH zcx_stock_allocation INTO DATA(lo_error).
      IF p_json = abap_true.
        IF lo_error->message IS INITIAL.
          lv_json_line = zcl_stock_json=>error(
            'Goods issue failed' ).
        ELSE.
          lv_error_message = lo_error->message.
          lv_json_line = zcl_stock_json=>error( lv_error_message ).
        ENDIF.
        WRITE: / lv_json_line.
        RETURN.
      ENDIF.
      IF lo_error->message IS INITIAL.
        WRITE: / 'Goods issue failed.'.
      ELSE.
        WRITE: / 'Goods issue failed:', lo_error->message.
      ENDIF.
      RETURN.
  ENDTRY.

  IF p_json = abap_true.
    APPEND zcl_stock_json=>property(
      iv_name  = 'mode'
      iv_value = 'goods_issue' ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'material'
      iv_value = p_matnr ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'plant'
      iv_value = p_werks ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'storage_location'
      iv_value = p_lgort ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'movement_type'
      iv_value = p_bwart ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'unit'
      iv_value = p_meins ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'batch'
      iv_value = p_charg ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'quantity'
      iv_value = p_qty ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'material_document'
      iv_value = ls_document-number ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'document_year'
      iv_value = ls_document-year ) TO lt_json_fields.
    CONCATENATE LINES OF lt_json_fields INTO lv_json_line SEPARATED BY ','.
    CONCATENATE '{' lv_json_line '}' INTO lv_json_line.
    WRITE: / lv_json_line.
    RETURN.
  ENDIF.

  WRITE: / 'Goods issue posted. Material document:',
           ls_document-number, 'Year:', ls_document-year.
