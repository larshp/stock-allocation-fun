REPORT zstock_alloc_stock.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_location OBLIGATORY.
PARAMETERS p_charg TYPE zif_stock_allocation=>ty_batch.
PARAMETERS p_json AS CHECKBOX.
PARAMETERS p_csv AS CHECKBOX.
PARAMETERS p_typed AS CHECKBOX.

START-OF-SELECTION.
  DATA lo_source TYPE REF TO zif_stock_source.
  DATA ls_available TYPE zif_stock_allocation=>ty_available.
  DATA lv_json_line TYPE string.
  DATA lv_csv_line TYPE string.
  DATA lv_error_message TYPE string.
  DATA lt_json_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lt_csv_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.

  IF p_csv = abap_true AND p_json = abap_true.
    WRITE: / zcl_stock_json=>error_with_schema(
      iv_message = 'Select only one export mode: CSV or JSON'
      iv_schema  = 1 ).
    RETURN.
  ENDIF.
  IF p_typed = abap_true AND p_json = abap_false.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_stock'
        iv_schema  = 1
        iv_message = 'Typed output requires JSON mode.' ).
      RETURN.
    ENDIF.
    WRITE: / zcl_stock_json=>error_with_schema(
      iv_message = 'Typed output requires JSON mode.'
      iv_schema  = 1 ).
    RETURN.
  ENDIF.

  CREATE OBJECT lo_source TYPE zcl_stock_source_sap.
  TRY.
      ls_available = lo_source->get_available(
        iv_material         = p_matnr
        iv_plant            = p_werks
        iv_storage_location = p_lgort
        iv_batch            = p_charg ).
    CATCH zcx_stock_allocation INTO DATA(lo_error).
      IF lo_error->message IS INITIAL.
        lv_error_message = 'Stock read failed'.
      ELSE.
        lv_error_message = lo_error->message.
      ENDIF.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error_with_schema(
          iv_message = lv_error_message
          iv_schema  = 1 ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;schema_version;message'.
        WRITE: / zcl_stock_csv=>error_with_schema(
          iv_mode    = 'zstock_alloc_stock'
          iv_schema  = 1
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / 'Stock read failed:', lv_error_message.
      ENDIF.
      RETURN.
  ENDTRY.

  IF p_csv = abap_true.
    CLEAR lt_csv_fields.
    APPEND zcl_stock_csv=>quote( 'stock' ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( sy-datum ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( sy-uzeit ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( 1 ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_matnr ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_werks ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_lgort ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_charg ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_available-quantity ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_available-unit ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_available-material_found ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_available-batch_managed ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_available-batch_found ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote(
      ls_available-batch_expiration_date ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_available-batch_restricted ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( 'success' ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( 'Stock read completed' ) TO lt_csv_fields.
    CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
    WRITE: / 'mode;generated_date;generated_time;schema_version;material;plant;'
      && 'storage_location;batch;quantity;unit;material_found;batch_managed;'
      && 'batch_found;batch_expiration_date;batch_restricted;status;message'.
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
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'quantity'
        iv_value = ls_available-quantity ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'material_found'
        iv_value = ls_available-material_found ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'batch_managed'
        iv_value = ls_available-batch_managed ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'batch_found'
        iv_value = ls_available-batch_found ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'batch_restricted'
        iv_value = ls_available-batch_restricted ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'schema_version'
        iv_value = 1 ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'quantity'
        iv_value = ls_available-quantity ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'material_found'
        iv_value = ls_available-material_found ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'batch_managed'
        iv_value = ls_available-batch_managed ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'batch_found'
        iv_value = ls_available-batch_found ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'batch_restricted'
        iv_value = ls_available-batch_restricted ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>property(
      iv_name  = 'mode'
      iv_value = 'stock' ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'generated_date'
      iv_value = sy-datum ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'generated_time'
      iv_value = sy-uzeit ) TO lt_json_fields.
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
      iv_name  = 'batch'
      iv_value = p_charg ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'unit'
      iv_value = ls_available-unit ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'batch_expiration_date'
      iv_value = ls_available-batch_expiration_date ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'status'
      iv_value = 'success' ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'message'
      iv_value = 'Stock read completed' ) TO lt_json_fields.
    CONCATENATE LINES OF lt_json_fields INTO lv_json_line SEPARATED BY ','.
    CONCATENATE '{' lv_json_line '}' INTO lv_json_line.
    WRITE: / lv_json_line.
    RETURN.
  ENDIF.

  WRITE: / 'Stock available:', ls_available-quantity, ls_available-unit.
  WRITE: / 'Material found:', ls_available-material_found,
         / 'Batch managed:', ls_available-batch_managed,
         / 'Batch found:', ls_available-batch_found,
         / 'Batch restricted:', ls_available-batch_restricted,
         / 'Batch expiration date:', ls_available-batch_expiration_date.
