REPORT zstock_alloc_reserve.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_location OBLIGATORY.
PARAMETERS p_bwart TYPE zif_stock_allocation=>ty_movement_type OBLIGATORY.
PARAMETERS p_meins TYPE zif_stock_allocation=>ty_unit OBLIGATORY.
PARAMETERS p_qty TYPE zif_stock_allocation=>ty_quantity OBLIGATORY.
PARAMETERS p_reqdt TYPE d OBLIGATORY.
PARAMETERS p_charg TYPE zif_stock_allocation=>ty_batch.
PARAMETERS p_exec AS CHECKBOX.
PARAMETERS p_json AS CHECKBOX.
PARAMETERS p_csv AS CHECKBOX.
PARAMETERS p_typed AS CHECKBOX.

START-OF-SELECTION.
  DATA lo_reservation TYPE REF TO zif_stock_reservation.
  DATA lo_authority TYPE REF TO zif_stock_allocation_authority.
  DATA lv_unit TYPE zif_stock_allocation=>ty_unit.
  DATA lv_json_line TYPE string.
  DATA lv_csv_line TYPE string.
  DATA lv_error_message TYPE string.
  DATA lv_document TYPE zif_stock_allocation=>ty_order_id.
  DATA lt_json_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lt_csv_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.

  lv_unit = to_upper( p_meins ).

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
        iv_mode    = 'zstock_alloc_reserve'
        iv_schema  = 1
        iv_message = 'Typed output requires JSON mode.' ).
      RETURN.
    ENDIF.
    WRITE: / zcl_stock_json=>error_with_schema(
      iv_message = 'Typed output requires JSON mode.'
      iv_schema  = 1 ).
    RETURN.
  ENDIF.

  IF p_exec <> abap_true.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = 'Select P_EXEC to create the reservation'
        iv_schema  = 1 ).
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      CLEAR lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'not_executed' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( sy-datum ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( sy-uzeit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( 1 ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_matnr ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_werks ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_lgort ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_bwart ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_unit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( p_qty ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_reqdt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_charg ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( '' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'not_executed' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        'Select P_EXEC to create the reservation' ) TO lt_csv_fields.
      CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
      WRITE: / 'mode;generated_date;generated_time;schema_version;material;plant;'
        && 'storage_location;movement_type;unit;quantity;required_date;batch;'
        && 'reservation_document;status;message'.
      WRITE: / lv_csv_line.
      RETURN.
    ENDIF.
    WRITE: / 'No reservation created. Select P_EXEC to create the reservation.'.
    RETURN.
  ENDIF.

  CREATE OBJECT lo_authority TYPE zcl_stock_alloc_auth_sap.
  CREATE OBJECT lo_reservation TYPE zcl_stock_reservation_sap
    EXPORTING
      io_authority = lo_authority.
  TRY.
      lv_document = lo_reservation->reserve(
        iv_material         = p_matnr
        iv_plant            = p_werks
        iv_storage_location = p_lgort
        iv_movement_type    = p_bwart
        iv_quantity         = p_qty
        iv_unit             = lv_unit
        iv_required_date    = p_reqdt
        iv_batch            = p_charg ).
    CATCH zcx_stock_allocation INTO DATA(lo_error).
      IF lo_error->message IS INITIAL.
        lv_error_message = 'Reservation creation failed'.
      ELSE.
        lv_error_message = lo_error->message.
      ENDIF.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error_with_schema(
          iv_message = lv_error_message
          iv_schema  = 1 ).
      ELSEIF p_csv = abap_true.
        CLEAR lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'execute' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( sy-datum ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( sy-uzeit ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( 1 ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( p_matnr ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( p_werks ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( p_lgort ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( p_bwart ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( lv_unit ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( p_qty ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( p_reqdt ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( p_charg ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( '' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'error' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( lv_error_message ) TO lt_csv_fields.
        CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
        WRITE: / 'mode;generated_date;generated_time;schema_version;material;plant;'
          && 'storage_location;movement_type;unit;quantity;required_date;batch;'
          && 'reservation_document;status;message'.
        WRITE: / lv_csv_line.
      ELSE.
        WRITE: / 'Reservation creation failed:', lv_error_message.
      ENDIF.
      RETURN.
  ENDTRY.

  IF p_csv = abap_true.
    CLEAR lt_csv_fields.
    APPEND zcl_stock_csv=>quote( 'execute' ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( sy-datum ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( sy-uzeit ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( 1 ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_matnr ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_werks ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_lgort ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_bwart ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_unit ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_qty ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_reqdt ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_charg ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_document ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( 'success' ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( 'Reservation created' ) TO lt_csv_fields.
    CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
    WRITE: / 'mode;generated_date;generated_time;schema_version;material;plant;'
      && 'storage_location;movement_type;unit;quantity;required_date;batch;'
      && 'reservation_document;status;message'.
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
        iv_value = p_qty ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'schema_version'
        iv_value = 1 ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'quantity'
        iv_value = p_qty ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>property(
      iv_name  = 'mode'
      iv_value = 'reservation_create' ) TO lt_json_fields.
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
      iv_name  = 'movement_type'
      iv_value = p_bwart ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'unit'
      iv_value = lv_unit ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'required_date'
      iv_value = p_reqdt ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'batch'
      iv_value = p_charg ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'reservation_document'
      iv_value = lv_document ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'status'
      iv_value = 'success' ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'message'
      iv_value = 'Reservation created' ) TO lt_json_fields.
    CONCATENATE LINES OF lt_json_fields INTO lv_json_line SEPARATED BY ','.
    CONCATENATE '{' lv_json_line '}' INTO lv_json_line.
    WRITE: / lv_json_line.
    RETURN.
  ENDIF.

  WRITE: / 'Reservation created:', lv_document.
