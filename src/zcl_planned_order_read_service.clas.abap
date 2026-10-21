CLASS zcl_planned_order_read_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_order_result,
        request_index         TYPE i,
        planned_order         TYPE zif_planned_order_read_repo=>ty_order_number,
        order_header          TYPE zif_planned_order_read_repo=>ty_order_header,
        quantity_in_base_unit TYPE decfloat34,
        is_found              TYPE abap_bool,
        is_quantity_converted TYPE abap_bool,
      END OF ty_order_result.
    TYPES ty_order_results TYPE STANDARD TABLE OF ty_order_result
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_read_result,
        orders                  TYPE ty_order_results,
        found_count             TYPE i,
        not_found_count         TYPE i,
        conversion_failed_count TYPE i,
        is_truncated            TYPE abap_bool,
        next_finish_date        TYPE plaf-pedtr,
        next_planned_order      TYPE plaf-plnum,
        snapshot_timestamp      TYPE timestampl,
        is_successful           TYPE abap_bool,
      END OF ty_bulk_read_result.

    METHODS constructor
      IMPORTING
        io_repository TYPE REF TO zif_planned_order_read_repo.

    METHODS read_orders_bulk
      IMPORTING
        it_planned_orders TYPE zif_planned_order_read_repo=>ty_order_numbers
      RETURNING
        VALUE(rs_result)  TYPE ty_bulk_read_result
      RAISING
        zcx_invalid_stock_request.

    METHODS read_orders_by_finish_window
      IMPORTING
        is_selection     TYPE zif_planned_order_read_repo=>ty_order_selection
      RETURNING
        VALUE(rs_result) TYPE ty_bulk_read_result
      RAISING
        zcx_invalid_stock_request.

  PRIVATE SECTION.
    METHODS validate_order_numbers
      IMPORTING
        it_planned_orders TYPE zif_planned_order_read_repo=>ty_order_numbers
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_bulk_order_headers
      IMPORTING
        it_planned_orders TYPE zif_planned_order_read_repo=>ty_order_numbers
        it_order_headers  TYPE zif_planned_order_read_repo=>ty_order_headers
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_order_selection
      IMPORTING
        is_selection TYPE zif_planned_order_read_repo=>ty_order_selection
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_finish_window_headers
      IMPORTING
        is_selection     TYPE zif_planned_order_read_repo=>ty_order_selection
        it_order_headers TYPE zif_planned_order_read_repo=>ty_order_headers
      RAISING
        zcx_invalid_stock_request.

    METHODS map_order_headers
      IMPORTING
        it_planned_orders TYPE zif_planned_order_read_repo=>ty_order_numbers
        it_order_headers  TYPE zif_planned_order_read_repo=>ty_order_headers
        iv_is_truncated   TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)  TYPE ty_bulk_read_result.

    DATA mo_repository TYPE REF TO zif_planned_order_read_repo.
ENDCLASS.

CLASS zcl_planned_order_read_service IMPLEMENTATION.

  METHOD constructor.
    mo_repository = io_repository.
  ENDMETHOD.

  METHOD validate_order_numbers.
    TYPES ty_seen_order TYPE zif_planned_order_read_repo=>ty_order_number.
    DATA lt_seen_orders TYPE HASHED TABLE OF ty_seen_order
      WITH UNIQUE KEY table_line.

    LOOP AT it_planned_orders INTO DATA(lv_planned_order).
      INSERT lv_planned_order INTO TABLE lt_seen_orders.
      IF lv_planned_order IS INITIAL OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_bulk_order_headers.
    TYPES ty_seen_order TYPE zif_planned_order_read_repo=>ty_order_number.
    DATA lt_requested_orders TYPE HASHED TABLE OF ty_seen_order
      WITH UNIQUE KEY table_line.
    DATA lt_seen_orders TYPE HASHED TABLE OF ty_seen_order
      WITH UNIQUE KEY table_line.

    LOOP AT it_planned_orders INTO DATA(lv_requested_order).
      INSERT lv_requested_order INTO TABLE lt_requested_orders.
    ENDLOOP.

    LOOP AT it_order_headers INTO DATA(ls_order_header).
      IF ls_order_header-planned_order IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_requested_orders
        WITH TABLE KEY table_line = ls_order_header-planned_order
        TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      INSERT ls_order_header-planned_order INTO TABLE lt_seen_orders.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD read_orders_bulk.
    DATA lt_order_headers TYPE zif_planned_order_read_repo=>ty_order_headers.
    DATA lv_snapshot_timestamp TYPE timestampl.

    IF it_planned_orders IS INITIAL.
      rs_result-is_successful = abap_true.
      RETURN.
    ENDIF.

    validate_order_numbers( it_planned_orders = it_planned_orders ).
    lt_order_headers = mo_repository->read_orders(
      it_planned_orders = it_planned_orders ).
    GET TIME STAMP FIELD lv_snapshot_timestamp.
    validate_bulk_order_headers(
      it_planned_orders = it_planned_orders
      it_order_headers  = lt_order_headers ).
    rs_result = map_order_headers(
      it_planned_orders = it_planned_orders
      it_order_headers  = lt_order_headers ).
    rs_result-snapshot_timestamp = lv_snapshot_timestamp.
  ENDMETHOD.

  METHOD read_orders_by_finish_window.
    DATA lt_order_headers TYPE zif_planned_order_read_repo=>ty_order_headers.
    DATA lt_planned_orders TYPE zif_planned_order_read_repo=>ty_order_numbers.
    DATA lv_is_truncated TYPE abap_bool.
    DATA lv_last_index TYPE i.
    DATA ls_last_order TYPE ty_order_result.
    DATA lv_snapshot_timestamp TYPE timestampl.

    validate_order_selection( is_selection = is_selection ).
    lt_order_headers = mo_repository->read_orders_by_finish_window(
      is_selection = is_selection ).
    GET TIME STAMP FIELD lv_snapshot_timestamp.
    validate_finish_window_headers(
      is_selection     = is_selection
      it_order_headers = lt_order_headers ).

    IF lines( lt_order_headers ) > is_selection-maximum_results.
      lv_is_truncated = abap_true.
      DELETE lt_order_headers INDEX is_selection-maximum_results + 1.
    ENDIF.

    LOOP AT lt_order_headers INTO DATA(ls_order_header).
      APPEND ls_order_header-planned_order TO lt_planned_orders.
    ENDLOOP.

    rs_result = map_order_headers(
      it_planned_orders = lt_planned_orders
      it_order_headers  = lt_order_headers
      iv_is_truncated   = lv_is_truncated ).

    IF lv_is_truncated = abap_true.
      lv_last_index = lines( rs_result-orders ).
      READ TABLE rs_result-orders INTO ls_last_order INDEX lv_last_index.
      IF sy-subrc = 0.
        rs_result-next_finish_date =
          ls_last_order-order_header-finish_date.
        rs_result-next_planned_order = ls_last_order-planned_order.
      ENDIF.
    ENDIF.
    rs_result-snapshot_timestamp = lv_snapshot_timestamp.
  ENDMETHOD.

  METHOD validate_finish_window_headers.
    TYPES ty_seen_order TYPE zif_planned_order_read_repo=>ty_order_number.
    DATA lt_seen_orders TYPE HASHED TABLE OF ty_seen_order
      WITH UNIQUE KEY table_line.
    DATA lv_has_previous_order TYPE abap_bool.
    DATA lv_base_quantity TYPE decfloat34.
    DATA ls_previous_order TYPE
      zif_planned_order_read_repo=>ty_order_header.

    IF lines( it_order_headers ) > is_selection-maximum_results + 1.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_order_headers INTO DATA(ls_order_header).
      IF is_selection-filter_base_quantity_from = abap_true
          OR is_selection-filter_base_quantity_to = abap_true.
        IF ls_order_header-base_unit IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ELSEIF ls_order_header-order_unit = ls_order_header-base_unit.
          lv_base_quantity = CONV decfloat34( ls_order_header-quantity ).
        ELSEIF ls_order_header-unit_to_base_numerator <= 0
            OR ls_order_header-unit_to_base_denominator <= 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ELSEIF ls_order_header-quantity <= 0.
          CLEAR lv_base_quantity.
        ELSE.
          lv_base_quantity =
            CONV decfloat34( ls_order_header-quantity )
            * CONV decfloat34(
              ls_order_header-unit_to_base_numerator )
            / CONV decfloat34(
              ls_order_header-unit_to_base_denominator ).
        ENDIF.
      ENDIF.

      IF ls_order_header-planned_order IS INITIAL
          OR ls_order_header-material <> is_selection-material
          OR ls_order_header-plant <> is_selection-plant
          OR ( ( is_selection-filter_planning_plant = abap_true
              OR is_selection-planning_plant IS NOT INITIAL )
            AND ls_order_header-planning_plant <>
              is_selection-planning_plant )
          OR ( is_selection-creation_date_from IS NOT INITIAL
            AND ( zcl_date_validation=>is_valid_gregorian_date(
              iv_date = ls_order_header-creation_date ) <> abap_true
              OR ls_order_header-creation_date <
                is_selection-creation_date_from
              OR ls_order_header-creation_date >
                is_selection-creation_date_to ) )
          OR ( is_selection-last_change_timestamp_from IS NOT INITIAL
            AND ls_order_header-last_change_timestamp <
              is_selection-last_change_timestamp_from )
          OR ( is_selection-last_change_timestamp_to IS NOT INITIAL
            AND ls_order_header-last_change_timestamp >
              is_selection-last_change_timestamp_to )
          OR ( ( is_selection-filter_planned_order_user = abap_true
              OR is_selection-planned_order_user IS NOT INITIAL )
            AND ls_order_header-planned_order_user <>
              is_selection-planned_order_user )
          OR ( ( is_selection-filter_sales_order = abap_true
              OR is_selection-sales_order IS NOT INITIAL )
            AND ls_order_header-sales_order <>
              is_selection-sales_order )
          OR ( ( is_selection-filter_planning_scenario = abap_true
              OR is_selection-planning_scenario IS NOT INITIAL )
            AND ls_order_header-planning_scenario <>
              is_selection-planning_scenario )
          OR ( ( is_selection-filter_order_type = abap_true
              OR is_selection-order_type IS NOT INITIAL )
            AND ls_order_header-order_type <> is_selection-order_type )
          OR ( is_selection-filter_storage_location = abap_true
            AND ls_order_header-storage_location <>
              is_selection-storage_location )
          OR ( is_selection-filter_procurement_indicator = abap_true
            AND ls_order_header-procurement_indicator <>
              is_selection-procurement_indicator )
          OR ( is_selection-filter_special_proc_type = abap_true
            AND ls_order_header-special_procurement_type <>
              is_selection-special_procurement_type )
          OR ( ( is_selection-filter_order_unit = abap_true
              OR is_selection-order_unit IS NOT INITIAL )
            AND ls_order_header-order_unit <> is_selection-order_unit )
          OR ( is_selection-positive_quantity_only = abap_true
            AND ls_order_header-quantity <= 0 )
          OR ( is_selection-filter_quantity_from = abap_true
            AND ls_order_header-quantity < is_selection-quantity_from )
          OR ( is_selection-filter_quantity_to = abap_true
            AND ls_order_header-quantity > is_selection-quantity_to )
          OR ( is_selection-filter_base_quantity_from = abap_true
            AND lv_base_quantity < is_selection-base_quantity_from )
          OR ( is_selection-filter_base_quantity_to = abap_true
            AND lv_base_quantity > is_selection-base_quantity_to )
          OR ( is_selection-filter_mrp_controller = abap_true
            AND ls_order_header-mrp_controller <>
              is_selection-mrp_controller )
          OR ( is_selection-filter_production_supervisor = abap_true
            AND ls_order_header-production_supervisor <>
              is_selection-production_supervisor )
          OR ( is_selection-filter_production_version = abap_true
            AND ls_order_header-production_version <>
              is_selection-production_version )
          OR ( is_selection-filter_mrp_area = abap_true
            AND ls_order_header-mrp_area <> is_selection-mrp_area )
          OR ( is_selection-filter_account_category = abap_true
            AND ls_order_header-account_assignment_category <>
              is_selection-account_assignment_category )
          OR ( is_selection-filter_sales_order_item = abap_true
            AND ls_order_header-sales_order_item <>
              is_selection-sales_order_item )
          OR ( is_selection-filter_sales_schedule_line = abap_true
            AND ls_order_header-sales_order_schedule_line <>
              is_selection-sales_order_schedule_line )
          OR ( is_selection-filter_special_stock = abap_true
            AND ls_order_header-special_stock_indicator <>
              is_selection-special_stock_indicator )
          OR ( is_selection-filter_fixed_indicator = abap_true
            AND ls_order_header-fixed_indicator <>
              is_selection-fixed_indicator )
          OR ( ( is_selection-filter_start_date = abap_true
              OR is_selection-start_date IS NOT INITIAL )
            AND ls_order_header-start_date <> is_selection-start_date )
          OR ( is_selection-start_date_from IS NOT INITIAL
            AND ( zcl_date_validation=>is_valid_gregorian_date(
              iv_date = ls_order_header-start_date ) <> abap_true
              OR ls_order_header-start_date <
                is_selection-start_date_from
              OR ls_order_header-start_date >
                is_selection-start_date_to ) )
          OR ( ( is_selection-filter_scheduled_start_date = abap_true
              OR is_selection-scheduled_start_date IS NOT INITIAL )
            AND ls_order_header-scheduled_start_date <>
              is_selection-scheduled_start_date )
          OR ( ( is_selection-filter_scheduled_finish_date = abap_true
              OR is_selection-scheduled_finish_date IS NOT INITIAL )
            AND ls_order_header-scheduled_finish_date <>
              is_selection-scheduled_finish_date )
          OR ( is_selection-scheduled_start_date_from IS NOT INITIAL
            AND ( zcl_date_validation=>is_valid_gregorian_date(
              iv_date = ls_order_header-scheduled_start_date ) <>
                abap_true
              OR ls_order_header-scheduled_start_date <
                is_selection-scheduled_start_date_from
              OR ls_order_header-scheduled_start_date >
                is_selection-scheduled_start_date_to ) )
          OR ( is_selection-scheduled_finish_date_from IS NOT INITIAL
            AND ( zcl_date_validation=>is_valid_gregorian_date(
              iv_date = ls_order_header-scheduled_finish_date ) <>
                abap_true
              OR ls_order_header-scheduled_finish_date <
                is_selection-scheduled_finish_date_from
              OR ls_order_header-scheduled_finish_date >
                is_selection-scheduled_finish_date_to ) )
          OR ( is_selection-filter_scheduled_start_time = abap_true
            AND ( zcl_date_validation=>is_valid_time(
                iv_time = ls_order_header-scheduled_start_time ) <>
                  abap_true
              OR ls_order_header-scheduled_start_time <
                  is_selection-scheduled_start_time_from
              OR ls_order_header-scheduled_start_time >
                  is_selection-scheduled_start_time_to ) )
          OR ( is_selection-filter_scheduled_finish_time = abap_true
            AND ( zcl_date_validation=>is_valid_time(
                iv_time = ls_order_header-scheduled_finish_time ) <>
                  abap_true
              OR ls_order_header-scheduled_finish_time <
                  is_selection-scheduled_finish_time_from
              OR ls_order_header-scheduled_finish_time >
                  is_selection-scheduled_finish_time_to ) )
          OR zcl_date_validation=>is_valid_gregorian_date(
            iv_date = ls_order_header-finish_date ) <> abap_true
          OR ls_order_header-finish_date <
            is_selection-finish_date_from
          OR ls_order_header-finish_date >
            is_selection-finish_date_to
          OR ( is_selection-after_finish_date IS NOT INITIAL
            AND ( ls_order_header-finish_date <
              is_selection-after_finish_date
              OR ( ls_order_header-finish_date =
                is_selection-after_finish_date
                AND ls_order_header-planned_order <=
                  is_selection-after_planned_order ) ) ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      INSERT ls_order_header-planned_order INTO TABLE lt_seen_orders.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      IF lv_has_previous_order = abap_true
          AND ( ls_order_header-finish_date <
            ls_previous_order-finish_date
            OR ( ls_order_header-finish_date =
              ls_previous_order-finish_date
              AND ls_order_header-planned_order <=
                ls_previous_order-planned_order ) ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      ls_previous_order = ls_order_header.
      lv_has_previous_order = abap_true.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_order_selection.
    IF is_selection-material IS INITIAL
        OR is_selection-plant IS INITIAL
        OR zcl_date_validation=>is_valid_gregorian_date(
          iv_date = is_selection-finish_date_from ) <> abap_true
        OR zcl_date_validation=>is_valid_gregorian_date(
          iv_date = is_selection-finish_date_to ) <> abap_true
        OR is_selection-finish_date_from > is_selection-finish_date_to
        OR is_selection-maximum_results < 1
        OR is_selection-maximum_results > 500
        OR ( is_selection-filter_planning_plant <> abap_true
          AND is_selection-filter_planning_plant <> abap_false )
        OR ( is_selection-filter_order_type <> abap_true
          AND is_selection-filter_order_type <> abap_false )
        OR ( is_selection-filter_planned_order_user <> abap_true
          AND is_selection-filter_planned_order_user <> abap_false )
        OR ( is_selection-filter_sales_order <> abap_true
          AND is_selection-filter_sales_order <> abap_false )
        OR ( is_selection-filter_planning_scenario <> abap_true
          AND is_selection-filter_planning_scenario <> abap_false )
        OR ( is_selection-filter_special_stock <> abap_true
          AND is_selection-filter_special_stock <> abap_false )
        OR ( is_selection-filter_special_stock = abap_false
          AND is_selection-special_stock_indicator IS NOT INITIAL )
        OR ( is_selection-filter_fixed_indicator <> abap_true
          AND is_selection-filter_fixed_indicator <> abap_false )
        OR ( is_selection-filter_fixed_indicator = abap_false
          AND is_selection-fixed_indicator IS NOT INITIAL )
        OR ( is_selection-filter_fixed_indicator = abap_true
          AND is_selection-fixed_indicator <> abap_true
          AND is_selection-fixed_indicator <> abap_false )
        OR ( is_selection-filter_storage_location <> abap_true
          AND is_selection-filter_storage_location <> abap_false )
        OR ( is_selection-filter_storage_location = abap_false
          AND is_selection-storage_location IS NOT INITIAL )
        OR ( is_selection-filter_procurement_indicator <> abap_true
          AND is_selection-filter_procurement_indicator <> abap_false )
        OR ( is_selection-filter_procurement_indicator = abap_false
          AND is_selection-procurement_indicator IS NOT INITIAL )
        OR ( is_selection-filter_special_proc_type <> abap_true
          AND is_selection-filter_special_proc_type <> abap_false )
        OR ( is_selection-filter_special_proc_type = abap_false
          AND is_selection-special_procurement_type IS NOT INITIAL )
        OR ( is_selection-filter_order_unit <> abap_true
          AND is_selection-filter_order_unit <> abap_false )
        OR ( is_selection-positive_quantity_only <> abap_true
          AND is_selection-positive_quantity_only <> abap_false )
        OR ( is_selection-filter_quantity_from <> abap_true
          AND is_selection-filter_quantity_from <> abap_false )
        OR ( is_selection-filter_quantity_from = abap_false
          AND is_selection-quantity_from IS NOT INITIAL )
        OR ( is_selection-filter_quantity_to <> abap_true
          AND is_selection-filter_quantity_to <> abap_false )
        OR ( is_selection-filter_quantity_to = abap_false
          AND is_selection-quantity_to IS NOT INITIAL )
        OR ( is_selection-filter_quantity_from = abap_true
          AND is_selection-filter_quantity_to = abap_true
          AND is_selection-quantity_from > is_selection-quantity_to )
        OR ( is_selection-filter_base_quantity_from <> abap_true
          AND is_selection-filter_base_quantity_from <> abap_false )
        OR ( is_selection-filter_base_quantity_from = abap_false
          AND is_selection-base_quantity_from IS NOT INITIAL )
        OR ( is_selection-filter_base_quantity_to <> abap_true
          AND is_selection-filter_base_quantity_to <> abap_false )
        OR ( is_selection-filter_base_quantity_to = abap_false
          AND is_selection-base_quantity_to IS NOT INITIAL )
        OR ( is_selection-filter_base_quantity_from = abap_true
          AND is_selection-filter_base_quantity_to = abap_true
          AND is_selection-base_quantity_from >
            is_selection-base_quantity_to )
        OR ( is_selection-filter_mrp_controller <> abap_true
          AND is_selection-filter_mrp_controller <> abap_false )
        OR ( is_selection-filter_mrp_controller = abap_false
          AND is_selection-mrp_controller IS NOT INITIAL )
        OR ( is_selection-filter_production_supervisor <> abap_true
          AND is_selection-filter_production_supervisor <> abap_false )
        OR ( is_selection-filter_production_supervisor = abap_false
          AND is_selection-production_supervisor IS NOT INITIAL )
        OR ( is_selection-filter_production_version <> abap_true
          AND is_selection-filter_production_version <> abap_false )
        OR ( is_selection-filter_production_version = abap_false
          AND is_selection-production_version IS NOT INITIAL )
        OR ( is_selection-filter_mrp_area <> abap_true
          AND is_selection-filter_mrp_area <> abap_false )
        OR ( is_selection-filter_mrp_area = abap_false
          AND is_selection-mrp_area IS NOT INITIAL )
        OR ( is_selection-filter_account_category <> abap_true
          AND is_selection-filter_account_category <> abap_false )
        OR ( is_selection-filter_account_category = abap_false
          AND is_selection-account_assignment_category IS NOT INITIAL )
        OR ( is_selection-filter_sales_order_item <> abap_true
          AND is_selection-filter_sales_order_item <> abap_false )
        OR ( is_selection-filter_sales_order_item = abap_false
          AND is_selection-sales_order_item IS NOT INITIAL )
        OR ( is_selection-filter_sales_order_item = abap_true
          AND is_selection-sales_order IS INITIAL )
        OR ( is_selection-filter_sales_schedule_line <> abap_true
          AND is_selection-filter_sales_schedule_line <> abap_false )
        OR ( is_selection-filter_sales_schedule_line = abap_false
          AND is_selection-sales_order_schedule_line IS NOT INITIAL )
        OR ( is_selection-filter_sales_schedule_line = abap_true
          AND ( is_selection-sales_order IS INITIAL
            OR is_selection-filter_sales_order_item <> abap_true
            OR is_selection-sales_order_item IS INITIAL ) )
        OR ( is_selection-creation_date_from IS INITIAL
          AND is_selection-creation_date_to IS NOT INITIAL )
        OR ( is_selection-creation_date_from IS NOT INITIAL
          AND is_selection-creation_date_to IS INITIAL )
        OR ( is_selection-creation_date_from IS NOT INITIAL
          AND ( zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-creation_date_from ) <> abap_true
            OR zcl_date_validation=>is_valid_gregorian_date(
              iv_date = is_selection-creation_date_to ) <> abap_true
            OR is_selection-creation_date_from >
              is_selection-creation_date_to ) )
        OR ( is_selection-last_change_timestamp_from IS NOT INITIAL
          AND is_selection-last_change_timestamp_from <= 0 )
        OR ( is_selection-last_change_timestamp_to IS NOT INITIAL
          AND is_selection-last_change_timestamp_to <= 0 )
        OR ( is_selection-last_change_timestamp_from IS NOT INITIAL
          AND is_selection-last_change_timestamp_to IS NOT INITIAL
          AND is_selection-last_change_timestamp_from >
            is_selection-last_change_timestamp_to )
        OR ( is_selection-filter_scheduled_start_date <> abap_true
          AND is_selection-filter_scheduled_start_date <> abap_false )
        OR ( is_selection-scheduled_start_date IS NOT INITIAL
          AND zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-scheduled_start_date ) <> abap_true )
        OR ( is_selection-filter_scheduled_finish_date <> abap_true
          AND is_selection-filter_scheduled_finish_date <> abap_false )
        OR ( is_selection-scheduled_finish_date IS NOT INITIAL
          AND zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-scheduled_finish_date ) <> abap_true )
        OR ( is_selection-filter_start_date <> abap_true
          AND is_selection-filter_start_date <> abap_false )
        OR ( is_selection-start_date IS NOT INITIAL
          AND zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-start_date ) <> abap_true )
        OR ( is_selection-start_date_from IS INITIAL
          AND is_selection-start_date_to IS NOT INITIAL )
        OR ( is_selection-start_date_from IS NOT INITIAL
          AND is_selection-start_date_to IS INITIAL )
        OR ( is_selection-start_date_from IS NOT INITIAL
          AND ( zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-start_date_from ) <> abap_true
            OR zcl_date_validation=>is_valid_gregorian_date(
              iv_date = is_selection-start_date_to ) <> abap_true
            OR is_selection-start_date_from >
              is_selection-start_date_to ) )
        OR ( is_selection-scheduled_start_date_from IS INITIAL
          AND is_selection-scheduled_start_date_to IS NOT INITIAL )
        OR ( is_selection-scheduled_start_date_from IS NOT INITIAL
          AND is_selection-scheduled_start_date_to IS INITIAL )
        OR ( is_selection-scheduled_start_date_from IS NOT INITIAL
          AND ( zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-scheduled_start_date_from ) <>
              abap_true
            OR zcl_date_validation=>is_valid_gregorian_date(
              iv_date = is_selection-scheduled_start_date_to ) <>
                abap_true
            OR is_selection-scheduled_start_date_from >
              is_selection-scheduled_start_date_to ) )
        OR ( is_selection-scheduled_finish_date_from IS INITIAL
          AND is_selection-scheduled_finish_date_to IS NOT INITIAL )
        OR ( is_selection-scheduled_finish_date_from IS NOT INITIAL
          AND is_selection-scheduled_finish_date_to IS INITIAL )
        OR ( is_selection-scheduled_finish_date_from IS NOT INITIAL
          AND ( zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-scheduled_finish_date_from ) <>
              abap_true
            OR zcl_date_validation=>is_valid_gregorian_date(
              iv_date = is_selection-scheduled_finish_date_to ) <>
                abap_true
            OR is_selection-scheduled_finish_date_from >
              is_selection-scheduled_finish_date_to ) )
        OR ( is_selection-filter_scheduled_start_time <>
              abap_true
          AND is_selection-filter_scheduled_start_time <>
              abap_false )
        OR ( is_selection-filter_scheduled_start_time = abap_false
          AND ( is_selection-scheduled_start_time_from IS NOT INITIAL
            OR is_selection-scheduled_start_time_to IS NOT INITIAL ) )
        OR ( is_selection-filter_scheduled_start_time = abap_true
          AND ( zcl_date_validation=>is_valid_time(
              iv_time = is_selection-scheduled_start_time_from ) <>
                abap_true
            OR zcl_date_validation=>is_valid_time(
              iv_time = is_selection-scheduled_start_time_to ) <>
                abap_true
            OR is_selection-scheduled_start_time_from >
              is_selection-scheduled_start_time_to ) )
        OR ( is_selection-filter_scheduled_finish_time <>
              abap_true
          AND is_selection-filter_scheduled_finish_time <>
              abap_false )
        OR ( is_selection-filter_scheduled_finish_time = abap_false
          AND ( is_selection-scheduled_finish_time_from IS NOT INITIAL
            OR is_selection-scheduled_finish_time_to IS NOT INITIAL ) )
        OR ( is_selection-filter_scheduled_finish_time = abap_true
          AND ( zcl_date_validation=>is_valid_time(
              iv_time = is_selection-scheduled_finish_time_from ) <>
                abap_true
            OR zcl_date_validation=>is_valid_time(
              iv_time = is_selection-scheduled_finish_time_to ) <>
                abap_true
            OR is_selection-scheduled_finish_time_from >
              is_selection-scheduled_finish_time_to ) )
        OR ( is_selection-after_finish_date IS INITIAL
          AND is_selection-after_planned_order IS NOT INITIAL )
        OR ( is_selection-after_finish_date IS NOT INITIAL
          AND is_selection-after_planned_order IS INITIAL )
        OR ( is_selection-after_finish_date IS NOT INITIAL
          AND ( zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-after_finish_date ) <> abap_true
            OR is_selection-after_finish_date <
              is_selection-finish_date_from
            OR is_selection-after_finish_date >
              is_selection-finish_date_to ) ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
  ENDMETHOD.

  METHOD map_order_headers.
    TYPES:
      ty_order_lookup TYPE HASHED TABLE OF
        zif_planned_order_read_repo=>ty_order_header
        WITH UNIQUE KEY planned_order.
    DATA lt_order_lookup TYPE ty_order_lookup.
    DATA(lo_quantity_calculator) = NEW zcl_planned_order_qty_calc( ).

    rs_result-is_successful = abap_true.
    rs_result-is_truncated = iv_is_truncated.
    LOOP AT it_order_headers INTO DATA(ls_lookup_row).
      INSERT ls_lookup_row INTO TABLE lt_order_lookup.
    ENDLOOP.

    LOOP AT it_planned_orders INTO DATA(lv_planned_order).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index = lv_request_index
        planned_order = lv_planned_order ) TO rs_result-orders.
      ASSIGN rs_result-orders[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_order_result>).

      READ TABLE lt_order_lookup
        WITH TABLE KEY planned_order = lv_planned_order
        INTO DATA(ls_order_header).
      IF sy-subrc <> 0.
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-not_found_count.
        CONTINUE.
      ENDIF.

      <ls_order_result>-is_found = abap_true.
      <ls_order_result>-order_header = ls_order_header.
      ADD 1 TO rs_result-found_count.

      IF ls_order_header-base_unit IS INITIAL.
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-conversion_failed_count.
        CONTINUE.
      ENDIF.

      IF ls_order_header-order_unit = ls_order_header-base_unit.
        <ls_order_result>-quantity_in_base_unit =
          CONV decfloat34( ls_order_header-quantity ).
        <ls_order_result>-is_quantity_converted = abap_true.
        CONTINUE.
      ENDIF.

      IF ls_order_header-unit_to_base_numerator <= 0
          OR ls_order_header-unit_to_base_denominator <= 0.
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-conversion_failed_count.
        CONTINUE.
      ENDIF.

      <ls_order_result>-quantity_in_base_unit =
        lo_quantity_calculator->calculate_open_base_quantity(
          iv_planned_quantity   = ls_order_header-quantity
          iv_unit_to_base_num   =
            ls_order_header-unit_to_base_numerator
          iv_unit_to_base_denom =
            ls_order_header-unit_to_base_denominator ).
      <ls_order_result>-is_quantity_converted = abap_true.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
