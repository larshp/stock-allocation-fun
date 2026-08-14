REPORT zstock_alloc_stock.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_location OBLIGATORY.
PARAMETERS p_charg TYPE zif_stock_allocation=>ty_batch.
PARAMETERS p_meins TYPE zif_stock_allocation=>ty_unit.
PARAMETERS p_min TYPE zif_stock_allocation=>ty_quantity DEFAULT 0.
PARAMETERS p_max TYPE zif_stock_allocation=>ty_quantity DEFAULT 0.
PARAMETERS p_json AS CHECKBOX.
PARAMETERS p_csv AS CHECKBOX.
PARAMETERS p_typed AS CHECKBOX.

START-OF-SELECTION.
  DATA lo_source TYPE REF TO zif_stock_source.
  DATA lo_authority TYPE REF TO zif_unit_conversion_authority.
  DATA lo_converter TYPE REF TO zif_unit_conversion.
  DATA lo_conversion_error TYPE REF TO zcx_stock_allocation.
  DATA ls_available TYPE zif_stock_allocation=>ty_available.
  DATA lv_base_quantity TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_base_unit TYPE zif_stock_allocation=>ty_unit.
  DATA lv_output_quantity TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_output_unit TYPE zif_stock_allocation=>ty_unit.
  DATA lv_target_unit TYPE zif_stock_allocation=>ty_unit.
  DATA lv_converted TYPE abap_bool.
  DATA lv_minimum_active TYPE abap_bool.
  DATA lv_minimum_evaluated TYPE abap_bool.
  DATA lv_below_minimum TYPE abap_bool.
  DATA lv_maximum_active TYPE abap_bool.
  DATA lv_maximum_evaluated TYPE abap_bool.
  DATA lv_above_maximum TYPE abap_bool.
  DATA lv_availability_status TYPE string.
  DATA lv_json_line TYPE string.
  DATA lv_csv_line TYPE string.
  DATA lv_error_message TYPE string.
  DATA lt_json_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lt_csv_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.

  lv_target_unit = to_upper( p_meins ).

  IF p_csv = abap_true AND p_json = abap_true.
    WRITE: / zcl_stock_json=>error_with_schema(
      iv_message = 'Select only one export mode: CSV or JSON'
      iv_schema  = 4 ).
    RETURN.
  ENDIF.
  IF p_typed = abap_true AND p_json = abap_false.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_stock'
        iv_schema  = 4
        iv_message = 'Typed output requires JSON mode.' ).
      RETURN.
    ENDIF.
    WRITE: / zcl_stock_json=>error_with_schema(
      iv_message = 'Typed output requires JSON mode.'
      iv_schema  = 4 ).
    RETURN.
  ENDIF.
  IF p_min < 0.
    lv_error_message = 'Minimum output quantity cannot be negative'.
  ELSEIF p_max < 0.
    lv_error_message = 'Maximum output quantity cannot be negative'.
  ELSEIF p_min > 0 AND p_max > 0 AND p_min > p_max.
    lv_error_message =
      'Minimum output quantity cannot exceed maximum output quantity'.
  ENDIF.
  IF lv_error_message IS NOT INITIAL.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error_message
        iv_schema  = 4 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_stock'
        iv_schema  = 4
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / 'Stock input validation failed:', lv_error_message.
    ENDIF.
    CLEAR lv_error_message.
    RETURN.
  ENDIF.

  CREATE OBJECT lo_source TYPE zcl_stock_source_sap.
  TRY.
      ls_available = lo_source->get_available(
        iv_material         = p_matnr
        iv_plant            = p_werks
        iv_storage_location = p_lgort
        iv_batch            = p_charg ).
      lv_base_quantity = ls_available-quantity.
      lv_base_unit = ls_available-unit.
      lv_output_quantity = ls_available-quantity.
      lv_output_unit = ls_available-unit.
      lv_converted = abap_false.
      IF lv_target_unit IS NOT INITIAL.
        IF ls_available-material_found = abap_false.
          CREATE OBJECT lo_conversion_error.
          lo_conversion_error->message =
            'Stock unit conversion requires a known material'.
          RAISE EXCEPTION lo_conversion_error.
        ENDIF.
        CREATE OBJECT lo_authority TYPE zcl_unit_conversion_auth_sap.
        CREATE OBJECT lo_converter TYPE zcl_unit_conversion_sap
          EXPORTING
            io_authority = lo_authority.
        lv_output_quantity = lo_converter->convert(
          iv_material  = p_matnr
          iv_quantity  = ls_available-quantity
          iv_unit_from = ls_available-unit
          iv_unit_to   = lv_target_unit ).
        lv_output_unit = lv_target_unit.
        lv_converted = abap_true.
      ENDIF.
    CATCH zcx_stock_allocation INTO DATA(lo_error).
      IF lo_error->message IS INITIAL.
        lv_error_message = 'Stock read failed'.
      ELSE.
        lv_error_message = lo_error->message.
      ENDIF.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error_with_schema(
          iv_message = lv_error_message
          iv_schema  = 4 ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;schema_version;message'.
        WRITE: / zcl_stock_csv=>error_with_schema(
          iv_mode    = 'zstock_alloc_stock'
          iv_schema  = 4
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / 'Stock read failed:', lv_error_message.
      ENDIF.
      RETURN.
  ENDTRY.

  lv_minimum_active = xsdbool( p_min > 0 ).
  lv_minimum_evaluated = xsdbool(
    lv_minimum_active = abap_true
    AND ls_available-material_found = abap_true ).
  lv_maximum_active = xsdbool( p_max > 0 ).
  lv_maximum_evaluated = xsdbool(
    lv_maximum_active = abap_true
    AND ls_available-material_found = abap_true ).
  lv_below_minimum = xsdbool(
    lv_minimum_evaluated = abap_true
    AND lv_output_quantity < p_min ).
  lv_above_maximum = xsdbool(
    lv_maximum_evaluated = abap_true
    AND lv_output_quantity > p_max ).
  IF lv_minimum_evaluated = abap_false
      AND lv_maximum_evaluated = abap_false.
    lv_availability_status = 'not_evaluated'.
  ELSEIF lv_below_minimum = abap_true.
    lv_availability_status = 'below_minimum'.
  ELSEIF lv_above_maximum = abap_true.
    lv_availability_status = 'above_maximum'.
  ELSE.
    lv_availability_status = 'within_range'.
  ENDIF.

  IF p_csv = abap_true.
    CLEAR lt_csv_fields.
    APPEND zcl_stock_csv=>quote( 'stock' ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( sy-datum ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( sy-uzeit ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( 4 ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_matnr ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_werks ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_lgort ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_charg ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( lv_output_quantity ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_output_unit ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( lv_base_quantity ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_base_unit ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_target_unit ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_converted ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_min ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_minimum_active ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_minimum_evaluated ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_below_minimum ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_max ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_maximum_active ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_maximum_evaluated ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_above_maximum ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_availability_status ) TO lt_csv_fields.
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
      && 'storage_location;batch;quantity;unit;base_quantity;base_unit;'
      && 'target_unit;converted;minimum_quantity;minimum_threshold_active;'
      && 'minimum_threshold_evaluated;below_minimum;maximum_quantity;'
      && 'maximum_threshold_active;maximum_threshold_evaluated;above_maximum;'
      && 'availability_status;material_found;batch_managed;'
      && 'batch_found;batch_expiration_date;batch_restricted;status;message'.
    WRITE: / lv_csv_line.
    RETURN.
  ENDIF.

  IF p_json = abap_true.
    IF p_typed = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'schema_version'
        iv_value = 4 ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'typed'
        iv_value = abap_true ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'quantity'
        iv_value = lv_output_quantity ) TO lt_json_fields.
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
        iv_value = 4 ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'quantity'
        iv_value = lv_output_quantity ) TO lt_json_fields.
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
    IF p_typed = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'base_quantity'
        iv_value = lv_base_quantity ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>property(
        iv_name  = 'base_quantity'
        iv_value = lv_base_quantity ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>property(
      iv_name  = 'base_unit'
      iv_value = lv_base_unit ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'target_unit'
      iv_value = lv_target_unit ) TO lt_json_fields.
    IF p_typed = abap_true.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'converted'
        iv_value = lv_converted ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>property(
        iv_name  = 'converted'
        iv_value = lv_converted ) TO lt_json_fields.
    ENDIF.
    IF p_typed = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'minimum_quantity'
        iv_value = p_min ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'minimum_threshold_active'
        iv_value = lv_minimum_active ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'minimum_threshold_evaluated'
        iv_value = lv_minimum_evaluated ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'below_minimum'
        iv_value = lv_below_minimum ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'maximum_quantity'
        iv_value = p_max ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'maximum_threshold_active'
        iv_value = lv_maximum_active ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'maximum_threshold_evaluated'
        iv_value = lv_maximum_evaluated ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'above_maximum'
        iv_value = lv_above_maximum ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>property(
        iv_name  = 'minimum_quantity'
        iv_value = p_min ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'minimum_threshold_active'
        iv_value = lv_minimum_active ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'minimum_threshold_evaluated'
        iv_value = lv_minimum_evaluated ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'below_minimum'
        iv_value = lv_below_minimum ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'maximum_quantity'
        iv_value = p_max ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'maximum_threshold_active'
        iv_value = lv_maximum_active ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'maximum_threshold_evaluated'
        iv_value = lv_maximum_evaluated ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'above_maximum'
        iv_value = lv_above_maximum ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>property(
      iv_name  = 'availability_status'
      iv_value = lv_availability_status ) TO lt_json_fields.
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
      iv_value = lv_output_unit ) TO lt_json_fields.
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

  WRITE: / 'Stock available:', lv_output_quantity, lv_output_unit,
         / 'Base stock:', lv_base_quantity, lv_base_unit,
         / 'Target unit:', lv_target_unit,
         / 'Converted:', lv_converted,
         / 'Minimum quantity:', p_min,
         / 'Minimum threshold active:', lv_minimum_active,
         / 'Minimum threshold evaluated:', lv_minimum_evaluated,
         / 'Below minimum:', lv_below_minimum,
         / 'Maximum quantity:', p_max,
         / 'Maximum threshold active:', lv_maximum_active,
         / 'Maximum threshold evaluated:', lv_maximum_evaluated,
         / 'Above maximum:', lv_above_maximum,
         / 'Availability status:', lv_availability_status.
  WRITE: / 'Material found:', ls_available-material_found,
         / 'Batch managed:', ls_available-batch_managed,
         / 'Batch found:', ls_available-batch_found,
         / 'Batch restricted:', ls_available-batch_restricted,
         / 'Batch expiration date:', ls_available-batch_expiration_date.
