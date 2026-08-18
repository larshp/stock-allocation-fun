REPORT zstock_alloc_res_cancel.

PARAMETERS p_resid TYPE zif_stock_allocation=>ty_order_id OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_bwart TYPE zif_stock_allocation=>ty_movement_type OBLIGATORY.
PARAMETERS p_exec AS CHECKBOX.
PARAMETERS p_json AS CHECKBOX.
PARAMETERS p_csv AS CHECKBOX.
PARAMETERS p_meta AS CHECKBOX.
PARAMETERS p_typed AS CHECKBOX.

START-OF-SELECTION.
  DATA lo_reservation TYPE REF TO zif_stock_reservation.
  DATA lo_authority TYPE REF TO zif_stock_allocation_authority.
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

  IF p_meta = abap_true.
    lv_json_schema = 3.
  ELSE.
    lv_json_schema = 2.
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
        iv_mode    = 'zstock_alloc_res_cancel'
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
        iv_mode    = 'zstock_alloc_res_cancel'
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

  IF p_exec <> abap_true.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = 'Select P_EXEC to cancel the reservation'
        iv_schema  = lv_json_schema ).
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      CLEAR lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'not_executed' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( sy-datum ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( sy-uzeit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( 1 ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_resid ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_werks ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_bwart ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'not_executed' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        'Select P_EXEC to cancel the reservation' ) TO lt_csv_fields.
      CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
      WRITE: / 'mode;generated_date;generated_time;schema_version;'
        && 'reservation_document;plant;movement_type;status;message'.
      WRITE: / lv_csv_line.
      RETURN.
    ENDIF.
    WRITE: / 'No reservation canceled. Select P_EXEC to cancel the reservation.'.
    RETURN.
  ENDIF.

  CREATE OBJECT lo_authority TYPE zcl_stock_alloc_auth_sap.
  CREATE OBJECT lo_reservation TYPE zcl_stock_reservation_sap
    EXPORTING
      io_authority = lo_authority.
  TRY.
      lo_reservation->cancel(
        iv_document      = p_resid
        iv_plant         = p_werks
        iv_movement_type = p_bwart ).
    CATCH zcx_stock_allocation INTO DATA(lo_error).
      IF lo_error->message IS INITIAL.
        lv_error_message = 'Reservation cancellation failed'.
      ELSE.
        lv_error_message = lo_error->message.
      ENDIF.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error_with_schema(
          iv_message = lv_error_message
          iv_schema  = lv_json_schema ).
      ELSEIF p_csv = abap_true.
        CLEAR lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'execute' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( sy-datum ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( sy-uzeit ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( 1 ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( p_resid ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( p_werks ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( p_bwart ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'error' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( lv_error_message ) TO lt_csv_fields.
        CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
        WRITE: / 'mode;generated_date;generated_time;schema_version;'
          && 'reservation_document;plant;movement_type;status;message'.
        WRITE: / lv_csv_line.
      ELSE.
        WRITE: / 'Reservation cancellation failed:', lv_error_message.
      ENDIF.
      RETURN.
  ENDTRY.

  IF p_csv = abap_true.
    CLEAR lt_csv_fields.
    APPEND zcl_stock_csv=>quote( 'execute' ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( sy-datum ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( sy-uzeit ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( 1 ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_resid ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_werks ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_bwart ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( 'success' ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( 'Reservation canceled' ) TO lt_csv_fields.
    CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
    WRITE: / 'mode;generated_date;generated_time;schema_version;'
      && 'reservation_document;plant;movement_type;status;message'.
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
    ELSE.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'schema_version'
        iv_value = lv_json_schema ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>property(
      iv_name  = 'mode'
      iv_value = 'reservation_cancel' ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'generated_date'
      iv_value = sy-datum ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'generated_time'
      iv_value = sy-uzeit ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'reservation_document'
      iv_value = p_resid ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'plant'
      iv_value = p_werks ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'movement_type'
      iv_value = p_bwart ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'status'
      iv_value = 'success' ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'message'
      iv_value = 'Reservation canceled' ) TO lt_json_fields.
    IF p_meta = abap_true.
      lt_summary_fields = lt_json_fields.
      CLEAR lt_scope_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'reservation_document'
        iv_value = p_resid ) TO lt_scope_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'plant'
        iv_value = p_werks ) TO lt_scope_fields.
      CLEAR lt_filter_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'movement_type'
        iv_value = p_bwart ) TO lt_filter_fields.
      CLEAR lt_filter_names.
      APPEND 'movement_type' TO lt_filter_names.
      CLEAR lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'schema_version'
        iv_value = lv_json_schema ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'mode'
        iv_value = 'execute' ) TO lt_json_fields.
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

  WRITE: / 'Reservation canceled:', p_resid.
