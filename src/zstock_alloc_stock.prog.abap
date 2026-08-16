REPORT zstock_alloc_stock.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_location OBLIGATORY.
PARAMETERS p_charg TYPE zif_stock_allocation=>ty_batch.
PARAMETERS p_expdt TYPE d.
PARAMETERS p_shelf TYPE i DEFAULT 0.
PARAMETERS p_saf TYPE zif_stock_allocation=>ty_quantity DEFAULT 0.
PARAMETERS p_amin TYPE zif_stock_allocation=>ty_quantity DEFAULT 0.
PARAMETERS p_amax TYPE zif_stock_allocation=>ty_quantity DEFAULT 0.
PARAMETERS p_net AS CHECKBOX.
PARAMETERS p_meins TYPE zif_stock_allocation=>ty_unit.
PARAMETERS p_min TYPE zif_stock_allocation=>ty_quantity DEFAULT 0.
PARAMETERS p_max TYPE zif_stock_allocation=>ty_quantity DEFAULT 0.
PARAMETERS p_json AS CHECKBOX.
PARAMETERS p_csv AS CHECKBOX.
PARAMETERS p_meta AS CHECKBOX.
PARAMETERS p_typed AS CHECKBOX.

START-OF-SELECTION.
  DATA lo_source TYPE REF TO zif_stock_source.
  DATA lo_authority TYPE REF TO zif_unit_conversion_authority.
  DATA lo_converter TYPE REF TO zif_unit_conversion.
  DATA lo_sink TYPE REF TO zif_allocation_sink.
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
  DATA lv_expiration_status TYPE string.
  DATA lv_expiration_as_of TYPE d.
  DATA lv_remaining_shelf_life TYPE i.
  DATA lv_remaining_shelf_life_text TYPE string.
  DATA lv_shelf_life_threshold_active TYPE abap_bool.
  DATA lv_shelf_life_evaluated TYPE abap_bool.
  DATA lv_below_minimum_shelf_life TYPE abap_bool.
  DATA lv_shelf_life_status TYPE string.
  DATA lv_safety_stock_active TYPE abap_bool.
  DATA lv_safety_stock_evaluated TYPE abap_bool.
  DATA lv_at_or_below_safety_stock TYPE abap_bool.
  DATA lv_allocatable_quantity TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_allocatable_quantity_status TYPE string.
  DATA lv_allocatable_minimum_active TYPE abap_bool.
  DATA lv_alloc_min_evaluated TYPE abap_bool.
  DATA lv_below_allocatable_minimum TYPE abap_bool.
  DATA lv_allocatable_maximum_active TYPE abap_bool.
  DATA lv_alloc_max_evaluated TYPE abap_bool.
  DATA lv_above_allocatable_maximum TYPE abap_bool.
  DATA lv_allocatable_range_status TYPE string.
  DATA lv_existing_alloc_qty TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_existing_alloc_count TYPE i.
  DATA lv_existing_alloc_row_count TYPE i.
  DATA lv_existing_alloc_run_count TYPE i.
  DATA lv_existing_alloc_unit_count TYPE i.
  DATA lv_existing_alloc_units_mixed TYPE abap_bool.
  DATA lv_existing_alloc_overflow TYPE abap_bool.
  DATA lv_existing_alloc_overflow_qty TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_existing_alloc_active TYPE abap_bool.
  DATA lv_existing_alloc_evaluated TYPE abap_bool.
  DATA lv_existing_alloc_status TYPE string.
  DATA lv_existing_allocated_pct TYPE p LENGTH 8 DECIMALS 2.
  DATA lv_existing_pct_available TYPE abap_bool.
  DATA lv_existing_allocated_pct_text TYPE string.
  DATA lv_net_available_quantity TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_net_allocatable_quantity TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_net_allocatable_pct TYPE p LENGTH 8 DECIMALS 2.
  DATA lv_net_pct_available TYPE abap_bool.
  DATA lv_net_allocatable_pct_text TYPE string.
  DATA lv_net_allocatable_status TYPE string.
  DATA lv_range_quantity TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_eligibility_status TYPE string.
  DATA lv_json_line TYPE string.
  DATA lv_csv_line TYPE string.
  DATA lv_error_message TYPE string.
  DATA lv_json_schema TYPE i.
  DATA lt_json_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lt_summary_fields TYPE zcl_stock_json=>tt_strings.
  DATA lt_scope_fields TYPE zcl_stock_json=>tt_strings.
  DATA lt_filter_fields TYPE zcl_stock_json=>tt_strings.
  DATA lt_filter_value_fields TYPE zcl_stock_json=>tt_strings.
  DATA lt_filter_names TYPE zcl_stock_json=>tt_strings.
  DATA lt_csv_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lt_existing_allocations TYPE zif_stock_allocation=>tt_demands.
  DATA lt_existing_alloc_run_ids TYPE SORTED TABLE OF
    zif_stock_allocation=>ty_run_id WITH UNIQUE KEY table_line.
  DATA lt_existing_alloc_units TYPE SORTED TABLE OF
    zif_stock_allocation=>ty_unit WITH UNIQUE KEY table_line.
  FIELD-SYMBOLS <ls_existing_allocation> TYPE zif_stock_allocation=>ty_demand.

  lv_target_unit = to_upper( p_meins ).
  lv_expiration_as_of = p_expdt.
  IF lv_expiration_as_of IS INITIAL.
    lv_expiration_as_of = sy-datum.
  ENDIF.
  IF p_meta = abap_true.
    lv_json_schema = 26.
  ELSE.
    lv_json_schema = 25.
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
        iv_mode    = 'zstock_alloc_stock'
        iv_schema  = 25
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
        iv_mode    = 'zstock_alloc_stock'
        iv_schema  = 25
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
  IF zcl_allocation_date_sap=>is_valid_or_initial( p_expdt ) <> abap_true.
    lv_error_message = 'Expiration as-of date is invalid'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error_message
        iv_schema  = lv_json_schema ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message' .
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_stock'
        iv_schema  = 25
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / 'Stock input validation failed:', lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_shelf < 0.
    lv_error_message = 'Minimum shelf life cannot be negative'.
  ELSEIF p_shelf > 0 AND p_charg IS INITIAL.
    lv_error_message = 'Minimum shelf life requires a batch'.
  ELSEIF p_saf < 0.
    lv_error_message = 'Safety stock cannot be negative'.
  ELSEIF p_amin < 0.
    lv_error_message = 'Minimum allocatable quantity cannot be negative'.
  ELSEIF p_amax < 0.
    lv_error_message = 'Maximum allocatable quantity cannot be negative'.
  ELSEIF p_net <> abap_true AND p_net IS NOT INITIAL.
    lv_error_message = 'Net allocation flag is invalid'.
  ELSEIF p_amin > 0 AND p_amax > 0 AND p_amin > p_amax.
    lv_error_message =
      'Minimum allocatable quantity cannot exceed maximum allocatable quantity'.
  ELSEIF p_min < 0.
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
        iv_schema  = lv_json_schema ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_stock'
        iv_schema  = 25
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
          iv_schema  = lv_json_schema ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;schema_version;message'.
        WRITE: / zcl_stock_csv=>error_with_schema(
          iv_mode    = 'zstock_alloc_stock'
          iv_schema  = 25
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / 'Stock read failed:', lv_error_message.
      ENDIF.
      RETURN.
  ENDTRY.

  lv_existing_alloc_active = xsdbool( p_net = abap_true ).
  lv_existing_alloc_evaluated = xsdbool(
    lv_existing_alloc_active = abap_true
    AND ls_available-material_found = abap_true ).
  IF lv_existing_alloc_evaluated = abap_true.
    CREATE OBJECT lo_sink TYPE zcl_allocation_sink_sap.
    TRY.
        lt_existing_allocations = lo_sink->get_allocations(
          iv_material         = p_matnr
          iv_plant            = p_werks
          iv_storage_location = p_lgort
          iv_batch            = p_charg ).
        DESCRIBE TABLE lt_existing_allocations LINES lv_existing_alloc_count.
        CLEAR lt_existing_alloc_run_ids.
        CLEAR lt_existing_alloc_units.
        CLEAR lv_existing_alloc_row_count.
        CLEAR lv_existing_alloc_qty.
        CLEAR lv_existing_alloc_overflow.
        CLEAR lv_existing_alloc_overflow_qty.
        LOOP AT lt_existing_allocations ASSIGNING <ls_existing_allocation>.
          IF <ls_existing_allocation>-allocation_run_id IS NOT INITIAL.
            INSERT <ls_existing_allocation>-allocation_run_id
              INTO TABLE lt_existing_alloc_run_ids.
          ENDIF.
          IF <ls_existing_allocation>-allocation_unit IS NOT INITIAL.
            INSERT <ls_existing_allocation>-allocation_unit
              INTO TABLE lt_existing_alloc_units.
          ENDIF.
          IF <ls_existing_allocation>-allocated <= 0.
            CONTINUE.
          ENDIF.
          lv_existing_alloc_row_count =
            lv_existing_alloc_row_count + 1.
          IF <ls_existing_allocation>-allocation_unit IS INITIAL.
            CREATE OBJECT lo_conversion_error.
            lo_conversion_error->message =
              'Existing allocation unit is missing'.
            RAISE EXCEPTION lo_conversion_error.
          ENDIF.
          DATA(lv_existing_converted_qty) =
            <ls_existing_allocation>-allocated.
          IF <ls_existing_allocation>-allocation_unit <> lv_output_unit.
            IF lo_converter IS NOT BOUND.
              CREATE OBJECT lo_authority TYPE zcl_unit_conversion_auth_sap.
              CREATE OBJECT lo_converter TYPE zcl_unit_conversion_sap
                EXPORTING
                  io_authority = lo_authority.
            ENDIF.
            lv_existing_converted_qty = lo_converter->convert(
              iv_material  = p_matnr
              iv_quantity  = <ls_existing_allocation>-allocated
              iv_unit_from = <ls_existing_allocation>-allocation_unit
              iv_unit_to   = lv_output_unit ).
          ENDIF.
          IF lv_existing_converted_qty <= 0.
            CREATE OBJECT lo_conversion_error.
            lo_conversion_error->message =
              'Existing allocation conversion produced invalid quantity'.
            RAISE EXCEPTION lo_conversion_error.
          ENDIF.
          IF lv_existing_alloc_qty >= lv_output_quantity.
            lv_existing_alloc_overflow = abap_true.
            lv_existing_alloc_overflow_qty = lv_existing_alloc_overflow_qty
              + lv_existing_converted_qty.
            lv_existing_alloc_qty = lv_output_quantity.
          ELSEIF lv_existing_converted_qty
              > lv_output_quantity - lv_existing_alloc_qty.
            lv_existing_alloc_overflow = abap_true.
            lv_existing_alloc_overflow_qty = lv_existing_alloc_overflow_qty
              + lv_existing_converted_qty
              - ( lv_output_quantity - lv_existing_alloc_qty ).
            lv_existing_alloc_qty = lv_output_quantity.
          ELSE.
            lv_existing_alloc_qty = lv_existing_alloc_qty
              + lv_existing_converted_qty.
          ENDIF.
        ENDLOOP.
        DESCRIBE TABLE lt_existing_alloc_run_ids
          LINES lv_existing_alloc_run_count.
        DESCRIBE TABLE lt_existing_alloc_units
          LINES lv_existing_alloc_unit_count.
        lv_existing_alloc_units_mixed = xsdbool(
          lv_existing_alloc_unit_count > 1 ).
      CATCH zcx_stock_allocation INTO DATA(lo_net_error).
        IF lo_net_error->message IS INITIAL.
          lv_error_message = 'Existing allocation read failed'.
        ELSE.
          lv_error_message = lo_net_error->message.
        ENDIF.
        IF p_json = abap_true.
          WRITE: / zcl_stock_json=>error_with_schema(
            iv_message = lv_error_message
            iv_schema  = lv_json_schema ).
        ELSEIF p_csv = abap_true.
          WRITE: / 'mode;status;schema_version;message'.
          WRITE: / zcl_stock_csv=>error_with_schema(
            iv_mode    = 'zstock_alloc_stock'
            iv_schema  = 25
            iv_message = lv_error_message ).
        ELSE.
          WRITE: / 'Existing allocation read failed:', lv_error_message.
        ENDIF.
        RETURN.
    ENDTRY.
  ENDIF.
  IF lv_existing_alloc_evaluated = abap_false.
    lv_existing_alloc_status = 'not_evaluated'.
  ELSEIF lv_existing_alloc_qty > 0.
    lv_existing_alloc_status = 'available'.
  ELSE.
    lv_existing_alloc_status = 'none'.
  ENDIF.
  lv_existing_pct_available = xsdbool(
    lv_existing_alloc_evaluated = abap_true
    AND lv_output_quantity > 0 ).
  IF lv_existing_pct_available = abap_true.
    lv_existing_allocated_pct =
      lv_existing_alloc_qty * 100 / lv_output_quantity.
    lv_existing_allocated_pct_text = lv_existing_allocated_pct.
  ELSE.
    CLEAR lv_existing_allocated_pct.
    lv_existing_allocated_pct_text = 'n/a'.
  ENDIF.

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

  IF ls_available-batch_expiration_date IS INITIAL.
    lv_expiration_status = 'n/a'.
  ELSEIF ls_available-batch_expiration_date < lv_expiration_as_of.
    lv_expiration_status = 'expired'.
  ELSEIF ls_available-batch_expiration_date = lv_expiration_as_of.
    lv_expiration_status = 'current_day'.
  ELSE.
    lv_expiration_status = 'future'.
  ENDIF.

  lv_shelf_life_threshold_active = xsdbool( p_shelf > 0 ).
  lv_shelf_life_evaluated = xsdbool(
    lv_shelf_life_threshold_active = abap_true
    AND ls_available-batch_expiration_date IS NOT INITIAL ).
  IF ls_available-batch_expiration_date IS NOT INITIAL.
    lv_remaining_shelf_life =
      ls_available-batch_expiration_date - lv_expiration_as_of.
    lv_remaining_shelf_life_text = lv_remaining_shelf_life.
  ELSE.
    lv_remaining_shelf_life_text = 'n/a'.
  ENDIF.
  lv_below_minimum_shelf_life = xsdbool(
    lv_shelf_life_evaluated = abap_true
    AND ls_available-batch_expiration_date
      < lv_expiration_as_of + p_shelf ).
  IF lv_shelf_life_evaluated = abap_false.
    lv_shelf_life_status = 'not_evaluated'.
  ELSEIF lv_below_minimum_shelf_life = abap_true.
    lv_shelf_life_status = 'below_minimum'.
  ELSE.
    lv_shelf_life_status = 'within_range'.
  ENDIF.

  lv_safety_stock_active = xsdbool( p_saf > 0 ).
  lv_safety_stock_evaluated = xsdbool(
    lv_safety_stock_active = abap_true
    AND ls_available-material_found = abap_true ).
  lv_allocatable_quantity = lv_output_quantity.
  IF lv_safety_stock_evaluated = abap_true.
    IF lv_output_quantity > p_saf.
      lv_allocatable_quantity = lv_output_quantity - p_saf.
    ELSE.
      CLEAR lv_allocatable_quantity.
    ENDIF.
  ENDIF.
  lv_at_or_below_safety_stock = xsdbool(
    lv_safety_stock_evaluated = abap_true
    AND lv_output_quantity <= p_saf ).
  IF lv_safety_stock_evaluated = abap_false.
    IF ls_available-material_found = abap_false.
      lv_allocatable_quantity_status = 'not_evaluated'.
    ELSEIF lv_output_quantity <= 0.
      lv_allocatable_quantity_status = 'no_available_stock'.
    ELSE.
      lv_allocatable_quantity_status = 'available'.
    ENDIF.
  ELSEIF lv_output_quantity <= 0.
    lv_allocatable_quantity_status = 'no_available_stock'.
  ELSEIF lv_at_or_below_safety_stock = abap_true.
    lv_allocatable_quantity_status = 'no_allocatable_stock'.
  ELSE.
    lv_allocatable_quantity_status = 'available'.
  ENDIF.

  lv_net_available_quantity = lv_output_quantity.
  IF lv_existing_alloc_evaluated = abap_true.
    IF lv_existing_alloc_qty >= lv_output_quantity.
      CLEAR lv_net_available_quantity.
    ELSE.
      lv_net_available_quantity = lv_output_quantity
        - lv_existing_alloc_qty.
    ENDIF.
  ENDIF.
  lv_net_allocatable_quantity = lv_allocatable_quantity.
  IF lv_existing_alloc_evaluated = abap_true.
    lv_net_allocatable_quantity = lv_net_available_quantity.
    IF lv_safety_stock_evaluated = abap_true.
      IF lv_net_allocatable_quantity > p_saf.
        lv_net_allocatable_quantity = lv_net_allocatable_quantity - p_saf.
      ELSE.
        CLEAR lv_net_allocatable_quantity.
      ENDIF.
    ENDIF.
    IF lv_output_quantity <= 0.
      lv_net_allocatable_status = 'no_available_stock'.
    ELSEIF lv_net_allocatable_quantity <= 0.
      lv_net_allocatable_status = 'no_allocatable_stock'.
    ELSE.
      lv_net_allocatable_status = 'available'.
    ENDIF.
  ELSE.
    lv_net_allocatable_status = 'not_evaluated'.
  ENDIF.
  lv_net_pct_available = xsdbool(
    lv_existing_alloc_evaluated = abap_true
    AND lv_output_quantity > 0 ).
  IF lv_net_pct_available = abap_true.
    lv_net_allocatable_pct =
      lv_net_allocatable_quantity * 100 / lv_output_quantity.
    lv_net_allocatable_pct_text = lv_net_allocatable_pct.
  ELSE.
    CLEAR lv_net_allocatable_pct.
    lv_net_allocatable_pct_text = 'n/a'.
  ENDIF.
  lv_range_quantity = lv_allocatable_quantity.
  IF lv_existing_alloc_evaluated = abap_true.
    lv_range_quantity = lv_net_allocatable_quantity.
  ENDIF.

  lv_allocatable_minimum_active = xsdbool( p_amin > 0 ).
  lv_alloc_min_evaluated = xsdbool(
    lv_allocatable_minimum_active = abap_true
    AND ls_available-material_found = abap_true ).
  lv_below_allocatable_minimum = xsdbool(
    lv_alloc_min_evaluated = abap_true
    AND lv_range_quantity < p_amin ).
  lv_allocatable_maximum_active = xsdbool( p_amax > 0 ).
  lv_alloc_max_evaluated = xsdbool(
    lv_allocatable_maximum_active = abap_true
    AND ls_available-material_found = abap_true ).
  lv_above_allocatable_maximum = xsdbool(
    lv_alloc_max_evaluated = abap_true
    AND lv_range_quantity > p_amax ).
  IF lv_alloc_min_evaluated = abap_false
      AND lv_alloc_max_evaluated = abap_false.
    lv_allocatable_range_status = 'not_evaluated'.
  ELSEIF lv_below_allocatable_minimum = abap_true.
    lv_allocatable_range_status = 'below_minimum'.
  ELSEIF lv_above_allocatable_maximum = abap_true.
    lv_allocatable_range_status = 'above_maximum'.
  ELSE.
    lv_allocatable_range_status = 'within_range'.
  ENDIF.
  IF ls_available-material_found = abap_false.
    lv_eligibility_status = 'material_not_found'.
  ELSEIF p_charg IS INITIAL
      AND ls_available-batch_managed = abap_true.
    lv_eligibility_status = 'batch_required'.
  ELSEIF p_charg IS NOT INITIAL
      AND ls_available-batch_managed = abap_false.
    lv_eligibility_status = 'batch_not_managed'.
  ELSEIF p_charg IS NOT INITIAL
      AND ls_available-batch_found = abap_false.
    lv_eligibility_status = 'batch_not_found'.
  ELSEIF ls_available-batch_restricted = abap_true.
    lv_eligibility_status = 'batch_restricted'.
  ELSEIF lv_expiration_status = 'expired'.
    lv_eligibility_status = 'expired'.
  ELSEIF p_shelf > 0 AND lv_shelf_life_evaluated = abap_false.
    lv_eligibility_status = 'shelf_life_not_evaluated'.
  ELSEIF lv_below_minimum_shelf_life = abap_true.
    lv_eligibility_status = 'below_minimum_shelf_life'.
  ELSEIF lv_output_quantity <= 0.
    lv_eligibility_status = 'no_available_stock'.
  ELSEIF p_saf > 0 AND lv_safety_stock_evaluated = abap_false.
    lv_eligibility_status = 'safety_stock_not_evaluated'.
  ELSEIF lv_at_or_below_safety_stock = abap_true.
    lv_eligibility_status = 'no_allocatable_stock'.
  ELSEIF lv_existing_alloc_evaluated = abap_true
      AND lv_net_allocatable_quantity <= 0.
    lv_eligibility_status = 'no_net_allocatable_stock'.
  ELSEIF lv_below_allocatable_minimum = abap_true.
    lv_eligibility_status = 'below_minimum_allocatable'.
  ELSEIF lv_above_allocatable_maximum = abap_true.
    lv_eligibility_status = 'above_maximum_allocatable'.
  ELSEIF lv_below_minimum = abap_true.
    lv_eligibility_status = 'below_minimum'.
  ELSEIF lv_above_maximum = abap_true.
    lv_eligibility_status = 'above_maximum'.
  ELSE.
    lv_eligibility_status = 'eligible'.
  ENDIF.

  IF p_csv = abap_true.
    CLEAR lt_csv_fields.
    APPEND zcl_stock_csv=>quote( 'stock' ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( sy-datum ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( sy-uzeit ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( 25 ) TO lt_csv_fields.
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
    APPEND zcl_stock_csv=>number( p_saf ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote(
      lv_safety_stock_active ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote(
      lv_safety_stock_evaluated ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote(
      lv_at_or_below_safety_stock ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number(
      lv_allocatable_quantity ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote(
      lv_allocatable_quantity_status ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_amin ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote(
      lv_allocatable_minimum_active ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote(
      lv_alloc_min_evaluated ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote(
      lv_below_allocatable_minimum ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_amax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote(
      lv_allocatable_maximum_active ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote(
      lv_alloc_max_evaluated ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote(
      lv_above_allocatable_maximum ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote(
      lv_allocatable_range_status ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_existing_alloc_active ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( lv_existing_alloc_qty ) TO lt_csv_fields.
    IF lv_existing_pct_available = abap_true.
      APPEND zcl_stock_csv=>number(
        lv_existing_allocated_pct ) TO lt_csv_fields.
    ELSE.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    ENDIF.
    APPEND zcl_stock_csv=>number( lv_existing_alloc_count ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number(
      lv_existing_alloc_row_count ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number(
      lv_existing_alloc_run_count ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number(
      lv_existing_alloc_unit_count ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote(
      lv_existing_alloc_units_mixed ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote(
      lv_existing_alloc_overflow ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number(
      lv_existing_alloc_overflow_qty ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote(
      lv_existing_alloc_evaluated ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_existing_alloc_status ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number(
      lv_net_available_quantity ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number(
      lv_net_allocatable_quantity ) TO lt_csv_fields.
    IF lv_net_pct_available = abap_true.
      APPEND zcl_stock_csv=>number(
        lv_net_allocatable_pct ) TO lt_csv_fields.
    ELSE.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    ENDIF.
    APPEND zcl_stock_csv=>quote(
      lv_net_allocatable_status ) TO lt_csv_fields.
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
    APPEND zcl_stock_csv=>quote( lv_expiration_as_of ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_expiration_status ) TO lt_csv_fields.
    IF ls_available-batch_expiration_date IS INITIAL.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    ELSE.
      APPEND zcl_stock_csv=>number( lv_remaining_shelf_life ) TO lt_csv_fields.
    ENDIF.
    APPEND zcl_stock_csv=>number( p_shelf ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote(
      lv_shelf_life_threshold_active ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote(
      lv_shelf_life_evaluated ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote(
      lv_below_minimum_shelf_life ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_shelf_life_status ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_eligibility_status ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_available-batch_restricted ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( 'success' ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( 'Stock read completed' ) TO lt_csv_fields.
    CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
    WRITE: / 'mode;generated_date;generated_time;schema_version;material;plant;'
      && 'storage_location;batch;quantity;unit;base_quantity;base_unit;'
      && 'target_unit;converted;safety_stock;safety_stock_threshold_active;'
      && 'safety_stock_threshold_evaluated;at_or_below_safety_stock;'
      && 'allocatable_quantity;allocatable_quantity_status;'
      && 'minimum_allocatable_quantity;minimum_allocatable_threshold_active;'
      && 'minimum_allocatable_threshold_evaluated;below_minimum_allocatable;'
      && 'maximum_allocatable_quantity;maximum_allocatable_threshold_active;'
      && 'maximum_allocatable_threshold_evaluated;above_maximum_allocatable;'
      && 'allocatable_range_status;'
      && 'net_allocation_active;existing_allocated_quantity;existing_allocated_pct;'
      && 'existing_allocation_count;existing_allocated_row_count;'
      && 'existing_allocation_run_count;existing_allocation_unit_count;'
      && 'existing_allocation_units_mixed;'
      && 'existing_allocations_overflow;'
      && 'existing_allocations_overflow_quantity;'
      && 'existing_allocations_evaluated;existing_allocations_status;'
      && 'net_available_quantity;net_allocatable_quantity;net_allocatable_pct;'
      && 'net_allocatable_quantity_status;'
      && 'minimum_quantity;minimum_threshold_active;'
      && 'minimum_threshold_evaluated;below_minimum;maximum_quantity;'
      && 'maximum_threshold_active;maximum_threshold_evaluated;above_maximum;'
      && 'availability_status;material_found;batch_managed;'
      && 'batch_found;batch_expiration_date;expiration_as_of;expiration_status;'
      && 'remaining_shelf_life_days;minimum_shelf_life_days;'
      && 'shelf_life_threshold_active;shelf_life_threshold_evaluated;'
      && 'below_minimum_shelf_life;shelf_life_status;'
      && 'allocation_eligibility_status;'
      && 'batch_restricted;status;message'.
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
        iv_value = lv_json_schema ) TO lt_json_fields.
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
        iv_name  = 'safety_stock'
        iv_value = p_saf ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'safety_stock_threshold_active'
        iv_value = lv_safety_stock_active ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'safety_stock_threshold_evaluated'
        iv_value = lv_safety_stock_evaluated ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'at_or_below_safety_stock'
        iv_value = lv_at_or_below_safety_stock ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'allocatable_quantity'
        iv_value = lv_allocatable_quantity ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>property(
        iv_name  = 'safety_stock'
        iv_value = p_saf ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'safety_stock_threshold_active'
        iv_value = lv_safety_stock_active ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'safety_stock_threshold_evaluated'
        iv_value = lv_safety_stock_evaluated ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'at_or_below_safety_stock'
        iv_value = lv_at_or_below_safety_stock ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'allocatable_quantity'
        iv_value = lv_allocatable_quantity ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>property(
      iv_name  = 'allocatable_quantity_status'
      iv_value = lv_allocatable_quantity_status ) TO lt_json_fields.
    IF p_typed = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'minimum_allocatable_quantity'
        iv_value = p_amin ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'minimum_allocatable_threshold_active'
        iv_value = lv_allocatable_minimum_active ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'minimum_allocatable_threshold_evaluated'
        iv_value = lv_alloc_min_evaluated ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'below_minimum_allocatable'
        iv_value = lv_below_allocatable_minimum ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'maximum_allocatable_quantity'
        iv_value = p_amax ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'maximum_allocatable_threshold_active'
        iv_value = lv_allocatable_maximum_active ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'maximum_allocatable_threshold_evaluated'
        iv_value = lv_alloc_max_evaluated ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'above_maximum_allocatable'
        iv_value = lv_above_allocatable_maximum ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>property(
        iv_name  = 'minimum_allocatable_quantity'
        iv_value = p_amin ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'minimum_allocatable_threshold_active'
        iv_value = lv_allocatable_minimum_active ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'minimum_allocatable_threshold_evaluated'
        iv_value = lv_alloc_min_evaluated ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'below_minimum_allocatable'
        iv_value = lv_below_allocatable_minimum ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'maximum_allocatable_quantity'
        iv_value = p_amax ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'maximum_allocatable_threshold_active'
        iv_value = lv_allocatable_maximum_active ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'maximum_allocatable_threshold_evaluated'
        iv_value = lv_alloc_max_evaluated ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'above_maximum_allocatable'
        iv_value = lv_above_allocatable_maximum ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>property(
      iv_name  = 'allocatable_range_status'
      iv_value = lv_allocatable_range_status ) TO lt_json_fields.
    IF p_typed = abap_true.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'net_allocation_active'
        iv_value = lv_existing_alloc_active ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'existing_allocated_quantity'
        iv_value = lv_existing_alloc_qty ) TO lt_json_fields.
      IF lv_existing_pct_available = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'existing_allocated_pct'
          iv_value = lv_existing_allocated_pct ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'existing_allocated_pct' ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'existing_allocation_count'
        iv_value = lv_existing_alloc_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'existing_allocated_row_count'
        iv_value = lv_existing_alloc_row_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'existing_allocation_run_count'
        iv_value = lv_existing_alloc_run_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'existing_allocation_unit_count'
        iv_value = lv_existing_alloc_unit_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'existing_allocation_units_mixed'
        iv_value = lv_existing_alloc_units_mixed ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'existing_allocations_overflow'
        iv_value = lv_existing_alloc_overflow ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'existing_allocations_overflow_quantity'
        iv_value = lv_existing_alloc_overflow_qty ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'existing_allocations_evaluated'
        iv_value = lv_existing_alloc_evaluated ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>property(
        iv_name  = 'net_allocation_active'
        iv_value = lv_existing_alloc_active ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'existing_allocated_quantity'
        iv_value = lv_existing_alloc_qty ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'existing_allocated_pct'
        iv_value = lv_existing_allocated_pct_text ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'existing_allocation_count'
        iv_value = lv_existing_alloc_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'existing_allocated_row_count'
        iv_value = lv_existing_alloc_row_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'existing_allocation_run_count'
        iv_value = lv_existing_alloc_run_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'existing_allocation_unit_count'
        iv_value = lv_existing_alloc_unit_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'existing_allocation_units_mixed'
        iv_value = lv_existing_alloc_units_mixed ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'existing_allocations_overflow'
        iv_value = lv_existing_alloc_overflow ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'existing_allocations_overflow_quantity'
        iv_value = lv_existing_alloc_overflow_qty ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'existing_allocations_evaluated'
        iv_value = lv_existing_alloc_evaluated ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>property(
      iv_name  = 'existing_allocations_status'
      iv_value = lv_existing_alloc_status ) TO lt_json_fields.
    IF p_typed = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'net_available_quantity'
        iv_value = lv_net_available_quantity ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'net_allocatable_quantity'
        iv_value = lv_net_allocatable_quantity ) TO lt_json_fields.
      IF lv_net_pct_available = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'net_allocatable_pct'
          iv_value = lv_net_allocatable_pct ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'net_allocatable_pct' ) TO lt_json_fields.
      ENDIF.
    ELSE.
      APPEND zcl_stock_json=>property(
        iv_name  = 'net_available_quantity'
        iv_value = lv_net_available_quantity ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'net_allocatable_quantity'
        iv_value = lv_net_allocatable_quantity ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'net_allocatable_pct'
        iv_value = lv_net_allocatable_pct_text ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>property(
      iv_name  = 'net_allocatable_quantity_status'
      iv_value = lv_net_allocatable_status ) TO lt_json_fields.
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
      iv_name  = 'expiration_as_of'
      iv_value = lv_expiration_as_of ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'expiration_status'
      iv_value = lv_expiration_status ) TO lt_json_fields.
    IF p_typed = abap_true.
      IF ls_available-batch_expiration_date IS INITIAL.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'remaining_shelf_life_days' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'remaining_shelf_life_days'
          iv_value = lv_remaining_shelf_life ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'minimum_shelf_life_days'
        iv_value = p_shelf ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'shelf_life_threshold_active'
        iv_value = lv_shelf_life_threshold_active ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'shelf_life_threshold_evaluated'
        iv_value = lv_shelf_life_evaluated ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'below_minimum_shelf_life'
        iv_value = lv_below_minimum_shelf_life ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>property(
        iv_name  = 'remaining_shelf_life_days'
        iv_value = lv_remaining_shelf_life_text ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'minimum_shelf_life_days'
        iv_value = p_shelf ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'shelf_life_threshold_active'
        iv_value = lv_shelf_life_threshold_active ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'shelf_life_threshold_evaluated'
        iv_value = lv_shelf_life_evaluated ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'below_minimum_shelf_life'
        iv_value = lv_below_minimum_shelf_life ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>property(
      iv_name  = 'shelf_life_status'
      iv_value = lv_shelf_life_status ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'allocation_eligibility_status'
      iv_value = lv_eligibility_status ) TO lt_json_fields.
    IF p_typed = abap_true.
      CLEAR lt_filter_value_fields.
      IF lv_target_unit IS INITIAL.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'target_unit' ) TO lt_filter_value_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'target_unit'
          iv_value = lv_target_unit ) TO lt_filter_value_fields.
      ENDIF.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'minimum_quantity'
        iv_value   = p_min
        iv_text    = 'n/a'
        iv_present = xsdbool( p_min > 0 )
        iv_typed   = abap_true ) TO lt_filter_value_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'maximum_quantity'
        iv_value   = p_max
        iv_text    = 'n/a'
        iv_present = xsdbool( p_max > 0 )
        iv_typed   = abap_true ) TO lt_filter_value_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'minimum_shelf_life_days'
        iv_value   = p_shelf
        iv_text    = 'n/a'
        iv_present = xsdbool( p_shelf > 0 )
        iv_typed   = abap_true ) TO lt_filter_value_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'safety_stock'
        iv_value   = p_saf
        iv_text    = 'n/a'
        iv_present = xsdbool( p_saf > 0 )
        iv_typed   = abap_true ) TO lt_filter_value_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'minimum_allocatable_quantity'
        iv_value   = p_amin
        iv_text    = 'n/a'
        iv_present = xsdbool( p_amin > 0 )
        iv_typed   = abap_true ) TO lt_filter_value_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'maximum_allocatable_quantity'
        iv_value   = p_amax
        iv_text    = 'n/a'
        iv_present = xsdbool( p_amax > 0 )
        iv_typed   = abap_true ) TO lt_filter_value_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'net_existing_allocations'
        iv_value = p_net ) TO lt_filter_value_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'expiration_as_of'
        iv_value = lv_expiration_as_of ) TO lt_filter_value_fields.
      APPEND zcl_stock_json=>object_property(
        iv_name   = 'filter_values'
        it_fields = lt_filter_value_fields ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>property(
      iv_name  = 'status'
      iv_value = 'success' ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'message'
      iv_value = 'Stock read completed' ) TO lt_json_fields.
    IF p_meta = abap_true.
      lt_summary_fields = lt_json_fields.
      CLEAR lt_scope_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'material'
        iv_value = p_matnr ) TO lt_scope_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'plant'
        iv_value = p_werks ) TO lt_scope_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'storage_location'
        iv_value = p_lgort ) TO lt_scope_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'batch'
        iv_value = p_charg ) TO lt_scope_fields.
      CLEAR lt_filter_fields.
      CLEAR lt_filter_names.
      IF lv_target_unit IS NOT INITIAL.
        APPEND zcl_stock_json=>property(
          iv_name  = 'target_unit'
          iv_value = lv_target_unit ) TO lt_filter_fields.
        APPEND 'target_unit' TO lt_filter_names.
      ENDIF.
      IF p_min > 0.
        APPEND zcl_stock_json=>property(
          iv_name  = 'minimum_quantity'
          iv_value = p_min ) TO lt_filter_fields.
        APPEND 'minimum_quantity' TO lt_filter_names.
      ENDIF.
      IF p_max > 0.
        APPEND zcl_stock_json=>property(
          iv_name  = 'maximum_quantity'
          iv_value = p_max ) TO lt_filter_fields.
        APPEND 'maximum_quantity' TO lt_filter_names.
      ENDIF.
      IF p_expdt IS NOT INITIAL.
        APPEND zcl_stock_json=>property(
          iv_name  = 'expiration_as_of'
          iv_value = p_expdt ) TO lt_filter_fields.
        APPEND 'expiration_as_of' TO lt_filter_names.
      ENDIF.
      IF p_shelf > 0.
        APPEND zcl_stock_json=>property(
          iv_name  = 'minimum_shelf_life_days'
          iv_value = p_shelf ) TO lt_filter_fields.
        APPEND 'minimum_shelf_life_days' TO lt_filter_names.
      ENDIF.
      IF p_saf > 0.
        APPEND zcl_stock_json=>property(
          iv_name  = 'safety_stock'
          iv_value = p_saf ) TO lt_filter_fields.
        APPEND 'safety_stock' TO lt_filter_names.
      ENDIF.
      IF p_amin > 0.
        APPEND zcl_stock_json=>property(
          iv_name  = 'minimum_allocatable_quantity'
          iv_value = p_amin ) TO lt_filter_fields.
        APPEND 'minimum_allocatable_quantity' TO lt_filter_names.
      ENDIF.
      IF p_amax > 0.
        APPEND zcl_stock_json=>property(
          iv_name  = 'maximum_allocatable_quantity'
          iv_value = p_amax ) TO lt_filter_fields.
        APPEND 'maximum_allocatable_quantity' TO lt_filter_names.
      ENDIF.
      IF p_net = abap_true.
        APPEND zcl_stock_json=>property(
          iv_name  = 'net_existing_allocations'
          iv_value = 'true' ) TO lt_filter_fields.
        APPEND 'net_existing_allocations' TO lt_filter_names.
      ENDIF.
      CLEAR lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'schema_version'
        iv_value = lv_json_schema ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'mode'
        iv_value = 'stock' ) TO lt_json_fields.
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

  WRITE: / 'Stock available:', lv_output_quantity, lv_output_unit,
         / 'Base stock:', lv_base_quantity, lv_base_unit,
         / 'Target unit:', lv_target_unit,
         / 'Converted:', lv_converted,
         / 'Safety stock:', p_saf,
         / 'Safety-stock threshold active:', lv_safety_stock_active,
         / 'Safety-stock threshold evaluated:', lv_safety_stock_evaluated,
         / 'At or below safety stock:', lv_at_or_below_safety_stock,
         / 'Allocatable quantity:', lv_allocatable_quantity,
         / 'Allocatable quantity status:', lv_allocatable_quantity_status,
         / 'Minimum allocatable quantity:', p_amin,
         / 'Minimum allocatable threshold active:',
           lv_allocatable_minimum_active,
         / 'Minimum allocatable threshold evaluated:',
           lv_alloc_min_evaluated,
         / 'Below minimum allocatable:', lv_below_allocatable_minimum,
         / 'Maximum allocatable quantity:', p_amax,
         / 'Maximum allocatable threshold active:',
           lv_allocatable_maximum_active,
         / 'Maximum allocatable threshold evaluated:',
           lv_alloc_max_evaluated,
         / 'Above maximum allocatable:', lv_above_allocatable_maximum,
         / 'Allocatable range status:', lv_allocatable_range_status,
         / 'Net existing allocations:', lv_existing_alloc_active,
         / 'Existing allocated quantity:', lv_existing_alloc_qty,
         / 'Existing allocated percentage:', lv_existing_allocated_pct_text,
         / 'Existing allocation rows:', lv_existing_alloc_count,
         / 'Existing allocated rows:', lv_existing_alloc_row_count,
         / 'Existing allocation runs:', lv_existing_alloc_run_count,
         / 'Existing allocation units:', lv_existing_alloc_unit_count,
         / 'Existing allocation units mixed:', lv_existing_alloc_units_mixed,
         / 'Existing allocations overflow:', lv_existing_alloc_overflow,
         / 'Existing allocations overflow quantity:',
           lv_existing_alloc_overflow_qty,
         / 'Existing allocations evaluated:', lv_existing_alloc_evaluated,
         / 'Existing allocations status:', lv_existing_alloc_status,
         / 'Net available quantity:', lv_net_available_quantity,
         / 'Net allocatable quantity:', lv_net_allocatable_quantity,
         / 'Net allocatable percentage:', lv_net_allocatable_pct_text,
         / 'Net allocatable quantity status:', lv_net_allocatable_status,
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
         / 'Batch expiration date:', ls_available-batch_expiration_date,
         / 'Expiration as-of date:', lv_expiration_as_of,
         / 'Expiration status:', lv_expiration_status,
         / 'Remaining shelf life:', lv_remaining_shelf_life_text,
         / 'Minimum shelf life:', p_shelf,
         / 'Shelf-life threshold active:', lv_shelf_life_threshold_active,
         / 'Shelf-life threshold evaluated:',
           lv_shelf_life_evaluated,
         / 'Below minimum shelf life:', lv_below_minimum_shelf_life,
         / 'Shelf-life status:', lv_shelf_life_status,
         / 'Allocation eligibility status:', lv_eligibility_status.
