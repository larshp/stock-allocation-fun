CLASS zcl_prod_order_read_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_status_result,
        status_code       TYPE zif_prod_order_read_repo=>ty_order_status-status_code,
        is_user_status    TYPE abap_bool,
        status_short_name TYPE zif_prod_order_read_repo=>ty_order_status-status_short_name,
        status_name       TYPE zif_prod_order_read_repo=>ty_order_status-status_name,
      END OF ty_status_result.
    TYPES ty_status_results TYPE STANDARD TABLE OF ty_status_result
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_item_result,
        order_item             TYPE
          zif_prod_order_read_repo=>ty_order_item,
        order_quantity_base    TYPE decfloat34,
        received_quantity_base TYPE decfloat34,
        open_quantity_base     TYPE decfloat34,
        is_quantity_converted  TYPE abap_bool,
      END OF ty_item_result.
    TYPES ty_item_results TYPE STANDARD TABLE OF ty_item_result
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_order_result,
        request_index      TYPE i,
        production_order   TYPE
          zif_prod_order_read_repo=>ty_order_number,
        items              TYPE ty_item_results,
        statuses           TYPE ty_status_results,
        status_filter_lost TYPE abap_bool,
        finish_filter_lost TYPE abap_bool,
        is_found           TYPE abap_bool,
      END OF ty_order_result.
    TYPES ty_order_results TYPE STANDARD TABLE OF ty_order_result
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_read_result,
        orders                   TYPE ty_order_results,
        found_count              TYPE i,
        not_found_count          TYPE i,
        conversion_failed_count  TYPE i,
        is_truncated             TYPE abap_bool,
        next_finish_date         TYPE afko-gltrp,
        next_production_order    TYPE
          zif_prod_order_read_repo=>ty_order_number,
        key_selection_timestamp  TYPE timestampl,
        snapshot_timestamp       TYPE timestampl,
        status_filter_lost_count TYPE i,
        finish_filter_lost_count TYPE i,
        is_successful            TYPE abap_bool,
      END OF ty_bulk_read_result.
    TYPES:
      BEGIN OF ty_confirmation_order_result,
        request_index    TYPE i,
        production_order TYPE
          zif_prod_order_read_repo=>ty_order_number,
        confirmations    TYPE
          zif_prod_order_read_repo=>ty_order_confirmations,
        is_found         TYPE abap_bool,
      END OF ty_confirmation_order_result.
    TYPES ty_confirmation_order_results TYPE STANDARD TABLE OF
      ty_confirmation_order_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_operation_order_result,
        request_index    TYPE i,
        production_order TYPE
          zif_prod_order_read_repo=>ty_order_number,
        operations       TYPE
          zif_prod_order_read_repo=>ty_order_operations,
        is_found         TYPE abap_bool,
      END OF ty_operation_order_result.
    TYPES ty_operation_order_results TYPE STANDARD TABLE OF
      ty_operation_order_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_confirmation_read_result,
        orders             TYPE ty_confirmation_order_results,
        found_count        TYPE i,
        empty_count        TYPE i,
        snapshot_timestamp TYPE timestampl,
        is_successful      TYPE abap_bool,
      END OF ty_bulk_confirmation_read_result.
    TYPES:
      BEGIN OF ty_confirmation_operation_summary,
        production_order            TYPE
          zif_prod_order_read_repo=>ty_order_number,
        order_category              TYPE aufk-autyp,
        operation_counter           TYPE afvc-aplzl,
        operation_number            TYPE afvc-vornr,
        operation_sequence          TYPE afvc-plnfl,
        operation_suboperation      TYPE afvc-uvorn,
        operation_description       TYPE afvc-ltxa1,
        control_key                 TYPE afvc-steus,
        quantity_unit               TYPE afru-meinh,
        first_posting_date          TYPE afru-budat,
        last_posting_date           TYPE afru-budat,
        confirmation_count          TYPE i,
        final_confirmation_count    TYPE i,
        reversed_confirmation_count TYPE i,
        yield_quantity_total        TYPE decfloat34,
        rework_quantity_total       TYPE decfloat34,
        scrap_quantity_total        TYPE decfloat34,
        yield_non_reversed_total    TYPE decfloat34,
        rework_non_reversed_total   TYPE decfloat34,
        scrap_non_reversed_total    TYPE decfloat34,
      END OF ty_confirmation_operation_summary.
    TYPES ty_confirmation_operation_summaries TYPE SORTED TABLE OF
      ty_confirmation_operation_summary
      WITH UNIQUE KEY production_order operation_counter
        operation_number operation_sequence operation_suboperation
        quantity_unit.
    TYPES:
      BEGIN OF ty_confirmation_search_result,
        confirmations             TYPE
          zif_prod_order_read_repo=>ty_order_confirmations,
        operation_summaries       TYPE ty_confirmation_operation_summaries,
        returned_count            TYPE i,
        is_truncated              TYPE abap_bool,
        next_posting_date         TYPE afru-budat,
        next_production_order     TYPE
          zif_prod_order_read_repo=>ty_order_number,
        next_confirmation         TYPE afru-rueck,
        next_confirmation_counter TYPE afru-rmzhl,
        snapshot_timestamp        TYPE timestampl,
        is_successful             TYPE abap_bool,
      END OF ty_confirmation_search_result.
    TYPES:
      BEGIN OF ty_base_conf_quantity,
        confirmation_row     TYPE
          zif_prod_order_read_repo=>ty_order_confirmation,
        base_quantity_unit   TYPE mara-meins,
        yield_quantity_base  TYPE mard-labst,
        rework_quantity_base TYPE mard-labst,
        scrap_quantity_base  TYPE mard-labst,
      END OF ty_base_conf_quantity.
    TYPES ty_base_conf_quantities TYPE STANDARD TABLE OF
      ty_base_conf_quantity WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_base_conf_summary,
        production_order               TYPE
          zif_prod_order_read_repo=>ty_order_number,
        order_category                 TYPE aufk-autyp,
        operation_counter              TYPE afvc-aplzl,
        operation_number               TYPE afvc-vornr,
        operation_sequence             TYPE afvc-plnfl,
        operation_suboperation         TYPE afvc-uvorn,
        operation_description          TYPE afvc-ltxa1,
        control_key                    TYPE afvc-steus,
        base_quantity_unit             TYPE mara-meins,
        first_posting_date             TYPE afru-budat,
        last_posting_date              TYPE afru-budat,
        confirmation_count             TYPE i,
        final_confirmation_count       TYPE i,
        reversed_confirmation_count    TYPE i,
        yield_quantity_base_total      TYPE decfloat34,
        rework_quantity_base_total     TYPE decfloat34,
        scrap_quantity_base_total      TYPE decfloat34,
        yield_base_non_reversed_total  TYPE decfloat34,
        rework_base_non_reversed_total TYPE decfloat34,
        scrap_base_non_reversed_total  TYPE decfloat34,
      END OF ty_base_conf_summary.
    TYPES ty_base_conf_summaries TYPE SORTED TABLE OF
      ty_base_conf_summary
      WITH UNIQUE KEY production_order operation_counter
        operation_number operation_sequence operation_suboperation
        base_quantity_unit.
    TYPES:
      BEGIN OF ty_conf_base_search_result,
        raw_result               TYPE ty_confirmation_search_result,
        base_quantities          TYPE ty_base_conf_quantities,
        base_operation_summaries TYPE ty_base_conf_summaries,
      END OF ty_conf_base_search_result.
    TYPES:
      BEGIN OF ty_bulk_operation_read_result,
        orders             TYPE ty_operation_order_results,
        found_count        TYPE i,
        empty_count        TYPE i,
        snapshot_timestamp TYPE timestampl,
        is_successful      TYPE abap_bool,
      END OF ty_bulk_operation_read_result.

    METHODS constructor
      IMPORTING
        io_repository    TYPE REF TO zif_prod_order_read_repo
        io_uom_converter TYPE REF TO zif_material_uom_converter OPTIONAL.

    METHODS read_orders_bulk
      IMPORTING
        it_production_orders TYPE
          zif_prod_order_read_repo=>ty_order_numbers
      RETURNING
        VALUE(rs_result)     TYPE ty_bulk_read_result
      RAISING
        zcx_invalid_stock_request.

    METHODS read_orders_by_finish_window
      IMPORTING
        is_selection     TYPE zif_prod_order_read_repo=>ty_order_selection
      RETURNING
        VALUE(rs_result) TYPE ty_bulk_read_result
      RAISING
        zcx_invalid_stock_request.

    METHODS read_confirmations_bulk
      IMPORTING
        it_production_orders TYPE
          zif_prod_order_read_repo=>ty_order_numbers
      RETURNING
        VALUE(rs_result)     TYPE ty_bulk_confirmation_read_result
      RAISING
        zcx_invalid_stock_request.

    METHODS search_confirmations_by_window
      IMPORTING
        is_selection     TYPE
          zif_prod_order_read_repo=>ty_confirmation_window_selection
      RETURNING
        VALUE(rs_result) TYPE ty_confirmation_search_result
      RAISING
        zcx_invalid_stock_request.

    METHODS search_conf_window_base_unit
      IMPORTING
        is_selection     TYPE
          zif_prod_order_read_repo=>ty_confirmation_window_selection
      RETURNING
        VALUE(rs_result) TYPE ty_conf_base_search_result
      RAISING
        zcx_invalid_stock_request.

    METHODS read_operations_bulk
      IMPORTING
        it_production_orders TYPE
          zif_prod_order_read_repo=>ty_order_numbers
      RETURNING
        VALUE(rs_result)     TYPE ty_bulk_operation_read_result
      RAISING
        zcx_invalid_stock_request.

  PRIVATE SECTION.
    METHODS validate_order_numbers
      IMPORTING
        it_production_orders TYPE
          zif_prod_order_read_repo=>ty_order_numbers
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_order_read_results
      IMPORTING
        it_production_orders TYPE
          zif_prod_order_read_repo=>ty_order_numbers
        it_order_items       TYPE
          zif_prod_order_read_repo=>ty_order_items
        it_order_statuses    TYPE
          zif_prod_order_read_repo=>ty_order_statuses
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_order_selection
      IMPORTING
        is_selection TYPE zif_prod_order_read_repo=>ty_order_selection
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_finish_window_keys
      IMPORTING
        is_selection  TYPE zif_prod_order_read_repo=>ty_order_selection
        it_order_keys TYPE
          zif_prod_order_read_repo=>ty_finish_search_keys
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_confirmation_results
      IMPORTING
        it_production_orders TYPE
          zif_prod_order_read_repo=>ty_order_numbers
        it_confirmations     TYPE
          zif_prod_order_read_repo=>ty_order_confirmations
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_conf_selection
      IMPORTING
        is_selection TYPE
          zif_prod_order_read_repo=>ty_confirmation_window_selection
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_conf_window_results
      IMPORTING
        is_selection     TYPE
          zif_prod_order_read_repo=>ty_confirmation_window_selection
        it_confirmations TYPE
          zif_prod_order_read_repo=>ty_order_confirmations
      RAISING
        zcx_invalid_stock_request.

    METHODS build_conf_summaries
      IMPORTING
        it_confirmations    TYPE
          zif_prod_order_read_repo=>ty_order_confirmations
      RETURNING
        VALUE(rt_summaries) TYPE ty_confirmation_operation_summaries.

    METHODS convert_conf_qty_to_base
      IMPORTING
        iv_quantity        TYPE decfloat34
        iv_numerator       TYPE marm-umrez
        iv_denominator     TYPE marm-umren
      RETURNING
        VALUE(rv_quantity) TYPE mard-labst
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_operation_results
      IMPORTING
        it_production_orders TYPE
          zif_prod_order_read_repo=>ty_order_numbers
        it_operations        TYPE
          zif_prod_order_read_repo=>ty_order_operations
      RAISING
        zcx_invalid_stock_request.

    DATA mo_repository TYPE REF TO zif_prod_order_read_repo.
    DATA mo_uom_converter TYPE REF TO zif_material_uom_converter.
ENDCLASS.

CLASS zcl_prod_order_read_service IMPLEMENTATION.

  METHOD constructor.
    mo_repository = io_repository.
    IF io_uom_converter IS BOUND.
      mo_uom_converter = io_uom_converter.
    ELSE.
      mo_uom_converter = NEW zcl_material_uom_converter(
        io_repository = NEW zcl_material_uom_repository( ) ).
    ENDIF.
  ENDMETHOD.

  METHOD validate_order_read_results.
    TYPES:
      BEGIN OF ty_order_item_key,
        production_order TYPE
          zif_prod_order_read_repo=>ty_order_number,
        production_item  TYPE
          zif_prod_order_read_repo=>ty_order_item-production_item,
      END OF ty_order_item_key,
      ty_order_item_keys TYPE HASHED TABLE OF ty_order_item_key
        WITH UNIQUE KEY production_order production_item,
      BEGIN OF ty_order_status_key,
        production_order TYPE
          zif_prod_order_read_repo=>ty_order_number,
        status_code      TYPE
          zif_prod_order_read_repo=>ty_order_status-status_code,
      END OF ty_order_status_key,
      ty_order_status_keys TYPE HASHED TABLE OF ty_order_status_key
        WITH UNIQUE KEY production_order status_code.
    DATA lt_requested_orders TYPE HASHED TABLE OF
      zif_prod_order_read_repo=>ty_order_number
      WITH UNIQUE KEY table_line.
    DATA lt_order_item_keys TYPE ty_order_item_keys.
    DATA lt_order_status_keys TYPE ty_order_status_keys.

    LOOP AT it_production_orders INTO DATA(lv_requested_order).
      INSERT lv_requested_order INTO TABLE lt_requested_orders.
    ENDLOOP.

    LOOP AT it_order_items INTO DATA(ls_order_item).
      READ TABLE lt_requested_orders
        WITH TABLE KEY table_line = ls_order_item-production_order
        TRANSPORTING NO FIELDS.
      IF ls_order_item-production_order IS INITIAL
          OR ls_order_item-production_item IS INITIAL
          OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #(
        production_order = ls_order_item-production_order
        production_item  = ls_order_item-production_item )
        INTO TABLE lt_order_item_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_order_statuses INTO DATA(ls_order_status).
      READ TABLE lt_requested_orders
        WITH TABLE KEY table_line = ls_order_status-production_order
        TRANSPORTING NO FIELDS.
      IF ls_order_status-production_order IS INITIAL
          OR ls_order_status-status_code IS INITIAL
          OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #(
        production_order = ls_order_status-production_order
        status_code      = ls_order_status-status_code )
        INTO TABLE lt_order_status_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_order_numbers.
    TYPES ty_seen_order TYPE zif_prod_order_read_repo=>ty_order_number.
    DATA lt_seen_orders TYPE HASHED TABLE OF ty_seen_order
      WITH UNIQUE KEY table_line.

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      INSERT lv_production_order INTO TABLE lt_seen_orders.
      IF lv_production_order IS INITIAL OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_finish_window_keys.
    TYPES ty_seen_order TYPE zif_prod_order_read_repo=>ty_order_number.
    DATA lt_seen_orders TYPE HASHED TABLE OF ty_seen_order
      WITH UNIQUE KEY table_line.
    DATA lv_has_previous_key TYPE abap_bool.
    DATA ls_previous_key TYPE zif_prod_order_read_repo=>ty_finish_search_key.

    IF lines( it_order_keys ) > is_selection-maximum_results + 1.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_order_keys INTO DATA(ls_order_key).
      IF ls_order_key-production_order IS INITIAL
          OR zcl_date_validation=>is_valid_gregorian_date(
            iv_date = ls_order_key-basic_finish_date ) <> abap_true
          OR ls_order_key-basic_finish_date <
            is_selection-finish_date_from
          OR ls_order_key-basic_finish_date >
            is_selection-finish_date_to
          OR ( ( is_selection-filter_basic_start_date = abap_true
                OR is_selection-basic_start_date IS NOT INITIAL )
            AND ls_order_key-basic_start_date <>
              is_selection-basic_start_date )
          OR ( is_selection-scheduled_start_date_from IS NOT INITIAL
            AND ( zcl_date_validation=>is_valid_gregorian_date(
              iv_date = ls_order_key-scheduled_start_date ) <> abap_true
              OR ls_order_key-scheduled_start_date <
                is_selection-scheduled_start_date_from
              OR ls_order_key-scheduled_start_date >
                is_selection-scheduled_start_date_to ) )
          OR ( is_selection-scheduled_finish_date_from IS NOT INITIAL
            AND ( zcl_date_validation=>is_valid_gregorian_date(
              iv_date = ls_order_key-scheduled_finish_date ) <> abap_true
              OR ls_order_key-scheduled_finish_date <
                is_selection-scheduled_finish_date_from
              OR ls_order_key-scheduled_finish_date >
                is_selection-scheduled_finish_date_to ) )
          OR ( ( is_selection-filter_scheduled_start_date = abap_true
                OR is_selection-scheduled_start_date IS NOT INITIAL )
            AND ls_order_key-scheduled_start_date <>
              is_selection-scheduled_start_date )
          OR ( ( is_selection-filter_scheduled_finish_date = abap_true
                OR is_selection-scheduled_finish_date IS NOT INITIAL )
            AND ls_order_key-scheduled_finish_date <>
              is_selection-scheduled_finish_date )
          OR ( is_selection-filter_scheduled_start_time = abap_true
            AND ( zcl_date_validation=>is_valid_time(
              iv_time = ls_order_key-scheduled_start_time ) <> abap_true
              OR ls_order_key-scheduled_start_time <
                is_selection-scheduled_start_time_from
              OR ls_order_key-scheduled_start_time >
                is_selection-scheduled_start_time_to ) )
          OR ( is_selection-filter_scheduled_finish_time = abap_true
            AND ( zcl_date_validation=>is_valid_time(
              iv_time = ls_order_key-scheduled_finish_time ) <> abap_true
              OR ls_order_key-scheduled_finish_time <
                is_selection-scheduled_finish_time_from
              OR ls_order_key-scheduled_finish_time >
                is_selection-scheduled_finish_time_to ) )
          OR ( is_selection-basic_start_date_from IS NOT INITIAL
            AND ( zcl_date_validation=>is_valid_gregorian_date(
              iv_date = ls_order_key-basic_start_date ) <> abap_true
              OR ls_order_key-basic_start_date <
                is_selection-basic_start_date_from
              OR ls_order_key-basic_start_date >
                is_selection-basic_start_date_to ) )
          OR ( is_selection-after_finish_date IS NOT INITIAL
            AND ( ls_order_key-basic_finish_date <
              is_selection-after_finish_date
              OR ( ls_order_key-basic_finish_date =
                is_selection-after_finish_date
                AND ls_order_key-production_order <=
                  is_selection-after_order ) ) ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      INSERT ls_order_key-production_order INTO TABLE lt_seen_orders.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      IF lv_has_previous_key = abap_true
          AND ( ls_order_key-basic_finish_date <
            ls_previous_key-basic_finish_date
            OR ( ls_order_key-basic_finish_date =
              ls_previous_key-basic_finish_date
              AND ls_order_key-production_order <=
                ls_previous_key-production_order ) ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      ls_previous_key = ls_order_key.
      lv_has_previous_key = abap_true.
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
        OR ( is_selection-filter_sales_order <> abap_true
          AND is_selection-filter_sales_order <> abap_false )
        OR ( is_selection-filter_sales_order_item <> abap_true
          AND is_selection-filter_sales_order_item <> abap_false )
        OR ( is_selection-filter_sales_schedule_line <> abap_true
          AND is_selection-filter_sales_schedule_line <> abap_false )
        OR ( is_selection-filter_planned_order <> abap_true
          AND is_selection-filter_planned_order <> abap_false )
        OR ( is_selection-filter_planning_plant <> abap_true
          AND is_selection-filter_planning_plant <> abap_false )
        OR ( is_selection-filter_delivery_plant <> abap_true
          AND is_selection-filter_delivery_plant <> abap_false )
        OR ( is_selection-filter_special_stock <> abap_true
          AND is_selection-filter_special_stock <> abap_false )
        OR ( is_selection-filter_stock_type <> abap_true
          AND is_selection-filter_stock_type <> abap_false )
        OR ( is_selection-filter_goods_recipient <> abap_true
          AND is_selection-filter_goods_recipient <> abap_false )
        OR ( is_selection-filter_unloading_point <> abap_true
          AND is_selection-filter_unloading_point <> abap_false )
        OR ( is_selection-filter_production_version <> abap_true
          AND is_selection-filter_production_version <> abap_false )
        OR ( is_selection-filter_plan_start_date <> abap_true
          AND is_selection-filter_plan_start_date <> abap_false )
        OR ( is_selection-filter_storage_location <> abap_true
          AND is_selection-filter_storage_location <> abap_false )
        OR ( is_selection-filter_batch <> abap_true
          AND is_selection-filter_batch <> abap_false )
        OR ( is_selection-filter_assignment_category <> abap_true
          AND is_selection-filter_assignment_category <> abap_false )
        OR ( is_selection-filter_mrp_area <> abap_true
          AND is_selection-filter_mrp_area <> abap_false )
        OR ( is_selection-filter_wbs_element <> abap_true
          AND is_selection-filter_wbs_element <> abap_false )
        OR ( is_selection-filter_order_description <> abap_true
          AND is_selection-filter_order_description <> abap_false )
        OR ( is_selection-filter_order_created_by <> abap_true
          AND is_selection-filter_order_created_by <> abap_false )
        OR ( is_selection-filter_order_changed_by <> abap_true
          AND is_selection-filter_order_changed_by <> abap_false )
        OR ( is_selection-basic_start_date_from IS INITIAL
          AND is_selection-basic_start_date_to IS NOT INITIAL )
        OR ( is_selection-basic_start_date_from IS NOT INITIAL
          AND is_selection-basic_start_date_to IS INITIAL )
        OR ( is_selection-basic_start_date_from IS NOT INITIAL
          AND ( zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-basic_start_date_from ) <> abap_true
            OR zcl_date_validation=>is_valid_gregorian_date(
              iv_date = is_selection-basic_start_date_to ) <> abap_true
            OR is_selection-basic_start_date_from >
              is_selection-basic_start_date_to ) )
        OR ( is_selection-filter_basic_start_date <> abap_true
          AND is_selection-filter_basic_start_date <> abap_false )
        OR ( is_selection-basic_start_date IS NOT INITIAL
          AND zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-basic_start_date ) <> abap_true )
        OR ( is_selection-planned_order_start_date IS NOT INITIAL
          AND zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-planned_order_start_date ) <> abap_true )
        OR ( is_selection-scheduled_finish_date_from IS INITIAL
          AND is_selection-scheduled_finish_date_to IS NOT INITIAL )
        OR ( is_selection-scheduled_finish_date_from IS NOT INITIAL
          AND is_selection-scheduled_finish_date_to IS INITIAL )
        OR ( is_selection-scheduled_finish_date_from IS NOT INITIAL
          AND ( zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-scheduled_finish_date_from ) <> abap_true
            OR zcl_date_validation=>is_valid_gregorian_date(
              iv_date = is_selection-scheduled_finish_date_to ) <> abap_true
            OR is_selection-scheduled_finish_date_from >
              is_selection-scheduled_finish_date_to ) )
        OR ( is_selection-scheduled_start_date_from IS INITIAL
          AND is_selection-scheduled_start_date_to IS NOT INITIAL )
        OR ( is_selection-scheduled_start_date_from IS NOT INITIAL
          AND is_selection-scheduled_start_date_to IS INITIAL )
        OR ( is_selection-scheduled_start_date_from IS NOT INITIAL
          AND ( zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-scheduled_start_date_from ) <> abap_true
            OR zcl_date_validation=>is_valid_gregorian_date(
              iv_date = is_selection-scheduled_start_date_to ) <> abap_true
            OR is_selection-scheduled_start_date_from >
              is_selection-scheduled_start_date_to ) )
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
        OR ( is_selection-filter_scheduled_start_time <> abap_true
          AND is_selection-filter_scheduled_start_time <> abap_false )
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
        OR ( is_selection-filter_scheduled_finish_time <> abap_true
          AND is_selection-filter_scheduled_finish_time <> abap_false )
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
        OR ( is_selection-order_category IS NOT INITIAL
          AND is_selection-order_category <> '10'
          AND is_selection-order_category <> '40' )
        OR ( is_selection-created_date_from IS INITIAL
          AND is_selection-created_date_to IS NOT INITIAL )
        OR ( is_selection-created_date_from IS NOT INITIAL
          AND is_selection-created_date_to IS INITIAL )
        OR ( is_selection-created_date_from IS NOT INITIAL
          AND ( zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-created_date_from ) <> abap_true
            OR zcl_date_validation=>is_valid_gregorian_date(
              iv_date = is_selection-created_date_to ) <> abap_true
            OR is_selection-created_date_from >
              is_selection-created_date_to ) )
        OR ( is_selection-changed_date_from IS INITIAL
          AND is_selection-changed_date_to IS NOT INITIAL )
        OR ( is_selection-changed_date_from IS NOT INITIAL
          AND is_selection-changed_date_to IS INITIAL )
        OR ( is_selection-changed_date_from IS NOT INITIAL
          AND ( zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-changed_date_from ) <> abap_true
            OR zcl_date_validation=>is_valid_gregorian_date(
              iv_date = is_selection-changed_date_to ) <> abap_true
            OR is_selection-changed_date_from >
              is_selection-changed_date_to ) )
        OR ( is_selection-required_phase IS NOT INITIAL
          AND is_selection-required_phase <> '1'
          AND is_selection-required_phase <> '2'
          AND is_selection-required_phase <> '3' )
        OR ( is_selection-exclude_deleted <> abap_true
          AND is_selection-exclude_deleted <> abap_false )
        OR ( is_selection-receipt_expected_only <> abap_true
          AND is_selection-receipt_expected_only <> abap_false )
        OR ( is_selection-receipt_not_expected_only <> abap_true
          AND is_selection-receipt_not_expected_only <> abap_false )
        OR ( is_selection-delivery_complete_only <> abap_true
          AND is_selection-delivery_complete_only <> abap_false )
        OR ( is_selection-delivery_not_complete_only <> abap_true
          AND is_selection-delivery_not_complete_only <> abap_false )
        OR ( is_selection-receipt_expected_only = abap_true
          AND is_selection-receipt_not_expected_only = abap_true )
        OR ( is_selection-delivery_complete_only = abap_true
          AND is_selection-delivery_not_complete_only = abap_true )
        OR ( is_selection-unreceived_quantity_only <> abap_true
          AND is_selection-unreceived_quantity_only <> abap_false )
        OR ( is_selection-filter_order_qty_from <> abap_true
          AND is_selection-filter_order_qty_from <> abap_false )
        OR ( is_selection-filter_order_qty_from = abap_false
          AND is_selection-order_qty_from IS NOT INITIAL )
        OR ( is_selection-filter_order_qty_from = abap_true
          AND is_selection-order_qty_from <= 0 )
        OR ( is_selection-filter_order_qty_to <> abap_true
          AND is_selection-filter_order_qty_to <> abap_false )
        OR ( is_selection-filter_order_qty_to = abap_false
          AND is_selection-order_qty_to IS NOT INITIAL )
        OR ( is_selection-filter_order_qty_to = abap_true
          AND is_selection-order_qty_to <= 0 )
        OR ( is_selection-filter_order_qty_from = abap_true
          AND is_selection-filter_order_qty_to = abap_true
          AND is_selection-order_qty_from >
            is_selection-order_qty_to )
        OR ( is_selection-filter_unreceived_qty_from <> abap_true
          AND is_selection-filter_unreceived_qty_from <> abap_false )
        OR ( is_selection-filter_unreceived_qty_from = abap_false
          AND is_selection-unreceived_qty_from IS NOT INITIAL )
        OR ( is_selection-filter_unreceived_qty_from = abap_true
          AND is_selection-unreceived_qty_from <= 0 )
        OR ( is_selection-filter_unreceived_qty_to <> abap_true
          AND is_selection-filter_unreceived_qty_to <> abap_false )
        OR ( is_selection-filter_unreceived_qty_to = abap_false
          AND is_selection-unreceived_qty_to IS NOT INITIAL )
        OR ( is_selection-filter_unreceived_qty_to = abap_true
          AND is_selection-unreceived_qty_to <= 0 )
        OR ( is_selection-filter_unreceived_qty_from = abap_true
          AND is_selection-filter_unreceived_qty_to = abap_true
          AND is_selection-unreceived_qty_from >
            is_selection-unreceived_qty_to )
        OR ( is_selection-after_finish_date IS INITIAL
          AND is_selection-after_order IS NOT INITIAL )
        OR ( is_selection-after_finish_date IS NOT INITIAL
          AND is_selection-after_order IS INITIAL )
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

  METHOD validate_confirmation_results.
    TYPES:
      BEGIN OF ty_confirmation_key,
        confirmation         TYPE
          zif_prod_order_read_repo=>ty_order_confirmation-confirmation,
        confirmation_counter TYPE
          zif_prod_order_read_repo=>ty_order_confirmation-confirmation_counter,
      END OF ty_confirmation_key.
    TYPES ty_confirmation_keys TYPE HASHED TABLE OF ty_confirmation_key
      WITH UNIQUE KEY confirmation confirmation_counter.
    DATA lt_requested_orders TYPE HASHED TABLE OF
      zif_prod_order_read_repo=>ty_order_number WITH UNIQUE KEY table_line.
    DATA lt_confirmation_keys TYPE ty_confirmation_keys.

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      INSERT lv_production_order INTO TABLE lt_requested_orders.
    ENDLOOP.

    LOOP AT it_confirmations INTO DATA(ls_confirmation).
      READ TABLE lt_requested_orders
        WITH TABLE KEY table_line = ls_confirmation-production_order
        TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0
          OR ls_confirmation-confirmation IS INITIAL
          OR ls_confirmation-confirmation_counter IS INITIAL
          OR ls_confirmation-production_order IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      INSERT VALUE #(
        confirmation         = ls_confirmation-confirmation
        confirmation_counter = ls_confirmation-confirmation_counter )
        INTO TABLE lt_confirmation_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_conf_selection.
    IF is_selection-material IS INITIAL
        OR is_selection-plant IS INITIAL
        OR zcl_date_validation=>is_valid_gregorian_date(
          iv_date = is_selection-posting_date_from ) <> abap_true
        OR zcl_date_validation=>is_valid_gregorian_date(
          iv_date = is_selection-posting_date_to ) <> abap_true
        OR is_selection-posting_date_from > is_selection-posting_date_to
        OR ( is_selection-entry_date_from IS INITIAL
          AND is_selection-entry_date_to IS NOT INITIAL )
        OR ( is_selection-entry_date_from IS NOT INITIAL
          AND is_selection-entry_date_to IS INITIAL )
        OR ( is_selection-entry_date_from IS NOT INITIAL
          AND ( zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-entry_date_from ) <> abap_true
            OR zcl_date_validation=>is_valid_gregorian_date(
              iv_date = is_selection-entry_date_to ) <> abap_true
            OR is_selection-entry_date_from > is_selection-entry_date_to ) )
        OR ( is_selection-last_change_date_from IS INITIAL
          AND is_selection-last_change_date_to IS NOT INITIAL )
        OR ( is_selection-last_change_date_from IS NOT INITIAL
          AND is_selection-last_change_date_to IS INITIAL )
        OR ( is_selection-last_change_date_from IS NOT INITIAL
          AND ( zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-last_change_date_from ) <> abap_true
            OR zcl_date_validation=>is_valid_gregorian_date(
              iv_date = is_selection-last_change_date_to ) <> abap_true
            OR is_selection-last_change_date_from >
              is_selection-last_change_date_to ) )
        OR is_selection-maximum_results < 1
        OR is_selection-maximum_results > 500
        OR ( is_selection-filter_quantity_unit <> abap_true
          AND is_selection-filter_quantity_unit <> abap_false )
        OR ( is_selection-filter_entered_by <> abap_true
          AND is_selection-filter_entered_by <> abap_false )
        OR ( is_selection-filter_changed_by <> abap_true
          AND is_selection-filter_changed_by <> abap_false )
        OR ( is_selection-filter_entry_time <> abap_true
          AND is_selection-filter_entry_time <> abap_false )
        OR ( is_selection-filter_entry_time = abap_false
          AND ( is_selection-entry_time_from IS NOT INITIAL
            OR is_selection-entry_time_to IS NOT INITIAL ) )
        OR ( is_selection-filter_entry_time = abap_true
          AND ( zcl_date_validation=>is_valid_time(
            iv_time = is_selection-entry_time_from ) <> abap_true
            OR zcl_date_validation=>is_valid_time(
              iv_time = is_selection-entry_time_to ) <> abap_true
            OR is_selection-entry_time_from > is_selection-entry_time_to ) )
        OR ( is_selection-filter_control_key <> abap_true
          AND is_selection-filter_control_key <> abap_false )
        OR ( is_selection-filter_operation_sequence <> abap_true
          AND is_selection-filter_operation_sequence <> abap_false )
        OR ( is_selection-filter_operation_suboperation <> abap_true
          AND is_selection-filter_operation_suboperation <> abap_false )
        OR ( is_selection-operation_number IS INITIAL
          AND ( is_selection-operation_suboperation IS NOT INITIAL
            OR is_selection-filter_operation_suboperation = abap_true ) )
        OR ( is_selection-confirmation_number IS INITIAL
          AND is_selection-confirmation_counter IS NOT INITIAL )
        OR ( is_selection-order_category IS NOT INITIAL
          AND is_selection-order_category <> '10'
          AND is_selection-order_category <> '40' )
        OR ( is_selection-operation_counter IS NOT INITIAL
          AND is_selection-production_order IS INITIAL )
        OR ( is_selection-exclude_reversed <> abap_true
          AND is_selection-exclude_reversed <> abap_false )
        OR ( is_selection-reversed_only <> abap_true
          AND is_selection-reversed_only <> abap_false )
        OR ( is_selection-positive_yield_only <> abap_true
          AND is_selection-positive_yield_only <> abap_false )
        OR ( is_selection-positive_rework_only <> abap_true
          AND is_selection-positive_rework_only <> abap_false )
        OR ( is_selection-positive_scrap_only <> abap_true
          AND is_selection-positive_scrap_only <> abap_false )
        OR ( is_selection-exclude_reversed = abap_true
          AND is_selection-reversed_only = abap_true )
        OR ( is_selection-final_only <> abap_true
          AND is_selection-final_only <> abap_false )
        OR ( is_selection-partial_only <> abap_true
          AND is_selection-partial_only <> abap_false )
        OR ( is_selection-final_only = abap_true
          AND is_selection-partial_only = abap_true )
        OR ( is_selection-after_posting_date IS INITIAL
          AND ( is_selection-after_production_order IS NOT INITIAL
            OR is_selection-after_confirmation IS NOT INITIAL
            OR is_selection-after_confirmation_counter IS NOT INITIAL ) )
        OR ( is_selection-after_posting_date IS NOT INITIAL
          AND ( is_selection-after_production_order IS INITIAL
            OR is_selection-after_confirmation IS INITIAL
            OR is_selection-after_confirmation_counter IS INITIAL ) )
        OR ( is_selection-after_posting_date IS NOT INITIAL
          AND ( zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-after_posting_date ) <> abap_true
            OR is_selection-after_posting_date <
              is_selection-posting_date_from
            OR is_selection-after_posting_date >
              is_selection-posting_date_to ) ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
  ENDMETHOD.

  METHOD validate_conf_window_results.
    TYPES:
      BEGIN OF ty_confirmation_sort_key,
        posting_date         TYPE afru-budat,
        production_order     TYPE
          zif_prod_order_read_repo=>ty_order_number,
        confirmation         TYPE afru-rueck,
        confirmation_counter TYPE afru-rmzhl,
      END OF ty_confirmation_sort_key.
    DATA ls_previous_key TYPE ty_confirmation_sort_key.
    DATA lv_has_previous TYPE abap_bool.

    IF lines( it_confirmations ) > is_selection-maximum_results + 1.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_confirmations INTO DATA(ls_confirmation).
      IF zcl_date_validation=>is_valid_gregorian_date(
          iv_date = ls_confirmation-posting_date ) <> abap_true
          OR ( ls_confirmation-entry_date IS NOT INITIAL
            AND zcl_date_validation=>is_valid_gregorian_date(
              iv_date = ls_confirmation-entry_date ) <> abap_true )
          OR ( ls_confirmation-last_change_date IS NOT INITIAL
            AND zcl_date_validation=>is_valid_gregorian_date(
              iv_date = ls_confirmation-last_change_date ) <> abap_true )
          OR zcl_date_validation=>is_valid_time(
            iv_time = ls_confirmation-entry_time ) <> abap_true
          OR ls_confirmation-scope_material <> is_selection-material
          OR ls_confirmation-scope_plant <> is_selection-plant
          OR ls_confirmation-posting_date <
            is_selection-posting_date_from
          OR ls_confirmation-posting_date >
            is_selection-posting_date_to
          OR ( is_selection-entry_date_from IS NOT INITIAL
            AND ( ls_confirmation-entry_date < is_selection-entry_date_from
              OR ls_confirmation-entry_date > is_selection-entry_date_to ) )
          OR ( is_selection-last_change_date_from IS NOT INITIAL
            AND ( ls_confirmation-last_change_date <
              is_selection-last_change_date_from
              OR ls_confirmation-last_change_date >
                is_selection-last_change_date_to ) )
          OR ( is_selection-filter_entry_time = abap_true
            AND ( ls_confirmation-entry_time < is_selection-entry_time_from
              OR ls_confirmation-entry_time > is_selection-entry_time_to ) )
          OR ( is_selection-production_order IS NOT INITIAL
            AND ls_confirmation-production_order <>
              is_selection-production_order )
          OR ( is_selection-order_category IS NOT INITIAL
            AND ls_confirmation-order_category <>
              is_selection-order_category )
          OR ( is_selection-operation_counter IS NOT INITIAL
            AND ls_confirmation-operation_counter <>
              is_selection-operation_counter )
          OR ( is_selection-operation_number IS NOT INITIAL
            AND ls_confirmation-operation_number <>
              is_selection-operation_number )
          OR ( ( is_selection-filter_operation_suboperation = abap_true
              OR is_selection-operation_suboperation IS NOT INITIAL )
            AND ls_confirmation-operation_suboperation <>
              is_selection-operation_suboperation )
          OR ( ( is_selection-filter_operation_sequence = abap_true
              OR is_selection-operation_sequence IS NOT INITIAL )
            AND ls_confirmation-operation_sequence <>
              is_selection-operation_sequence )
          OR ( ( is_selection-filter_control_key = abap_true
              OR is_selection-control_key IS NOT INITIAL )
            AND ls_confirmation-control_key <>
              is_selection-control_key )
          OR ( ( is_selection-filter_quantity_unit = abap_true
              OR is_selection-quantity_unit IS NOT INITIAL )
            AND ls_confirmation-quantity_unit <>
              is_selection-quantity_unit )
          OR ( ( is_selection-filter_entered_by = abap_true
              OR is_selection-entered_by IS NOT INITIAL )
            AND ls_confirmation-entered_by <> is_selection-entered_by )
          OR ( ( is_selection-filter_changed_by = abap_true
              OR is_selection-changed_by IS NOT INITIAL )
            AND ls_confirmation-changed_by <> is_selection-changed_by )
          OR ( is_selection-confirmation_number IS NOT INITIAL
            AND ls_confirmation-confirmation <>
              is_selection-confirmation_number )
          OR ( is_selection-confirmation_counter IS NOT INITIAL
            AND ls_confirmation-confirmation_counter <>
              is_selection-confirmation_counter )
          OR ( is_selection-exclude_reversed = abap_true
            AND ls_confirmation-is_reversed = abap_true )
          OR ( is_selection-reversed_only = abap_true
            AND ls_confirmation-is_reversed <> abap_true )
          OR ( is_selection-positive_yield_only = abap_true
            AND ls_confirmation-yield_quantity <= 0 )
          OR ( is_selection-positive_rework_only = abap_true
            AND ls_confirmation-rework_quantity <= 0 )
          OR ( is_selection-positive_scrap_only = abap_true
            AND ls_confirmation-scrap_quantity <= 0 )
          OR ( is_selection-final_only = abap_true
            AND ls_confirmation-is_final <> abap_true )
          OR ( is_selection-partial_only = abap_true
            AND ls_confirmation-is_final <> abap_false )
          OR ( is_selection-after_posting_date IS NOT INITIAL
            AND ( ls_confirmation-posting_date <
              is_selection-after_posting_date
              OR ( ls_confirmation-posting_date =
                is_selection-after_posting_date
                AND ls_confirmation-production_order <
                  is_selection-after_production_order )
              OR ( ls_confirmation-posting_date =
                is_selection-after_posting_date
                AND ls_confirmation-production_order =
                  is_selection-after_production_order
                AND ls_confirmation-confirmation <
                  is_selection-after_confirmation )
              OR ( ls_confirmation-posting_date =
                is_selection-after_posting_date
                AND ls_confirmation-production_order =
                  is_selection-after_production_order
                AND ls_confirmation-confirmation =
                  is_selection-after_confirmation
                AND ls_confirmation-confirmation_counter <=
                  is_selection-after_confirmation_counter ) ) )
          OR ( lv_has_previous = abap_true
            AND ( ls_confirmation-posting_date <
              ls_previous_key-posting_date
              OR ( ls_confirmation-posting_date =
                ls_previous_key-posting_date
                AND ls_confirmation-production_order <
                  ls_previous_key-production_order )
              OR ( ls_confirmation-posting_date =
                ls_previous_key-posting_date
                AND ls_confirmation-production_order =
                  ls_previous_key-production_order
                AND ls_confirmation-confirmation <
                  ls_previous_key-confirmation )
              OR ( ls_confirmation-posting_date =
                ls_previous_key-posting_date
                AND ls_confirmation-production_order =
                  ls_previous_key-production_order
                AND ls_confirmation-confirmation =
                  ls_previous_key-confirmation
                AND ls_confirmation-confirmation_counter <=
                  ls_previous_key-confirmation_counter ) ) ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      ls_previous_key = VALUE #(
        posting_date         = ls_confirmation-posting_date
        production_order     = ls_confirmation-production_order
        confirmation         = ls_confirmation-confirmation
        confirmation_counter = ls_confirmation-confirmation_counter ).
      lv_has_previous = abap_true.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_conf_summaries.
    FIELD-SYMBOLS <ls_summary> TYPE ty_confirmation_operation_summary.

    LOOP AT it_confirmations INTO DATA(ls_confirmation).
      READ TABLE rt_summaries ASSIGNING <ls_summary>
        WITH TABLE KEY
          production_order       = ls_confirmation-production_order
          operation_counter      = ls_confirmation-operation_counter
          operation_number       = ls_confirmation-operation_number
          operation_sequence     = ls_confirmation-operation_sequence
          operation_suboperation =
            ls_confirmation-operation_suboperation
          quantity_unit = ls_confirmation-quantity_unit.
      IF sy-subrc <> 0.
        INSERT VALUE #(
          production_order       = ls_confirmation-production_order
          order_category         = ls_confirmation-order_category
          operation_counter      = ls_confirmation-operation_counter
          operation_number       = ls_confirmation-operation_number
          operation_sequence     = ls_confirmation-operation_sequence
          operation_suboperation =
            ls_confirmation-operation_suboperation
          operation_description  =
            ls_confirmation-operation_description
          control_key            = ls_confirmation-control_key
          first_posting_date     = ls_confirmation-posting_date
          last_posting_date      = ls_confirmation-posting_date
          quantity_unit          = ls_confirmation-quantity_unit )
          INTO TABLE rt_summaries.
        READ TABLE rt_summaries ASSIGNING <ls_summary>
          WITH TABLE KEY
            production_order     = ls_confirmation-production_order
            operation_counter    = ls_confirmation-operation_counter
            operation_number     = ls_confirmation-operation_number
            operation_sequence   = ls_confirmation-operation_sequence
            operation_suboperation =
              ls_confirmation-operation_suboperation
            quantity_unit = ls_confirmation-quantity_unit.
      ENDIF.

      IF ls_confirmation-posting_date <
          <ls_summary>-first_posting_date.
        <ls_summary>-first_posting_date = ls_confirmation-posting_date.
      ENDIF.
      IF ls_confirmation-posting_date >
          <ls_summary>-last_posting_date.
        <ls_summary>-last_posting_date = ls_confirmation-posting_date.
      ENDIF.
      ADD 1 TO <ls_summary>-confirmation_count.
      IF ls_confirmation-is_final = abap_true.
        ADD 1 TO <ls_summary>-final_confirmation_count.
      ENDIF.
      IF ls_confirmation-is_reversed = abap_true.
        ADD 1 TO <ls_summary>-reversed_confirmation_count.
      ENDIF.
      <ls_summary>-yield_quantity_total =
        <ls_summary>-yield_quantity_total +
        CONV decfloat34( ls_confirmation-yield_quantity ).
      <ls_summary>-rework_quantity_total =
        <ls_summary>-rework_quantity_total +
        CONV decfloat34( ls_confirmation-rework_quantity ).
      <ls_summary>-scrap_quantity_total =
        <ls_summary>-scrap_quantity_total +
        CONV decfloat34( ls_confirmation-scrap_quantity ).
      IF ls_confirmation-is_reversed <> abap_true.
        <ls_summary>-yield_non_reversed_total =
          <ls_summary>-yield_non_reversed_total +
          CONV decfloat34( ls_confirmation-yield_quantity ).
        <ls_summary>-rework_non_reversed_total =
          <ls_summary>-rework_non_reversed_total +
          CONV decfloat34( ls_confirmation-rework_quantity ).
        <ls_summary>-scrap_non_reversed_total =
          <ls_summary>-scrap_non_reversed_total +
          CONV decfloat34( ls_confirmation-scrap_quantity ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD read_orders_bulk.
    DATA(lo_quantity_calculator) = NEW zcl_prod_order_qty_calc( ).
    DATA lv_snapshot_timestamp TYPE timestampl.
    rs_result-is_successful = abap_true.

    IF it_production_orders IS INITIAL.
      RETURN.
    ENDIF.

    validate_order_numbers( it_production_orders = it_production_orders ).
    DATA(lt_order_items) = mo_repository->read_orders(
      it_production_orders = it_production_orders ).
    DATA(lt_order_statuses) = mo_repository->read_order_statuses(
      it_production_orders = it_production_orders ).
    GET TIME STAMP FIELD lv_snapshot_timestamp.
    rs_result-snapshot_timestamp = lv_snapshot_timestamp.
    validate_order_read_results(
      it_production_orders = it_production_orders
      it_order_items       = lt_order_items
      it_order_statuses    = lt_order_statuses ).

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index    = lv_request_index
        production_order = lv_production_order ) TO rs_result-orders.
      ASSIGN rs_result-orders[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_order_result>).

      LOOP AT lt_order_items INTO DATA(ls_order_item)
          WHERE production_order = lv_production_order.
        DATA(ls_item_result) = VALUE ty_item_result(
          order_item = ls_order_item ).
        APPEND ls_item_result TO <ls_order_result>-items.
        ASSIGN <ls_order_result>-items[ lines(
          <ls_order_result>-items ) ] TO FIELD-SYMBOL(<ls_item_result>).

        IF <ls_order_result>-is_found <> abap_true.
          <ls_order_result>-is_found = abap_true.
          ADD 1 TO rs_result-found_count.
        ENDIF.

        IF ls_order_item-order_unit IS INITIAL
            OR ls_order_item-base_unit IS INITIAL
            OR ls_order_item-order_quantity < 0
            OR ls_order_item-received_quantity < 0
            OR ls_order_item-order_to_base_numerator <= 0
            OR ls_order_item-order_to_base_denominator <= 0.
          rs_result-is_successful = abap_false.
          ADD 1 TO rs_result-conversion_failed_count.
          CONTINUE.
        ENDIF.

        <ls_item_result>-order_quantity_base =
          lo_quantity_calculator->calculate_base_quantity(
            iv_quantity            = ls_order_item-order_quantity
            iv_order_to_base_num   =
              ls_order_item-order_to_base_numerator
            iv_order_to_base_denom =
              ls_order_item-order_to_base_denominator ).
        <ls_item_result>-received_quantity_base =
          lo_quantity_calculator->calculate_base_quantity(
            iv_quantity            = ls_order_item-received_quantity
            iv_order_to_base_num   =
              ls_order_item-order_to_base_numerator
            iv_order_to_base_denom =
              ls_order_item-order_to_base_denominator ).
        <ls_item_result>-open_quantity_base =
          lo_quantity_calculator->calculate_open_base_quantity(
            iv_order_quantity      = ls_order_item-order_quantity
            iv_received_quantity   = ls_order_item-received_quantity
            iv_order_to_base_num   =
              ls_order_item-order_to_base_numerator
            iv_order_to_base_denom =
              ls_order_item-order_to_base_denominator ).
        <ls_item_result>-is_quantity_converted = abap_true.
      ENDLOOP.

      LOOP AT lt_order_statuses INTO DATA(ls_order_status)
          WHERE production_order = lv_production_order.
        APPEND VALUE #(
          status_code       = ls_order_status-status_code
          is_user_status    = ls_order_status-is_user_status
          status_short_name = ls_order_status-status_short_name
          status_name       = ls_order_status-status_name )
          TO <ls_order_result>-statuses.
      ENDLOOP.

      IF <ls_order_result>-is_found <> abap_true.
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-not_found_count.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD read_orders_by_finish_window.
    DATA lt_order_keys TYPE
      zif_prod_order_read_repo=>ty_finish_search_keys.
    DATA lt_production_orders TYPE
      zif_prod_order_read_repo=>ty_order_numbers.
    DATA lv_is_truncated TYPE abap_bool.
    DATA lv_last_index TYPE i.
    DATA lv_key_selection_timestamp TYPE timestampl.
    DATA ls_last_key TYPE zif_prod_order_read_repo=>ty_finish_search_key.
    DATA lv_finish_filter_matches TYPE abap_bool.

    validate_order_selection( is_selection = is_selection ).
    lt_order_keys = mo_repository->read_orders_by_finish_window(
      is_selection = is_selection ).
    GET TIME STAMP FIELD lv_key_selection_timestamp.
    validate_finish_window_keys(
      is_selection  = is_selection
      it_order_keys = lt_order_keys ).

    IF lines( lt_order_keys ) > is_selection-maximum_results.
      lv_is_truncated = abap_true.
      DELETE lt_order_keys INDEX is_selection-maximum_results + 1.
    ENDIF.

    LOOP AT lt_order_keys INTO DATA(ls_order_key).
      APPEND ls_order_key-production_order TO lt_production_orders.
    ENDLOOP.

    rs_result = read_orders_bulk(
      it_production_orders = lt_production_orders ).
    LOOP AT rs_result-orders ASSIGNING FIELD-SYMBOL(<ls_finish_order>).
      CLEAR lv_finish_filter_matches.
      LOOP AT <ls_finish_order>-items INTO DATA(ls_finish_item).
        IF ls_finish_item-order_item-material = is_selection-material
            AND ls_finish_item-order_item-plant = is_selection-plant
            AND ( ( is_selection-filter_planning_plant = abap_false
                  AND is_selection-planning_plant IS INITIAL )
              OR ls_finish_item-order_item-planning_plant =
                is_selection-planning_plant )
            AND ( ( is_selection-filter_delivery_plant = abap_false
                  AND is_selection-delivery_plant IS INITIAL )
              OR ls_finish_item-order_item-delivery_plant =
                is_selection-delivery_plant )
            AND ( ( is_selection-filter_special_stock = abap_false
                  AND is_selection-special_stock_indicator IS INITIAL )
              OR ls_finish_item-order_item-special_stock_indicator =
                is_selection-special_stock_indicator )
            AND ( ( is_selection-filter_stock_type = abap_false
                  AND is_selection-stock_type IS INITIAL )
              OR ls_finish_item-order_item-stock_type =
                is_selection-stock_type )
            AND ( ( is_selection-filter_goods_recipient = abap_false
                  AND is_selection-goods_recipient IS INITIAL )
              OR ls_finish_item-order_item-goods_recipient =
                is_selection-goods_recipient )
            AND ( ( is_selection-filter_unloading_point = abap_false
                  AND is_selection-unloading_point IS INITIAL )
              OR ls_finish_item-order_item-unloading_point =
                is_selection-unloading_point )
            AND ( ( is_selection-filter_production_version = abap_false
                  AND is_selection-production_version IS INITIAL )
              OR ls_finish_item-order_item-production_version =
                is_selection-production_version )
            AND ( ( is_selection-filter_plan_start_date = abap_false
                  AND is_selection-planned_order_start_date IS INITIAL )
              OR ls_finish_item-order_item-planned_order_start_date =
                is_selection-planned_order_start_date )
            AND ( ( is_selection-filter_sales_order = abap_false
                  AND is_selection-sales_order IS INITIAL )
              OR ls_finish_item-order_item-sales_order =
                is_selection-sales_order )
            AND ( ( is_selection-filter_sales_order_item = abap_false
                  AND is_selection-sales_order_item IS INITIAL )
              OR ls_finish_item-order_item-sales_order_item =
                is_selection-sales_order_item )
            AND ( ( is_selection-filter_sales_schedule_line = abap_false
                  AND is_selection-sales_order_schedule_line IS INITIAL )
              OR ls_finish_item-order_item-sales_order_schedule_line =
                is_selection-sales_order_schedule_line )
            AND ( ( is_selection-filter_planned_order = abap_false
                  AND is_selection-planned_order IS INITIAL )
              OR ls_finish_item-order_item-planned_order =
                is_selection-planned_order )
            AND ( ( is_selection-filter_storage_location = abap_false
                  AND is_selection-storage_location IS INITIAL )
              OR ls_finish_item-order_item-storage_location =
                is_selection-storage_location )
            AND ( ( is_selection-filter_batch = abap_false
                  AND is_selection-batch IS INITIAL )
              OR ls_finish_item-order_item-batch = is_selection-batch )
            AND ( ( is_selection-filter_assignment_category = abap_false
                  AND is_selection-account_assignment_category IS INITIAL )
              OR ls_finish_item-order_item-account_assignment_category =
                is_selection-account_assignment_category )
            AND ( ( is_selection-filter_mrp_area = abap_false
                  AND is_selection-mrp_area IS INITIAL )
              OR ls_finish_item-order_item-mrp_area = is_selection-mrp_area )
            AND ( ( is_selection-filter_wbs_element = abap_false
                  AND is_selection-wbs_element IS INITIAL )
              OR ( is_selection-wbs_element IS INITIAL
                AND ls_finish_item-order_item-wbs_element_internal_id IS INITIAL )
              OR ls_finish_item-order_item-wbs_element =
                is_selection-wbs_element )
            AND ( is_selection-production_item IS INITIAL
              OR ls_finish_item-order_item-production_item =
                is_selection-production_item )
            AND ( is_selection-order_unit IS INITIAL
              OR ls_finish_item-order_item-order_unit =
                is_selection-order_unit )
            AND ( ls_finish_item-order_item-order_category = '10'
              OR ls_finish_item-order_item-order_category = '40' )
            AND ( is_selection-order_category IS INITIAL
              OR ls_finish_item-order_item-order_category =
                is_selection-order_category )
            AND ( is_selection-order_type IS INITIAL
              OR ls_finish_item-order_item-order_type =
                is_selection-order_type )
            AND ( ( is_selection-filter_order_description = abap_false
                  AND is_selection-order_description IS INITIAL )
              OR ls_finish_item-order_item-order_description =
                is_selection-order_description )
            AND ( ( is_selection-filter_order_created_by = abap_false
                  AND is_selection-order_created_by IS INITIAL )
              OR ls_finish_item-order_item-order_created_by =
                is_selection-order_created_by )
            AND ( ( is_selection-filter_order_changed_by = abap_false
                  AND is_selection-order_changed_by IS INITIAL )
              OR ls_finish_item-order_item-order_changed_by =
                is_selection-order_changed_by )
            AND ( is_selection-required_phase IS INITIAL
              OR ( is_selection-required_phase = '1'
                AND ls_finish_item-order_item-phase_1_indicator = abap_true )
              OR ( is_selection-required_phase = '2'
                AND ls_finish_item-order_item-phase_2_indicator = abap_true )
              OR ( is_selection-required_phase = '3'
                AND ls_finish_item-order_item-phase_3_indicator = abap_true ) )
            AND ( is_selection-created_date_from IS INITIAL
              OR ( zcl_date_validation=>is_valid_gregorian_date(
                    iv_date = ls_finish_item-order_item-created_date )
                  = abap_true
                AND ls_finish_item-order_item-created_date >=
                  is_selection-created_date_from
                AND ls_finish_item-order_item-created_date <=
                  is_selection-created_date_to ) )
            AND ( is_selection-changed_date_from IS INITIAL
              OR ( zcl_date_validation=>is_valid_gregorian_date(
                    iv_date = ls_finish_item-order_item-changed_date )
                  = abap_true
                AND ls_finish_item-order_item-changed_date >=
                  is_selection-changed_date_from
                AND ls_finish_item-order_item-changed_date <=
                  is_selection-changed_date_to ) )
            AND ( is_selection-exclude_deleted = abap_false
              OR ( ls_finish_item-order_item-order_deletion_indicator
                    IS INITIAL
                AND ls_finish_item-order_item-item_deletion_indicator
                    IS INITIAL ) )
            AND ( is_selection-receipt_expected_only = abap_false
              OR ls_finish_item-order_item-receipt_expected = abap_true )
            AND ( is_selection-receipt_not_expected_only = abap_false
              OR ls_finish_item-order_item-receipt_expected IS INITIAL )
            AND ( is_selection-delivery_complete_only = abap_false
              OR ls_finish_item-order_item-delivery_complete = abap_true )
            AND ( is_selection-delivery_not_complete_only = abap_false
              OR ls_finish_item-order_item-delivery_complete IS INITIAL )
            AND ( is_selection-unreceived_quantity_only = abap_false
              OR ls_finish_item-order_item-order_quantity >
                ls_finish_item-order_item-received_quantity )
            AND ( is_selection-filter_order_qty_from = abap_false
              OR ls_finish_item-order_item-order_quantity >=
                is_selection-order_qty_from )
            AND ( is_selection-filter_order_qty_to = abap_false
              OR ls_finish_item-order_item-order_quantity <=
                is_selection-order_qty_to )
            AND ( is_selection-filter_unreceived_qty_from =
                abap_false
              OR ( ls_finish_item-order_item-order_quantity >
                  ls_finish_item-order_item-received_quantity
                AND ls_finish_item-order_item-order_quantity
                    - ls_finish_item-order_item-received_quantity >=
                  is_selection-unreceived_qty_from ) )
            AND ( is_selection-filter_unreceived_qty_to =
                abap_false
              OR ( ls_finish_item-order_item-order_quantity >
                  ls_finish_item-order_item-received_quantity
                AND ls_finish_item-order_item-order_quantity
                    - ls_finish_item-order_item-received_quantity <=
                  is_selection-unreceived_qty_to ) )
            AND zcl_date_validation=>is_valid_gregorian_date(
              iv_date = ls_finish_item-order_item-basic_finish_date )
              = abap_true
            AND ls_finish_item-order_item-basic_finish_date >=
              is_selection-finish_date_from
            AND ls_finish_item-order_item-basic_finish_date <=
              is_selection-finish_date_to
            AND ( is_selection-basic_start_date_from IS INITIAL
              OR ( zcl_date_validation=>is_valid_gregorian_date(
                    iv_date =
                      ls_finish_item-order_item-basic_start_date )
                  = abap_true
                AND ls_finish_item-order_item-basic_start_date >=
                  is_selection-basic_start_date_from
                AND ls_finish_item-order_item-basic_start_date <=
                  is_selection-basic_start_date_to ) )
            AND ( ( is_selection-filter_basic_start_date = abap_false
                  AND is_selection-basic_start_date IS INITIAL )
              OR ls_finish_item-order_item-basic_start_date =
                is_selection-basic_start_date )
            AND ( is_selection-scheduled_finish_date_from IS INITIAL
              OR ( zcl_date_validation=>is_valid_gregorian_date(
                    iv_date =
                      ls_finish_item-order_item-scheduled_finish_date )
                  = abap_true
                AND ls_finish_item-order_item-scheduled_finish_date >=
                  is_selection-scheduled_finish_date_from
                AND ls_finish_item-order_item-scheduled_finish_date <=
                  is_selection-scheduled_finish_date_to ) )
            AND ( is_selection-scheduled_start_date_from IS INITIAL
              OR ( zcl_date_validation=>is_valid_gregorian_date(
                    iv_date =
                      ls_finish_item-order_item-scheduled_start_date )
                  = abap_true
                AND ls_finish_item-order_item-scheduled_start_date >=
                  is_selection-scheduled_start_date_from
                AND ls_finish_item-order_item-scheduled_start_date <=
                  is_selection-scheduled_start_date_to ) )
            AND ( ( is_selection-filter_scheduled_start_date = abap_false
                  AND is_selection-scheduled_start_date IS INITIAL )
              OR ls_finish_item-order_item-scheduled_start_date =
                is_selection-scheduled_start_date )
            AND ( ( is_selection-filter_scheduled_finish_date = abap_false
                  AND is_selection-scheduled_finish_date IS INITIAL )
              OR ls_finish_item-order_item-scheduled_finish_date =
                is_selection-scheduled_finish_date )
            AND ( is_selection-filter_scheduled_start_time = abap_false
              OR ( zcl_date_validation=>is_valid_time(
                    iv_time =
                      ls_finish_item-order_item-scheduled_start_time )
                  = abap_true
                AND ls_finish_item-order_item-scheduled_start_time >=
                  is_selection-scheduled_start_time_from
                AND ls_finish_item-order_item-scheduled_start_time <=
                  is_selection-scheduled_start_time_to ) )
            AND ( is_selection-filter_scheduled_finish_time = abap_false
              OR ( zcl_date_validation=>is_valid_time(
                    iv_time =
                      ls_finish_item-order_item-scheduled_finish_time )
                  = abap_true
                AND ls_finish_item-order_item-scheduled_finish_time >=
                  is_selection-scheduled_finish_time_from
                AND ls_finish_item-order_item-scheduled_finish_time <=
                  is_selection-scheduled_finish_time_to ) ).
          lv_finish_filter_matches = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.
      IF lv_finish_filter_matches <> abap_true.
        <ls_finish_order>-finish_filter_lost = abap_true.
        ADD 1 TO rs_result-finish_filter_lost_count.
      ENDIF.
    ENDLOOP.
    IF is_selection-active_status_code IS NOT INITIAL.
      LOOP AT rs_result-orders ASSIGNING FIELD-SYMBOL(<ls_order_result>).
        READ TABLE <ls_order_result>-statuses
          WITH KEY status_code = is_selection-active_status_code
          TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
          <ls_order_result>-status_filter_lost = abap_true.
          ADD 1 TO rs_result-status_filter_lost_count.
        ENDIF.
      ENDLOOP.
    ENDIF.
    rs_result-is_truncated = lv_is_truncated.
    rs_result-key_selection_timestamp = lv_key_selection_timestamp.
    IF lv_is_truncated = abap_true.
      lv_last_index = lines( lt_order_keys ).
      READ TABLE lt_order_keys INTO ls_last_key INDEX lv_last_index.
      IF sy-subrc = 0.
        rs_result-next_finish_date = ls_last_key-basic_finish_date.
        rs_result-next_production_order = ls_last_key-production_order.
      ENDIF.
    ENDIF.
    GET TIME STAMP FIELD rs_result-snapshot_timestamp.
  ENDMETHOD.

  METHOD read_confirmations_bulk.
    DATA lv_snapshot_timestamp TYPE timestampl.
    rs_result-is_successful = abap_true.
    IF it_production_orders IS INITIAL.
      RETURN.
    ENDIF.

    validate_order_numbers(
      it_production_orders = it_production_orders ).
    DATA(lt_confirmations) = mo_repository->read_confirmations(
      it_production_orders = it_production_orders ).
    GET TIME STAMP FIELD lv_snapshot_timestamp.
    validate_confirmation_results(
      it_production_orders = it_production_orders
      it_confirmations     = lt_confirmations ).

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index    = lv_request_index
        production_order = lv_production_order ) TO rs_result-orders.
      ASSIGN rs_result-orders[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_confirmation_order>).

      LOOP AT lt_confirmations INTO DATA(ls_confirmation)
          WHERE production_order = lv_production_order.
        APPEND ls_confirmation TO <ls_confirmation_order>-confirmations.
      ENDLOOP.

      IF <ls_confirmation_order>-confirmations IS INITIAL.
        ADD 1 TO rs_result-empty_count.
      ELSE.
        <ls_confirmation_order>-is_found = abap_true.
        ADD 1 TO rs_result-found_count.
      ENDIF.
    ENDLOOP.
    rs_result-snapshot_timestamp = lv_snapshot_timestamp.
  ENDMETHOD.

  METHOD search_confirmations_by_window.
    TYPES ty_seen_order TYPE zif_prod_order_read_repo=>ty_order_number.
    DATA lt_confirmations TYPE
      zif_prod_order_read_repo=>ty_order_confirmations.
    DATA lt_production_orders TYPE
      zif_prod_order_read_repo=>ty_order_numbers.
    DATA lt_seen_orders TYPE HASHED TABLE OF ty_seen_order
      WITH UNIQUE KEY table_line.
    DATA lv_is_truncated TYPE abap_bool.
    DATA lv_snapshot_timestamp TYPE timestampl.
    DATA lv_last_index TYPE i.
    DATA ls_last_confirmation TYPE
      zif_prod_order_read_repo=>ty_order_confirmation.

    validate_conf_selection( is_selection = is_selection ).
    lt_confirmations = mo_repository->search_confirmations_by_window(
      is_selection = is_selection ).
    GET TIME STAMP FIELD lv_snapshot_timestamp.

    LOOP AT lt_confirmations INTO DATA(ls_confirmation).
      INSERT ls_confirmation-production_order INTO TABLE lt_seen_orders.
      IF sy-subrc = 0.
        APPEND ls_confirmation-production_order TO lt_production_orders.
      ENDIF.
    ENDLOOP.
    IF lt_confirmations IS NOT INITIAL.
      validate_confirmation_results(
        it_production_orders = lt_production_orders
        it_confirmations     = lt_confirmations ).
    ENDIF.
    validate_conf_window_results(
      is_selection     = is_selection
      it_confirmations = lt_confirmations ).

    IF lines( lt_confirmations ) > is_selection-maximum_results.
      lv_is_truncated = abap_true.
      WHILE lines( lt_confirmations ) > is_selection-maximum_results.
        DELETE lt_confirmations INDEX is_selection-maximum_results + 1.
      ENDWHILE.
    ENDIF.

    rs_result-confirmations = lt_confirmations.
    rs_result-operation_summaries = build_conf_summaries(
      it_confirmations = lt_confirmations ).
    rs_result-returned_count = lines( lt_confirmations ).
    rs_result-is_truncated = lv_is_truncated.
    rs_result-snapshot_timestamp = lv_snapshot_timestamp.
    rs_result-is_successful = abap_true.
    IF lv_is_truncated = abap_true.
      lv_last_index = lines( lt_confirmations ).
      READ TABLE lt_confirmations INTO ls_last_confirmation
        INDEX lv_last_index.
      IF sy-subrc = 0.
        rs_result-next_posting_date =
          ls_last_confirmation-posting_date.
        rs_result-next_production_order =
          ls_last_confirmation-production_order.
        rs_result-next_confirmation = ls_last_confirmation-confirmation.
        rs_result-next_confirmation_counter =
          ls_last_confirmation-confirmation_counter.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD search_conf_window_base_unit.
    TYPES:
      BEGIN OF ty_cached_unit_ratio,
        quantity_unit TYPE afru-meinh,
        ratio         TYPE zif_material_uom_converter=>ty_unit_ratio,
      END OF ty_cached_unit_ratio,
      ty_cached_unit_ratios TYPE HASHED TABLE OF ty_cached_unit_ratio
        WITH UNIQUE KEY quantity_unit.
    DATA lt_cached_unit_ratios TYPE ty_cached_unit_ratios.
    FIELD-SYMBOLS <ls_base_summary> TYPE ty_base_conf_summary.

    rs_result-raw_result = search_confirmations_by_window(
      is_selection = is_selection ).

    LOOP AT rs_result-raw_result-confirmations
        INTO DATA(ls_confirmation).
      DATA ls_cached_unit_ratio TYPE ty_cached_unit_ratio.
      CLEAR ls_cached_unit_ratio.
      READ TABLE lt_cached_unit_ratios INTO ls_cached_unit_ratio
        WITH TABLE KEY quantity_unit = ls_confirmation-quantity_unit.
      IF sy-subrc <> 0.
        ls_cached_unit_ratio-quantity_unit =
          ls_confirmation-quantity_unit.
        ls_cached_unit_ratio-ratio =
          mo_uom_converter->get_material_unit_ratio(
            iv_material         = is_selection-material
            iv_alternative_unit = ls_confirmation-quantity_unit ).
        IF ls_cached_unit_ratio-ratio-is_successful <> abap_true
            OR ls_cached_unit_ratio-ratio-base_unit IS INITIAL
            OR ls_cached_unit_ratio-ratio-numerator <= 0
            OR ls_cached_unit_ratio-ratio-denominator <= 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        INSERT ls_cached_unit_ratio INTO TABLE lt_cached_unit_ratios.
      ENDIF.

      DATA(ls_base_quantity) = VALUE ty_base_conf_quantity(
        confirmation_row     = ls_confirmation
        base_quantity_unit   = ls_cached_unit_ratio-ratio-base_unit
        yield_quantity_base  = convert_conf_qty_to_base(
          iv_quantity    = CONV decfloat34( ls_confirmation-yield_quantity )
          iv_numerator   = ls_cached_unit_ratio-ratio-numerator
          iv_denominator = ls_cached_unit_ratio-ratio-denominator )
        rework_quantity_base = convert_conf_qty_to_base(
          iv_quantity    = CONV decfloat34( ls_confirmation-rework_quantity )
          iv_numerator   = ls_cached_unit_ratio-ratio-numerator
          iv_denominator = ls_cached_unit_ratio-ratio-denominator )
        scrap_quantity_base  = convert_conf_qty_to_base(
          iv_quantity    = CONV decfloat34( ls_confirmation-scrap_quantity )
          iv_numerator   = ls_cached_unit_ratio-ratio-numerator
          iv_denominator = ls_cached_unit_ratio-ratio-denominator ) ).
      APPEND ls_base_quantity TO rs_result-base_quantities.

      READ TABLE rs_result-base_operation_summaries
        ASSIGNING <ls_base_summary>
        WITH TABLE KEY
          production_order       = ls_confirmation-production_order
          operation_counter      = ls_confirmation-operation_counter
          operation_number       = ls_confirmation-operation_number
          operation_sequence     = ls_confirmation-operation_sequence
          operation_suboperation =
            ls_confirmation-operation_suboperation
          base_quantity_unit     = ls_cached_unit_ratio-ratio-base_unit.
      IF sy-subrc <> 0.
        INSERT VALUE #(
          production_order       = ls_confirmation-production_order
          order_category         = ls_confirmation-order_category
          operation_counter      = ls_confirmation-operation_counter
          operation_number       = ls_confirmation-operation_number
          operation_sequence     = ls_confirmation-operation_sequence
          operation_suboperation =
            ls_confirmation-operation_suboperation
          operation_description  = ls_confirmation-operation_description
          control_key            = ls_confirmation-control_key
          base_quantity_unit     = ls_cached_unit_ratio-ratio-base_unit
          first_posting_date     = ls_confirmation-posting_date
          last_posting_date      = ls_confirmation-posting_date )
          INTO TABLE rs_result-base_operation_summaries.
        READ TABLE rs_result-base_operation_summaries
          ASSIGNING <ls_base_summary>
          WITH TABLE KEY
            production_order = ls_confirmation-production_order
            operation_counter = ls_confirmation-operation_counter
            operation_number = ls_confirmation-operation_number
            operation_sequence = ls_confirmation-operation_sequence
            operation_suboperation =
              ls_confirmation-operation_suboperation
            base_quantity_unit = ls_cached_unit_ratio-ratio-base_unit.
      ENDIF.

      IF ls_confirmation-posting_date <
          <ls_base_summary>-first_posting_date.
        <ls_base_summary>-first_posting_date =
          ls_confirmation-posting_date.
      ENDIF.
      IF ls_confirmation-posting_date >
          <ls_base_summary>-last_posting_date.
        <ls_base_summary>-last_posting_date =
          ls_confirmation-posting_date.
      ENDIF.
      ADD 1 TO <ls_base_summary>-confirmation_count.
      IF ls_confirmation-is_final = abap_true.
        ADD 1 TO <ls_base_summary>-final_confirmation_count.
      ENDIF.
      IF ls_confirmation-is_reversed = abap_true.
        ADD 1 TO <ls_base_summary>-reversed_confirmation_count.
      ENDIF.
      <ls_base_summary>-yield_quantity_base_total =
        <ls_base_summary>-yield_quantity_base_total +
        CONV decfloat34( ls_base_quantity-yield_quantity_base ).
      <ls_base_summary>-rework_quantity_base_total =
        <ls_base_summary>-rework_quantity_base_total +
        CONV decfloat34( ls_base_quantity-rework_quantity_base ).
      <ls_base_summary>-scrap_quantity_base_total =
        <ls_base_summary>-scrap_quantity_base_total +
        CONV decfloat34( ls_base_quantity-scrap_quantity_base ).
      IF ls_confirmation-is_reversed <> abap_true.
        <ls_base_summary>-yield_base_non_reversed_total =
          <ls_base_summary>-yield_base_non_reversed_total +
          CONV decfloat34( ls_base_quantity-yield_quantity_base ).
        <ls_base_summary>-rework_base_non_reversed_total =
          <ls_base_summary>-rework_base_non_reversed_total +
          CONV decfloat34( ls_base_quantity-rework_quantity_base ).
        <ls_base_summary>-scrap_base_non_reversed_total =
          <ls_base_summary>-scrap_base_non_reversed_total +
          CONV decfloat34( ls_base_quantity-scrap_quantity_base ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD convert_conf_qty_to_base.
    TRY.
        rv_quantity = CONV mard-labst(
          iv_quantity
          * CONV decfloat34( iv_numerator )
          / CONV decfloat34( iv_denominator ) ).
      CATCH cx_sy_conversion_overflow.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDTRY.

    IF iv_quantity <> 0 AND rv_quantity IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
  ENDMETHOD.

  METHOD validate_operation_results.
    TYPES:
      BEGIN OF ty_operation_key,
        production_order  TYPE
          zif_prod_order_read_repo=>ty_order_operation-production_order,
        operation_counter TYPE
          zif_prod_order_read_repo=>ty_order_operation-operation_counter,
      END OF ty_operation_key.
    TYPES ty_operation_keys TYPE HASHED TABLE OF ty_operation_key
      WITH UNIQUE KEY production_order operation_counter.
    DATA lt_requested_orders TYPE HASHED TABLE OF
      zif_prod_order_read_repo=>ty_order_number WITH UNIQUE KEY table_line.
    DATA lt_operation_keys TYPE ty_operation_keys.

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      INSERT lv_production_order INTO TABLE lt_requested_orders.
    ENDLOOP.

    LOOP AT it_operations INTO DATA(ls_operation).
      READ TABLE lt_requested_orders
        WITH TABLE KEY table_line = ls_operation-production_order
        TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0
          OR ls_operation-production_order IS INITIAL
          OR ls_operation-operation_counter IS INITIAL
          OR ls_operation-operation_number IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      INSERT VALUE #(
        production_order  = ls_operation-production_order
        operation_counter = ls_operation-operation_counter )
        INTO TABLE lt_operation_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD read_operations_bulk.
    DATA lv_snapshot_timestamp TYPE timestampl.
    rs_result-is_successful = abap_true.
    IF it_production_orders IS INITIAL.
      RETURN.
    ENDIF.

    validate_order_numbers(
      it_production_orders = it_production_orders ).
    DATA(lt_operations) = mo_repository->read_operations(
      it_production_orders = it_production_orders ).
    GET TIME STAMP FIELD lv_snapshot_timestamp.
    validate_operation_results(
      it_production_orders = it_production_orders
      it_operations        = lt_operations ).

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index    = lv_request_index
        production_order = lv_production_order ) TO rs_result-orders.
      ASSIGN rs_result-orders[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_operation_order>).

      LOOP AT lt_operations INTO DATA(ls_operation)
          WHERE production_order = lv_production_order.
        APPEND ls_operation TO <ls_operation_order>-operations.
      ENDLOOP.

      IF <ls_operation_order>-operations IS INITIAL.
        ADD 1 TO rs_result-empty_count.
      ELSE.
        <ls_operation_order>-is_found = abap_true.
        ADD 1 TO rs_result-found_count.
      ENDIF.
    ENDLOOP.
    rs_result-snapshot_timestamp = lv_snapshot_timestamp.
  ENDMETHOD.

ENDCLASS.
