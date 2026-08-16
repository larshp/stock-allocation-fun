REPORT zstock_alloc_convert.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_qty TYPE zif_stock_allocation=>ty_quantity OBLIGATORY.
PARAMETERS p_from TYPE zif_stock_allocation=>ty_unit OBLIGATORY.
PARAMETERS p_to TYPE zif_stock_allocation=>ty_unit OBLIGATORY.
PARAMETERS p_json AS CHECKBOX.
PARAMETERS p_csv AS CHECKBOX.
PARAMETERS p_meta AS CHECKBOX.
PARAMETERS p_typed AS CHECKBOX.

START-OF-SELECTION.
  DATA lo_converter TYPE REF TO zif_unit_conversion.
  DATA lo_authority TYPE REF TO zif_unit_conversion_authority.
  DATA lv_unit_from TYPE zif_stock_allocation=>ty_unit.
  DATA lv_unit_to TYPE zif_stock_allocation=>ty_unit.
  DATA lv_quantity TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_json_line TYPE string.
  DATA lv_csv_line TYPE string.
  DATA lv_error_message TYPE string.
  DATA lv_json_schema TYPE i.
  DATA lt_json_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lt_summary_fields TYPE zcl_stock_json=>tt_strings.
  DATA lt_scope_fields TYPE zcl_stock_json=>tt_strings.
  DATA lt_filter_fields TYPE zcl_stock_json=>tt_strings.
  DATA lt_filter_names TYPE zcl_stock_json=>tt_strings.
  DATA lt_csv_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.

  lv_unit_from = to_upper( p_from ).
  lv_unit_to = to_upper( p_to ).
  IF p_meta = abap_true.
    lv_json_schema = 2.
  ELSE.
    lv_json_schema = 1.
  ENDIF.

  IF p_csv = abap_true AND p_json = abap_true.
    WRITE: / zcl_stock_json=>error_with_schema(
      iv_message = 'Select only one export mode: CSV or JSON'
      iv_schema  = lv_json_schema ).
    RETURN.
  ENDIF.
  IF p_typed = abap_true AND p_json = abap_false.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_convert'
        iv_schema  = 1
        iv_message = 'Typed output requires JSON mode.' ).
      RETURN.
    ENDIF.
    WRITE: / zcl_stock_json=>error_with_schema(
      iv_message = 'Typed output requires JSON mode.'
      iv_schema  = lv_json_schema ).
    RETURN.
  ENDIF.
  IF p_meta = abap_true AND p_json = abap_false.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_convert'
        iv_schema  = 1
        iv_message = 'Metadata output requires JSON mode.' ).
      RETURN.
    ENDIF.
    WRITE: / zcl_stock_json=>error_with_schema(
      iv_message = 'Metadata output requires JSON mode.'
      iv_schema  = lv_json_schema ).
    RETURN.
  ENDIF.
  IF p_meta = abap_true AND p_typed = abap_true.
    WRITE: / zcl_stock_json=>error_with_schema(
      iv_message = 'Select either typed JSON or metadata output.'
      iv_schema  = lv_json_schema ).
    RETURN.
  ENDIF.

  CREATE OBJECT lo_authority TYPE zcl_unit_conversion_auth_sap.
  CREATE OBJECT lo_converter TYPE zcl_unit_conversion_sap
    EXPORTING
      io_authority = lo_authority.
  TRY.
      lv_quantity = lo_converter->convert(
        iv_material  = p_matnr
        iv_quantity  = p_qty
        iv_unit_from = lv_unit_from
        iv_unit_to   = lv_unit_to ).
    CATCH zcx_stock_allocation INTO DATA(lo_error).
      IF lo_error->message IS INITIAL.
        lv_error_message = 'Unit conversion failed'.
      ELSE.
        lv_error_message = lo_error->message.
      ENDIF.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error_with_schema(
          iv_message = lv_error_message
          iv_schema  = lv_json_schema ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;schema_version;message'.
        WRITE: / zcl_stock_csv=>error_with_schema(
          iv_mode    = 'zstock_alloc_convert'
          iv_schema  = 1
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / 'Unit conversion failed:', lv_error_message.
      ENDIF.
      RETURN.
  ENDTRY.

  IF p_csv = abap_true.
    CLEAR lt_csv_fields.
    APPEND zcl_stock_csv=>quote( 'convert' ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( sy-datum ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( sy-uzeit ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( 1 ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_matnr ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_qty ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_unit_from ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_unit_to ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( lv_quantity ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( 'success' ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( 'Unit conversion completed' ) TO lt_csv_fields.
    CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
    WRITE: / 'mode;generated_date;generated_time;schema_version;material;'
      && 'quantity;unit_from;unit_to;converted_quantity;status;message'.
    WRITE: / lv_csv_line.
    RETURN.
  ENDIF.

  IF p_json = abap_true.
    IF p_typed = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'schema_version'
        iv_value = lv_json_schema ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'typed'
        iv_value = abap_true ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'quantity'
        iv_value = p_qty ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'converted_quantity'
        iv_value = lv_quantity ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'schema_version'
        iv_value = lv_json_schema ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'quantity'
        iv_value = p_qty ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'converted_quantity'
        iv_value = lv_quantity ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>property(
      iv_name  = 'mode'
      iv_value = 'convert' ) TO lt_json_fields.
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
      iv_name  = 'unit_from'
      iv_value = lv_unit_from ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'unit_to'
      iv_value = lv_unit_to ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'status'
      iv_value = 'success' ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'message'
      iv_value = 'Unit conversion completed' ) TO lt_json_fields.
    IF p_meta = abap_true.
      lt_summary_fields = lt_json_fields.
      CLEAR lt_scope_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'material'
        iv_value = p_matnr ) TO lt_scope_fields.
      CLEAR lt_filter_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'quantity'
        iv_value = p_qty ) TO lt_filter_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'unit_from'
        iv_value = lv_unit_from ) TO lt_filter_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'unit_to'
        iv_value = lv_unit_to ) TO lt_filter_fields.
      CLEAR lt_filter_names.
      APPEND 'quantity' TO lt_filter_names.
      APPEND 'unit_from' TO lt_filter_names.
      APPEND 'unit_to' TO lt_filter_names.
      CLEAR lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'schema_version'
        iv_value = lv_json_schema ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'mode'
        iv_value = 'convert' ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'generated_date'
        iv_value = sy-datum ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'generated_time'
        iv_value = sy-uzeit ) TO lt_json_fields.
      APPEND zcl_stock_json=>object_property(
        iv_name   = 'scope'
        it_fields = lt_scope_fields ) TO lt_json_fields.
      APPEND zcl_stock_json=>string_array_property(
        iv_name   = 'filters_applied'
        it_values = lt_filter_names ) TO lt_json_fields.
      APPEND zcl_stock_json=>object_property(
        iv_name   = 'filters'
        it_fields = lt_filter_fields ) TO lt_json_fields.
      APPEND zcl_stock_json=>object_property(
        iv_name   = 'summary'
        it_fields = lt_summary_fields ) TO lt_json_fields.
    ENDIF.
    CONCATENATE LINES OF lt_json_fields INTO lv_json_line SEPARATED BY ','.
    CONCATENATE '{' lv_json_line '}' INTO lv_json_line.
    WRITE: / lv_json_line.
    RETURN.
  ENDIF.

  WRITE: / p_qty, lv_unit_from, 'converts to', lv_quantity, lv_unit_to.
