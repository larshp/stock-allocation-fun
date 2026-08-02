REPORT zstock_alloc_order_update.

PARAMETERS p_vbeln TYPE zif_order_sink=>ty_sales_document OBLIGATORY.
PARAMETERS p_auart TYPE zif_order_sink=>ty_sales_document_type OBLIGATORY.
PARAMETERS p_posnr TYPE zif_order_sink=>ty_sales_item OBLIGATORY.
PARAMETERS p_etenr TYPE zif_order_sink=>ty_schedule_line OBLIGATORY.
PARAMETERS p_qty TYPE zif_stock_allocation=>ty_quantity OBLIGATORY.
PARAMETERS p_exec AS CHECKBOX.
PARAMETERS p_json AS CHECKBOX.
PARAMETERS p_csv AS CHECKBOX.
PARAMETERS p_typed AS CHECKBOX.

START-OF-SELECTION.
  DATA lo_sink TYPE REF TO zif_order_sink.
  DATA lo_authority TYPE REF TO zif_order_sink_authority.
  DATA lv_json_line TYPE string.
  DATA lv_error_message TYPE string.
  DATA lt_json_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lv_csv_line TYPE string.
  DATA lt_csv_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.

  IF p_csv = abap_true AND p_json = abap_true.
    lv_json_line = zcl_stock_json=>error(
      'Select only one export mode: CSV or JSON' ).
    WRITE: / lv_json_line.
    RETURN.
  ENDIF.
  IF p_typed = abap_true AND p_json = abap_false.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_order_update'
        iv_message = 'Typed output requires JSON mode.' ).
      RETURN.
    ENDIF.
    lv_json_line = zcl_stock_json=>error(
      'Typed output requires JSON mode.' ).
    WRITE: / lv_json_line.
    RETURN.
  ENDIF.

  IF p_exec <> abap_true.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Select P_EXEC to execute the sales-order update' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      CLEAR lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'not_executed' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( sy-datum ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( sy-uzeit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( 1 ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_vbeln ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_auart ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_posnr ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_etenr ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( p_qty ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'not_executed' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        'Select P_EXEC to execute the sales-order update' ) TO lt_csv_fields.
      CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
      WRITE: / 'mode;generated_date;generated_time;schema_version;sales_document;sales_document_type;sales_item;schedule_line;quantity;status;message'.
      WRITE: / lv_csv_line.
      RETURN.
    ENDIF.
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
      IF p_json = abap_true.
        IF lo_error->message IS INITIAL.
          lv_json_line = zcl_stock_json=>error(
            'Sales-order change failed' ).
        ELSE.
          lv_error_message = lo_error->message.
          lv_json_line = zcl_stock_json=>error( lv_error_message ).
        ENDIF.
        WRITE: / lv_json_line.
        RETURN.
      ENDIF.
      IF p_csv = abap_false.
        IF lo_error->message IS INITIAL.
          WRITE: / 'Sales-order change failed.'.
        ELSE.
          WRITE: / 'Sales-order change failed:', lo_error->message.
        ENDIF.
      ENDIF.
      IF p_csv = abap_true.
        CLEAR lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'execute' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( sy-datum ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( sy-uzeit ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( 1 ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( p_vbeln ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( p_auart ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( p_posnr ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( p_etenr ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( p_qty ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'error' ) TO lt_csv_fields.
        IF lo_error->message IS INITIAL.
          APPEND zcl_stock_csv=>quote( 'Sales-order change failed' )
            TO lt_csv_fields.
        ELSE.
          APPEND zcl_stock_csv=>quote( lo_error->message ) TO lt_csv_fields.
        ENDIF.
        CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
        WRITE: / 'mode;generated_date;generated_time;schema_version;sales_document;sales_document_type;sales_item;schedule_line;quantity;status;message'.
        WRITE: / lv_csv_line.
      ENDIF.
      RETURN.
  ENDTRY.

  IF p_csv = abap_true.
    CLEAR lt_csv_fields.
    APPEND zcl_stock_csv=>quote( 'execute' ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( sy-datum ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( sy-uzeit ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( 1 ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_vbeln ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_auart ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_posnr ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_etenr ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_qty ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( 'success' ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( 'Sales-order schedule quantity changed' )
      TO lt_csv_fields.
    CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
    WRITE: / 'mode;generated_date;generated_time;schema_version;sales_document;sales_document_type;sales_item;schedule_line;quantity;status;message'.
    WRITE: / lv_csv_line.
    RETURN.
  ENDIF.

  IF p_json = abap_true.
    IF p_typed = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'schema_version'
        iv_value = 1 ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'typed'
        iv_value = abap_true ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'generated_date'
        iv_value = sy-datum ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'generated_time'
        iv_value = sy-uzeit ) TO lt_json_fields.
    ENDIF.
    IF p_typed = abap_false.
      APPEND zcl_stock_json=>property(
        iv_name  = 'generated_date'
        iv_value = sy-datum ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'generated_time'
        iv_value = sy-uzeit ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>property(
      iv_name  = 'mode'
      iv_value = 'sales_order_update' ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'sales_document'
      iv_value = p_vbeln ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'sales_document_type'
      iv_value = p_auart ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'sales_item'
      iv_value = p_posnr ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'schedule_line'
      iv_value = p_etenr ) TO lt_json_fields.
    IF p_typed = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'quantity'
        iv_value = p_qty ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>property(
        iv_name  = 'quantity'
        iv_value = p_qty ) TO lt_json_fields.
    ENDIF.
    CONCATENATE LINES OF lt_json_fields INTO lv_json_line SEPARATED BY ','.
    CONCATENATE '{' lv_json_line '}' INTO lv_json_line.
    WRITE: / lv_json_line.
    RETURN.
  ENDIF.

  WRITE: / 'Sales-order schedule quantity changed:',
           p_vbeln, p_posnr, p_etenr.
