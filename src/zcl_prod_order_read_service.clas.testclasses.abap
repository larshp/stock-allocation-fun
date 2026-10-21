CLASS lcl_prod_order_read_repo DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_prod_order_read_repo.
    DATA order_items TYPE zif_prod_order_read_repo=>ty_order_items.
    DATA use_unfiltered_order_items TYPE abap_bool.
    DATA order_statuses TYPE zif_prod_order_read_repo=>ty_order_statuses.
    DATA finish_candidate_statuses TYPE
      zif_prod_order_read_repo=>ty_order_statuses.
    DATA order_confirmations TYPE
      zif_prod_order_read_repo=>ty_order_confirmations.
    DATA order_operations TYPE zif_prod_order_read_repo=>ty_order_operations.
    DATA requested_orders TYPE zif_prod_order_read_repo=>ty_order_numbers.
    DATA requested_status_orders TYPE
      zif_prod_order_read_repo=>ty_order_numbers.
    DATA read_calls TYPE i.
    DATA status_read_calls TYPE i.
    DATA confirmation_read_calls TYPE i.
    DATA operation_read_calls TYPE i.
    DATA requested_op_resource_filter TYPE abap_bool.
    DATA requested_op_resource_id TYPE afvc-arbid.
    DATA use_operation_override TYPE abap_bool.
    DATA operation_override TYPE
      zif_prod_order_read_repo=>ty_order_operations.
    DATA use_confirmation_override TYPE abap_bool.
    DATA confirmation_override TYPE
      zif_prod_order_read_repo=>ty_order_confirmations.
    DATA requested_confirmation_orders TYPE
      zif_prod_order_read_repo=>ty_order_numbers.
    DATA requested_operation_orders TYPE
      zif_prod_order_read_repo=>ty_order_numbers.
    DATA requested_selection TYPE
      zif_prod_order_read_repo=>ty_order_selection.
    DATA finish_window_read_calls TYPE i.
    DATA use_finish_window_override TYPE abap_bool.
    DATA finish_window_override TYPE
      zif_prod_order_read_repo=>ty_finish_search_keys.
    DATA requested_conf_selection TYPE
      zif_prod_order_read_repo=>ty_confirmation_window_selection.
    DATA confirmation_window_read_calls TYPE i.
    DATA use_conf_window_override TYPE abap_bool.
    DATA conf_window_override TYPE
      zif_prod_order_read_repo=>ty_order_confirmations.
ENDCLASS.

CLASS lcl_prod_order_uom_repo DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_material_uom_repository.
    DATA base_unit TYPE mara-meins.
    DATA alternative_unit TYPE marm-meinh.
    DATA numerator TYPE marm-umrez.
    DATA denominator TYPE marm-umren.
    DATA ratio_read_calls TYPE i.
ENDCLASS.

CLASS lcl_prod_order_uom_repo IMPLEMENTATION.
  METHOD zif_material_uom_repository~get_base_unit.
    rv_base_unit = base_unit.
  ENDMETHOD.

  METHOD zif_material_uom_repository~get_alt_unit_ratio.
    ADD 1 TO ratio_read_calls.
    IF iv_alternative_unit = alternative_unit.
      rs_ratio-numerator = numerator.
      rs_ratio-denominator = denominator.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_prod_order_read_repo IMPLEMENTATION.
  METHOD zif_prod_order_read_repo~read_orders.
    ADD 1 TO read_calls.
    requested_orders = it_production_orders.
    IF use_unfiltered_order_items = abap_true.
      rt_order_items = order_items.
      RETURN.
    ENDIF.
    CLEAR rt_order_items.
    LOOP AT order_items INTO DATA(ls_order_item).
      READ TABLE it_production_orders
        WITH KEY table_line = ls_order_item-production_order
        TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        APPEND ls_order_item TO rt_order_items.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD zif_prod_order_read_repo~read_orders_by_finish_window.
    DATA lt_candidate_keys TYPE
      zif_prod_order_read_repo=>ty_finish_search_keys.
    DATA lt_candidate_statuses TYPE
      zif_prod_order_read_repo=>ty_order_statuses.
    DATA lv_candidate_progress_status TYPE c LENGTH 1.
    DATA lv_order_quantity_base TYPE decfloat34.
    DATA lv_received_quantity_base TYPE decfloat34.
    DATA lv_open_quantity_base TYPE decfloat34.
    DATA lv_over_receipt_quantity_base TYPE decfloat34.
    DATA lv_quantity_converted TYPE abap_bool.

    ADD 1 TO finish_window_read_calls.
    requested_selection = is_selection.
    IF use_finish_window_override = abap_true.
      rt_order_keys = finish_window_override.
      RETURN.
    ENDIF.
    lt_candidate_statuses = order_statuses.
    IF finish_candidate_statuses IS NOT INITIAL.
      lt_candidate_statuses = finish_candidate_statuses.
    ENDIF.
    LOOP AT order_items INTO DATA(ls_order_item).
      CLEAR lv_candidate_progress_status.
      CLEAR: lv_order_quantity_base, lv_received_quantity_base,
        lv_open_quantity_base, lv_over_receipt_quantity_base,
        lv_quantity_converted.
      IF ls_order_item-order_unit IS NOT INITIAL
          AND ls_order_item-base_unit IS NOT INITIAL
          AND ls_order_item-order_quantity >= 0
          AND ls_order_item-received_quantity >= 0
          AND ls_order_item-order_to_base_numerator > 0
          AND ls_order_item-order_to_base_denominator > 0.
        lv_order_quantity_base =
          CONV decfloat34( ls_order_item-order_quantity )
          * CONV decfloat34( ls_order_item-order_to_base_numerator )
          / CONV decfloat34( ls_order_item-order_to_base_denominator ).
        lv_received_quantity_base =
          CONV decfloat34( ls_order_item-received_quantity )
          * CONV decfloat34( ls_order_item-order_to_base_numerator )
          / CONV decfloat34( ls_order_item-order_to_base_denominator ).
        IF ls_order_item-order_quantity > 0
            AND ls_order_item-received_quantity <
              ls_order_item-order_quantity.
          lv_open_quantity_base =
            CONV decfloat34(
              ls_order_item-order_quantity -
                ls_order_item-received_quantity )
            * CONV decfloat34( ls_order_item-order_to_base_numerator )
            / CONV decfloat34( ls_order_item-order_to_base_denominator ).
        ENDIF.
        IF ls_order_item-order_quantity > 0
            AND ls_order_item-received_quantity >
              ls_order_item-order_quantity.
          lv_over_receipt_quantity_base =
            CONV decfloat34( ls_order_item-received_quantity
              - ls_order_item-order_quantity )
            * CONV decfloat34( ls_order_item-order_to_base_numerator )
            / CONV decfloat34( ls_order_item-order_to_base_denominator ).
        ENDIF.
        lv_quantity_converted = abap_true.
      ENDIF.
      IF ls_order_item-order_quantity > 0
          AND ls_order_item-received_quantity >= 0.
        IF ls_order_item-received_quantity = 0.
          lv_candidate_progress_status =
            zcl_prod_order_read_service=>c_receipt_progress_not_started.
        ELSEIF ls_order_item-received_quantity <
            ls_order_item-order_quantity.
          lv_candidate_progress_status =
            zcl_prod_order_read_service=>c_receipt_progress_partial.
        ELSEIF ls_order_item-received_quantity =
            ls_order_item-order_quantity.
          lv_candidate_progress_status =
            zcl_prod_order_read_service=>c_receipt_progress_complete.
        ELSE.
          lv_candidate_progress_status =
            zcl_prod_order_read_service=>c_receipt_over_received.
        ENDIF.
      ENDIF.
      IF ls_order_item-material <> is_selection-material
          OR ls_order_item-plant <> is_selection-plant
          OR ( ( is_selection-filter_planning_plant = abap_true
                OR is_selection-planning_plant IS NOT INITIAL )
            AND ls_order_item-planning_plant <>
              is_selection-planning_plant )
          OR ( ( is_selection-filter_delivery_plant = abap_true
                OR is_selection-delivery_plant IS NOT INITIAL )
            AND ls_order_item-delivery_plant <>
              is_selection-delivery_plant )
          OR ( ( is_selection-filter_special_stock = abap_true
                OR is_selection-special_stock_indicator IS NOT INITIAL )
            AND ls_order_item-special_stock_indicator <>
              is_selection-special_stock_indicator )
          OR ( ( is_selection-filter_stock_type = abap_true
                OR is_selection-stock_type IS NOT INITIAL )
            AND ls_order_item-stock_type <>
              is_selection-stock_type )
          OR ( ( is_selection-filter_goods_recipient = abap_true
                OR is_selection-goods_recipient IS NOT INITIAL )
            AND ls_order_item-goods_recipient <>
              is_selection-goods_recipient )
          OR ( ( is_selection-filter_unloading_point = abap_true
                OR is_selection-unloading_point IS NOT INITIAL )
            AND ls_order_item-unloading_point <>
              is_selection-unloading_point )
          OR ( ( is_selection-filter_production_version = abap_true
                OR is_selection-production_version IS NOT INITIAL )
            AND ls_order_item-production_version <>
              is_selection-production_version )
          OR ( ( is_selection-filter_plan_start_date = abap_true
                OR is_selection-planned_order_start_date IS NOT INITIAL )
            AND ls_order_item-planned_order_start_date <>
              is_selection-planned_order_start_date )
          OR ( ( is_selection-filter_sales_order = abap_true
                OR is_selection-sales_order IS NOT INITIAL )
            AND ls_order_item-sales_order <> is_selection-sales_order )
          OR ( ( is_selection-filter_sales_order_item = abap_true
                OR is_selection-sales_order_item IS NOT INITIAL )
            AND ls_order_item-sales_order_item <>
              is_selection-sales_order_item )
          OR ( ( is_selection-filter_sales_schedule_line = abap_true
                OR is_selection-sales_order_schedule_line IS NOT INITIAL )
            AND ls_order_item-sales_order_schedule_line <>
              is_selection-sales_order_schedule_line )
          OR ( ( is_selection-filter_planned_order = abap_true
                OR is_selection-planned_order IS NOT INITIAL )
            AND ls_order_item-planned_order <> is_selection-planned_order )
          OR ( ( is_selection-filter_storage_location = abap_true
                OR is_selection-storage_location IS NOT INITIAL )
            AND ls_order_item-storage_location <>
              is_selection-storage_location )
          OR ( ( is_selection-filter_batch = abap_true
                OR is_selection-batch IS NOT INITIAL )
            AND ls_order_item-batch <> is_selection-batch )
          OR ( ( is_selection-filter_assignment_category = abap_true
                OR is_selection-account_assignment_category IS NOT INITIAL )
            AND ls_order_item-account_assignment_category <>
              is_selection-account_assignment_category )
          OR ( ( is_selection-filter_mrp_area = abap_true
                OR is_selection-mrp_area IS NOT INITIAL )
            AND ls_order_item-mrp_area <> is_selection-mrp_area )
          OR ( ( is_selection-filter_wbs_element = abap_true
                OR is_selection-wbs_element IS NOT INITIAL )
            AND ls_order_item-wbs_element <> is_selection-wbs_element )
          OR ( is_selection-filter_wbs_element = abap_true
            AND is_selection-wbs_element IS INITIAL
            AND ls_order_item-wbs_element_internal_id IS NOT INITIAL )
          OR ( is_selection-production_item IS NOT INITIAL
            AND ls_order_item-production_item <>
              is_selection-production_item )
          OR ( is_selection-order_unit IS NOT INITIAL
            AND ls_order_item-order_unit <> is_selection-order_unit )
          OR ( ls_order_item-order_category <> '10'
            AND ls_order_item-order_category <> '40' )
          OR ( is_selection-order_category IS NOT INITIAL
            AND ls_order_item-order_category <>
              is_selection-order_category )
          OR ( is_selection-order_type IS NOT INITIAL
            AND ls_order_item-order_type <> is_selection-order_type )
          OR ( ( is_selection-filter_order_description = abap_true
                OR is_selection-order_description IS NOT INITIAL )
            AND ls_order_item-order_description <>
              is_selection-order_description )
          OR ( ( is_selection-filter_order_created_by = abap_true
                OR is_selection-order_created_by IS NOT INITIAL )
            AND ls_order_item-order_created_by <>
              is_selection-order_created_by )
          OR ( ( is_selection-filter_order_changed_by = abap_true
                OR is_selection-order_changed_by IS NOT INITIAL )
            AND ls_order_item-order_changed_by <>
              is_selection-order_changed_by )
          OR ( is_selection-created_date_from IS NOT INITIAL
            AND ( ls_order_item-created_date <
                  is_selection-created_date_from
              OR ls_order_item-created_date >
                is_selection-created_date_to ) )
          OR ( is_selection-changed_date_from IS NOT INITIAL
            AND ( ls_order_item-changed_date <
                  is_selection-changed_date_from
              OR ls_order_item-changed_date >
                is_selection-changed_date_to ) )
          OR ( is_selection-required_phase = '1'
            AND ls_order_item-phase_1_indicator <> abap_true )
          OR ( is_selection-required_phase = '2'
            AND ls_order_item-phase_2_indicator <> abap_true )
          OR ( is_selection-required_phase = '3'
            AND ls_order_item-phase_3_indicator <> abap_true )
          OR ( is_selection-exclude_deleted = abap_true
            AND ( ls_order_item-order_deletion_indicator IS NOT INITIAL
              OR ls_order_item-item_deletion_indicator IS NOT INITIAL ) )
          OR ( is_selection-receipt_expected_only = abap_true
            AND ls_order_item-receipt_expected <> abap_true )
          OR ( is_selection-receipt_not_expected_only = abap_true
            AND ls_order_item-receipt_expected IS NOT INITIAL )
          OR ( is_selection-delivery_complete_only = abap_true
            AND ls_order_item-delivery_complete <> abap_true )
          OR ( is_selection-delivery_not_complete_only = abap_true
            AND ls_order_item-delivery_complete IS NOT INITIAL )
          OR ( is_selection-unreceived_quantity_only = abap_true
            AND ls_order_item-order_quantity <=
              ls_order_item-received_quantity )
          OR ( is_selection-filter_receipt_progress_status = abap_true
            AND lv_candidate_progress_status <>
              is_selection-receipt_progress_status )
          OR ( is_selection-filter_order_qty_from = abap_true
            AND ls_order_item-order_quantity <
              is_selection-order_qty_from )
          OR ( is_selection-filter_order_qty_to = abap_true
            AND ls_order_item-order_quantity >
              is_selection-order_qty_to )
          OR ( is_selection-filter_order_qty_base_from = abap_true
            AND ( lv_quantity_converted <> abap_true
              OR lv_order_quantity_base <
                is_selection-order_qty_base_from ) )
          OR ( is_selection-filter_order_qty_base_to = abap_true
            AND ( lv_quantity_converted <> abap_true
              OR lv_order_quantity_base >
                is_selection-order_qty_base_to ) )
          OR ( is_selection-filter_received_qty_from = abap_true
            AND ls_order_item-received_quantity <
              is_selection-received_qty_from )
          OR ( is_selection-filter_received_qty_to = abap_true
            AND ls_order_item-received_quantity >
              is_selection-received_qty_to )
          OR ( is_selection-filter_over_receipt_qty_from = abap_true
            AND ( ls_order_item-order_quantity <= 0
              OR ls_order_item-received_quantity < 0
              OR ( ls_order_item-received_quantity <=
                    ls_order_item-order_quantity
                AND is_selection-over_receipt_qty_from > 0 )
              OR ( ls_order_item-received_quantity >
                    ls_order_item-order_quantity
                AND ls_order_item-received_quantity
                    - ls_order_item-order_quantity <
                  is_selection-over_receipt_qty_from ) ) )
          OR ( is_selection-filter_over_receipt_qty_to = abap_true
            AND ( ls_order_item-order_quantity <= 0
              OR ls_order_item-received_quantity < 0
              OR ( ls_order_item-received_quantity >
                    ls_order_item-order_quantity
                AND ls_order_item-received_quantity
                    - ls_order_item-order_quantity >
                  is_selection-over_receipt_qty_to ) ) )
          OR ( is_selection-filter_over_receipt_pct_from = abap_true
            AND ( ls_order_item-order_quantity <= 0
              OR ls_order_item-received_quantity < 0
              OR ( is_selection-over_receipt_pct_from > 0
                AND ( ls_order_item-received_quantity <=
                      ls_order_item-order_quantity
                  OR ls_order_item-received_quantity * 100
                      - ls_order_item-order_quantity * 100 <
                    is_selection-over_receipt_pct_from
                      * ls_order_item-order_quantity ) ) ) )
          OR ( is_selection-filter_over_receipt_pct_to = abap_true
            AND ( ls_order_item-order_quantity <= 0
              OR ls_order_item-received_quantity < 0
              OR ( ls_order_item-received_quantity >
                    ls_order_item-order_quantity
                AND ls_order_item-received_quantity * 100
                    - ls_order_item-order_quantity * 100 >
                  is_selection-over_receipt_pct_to
                    * ls_order_item-order_quantity ) ) )
          OR ( is_selection-filter_received_qty_base_from = abap_true
            AND ( lv_quantity_converted <> abap_true
              OR lv_received_quantity_base <
                is_selection-received_qty_base_from ) )
          OR ( is_selection-filter_received_qty_base_to = abap_true
            AND ( lv_quantity_converted <> abap_true
              OR lv_received_quantity_base >
                is_selection-received_qty_base_to ) )
          OR ( is_selection-filter_over_rcpt_qty_base_from = abap_true
            AND ( lv_quantity_converted <> abap_true
              OR lv_candidate_progress_status IS INITIAL
              OR ( is_selection-over_rcpt_qty_base_from > 0
                AND ( ls_order_item-received_quantity <=
                      ls_order_item-order_quantity
                  OR lv_over_receipt_quantity_base <
                    is_selection-over_rcpt_qty_base_from ) ) ) )
          OR ( is_selection-filter_over_rcpt_qty_base_to = abap_true
            AND ( lv_quantity_converted <> abap_true
              OR lv_candidate_progress_status IS INITIAL
              OR ( ls_order_item-received_quantity >
                    ls_order_item-order_quantity
                AND lv_over_receipt_quantity_base >
                  is_selection-over_rcpt_qty_base_to ) ) )
          OR ( is_selection-filter_unrecv_qty_base_from = abap_true
            AND ( lv_quantity_converted <> abap_true
              OR lv_open_quantity_base <
                is_selection-unrecv_qty_base_from ) )
          OR ( is_selection-filter_unrecv_qty_base_to = abap_true
            AND ( lv_quantity_converted <> abap_true
              OR lv_open_quantity_base >
                is_selection-unrecv_qty_base_to ) )
          OR ( is_selection-filter_received_pct_from = abap_true
            AND ( ls_order_item-order_quantity <= 0
              OR ls_order_item-received_quantity < 0
              OR ls_order_item-received_quantity * 100 <
                is_selection-received_pct_from
                  * ls_order_item-order_quantity ) )
          OR ( is_selection-filter_received_pct_to = abap_true
            AND ( ls_order_item-order_quantity <= 0
              OR ls_order_item-received_quantity < 0
              OR ls_order_item-received_quantity * 100 >
                is_selection-received_pct_to
                  * ls_order_item-order_quantity ) )
          OR ( is_selection-filter_unreceived_qty_from = abap_true
            AND ( ls_order_item-order_quantity <=
                ls_order_item-received_quantity
              OR ls_order_item-order_quantity -
                ls_order_item-received_quantity <
                  is_selection-unreceived_qty_from ) )
          OR ( is_selection-filter_unreceived_qty_to = abap_true
            AND ( ls_order_item-order_quantity <=
                ls_order_item-received_quantity
              OR ls_order_item-order_quantity -
                ls_order_item-received_quantity >
                  is_selection-unreceived_qty_to ) )
          OR ls_order_item-basic_finish_date <
            is_selection-finish_date_from
          OR ls_order_item-basic_finish_date > is_selection-finish_date_to
          OR ( is_selection-basic_start_date_from IS NOT INITIAL
            AND ( ls_order_item-basic_start_date <
              is_selection-basic_start_date_from
              OR ls_order_item-basic_start_date >
                is_selection-basic_start_date_to ) )
          OR ( ( is_selection-filter_basic_start_date = abap_true
                OR is_selection-basic_start_date IS NOT INITIAL )
            AND ls_order_item-basic_start_date <>
              is_selection-basic_start_date )
          OR ( is_selection-scheduled_start_date_from IS NOT INITIAL
            AND ( ls_order_item-scheduled_start_date <
              is_selection-scheduled_start_date_from
              OR ls_order_item-scheduled_start_date >
                is_selection-scheduled_start_date_to ) )
          OR ( ( is_selection-filter_scheduled_start_date = abap_true
                OR is_selection-scheduled_start_date IS NOT INITIAL )
            AND ls_order_item-scheduled_start_date <>
              is_selection-scheduled_start_date )
          OR ( is_selection-filter_scheduled_start_time = abap_true
            AND ( ls_order_item-scheduled_start_time <
              is_selection-scheduled_start_time_from
              OR ls_order_item-scheduled_start_time >
                is_selection-scheduled_start_time_to ) )
          OR ( is_selection-scheduled_finish_date_from IS NOT INITIAL
            AND ( ls_order_item-scheduled_finish_date <
              is_selection-scheduled_finish_date_from
              OR ls_order_item-scheduled_finish_date >
                is_selection-scheduled_finish_date_to ) )
          OR ( ( is_selection-filter_scheduled_finish_date = abap_true
                OR is_selection-scheduled_finish_date IS NOT INITIAL )
            AND ls_order_item-scheduled_finish_date <>
              is_selection-scheduled_finish_date )
          OR ( is_selection-filter_scheduled_finish_time = abap_true
            AND ( ls_order_item-scheduled_finish_time <
              is_selection-scheduled_finish_time_from
              OR ls_order_item-scheduled_finish_time >
                is_selection-scheduled_finish_time_to ) ).
        CONTINUE.
      ENDIF.

      IF is_selection-active_status_code IS NOT INITIAL.
        READ TABLE lt_candidate_statuses
          WITH KEY
            production_order = ls_order_item-production_order
            status_code = is_selection-active_status_code
          TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
      ELSEIF is_selection-active_status_codes IS NOT INITIAL.
        DATA(lv_active_status_found) = abap_false.
        LOOP AT is_selection-active_status_codes
            INTO DATA(lv_active_status_code).
          READ TABLE lt_candidate_statuses
            WITH KEY
              production_order = ls_order_item-production_order
              status_code = lv_active_status_code
            TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            lv_active_status_found = abap_true.
            EXIT.
          ENDIF.
        ENDLOOP.
        IF lv_active_status_found <> abap_true.
          CONTINUE.
        ENDIF.
      ENDIF.

      APPEND VALUE #(
        production_order      = ls_order_item-production_order
        basic_start_date      = ls_order_item-basic_start_date
        basic_finish_date     = ls_order_item-basic_finish_date
        scheduled_start_date  = ls_order_item-scheduled_start_date
        scheduled_finish_date = ls_order_item-scheduled_finish_date
        scheduled_start_time  = ls_order_item-scheduled_start_time
        scheduled_finish_time = ls_order_item-scheduled_finish_time )
        TO lt_candidate_keys.
    ENDLOOP.

    SORT lt_candidate_keys BY basic_finish_date production_order.
    DELETE ADJACENT DUPLICATES FROM lt_candidate_keys
      COMPARING basic_finish_date production_order.

    LOOP AT lt_candidate_keys INTO DATA(ls_candidate_key).
      IF is_selection-after_finish_date IS NOT INITIAL
          AND ( ls_candidate_key-basic_finish_date <
            is_selection-after_finish_date
            OR ( ls_candidate_key-basic_finish_date =
              is_selection-after_finish_date
              AND ls_candidate_key-production_order <=
                is_selection-after_order ) ).
        CONTINUE.
      ENDIF.

      APPEND ls_candidate_key TO rt_order_keys.
      IF lines( rt_order_keys ) > is_selection-maximum_results.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_prod_order_read_repo~read_order_statuses.
    ADD 1 TO status_read_calls.
    requested_status_orders = it_production_orders.
    CLEAR rt_statuses.
    LOOP AT order_statuses INTO DATA(ls_order_status).
      READ TABLE it_production_orders
        WITH KEY table_line = ls_order_status-production_order
        TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        APPEND ls_order_status TO rt_statuses.
      ENDIF.
    ENDLOOP.
    SORT rt_statuses BY production_order status_code.
  ENDMETHOD.

  METHOD zif_prod_order_read_repo~read_confirmations.
    ADD 1 TO confirmation_read_calls.
    requested_confirmation_orders = it_production_orders.
    IF use_confirmation_override = abap_true.
      rt_confirmations = confirmation_override.
      RETURN.
    ENDIF.
    rt_confirmations = order_confirmations.
    LOOP AT rt_confirmations ASSIGNING FIELD-SYMBOL(<ls_confirmation>).
      READ TABLE order_items INTO DATA(ls_confirmation_order_item)
        WITH KEY production_order = <ls_confirmation>-production_order.
      IF sy-subrc = 0.
        <ls_confirmation>-order_category =
          ls_confirmation_order_item-order_category.
        <ls_confirmation>-order_type =
          ls_confirmation_order_item-order_type.
      ENDIF.
    ENDLOOP.
    IF iv_order_category IS NOT INITIAL.
      DELETE rt_confirmations WHERE order_category <> iv_order_category.
    ENDIF.
    IF iv_order_type IS NOT INITIAL.
      DELETE rt_confirmations WHERE order_type <> iv_order_type.
    ENDIF.
    IF iv_operation_counter_from IS NOT INITIAL.
      DELETE rt_confirmations WHERE operation_counter <
        iv_operation_counter_from.
    ENDIF.
    IF iv_operation_counter_to IS NOT INITIAL.
      DELETE rt_confirmations WHERE operation_counter >
        iv_operation_counter_to.
    ENDIF.
    IF iv_operation_counter IS NOT INITIAL.
      DELETE rt_confirmations WHERE operation_counter <> iv_operation_counter.
    ENDIF.
    IF iv_operation_number IS NOT INITIAL.
      DELETE rt_confirmations WHERE operation_number <> iv_operation_number.
    ENDIF.
    IF iv_operation_number_from IS NOT INITIAL.
      DELETE rt_confirmations WHERE operation_number <
        iv_operation_number_from.
    ENDIF.
    IF iv_operation_number_to IS NOT INITIAL.
      DELETE rt_confirmations WHERE operation_number >
        iv_operation_number_to.
    ENDIF.
    IF iv_filter_control_key = abap_true
        OR iv_control_key IS NOT INITIAL.
      DELETE rt_confirmations WHERE control_key <> iv_control_key.
    ENDIF.
    IF iv_filter_op_description = abap_true
        OR iv_operation_description IS NOT INITIAL.
      DELETE rt_confirmations WHERE operation_description <>
        iv_operation_description.
    ENDIF.
    IF iv_filter_resource_object_id = abap_true
        OR iv_resource_object_id IS NOT INITIAL.
      DELETE rt_confirmations WHERE resource_object_id <>
        iv_resource_object_id.
    ENDIF.
    IF iv_filter_work_center = abap_true
        OR iv_work_center IS NOT INITIAL.
      DELETE rt_confirmations WHERE work_center <> iv_work_center.
    ENDIF.
    IF iv_filter_work_center_plant = abap_true
        OR iv_work_center_plant IS NOT INITIAL.
      DELETE rt_confirmations WHERE work_center_plant <>
        iv_work_center_plant.
    ENDIF.
    IF iv_filter_operation_sequence = abap_true
        OR iv_operation_sequence IS NOT INITIAL.
      DELETE rt_confirmations WHERE operation_sequence <>
        iv_operation_sequence.
    ENDIF.
    IF iv_operation_sequence_from IS NOT INITIAL.
      DELETE rt_confirmations WHERE operation_sequence <
        iv_operation_sequence_from.
    ENDIF.
    IF iv_operation_sequence_to IS NOT INITIAL.
      DELETE rt_confirmations WHERE operation_sequence >
        iv_operation_sequence_to.
    ENDIF.
    IF iv_filter_suboperation_number = abap_true
        OR iv_suboperation_number IS NOT INITIAL.
      DELETE rt_confirmations WHERE operation_suboperation <>
        iv_suboperation_number.
    ENDIF.
    IF iv_suboperation_number_from IS NOT INITIAL.
      DELETE rt_confirmations WHERE operation_suboperation <
        iv_suboperation_number_from.
    ENDIF.
    IF iv_suboperation_number_to IS NOT INITIAL.
      DELETE rt_confirmations WHERE operation_suboperation >
        iv_suboperation_number_to.
    ENDIF.
    IF iv_confirmation_number IS NOT INITIAL.
      DELETE rt_confirmations WHERE confirmation <> iv_confirmation_number.
    ENDIF.
    IF iv_confirmation_counter IS NOT INITIAL.
      DELETE rt_confirmations WHERE confirmation_counter <>
        iv_confirmation_counter.
    ENDIF.
    IF iv_posting_date_from IS NOT INITIAL
        OR iv_posting_date_to IS NOT INITIAL.
      DELETE rt_confirmations WHERE posting_date IS INITIAL.
    ENDIF.
    IF iv_posting_date_from IS NOT INITIAL.
      DELETE rt_confirmations WHERE posting_date < iv_posting_date_from.
    ENDIF.
    IF iv_posting_date_to IS NOT INITIAL.
      DELETE rt_confirmations WHERE posting_date > iv_posting_date_to.
    ENDIF.
    IF iv_entry_date_from IS NOT INITIAL
        OR iv_entry_date_to IS NOT INITIAL.
      DELETE rt_confirmations WHERE entry_date IS INITIAL.
    ENDIF.
    IF iv_entry_date_from IS NOT INITIAL.
      DELETE rt_confirmations WHERE entry_date < iv_entry_date_from.
    ENDIF.
    IF iv_entry_date_to IS NOT INITIAL.
      DELETE rt_confirmations WHERE entry_date > iv_entry_date_to.
    ENDIF.
    IF iv_execution_start_date_from IS NOT INITIAL
        OR iv_execution_start_date_to IS NOT INITIAL.
      DELETE rt_confirmations WHERE execution_start_date IS INITIAL.
    ENDIF.
    IF iv_execution_start_date_from IS NOT INITIAL.
      DELETE rt_confirmations WHERE execution_start_date <
        iv_execution_start_date_from.
    ENDIF.
    IF iv_execution_start_date_to IS NOT INITIAL.
      DELETE rt_confirmations WHERE execution_start_date >
        iv_execution_start_date_to.
    ENDIF.
    IF iv_execution_finish_date_from IS NOT INITIAL
        OR iv_execution_finish_date_to IS NOT INITIAL.
      DELETE rt_confirmations WHERE execution_finish_date IS INITIAL.
    ENDIF.
    IF iv_execution_finish_date_from IS NOT INITIAL.
      DELETE rt_confirmations WHERE execution_finish_date <
        iv_execution_finish_date_from.
    ENDIF.
    IF iv_execution_finish_date_to IS NOT INITIAL.
      DELETE rt_confirmations WHERE execution_finish_date >
        iv_execution_finish_date_to.
    ENDIF.
    IF iv_filter_execution_start_time = abap_true.
      DELETE rt_confirmations WHERE execution_start_date IS INITIAL.
      DELETE rt_confirmations WHERE execution_start_time <
        iv_execution_start_time_from.
      DELETE rt_confirmations WHERE execution_start_time >
        iv_execution_start_time_to.
    ENDIF.
    IF iv_filter_exec_finish_time = abap_true.
      DELETE rt_confirmations WHERE execution_finish_date IS INITIAL.
      DELETE rt_confirmations WHERE execution_finish_time <
        iv_execution_finish_time_from.
      DELETE rt_confirmations WHERE execution_finish_time >
        iv_execution_finish_time_to.
    ENDIF.
    IF iv_filter_entered_by = abap_true
        OR iv_entered_by IS NOT INITIAL.
      DELETE rt_confirmations WHERE entered_by <> iv_entered_by.
    ENDIF.
    IF iv_filter_changed_by = abap_true
        OR iv_changed_by IS NOT INITIAL.
      DELETE rt_confirmations WHERE changed_by <> iv_changed_by.
    ENDIF.
    IF iv_last_change_date_from IS NOT INITIAL
        OR iv_last_change_date_to IS NOT INITIAL.
      DELETE rt_confirmations WHERE last_change_date IS INITIAL.
    ENDIF.
    IF iv_last_change_date_from IS NOT INITIAL.
      DELETE rt_confirmations WHERE last_change_date <
        iv_last_change_date_from.
    ENDIF.
    IF iv_last_change_date_to IS NOT INITIAL.
      DELETE rt_confirmations WHERE last_change_date >
        iv_last_change_date_to.
    ENDIF.
    IF iv_filter_quantity_unit = abap_true
        OR iv_quantity_unit IS NOT INITIAL.
      DELETE rt_confirmations WHERE quantity_unit <> iv_quantity_unit.
    ENDIF.
    IF iv_filter_entry_time = abap_true.
      DELETE rt_confirmations WHERE entry_time < iv_entry_time_from.
      DELETE rt_confirmations WHERE entry_time > iv_entry_time_to.
    ENDIF.
    IF iv_positive_yield_only = abap_true.
      DELETE rt_confirmations WHERE yield_quantity <= 0.
    ENDIF.
    IF iv_positive_rework_only = abap_true.
      DELETE rt_confirmations WHERE rework_quantity <= 0.
    ENDIF.
    IF iv_positive_scrap_only = abap_true.
      DELETE rt_confirmations WHERE scrap_quantity <= 0.
    ENDIF.
    IF iv_filter_yield_quantity_from = abap_true.
      DELETE rt_confirmations WHERE yield_quantity <
        iv_yield_quantity_from.
    ENDIF.
    IF iv_filter_yield_quantity_to = abap_true.
      DELETE rt_confirmations WHERE yield_quantity >
        iv_yield_quantity_to.
    ENDIF.
    IF iv_filter_rework_quantity_from = abap_true.
      DELETE rt_confirmations WHERE rework_quantity <
        iv_rework_quantity_from.
    ENDIF.
    IF iv_filter_rework_quantity_to = abap_true.
      DELETE rt_confirmations WHERE rework_quantity >
        iv_rework_quantity_to.
    ENDIF.
    IF iv_filter_scrap_quantity_from = abap_true.
      DELETE rt_confirmations WHERE scrap_quantity <
        iv_scrap_quantity_from.
    ENDIF.
    IF iv_filter_scrap_quantity_to = abap_true.
      DELETE rt_confirmations WHERE scrap_quantity >
        iv_scrap_quantity_to.
    ENDIF.
    IF iv_exclude_reversed = abap_true.
      DELETE rt_confirmations WHERE is_reversed = abap_true.
    ENDIF.
    IF iv_reversed_only = abap_true.
      DELETE rt_confirmations WHERE is_reversed <> abap_true.
    ENDIF.
    IF iv_final_only = abap_true.
      DELETE rt_confirmations WHERE is_final <> abap_true.
    ENDIF.
    IF iv_partial_only = abap_true.
      DELETE rt_confirmations WHERE is_final = abap_true.
    ENDIF.

    SORT rt_confirmations BY production_order posting_date DESCENDING
      confirmation DESCENDING confirmation_counter DESCENDING.
    IF is_page_selection IS SUPPLIED.
      DATA(lt_confirmation_page) = VALUE
        zif_prod_order_read_repo=>ty_order_confirmations( ).
      DATA lv_confirmation_after_cursor TYPE abap_bool.

      LOOP AT rt_confirmations INTO DATA(ls_page_candidate).
        lv_confirmation_after_cursor = abap_false.
        IF is_page_selection-has_cursor = abap_false
            OR ls_page_candidate-production_order >
              is_page_selection-after_production_order
            OR ( ls_page_candidate-production_order =
                is_page_selection-after_production_order
              AND ls_page_candidate-posting_date <
                is_page_selection-after_posting_date )
            OR ( ls_page_candidate-production_order =
                is_page_selection-after_production_order
              AND ls_page_candidate-posting_date =
                is_page_selection-after_posting_date
              AND ls_page_candidate-confirmation <
                is_page_selection-after_confirmation )
            OR ( ls_page_candidate-production_order =
                is_page_selection-after_production_order
              AND ls_page_candidate-posting_date =
                is_page_selection-after_posting_date
              AND ls_page_candidate-confirmation =
                is_page_selection-after_confirmation
              AND ls_page_candidate-confirmation_counter <
                is_page_selection-after_confirmation_counter ).
          lv_confirmation_after_cursor = abap_true.
        ENDIF.

        IF lv_confirmation_after_cursor = abap_true.
          APPEND ls_page_candidate TO lt_confirmation_page.
          IF lines( lt_confirmation_page ) >
              is_page_selection-maximum_results.
            EXIT.
          ENDIF.
        ENDIF.
      ENDLOOP.
      rt_confirmations = lt_confirmation_page.
    ENDIF.
  ENDMETHOD.

  METHOD zif_prod_order_read_repo~search_confirmations_by_window.
    DATA lt_matching_orders TYPE HASHED TABLE OF
      zif_prod_order_read_repo=>ty_order_number
      WITH UNIQUE KEY table_line.
    DATA lt_candidates TYPE
      zif_prod_order_read_repo=>ty_order_confirmations.

    ADD 1 TO confirmation_window_read_calls.
    requested_conf_selection = is_selection.
    IF use_conf_window_override = abap_true.
      rt_confirmations = conf_window_override.
      LOOP AT rt_confirmations ASSIGNING FIELD-SYMBOL(<ls_override>).
        IF <ls_override>-scope_material IS INITIAL.
          <ls_override>-scope_material = is_selection-material.
        ENDIF.
        IF <ls_override>-scope_plant IS INITIAL.
          <ls_override>-scope_plant = is_selection-plant.
        ENDIF.
      ENDLOOP.
      RETURN.
    ENDIF.
    LOOP AT order_items INTO DATA(ls_order_item).
      IF ls_order_item-material = is_selection-material
          AND ls_order_item-plant = is_selection-plant
          AND ( ls_order_item-order_category = '10'
            OR ls_order_item-order_category = '40' )
          AND ( ( is_selection-filter_order_type = abap_false
                AND is_selection-order_type IS INITIAL )
            OR ls_order_item-order_type = is_selection-order_type )
          AND ( is_selection-exclude_deleted = abap_false
            OR ( ls_order_item-order_deletion_indicator IS INITIAL
              AND ls_order_item-item_deletion_indicator IS INITIAL ) ).
        INSERT ls_order_item-production_order INTO TABLE lt_matching_orders.
      ENDIF.
    ENDLOOP.

    LOOP AT order_confirmations INTO DATA(ls_confirmation).
      READ TABLE order_items INTO DATA(ls_confirmation_order_item)
        WITH KEY production_order = ls_confirmation-production_order
                 material = is_selection-material
                 plant = is_selection-plant.
      IF sy-subrc = 0.
        ls_confirmation-order_type = ls_confirmation_order_item-order_type.
        ls_confirmation-order_deletion_indicator =
          ls_confirmation_order_item-order_deletion_indicator.
      ENDIF.
      READ TABLE lt_matching_orders
        WITH TABLE KEY table_line = ls_confirmation-production_order
        TRANSPORTING NO FIELDS.
      IF sy-subrc = 0
          AND ( is_selection-production_order IS INITIAL
            OR ls_confirmation-production_order =
              is_selection-production_order )
          AND ( is_selection-operation_number IS INITIAL
            OR ls_confirmation-operation_number =
              is_selection-operation_number )
          AND ( is_selection-operation_number_from IS INITIAL
            OR ls_confirmation-operation_number >=
              is_selection-operation_number_from )
          AND ( is_selection-operation_counter_from IS INITIAL
            OR ls_confirmation-operation_counter >=
              is_selection-operation_counter_from )
          AND ( is_selection-operation_counter_to IS INITIAL
            OR ls_confirmation-operation_counter <=
              is_selection-operation_counter_to )
          AND ( is_selection-operation_number_to IS INITIAL
            OR ls_confirmation-operation_number <=
              is_selection-operation_number_to )
          AND ( is_selection-operation_sequence_from IS INITIAL
            OR ls_confirmation-operation_sequence >=
              is_selection-operation_sequence_from )
          AND ( is_selection-operation_sequence_to IS INITIAL
            OR ls_confirmation-operation_sequence <=
              is_selection-operation_sequence_to )
          AND ( is_selection-operation_suboperation_from IS INITIAL
            OR ls_confirmation-operation_suboperation >=
              is_selection-operation_suboperation_from )
          AND ( is_selection-operation_suboperation_to IS INITIAL
            OR ls_confirmation-operation_suboperation <=
              is_selection-operation_suboperation_to )
          AND ( ( is_selection-filter_operation_suboperation = abap_false
              AND is_selection-operation_suboperation IS INITIAL )
            OR ls_confirmation-operation_suboperation =
              is_selection-operation_suboperation )
          AND ( ( is_selection-filter_operation_sequence = abap_false
              AND is_selection-operation_sequence IS INITIAL )
            OR ls_confirmation-operation_sequence =
              is_selection-operation_sequence )
          AND ( ( is_selection-filter_control_key = abap_false
              AND is_selection-control_key IS INITIAL )
            OR ls_confirmation-control_key = is_selection-control_key )
          AND ( ( is_selection-filter_operation_description = abap_false
              AND is_selection-operation_description IS INITIAL )
            OR ls_confirmation-operation_description =
              is_selection-operation_description )
          AND ( ( is_selection-filter_resource_object_id = abap_false
              AND is_selection-resource_object_id IS INITIAL )
            OR ls_confirmation-resource_object_id =
              is_selection-resource_object_id )
          AND ( ( is_selection-filter_work_center = abap_false
              AND is_selection-work_center IS INITIAL )
            OR ls_confirmation-work_center = is_selection-work_center )
          AND ( ( is_selection-filter_work_center_plant = abap_false
              AND is_selection-work_center_plant IS INITIAL )
            OR ls_confirmation-work_center_plant =
              is_selection-work_center_plant )
          AND ( ( is_selection-filter_quantity_unit = abap_false
              AND is_selection-quantity_unit IS INITIAL )
            OR ls_confirmation-quantity_unit = is_selection-quantity_unit )
          AND ( ( is_selection-filter_entered_by = abap_false
              AND is_selection-entered_by IS INITIAL )
            OR ls_confirmation-entered_by = is_selection-entered_by )
          AND ( is_selection-confirmation_number IS INITIAL
            OR ls_confirmation-confirmation =
              is_selection-confirmation_number )
          AND ( is_selection-confirmation_counter IS INITIAL
            OR ls_confirmation-confirmation_counter =
              is_selection-confirmation_counter )
          AND ( is_selection-confirmation_counter_from IS INITIAL
            OR ls_confirmation-confirmation_counter >=
              is_selection-confirmation_counter_from )
          AND ( is_selection-confirmation_counter_to IS INITIAL
            OR ls_confirmation-confirmation_counter <=
              is_selection-confirmation_counter_to )
          AND ( is_selection-filter_yield_quantity_from = abap_false
            OR ls_confirmation-yield_quantity >=
              is_selection-yield_quantity_from )
          AND ( is_selection-filter_yield_quantity_to = abap_false
            OR ls_confirmation-yield_quantity <=
              is_selection-yield_quantity_to )
          AND ( is_selection-filter_rework_quantity_from = abap_false
            OR ls_confirmation-rework_quantity >=
              is_selection-rework_quantity_from )
          AND ( is_selection-filter_rework_quantity_to = abap_false
            OR ls_confirmation-rework_quantity <=
              is_selection-rework_quantity_to )
          AND ( is_selection-filter_scrap_quantity_from = abap_false
            OR ls_confirmation-scrap_quantity >=
              is_selection-scrap_quantity_from )
          AND ( is_selection-filter_scrap_quantity_to = abap_false
            OR ls_confirmation-scrap_quantity <=
              is_selection-scrap_quantity_to )
          AND ( is_selection-order_category IS INITIAL
            OR ls_confirmation-order_category =
              is_selection-order_category )
          AND ( is_selection-order_type IS INITIAL
            OR ls_confirmation-order_type = is_selection-order_type )
          AND ( is_selection-operation_counter IS INITIAL
            OR ls_confirmation-operation_counter =
              is_selection-operation_counter )
          AND ls_confirmation-posting_date >=
            is_selection-posting_date_from
          AND ls_confirmation-posting_date <=
            is_selection-posting_date_to
          AND ( is_selection-entry_date_from IS INITIAL
            OR ( ls_confirmation-entry_date >=
                is_selection-entry_date_from
              AND ls_confirmation-entry_date <=
                is_selection-entry_date_to ) )
          AND ( ( is_selection-filter_changed_by = abap_false
              AND is_selection-changed_by IS INITIAL )
            OR ls_confirmation-changed_by = is_selection-changed_by )
          AND ( is_selection-last_change_date_from IS INITIAL
            OR ( ls_confirmation-last_change_date >=
                is_selection-last_change_date_from
              AND ls_confirmation-last_change_date <=
                is_selection-last_change_date_to ) )
          AND ( is_selection-execution_start_date_from IS INITIAL
            OR ( ls_confirmation-execution_start_date IS NOT INITIAL
              AND ls_confirmation-execution_start_date >=
                is_selection-execution_start_date_from ) )
          AND ( is_selection-execution_start_date_to IS INITIAL
            OR ( ls_confirmation-execution_start_date IS NOT INITIAL
              AND ls_confirmation-execution_start_date <=
                is_selection-execution_start_date_to ) )
          AND ( is_selection-filter_execution_start_time = abap_false
            OR ( ls_confirmation-execution_start_date IS NOT INITIAL
              AND ls_confirmation-execution_start_time >=
                is_selection-execution_start_time_from
              AND ls_confirmation-execution_start_time <=
                is_selection-execution_start_time_to ) )
          AND ( is_selection-execution_finish_date_from IS INITIAL
            OR ( ls_confirmation-execution_finish_date IS NOT INITIAL
              AND ls_confirmation-execution_finish_date >=
                is_selection-execution_finish_date_from ) )
          AND ( is_selection-execution_finish_date_to IS INITIAL
            OR ( ls_confirmation-execution_finish_date IS NOT INITIAL
              AND ls_confirmation-execution_finish_date <=
                is_selection-execution_finish_date_to ) )
          AND ( is_selection-filter_execution_finish_time = abap_false
            OR ( ls_confirmation-execution_finish_date IS NOT INITIAL
              AND ls_confirmation-execution_finish_time >=
                is_selection-execution_finish_time_from
              AND ls_confirmation-execution_finish_time <=
                is_selection-execution_finish_time_to ) )
          AND ( is_selection-filter_entry_time = abap_false
            OR ( ls_confirmation-entry_time >=
                is_selection-entry_time_from
              AND ls_confirmation-entry_time <=
                is_selection-entry_time_to ) ).
        IF is_selection-exclude_reversed = abap_true
            AND ls_confirmation-is_reversed = abap_true.
          CONTINUE.
        ENDIF.
        IF is_selection-reversed_only = abap_true
            AND ls_confirmation-is_reversed <> abap_true.
          CONTINUE.
        ENDIF.
        IF is_selection-positive_rework_only = abap_true
            AND ls_confirmation-rework_quantity <= 0.
          CONTINUE.
        ENDIF.
        IF is_selection-positive_yield_only = abap_true
            AND ls_confirmation-yield_quantity <= 0.
          CONTINUE.
        ENDIF.
        IF is_selection-positive_scrap_only = abap_true
            AND ls_confirmation-scrap_quantity <= 0.
          CONTINUE.
        ENDIF.
        IF is_selection-final_only = abap_true
            AND ls_confirmation-is_final <> abap_true.
          CONTINUE.
        ENDIF.
        IF is_selection-partial_only = abap_true
            AND ls_confirmation-is_final = abap_true.
          CONTINUE.
        ENDIF.
        ls_confirmation-scope_material = is_selection-material.
        ls_confirmation-scope_plant = is_selection-plant.
        APPEND ls_confirmation TO lt_candidates.
      ENDIF.
    ENDLOOP.

    SORT lt_candidates BY posting_date production_order confirmation
      confirmation_counter.
    LOOP AT lt_candidates INTO ls_confirmation.
      IF is_selection-after_posting_date IS NOT INITIAL
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
                is_selection-after_confirmation_counter ) ).
        CONTINUE.
      ENDIF.

      APPEND ls_confirmation TO rt_confirmations.
      IF lines( rt_confirmations ) > is_selection-maximum_results.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_prod_order_read_repo~read_operations.
    requested_op_resource_filter = iv_filter_resource_object_id.
    requested_op_resource_id = iv_resource_object_id.
    ADD 1 TO operation_read_calls.
    requested_operation_orders = it_production_orders.
    IF use_operation_override = abap_true.
      rt_operations = operation_override.
      RETURN.
    ENDIF.

    LOOP AT order_operations INTO DATA(ls_operation).
      READ TABLE it_production_orders
        WITH KEY table_line = ls_operation-production_order
        TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        DATA(lv_operation_order_type) = ls_operation-order_type.
        READ TABLE order_items INTO DATA(ls_operation_order_item)
          WITH KEY production_order = ls_operation-production_order.
        IF sy-subrc = 0.
          lv_operation_order_type = ls_operation_order_item-order_type.
        ENDIF.
        IF ( iv_filter_resource_object_id = abap_false
            AND iv_resource_object_id IS INITIAL )
            OR ls_operation-resource_object_id = iv_resource_object_id.
          IF ( iv_filter_control_key = abap_false
              AND iv_control_key IS INITIAL )
              OR ls_operation-control_key = iv_control_key.
            IF ( iv_filter_op_description = abap_false
                AND iv_operation_description IS INITIAL )
                OR ls_operation-operation_description =
                  iv_operation_description.
              IF iv_operation_number IS INITIAL
                  OR ls_operation-operation_number = iv_operation_number.
                IF ( iv_filter_operation_sequence = abap_false
                    AND iv_operation_sequence IS INITIAL )
                    OR ls_operation-operation_sequence =
                      iv_operation_sequence.
                  IF ( iv_filter_suboperation_number = abap_false
                      AND iv_suboperation_number IS INITIAL )
                      OR ls_operation-suboperation_number =
                        iv_suboperation_number.
                    IF ( iv_order_category IS INITIAL
                        OR ls_operation-order_category = iv_order_category )
                        AND ( iv_order_type IS INITIAL
                          OR lv_operation_order_type = iv_order_type )
                        AND ( iv_operation_counter IS INITIAL
                          OR ls_operation-operation_counter =
                            iv_operation_counter )
                        AND ( iv_operation_number_from IS INITIAL
                          OR ls_operation-operation_number >=
                            iv_operation_number_from )
                        AND ( iv_operation_number_to IS INITIAL
                          OR ls_operation-operation_number <=
                            iv_operation_number_to )
                        AND ( iv_operation_counter_from IS INITIAL
                          OR ls_operation-operation_counter >=
                            iv_operation_counter_from )
                        AND ( iv_operation_counter_to IS INITIAL
                          OR ls_operation-operation_counter <=
                            iv_operation_counter_to )
                        AND ( iv_operation_sequence_from IS INITIAL
                          OR ls_operation-operation_sequence >=
                            iv_operation_sequence_from )
                        AND ( iv_operation_sequence_to IS INITIAL
                          OR ls_operation-operation_sequence <=
                            iv_operation_sequence_to )
                        AND ( iv_suboperation_number_from IS INITIAL
                          OR ls_operation-suboperation_number >=
                            iv_suboperation_number_from )
                        AND ( iv_suboperation_number_to IS INITIAL
                          OR ls_operation-suboperation_number <=
                            iv_suboperation_number_to ).
                      ls_operation-order_type = lv_operation_order_type.
                      APPEND ls_operation TO rt_operations.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF iv_work_center IS NOT INITIAL.
      DELETE rt_operations WHERE work_center <> iv_work_center.
    ELSEIF iv_filter_work_center = abap_true.
      DELETE rt_operations WHERE work_center IS NOT INITIAL.
    ENDIF.
    IF iv_work_center_plant IS NOT INITIAL.
      DELETE rt_operations
        WHERE work_center_plant <> iv_work_center_plant.
    ELSEIF iv_filter_work_center_plant = abap_true.
      DELETE rt_operations WHERE work_center_plant IS NOT INITIAL.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_prod_order_read DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS reads_multiple_items_and_units FOR TESTING
      RAISING cx_static_check.
    METHODS filters_ops_by_work_center FOR TESTING
      RAISING cx_static_check.
    METHODS reports_missing_or_bad_units FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_bad_bulk_rows FOR TESTING
      RAISING cx_static_check.
    METHODS validates_numbers_before_read FOR TESTING
      RAISING cx_static_check.
    METHODS empty_read_skips_repository FOR TESTING
      RAISING cx_static_check.
    METHODS searches_order_finish_window FOR TESTING
      RAISING cx_static_check.
    METHODS summarizes_finish_conv_scope FOR TESTING
      RAISING cx_static_check.
    METHODS filters_finish_receipt_state FOR TESTING
      RAISING cx_static_check.
    METHODS filters_finish_rcvd_qty FOR TESTING
      RAISING cx_static_check.
    METHODS filters_finish_start_window FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_partial_start_window FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_bad_start_finish_key FOR TESTING
      RAISING cx_static_check.
    METHODS filters_finish_window_category FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_bad_finish_category FOR TESTING
      RAISING cx_static_check.
    METHODS searches_empty_finish_window FOR TESTING
      RAISING cx_static_check.
    METHODS filters_active_status FOR TESTING
      RAISING cx_static_check.
    METHODS reports_status_drift FOR TESTING
      RAISING cx_static_check.
    METHODS reports_finish_scope_drift FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_invalid_finish_keys FOR TESTING
      RAISING cx_static_check.
    METHODS reads_exact_finish_limit FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_bad_finish_search FOR TESTING
      RAISING cx_static_check.
    METHODS searches_confirmation_window FOR TESTING
      RAISING cx_static_check.
    METHODS filters_deleted_conf_orders FOR TESTING
      RAISING cx_static_check.
    METHODS excludes_reversed_confirmation FOR TESTING
      RAISING cx_static_check.
    METHODS filters_quality_quantities FOR TESTING
      RAISING cx_static_check.
    METHODS filters_conf_yield_range FOR TESTING
      RAISING cx_static_check.
    METHODS filters_conf_operation_range FOR TESTING
      RAISING cx_static_check.
    METHODS filters_conf_sequence_range FOR TESTING
      RAISING cx_static_check.
    METHODS filters_conf_subop_range FOR TESTING
      RAISING cx_static_check.
    METHODS filters_conf_counter_range FOR TESTING
      RAISING cx_static_check.
    METHODS filters_conf_rmzhl_range FOR TESTING
      RAISING cx_static_check.
    METHODS filters_conf_work_center FOR TESTING
      RAISING cx_static_check.
    METHODS filters_conf_bulk_work_center FOR TESTING
      RAISING cx_static_check.
    METHODS filters_conf_execution_finish FOR TESTING
      RAISING cx_static_check.
    METHODS converts_conf_window_base_unit FOR TESTING
      RAISING cx_static_check.
    METHODS checks_avg_exec_duration FOR TESTING
      RAISING cx_static_check.
    METHODS checks_exec_duration_union FOR TESTING
      RAISING cx_static_check.
    METHODS checks_exec_percentiles FOR TESTING
      RAISING cx_static_check.
    METHODS checks_exec_p99_tails FOR TESTING
      RAISING cx_static_check.
    METHODS checks_exec_3plus_avg FOR TESTING
      RAISING cx_static_check.
    METHODS checks_exec_idle_gap_average FOR TESTING
      RAISING cx_static_check.
    METHODS checks_zero_exec_duration FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_unknown_conf_uom FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_conf_base_loss FOR TESTING
      RAISING cx_static_check.
    METHODS filters_confirmation_operation FOR TESTING
      RAISING cx_static_check.
    METHODS filters_conf_routing FOR TESTING
      RAISING cx_static_check.
    METHODS filters_final_confirmations FOR TESTING
      RAISING cx_static_check.
    METHODS filters_partial_confirmations FOR TESTING
      RAISING cx_static_check.
    METHODS summarizes_confirmation_page FOR TESTING
      RAISING cx_static_check.
    METHODS reads_exact_confirmation_limit FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_bad_conf_window FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_bad_window_results FOR TESTING
      RAISING cx_static_check.
    METHODS assert_bad_window_result
      IMPORTING
        io_cut           TYPE REF TO zcl_prod_order_read_service
        io_repository    TYPE REF TO lcl_prod_order_read_repo
        is_selection     TYPE
          zif_prod_order_read_repo=>ty_confirmation_window_selection
        it_confirmations TYPE
          zif_prod_order_read_repo=>ty_order_confirmations
      RAISING cx_static_check.
    METHODS reads_order_statuses FOR TESTING
      RAISING cx_static_check.
    METHODS reads_order_confirmations FOR TESTING
      RAISING cx_static_check.
    METHODS validates_confirmation_reads FOR TESTING
      RAISING cx_static_check.
    METHODS filters_conf_audit FOR TESTING
      RAISING cx_static_check.
    METHODS filters_conf_unit FOR TESTING
      RAISING cx_static_check.
    METHODS filters_conf_time FOR TESTING
      RAISING cx_static_check.
    METHODS filters_conf_quality_ranges FOR TESTING
      RAISING cx_static_check.
    METHODS empty_confirmation_read FOR TESTING
      RAISING cx_static_check.
    METHODS reads_order_operations FOR TESTING
      RAISING cx_static_check.
    METHODS validates_operation_reads FOR TESTING
      RAISING cx_static_check.
    METHODS empty_operation_read FOR TESTING
      RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_prod_order_read IMPLEMENTATION.
  METHOD reads_multiple_items_and_units.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order          = '0000000002'
        production_item           = '0002'
        material                  = 'MAT-BY'
        plant                     = '1000'
        order_unit                = 'CS'
        base_unit                 = 'EA'
        order_quantity            = '5.000'
        received_quantity         = '1.000'
        order_to_base_numerator   = 12
        order_to_base_denominator = 1
        receipt_expected          = abap_true )
      ( production_order          = '0000000001'
        production_item           = '0001'
        material                  = 'MAT-A'
        plant                     = '2000'
        order_unit                = 'KG'
        base_unit                 = 'KG'
        order_quantity            = '2.000'
        received_quantity         = '0.500'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1
        phase_1_indicator         = abap_true )
      ( production_order          = '0000000002'
        production_item           = '0003'
        material                  = 'MAT-C'
        plant                     = '1000'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '3.000'
        received_quantity         = '3.000'
        order_to_base_numerator   = 12
        order_to_base_denominator = 1 )
      ( production_order          = '0000000002'
        production_item           = '0004'
        material                  = 'MAT-D'
        plant                     = '1000'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '2.000'
        received_quantity         = '2.500'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_bulk(
      it_production_orders = VALUE #(
        ( '0000000001' )
        ( '0000000002' ) ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_not_initial(
      act = ls_result-snapshot_timestamp ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-key_selection_timestamp ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->read_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-conversion_succeeded_count
      exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-conversion_failed_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-receipt_progress_counts-not_started_item_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-receipt_progress_counts-partial_item_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-receipt_progress_counts-complete_item_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-receipt_progress_counts-over_received_item_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-receipt_progress_counts-invalid_item_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-receipt_progress_counts-total_item_count
      exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-receipt_progress_counts-partial_pct
      exp = CONV decfloat34( '50.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-receipt_progress_counts-complete_pct
      exp = CONV decfloat34( '25.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-receipt_progress_counts-over_received_pct
      exp = CONV decfloat34( '25.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-production_order
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-conversion_succeeded_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-conversion_failed_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-receipt_progress_counts-total_item_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-receipt_progress_counts-partial_pct
      exp = CONV decfloat34( '100.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-orders[ 2 ]-items )
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-receipt_progress_counts-total_item_count
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-conversion_succeeded_count
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-conversion_failed_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-receipt_progress_counts-partial_item_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-receipt_progress_counts-complete_item_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-receipt_progress_counts-over_received_item_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-receipt_progress_counts-partial_pct
      exp = CONV decfloat34( '33.33' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-items[ 1 ]-order_quantity_base
      exp = CONV decfloat34( '60.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-items[ 1 ]-received_quantity_base
      exp = CONV decfloat34( '12.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-items[ 1 ]-open_quantity_base
      exp = CONV decfloat34( '48.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-items[ 1 ]-open_quantity_order_unit
      exp = CONV decfloat34( '4.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-items[ 1 ]-over_receipt_qty_order_unit
      exp = CONV decfloat34( 0 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-items[ 1 ]-received_pct_of_order_qty
      exp = CONV decfloat34( '20.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-items[ 1 ]-open_pct_of_order_qty
      exp = CONV decfloat34( '80.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-items[ 1 ]-receipt_progress_status
      exp = zcl_prod_order_read_service=>c_receipt_progress_partial ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 2 ]-items[ 1 ]-is_receipt_progress_valid ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 2 ]-items[ 1 ]-matches_finish_selection ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-finish_window_match_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 2 ]-matching_progress_counts ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-finish_match_progress_counts ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-finish_match_conv_ok_count ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-finish_match_conv_fail_count ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 2 ]-matching_conv_ok_count ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 2 ]-matching_conv_fail_count ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-items[ 2 ]-open_quantity_base
      exp = CONV decfloat34( 0 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-items[ 2 ]-received_pct_of_order_qty
      exp = CONV decfloat34( '100.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-items[ 2 ]-over_receipt_qty_order_unit
      exp = CONV decfloat34( 0 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-items[ 2 ]-receipt_progress_status
      exp = zcl_prod_order_read_service=>c_receipt_progress_complete ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-items[ 2 ]-open_pct_of_order_qty
      exp = CONV decfloat34( 0 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-items[ 3 ]-open_quantity_order_unit
      exp = CONV decfloat34( 0 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-items[ 3 ]-over_receipt_qty_order_unit
      exp = CONV decfloat34( '0.500' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-items[ 3 ]-received_pct_of_order_qty
      exp = CONV decfloat34( '125.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-items[ 3 ]-open_pct_of_order_qty
      exp = CONV decfloat34( 0 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-items[ 3 ]-receipt_progress_status
      exp = zcl_prod_order_read_service=>c_receipt_over_received ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 2 ]-items[ 1 ]-is_quantity_converted ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->status_read_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD reads_order_statuses.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order          = '0000000001'
        production_item           = '0001'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = 1
        received_quantity         = 0
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 )
      ( production_order          = '0000000002'
        production_item           = '0001'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = 1
        received_quantity         = 0
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 ) ).
    lo_repository->order_statuses = VALUE #(
      ( production_order  = '0000000002'
        status_code       = 'E0001'
        status_profile    = 'ZPROD'
        is_user_status    = abap_true
        status_short_name = 'HOLD'
        status_name       = 'Material hold' )
      ( production_order  = '0000000001'
        status_code       = 'I0002'
        is_user_status    = abap_false
        status_short_name = 'REL'
        status_name       = 'Released' )
      ( production_order  = '0000000002'
        status_code       = 'I0001'
        is_user_status    = abap_false
        status_short_name = 'CRTD'
        status_name       = 'Created' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_bulk(
      it_production_orders = VALUE #(
        ( '0000000001' )
        ( '0000000002' ) ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->status_read_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->requested_status_orders[ 2 ]
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-orders[ 1 ]-statuses )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-statuses[ 1 ]-status_code
      exp = 'I0002' ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-statuses[ 1 ]-is_user_status ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-statuses[ 1 ]-status_name
      exp = 'Released' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-orders[ 2 ]-statuses )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-statuses[ 1 ]-status_code
      exp = 'E0001' ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 2 ]-statuses[ 1 ]-is_user_status ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-statuses[ 1 ]-status_short_name
      exp = 'HOLD' ).
  ENDMETHOD.

  METHOD reports_missing_or_bad_units.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order          = '0000000001'
        production_item           = '0001'
        material                  = 'MAT-A'
        plant                     = '1000'
        order_quantity            = '2.000'
        received_quantity         = '0.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 )
      ( production_order          = '0000000001'
        production_item           = '0002'
        material                  = 'MAT-B'
        plant                     = '1000'
        order_unit                = 'CS'
        base_unit                 = 'EA'
        order_quantity            = '2.000'
        received_quantity         = '0.000'
        order_to_base_numerator   = 0
        order_to_base_denominator = 1 )
      ( production_order          = '0000000001'
        production_item           = '0003'
        material                  = 'MAT-C'
        plant                     = '1000'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '2.000'
        received_quantity         = '-1.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 )
      ( production_order          = '0000000001'
        production_item           = '0004'
        material                  = 'MAT-D'
        plant                     = '1000'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '0.000'
        received_quantity         = '0.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 )
      ( production_order          = '0000000001'
        production_item           = '0005'
        material                  = 'MAT-E'
        plant                     = '1000'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '-2.000'
        received_quantity         = '0.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_bulk(
      it_production_orders = VALUE #(
        ( '0000000001' )
        ( '0000000002' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-not_found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-conversion_failed_count
      exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-conversion_succeeded_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-conversion_succeeded_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-conversion_failed_count
      exp = 4 ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 2 ]-conversion_succeeded_count ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 2 ]-conversion_failed_count ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-receipt_progress_counts-not_started_item_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-receipt_progress_counts-partial_item_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-receipt_progress_counts-complete_item_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-receipt_progress_counts-over_received_item_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-receipt_progress_counts-invalid_item_count
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-receipt_progress_counts-total_item_count
      exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-receipt_progress_counts-not_started_pct
      exp = CONV decfloat34( '40.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-receipt_progress_counts-invalid_pct
      exp = CONV decfloat34( '60.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-receipt_progress_counts-total_item_count
      exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-receipt_progress_counts-invalid_pct
      exp = CONV decfloat34( '60.00' ) ).
    cl_abap_unit_assert=>assert_true( ls_result-orders[ 1 ]-is_found ).
    cl_abap_unit_assert=>assert_false( ls_result-orders[ 2 ]-is_found ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 2 ]-receipt_progress_counts ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-items[ 1 ]-is_quantity_converted ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 1 ]-items[ 1 ]-is_receipt_progress_valid ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-items[ 1 ]-open_quantity_order_unit
      exp = CONV decfloat34( '2.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-items[ 1 ]-over_receipt_qty_order_unit
      exp = CONV decfloat34( 0 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-items[ 1 ]-received_pct_of_order_qty
      exp = CONV decfloat34( 0 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-items[ 1 ]-open_pct_of_order_qty
      exp = CONV decfloat34( '100.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-items[ 1 ]-receipt_progress_status
      exp = zcl_prod_order_read_service=>c_receipt_progress_not_started ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 1 ]-items[ 3 ]-open_quantity_order_unit ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-items[ 3 ]-is_receipt_progress_valid ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 1 ]-items[ 3 ]-over_receipt_qty_order_unit ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 1 ]-items[ 3 ]-received_pct_of_order_qty ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 1 ]-items[ 3 ]-open_pct_of_order_qty ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 1 ]-items[ 3 ]-receipt_progress_status ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 1 ]-items[ 4 ]-open_quantity_order_unit ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 1 ]-items[ 4 ]-over_receipt_qty_order_unit ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 1 ]-items[ 4 ]-received_pct_of_order_qty ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 1 ]-items[ 4 ]-open_pct_of_order_qty ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 1 ]-items[ 4 ]-receipt_progress_status ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-items[ 4 ]-is_receipt_progress_valid ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 1 ]-items[ 5 ]-open_quantity_order_unit ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 1 ]-items[ 5 ]-over_receipt_qty_order_unit ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 1 ]-items[ 5 ]-received_pct_of_order_qty ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 1 ]-items[ 5 ]-open_pct_of_order_qty ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 1 ]-items[ 5 ]-receipt_progress_status ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-items[ 5 ]-is_receipt_progress_valid ).
  ENDMETHOD.

  METHOD rejects_bad_bulk_rows.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    lo_repository->order_items = VALUE #(
      ( production_order = '0000000002'
        production_item  = '0001' ) ).
    lo_repository->use_unfiltered_order_items = abap_true.
    TRY.
        lo_cut->read_orders_bulk(
          it_production_orders = VALUE #( ( '0000000001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    lo_repository->use_unfiltered_order_items = abap_false.
    lo_repository->order_items = VALUE #(
      ( production_order = '0000000001'
        production_item  = '0001' )
      ( production_order = '0000000001'
        production_item  = '0001' ) ).
    TRY.
        lo_cut->read_orders_bulk(
          it_production_orders = VALUE #( ( '0000000001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->read_calls
      exp = 2 ).
  ENDMETHOD.

  METHOD validates_numbers_before_read.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_bulk(
          it_production_orders = VALUE #(
            ( '0000000001' )
            ( '0000000001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->read_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->status_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_bulk(
          it_production_orders = VALUE #(
            ( '0000000001' )
            ( ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->read_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->status_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD empty_read_skips_repository.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_bulk(
      it_production_orders = VALUE #( ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_initial( ls_result-orders ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-receipt_progress_counts ).
    cl_abap_unit_assert=>assert_initial( ls_result-snapshot_timestamp ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD reads_order_confirmations.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order       = '0000000002'
        operation_number       = '0020'
        operation_sequence     = '000000'
        operation_suboperation = '0001'
        operation_description  = 'Inspect suboperation'
        control_key            = 'QM01'
        confirmation           = '0000000003'
        confirmation_counter   = '00000001'
        posting_date           = '20261011'
        execution_start_date   = '20261011'
        execution_start_time   = '070000'
        execution_finish_date  = '20261011'
        execution_finish_time  = '080000'
        work_center            = 'WC-02'
        work_center_plant      = '1000'
        yield_quantity         = '2.000'
        rework_quantity        = '0.100'
        scrap_quantity         = '0.300'
        quantity_unit          = 'EA'
        is_reversed            = 'X' )
      ( production_order      = '0000000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        confirmation          = '0000000001'
        confirmation_counter  = '00000001'
        posting_date          = '20261009'
        execution_start_date  = '20261009'
        execution_start_time  = '070000'
        execution_finish_date = '20261009'
        execution_finish_time = '080000'
        work_center           = 'WC-01'
        work_center_plant     = '1000' )
      ( production_order      = '0000000002'
        operation_number      = '0020'
        operation_sequence    = '000000'
        confirmation          = '0000000002'
        confirmation_counter  = '00000002'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '000000'
        execution_finish_date = '20261010'
        execution_finish_time = '010000'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        is_final              = 'X' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_confirmations_bulk(
      it_production_orders = VALUE #(
        ( '0000000001' )
        ( '0000000002' ) ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_not_initial(
      act = ls_result-snapshot_timestamp ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_read_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->requested_confirmation_orders[ 2 ]
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-empty_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-production_order
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-confirmations[ 1 ]-confirmation
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-orders[ 2 ]-confirmations )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-confirmations[ 1 ]-confirmation
      exp = '0000000003' ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 2 ]-confirmations[ 1 ]-is_reversed ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-confirmations[ 1 ]-operation_suboperation
      exp = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-confirmations[ 1 ]-operation_description
      exp = 'Inspect suboperation' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-confirmations[ 1 ]-control_key
      exp = 'QM01' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-confirmations[ 1 ]-work_center
      exp = 'WC-02' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-confirmations[ 1 ]-work_center_plant
      exp = '1000' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-confirmations[ 1 ]-yield_quantity
      exp = '2.000' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-confirmations[ 1 ]-rework_quantity
      exp = '0.100' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-confirmations[ 1 ]-scrap_quantity
      exp = '0.300' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-confirmations[ 1 ]-quantity_unit
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 2 ]-confirmations[ 2 ]-is_final ).

    DATA(ls_start_time_result) = lo_cut->read_confirmations_bulk(
      it_production_orders           = VALUE #( ( '0000000002' ) )
      iv_execution_start_date_from   = '20261010'
      iv_filter_execution_start_time = abap_true
      iv_execution_start_time_from   = '000000'
      iv_execution_start_time_to     = '000000' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_start_time_result-returned_count
      exp = 1 ).
    DATA(ls_start_time_confirmation) =
      ls_start_time_result-orders[ 1 ]-confirmations[ 1 ].
    cl_abap_unit_assert=>assert_equals(
      act = ls_start_time_confirmation-execution_start_date
      exp = '20261010' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_start_time_confirmation-execution_start_time
      exp = '000000' ).

    DATA(ls_finish_time_result) = lo_cut->read_confirmations_bulk(
      it_production_orders          = VALUE #( ( '0000000002' ) )
      iv_execution_finish_date_from = '20261010'
      iv_execution_finish_date_to   = '20261010'
      iv_filter_exec_finish_time    = abap_true
      iv_execution_finish_time_from = '010000'
      iv_execution_finish_time_to   = '010000' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_finish_time_result-returned_count
      exp = 1 ).
    DATA(ls_finish_time_confirmation) =
      ls_finish_time_result-orders[ 1 ]-confirmations[ 1 ].
    cl_abap_unit_assert=>assert_equals(
      act = ls_finish_time_confirmation-execution_finish_date
      exp = '20261010' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_finish_time_confirmation-execution_finish_time
      exp = '010000' ).

    lo_repository->order_confirmations = VALUE #(
      ( production_order       = '0000000002'
        operation_number       = '0020'
        operation_suboperation = '0001'
        confirmation           = '0000000011'
        confirmation_counter   = '00000001'
        posting_date           = '20261010' )
      ( production_order       = '0000000002'
        operation_number       = '0020'
        operation_suboperation = '0002'
        confirmation           = '0000000012'
        confirmation_counter   = '00000001'
        posting_date           = '20261011' )
      ( production_order       = '0000000002'
        operation_number       = '0020'
        operation_suboperation = '0003'
        confirmation           = '0000000013'
        confirmation_counter   = '00000001'
        posting_date           = '20261012' ) ).
    DATA(ls_subop_range_result) = lo_cut->read_confirmations_bulk(
      it_production_orders        = VALUE #( ( '0000000002' ) )
      iv_operation_number         = '0020'
      iv_suboperation_number_from = '0002'
      iv_suboperation_number_to   = '0003' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_subop_range_result-returned_count
      exp = 2 ).
    DATA(ls_subop_lower_result) = lo_cut->read_confirmations_bulk(
      it_production_orders        = VALUE #( ( '0000000002' ) )
      iv_operation_number         = '0020'
      iv_suboperation_number_from = '0003' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_subop_lower_result-returned_count
      exp = 1 ).
    DATA(ls_subop_upper_result) = lo_cut->read_confirmations_bulk(
      it_production_orders      = VALUE #( ( '0000000002' ) )
      iv_operation_number       = '0020'
      iv_suboperation_number_to = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_subop_upper_result-returned_count
      exp = 1 ).
    DATA(ls_subop_intersect_result) = lo_cut->read_confirmations_bulk(
      it_production_orders        = VALUE #( ( '0000000002' ) )
      iv_operation_number         = '0020'
      iv_suboperation_number      = '0003'
      iv_suboperation_number_from = '0002'
      iv_suboperation_number_to   = '0003' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_subop_intersect_result-returned_count
      exp = 1 ).

    lo_repository->order_confirmations = VALUE #(
      ( production_order     = '0000000002'
        operation_number     = '0010'
        confirmation         = '0000000021'
        confirmation_counter = '00000001'
        posting_date         = '20261010' )
      ( production_order     = '0000000002'
        operation_number     = '0020'
        confirmation         = '0000000022'
        confirmation_counter = '00000001'
        posting_date         = '20261011' )
      ( production_order     = '0000000002'
        operation_number     = '0030'
        confirmation         = '0000000023'
        confirmation_counter = '00000001'
        posting_date         = '20261012' ) ).
    DATA(ls_vornr_range) = lo_cut->read_confirmations_bulk(
      it_production_orders     = VALUE #( ( '0000000002' ) )
      iv_operation_number_from = '0020'
      iv_operation_number_to   = '0030' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_vornr_range-returned_count
      exp = 2 ).
    DATA(ls_vornr_lower) = lo_cut->read_confirmations_bulk(
      it_production_orders     = VALUE #( ( '0000000002' ) )
      iv_operation_number_from = '0030' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_vornr_lower-returned_count
      exp = 1 ).
    DATA(ls_vornr_upper) = lo_cut->read_confirmations_bulk(
      it_production_orders   = VALUE #( ( '0000000002' ) )
      iv_operation_number_to = '0010' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_vornr_upper-returned_count
      exp = 1 ).
    DATA(ls_vornr_intersection) = lo_cut->read_confirmations_bulk(
      it_production_orders     = VALUE #( ( '0000000002' ) )
      iv_operation_number      = '0030'
      iv_operation_number_from = '0020'
      iv_operation_number_to   = '0030' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_vornr_intersection-returned_count
      exp = 1 ).

    lo_repository->order_confirmations = VALUE #(
      ( production_order     = '0000000002'
        operation_sequence   = '000000'
        confirmation         = '0000000031'
        confirmation_counter = '00000001' )
      ( production_order     = '0000000002'
        operation_sequence   = '000001'
        confirmation         = '0000000032'
        confirmation_counter = '00000001' )
      ( production_order     = '0000000002'
        operation_sequence   = '000002'
        confirmation         = '0000000033'
        confirmation_counter = '00000001' ) ).
    DATA(ls_sequence_range) = lo_cut->read_confirmations_bulk(
      it_production_orders       = VALUE #( ( '0000000002' ) )
      iv_operation_sequence_from = '000001'
      iv_operation_sequence_to   = '000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_sequence_range-returned_count
      exp = 2 ).
    DATA(ls_sequence_lower) = lo_cut->read_confirmations_bulk(
      it_production_orders       = VALUE #( ( '0000000002' ) )
      iv_operation_sequence_from = '000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_sequence_lower-returned_count
      exp = 1 ).
    DATA(ls_sequence_upper) = lo_cut->read_confirmations_bulk(
      it_production_orders     = VALUE #( ( '0000000002' ) )
      iv_operation_sequence_to = '000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_sequence_upper-returned_count
      exp = 2 ).
    DATA(ls_sequence_intersection) =
      lo_cut->read_confirmations_bulk(
        it_production_orders         = VALUE #( ( '0000000002' ) )
        iv_filter_operation_sequence = abap_true
        iv_operation_sequence        = '000001'
        iv_operation_sequence_from   = '000000'
        iv_operation_sequence_to     = '000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_sequence_intersection-returned_count
      exp = 1 ).

    lo_repository->order_confirmations = VALUE #(
      ( production_order     = '0000000002'
        operation_counter    = '00000001'
        confirmation         = '0000000041'
        confirmation_counter = '00000001' )
      ( production_order     = '0000000002'
        operation_counter    = '00000002'
        confirmation         = '0000000042'
        confirmation_counter = '00000001' )
      ( production_order     = '0000000002'
        operation_counter    = '00000003'
        confirmation         = '0000000043'
        confirmation_counter = '00000001' )
      ( production_order     = '0000000002'
        operation_counter    = '00000004'
        confirmation         = '0000000044'
        confirmation_counter = '00000001' ) ).
    DATA(ls_counter_range) = lo_cut->read_confirmations_bulk(
      it_production_orders      = VALUE #( ( '0000000002' ) )
      iv_operation_counter_from = '00000002'
      iv_operation_counter_to   = '00000003' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_counter_range-returned_count
      exp = 2 ).
    DATA(ls_counter_lower) = lo_cut->read_confirmations_bulk(
      it_production_orders      = VALUE #( ( '0000000002' ) )
      iv_operation_counter_from = '00000004' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_counter_lower-returned_count
      exp = 1 ).
    DATA(ls_counter_upper) = lo_cut->read_confirmations_bulk(
      it_production_orders    = VALUE #( ( '0000000002' ) )
      iv_operation_counter_to = '00000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_counter_upper-returned_count
      exp = 1 ).
    DATA(ls_counter_intersection) =
      lo_cut->read_confirmations_bulk(
        it_production_orders      = VALUE #( ( '0000000002' ) )
        iv_operation_counter      = '00000003'
        iv_operation_counter_from = '00000002'
        iv_operation_counter_to   = '00000004' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_counter_intersection-returned_count
      exp = 1 ).
  ENDMETHOD.

  METHOD validates_confirmation_reads.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_confirmations_bulk(
          it_production_orders = VALUE #(
            ( '0000000001' )
            ( '0000000001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_confirmations_bulk(
          it_production_orders     = VALUE #( ( '0000000001' ) )
          iv_operation_number_from = '0030'
          iv_operation_number_to   = '0020' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_confirmations_bulk(
          it_production_orders       = VALUE #( ( '0000000001' ) )
          iv_operation_sequence_from = '000002'
          iv_operation_sequence_to   = '000001' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_confirmations_bulk(
          it_production_orders      = VALUE #( ( '0000000001' ) )
          iv_operation_counter_from = '00000004'
          iv_operation_counter_to   = '00000003' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_confirmations_bulk(
          it_production_orders        = VALUE #( ( '0000000001' ) )
          iv_operation_number         = '0020'
          iv_suboperation_number_from = '0002'
          iv_suboperation_number_to   = '0001' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_confirmations_bulk(
          it_production_orders        = VALUE #( ( '0000000001' ) )
          iv_suboperation_number_from = '0001' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_confirmations_bulk(
          it_production_orders         = VALUE #( ( '0000000001' ) )
          iv_execution_start_date_from = '20261011'
          iv_execution_start_date_to   = '20261010' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_confirmations_bulk(
          it_production_orders          = VALUE #( ( '0000000001' ) )
          iv_filter_exec_finish_time    = abap_true
          iv_execution_finish_time_from = '120000'
          iv_execution_finish_time_to   = '080000' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_read_calls
      exp = 0 ).

    lo_repository->order_confirmations = VALUE #(
      ( production_order     = '0000000002'
        confirmation         = '0000000001'
        confirmation_counter = '00000001' ) ).
    CLEAR lv_raised.
    TRY.
        lo_cut->read_confirmations_bulk(
          it_production_orders = VALUE #( ( '0000000001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_read_calls
      exp = 1 ).

    lo_repository->order_confirmations = VALUE #(
      ( production_order     = '0000000001'
        confirmation         = '0000000001'
        confirmation_counter = '00000001' )
      ( production_order     = '0000000001'
        confirmation         = '0000000001'
        confirmation_counter = '00000001' ) ).
    CLEAR lv_raised.
    TRY.
        lo_cut->read_confirmations_bulk(
          it_production_orders = VALUE #( ( '0000000001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    lo_repository->use_confirmation_override = abap_true.
    lo_repository->confirmation_override = VALUE #(
      ( production_order       = '0000000001'
        operation_number       = '0020'
        operation_suboperation = '0001'
        confirmation           = '0000000001'
        confirmation_counter   = '00000001' ) ).
    CLEAR lv_raised.
    TRY.
        lo_cut->read_confirmations_bulk(
          it_production_orders        = VALUE #( ( '0000000001' ) )
          iv_operation_number         = '0020'
          iv_suboperation_number_from = '0002'
          iv_suboperation_number_to   = '0003' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    lo_repository->confirmation_override = VALUE #(
      ( production_order     = '0000000001'
        operation_number     = '0010'
        confirmation         = '0000000001'
        confirmation_counter = '00000001' ) ).
    CLEAR lv_raised.
    TRY.
        lo_cut->read_confirmations_bulk(
          it_production_orders     = VALUE #( ( '0000000001' ) )
          iv_operation_number_from = '0020'
          iv_operation_number_to   = '0030' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    lo_repository->confirmation_override = VALUE #(
      ( production_order     = '0000000001'
        operation_sequence   = '000001'
        confirmation         = '0000000001'
        confirmation_counter = '00000001' ) ).
    CLEAR lv_raised.
    TRY.
        lo_cut->read_confirmations_bulk(
          it_production_orders       = VALUE #( ( '0000000001' ) )
          iv_operation_sequence_from = '000002' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    lo_repository->confirmation_override = VALUE #(
      ( production_order     = '0000000001'
        operation_counter    = '00000002'
        confirmation         = '0000000001'
        confirmation_counter = '00000001' ) ).
    CLEAR lv_raised.
    TRY.
        lo_cut->read_confirmations_bulk(
          it_production_orders      = VALUE #( ( '0000000001' ) )
          iv_operation_counter_from = '00000003' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD filters_conf_audit.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order     = '0000000001'
        confirmation         = '0000000001'
        confirmation_counter = '00000001'
        posting_date         = '20261001'
        entered_by           = 'ALICE'
        changed_by           = 'BOB'
        last_change_date     = '20261004' )
      ( production_order     = '0000000001'
        confirmation         = '0000000002'
        confirmation_counter = '00000001'
        posting_date         = '20261002'
        entered_by           = 'ALICE'
        last_change_date     = '20261005' )
      ( production_order     = '0000000001'
        confirmation         = '0000000003'
        confirmation_counter = '00000001'
        posting_date         = '20261003'
        entered_by           = 'CAROL'
        changed_by           = 'BOB'
        last_change_date     = '20261004' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_confirmations_bulk(
      it_production_orders     = VALUE #( ( '0000000001' ) )
      iv_entered_by            = 'ALICE'
      iv_changed_by            = 'BOB'
      iv_last_change_date_from = '20261004'
      iv_last_change_date_to   = '20261004' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-returned_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-confirmations[ 1 ]-confirmation
      exp = '0000000001' ).

    ls_result = lo_cut->read_confirmations_bulk(
      it_production_orders   = VALUE #( ( '0000000001' ) )
      iv_entered_by          = 'ALICE'
      iv_filter_changed_by   = abap_true
      iv_last_change_date_to = '20261005' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-returned_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-confirmations[ 1 ]-confirmation
      exp = '0000000002' ).

    DATA lv_raised TYPE abap_bool.
    TRY.
        lo_cut->read_confirmations_bulk(
          it_production_orders     = VALUE #( ( '0000000001' ) )
          iv_last_change_date_from = '20260230' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_read_calls
      exp = 2 ).
  ENDMETHOD.

  METHOD filters_conf_unit.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order     = '0000000001'
        confirmation         = '0000000001'
        confirmation_counter = '00000001'
        posting_date         = '20261003'
        quantity_unit        = 'EA' )
      ( production_order     = '0000000001'
        confirmation         = '0000000002'
        confirmation_counter = '00000001'
        posting_date         = '20261002'
        quantity_unit        = 'BOX' )
      ( production_order     = '0000000001'
        confirmation         = '0000000003'
        confirmation_counter = '00000001'
        posting_date         = '20261001' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_confirmations_bulk(
      it_production_orders = VALUE #( ( '0000000001' ) )
      iv_quantity_unit     = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-returned_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-confirmations[ 1 ]-quantity_unit
      exp = 'EA' ).

    ls_result = lo_cut->read_confirmations_bulk(
      it_production_orders    = VALUE #( ( '0000000001' ) )
      iv_filter_quantity_unit = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-returned_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 1 ]-confirmations[ 1 ]-quantity_unit ).

    DATA lv_raised TYPE abap_bool.
    TRY.
        lo_cut->read_confirmations_bulk(
          it_production_orders    = VALUE #( ( '0000000001' ) )
          iv_filter_quantity_unit = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_read_calls
      exp = 2 ).
  ENDMETHOD.

  METHOD filters_conf_time.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order     = '0000000001'
        confirmation         = '0000000001'
        confirmation_counter = '00000001'
        posting_date         = '20261003'
        entry_time           = '000000' )
      ( production_order     = '0000000001'
        confirmation         = '0000000002'
        confirmation_counter = '00000001'
        posting_date         = '20261002'
        entry_time           = '120000' )
      ( production_order     = '0000000001'
        confirmation         = '0000000003'
        confirmation_counter = '00000001'
        posting_date         = '20261001'
        entry_time           = '170000' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_confirmations_bulk(
      it_production_orders = VALUE #( ( '0000000001' ) )
      iv_filter_entry_time = abap_true
      iv_entry_time_from   = '000000'
      iv_entry_time_to     = '120000' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-returned_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-confirmations[ 1 ]-entry_time
      exp = '000000' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-confirmations[ 2 ]-entry_time
      exp = '120000' ).

    DATA lv_raised TYPE abap_bool.
    TRY.
        lo_cut->read_confirmations_bulk(
          it_production_orders = VALUE #( ( '0000000001' ) )
          iv_filter_entry_time = abap_true
          iv_entry_time_from   = '120000'
          iv_entry_time_to     = '080000' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_read_calls
      exp = 1 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_confirmations_bulk(
          it_production_orders = VALUE #( ( '0000000001' ) )
          iv_entry_time_from   = '080000' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_read_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD filters_conf_quality_ranges.
    DATA lv_raised TYPE abap_bool.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order     = '0000000001'
        confirmation         = '0000000001'
        confirmation_counter = '00000001'
        posting_date         = '20261001'
        quantity_unit        = 'EA'
        yield_quantity       = '0.000'
        rework_quantity      = '1.000'
        scrap_quantity       = '0.000' )
      ( production_order     = '0000000001'
        confirmation         = '0000000002'
        confirmation_counter = '00000001'
        posting_date         = '20261002'
        quantity_unit        = 'EA'
        yield_quantity       = '2.000'
        rework_quantity      = '3.000'
        scrap_quantity       = '4.000' )
      ( production_order     = '0000000001'
        confirmation         = '0000000003'
        confirmation_counter = '00000001'
        posting_date         = '20261003'
        quantity_unit        = 'EA'
        yield_quantity       = '1.000'
        rework_quantity      = '0.000'
        scrap_quantity       = '3.000' )
      ( production_order     = '0000000001'
        confirmation         = '0000000004'
        confirmation_counter = '00000001'
        posting_date         = '20261004'
        quantity_unit        = 'EA'
        yield_quantity       = '5.000'
        rework_quantity      = '5.000'
        scrap_quantity       = '6.000' )
      ( production_order     = '0000000001'
        confirmation         = '0000000005'
        confirmation_counter = '00000001'
        posting_date         = '20261005'
        quantity_unit        = 'BOX'
        yield_quantity       = '1.000'
        rework_quantity      = '1.000'
        scrap_quantity       = '1.000' )
      ( production_order     = '0000000001'
        confirmation         = '0000000006'
        confirmation_counter = '00000001'
        posting_date         = '20261006'
        yield_quantity       = '0.500'
        rework_quantity      = '0.500'
        scrap_quantity       = '0.500' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    TRY.
        lo_cut->read_confirmations_bulk(
          it_production_orders          = VALUE #( ( '0000000001' ) )
          iv_filter_yield_quantity_from = abap_true
          iv_yield_quantity_from        = '0.000' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_read_calls
      exp = 0 ).

    DATA(ls_result) = lo_cut->read_confirmations_bulk(
      it_production_orders           = VALUE #( ( '0000000001' ) )
      iv_quantity_unit               = 'EA'
      iv_filter_yield_quantity_from  = abap_true
      iv_yield_quantity_from         = '0.000'
      iv_filter_yield_quantity_to    = abap_true
      iv_yield_quantity_to           = '2.000'
      iv_filter_rework_quantity_from = abap_true
      iv_rework_quantity_from        = '0.000'
      iv_filter_rework_quantity_to   = abap_true
      iv_rework_quantity_to          = '3.000'
      iv_filter_scrap_quantity_from  = abap_true
      iv_scrap_quantity_from         = '0.000'
      iv_filter_scrap_quantity_to    = abap_true
      iv_scrap_quantity_to           = '4.000' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-returned_count
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-confirmations[ 1 ]-confirmation
      exp = '0000000003' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-confirmations[ 3 ]-yield_quantity
      exp = CONV afru-lmnga( '0.000' ) ).

    ls_result = lo_cut->read_confirmations_bulk(
      it_production_orders          = VALUE #( ( '0000000001' ) )
      iv_quantity_unit              = 'EA'
      iv_filter_yield_quantity_from = abap_true
      iv_yield_quantity_from        = '0.000'
      iv_filter_yield_quantity_to   = abap_true
      iv_yield_quantity_to          = '2.000'
      iv_positive_yield_only        = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-returned_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_true(
      xsdbool( ls_result-orders[ 1 ]-confirmations[ 1 ]-yield_quantity > 0 ) ).

    ls_result = lo_cut->read_confirmations_bulk(
      it_production_orders          = VALUE #( ( '0000000001' ) )
      iv_quantity_unit              = 'EA'
      iv_filter_yield_quantity_from = abap_true
      iv_yield_quantity_from        = '0.000'
      iv_filter_yield_quantity_to   = abap_true
      iv_yield_quantity_to          = '2.000'
      iv_positive_rework_only       = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-returned_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-confirmations[ 1 ]-confirmation
      exp = '0000000002' ).

    ls_result = lo_cut->read_confirmations_bulk(
      it_production_orders          = VALUE #( ( '0000000001' ) )
      iv_quantity_unit              = 'EA'
      iv_filter_yield_quantity_from = abap_true
      iv_yield_quantity_from        = '0.000'
      iv_filter_yield_quantity_to   = abap_true
      iv_yield_quantity_to          = '2.000'
      iv_positive_scrap_only        = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-returned_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-confirmations[ 1 ]-confirmation
      exp = '0000000003' ).

    ls_result = lo_cut->read_confirmations_bulk(
      it_production_orders          = VALUE #( ( '0000000001' ) )
      iv_filter_quantity_unit       = abap_true
      iv_filter_yield_quantity_from = abap_true
      iv_yield_quantity_from        = '0.000'
      iv_filter_yield_quantity_to   = abap_true
      iv_yield_quantity_to          = '1.000' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-returned_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-confirmations[ 1 ]-confirmation
      exp = '0000000006' ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 1 ]-confirmations[ 1 ]-quantity_unit ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_confirmations_bulk(
          it_production_orders          = VALUE #( ( '0000000001' ) )
          iv_quantity_unit              = 'EA'
          iv_filter_yield_quantity_from = abap_true
          iv_yield_quantity_from        = '3.000'
          iv_filter_yield_quantity_to   = abap_true
          iv_yield_quantity_to          = '2.000' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_read_calls
      exp = 5 ).
  ENDMETHOD.

  METHOD empty_confirmation_read.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_confirmations_bulk(
      it_production_orders = VALUE #( ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_initial( ls_result-orders ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-snapshot_timestamp ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD reads_order_operations.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_operations = VALUE #(
      ( production_order      = '0000000001'
        operation_counter     = '00000001'
        operation_sequence    = '000000'
        operation_number      = '0010'
        suboperation_number   = '0010'
        operation_description = 'Prepare'
        control_key           = 'PP02'
        resource_object_id    = '00000001' )
      ( production_order      = '0000000002'
        operation_counter     = '00000001'
        operation_sequence    = '000000'
        operation_number      = '0010'
        operation_description = 'Cut'
        control_key           = 'PP01'
        resource_object_id    = '00000002' )
      ( production_order      = '0000000002'
        operation_counter     = '00000002'
        operation_sequence    = '000001'
        operation_number      = '0020'
        operation_description = 'Assembly'
        control_key           = 'PP01'
        resource_object_id    = '00000003' )
      ( production_order      = '0000000002'
        operation_counter     = '00000003'
        operation_sequence    = '000001'
        operation_number      = '0030'
        operation_description = 'Inspect'
        control_key           = 'PP01' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_operations_bulk(
      it_production_orders = VALUE #(
        ( '0000000001' )
        ( '0000000002' )
        ( '0000000003' ) ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_not_initial(
      act = ls_result-snapshot_timestamp ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->operation_read_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->requested_operation_orders[ 2 ]
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-empty_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-production_order
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-operations[ 1 ]-operation_number
      exp = '0010' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-operations[ 1 ]-suboperation_number
      exp = '0010' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-operations[ 1 ]-operation_description
      exp = 'Prepare' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-operations[ 1 ]-control_key
      exp = 'PP02' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-operations[ 1 ]-resource_object_id
      exp = '00000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-orders[ 2 ]-operations )
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-operations[ 1 ]-operation_number
      exp = '0010' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-operations[ 2 ]-operation_number
      exp = '0020' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-operations[ 3 ]-operation_number
      exp = '0030' ).
    DATA(ls_range_result) = lo_cut->read_operations_bulk(
      it_production_orders     = VALUE #( ( '0000000002' ) )
      iv_operation_number_from = '0020'
      iv_operation_number_to   = '0030' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_range_result-orders[ 1 ]-operations )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_range_result-orders[ 1 ]-operations[ 1 ]-operation_number
      exp = '0020' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_range_result-orders[ 1 ]-operations[ 2 ]-operation_number
      exp = '0030' ).

    DATA(ls_sequence_range_result) = lo_cut->read_operations_bulk(
      it_production_orders       = VALUE #( ( '0000000002' ) )
      iv_operation_sequence_from = '000000'
      iv_operation_sequence_to   = '000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_sequence_range_result-orders[ 1 ]-operations )
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_sequence_range_result-orders[ 1 ]-operations[ 1 ]-operation_sequence
      exp = '000000' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_sequence_range_result-orders[ 1 ]-operations[ 3 ]-operation_sequence
      exp = '000001' ).
    DATA(ls_sequence_intersection) = lo_cut->read_operations_bulk(
      it_production_orders         = VALUE #( ( '0000000002' ) )
      iv_filter_operation_sequence = abap_true
      iv_operation_sequence        = '000001'
      iv_operation_sequence_from   = '000000'
      iv_operation_sequence_to     = '000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_sequence_intersection-orders[ 1 ]-operations )
      exp = 2 ).
    DATA(ls_sequence_from_only) = lo_cut->read_operations_bulk(
      it_production_orders       = VALUE #( ( '0000000002' ) )
      iv_operation_sequence_from = '000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_sequence_from_only-orders[ 1 ]-operations )
      exp = 2 ).
    DATA(ls_sequence_to_only) = lo_cut->read_operations_bulk(
      it_production_orders     = VALUE #( ( '0000000002' ) )
      iv_operation_sequence_to = '000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_sequence_to_only-orders[ 1 ]-operations )
      exp = 3 ).

    DATA(ls_counter_range_result) = lo_cut->read_operations_bulk(
      it_production_orders      = VALUE #( ( '0000000002' ) )
      iv_operation_counter_from = '00000002'
      iv_operation_counter_to   = '00000003' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_counter_range_result-orders[ 1 ]-operations )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_counter_range_result-orders[ 1 ]-operations[ 1 ]-operation_counter
      exp = '00000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_counter_range_result-orders[ 1 ]-operations[ 2 ]-operation_counter
      exp = '00000003' ).
    DATA(ls_counter_from_only) = lo_cut->read_operations_bulk(
      it_production_orders      = VALUE #( ( '0000000002' ) )
      iv_operation_counter_from = '00000003' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_counter_from_only-orders[ 1 ]-operations )
      exp = 1 ).
    DATA(ls_counter_to_only) = lo_cut->read_operations_bulk(
      it_production_orders    = VALUE #( ( '0000000002' ) )
      iv_operation_counter_to = '00000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_counter_to_only-orders[ 1 ]-operations )
      exp = 1 ).
    DATA(ls_exact_counter_range) = lo_cut->read_operations_bulk(
      it_production_orders      = VALUE #( ( '0000000002' ) )
      iv_operation_counter      = '00000003'
      iv_operation_counter_from = '00000002'
      iv_operation_counter_to   = '00000003' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_exact_counter_range-orders[ 1 ]-operations )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_exact_counter_range-orders[ 1 ]-operations[ 1 ]-operation_counter
      exp = '00000003' ).

    DATA(ls_from_only_result) = lo_cut->read_operations_bulk(
      it_production_orders     = VALUE #( ( '0000000002' ) )
      iv_operation_number_from = '0030' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_from_only_result-orders[ 1 ]-operations )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_from_only_result-orders[ 1 ]-operations[ 1 ]-operation_number
      exp = '0030' ).

    DATA(ls_to_only_result) = lo_cut->read_operations_bulk(
      it_production_orders   = VALUE #( ( '0000000002' ) )
      iv_operation_number_to = '0010' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_to_only_result-orders[ 1 ]-operations )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_to_only_result-orders[ 1 ]-operations[ 1 ]-operation_number
      exp = '0010' ).

    DATA(ls_exact_range_result) = lo_cut->read_operations_bulk(
      it_production_orders     = VALUE #( ( '0000000002' ) )
      iv_operation_number      = '0030'
      iv_operation_number_from = '0020'
      iv_operation_number_to   = '0030' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_exact_range_result-orders[ 1 ]-operations )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_exact_range_result-orders[ 1 ]-operations[ 1 ]-operation_number
      exp = '0030' ).

    DATA(ls_resource_result) = lo_cut->read_operations_bulk(
      it_production_orders  = VALUE #( ( '0000000002' ) )
      iv_resource_object_id = '00000003' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_resource_result-orders[ 1 ]-operations )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_resource_result-orders[ 1 ]-operations[ 1 ]-operation_number
      exp = '0020' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_resource_result-orders[ 1 ]-operations[ 1 ]-resource_object_id
      exp = '00000003' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->requested_op_resource_id
      exp = '00000003' ).

    DATA(ls_unassigned_result) = lo_cut->read_operations_bulk(
      it_production_orders         = VALUE #( ( '0000000002' ) )
      iv_filter_resource_object_id = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_unassigned_result-orders[ 1 ]-operations )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_unassigned_result-orders[ 1 ]-operations[ 1 ]-operation_number
      exp = '0030' ).
    cl_abap_unit_assert=>assert_initial(
      ls_unassigned_result-orders[ 1 ]-operations[ 1 ]-resource_object_id ).
    cl_abap_unit_assert=>assert_true(
      lo_repository->requested_op_resource_filter ).
    cl_abap_unit_assert=>assert_initial(
      lo_repository->requested_op_resource_id ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 3 ]-is_found ).

    lo_repository->order_operations = VALUE #(
      ( production_order    = '0000000002'
        operation_counter   = '00000001'
        operation_number    = '0010'
        suboperation_number = '0001' )
      ( production_order    = '0000000002'
        operation_counter   = '00000002'
        operation_number    = '0010'
        suboperation_number = '0002' )
      ( production_order    = '0000000002'
        operation_counter   = '00000003'
        operation_number    = '0010'
        suboperation_number = '0003' ) ).
    DATA(ls_suboperation_range) = lo_cut->read_operations_bulk(
      it_production_orders        = VALUE #( ( '0000000002' ) )
      iv_operation_number         = '0010'
      iv_suboperation_number_from = '0002'
      iv_suboperation_number_to   = '0003' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_suboperation_range-orders[ 1 ]-operations )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_suboperation_range-orders[ 1 ]-operations[ 1 ]-suboperation_number
      exp = '0002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_suboperation_range-orders[ 1 ]-operations[ 2 ]-suboperation_number
      exp = '0003' ).

    DATA(ls_suboperation_lower_only) = lo_cut->read_operations_bulk(
      it_production_orders        = VALUE #( ( '0000000002' ) )
      iv_operation_number         = '0010'
      iv_suboperation_number_from = '0003' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_suboperation_lower_only-orders[ 1 ]-operations )
      exp = 1 ).

    DATA(ls_suboperation_upper_only) = lo_cut->read_operations_bulk(
      it_production_orders      = VALUE #( ( '0000000002' ) )
      iv_operation_number       = '0010'
      iv_suboperation_number_to = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_suboperation_upper_only-orders[ 1 ]-operations )
      exp = 1 ).

    DATA(ls_suboperation_intersection) = lo_cut->read_operations_bulk(
      it_production_orders        = VALUE #( ( '0000000002' ) )
      iv_operation_number         = '0010'
      iv_suboperation_number      = '0003'
      iv_suboperation_number_from = '0002'
      iv_suboperation_number_to   = '0003' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_suboperation_intersection-orders[ 1 ]-operations )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_suboperation_intersection-orders[ 1 ]-operations[ 1 ]-suboperation_number
      exp = '0003' ).
  ENDMETHOD.

  METHOD filters_ops_by_work_center.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_operations = VALUE #(
      ( production_order  = '0000000001'
        operation_counter = '00000001'
        operation_number  = '0010'
        work_center       = 'WC-01'
        work_center_plant = '1000' )
      ( production_order  = '0000000001'
        operation_counter = '00000002'
        operation_number  = '0020'
        work_center       = 'WC-01'
        work_center_plant = '1000' )
      ( production_order  = '0000000001'
        operation_counter = '00000003'
        operation_number  = '0030'
        work_center       = 'WC-02'
        work_center_plant = '2000' )
      ( production_order  = '0000000001'
        operation_counter = '00000004'
        operation_number  = '0040' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_center_result) = lo_cut->read_operations_bulk(
      it_production_orders = VALUE #( ( '0000000001' ) )
      iv_work_center       = 'WC-02'
      iv_maximum_results   = 1 ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_center_result-total_operation_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'WC-02'
      act = ls_center_result-orders[ 1 ]-operations[ 1 ]-work_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = ls_center_result-orders[ 1 ]-operations[ 1 ]-work_center_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_center_result-work_center_summaries ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'WC-02'
      act = ls_center_result-work_center_summaries[ 1 ]-work_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = ls_center_result-work_center_summaries[ 1 ]-work_center_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_center_result-work_center_summaries[ 1 ]-operation_count ).

    DATA(ls_blank_center_result) = lo_cut->read_operations_bulk(
      it_production_orders  = VALUE #( ( '0000000001' ) )
      iv_filter_work_center = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_blank_center_result-total_operation_count ).
    cl_abap_unit_assert=>assert_initial(
      ls_blank_center_result-orders[ 1 ]-operations[ 1 ]-work_center ).
    cl_abap_unit_assert=>assert_initial(
      ls_blank_center_result-work_center_summaries[ 1 ]-work_center ).

    DATA(ls_page_summary_result) = lo_cut->read_operations_bulk(
      it_production_orders = VALUE #( ( '0000000001' ) )
      iv_maximum_results   = 2 ).
    cl_abap_unit_assert=>assert_true(
      ls_page_summary_result-is_truncated ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_page_summary_result-total_operation_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_page_summary_result-work_center_summaries ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_page_summary_result-work_center_summaries[ 1 ]-operation_count ).

    DATA(ls_plant_result) = lo_cut->read_operations_bulk(
      it_production_orders = VALUE #( ( '0000000001' ) )
      iv_work_center_plant = '1000' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = ls_plant_result-orders[ 1 ]-operations[ 1 ]-work_center_plant ).

    DATA(ls_blank_plant_result) = lo_cut->read_operations_bulk(
      it_production_orders        = VALUE #( ( '0000000001' ) )
      iv_filter_work_center_plant = abap_true ).
    cl_abap_unit_assert=>assert_initial(
      ls_blank_plant_result-orders[ 1 ]-operations[ 1 ]-work_center_plant ).

    DATA lv_raised TYPE abap_bool.
    TRY.
        lo_cut->read_operations_bulk(
          it_production_orders  = VALUE #( ( '0000000001' ) )
          iv_filter_work_center = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.
    TRY.
        lo_cut->read_operations_bulk(
          it_production_orders        = VALUE #( ( '0000000001' ) )
          iv_filter_work_center_plant = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = lo_repository->operation_read_calls ).
  ENDMETHOD.

  METHOD validates_operation_reads.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.
    DATA(lt_duplicate_orders) = VALUE zif_prod_order_read_repo=>ty_order_numbers(
      ( '0000000001' ) ).
    APPEND '0000000001' TO lt_duplicate_orders.

    TRY.
        lo_cut->read_operations_bulk(
          it_production_orders = lt_duplicate_orders ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->operation_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_operations_bulk(
          it_production_orders     = VALUE #( ( '0000000001' ) )
          iv_operation_number_from = '0020'
          iv_operation_number_to   = '0010' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->operation_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_operations_bulk(
          it_production_orders      = VALUE #( ( '0000000001' ) )
          iv_operation_counter_from = '00000002'
          iv_operation_counter_to   = '00000001' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->operation_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_operations_bulk(
          it_production_orders       = VALUE #( ( '0000000001' ) )
          iv_operation_sequence_from = '000002'
          iv_operation_sequence_to   = '000001' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->operation_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_operations_bulk(
          it_production_orders        = VALUE #( ( '0000000001' ) )
          iv_operation_number         = '0010'
          iv_suboperation_number_from = '0002'
          iv_suboperation_number_to   = '0001' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->operation_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_operations_bulk(
          it_production_orders        = VALUE #( ( '0000000001' ) )
          iv_suboperation_number_from = '0001' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->operation_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_operations_bulk(
          it_production_orders         = VALUE #( ( '0000000001' ) )
          iv_filter_resource_object_id = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->operation_read_calls
      exp = 0 ).

    lo_repository->use_operation_override = abap_true.
    lo_repository->operation_override = VALUE #(
      ( production_order  = '0000000002'
        operation_counter = '00000001'
        operation_number  = '0010' ) ).
    CLEAR lv_raised.
    TRY.
        lo_cut->read_operations_bulk(
          it_production_orders = VALUE #( ( '0000000001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    lo_repository->use_operation_override = abap_false.
    lo_repository->order_operations = VALUE #(
      ( production_order  = '0000000001'
        operation_counter = '00000001'
        operation_number  = '0010' )
      ( production_order  = '0000000001'
        operation_counter = '00000001'
        operation_number  = '0020' ) ).
    CLEAR lv_raised.
    TRY.
        lo_cut->read_operations_bulk(
          it_production_orders = VALUE #( ( '0000000001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    lo_repository->use_operation_override = abap_true.
    lo_repository->operation_override = VALUE #(
      ( production_order   = '0000000001'
        operation_counter  = '00000001'
        operation_number   = '0010'
        resource_object_id = '00000001' ) ).
    CLEAR lv_raised.
    TRY.
        lo_cut->read_operations_bulk(
          it_production_orders  = VALUE #( ( '0000000001' ) )
          iv_resource_object_id = '00000002' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    lo_repository->operation_override = VALUE #(
      ( production_order   = '0000000001'
        operation_counter  = '00000001'
        operation_number   = '0010'
        resource_object_id = '00000002' ) ).
    CLEAR lv_raised.
    TRY.
        lo_cut->read_operations_bulk(
          it_production_orders     = VALUE #( ( '0000000001' ) )
          iv_resource_object_id    = '00000002'
          iv_operation_number_from = '0020'
          iv_operation_number_to   = '0030' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_operations_bulk(
          it_production_orders      = VALUE #( ( '0000000001' ) )
          iv_resource_object_id     = '00000002'
          iv_operation_counter_from = '00000002'
          iv_operation_counter_to   = '00000003' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_operations_bulk(
          it_production_orders       = VALUE #( ( '0000000001' ) )
          iv_resource_object_id      = '00000002'
          iv_operation_sequence_from = '000001'
          iv_operation_sequence_to   = '000002' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    lo_repository->operation_override = VALUE #(
      ( production_order    = '0000000001'
        operation_counter   = '00000001'
        operation_number    = '0010'
        suboperation_number = '0001'
        resource_object_id  = '00000002' ) ).
    CLEAR lv_raised.
    TRY.
        lo_cut->read_operations_bulk(
          it_production_orders        = VALUE #( ( '0000000001' ) )
          iv_operation_number         = '0010'
          iv_suboperation_number_from = '0002'
          iv_suboperation_number_to   = '0003' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD empty_operation_read.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_operations_bulk(
      it_production_orders = VALUE #( ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_initial( ls_result-orders ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-snapshot_timestamp ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->operation_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD filters_finish_window_category.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order          = '0000000001'
        production_item           = '0001'
        order_category            = '10'
        material                  = 'MAT-1'
        plant                     = '1000'
        basic_finish_date         = '20261110'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '4.000'
        received_quantity         = '0.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 )
      ( production_order          = '0000000002'
        production_item           = '0001'
        order_category            = '40'
        material                  = 'MAT-1'
        plant                     = '1000'
        basic_finish_date         = '20261110'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '5.000'
        received_quantity         = '0.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material         = 'MAT-1'
        plant            = '1000'
        finish_date_from = '20261101'
        finish_date_to   = '20261130'
        order_category   = '40'
        maximum_results  = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->requested_selection-order_category
      exp = '40' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-production_order
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-items[ 1 ]-order_item-order_category
      exp = '40' ).
  ENDMETHOD.

  METHOD rejects_bad_finish_category.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material         = 'MAT-1'
            plant            = '1000'
            finish_date_from = '20261101'
            finish_date_to   = '20261130'
            order_category   = '99'
            maximum_results  = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->finish_window_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD filters_finish_start_window.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order          = '0000000001'
        production_item           = '0001'
        order_category            = '10'
        material                  = 'MAT-1'
        plant                     = '1000'
        basic_start_date          = '20261105'
        basic_finish_date         = '20261125'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '4.000'
        received_quantity         = '0.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 )
      ( production_order          = '0000000002'
        production_item           = '0001'
        order_category            = '40'
        material                  = 'MAT-1'
        plant                     = '1000'
        basic_start_date          = '20261115'
        basic_finish_date         = '20261125'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '5.000'
        received_quantity         = '0.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material              = 'MAT-1'
        plant                 = '1000'
        basic_start_date_from = '20261110'
        basic_start_date_to   = '20261120'
        finish_date_from      = '20261101'
        finish_date_to        = '20261130'
        maximum_results       = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->requested_selection-basic_start_date_from
      exp = '20261110' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-production_order
      exp = '0000000002' ).
  ENDMETHOD.

  METHOD rejects_partial_start_window.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material              = 'MAT-1'
            plant                 = '1000'
            basic_start_date_from = '20261110'
            finish_date_from      = '20261101'
            finish_date_to        = '20261130'
            maximum_results       = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->finish_window_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_bad_start_finish_key.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( production_order  = '0000000001'
        basic_start_date  = '20261105'
        basic_finish_date = '20261125' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material              = 'MAT-1'
            plant                 = '1000'
            basic_start_date_from = '20261110'
            basic_start_date_to   = '20261120'
            finish_date_from      = '20261101'
            finish_date_to        = '20261130'
            maximum_results       = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->finish_window_read_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD searches_empty_finish_window.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material         = 'MAT-MISSING'
        plant            = '1000'
        finish_date_from = '20261101'
        finish_date_to   = '20261130'
        maximum_results  = 1 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_initial( ls_result-orders ).
    cl_abap_unit_assert=>assert_not_initial(
      act = ls_result-snapshot_timestamp ).
    cl_abap_unit_assert=>assert_not_initial(
      act = ls_result-key_selection_timestamp ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->finish_window_read_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD searches_order_finish_window.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order          = '0000000001'
        production_item           = '0001'
        order_category            = '10'
        material                  = 'MAT-1'
        plant                     = '1000'
        basic_finish_date         = '20261110'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '10.000'
        received_quantity         = '3.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 )
      ( production_order          = '0000000001'
        production_item           = '0002'
        order_category            = '10'
        material                  = 'MAT-OTHER'
        plant                     = '1000'
        basic_finish_date         = '20261110'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '2.000'
        received_quantity         = '0.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 )
      ( production_order          = '0000000001'
        production_item           = '0003'
        order_category            = '10'
        material                  = 'MAT-1'
        plant                     = '1000'
        basic_finish_date         = '20261110'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '4.000'
        received_quantity         = '0.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 )
      ( production_order          = '0000000002'
        production_item           = '0001'
        order_category            = '40'
        material                  = 'MAT-1'
        plant                     = '1000'
        basic_finish_date         = '20261110'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '5.000'
        received_quantity         = '0.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 )
      ( production_order          = '0000000003'
        production_item           = '0001'
        order_category            = '10'
        material                  = 'MAT-1'
        plant                     = '1000'
        basic_finish_date         = '20261112'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '6.000'
        received_quantity         = '0.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 )
      ( production_order          = '0000000004'
        production_item           = '0001'
        order_category            = '99'
        material                  = 'MAT-1'
        plant                     = '1000'
        basic_finish_date         = '20261101'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '7.000'
        received_quantity         = '0.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 ) ).
    lo_repository->order_statuses = VALUE #(
      ( production_order  = '0000000001'
        status_code       = 'I0002'
        status_short_name = 'REL'
        status_name       = 'Released' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material         = 'MAT-1'
        plant            = '1000'
        finish_date_from = '20261101'
        finish_date_to   = '20261130'
        maximum_results  = 1 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_not_initial(
      act = ls_result-snapshot_timestamp ).
    cl_abap_unit_assert=>assert_not_initial(
      act = ls_result-key_selection_timestamp ).
    cl_abap_unit_assert=>assert_true( ls_result-is_truncated ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-production_order
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-orders[ 1 ]-items )
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-conversion_succeeded_count
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-conversion_failed_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-conversion_succeeded_count
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-conversion_failed_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 1 ]-items[ 1 ]-matches_finish_selection ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-items[ 2 ]-matches_finish_selection ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 1 ]-items[ 3 ]-matches_finish_selection ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-finish_window_match_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-finish_match_conv_ok_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-finish_match_conv_fail_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-matching_conv_ok_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-matching_conv_fail_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-receipt_progress_counts-total_item_count
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-receipt_progress_counts-not_started_item_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-receipt_progress_counts-partial_item_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-receipt_progress_counts-not_started_pct
      exp = CONV decfloat34( '66.67' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-receipt_progress_counts-not_started_item_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-receipt_progress_counts-partial_item_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-receipt_progress_counts-complete_item_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-receipt_progress_counts-over_received_item_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-receipt_progress_counts-invalid_item_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-receipt_progress_counts-not_started_pct
      exp = CONV decfloat34( '66.67' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-receipt_progress_counts-partial_pct
      exp = CONV decfloat34( '33.33' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-receipt_progress_counts-total_item_count
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-finish_match_progress_counts-not_started_item_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-finish_match_progress_counts-partial_item_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-finish_match_progress_counts-complete_item_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-finish_match_progress_counts-over_received_item_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-finish_match_progress_counts-invalid_item_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-finish_match_progress_counts-not_started_pct
      exp = CONV decfloat34( '50.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-finish_match_progress_counts-partial_pct
      exp = CONV decfloat34( '50.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-finish_match_progress_counts-total_item_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-matching_progress_counts-not_started_item_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-matching_progress_counts-partial_item_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-matching_progress_counts-complete_item_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-matching_progress_counts-over_received_item_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-matching_progress_counts-invalid_item_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-matching_progress_counts-not_started_pct
      exp = CONV decfloat34( '50.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-matching_progress_counts-partial_pct
      exp = CONV decfloat34( '50.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-matching_progress_counts-total_item_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-items[ 1 ]-open_quantity_base
      exp = CONV decfloat34( '7.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-items[ 1 ]-open_quantity_order_unit
      exp = CONV decfloat34( '7.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-items[ 1 ]-over_receipt_qty_order_unit
      exp = CONV decfloat34( 0 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-items[ 1 ]-received_pct_of_order_qty
      exp = CONV decfloat34( '30.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-items[ 1 ]-open_pct_of_order_qty
      exp = CONV decfloat34( '70.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-items[ 1 ]-receipt_progress_status
      exp = zcl_prod_order_read_service=>c_receipt_progress_partial ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-statuses[ 1 ]-status_name
      exp = 'Released' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-next_finish_date
      exp = '20261110' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-next_production_order
      exp = '0000000001' ).

    DATA(ls_next_page) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        finish_date_from  = '20261101'
        finish_date_to    = '20261130'
        after_finish_date = ls_result-next_finish_date
        after_order       = ls_result-next_production_order
        maximum_results   = 1 ) ).

    cl_abap_unit_assert=>assert_true( ls_next_page-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_next_page-is_truncated ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_next_page-orders[ 1 ]-production_order
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_next_page-next_production_order
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->finish_window_read_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->requested_selection-after_order
      exp = '0000000001' ).
  ENDMETHOD.

  METHOD summarizes_finish_conv_scope.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order          = '0000000009'
        production_item           = '0001'
        order_category            = '10'
        material                  = 'MAT-1'
        plant                     = '1000'
        basic_finish_date         = '20261110'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '1.000'
        received_quantity         = '0.000'
        order_to_base_numerator   = 0
        order_to_base_denominator = 1 )
      ( production_order          = '0000000009'
        production_item           = '0002'
        order_category            = '10'
        material                  = 'MAT-OTHER'
        plant                     = '1000'
        basic_finish_date         = '20261110'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '1.000'
        received_quantity         = '0.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material         = 'MAT-1'
        plant            = '1000'
        finish_date_from = '20261101'
        finish_date_to   = '20261130'
        maximum_results  = 10 ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-conversion_succeeded_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-conversion_failed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-finish_match_conv_ok_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-finish_match_conv_fail_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-conversion_succeeded_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-conversion_failed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-matching_conv_ok_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-matching_conv_fail_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-finish_window_match_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 1 ]-items[ 1 ]-matches_finish_selection ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-items[ 2 ]-matches_finish_selection ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-items[ 1 ]-is_quantity_converted ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 1 ]-items[ 2 ]-is_quantity_converted ).
  ENDMETHOD.

  METHOD filters_finish_receipt_state.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order          = '0000000001'
        production_item           = '0001'
        order_category            = '10'
        material                  = 'MAT-1'
        plant                     = '1000'
        basic_finish_date         = '20261110'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '10.000'
        received_quantity         = '0.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 )
      ( production_order          = '0000000002'
        production_item           = '0001'
        order_category            = '10'
        material                  = 'MAT-1'
        plant                     = '1000'
        basic_finish_date         = '20261110'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '10.000'
        received_quantity         = '3.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 )
      ( production_order          = '0000000003'
        production_item           = '0001'
        order_category            = '10'
        material                  = 'MAT-1'
        plant                     = '1000'
        basic_finish_date         = '20261110'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '10.000'
        received_quantity         = '10.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 )
      ( production_order          = '0000000004'
        production_item           = '0001'
        order_category            = '10'
        material                  = 'MAT-1'
        plant                     = '1000'
        basic_finish_date         = '20261110'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '10.000'
        received_quantity         = '11.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 )
      ( production_order          = '0000000005'
        production_item           = '0001'
        order_category            = '10'
        material                  = 'MAT-1'
        plant                     = '1000'
        basic_finish_date         = '20261110'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '0.000'
        received_quantity         = '0.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 )
      ( production_order          = '0000000006'
        production_item           = '0001'
        order_category            = '10'
        material                  = 'MAT-1'
        plant                     = '1000'
        basic_finish_date         = '20261110'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '10.000'
        received_quantity         = '-1.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 )
      ( production_order          = '0000000007'
        production_item           = '0001'
        order_category            = '10'
        material                  = 'MAT-1'
        plant                     = '1000'
        basic_finish_date         = '20261110'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '10.000'
        received_quantity         = '10.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).
    DATA(ls_selection) = VALUE
      zif_prod_order_read_repo=>ty_order_selection(
        material                       = 'MAT-1'
        plant                          = '1000'
        finish_date_from               = '20261101'
        finish_date_to                 = '20261130'
        filter_receipt_progress_status = abap_true
        receipt_progress_status        =
          zcl_prod_order_read_service=>c_receipt_progress_complete
        maximum_results                = 1 ).

    DATA(ls_complete_page) = lo_cut->read_orders_by_finish_window(
      is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_true( ls_complete_page-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_complete_page-is_truncated ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_complete_page-orders[ 1 ]-production_order
      exp = '0000000003' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_complete_page-next_production_order
      exp = '0000000003' ).

    ls_selection-maximum_results = 10.
    ls_selection-receipt_progress_status =
      zcl_prod_order_read_service=>c_receipt_progress_not_started.
    DATA(ls_not_started) = lo_cut->read_orders_by_finish_window(
      is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_not_started-orders[ 1 ]-production_order
      exp = '0000000001' ).

    ls_selection-receipt_progress_status =
      zcl_prod_order_read_service=>c_receipt_progress_partial.
    DATA(ls_partial) = lo_cut->read_orders_by_finish_window(
      is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_partial-orders[ 1 ]-production_order
      exp = '0000000002' ).

    ls_selection-receipt_progress_status =
      zcl_prod_order_read_service=>c_receipt_over_received.
    DATA(ls_over_received) = lo_cut->read_orders_by_finish_window(
      is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_over_received-orders[ 1 ]-production_order
      exp = '0000000004' ).

    CLEAR ls_selection-receipt_progress_status.
    DATA(ls_invalid_quantity) = lo_cut->read_orders_by_finish_window(
      is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_invalid_quantity-orders )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_invalid_quantity-receipt_progress_counts-invalid_item_count
      exp = 2 ).

    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( production_order      = '0000000001'
        basic_finish_date     = '20261110'
        scheduled_start_date  = '00000000'
        scheduled_finish_date = '00000000' ) ).
    ls_selection-receipt_progress_status =
      zcl_prod_order_read_service=>c_receipt_progress_complete.
    ls_selection-maximum_results = 1.
    DATA(ls_status_drift) = lo_cut->read_orders_by_finish_window(
      is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_true(
      ls_status_drift-orders[ 1 ]-finish_filter_lost ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_status_drift-finish_filter_lost_count
      exp = 1 ).

    DATA(lo_invalid_repository) = NEW lcl_prod_order_read_repo( ).
    DATA(lo_invalid_cut) = NEW zcl_prod_order_read_service(
      lo_invalid_repository ).
    CLEAR ls_selection-filter_receipt_progress_status.
    ls_selection-receipt_progress_status =
      zcl_prod_order_read_service=>c_receipt_progress_partial.
    DATA lv_raised TYPE abap_bool.
    TRY.
        lo_invalid_cut->read_orders_by_finish_window(
          is_selection = ls_selection ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_invalid_repository->finish_window_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    ls_selection-filter_receipt_progress_status = abap_true.
    ls_selection-receipt_progress_status = 'X'.
    TRY.
        lo_invalid_cut->read_orders_by_finish_window(
          is_selection = ls_selection ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_invalid_repository->finish_window_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    ls_selection-filter_receipt_progress_status = 'Y'.
    CLEAR ls_selection-receipt_progress_status.
    TRY.
        lo_invalid_cut->read_orders_by_finish_window(
          is_selection = ls_selection ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_invalid_repository->finish_window_read_calls
      exp = 0 ).

    ls_selection = VALUE #(
      material                 = 'MAT-1'
      plant                    = '1000'
      finish_date_from         = '20261101'
      finish_date_to           = '20261130'
      filter_received_pct_from = abap_true
      received_pct_from        = '80.00'
      filter_received_pct_to   = abap_true
      received_pct_to          = '79.99'
      maximum_results          = 1 ).
    CLEAR lv_raised.
    TRY.
        lo_invalid_cut->read_orders_by_finish_window(
          is_selection = ls_selection ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_invalid_repository->finish_window_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    ls_selection-filter_received_pct_to = abap_false.
    CLEAR ls_selection-received_pct_to.
    ls_selection-filter_received_pct_from = abap_false.
    TRY.
        lo_invalid_cut->read_orders_by_finish_window(
          is_selection = ls_selection ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_invalid_repository->finish_window_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    CLEAR ls_selection-received_pct_from.
    ls_selection-filter_received_pct_from = 'Y'.
    TRY.
        lo_invalid_cut->read_orders_by_finish_window(
          is_selection = ls_selection ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_invalid_repository->finish_window_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    ls_selection-filter_received_pct_from = abap_true.
    ls_selection-received_pct_from = '-0.01'.
    TRY.
        lo_invalid_cut->read_orders_by_finish_window(
          is_selection = ls_selection ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_invalid_repository->finish_window_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD filters_finish_rcvd_qty.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order          = '0000000001'
        production_item           = '0001'
        order_category            = '10'
        material                  = 'MAT-1'
        plant                     = '1000'
        basic_finish_date         = '20261110'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '10.000'
        received_quantity         = '0.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 )
      ( production_order          = '0000000002'
        production_item           = '0001'
        order_category            = '10'
        material                  = 'MAT-1'
        plant                     = '1000'
        basic_finish_date         = '20261110'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '10.000'
        received_quantity         = '3.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 )
      ( production_order          = '0000000003'
        production_item           = '0001'
        order_category            = '10'
        material                  = 'MAT-1'
        plant                     = '1000'
        basic_finish_date         = '20261110'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '10.000'
        received_quantity         = '10.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).
    DATA(ls_selection) = VALUE
      zif_prod_order_read_repo=>ty_order_selection(
        material                 = 'MAT-1'
        plant                    = '1000'
        finish_date_from         = '20261101'
        finish_date_to           = '20261130'
        filter_received_qty_from = abap_true
        received_qty_from        = '10.000'
        maximum_results          = 1 ).

    DATA(ls_full_receipt_page) = lo_cut->read_orders_by_finish_window(
      is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_true( ls_full_receipt_page-is_successful ).
    cl_abap_unit_assert=>assert_false( ls_full_receipt_page-is_truncated ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_full_receipt_page-orders[ 1 ]-production_order
      exp = '0000000003' ).

    CLEAR ls_selection-filter_received_qty_from.
    CLEAR ls_selection-received_qty_from.
    ls_selection-filter_received_qty_to = abap_true.
    ls_selection-received_qty_to = 0.
    DATA(ls_zero_receipt_page) = lo_cut->read_orders_by_finish_window(
      is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_zero_receipt_page-orders[ 1 ]-production_order
      exp = '0000000001' ).

    ls_selection-filter_received_qty_from = abap_true.
    ls_selection-received_qty_from = '3.000'.
    ls_selection-received_qty_to = '3.000'.
    DATA(ls_exact_receipt_page) = lo_cut->read_orders_by_finish_window(
      is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_exact_receipt_page-orders )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_exact_receipt_page-orders[ 1 ]-production_order
      exp = '0000000002' ).

    CLEAR ls_selection-filter_received_qty_from.
    CLEAR ls_selection-received_qty_from.
    CLEAR ls_selection-filter_received_qty_to.
    CLEAR ls_selection-received_qty_to.
    ls_selection-filter_received_pct_from = abap_true.
    ls_selection-received_pct_from = '30.00'.
    ls_selection-filter_received_pct_to = abap_true.
    ls_selection-received_pct_to = '100.00'.
    DATA(ls_received_pct_page) = lo_cut->read_orders_by_finish_window(
      is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_true( ls_received_pct_page-is_truncated ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_received_pct_page-orders[ 1 ]-production_order
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_received_pct_page-orders[ 1 ]-items[ 1 ]-matches_finish_selection
      exp = abap_true ).

    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( production_order  = '0000000001'
        basic_finish_date = '20261110' ) ).
    CLEAR ls_selection-filter_received_pct_to.
    CLEAR ls_selection-received_pct_to.
    CLEAR ls_selection-filter_received_pct_from.
    CLEAR ls_selection-received_pct_from.
    ls_selection-filter_received_qty_from = abap_true.
    ls_selection-received_qty_from = '10.000'.
    CLEAR ls_selection-filter_received_qty_to.
    CLEAR ls_selection-received_qty_to.
    DATA(ls_received_quantity_drift) = lo_cut->read_orders_by_finish_window(
      is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_true(
      ls_received_quantity_drift-orders[ 1 ]-finish_filter_lost ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_received_quantity_drift-finish_filter_lost_count
      exp = 1 ).

    CLEAR ls_selection-filter_received_qty_from.
    CLEAR ls_selection-received_qty_from.
    ls_selection-filter_received_pct_from = abap_true.
    ls_selection-received_pct_from = '50.00'.
    DATA(ls_received_pct_drift) = lo_cut->read_orders_by_finish_window(
      is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_true(
      ls_received_pct_drift-orders[ 1 ]-finish_filter_lost ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_received_pct_drift-finish_filter_lost_count
      exp = 1 ).
    CLEAR ls_selection-filter_received_pct_from.
    CLEAR ls_selection-received_pct_from.

    DATA(lo_invalid_repository) = NEW lcl_prod_order_read_repo( ).
    DATA(lo_invalid_cut) = NEW zcl_prod_order_read_service(
      lo_invalid_repository ).
    DATA lv_raised TYPE abap_bool.
    CLEAR ls_selection-filter_received_qty_from.
    CLEAR ls_selection-received_qty_from.
    ls_selection-filter_received_qty_to = abap_false.
    ls_selection-received_qty_to = '1.000'.
    TRY.
        lo_invalid_cut->read_orders_by_finish_window(
          is_selection = ls_selection ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_invalid_repository->finish_window_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    ls_selection-filter_received_qty_to = abap_true.
    ls_selection-received_qty_to = '-1.000'.
    TRY.
        lo_invalid_cut->read_orders_by_finish_window(
          is_selection = ls_selection ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_invalid_repository->finish_window_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    ls_selection-filter_received_qty_from = abap_true.
    ls_selection-received_qty_from = '5.000'.
    ls_selection-received_qty_to = '4.000'.
    TRY.
        lo_invalid_cut->read_orders_by_finish_window(
          is_selection = ls_selection ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_invalid_repository->finish_window_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    CLEAR ls_selection-filter_received_qty_from.
    CLEAR ls_selection-received_qty_from.
    CLEAR ls_selection-received_qty_to.
    ls_selection-filter_received_qty_from = 'Y'.
    ls_selection-filter_received_qty_to = abap_false.
    TRY.
        lo_invalid_cut->read_orders_by_finish_window(
          is_selection = ls_selection ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_invalid_repository->finish_window_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD filters_active_status.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order          = '0000000001'
        production_item           = '0001'
        order_category            = '10'
        material                  = 'MAT-1'
        plant                     = '1000'
        basic_finish_date         = '20261110'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '5.000'
        received_quantity         = '0.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 )
      ( production_order          = '0000000002'
        production_item           = '0001'
        order_category            = '40'
        material                  = 'MAT-1'
        plant                     = '1000'
        basic_finish_date         = '20261111'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '7.000'
        received_quantity         = '0.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 ) ).
    lo_repository->order_statuses = VALUE #(
      ( production_order  = '0000000001'
        status_code       = 'I0002'
        status_short_name = 'REL'
        status_name       = 'Released' )
      ( production_order  = '0000000001'
        status_code       = 'I0001'
        status_short_name = 'CRTD'
        status_name       = 'Created' )
      ( production_order  = '0000000002'
        status_code       = 'I0001'
        status_short_name = 'CRTD'
        status_name       = 'Created' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material           = 'MAT-1'
        plant              = '1000'
        finish_date_from   = '20261101'
        finish_date_to     = '20261130'
        active_status_code = 'I0002'
        maximum_results    = 1 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_false( ls_result-is_truncated ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-production_order
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-orders[ 1 ]-statuses )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-statuses[ 1 ]-status_code
      exp = 'I0001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-statuses[ 2 ]-status_code
      exp = 'I0002' ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-status_filter_lost ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-status_filter_lost_count
      exp = 0 ).
  ENDMETHOD.

  METHOD reports_status_drift.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order          = '0000000001'
        production_item           = '0001'
        order_category            = '10'
        material                  = 'MAT-1'
        plant                     = '1000'
        basic_finish_date         = '20261110'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '5.000'
        received_quantity         = '0.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 ) ).
    lo_repository->finish_candidate_statuses = VALUE #(
      ( production_order = '0000000001'
        status_code      = 'I0002' ) ).
    lo_repository->order_statuses = VALUE #(
      ( production_order = '0000000001'
        status_code      = 'I0001' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material           = 'MAT-1'
        plant              = '1000'
        finish_date_from   = '20261101'
        finish_date_to     = '20261130'
        active_status_code = 'I0002'
        maximum_results    = 1 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 1 ]-status_filter_lost ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-status_filter_lost_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-statuses[ 1 ]-status_code
      exp = 'I0001' ).
  ENDMETHOD.

  METHOD reports_finish_scope_drift.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( production_order  = '0000000001'
        basic_finish_date = '20261110' )
      ( production_order  = '0000000002'
        basic_finish_date = '20261111' ) ).
    lo_repository->use_unfiltered_order_items = abap_true.
    lo_repository->order_items = VALUE #(
      ( production_order          = '0000000001'
        production_item           = '0001'
        order_category            = '10'
        material                  = 'MAT-2'
        plant                     = '1000'
        basic_finish_date         = '20261110'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '5.000'
        received_quantity         = '0.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 )
      ( production_order          = '0000000002'
        production_item           = '0001'
        order_category            = '10'
        material                  = 'MAT-1'
        plant                     = '1000'
        basic_finish_date         = '20261111'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '7.000'
        received_quantity         = '0.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material         = 'MAT-1'
        plant            = '1000'
        finish_date_from = '20261101'
        finish_date_to   = '20261130'
        maximum_results  = 2 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-items[ 1 ]-order_item-material
      exp = 'MAT-2' ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 1 ]-finish_filter_lost ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 2 ]-finish_filter_lost ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-finish_filter_lost_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-conversion_succeeded_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 1 ]-matching_conv_ok_count ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 1 ]-matching_conv_fail_count ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-matching_conv_ok_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-finish_match_conv_ok_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-finish_match_conv_fail_count
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_invalid_finish_keys.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( production_order  = '0000000001'
        basic_finish_date = '20261110' )
      ( production_order  = '0000000001'
        basic_finish_date = '20261110' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material         = 'MAT-1'
            plant            = '1000'
            finish_date_from = '20261101'
            finish_date_to   = '20261130'
            maximum_results  = 1 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->finish_window_read_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD reads_exact_finish_limit.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order          = '0000000001'
        production_item           = '0001'
        order_category            = '10'
        material                  = 'MAT-1'
        plant                     = '1000'
        basic_finish_date         = '20261110'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '5.000'
        received_quantity         = '0.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material         = 'MAT-1'
        plant            = '1000'
        finish_date_from = '20261101'
        finish_date_to   = '20261130'
        maximum_results  = 1 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_false( ls_result-is_truncated ).
    cl_abap_unit_assert=>assert_initial( ls_result-next_finish_date ).
    cl_abap_unit_assert=>assert_initial( ls_result-next_production_order ).
  ENDMETHOD.

  METHOD rejects_bad_finish_search.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material         = 'MAT-1'
            plant            = '1000'
            finish_date_from = '20260230'
            finish_date_to   = '20260331'
            maximum_results  = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->finish_window_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material          = 'MAT-1'
            plant             = '1000'
            finish_date_from  = '20260301'
            finish_date_to    = '20260331'
            after_finish_date = '20260315'
            maximum_results   = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->finish_window_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material         = 'MAT-1'
            plant            = '1000'
            finish_date_from = '20260301'
            finish_date_to   = '20260331'
            maximum_results  = 501 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->finish_window_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD searches_confirmation_window.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order = '0000000001'
        production_item  = '0001'
        order_category   = '10'
        material         = 'MAT-1'
        plant            = '1000' )
      ( production_order = '0000000002'
        production_item  = '0001'
        order_category   = '40'
        material         = 'MAT-1'
        plant            = '1000' )
      ( production_order = '0000000003'
        production_item  = '0001'
        order_category   = '99'
        material         = 'MAT-1'
        plant            = '1000' )
      ( production_order = '0000000004'
        production_item  = '0001'
        order_category   = '10'
        material         = 'MAT-OTHER'
        plant            = '1000' ) ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        operation_description = 'Mix ingredients'
        control_key           = 'PP01'
        confirmation          = '0000000001'
        confirmation_counter  = '00000001'
        posting_date          = '20261011'
        is_reversed           = abap_true )
      ( production_order     = '0000000001'
        operation_counter    = '00000001'
        order_category       = '10'
        confirmation         = '0000000002'
        confirmation_counter = '00000001'
        posting_date         = '20261011' )
      ( production_order     = '0000000001'
        operation_counter    = '00000001'
        order_category       = '10'
        confirmation         = '0000000002'
        confirmation_counter = '00000002'
        posting_date         = '20261011' )
      ( production_order     = '0000000002'
        order_category       = '40'
        confirmation         = '0000000003'
        confirmation_counter = '00000001'
        posting_date         = '20261011' )
      ( production_order     = '0000000003'
        order_category       = '99'
        confirmation         = '0000000004'
        confirmation_counter = '00000001'
        posting_date         = '20261011' )
      ( production_order     = '0000000004'
        order_category       = '10'
        confirmation         = '0000000005'
        confirmation_counter = '00000001'
        posting_date         = '20261011' )
      ( production_order     = '0000000001'
        confirmation         = '0000000006'
        confirmation_counter = '00000001'
        posting_date         = '20260930' ) ).    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        posting_date_from = '20261001'
        posting_date_to   = '20261031'
        maximum_results   = 2 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_truncated ).
    cl_abap_unit_assert=>assert_not_initial(
      act = ls_result-snapshot_timestamp ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-returned_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-confirmations[ 1 ]-confirmation
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_true(
      ls_result-confirmations[ 1 ]-is_reversed ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-confirmations[ 1 ]-operation_description
      exp = 'Mix ingredients' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-confirmations[ 1 ]-control_key
      exp = 'PP01' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-confirmations[ 1 ]-operation_counter
      exp = '00000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-next_posting_date
      exp = '20261011' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-next_production_order
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-next_confirmation
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-next_confirmation_counter
      exp = '00000001' ).

    DATA(ls_order_page) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        production_order  = '0000000001'
        posting_date_from = '20261001'
        posting_date_to   = '20261031'
        maximum_results   = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_order_page-returned_count
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_order_page-confirmations[ 1 ]-production_order
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_order_page-confirmations[ 3 ]-production_order
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->requested_conf_selection-production_order
      exp = '0000000001' ).

    DATA(ls_process_order_page) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        order_category    = '40'
        posting_date_from = '20261001'
        posting_date_to   = '20261031'
        maximum_results   = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_process_order_page-returned_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_process_order_page-confirmations[ 1 ]-order_category
      exp = '40' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_process_order_page-confirmations[ 1 ]-production_order
      exp = '0000000002' ).

    DATA(ls_internal_operation_page) =
      lo_cut->search_confirmations_by_window(
        is_selection = VALUE #(
          material          = 'MAT-1'
          plant             = '1000'
          production_order  = '0000000001'
          operation_counter = '00000001'
          posting_date_from = '20261001'
          posting_date_to   = '20261031'
          maximum_results   = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_internal_operation_page-returned_count
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_internal_operation_page-confirmations[ 1 ]-operation_counter
      exp = '00000001' ).

    DATA(ls_exact_confirmation_page) =
      lo_cut->search_confirmations_by_window(
        is_selection = VALUE #(
          material             = 'MAT-1'
          plant                = '1000'
          confirmation_number  = '0000000002'
          confirmation_counter = '00000002'
          posting_date_from    = '20261001'
          posting_date_to      = '20261031'
          maximum_results      = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_exact_confirmation_page-returned_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_exact_confirmation_page-confirmations[ 1 ]-confirmation_counter
      exp = '00000002' ).

    DATA(ls_next_page) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material                   = 'MAT-1'
        plant                      = '1000'
        posting_date_from          = '20261001'
        posting_date_to            = '20261031'
        after_posting_date         = ls_result-next_posting_date
        after_production_order     = ls_result-next_production_order
        after_confirmation         = ls_result-next_confirmation
        after_confirmation_counter = ls_result-next_confirmation_counter
        maximum_results            = 2 ) ).

    cl_abap_unit_assert=>assert_true( ls_next_page-is_successful ).
    cl_abap_unit_assert=>assert_false( ls_next_page-is_truncated ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_next_page-returned_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_next_page-confirmations[ 1 ]-confirmation_counter
      exp = '00000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_next_page-confirmations[ 2 ]-production_order
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_window_read_calls
      exp = 6 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->requested_conf_selection-after_confirmation
      exp = '0000000002' ).
  ENDMETHOD.

  METHOD filters_deleted_conf_orders.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order = '0000000001' production_item = '0001'
        material = 'MAT-DEL' plant = '1000' order_category = '10'
        order_deletion_indicator = 'X' )
      ( production_order = '0000000002' production_item = '0001'
        material = 'MAT-DEL' plant = '1000' order_category = '10'
        item_deletion_indicator = 'X' )
      ( production_order = '0000000003' production_item = '0001'
        material = 'MAT-DEL' plant = '1000' order_category = '10' ) ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order = '0000000001' confirmation = '0000000001'
        confirmation_counter = '00000001' posting_date = '20261011' )
      ( production_order = '0000000002' confirmation = '0000000002'
        confirmation_counter = '00000001' posting_date = '20261011' )
      ( production_order = '0000000003' confirmation = '0000000003'
        confirmation_counter = '00000001' posting_date = '20261011' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).
    DATA(ls_selection) = VALUE
      zif_prod_order_read_repo=>ty_confirmation_window_selection(
        material = 'MAT-DEL' plant = '1000'
        posting_date_from = '20261001' posting_date_to = '20261031'
        maximum_results = 10 ).

    DATA(ls_all_rows) = lo_cut->search_confirmations_by_window(
      is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = ls_all_rows-returned_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'X'
      act = ls_all_rows-confirmations[ 1 ]-order_deletion_indicator ).
    ls_selection-exclude_deleted = abap_true.
    DATA(ls_active_rows) = lo_cut->search_confirmations_by_window(
      is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_active_rows-returned_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000003'
      act = ls_active_rows-confirmations[ 1 ]-production_order ).
    cl_abap_unit_assert=>assert_true(
      lo_repository->requested_conf_selection-exclude_deleted ).

    DATA(lv_read_calls) = lo_repository->confirmation_window_read_calls.
    DATA(lv_raised) = abap_false.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material = 'MAT-DEL' plant = '1000'
            posting_date_from = '20261001'
            posting_date_to = '20261031' exclude_deleted = 'Y'
            maximum_results = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_read_calls
      act = lo_repository->confirmation_window_read_calls ).

    lo_repository->use_conf_window_override = abap_true.
    lo_repository->conf_window_override = VALUE #(
      ( production_order = '0000000001' order_category = '10'
        order_deletion_indicator = 'X' confirmation = '0000000001'
        confirmation_counter = '00000001' posting_date = '20261011' ) ).
    lv_raised = abap_false.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = ls_selection ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD reads_exact_confirmation_limit.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order = '0000000001'
        production_item  = '0001'
        order_category   = '10'
        material         = 'MAT-1'
        plant            = '1000' )
      ( production_order = '0000000002'
        production_item  = '0001'
        order_category   = '10'
        material         = 'MAT-1'
        plant            = '1000' ) ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order     = '0000000001'
        confirmation         = '0000000001'
        confirmation_counter = '00000001'
        posting_date         = '20261011' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        posting_date_from = '20261001'
        posting_date_to   = '20261031'
        maximum_results   = 1 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_false( ls_result-is_truncated ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-returned_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_initial( ls_result-next_posting_date ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-next_production_order ).
    cl_abap_unit_assert=>assert_initial( ls_result-next_confirmation ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-next_confirmation_counter ).
  ENDMETHOD.

  METHOD excludes_reversed_confirmation.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order = '0000000001'
        production_item  = '0001'
        order_category   = '10'
        material         = 'MAT-1'
        plant            = '1000' ) ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order     = '0000000001'
        confirmation         = '0000000001'
        confirmation_counter = '00000001'
        posting_date         = '20261010'
        is_reversed          = abap_true )
      ( production_order     = '0000000001'
        confirmation         = '0000000002'
        confirmation_counter = '00000001'
        posting_date         = '20261011' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        posting_date_from = '20261001'
        posting_date_to   = '20261031'
        exclude_reversed  = abap_true
        maximum_results   = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-returned_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-confirmations[ 1 ]-confirmation
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_false(
      ls_result-confirmations[ 1 ]-is_reversed ).
    cl_abap_unit_assert=>assert_true(
      lo_repository->requested_conf_selection-exclude_reversed ).

    ls_result = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        posting_date_from = '20261001'
        posting_date_to   = '20261031'
        reversed_only     = abap_true
        maximum_results   = 10 ) ).
    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-returned_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-confirmations[ 1 ]-confirmation
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_true(
      ls_result-confirmations[ 1 ]-is_reversed ).
    cl_abap_unit_assert=>assert_true(
      lo_repository->requested_conf_selection-reversed_only ).
  ENDMETHOD.

  METHOD filters_quality_quantities.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order = '0000000001'
        production_item  = '0001'
        order_category   = '10'
        material         = 'MAT-1'
        plant            = '1000' ) ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order     = '0000000001'
        operation_number     = '0010'
        confirmation         = '0000000001'
        confirmation_counter = '00000001'
        posting_date         = '20261010'
        quantity_unit        = 'EA'
        yield_quantity       = '1.000'
        rework_quantity      = '1.000' )
      ( production_order     = '0000000001'
        operation_number     = '0010'
        confirmation         = '0000000002'
        confirmation_counter = '00000001'
        posting_date         = '20261011'
        quantity_unit        = 'EA'
        scrap_quantity       = '2.000' )
      ( production_order     = '0000000001'
        operation_number     = '0010'
        confirmation         = '0000000003'
        confirmation_counter = '00000001'
        posting_date         = '20261012'
        quantity_unit        = 'EA'
        rework_quantity      = '0.500'
        yield_quantity       = '2.000'
        scrap_quantity       = '0.250' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_rework_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material             = 'MAT-1'
        plant                = '1000'
        posting_date_from    = '20261001'
        posting_date_to      = '20261031'
        positive_rework_only = abap_true
        maximum_results      = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_rework_result-returned_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_rework_result-confirmations[ 2 ]-confirmation
      exp = '0000000003' ).

    DATA(ls_scrap_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material            = 'MAT-1'
        plant               = '1000'
        posting_date_from   = '20261001'
        posting_date_to     = '20261031'
        positive_scrap_only = abap_true
        maximum_results     = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_scrap_result-returned_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_scrap_result-confirmations[ 1 ]-confirmation
      exp = '0000000002' ).

    DATA(ls_yield_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material            = 'MAT-1'
        plant               = '1000'
        posting_date_from   = '20261001'
        posting_date_to     = '20261031'
        positive_yield_only = abap_true
        maximum_results     = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_yield_result-returned_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_yield_result-confirmations[ 2 ]-confirmation
      exp = '0000000003' ).

    DATA(ls_rework_and_scrap_result) =
      lo_cut->search_confirmations_by_window(
        is_selection = VALUE #(
          material             = 'MAT-1'
          plant                = '1000'
          posting_date_from    = '20261001'
          posting_date_to      = '20261031'
          positive_rework_only = abap_true
          positive_scrap_only  = abap_true
          maximum_results      = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_rework_and_scrap_result-returned_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_rework_and_scrap_result-confirmations[ 1 ]-confirmation
      exp = '0000000003' ).
  ENDMETHOD.

  METHOD filters_conf_yield_range.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order = '0000000001'
        production_item  = '0001'
        order_category   = '10'
        material         = 'MAT-1'
        plant            = '1000' ) ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order     = '0000000001'
        confirmation         = '0000000001'
        confirmation_counter = '00000001'
        posting_date         = '20261010'
        resource_object_id   = space
        quantity_unit        = 'EA'
        yield_quantity       = '0.000'
        rework_quantity      = '1.000'
        scrap_quantity       = '2.000' )
      ( production_order     = '0000000001'
        confirmation         = '0000000002'
        confirmation_counter = '00000001'
        posting_date         = '20261011'
        resource_object_id   = '00000001'
        quantity_unit        = 'EA'
        yield_quantity       = '2.000'
        rework_quantity      = '3.000'
        scrap_quantity       = '4.000' )
      ( production_order     = '0000000001'
        confirmation         = '0000000003'
        confirmation_counter = '00000001'
        posting_date         = '20261012'
        resource_object_id   = '00000002'
        quantity_unit        = 'EA'
        yield_quantity       = '5.000'
        rework_quantity      = '5.000'
        scrap_quantity       = '6.000' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_range_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material                   = 'MAT-1'
        plant                      = '1000'
        quantity_unit              = 'EA'
        posting_date_from          = '20261001'
        posting_date_to            = '20261031'
        filter_yield_quantity_from = abap_true
        yield_quantity_from        = '0.000'
        filter_yield_quantity_to   = abap_true
        yield_quantity_to          = '2.000'
        maximum_results            = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_range_result-returned_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_range_result-confirmations[ 1 ]-yield_quantity
      exp = CONV afru-lmnga( '0.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_range_result-confirmations[ 2 ]-yield_quantity
      exp = CONV afru-lmnga( '2.000' ) ).
    cl_abap_unit_assert=>assert_true(
      lo_repository->requested_conf_selection-filter_yield_quantity_from ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->requested_conf_selection-yield_quantity_from
      exp = CONV afru-lmnga( '0.000' ) ).

    DATA(ls_resource_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material           = 'MAT-1'
        plant              = '1000'
        quantity_unit      = 'EA'
        resource_object_id = '00000002'
        posting_date_from  = '20261001'
        posting_date_to    = '20261031'
        maximum_results    = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_resource_result-returned_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_resource_result-confirmations[ 1 ]-confirmation
      exp = '0000000003' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_resource_result-confirmations[ 1 ]-resource_object_id
      exp = '00000002' ).

    DATA(ls_blank_resource_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material                  = 'MAT-1'
        plant                     = '1000'
        quantity_unit             = 'EA'
        filter_resource_object_id = abap_true
        posting_date_from         = '20261001'
        posting_date_to           = '20261031'
        maximum_results           = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_blank_resource_result-returned_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_blank_resource_result-confirmations[ 1 ]-confirmation
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_initial(
      ls_blank_resource_result-confirmations[ 1 ]-resource_object_id ).

    DATA(ls_lower_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material                   = 'MAT-1'
        plant                      = '1000'
        quantity_unit              = 'EA'
        posting_date_from          = '20261001'
        posting_date_to            = '20261031'
        filter_yield_quantity_from = abap_true
        yield_quantity_from        = '2.000'
        maximum_results            = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_lower_result-returned_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_lower_result-confirmations[ 2 ]-yield_quantity
      exp = CONV afru-lmnga( '5.000' ) ).

    DATA(ls_yield_page_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material                   = 'MAT-1'
        plant                      = '1000'
        quantity_unit              = 'EA'
        posting_date_from          = '20261001'
        posting_date_to            = '20261031'
        filter_yield_quantity_from = abap_true
        yield_quantity_from        = '2.000'
        maximum_results            = 1 ) ).
    cl_abap_unit_assert=>assert_true( ls_yield_page_result-is_truncated ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_yield_page_result-returned_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_yield_page_result-confirmations[ 1 ]-confirmation
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_yield_page_result-next_confirmation
      exp = '0000000002' ).

    DATA(ls_upper_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material                 = 'MAT-1'
        plant                    = '1000'
        quantity_unit            = 'EA'
        posting_date_from        = '20261001'
        posting_date_to          = '20261031'
        filter_yield_quantity_to = abap_true
        yield_quantity_to        = '2.000'
        maximum_results          = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_upper_result-returned_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_upper_result-confirmations[ 1 ]-yield_quantity
      exp = CONV afru-lmnga( '0.000' ) ).

    DATA(ls_rework_range_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material                    = 'MAT-1'
        plant                       = '1000'
        quantity_unit               = 'EA'
        posting_date_from           = '20261001'
        posting_date_to             = '20261031'
        filter_rework_quantity_from = abap_true
        rework_quantity_from        = '3.000'
        filter_rework_quantity_to   = abap_true
        rework_quantity_to          = '5.000'
        maximum_results             = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_rework_range_result-returned_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_rework_range_result-confirmations[ 1 ]-rework_quantity
      exp = CONV afru-rmnga( '3.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_rework_range_result-confirmations[ 2 ]-rework_quantity
      exp = CONV afru-rmnga( '5.000' ) ).

    DATA(ls_scrap_range_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material                   = 'MAT-1'
        plant                      = '1000'
        quantity_unit              = 'EA'
        posting_date_from          = '20261001'
        posting_date_to            = '20261031'
        filter_scrap_quantity_from = abap_true
        scrap_quantity_from        = '2.000'
        filter_scrap_quantity_to   = abap_true
        scrap_quantity_to          = '4.000'
        maximum_results            = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_scrap_range_result-returned_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_scrap_range_result-confirmations[ 2 ]-scrap_quantity
      exp = CONV afru-xmnga( '4.000' ) ).

    DATA(lv_read_calls) = lo_repository->confirmation_window_read_calls.
    DATA lv_raised TYPE abap_bool.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material                   = 'MAT-1'
            plant                      = '1000'
            quantity_unit              = 'EA'
            posting_date_from          = '20261001'
            posting_date_to            = '20261031'
            filter_yield_quantity_from = abap_true
            yield_quantity_from        = '5.000'
            filter_yield_quantity_to   = abap_true
            yield_quantity_to          = '2.000'
            maximum_results            = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_window_read_calls
      exp = lv_read_calls ).

    CLEAR lv_raised.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material                    = 'MAT-1'
            plant                       = '1000'
            quantity_unit               = 'EA'
            posting_date_from           = '20261001'
            posting_date_to             = '20261031'
            filter_rework_quantity_from = abap_true
            rework_quantity_from        = '5.000'
            filter_rework_quantity_to   = abap_true
            rework_quantity_to          = '3.000'
            maximum_results             = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_window_read_calls
      exp = lv_read_calls ).

    CLEAR lv_raised.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material                   = 'MAT-1'
            plant                      = '1000'
            posting_date_from          = '20261001'
            posting_date_to            = '20261031'
            filter_yield_quantity_from = abap_true
            yield_quantity_from        = '0.000'
            maximum_results            = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_window_read_calls
      exp = lv_read_calls ).

    CLEAR lv_raised.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material                   = 'MAT-1'
            plant                      = '1000'
            quantity_unit              = 'EA'
            posting_date_from          = '20261001'
            posting_date_to            = '20261031'
            filter_yield_quantity_from = 'Y'
            yield_quantity_from        = '0.000'
            maximum_results            = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_window_read_calls
      exp = lv_read_calls ).

    lo_repository->use_conf_window_override = abap_true.
    lo_repository->conf_window_override = VALUE #(
      ( production_order     = '0000000001'
        confirmation         = '0000000004'
        confirmation_counter = '00000001'
        posting_date         = '20261013'
        quantity_unit        = 'EA'
        yield_quantity       = '1.000' ) ).
    CLEAR lv_raised.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material                   = 'MAT-1'
            plant                      = '1000'
            quantity_unit              = 'EA'
            posting_date_from          = '20261001'
            posting_date_to            = '20261031'
            filter_yield_quantity_from = abap_true
            yield_quantity_from        = '2.000'
            maximum_results            = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD filters_conf_operation_range.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order = '0000000001'
        production_item  = '0001'
        order_category   = '10'
        material         = 'MAT-1'
        plant            = '1000' ) ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order     = '0000000001'
        operation_number     = '0010'
        confirmation         = '0000000001'
        confirmation_counter = '00000001'
        posting_date         = '20261010' )
      ( production_order     = '0000000001'
        operation_number     = '0020'
        confirmation         = '0000000002'
        confirmation_counter = '00000001'
        posting_date         = '20261011' )
      ( production_order     = '0000000001'
        operation_number     = '0030'
        confirmation         = '0000000003'
        confirmation_counter = '00000001'
        posting_date         = '20261012' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_range_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material              = 'MAT-1'
        plant                 = '1000'
        posting_date_from     = '20261001'
        posting_date_to       = '20261031'
        operation_number_from = '0010'
        operation_number_to   = '0020'
        maximum_results       = 10 ) ).
    cl_abap_unit_assert=>assert_true( ls_range_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_range_result-returned_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0010'
      act = ls_range_result-confirmations[ 1 ]-operation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0020'
      act = ls_range_result-confirmations[ 2 ]-operation_number ).

    DATA(ls_lower_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material              = 'MAT-1'
        plant                 = '1000'
        posting_date_from     = '20261001'
        posting_date_to       = '20261031'
        operation_number_from = '0020'
        maximum_results       = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_lower_result-returned_count ).

    DATA(ls_paged_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material              = 'MAT-1'
        plant                 = '1000'
        posting_date_from     = '20261001'
        posting_date_to       = '20261031'
        operation_number_from = '0020'
        maximum_results       = 1 ) ).
    cl_abap_unit_assert=>assert_true( ls_paged_result-is_truncated ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0020'
      act = ls_paged_result-confirmations[ 1 ]-operation_number ).

    DATA(ls_upper_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material            = 'MAT-1'
        plant               = '1000'
        posting_date_from   = '20261001'
        posting_date_to     = '20261031'
        operation_number_to = '0020'
        maximum_results     = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_upper_result-returned_count ).

    DATA(ls_intersection_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material              = 'MAT-1'
        plant                 = '1000'
        posting_date_from     = '20261001'
        posting_date_to       = '20261031'
        operation_number      = '0030'
        operation_number_from = '0020'
        operation_number_to   = '0030'
        maximum_results       = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_intersection_result-returned_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0030'
      act = ls_intersection_result-confirmations[ 1 ]-operation_number ).

    DATA(lv_read_calls) = lo_repository->confirmation_window_read_calls.
    DATA lv_raised TYPE abap_bool.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material              = 'MAT-1'
            plant                 = '1000'
            posting_date_from     = '20261001'
            posting_date_to       = '20261031'
            operation_number_from = '0030'
            operation_number_to   = '0020'
            maximum_results       = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_read_calls
      act = lo_repository->confirmation_window_read_calls ).
  ENDMETHOD.

  METHOD filters_conf_sequence_range.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order = '0000000001'
        production_item  = '0001'
        order_category   = '10'
        material         = 'MAT-1'
        plant            = '1000' ) ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order     = '0000000001'
        operation_sequence   = '000001'
        confirmation         = '0000000001'
        confirmation_counter = '00000001'
        posting_date         = '20261010' )
      ( production_order     = '0000000001'
        operation_sequence   = '000002'
        confirmation         = '0000000002'
        confirmation_counter = '00000001'
        posting_date         = '20261011' )
      ( production_order     = '0000000001'
        operation_sequence   = '000003'
        confirmation         = '0000000003'
        confirmation_counter = '00000001'
        posting_date         = '20261012' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_range_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material                = 'MAT-1'
        plant                   = '1000'
        posting_date_from       = '20261001'
        posting_date_to         = '20261031'
        operation_sequence_from = '000001'
        operation_sequence_to   = '000002'
        maximum_results         = 10 ) ).
    cl_abap_unit_assert=>assert_true( ls_range_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_range_result-returned_count ).

    DATA(ls_lower_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material                = 'MAT-1'
        plant                   = '1000'
        posting_date_from       = '20261001'
        posting_date_to         = '20261031'
        operation_sequence_from = '000002'
        maximum_results         = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_lower_result-returned_count ).

    DATA(ls_paged_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material                = 'MAT-1'
        plant                   = '1000'
        posting_date_from       = '20261001'
        posting_date_to         = '20261031'
        operation_sequence_from = '000002'
        maximum_results         = 1 ) ).
    cl_abap_unit_assert=>assert_true( ls_paged_result-is_truncated ).
    cl_abap_unit_assert=>assert_equals(
      exp = '000002'
      act = ls_paged_result-confirmations[ 1 ]-operation_sequence ).

    DATA(ls_upper_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material              = 'MAT-1'
        plant                 = '1000'
        posting_date_from     = '20261001'
        posting_date_to       = '20261031'
        operation_sequence_to = '000002'
        maximum_results       = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_upper_result-returned_count ).

    DATA(ls_intersection_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material                  = 'MAT-1'
        plant                     = '1000'
        posting_date_from         = '20261001'
        posting_date_to           = '20261031'
        filter_operation_sequence = abap_true
        operation_sequence        = '000003'
        operation_sequence_from   = '000002'
        operation_sequence_to     = '000003'
        maximum_results           = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_intersection_result-returned_count ).

    DATA(lv_read_calls) = lo_repository->confirmation_window_read_calls.
    DATA lv_raised TYPE abap_bool.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material                = 'MAT-1'
            plant                   = '1000'
            posting_date_from       = '20261001'
            posting_date_to         = '20261031'
            operation_sequence_from = '000003'
            operation_sequence_to   = '000002'
            maximum_results         = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_read_calls
      act = lo_repository->confirmation_window_read_calls ).
  ENDMETHOD.

  METHOD filters_conf_subop_range.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order = '0000000001'
        production_item  = '0001'
        order_category   = '10'
        material         = 'MAT-1'
        plant            = '1000' ) ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order       = '0000000001'
        operation_number       = '0020'
        operation_suboperation = '0001'
        confirmation           = '0000000001'
        confirmation_counter   = '00000001'
        posting_date           = '20261010' )
      ( production_order       = '0000000001'
        operation_number       = '0020'
        operation_suboperation = '0002'
        confirmation           = '0000000002'
        confirmation_counter   = '00000001'
        posting_date           = '20261011' )
      ( production_order       = '0000000001'
        operation_number       = '0020'
        operation_suboperation = '0003'
        confirmation           = '0000000003'
        confirmation_counter   = '00000001'
        posting_date           = '20261012' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_range_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material                    = 'MAT-1'
        plant                       = '1000'
        posting_date_from           = '20261001'
        posting_date_to             = '20261031'
        operation_number            = '0020'
        operation_suboperation_from = '0001'
        operation_suboperation_to   = '0002'
        maximum_results             = 10 ) ).
    cl_abap_unit_assert=>assert_true( ls_range_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_range_result-returned_count ).

    DATA(ls_lower_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material                    = 'MAT-1'
        plant                       = '1000'
        posting_date_from           = '20261001'
        posting_date_to             = '20261031'
        operation_number            = '0020'
        operation_suboperation_from = '0002'
        maximum_results             = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_lower_result-returned_count ).

    DATA(ls_paged_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material                    = 'MAT-1'
        plant                       = '1000'
        posting_date_from           = '20261001'
        posting_date_to             = '20261031'
        operation_number            = '0020'
        operation_suboperation_from = '0002'
        maximum_results             = 1 ) ).
    cl_abap_unit_assert=>assert_true( ls_paged_result-is_truncated ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_paged_result-confirmations[ 1 ]-operation_suboperation ).

    DATA(ls_upper_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material                  = 'MAT-1'
        plant                     = '1000'
        posting_date_from         = '20261001'
        posting_date_to           = '20261031'
        operation_number          = '0020'
        operation_suboperation_to = '0001'
        maximum_results           = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_upper_result-returned_count ).

    DATA(ls_intersection_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material                    = 'MAT-1'
        plant                       = '1000'
        posting_date_from           = '20261001'
        posting_date_to             = '20261031'
        operation_number            = '0020'
        operation_suboperation      = '0002'
        operation_suboperation_from = '0001'
        operation_suboperation_to   = '0003'
        maximum_results             = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_intersection_result-returned_count ).

    DATA(lv_read_calls) = lo_repository->confirmation_window_read_calls.
    DATA lv_raised TYPE abap_bool.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material                    = 'MAT-1'
            plant                       = '1000'
            posting_date_from           = '20261001'
            posting_date_to             = '20261031'
            operation_number            = space
            operation_suboperation_from = '0001'
            operation_suboperation_to   = '0002'
            maximum_results             = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_read_calls
      act = lo_repository->confirmation_window_read_calls ).

    CLEAR lv_raised.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material                    = 'MAT-1'
            plant                       = '1000'
            posting_date_from           = '20261001'
            posting_date_to             = '20261031'
            operation_number            = '0020'
            operation_suboperation_from = '0003'
            operation_suboperation_to   = '0002'
            maximum_results             = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_read_calls
      act = lo_repository->confirmation_window_read_calls ).
  ENDMETHOD.

  METHOD filters_conf_counter_range.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order = '0000000001'
        production_item  = '0001'
        order_category   = '10'
        material         = 'MAT-1'
        plant            = '1000' ) ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order     = '0000000001'
        operation_counter    = '00000001'
        confirmation         = '0000000001'
        confirmation_counter = '00000001'
        posting_date         = '20261010' )
      ( production_order     = '0000000001'
        operation_counter    = '00000002'
        confirmation         = '0000000002'
        confirmation_counter = '00000001'
        posting_date         = '20261011' )
      ( production_order     = '0000000001'
        operation_counter    = '00000003'
        confirmation         = '0000000003'
        confirmation_counter = '00000001'
        posting_date         = '20261012' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_range_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material               = 'MAT-1'
        plant                  = '1000'
        production_order       = '0000000001'
        posting_date_from      = '20261001'
        posting_date_to        = '20261031'
        operation_counter_from = '00000001'
        operation_counter_to   = '00000002'
        maximum_results        = 10 ) ).
    cl_abap_unit_assert=>assert_true( ls_range_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_range_result-returned_count ).

    DATA(ls_lower_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material               = 'MAT-1'
        plant                  = '1000'
        production_order       = '0000000001'
        posting_date_from      = '20261001'
        posting_date_to        = '20261031'
        operation_counter_from = '00000002'
        maximum_results        = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_lower_result-returned_count ).

    DATA(ls_paged_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material               = 'MAT-1'
        plant                  = '1000'
        production_order       = '0000000001'
        posting_date_from      = '20261001'
        posting_date_to        = '20261031'
        operation_counter_from = '00000002'
        maximum_results        = 1 ) ).
    cl_abap_unit_assert=>assert_true( ls_paged_result-is_truncated ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00000002'
      act = ls_paged_result-confirmations[ 1 ]-operation_counter ).

    DATA(ls_upper_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material             = 'MAT-1'
        plant                = '1000'
        production_order     = '0000000001'
        posting_date_from    = '20261001'
        posting_date_to      = '20261031'
        operation_counter_to = '00000002'
        maximum_results      = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_upper_result-returned_count ).

    DATA(ls_intersection_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material               = 'MAT-1'
        plant                  = '1000'
        production_order       = '0000000001'
        posting_date_from      = '20261001'
        posting_date_to        = '20261031'
        operation_counter      = '00000003'
        operation_counter_from = '00000002'
        operation_counter_to   = '00000003'
        maximum_results        = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_intersection_result-returned_count ).

    DATA(lv_read_calls) = lo_repository->confirmation_window_read_calls.
    DATA lv_raised TYPE abap_bool.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material               = 'MAT-1'
            plant                  = '1000'
            posting_date_from      = '20261001'
            posting_date_to        = '20261031'
            operation_counter_from = '00000001'
            operation_counter_to   = '00000002'
            maximum_results        = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_read_calls
      act = lo_repository->confirmation_window_read_calls ).

    CLEAR lv_raised.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material               = 'MAT-1'
            plant                  = '1000'
            production_order       = '0000000001'
            posting_date_from      = '20261001'
            posting_date_to        = '20261031'
            operation_counter_from = '00000003'
            operation_counter_to   = '00000002'
            maximum_results        = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_read_calls
      act = lo_repository->confirmation_window_read_calls ).
  ENDMETHOD.

  METHOD filters_conf_rmzhl_range.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order = '0000000001'
        production_item  = '0001'
        order_category   = '10'
        material         = 'MAT-1'
        plant            = '1000' ) ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order     = '0000000001'
        confirmation         = '0000000001'
        confirmation_counter = '00000001'
        posting_date         = '20261010' )
      ( production_order     = '0000000001'
        confirmation         = '0000000001'
        confirmation_counter = '00000002'
        posting_date         = '20261011' )
      ( production_order     = '0000000001'
        confirmation         = '0000000001'
        confirmation_counter = '00000003'
        posting_date         = '20261012' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_range_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material                  = 'MAT-1'
        plant                     = '1000'
        posting_date_from         = '20261001'
        posting_date_to           = '20261031'
        confirmation_number       = '0000000001'
        confirmation_counter_from = '00000002'
        confirmation_counter_to   = '00000003'
        maximum_results           = 10 ) ).
    cl_abap_unit_assert=>assert_true( ls_range_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_range_result-returned_count ).

    DATA(ls_lower_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material                  = 'MAT-1'
        plant                     = '1000'
        posting_date_from         = '20261001'
        posting_date_to           = '20261031'
        confirmation_number       = '0000000001'
        confirmation_counter_from = '00000002'
        maximum_results           = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_lower_result-returned_count ).

    DATA(ls_paged_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material                  = 'MAT-1'
        plant                     = '1000'
        posting_date_from         = '20261001'
        posting_date_to           = '20261031'
        confirmation_number       = '0000000001'
        confirmation_counter_from = '00000002'
        maximum_results           = 1 ) ).
    cl_abap_unit_assert=>assert_true( ls_paged_result-is_truncated ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00000002'
      act = ls_paged_result-confirmations[ 1 ]-confirmation_counter ).

    DATA(ls_upper_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material                = 'MAT-1'
        plant                   = '1000'
        posting_date_from       = '20261001'
        posting_date_to         = '20261031'
        confirmation_number     = '0000000001'
        confirmation_counter_to = '00000002'
        maximum_results         = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_upper_result-returned_count ).

    DATA(ls_intersection_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material                  = 'MAT-1'
        plant                     = '1000'
        posting_date_from         = '20261001'
        posting_date_to           = '20261031'
        confirmation_number       = '0000000001'
        confirmation_counter      = '00000003'
        confirmation_counter_from = '00000002'
        confirmation_counter_to   = '00000003'
        maximum_results           = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_intersection_result-returned_count ).

    DATA(lv_read_calls) = lo_repository->confirmation_window_read_calls.
    DATA lv_raised TYPE abap_bool.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material                  = 'MAT-1'
            plant                     = '1000'
            posting_date_from         = '20261001'
            posting_date_to           = '20261031'
            confirmation_counter_from = '00000001'
            confirmation_counter_to   = '00000002'
            maximum_results           = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_read_calls
      act = lo_repository->confirmation_window_read_calls ).

    CLEAR lv_raised.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material                  = 'MAT-1'
            plant                     = '1000'
            posting_date_from         = '20261001'
            posting_date_to           = '20261031'
            confirmation_number       = '0000000001'
            confirmation_counter_from = '00000003'
            confirmation_counter_to   = '00000002'
            maximum_results           = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_read_calls
      act = lo_repository->confirmation_window_read_calls ).
  ENDMETHOD.

  METHOD filters_conf_execution_finish.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order = '0000000001'
        production_item  = '0001'
        order_category   = '10'
        material         = 'MAT-1'
        plant            = '1000' ) ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order      = '0000000001'
        order_category        = '10'
        confirmation          = '0000000001'
        confirmation_counter  = '00000001'
        posting_date          = '20261011'
        entry_time            = '000000'
        execution_start_date  = '20261009'
        execution_start_time  = '080000'
        execution_finish_date = '20261010'
        execution_finish_time = '090000' )
      ( production_order      = '0000000001'
        order_category        = '10'
        confirmation          = '0000000002'
        confirmation_counter  = '00000001'
        posting_date          = '20261011'
        entry_time            = '000000'
        execution_start_date  = '20261010'
        execution_start_time  = '100000'
        execution_finish_date = '20261011'
        execution_finish_time = '110000' )
      ( production_order      = '0000000001'
        order_category        = '10'
        confirmation          = '0000000003'
        confirmation_counter  = '00000001'
        posting_date          = '20261011'
        entry_time            = '000000'
        execution_finish_date = '20261012'
        execution_finish_time = '120000' )
      ( production_order     = '0000000001'
        order_category       = '10'
        confirmation         = '0000000004'
        confirmation_counter = '00000001'
        posting_date         = '20261011'
        entry_time           = '000000' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material                   = 'MAT-1'
        plant                      = '1000'
        posting_date_from          = '20261001'
        posting_date_to            = '20261031'
        execution_finish_date_from = '20261010'
        execution_finish_date_to   = '20261011'
        maximum_results            = 10 ) ).
    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-returned_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000001'
      act = ls_result-confirmations[ 1 ]-confirmation ).
    cl_abap_unit_assert=>assert_equals(
      exp = '080000'
      act = ls_result-confirmations[ 1 ]-execution_start_time ).
    cl_abap_unit_assert=>assert_equals(
      exp = '090000'
      act = ls_result-confirmations[ 1 ]-execution_finish_time ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000002'
      act = ls_result-confirmations[ 2 ]-confirmation ).

    ls_result = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material                   = 'MAT-1'
        plant                      = '1000'
        posting_date_from          = '20261001'
        posting_date_to            = '20261031'
        execution_finish_date_from = '20261011'
        maximum_results            = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-returned_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000002'
      act = ls_result-confirmations[ 1 ]-confirmation ).

    ls_result = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material                 = 'MAT-1'
        plant                    = '1000'
        posting_date_from        = '20261001'
        posting_date_to          = '20261031'
        execution_finish_date_to = '20261010'
        maximum_results          = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-returned_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000001'
      act = ls_result-confirmations[ 1 ]-confirmation ).

    ls_result = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material                  = 'MAT-1'
        plant                     = '1000'
        posting_date_from         = '20261001'
        posting_date_to           = '20261031'
        execution_start_date_from = '20261009'
        execution_start_date_to   = '20261010'
        maximum_results           = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-returned_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000001'
      act = ls_result-confirmations[ 1 ]-confirmation ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000002'
      act = ls_result-confirmations[ 2 ]-confirmation ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261009'
      act = ls_result-confirmations[ 1 ]-execution_start_date ).

    ls_result = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material                  = 'MAT-1'
        plant                     = '1000'
        posting_date_from         = '20261001'
        posting_date_to           = '20261031'
        execution_start_date_from = '20261010'
        maximum_results           = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-returned_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000002'
      act = ls_result-confirmations[ 1 ]-confirmation ).

    ls_result = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material                = 'MAT-1'
        plant                   = '1000'
        posting_date_from       = '20261001'
        posting_date_to         = '20261031'
        execution_start_date_to = '20261009'
        maximum_results         = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-returned_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000001'
      act = ls_result-confirmations[ 1 ]-confirmation ).

    ls_result = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material                    = 'MAT-1'
        plant                       = '1000'
        posting_date_from           = '20261001'
        posting_date_to             = '20261031'
        filter_execution_start_time = abap_true
        execution_start_time_from   = '000000'
        execution_start_time_to     = '100000'
        maximum_results             = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-returned_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000001'
      act = ls_result-confirmations[ 1 ]-confirmation ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000002'
      act = ls_result-confirmations[ 2 ]-confirmation ).

    ls_result = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material                     = 'MAT-1'
        plant                        = '1000'
        posting_date_from            = '20261001'
        posting_date_to              = '20261031'
        filter_execution_finish_time = abap_true
        execution_finish_time_from   = '090000'
        execution_finish_time_to     = '110000'
        maximum_results              = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-returned_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000001'
      act = ls_result-confirmations[ 1 ]-confirmation ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000002'
      act = ls_result-confirmations[ 2 ]-confirmation ).

    DATA(lv_read_calls) = lo_repository->confirmation_window_read_calls.
    DATA(lv_raised) = abap_false.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material                   = 'MAT-1'
            plant                      = '1000'
            posting_date_from          = '20261001'
            posting_date_to            = '20261031'
            execution_finish_date_from = '20261012'
            execution_finish_date_to   = '20261011'
            maximum_results            = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_read_calls
      act = lo_repository->confirmation_window_read_calls ).

    CLEAR lv_raised.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material                  = 'MAT-1'
            plant                     = '1000'
            posting_date_from         = '20261001'
            posting_date_to           = '20261031'
            execution_start_date_from = '20261011'
            execution_start_date_to   = '20261010'
            maximum_results           = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_read_calls
      act = lo_repository->confirmation_window_read_calls ).

    CLEAR lv_raised.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material                    = 'MAT-1'
            plant                       = '1000'
            posting_date_from           = '20261001'
            posting_date_to             = '20261031'
            filter_execution_start_time = abap_true
            execution_start_time_from   = '100000'
            execution_start_time_to     = '080000'
            maximum_results             = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_read_calls
      act = lo_repository->confirmation_window_read_calls ).
  ENDMETHOD.

  METHOD filters_conf_work_center.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order = '0000000001'
        production_item  = '0001'
        order_category   = '10'
        material         = 'MAT-1'
        plant            = '1000' ) ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order     = '0000000001'
        operation_number     = '0010'
        resource_object_id   = '00000001'
        work_center          = 'WC-01'
        work_center_plant    = '1000'
        confirmation         = '0000000001'
        confirmation_counter = '00000001'
        posting_date         = '20261010' )
      ( production_order     = '0000000001'
        operation_number     = '0020'
        resource_object_id   = '00000002'
        work_center          = 'WC-02'
        work_center_plant    = '2000'
        confirmation         = '0000000002'
        confirmation_counter = '00000001'
        posting_date         = '20261011' )
      ( production_order     = '0000000001'
        operation_number     = '0030'
        confirmation         = '0000000003'
        confirmation_counter = '00000001'
        posting_date         = '20261012' ) ).
    APPEND VALUE #(
      production_order     = '0000000001'
      operation_number     = '0040'
      resource_object_id   = '00000001'
      work_center          = 'WC-01'
      work_center_plant    = '1000'
      confirmation         = '0000000004'
      confirmation_counter = '00000001'
      posting_date         = '20261009' ) TO lo_repository->order_confirmations.
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        work_center       = 'WC-02'
        posting_date_from = '20261001'
        posting_date_to   = '20261031'
        maximum_results   = 10 ) ).
    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-returned_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'WC-02'
      act = ls_result-confirmations[ 1 ]-work_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'WC-02'
      act = ls_result-operation_summaries[ 1 ]-work_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = ls_result-confirmations[ 1 ]-work_center_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = ls_result-operation_summaries[ 1 ]-work_center_plant ).
    DATA(ls_plant_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        work_center_plant = '2000'
        posting_date_from = '20261001'
        posting_date_to   = '20261031'
        maximum_results   = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_plant_result-returned_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000002'
      act = ls_plant_result-confirmations[ 1 ]-confirmation ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = ls_plant_result-confirmations[ 1 ]-work_center_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000002'
      act = ls_result-confirmations[ 1 ]-confirmation ).

    DATA(ls_blank_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material                 = 'MAT-1'
        plant                    = '1000'
        filter_work_center       = abap_true
        filter_work_center_plant = abap_true
        posting_date_from        = '20261001'
        posting_date_to          = '20261031'
        maximum_results          = 10 ) ).
    cl_abap_unit_assert=>assert_true( ls_blank_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_blank_result-returned_count ).
    cl_abap_unit_assert=>assert_initial(
      ls_blank_result-confirmations[ 1 ]-work_center ).
    cl_abap_unit_assert=>assert_initial(
      ls_blank_result-confirmations[ 1 ]-work_center_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000003'
      act = ls_blank_result-confirmations[ 1 ]-confirmation ).

    DATA(ls_page_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        posting_date_from = '20261001'
        posting_date_to   = '20261031'
        maximum_results   = 2 ) ).
    cl_abap_unit_assert=>assert_true( ls_page_result-is_truncated ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_page_result-returned_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_page_result-work_center_summaries ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_page_result-work_center_summaries[ 1 ]-confirmation_count ).
  ENDMETHOD.

  METHOD filters_conf_bulk_work_center.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order     = '0000000001'
        confirmation         = '0000000001'
        confirmation_counter = '00000001'
        posting_date         = '20261006'
        yield_quantity       = '1.000'
        quantity_unit        = 'EA'
        is_reversed          = abap_true
        work_center          = 'WC-01'
        work_center_plant    = '1000' )
      ( production_order     = '0000000001'
        confirmation         = '0000000002'
        confirmation_counter = '00000001'
        posting_date         = '20261005'
        yield_quantity       = '2.000'
        rework_quantity      = '0.250'
        scrap_quantity       = '0.125'
        quantity_unit        = 'EA'
        work_center          = 'WC-01'
        work_center_plant    = '1000' )
      ( production_order     = '0000000001'
        confirmation         = '0000000003'
        confirmation_counter = '00000001'
        posting_date         = '20261003'
        work_center          = 'WC-02'
        work_center_plant    = '2000' )
      ( production_order     = '0000000001'
        confirmation         = '0000000004'
        confirmation_counter = '00000001'
        posting_date         = '20261002' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_center_result) = lo_cut->read_confirmations_bulk(
      it_production_orders = VALUE #( ( '0000000001' ) )
      iv_work_center       = 'WC-02' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_center_result-returned_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'WC-02'
      act = ls_center_result-orders[ 1 ]-confirmations[ 1 ]-work_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_center_result-work_center_summaries ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_center_result-work_center_summaries[ 1 ]-confirmation_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'WC-02'
      act = ls_center_result-work_center_summaries[ 1 ]-work_center ).

    DATA(ls_blank_center_result) = lo_cut->read_confirmations_bulk(
      it_production_orders  = VALUE #( ( '0000000001' ) )
      iv_filter_work_center = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_blank_center_result-returned_count ).
    cl_abap_unit_assert=>assert_initial(
      ls_blank_center_result-orders[ 1 ]-confirmations[ 1 ]-work_center ).
    cl_abap_unit_assert=>assert_initial(
      ls_blank_center_result-work_center_summaries[ 1 ]-work_center ).

    DATA(ls_page_result) = lo_cut->read_confirmations_bulk(
      it_production_orders = VALUE #( ( '0000000001' ) )
      iv_maximum_results   = 2 ).
    cl_abap_unit_assert=>assert_true( ls_page_result-is_truncated ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_page_result-returned_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_page_result-work_center_summaries ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_page_result-work_center_summaries[ 1 ]-confirmation_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_page_result-work_center_summaries[ 1 ]-partial_confirmation_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_page_result-work_center_summaries[ 1 ]-reversed_confirmation_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '100.00' )
      act = ls_page_result-work_center_summaries[ 1 ]-partial_confirmation_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261005'
      act = ls_page_result-work_center_summaries[ 1 ]-first_posting_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261006'
      act = ls_page_result-work_center_summaries[ 1 ]-last_posting_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_page_result-work_center_summaries[ 1 ]-quantity_summaries[
        quantity_unit = 'EA' ]-confirmation_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3.000' )
      act = ls_page_result-work_center_summaries[ 1 ]-quantity_summaries[
        quantity_unit = 'EA' ]-yield_quantity_total ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '2.000' )
      act = ls_page_result-work_center_summaries[ 1 ]-quantity_summaries[
        quantity_unit = 'EA' ]-yield_non_reversed_total ).

    DATA(ls_plant_result) = lo_cut->read_confirmations_bulk(
      it_production_orders = VALUE #( ( '0000000001' ) )
      iv_work_center_plant = '1000' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_plant_result-returned_count ).
    DATA(ls_plant_confirmation) =
      ls_plant_result-orders[ 1 ]-confirmations[ 1 ].
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = ls_plant_confirmation-work_center_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_plant_result-work_center_summaries[ 1 ]-confirmation_count ).

    DATA(ls_blank_plant_result) = lo_cut->read_confirmations_bulk(
      it_production_orders        = VALUE #( ( '0000000001' ) )
      iv_filter_work_center_plant = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_blank_plant_result-returned_count ).
    DATA(ls_blank_plant_confirmation) =
      ls_blank_plant_result-orders[ 1 ]-confirmations[ 1 ].
    cl_abap_unit_assert=>assert_initial(
      ls_blank_plant_confirmation-work_center_plant ).

    DATA lv_raised TYPE abap_bool.
    TRY.
        lo_cut->read_confirmations_bulk(
          it_production_orders  = VALUE #( ( '0000000001' ) )
          iv_filter_work_center = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    CLEAR lv_raised.
    TRY.
        lo_cut->read_confirmations_bulk(
          it_production_orders        = VALUE #( ( '0000000001' ) )
          iv_filter_work_center_plant = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = lo_repository->confirmation_read_calls ).
  ENDMETHOD.

  METHOD converts_conf_window_base_unit.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order = '0000000001'
        production_item  = '0001'
        order_category   = '10'
        material         = 'MAT-1'
        plant            = '1000' ) ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        operation_description = 'Make component'
        control_key           = 'PP01'
        resource_object_id    = '00000001'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = '0000000001'
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '233000'
        execution_finish_date = '20261011'
        execution_finish_time = '001500'
        yield_quantity        = '2.000'
        rework_quantity       = '0.500'
        scrap_quantity        = '0.250'
        quantity_unit         = 'EA'
        is_reversed           = abap_true )
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        operation_description = 'Make component'
        control_key           = 'PP01'
        resource_object_id    = '00000001'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = '0000000002'
        confirmation_counter  = '00000001'
        posting_date          = '20261011'
        execution_start_date  = '20261011'
        execution_start_time  = '020000'
        execution_finish_date = '20261011'
        execution_finish_time = '010000'
        yield_quantity        = '3.000'
        rework_quantity       = '0.250'
        scrap_quantity        = '1.000'
        quantity_unit         = 'BOX'
        is_final              = abap_true )
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000002'
        operation_number      = '0020'
        operation_sequence    = '000000'
        operation_description = 'Pack component'
        control_key           = 'PP01'
        resource_object_id    = '00000002'
        work_center           = 'WC-02'
        work_center_plant     = '2000'
        confirmation          = '0000000003'
        confirmation_counter  = '00000001'
        posting_date          = '20261012'
        execution_finish_date = '20261012'
        execution_finish_time = '000000'
        yield_quantity        = '1.000'
        rework_quantity       = '0.125'
        scrap_quantity        = '0.500'
        quantity_unit         = 'BOX' ) ).
    DATA(lo_uom_repository) = NEW lcl_prod_order_uom_repo( ).
    lo_uom_repository->base_unit = 'EA'.
    lo_uom_repository->alternative_unit = 'BOX'.
    lo_uom_repository->numerator = 12.
    lo_uom_repository->denominator = 1.
    DATA(lo_uom_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service(
      io_repository    = lo_repository
      io_uom_converter = lo_uom_converter ).

    DATA(ls_result) = lo_cut->search_conf_window_base_unit(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        posting_date_from = '20261001'
        posting_date_to   = '20261031'
        maximum_results   = 10 ) ).
    DATA(ls_raw_wc_summary) =
      ls_result-raw_result-work_center_summaries[ 1 ].
    DATA(ls_raw_operation_box) =
      ls_result-raw_result-operation_summaries[ 1 ].
    DATA(ls_raw_operation_ea) =
      ls_result-raw_result-operation_summaries[ 2 ].
    DATA(ls_raw_operation_missing_start) =
      ls_result-raw_result-operation_summaries[ 3 ].
    DATA(ls_raw_order_box) = ls_result-raw_result-order_summaries[ 1 ].
    DATA(ls_raw_order_ea) = ls_result-raw_result-order_summaries[ 2 ].
    DATA(ls_raw_confirmation_valid) =
      ls_result-raw_result-confirmations[
        confirmation = '0000000001' ].
    DATA(ls_raw_confirmation_invalid) =
      ls_result-raw_result-confirmations[
        confirmation = '0000000002' ].
    DATA(ls_raw_confirmation_missing) =
      ls_result-raw_result-confirmations[
        confirmation = '0000000003' ].
    DATA(ls_base_wc_summary) = ls_result-base_work_center_summaries[ 1 ].
    DATA(ls_base_wc_summary_second) =
      ls_result-base_work_center_summaries[ 2 ].
    DATA(ls_base_operation_primary) =
      ls_result-base_operation_summaries[ 1 ].
    DATA(ls_base_operation_secondary) =
      ls_result-base_operation_summaries[ 2 ].
    DATA(ls_base_order_summary) = ls_result-base_order_summaries[ 1 ].

    cl_abap_unit_assert=>assert_true(
      ls_result-raw_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'V'
      act = ls_raw_confirmation_valid-exec_duration_status ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'I'
      act = ls_raw_confirmation_invalid-exec_duration_status ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'M'
      act = ls_raw_confirmation_missing-exec_duration_status ).
    cl_abap_unit_assert=>assert_initial(
      ls_raw_confirmation_invalid-exec_duration_seconds ).
    cl_abap_unit_assert=>assert_initial(
      ls_raw_confirmation_missing-exec_duration_seconds ).
    cl_abap_unit_assert=>assert_not_initial(
      act = ls_result-raw_result-snapshot_timestamp ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-raw_result-confirmations )
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-raw_result-operation_summaries )
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-raw_result-order_summaries )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-raw_result-order_summaries[ 1 ]-quantity_unit
      exp = 'BOX' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-raw_result-order_summaries[ 1 ]-confirmation_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-raw_result-order_summaries[ 2 ]-quantity_unit
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-raw_result-order_summaries[ 2 ]-confirmation_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-raw_result-order_summaries[ 1 ]-yield_quantity_total
      exp = CONV decfloat34( '4.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_box-execution_start_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_box-execution_start_pct
      exp = CONV decfloat34( '100.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_box-valid_exec_duration_pct
      exp = CONV decfloat34( '0' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_box-first_execution_start_date
      exp = '20261011' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_box-first_execution_start_time
      exp = '020000' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_box-execution_finish_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_box-execution_finish_pct
      exp = CONV decfloat34( '100.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_box-last_execution_finish_date
      exp = '20261011' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_box-last_execution_finish_time
      exp = '010000' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_box-exec_duration_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_box-zero_exec_duration_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_box-zero_exec_duration_pct
      exp = CONV decfloat34( '0' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_box-exec_duration_seconds_total
      exp = CONV decfloat34( '0' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_box-exec_duration_seconds_avg
      exp = CONV decfloat34( '0' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_box-exec_duration_seconds_min
      exp = CONV decfloat34( '0' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_box-exec_duration_seconds_max
      exp = CONV decfloat34( '0' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_box-invalid_exec_duration_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_box-invalid_exec_duration_pct
      exp = CONV decfloat34( '100.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_box-missing_exec_duration_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_box-missing_exec_duration_pct
      exp = CONV decfloat34( '0' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_ea-execution_start_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_ea-execution_start_pct
      exp = CONV decfloat34( '100.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_ea-first_execution_start_date
      exp = '20261010' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_ea-first_execution_start_time
      exp = '233000' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_ea-execution_finish_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_ea-execution_finish_pct
      exp = CONV decfloat34( '100.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_ea-last_execution_finish_date
      exp = '20261011' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_ea-last_execution_finish_time
      exp = '001500' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_ea-exec_duration_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_ea-valid_exec_duration_pct
      exp = CONV decfloat34( '100.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_ea-exec_duration_seconds_total
      exp = CONV decfloat34( '2700' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_ea-exec_duration_seconds_min
      exp = CONV decfloat34( '2700' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_ea-exec_duration_seconds_max
      exp = CONV decfloat34( '2700' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_ea-exec_duration_seconds_avg
      exp = CONV decfloat34( '2700' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_ea-invalid_exec_duration_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_ea-invalid_exec_duration_pct
      exp = CONV decfloat34( '0' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_ea-missing_exec_duration_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_ea-missing_exec_duration_pct
      exp = CONV decfloat34( '0' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_missing_start-execution_start_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_missing_start-execution_start_pct
      exp = CONV decfloat34( '0' ) ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_raw_operation_missing_start-first_execution_start_date ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_missing_start-execution_finish_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_missing_start-execution_finish_pct
      exp = CONV decfloat34( '100.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_missing_start-last_execution_finish_date
      exp = '20261012' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_missing_start-last_execution_finish_time
      exp = '000000' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_missing_start-exec_duration_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_missing_start-valid_exec_duration_pct
      exp = CONV decfloat34( '0' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_missing_start-exec_duration_seconds_avg
      exp = CONV decfloat34( '0' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_missing_start-invalid_exec_duration_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_missing_start-missing_exec_duration_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_operation_missing_start-missing_exec_duration_pct
      exp = CONV decfloat34( '100.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_order_box-execution_start_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_order_box-execution_start_pct
      exp = CONV decfloat34( '50.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_order_box-first_execution_start_date
      exp = '20261011' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_order_box-first_execution_start_time
      exp = '020000' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_order_box-execution_finish_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_order_box-execution_finish_pct
      exp = CONV decfloat34( '100.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_order_box-last_execution_finish_date
      exp = '20261012' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_order_box-last_execution_finish_time
      exp = '000000' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_order_box-exec_duration_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_order_box-valid_exec_duration_pct
      exp = CONV decfloat34( '0' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_order_box-exec_duration_seconds_avg
      exp = CONV decfloat34( '0' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_order_box-invalid_exec_duration_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_order_box-invalid_exec_duration_pct
      exp = CONV decfloat34( '50.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_order_box-missing_exec_duration_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_order_box-missing_exec_duration_pct
      exp = CONV decfloat34( '50.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_order_ea-execution_start_pct
      exp = CONV decfloat34( '100.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_order_ea-execution_finish_pct
      exp = CONV decfloat34( '100.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_order_ea-exec_duration_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_order_ea-valid_exec_duration_pct
      exp = CONV decfloat34( '100.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_order_ea-exec_duration_seconds_total
      exp = CONV decfloat34( '2700' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_order_ea-exec_duration_seconds_avg
      exp = CONV decfloat34( '2700' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_order_ea-invalid_exec_duration_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_order_ea-invalid_exec_duration_pct
      exp = CONV decfloat34( '0' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_order_ea-missing_exec_duration_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_order_ea-missing_exec_duration_pct
      exp = CONV decfloat34( '0' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-raw_result-work_center_summaries )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_raw_wc_summary-execution_start_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '100.00' )
      act = ls_raw_wc_summary-execution_start_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261010'
      act = ls_raw_wc_summary-first_execution_start_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '233000'
      act = ls_raw_wc_summary-first_execution_start_time ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_raw_wc_summary-execution_finish_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '100.00' )
      act = ls_raw_wc_summary-execution_finish_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261011'
      act = ls_raw_wc_summary-last_execution_finish_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '010000'
      act = ls_raw_wc_summary-last_execution_finish_time ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_raw_wc_summary-exec_duration_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '50.00' )
      act = ls_raw_wc_summary-valid_exec_duration_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '2700' )
      act = ls_raw_wc_summary-exec_duration_seconds_total ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '2700' )
      act = ls_raw_wc_summary-exec_duration_seconds_avg ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_raw_wc_summary-invalid_exec_duration_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '50.00' )
      act = ls_raw_wc_summary-invalid_exec_duration_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_raw_wc_summary-missing_exec_duration_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_wc_summary-missing_exec_duration_pct ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-yield_quantity_total
      exp = CONV decfloat34( '3.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-yield_non_reversed_total
      exp = CONV decfloat34( '3.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'EA' ]-yield_quantity_total
      exp = CONV decfloat34( '2.000' ) ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'EA' ]-yield_non_reversed_total ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261010'
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'EA' ]-first_posting_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261010'
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'EA' ]-last_posting_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261010'
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'EA' ]-first_execution_start_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '100.00' )
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'EA' ]-execution_start_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = '233000'
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'EA' ]-first_execution_start_time ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261011'
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'EA' ]-last_execution_finish_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '001500'
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'EA' ]-last_execution_finish_time ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_duration_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '100.00' )
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'EA' ]-valid_exec_duration_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '2700' )
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_duration_seconds_total ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '2700' )
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_duration_seconds_avg ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'EA' ]-invalid_exec_duration_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'EA' ]-missing_exec_duration_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'EA' ]-partial_confirmation_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'EA' ]-reversed_confirmation_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '100.00' )
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'EA' ]-partial_confirmation_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '100.00' )
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'EA' ]-reversed_confirmation_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-final_confirmation_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '100.00' )
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-final_confirmation_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261011'
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-first_posting_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-execution_start_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '100.00' )
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-execution_start_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = '020000'
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-first_execution_start_time ).
    cl_abap_unit_assert=>assert_equals(
      exp = '010000'
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-last_execution_finish_time ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_duration_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-valid_exec_duration_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_duration_seconds_avg ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_duration_seconds_total ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-invalid_exec_duration_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '100.00' )
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-invalid_exec_duration_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_raw_wc_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-missing_exec_duration_count ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-base_quantities )
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_uom_repository->ratio_read_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_quantities[ 1 ]-confirmation_row-confirmation
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_quantities[ 1 ]-base_quantity_unit
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_quantities[ 1 ]-yield_quantity_base
      exp = CONV mard-labst( '2.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_quantities[ 1 ]-rework_quantity_base
      exp = CONV mard-labst( '0.500' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_quantities[ 1 ]-scrap_quantity_base
      exp = CONV mard-labst( '0.250' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_quantities[ 2 ]-confirmation_row-confirmation
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_quantities[ 2 ]-base_quantity_unit
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_quantities[ 2 ]-yield_quantity_base
      exp = CONV mard-labst( '36.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_quantities[ 2 ]-rework_quantity_base
      exp = CONV mard-labst( '3.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_quantities[ 2 ]-scrap_quantity_base
      exp = CONV mard-labst( '12.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_quantities[ 3 ]-yield_quantity_base
      exp = CONV mard-labst( '12.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_quantities[ 3 ]-rework_quantity_base
      exp = CONV mard-labst( '1.500' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_quantities[ 3 ]-scrap_quantity_base
      exp = CONV mard-labst( '6.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-base_operation_summaries )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-base_order_summaries )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-base_work_center_summaries )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_work_center_summaries[ 1 ]-work_center
      exp = 'WC-01' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_work_center_summaries[ 1 ]-base_quantity_unit
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_work_center_summaries[ 1 ]-confirmation_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_wc_summary-final_confirmation_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_wc_summary-partial_confirmation_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_wc_summary-reversed_confirmation_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_wc_summary-final_confirmation_pct
      exp = CONV decfloat34( '50.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_wc_summary-partial_confirmation_pct
      exp = CONV decfloat34( '50.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_wc_summary-reversed_confirmation_pct
      exp = CONV decfloat34( '50.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_wc_summary-first_posting_date
      exp = '20261010' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_wc_summary-last_posting_date
      exp = '20261011' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_base_wc_summary-execution_start_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '100.00' )
      act = ls_base_wc_summary-execution_start_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261010'
      act = ls_base_wc_summary-first_execution_start_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '233000'
      act = ls_base_wc_summary-first_execution_start_time ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_base_wc_summary-execution_finish_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '100.00' )
      act = ls_base_wc_summary-execution_finish_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261011'
      act = ls_base_wc_summary-last_execution_finish_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '010000'
      act = ls_base_wc_summary-last_execution_finish_time ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_base_wc_summary-exec_duration_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '50.00' )
      act = ls_base_wc_summary-valid_exec_duration_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '2700' )
      act = ls_base_wc_summary-exec_duration_seconds_total ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '2700' )
      act = ls_base_wc_summary-exec_duration_seconds_avg ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_base_wc_summary-invalid_exec_duration_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '50.00' )
      act = ls_base_wc_summary-invalid_exec_duration_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_base_wc_summary-missing_exec_duration_count ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_wc_summary-yield_quantity_base_total
      exp = CONV decfloat34( '38.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_wc_summary-yield_base_non_reversed_total
      exp = CONV decfloat34( '36.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_wc_summary-scrap_quantity_base_total
      exp = CONV decfloat34( '12.250' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_wc_summary_second-work_center
      exp = 'WC-02' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_base_wc_summary_second-execution_start_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_base_wc_summary_second-execution_start_pct ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_base_wc_summary_second-first_execution_start_date ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_base_wc_summary_second-first_execution_start_time ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_base_wc_summary_second-execution_finish_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '100.00' )
      act = ls_base_wc_summary_second-execution_finish_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261012'
      act = ls_base_wc_summary_second-last_execution_finish_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '000000'
      act = ls_base_wc_summary_second-last_execution_finish_time ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_base_wc_summary_second-exec_duration_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_wc_summary_second-valid_exec_duration_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_wc_summary_second-exec_duration_seconds_avg ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_base_wc_summary_second-exec_duration_seconds_total ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_base_wc_summary_second-invalid_exec_duration_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_base_wc_summary_second-missing_exec_duration_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '100.00' )
      act = ls_base_wc_summary_second-missing_exec_duration_pct ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_wc_summary_second-yield_quantity_base_total
      exp = CONV decfloat34( '12.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_order_summaries[ 1 ]-production_order
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_order_summaries[ 1 ]-base_quantity_unit
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_order_summaries[ 1 ]-confirmation_count
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_order_summaries[ 1 ]-final_confirmation_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_order_summaries[ 1 ]-partial_confirmation_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_order_summaries[ 1 ]-final_confirmation_pct
      exp = CONV decfloat34( '33.33' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_order_summaries[ 1 ]-partial_confirmation_pct
      exp = CONV decfloat34( '66.67' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_order_summaries[ 1 ]-reversed_confirmation_pct
      exp = CONV decfloat34( '33.33' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_order_summaries[ 1 ]-reversed_confirmation_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_order_summaries[ 1 ]-yield_quantity_base_total
      exp = CONV decfloat34( '50.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_order_summaries[ 1 ]-yield_base_non_reversed_total
      exp = CONV decfloat34( '48.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_order_summaries[ 1 ]-rework_quantity_base_total
      exp = CONV decfloat34( '5.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_order_summaries[ 1 ]-scrap_quantity_base_total
      exp = CONV decfloat34( '18.250' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_order_summaries[ 1 ]-rework_base_non_reversed_total
      exp = CONV decfloat34( '4.500' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_order_summaries[ 1 ]-scrap_base_non_reversed_total
      exp = CONV decfloat34( '18.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_order_summaries[ 1 ]-first_posting_date
      exp = '20261010' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_order_summaries[ 1 ]-last_posting_date
      exp = '20261012' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_order_summary-execution_start_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_order_summary-execution_start_pct
      exp = CONV decfloat34( '66.67' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_order_summary-first_execution_start_date
      exp = '20261010' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_order_summary-first_execution_start_time
      exp = '233000' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_order_summary-execution_finish_count
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_order_summary-execution_finish_pct
      exp = CONV decfloat34( '100.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_order_summary-last_execution_finish_date
      exp = '20261012' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_order_summary-last_execution_finish_time
      exp = '000000' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_order_summary-exec_duration_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_order_summary-valid_exec_duration_pct
      exp = CONV decfloat34( '33.33' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_order_summary-exec_duration_seconds_total
      exp = CONV decfloat34( '2700' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_order_summary-exec_duration_seconds_avg
      exp = CONV decfloat34( '2700' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_order_summary-invalid_exec_duration_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_order_summary-invalid_exec_duration_pct
      exp = CONV decfloat34( '33.33' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_order_summary-missing_exec_duration_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_order_summary-missing_exec_duration_pct
      exp = CONV decfloat34( '33.33' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_primary-base_quantity_unit
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_primary-resource_object_id
      exp = '00000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_primary-work_center
      exp = 'WC-01' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_primary-work_center_plant
      exp = '1000' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_primary-confirmation_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_operation_summaries[ 1 ]-final_confirmation_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_operation_summaries[ 1 ]-partial_confirmation_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_operation_summaries[ 1 ]-final_confirmation_pct
      exp = CONV decfloat34( '50.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_operation_summaries[ 1 ]-partial_confirmation_pct
      exp = CONV decfloat34( '50.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_operation_summaries[ 1 ]-reversed_confirmation_pct
      exp = CONV decfloat34( '50.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_operation_summaries[ 1 ]-reversed_confirmation_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_primary-first_posting_date
      exp = '20261010' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_primary-last_posting_date
      exp = '20261011' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_primary-execution_start_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_primary-execution_start_pct
      exp = CONV decfloat34( '100.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_primary-first_execution_start_date
      exp = '20261010' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_primary-first_execution_start_time
      exp = '233000' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_primary-execution_finish_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_primary-execution_finish_pct
      exp = CONV decfloat34( '100.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_primary-last_execution_finish_date
      exp = '20261011' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_primary-last_execution_finish_time
      exp = '010000' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_primary-exec_duration_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_primary-valid_exec_duration_pct
      exp = CONV decfloat34( '50.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_primary-exec_duration_seconds_total
      exp = CONV decfloat34( '2700' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_primary-exec_duration_seconds_avg
      exp = CONV decfloat34( '2700' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_primary-exec_duration_seconds_min
      exp = CONV decfloat34( '2700' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_primary-exec_duration_seconds_max
      exp = CONV decfloat34( '2700' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_primary-invalid_exec_duration_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_primary-invalid_exec_duration_pct
      exp = CONV decfloat34( '50.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_primary-missing_exec_duration_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_operation_summaries[ 1 ]-yield_quantity_base_total
      exp = CONV decfloat34( '38.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_operation_summaries[ 1 ]-yield_base_non_reversed_total
      exp = CONV decfloat34( '36.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_operation_summaries[ 1 ]-rework_quantity_base_total
      exp = CONV decfloat34( '3.500' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_operation_summaries[ 1 ]-rework_base_non_reversed_total
      exp = CONV decfloat34( '3.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_operation_summaries[ 1 ]-scrap_quantity_base_total
      exp = CONV decfloat34( '12.250' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_operation_summaries[ 1 ]-scrap_base_non_reversed_total
      exp = CONV decfloat34( '12.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_secondary-operation_counter
      exp = '00000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_secondary-resource_object_id
      exp = '00000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_secondary-execution_start_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_secondary-execution_start_pct
      exp = CONV decfloat34( '0' ) ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_base_operation_secondary-first_execution_start_date ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_secondary-execution_finish_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_secondary-execution_finish_pct
      exp = CONV decfloat34( '100.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_secondary-last_execution_finish_date
      exp = '20261012' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_secondary-last_execution_finish_time
      exp = '000000' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_secondary-exec_duration_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_secondary-valid_exec_duration_pct
      exp = CONV decfloat34( '0' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_secondary-exec_duration_seconds_total
      exp = CONV decfloat34( '0' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_secondary-exec_duration_seconds_avg
      exp = CONV decfloat34( '0' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_secondary-invalid_exec_duration_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_secondary-missing_exec_duration_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_base_operation_secondary-missing_exec_duration_pct
      exp = CONV decfloat34( '100.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_operation_summaries[ 2 ]-confirmation_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_operation_summaries[ 2 ]-yield_quantity_base_total
      exp = CONV decfloat34( '12.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_operation_summaries[ 2 ]-rework_quantity_base_total
      exp = CONV decfloat34( '1.500' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_operation_summaries[ 2 ]-scrap_quantity_base_total
      exp = CONV decfloat34( '6.000' ) ).
  ENDMETHOD.

  METHOD checks_avg_exec_duration.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order = '0000000001'
        production_item  = '0001'
        order_category   = '10'
        material         = 'MAT-1'
        plant            = '1000' ) ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = '0000000001'
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '080000'
        execution_finish_date = '20261010'
        execution_finish_time = '090000'
        quantity_unit         = 'EA' )
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = '0000000002'
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '100000'
        execution_finish_date = '20261010'
        execution_finish_time = '123001'
        quantity_unit         = 'EA' )
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = '0000000003'
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '140000'
        execution_finish_date = '20261010'
        execution_finish_time = '130000'
        quantity_unit         = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service(
      io_repository = lo_repository ).

    DATA(ls_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        posting_date_from = '20261001'
        posting_date_to   = '20261031'
        maximum_results   = 10 ) ).
    DATA(ls_valid_confirmation) = ls_result-confirmations[
      confirmation = '0000000001' ].
    DATA(ls_valid_confirmation_long) = ls_result-confirmations[
      confirmation = '0000000002' ].
    DATA(ls_invalid_confirmation) = ls_result-confirmations[
      confirmation = '0000000003' ].

    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-operation_summaries )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'V'
      act = ls_valid_confirmation-exec_duration_status ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'I'
      act = ls_invalid_confirmation-exec_duration_status ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_valid_confirmation-exec_duration_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '9001' )
      act = ls_valid_confirmation_long-exec_duration_seconds ).
    cl_abap_unit_assert=>assert_initial(
      ls_invalid_confirmation-exec_duration_seconds ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-exec_duration_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-zero_exec_duration_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-zero_exec_duration_pct
      exp = CONV decfloat34( '0' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-valid_exec_duration_pct
      exp = CONV decfloat34( '66.67' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-exec_duration_seconds_total
      exp = CONV decfloat34( '12601' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-exec_duration_seconds_min
      exp = CONV decfloat34( '3600' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-exec_duration_seconds_max
      exp = CONV decfloat34( '9001' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-exec_duration_seconds_avg
      exp = CONV decfloat34( '6300.5' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-invalid_exec_duration_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-invalid_exec_duration_pct
      exp = CONV decfloat34( '33.33' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-missing_exec_duration_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-order_summaries[ 1 ]-exec_duration_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-order_summaries[ 1 ]-valid_exec_duration_pct
      exp = CONV decfloat34( '66.67' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-order_summaries[ 1 ]-invalid_exec_duration_pct
      exp = CONV decfloat34( '33.33' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-order_summaries[ 1 ]-missing_exec_duration_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-order_summaries[ 1 ]-exec_duration_seconds_avg
      exp = CONV decfloat34( '6300.5' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-order_summaries[ 1 ]-exec_duration_seconds_min
      exp = CONV decfloat34( '3600' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-order_summaries[ 1 ]-exec_duration_seconds_max
      exp = CONV decfloat34( '9001' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-work_center_summaries[ 1 ]-exec_duration_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-work_center_summaries[ 1 ]-valid_exec_duration_pct
      exp = CONV decfloat34( '66.67' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-work_center_summaries[ 1 ]-exec_duration_seconds_avg
      exp = CONV decfloat34( '6300.5' ) ).
  ENDMETHOD.

  METHOD checks_exec_duration_union.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order = '0000000001'
        production_item  = '0001'
        order_category   = '10'
        material         = 'MAT-1'
        plant            = '1000' ) ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = '0000000001'
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '080000'
        execution_finish_date = '20261010'
        execution_finish_time = '100000'
        yield_quantity        = '1.000'
        quantity_unit         = 'EA' )
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = '0000000002'
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '090000'
        execution_finish_date = '20261010'
        execution_finish_time = '110000'
        yield_quantity        = '1.000'
        quantity_unit         = 'BOX'
        is_reversed           = 'X' )
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = '0000000003'
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '120000'
        execution_finish_date = '20261010'
        execution_finish_time = '130000'
        yield_quantity        = '1.000'
        quantity_unit         = 'EA' )
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = '0000000004'
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '233000'
        execution_finish_date = '20261011'
        execution_finish_time = '000000'
        yield_quantity        = '1.000'
        quantity_unit         = 'EA' )
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = '0000000005'
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '093000'
        execution_finish_date = '20261010'
        execution_finish_time = '093000'
        yield_quantity        = '1.000'
        quantity_unit         = 'EA' )
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = '0000000006'
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '093000'
        execution_finish_date = '20261010'
        execution_finish_time = '103000'
        yield_quantity        = '1.000'
        quantity_unit         = 'BOX' )
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = '0000000007'
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '060000'
        execution_finish_date = '20261010'
        execution_finish_time = '060000'
        yield_quantity        = '1.000'
        quantity_unit         = 'EA' )
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = '0000000008'
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261011'
        execution_start_time  = '010000'
        execution_finish_date = '20261011'
        execution_finish_time = '010000'
        yield_quantity        = '1.000'
        quantity_unit         = 'EA' ) ).
    DATA(lo_uom_repository) = NEW lcl_prod_order_uom_repo( ).
    lo_uom_repository->base_unit = 'EA'.
    lo_uom_repository->alternative_unit = 'BOX'.
    lo_uom_repository->numerator = 12.
    lo_uom_repository->denominator = 1.
    DATA(lo_uom_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service(
      io_repository    = lo_repository
      io_uom_converter = lo_uom_converter ).
    DATA(ls_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        posting_date_from = '20261001'
        posting_date_to   = '20261031'
        maximum_results   = 10 ) ).

    DATA(ls_work_center_summary) = ls_result-work_center_summaries[ 1 ].
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '23400' )
      act = ls_work_center_summary-exec_duration_seconds_total ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '16200' )
      act = ls_work_center_summary-exec_covered_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '14400' )
      act = ls_work_center_summary-exec_nonrev_covered_secs ).
      cl_abap_unit_assert=>assert_equals(
        exp = 7
        act = ls_work_center_summary-exec_nonrev_duration_count ).
      cl_abap_unit_assert=>assert_equals(
        exp = CONV decfloat34( '16200' )
        act = ls_work_center_summary-exec_nonrev_total_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '16200' ) / 7
          act = ls_work_center_summary-exec_nonrev_duration_avg_secs ).
      cl_abap_unit_assert=>assert_equals(
        exp = CONV decfloat34( '1800' )
        act = ls_work_center_summary-exec_nonrev_excess_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = 1
          act = ls_work_center_summary-exec_reversed_duration_count ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_work_center_summary-exec_reversed_total_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_work_center_summary-exec_rev_duration_avg_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_work_center_summary-exec_reversed_covered_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_work_center_summary-exec_reversed_excess_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '69.23' )
          act = ls_work_center_summary-exec_nonrev_duration_pct ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '30.77' )
          act = ls_work_center_summary-exec_reversed_duration_pct ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '2700' )
          act = ls_work_center_summary-exec_duration_seconds_median ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '2700' )
          act = ls_work_center_summary-exec_duration_seconds_mad ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_work_center_summary-exec_duration_seconds_p90 ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_work_center_summary-exec_duration_seconds_p95 ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_work_center_summary-exec_nonrev_p90_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_work_center_summary-exec_reversed_p90_secs ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '1800' )
          act = ls_work_center_summary-exec_nonrev_mad_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_work_center_summary-exec_reversed_mad_secs ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '1800' )
          act = ls_work_center_summary-exec_nonrev_median_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_work_center_summary-exec_reversed_median_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_work_center_summary-exec_overlap_excess_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = ls_work_center_summary-exec_peak_concurrency ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_work_center_summary-exec_peak_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3.13' )
      act = ls_work_center_summary-exec_peak_concurrency_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_work_center_summary-exec_peak_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_work_center_summary-exec_longest_peak_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_work_center_summary-exec_peak_episode_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0.40625' )
      act = ls_work_center_summary-exec_avg_concurrency ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '41400' )
      act = ls_work_center_summary-exec_idle_gap_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '37800' )
      act = ls_work_center_summary-exec_longest_idle_gap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_work_center_summary-exec_idle_gap_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '20700' )
      act = ls_work_center_summary-exec_idle_gap_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '28.13' )
      act = ls_work_center_summary-exec_interval_coverage_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '9.38' )
      act = ls_work_center_summary-exec_overlap_wall_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '10800' )
      act = ls_work_center_summary-exec_single_active_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = ls_work_center_summary-exec_single_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-exec_longest_single_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '2700' )
      act = ls_work_center_summary-exec_single_active_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_work_center_summary-exec_high_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-exec_exactly_two_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '9000' )
      act = ls_work_center_summary-exec_pairwise_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = ls_work_center_summary-exec_overlap_pair_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3000' )
      act = ls_work_center_summary-exec_overlap_pair_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-exec_longest_pair_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '6.25' )
      act = ls_work_center_summary-exec_exactly_two_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3.13' )
      act = ls_work_center_summary-exec_3plus_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_work_center_summary-exec_3plus_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_work_center_summary-exec_longest_3plus_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_work_center_summary-exec_3plus_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '18.75' )
      act = ls_work_center_summary-exec_single_active_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '5400' )
      act = ls_work_center_summary-exec_overlap_wall_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_work_center_summary-exec_overlap_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '5400' )
      act = ls_work_center_summary-exec_longest_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '5400' )
      act = ls_work_center_summary-exec_overlap_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '12600' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_covered_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '12600' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_nonrev_covered_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 6
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_nonrev_duration_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '12600' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_nonrev_total_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '12600' ) / 6
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_nonrev_duration_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_nonrev_excess_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = 0
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_reversed_duration_count ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_reversed_total_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_rev_duration_avg_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_reversed_covered_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_reversed_excess_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '100.00' )
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_nonrev_duration_pct ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0.00' )
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_reversed_duration_pct ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '900' )
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_duration_seconds_median ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_duration_seconds_p90 ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_duration_seconds_p95 ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_nonrev_p90_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_reversed_p90_secs ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '900' )
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_nonrev_mad_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_reversed_mad_secs ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '900' )
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_nonrev_median_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_reversed_median_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_overlap_excess_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_peak_concurrency ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '12600' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_peak_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '21.88' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_peak_concurrency_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_peak_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_longest_peak_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '4200' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_peak_episode_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0.21875' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_avg_concurrency ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '45000' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_idle_gap_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '37800' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_longest_idle_gap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_idle_gap_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '22500' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_idle_gap_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '21.88' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_interval_coverage_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0.00' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_overlap_wall_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '12600' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_single_active_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_single_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_longest_single_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '4200' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_single_active_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_high_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_exactly_two_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_pairwise_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_overlap_pair_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_overlap_pair_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_longest_pair_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_exactly_two_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_3plus_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_3plus_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_longest_3plus_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_3plus_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '21.88' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_single_active_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_overlap_wall_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_overlap_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_longest_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_covered_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_nonrev_covered_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_nonrev_duration_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_nonrev_total_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '3600' )
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_nonrev_duration_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_nonrev_excess_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = 1
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_reversed_duration_count ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_reversed_total_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_rev_duration_avg_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_reversed_covered_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_reversed_excess_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '33.33' )
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_nonrev_duration_pct ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '66.67' )
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_reversed_duration_pct ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '5400' )
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_duration_seconds_median ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_duration_seconds_p90 ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_duration_seconds_p95 ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '3600' )
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_nonrev_p90_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_reversed_p90_secs ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_nonrev_mad_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_reversed_mad_secs ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '3600' )
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_nonrev_median_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_reversed_median_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_overlap_excess_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_peak_concurrency ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_peak_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '50.00' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_peak_concurrency_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_peak_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_longest_peak_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_peak_episode_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1.5' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_avg_concurrency ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_idle_gap_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_longest_idle_gap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_idle_gap_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_idle_gap_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '100.00' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_interval_coverage_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '50.00' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_overlap_wall_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_single_active_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_single_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_longest_single_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_single_active_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_high_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_exactly_two_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_pairwise_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_overlap_pair_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_overlap_pair_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_longest_pair_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '50.00' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_exactly_two_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_3plus_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_3plus_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_longest_3plus_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_3plus_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '50.00' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_single_active_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_overlap_wall_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_overlap_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_longest_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_overlap_avg_secs ).
    DATA(ls_raw_operation_ea) = ls_result-operation_summaries[
      quantity_unit = 'EA' ].
    DATA(ls_raw_operation_box) = ls_result-operation_summaries[
      quantity_unit = 'BOX' ].
    DATA(ls_raw_order_ea) = ls_result-order_summaries[
      quantity_unit = 'EA' ].
    DATA(ls_raw_order_box) = ls_result-order_summaries[
      quantity_unit = 'BOX' ].
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '12600' )
      act = ls_raw_operation_ea-exec_covered_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '12600' )
      act = ls_raw_operation_ea-exec_nonrev_covered_secs ).
      cl_abap_unit_assert=>assert_equals(
        exp = 6
        act = ls_raw_operation_ea-exec_nonrev_duration_count ).
      cl_abap_unit_assert=>assert_equals(
        exp = CONV decfloat34( '12600' )
        act = ls_raw_operation_ea-exec_nonrev_total_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '12600' ) / 6
          act = ls_raw_operation_ea-exec_nonrev_duration_avg_secs ).
      cl_abap_unit_assert=>assert_equals(
        exp = CONV decfloat34( '0' )
        act = ls_raw_operation_ea-exec_nonrev_excess_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = 0
          act = ls_raw_operation_ea-exec_reversed_duration_count ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_raw_operation_ea-exec_reversed_total_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_raw_operation_ea-exec_rev_duration_avg_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_raw_operation_ea-exec_reversed_covered_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_raw_operation_ea-exec_reversed_excess_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '100.00' )
          act = ls_raw_operation_ea-exec_nonrev_duration_pct ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0.00' )
          act = ls_raw_operation_ea-exec_reversed_duration_pct ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '900' )
          act = ls_raw_operation_ea-exec_duration_seconds_median ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_raw_operation_ea-exec_duration_seconds_p90 ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_raw_operation_ea-exec_duration_seconds_p95 ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_raw_operation_ea-exec_nonrev_p90_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_raw_operation_ea-exec_reversed_p90_secs ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '900' )
          act = ls_raw_operation_ea-exec_nonrev_mad_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_raw_operation_ea-exec_reversed_mad_secs ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '900' )
          act = ls_raw_operation_ea-exec_nonrev_median_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_raw_operation_ea-exec_reversed_median_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_raw_operation_ea-exec_peak_concurrency ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '12600' )
      act = ls_raw_operation_ea-exec_peak_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '21.88' )
      act = ls_raw_operation_ea-exec_peak_concurrency_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = ls_raw_operation_ea-exec_peak_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_raw_operation_ea-exec_longest_peak_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '4200' )
      act = ls_raw_operation_ea-exec_peak_episode_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0.21875' )
      act = ls_raw_operation_ea-exec_avg_concurrency ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '45000' )
      act = ls_raw_operation_ea-exec_idle_gap_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '37800' )
      act = ls_raw_operation_ea-exec_longest_idle_gap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_raw_operation_ea-exec_idle_gap_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '22500' )
      act = ls_raw_operation_ea-exec_idle_gap_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '21.88' )
      act = ls_raw_operation_ea-exec_interval_coverage_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0.00' )
      act = ls_raw_operation_ea-exec_overlap_wall_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_raw_operation_ea-exec_overlap_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '12600' )
      act = ls_raw_operation_ea-exec_single_active_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = ls_raw_operation_ea-exec_single_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_raw_operation_ea-exec_longest_single_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '4200' )
      act = ls_raw_operation_ea-exec_single_active_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_ea-exec_high_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_ea-exec_exactly_two_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_ea-exec_pairwise_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_raw_operation_ea-exec_overlap_pair_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_ea-exec_overlap_pair_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_ea-exec_longest_pair_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_ea-exec_exactly_two_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_ea-exec_3plus_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_raw_operation_ea-exec_3plus_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_ea-exec_longest_3plus_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_ea-exec_3plus_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '21.88' )
      act = ls_raw_operation_ea-exec_single_active_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_ea-exec_overlap_wall_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_ea-exec_longest_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_raw_operation_box-exec_covered_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_operation_box-exec_nonrev_covered_secs ).
      cl_abap_unit_assert=>assert_equals(
        exp = 1
        act = ls_raw_operation_box-exec_nonrev_duration_count ).
      cl_abap_unit_assert=>assert_equals(
        exp = CONV decfloat34( '3600' )
        act = ls_raw_operation_box-exec_nonrev_total_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '3600' )
          act = ls_raw_operation_box-exec_nonrev_duration_avg_secs ).
      cl_abap_unit_assert=>assert_equals(
        exp = CONV decfloat34( '0' )
        act = ls_raw_operation_box-exec_nonrev_excess_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = 1
          act = ls_raw_operation_box-exec_reversed_duration_count ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_raw_operation_box-exec_reversed_total_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_raw_operation_box-exec_rev_duration_avg_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_raw_operation_box-exec_reversed_covered_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_raw_operation_box-exec_reversed_excess_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '33.33' )
          act = ls_raw_operation_box-exec_nonrev_duration_pct ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '66.67' )
          act = ls_raw_operation_box-exec_reversed_duration_pct ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '5400' )
          act = ls_raw_operation_box-exec_duration_seconds_median ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_raw_operation_box-exec_duration_seconds_p90 ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_raw_operation_box-exec_duration_seconds_p95 ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '3600' )
          act = ls_raw_operation_box-exec_nonrev_p90_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_raw_operation_box-exec_reversed_p90_secs ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_raw_operation_box-exec_nonrev_mad_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_raw_operation_box-exec_reversed_mad_secs ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '3600' )
          act = ls_raw_operation_box-exec_nonrev_median_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_raw_operation_box-exec_reversed_median_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_operation_box-exec_overlap_excess_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_raw_operation_box-exec_peak_concurrency ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_operation_box-exec_peak_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '50.00' )
      act = ls_raw_operation_box-exec_peak_concurrency_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_raw_operation_box-exec_peak_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_operation_box-exec_longest_peak_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_operation_box-exec_peak_episode_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1.5' )
      act = ls_raw_operation_box-exec_avg_concurrency ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_box-exec_idle_gap_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_box-exec_longest_idle_gap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_raw_operation_box-exec_idle_gap_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_box-exec_idle_gap_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '100.00' )
      act = ls_raw_operation_box-exec_interval_coverage_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '50.00' )
      act = ls_raw_operation_box-exec_overlap_wall_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_operation_box-exec_single_active_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_raw_operation_box-exec_single_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_raw_operation_box-exec_longest_single_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_raw_operation_box-exec_single_active_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_box-exec_high_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_operation_box-exec_exactly_two_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_operation_box-exec_pairwise_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_raw_operation_box-exec_overlap_pair_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_operation_box-exec_overlap_pair_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_operation_box-exec_longest_pair_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '50.00' )
      act = ls_raw_operation_box-exec_exactly_two_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_box-exec_3plus_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_raw_operation_box-exec_3plus_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_box-exec_longest_3plus_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_box-exec_3plus_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '50.00' )
      act = ls_raw_operation_box-exec_single_active_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_operation_box-exec_overlap_wall_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_raw_operation_box-exec_overlap_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_operation_box-exec_longest_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '12600' )
      act = ls_raw_order_ea-exec_covered_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '12600' )
      act = ls_raw_order_ea-exec_nonrev_covered_secs ).
      cl_abap_unit_assert=>assert_equals(
        exp = 6
        act = ls_raw_order_ea-exec_nonrev_duration_count ).
      cl_abap_unit_assert=>assert_equals(
        exp = CONV decfloat34( '12600' )
        act = ls_raw_order_ea-exec_nonrev_total_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '12600' ) / 6
          act = ls_raw_order_ea-exec_nonrev_duration_avg_secs ).
      cl_abap_unit_assert=>assert_equals(
        exp = CONV decfloat34( '0' )
        act = ls_raw_order_ea-exec_nonrev_excess_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = 0
          act = ls_raw_order_ea-exec_reversed_duration_count ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_raw_order_ea-exec_reversed_total_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_raw_order_ea-exec_rev_duration_avg_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_raw_order_ea-exec_reversed_covered_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_raw_order_ea-exec_reversed_excess_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '100.00' )
          act = ls_raw_order_ea-exec_nonrev_duration_pct ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0.00' )
          act = ls_raw_order_ea-exec_reversed_duration_pct ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '900' )
          act = ls_raw_order_ea-exec_duration_seconds_median ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_raw_order_ea-exec_duration_seconds_p90 ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_raw_order_ea-exec_duration_seconds_p95 ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_raw_order_ea-exec_nonrev_p90_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_raw_order_ea-exec_reversed_p90_secs ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '900' )
          act = ls_raw_order_ea-exec_nonrev_mad_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_raw_order_ea-exec_reversed_mad_secs ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '900' )
          act = ls_raw_order_ea-exec_nonrev_median_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_raw_order_ea-exec_reversed_median_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_raw_order_ea-exec_peak_concurrency ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '12600' )
      act = ls_raw_order_ea-exec_peak_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '21.88' )
      act = ls_raw_order_ea-exec_peak_concurrency_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = ls_raw_order_ea-exec_peak_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_raw_order_ea-exec_longest_peak_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '4200' )
      act = ls_raw_order_ea-exec_peak_episode_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0.21875' )
      act = ls_raw_order_ea-exec_avg_concurrency ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '45000' )
      act = ls_raw_order_ea-exec_idle_gap_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '37800' )
      act = ls_raw_order_ea-exec_longest_idle_gap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_raw_order_ea-exec_idle_gap_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '22500' )
      act = ls_raw_order_ea-exec_idle_gap_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '21.88' )
      act = ls_raw_order_ea-exec_interval_coverage_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0.00' )
      act = ls_raw_order_ea-exec_overlap_wall_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_raw_order_ea-exec_overlap_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '12600' )
      act = ls_raw_order_ea-exec_single_active_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = ls_raw_order_ea-exec_single_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_raw_order_ea-exec_longest_single_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '4200' )
      act = ls_raw_order_ea-exec_single_active_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_ea-exec_high_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_ea-exec_exactly_two_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_ea-exec_pairwise_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_raw_order_ea-exec_overlap_pair_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_ea-exec_overlap_pair_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_ea-exec_longest_pair_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_ea-exec_exactly_two_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_ea-exec_3plus_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_raw_order_ea-exec_3plus_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_ea-exec_longest_3plus_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_ea-exec_3plus_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '21.88' )
      act = ls_raw_order_ea-exec_single_active_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_ea-exec_overlap_wall_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_ea-exec_longest_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_raw_order_box-exec_covered_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_order_box-exec_nonrev_covered_secs ).
      cl_abap_unit_assert=>assert_equals(
        exp = 1
        act = ls_raw_order_box-exec_nonrev_duration_count ).
      cl_abap_unit_assert=>assert_equals(
        exp = CONV decfloat34( '3600' )
        act = ls_raw_order_box-exec_nonrev_total_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '3600' )
          act = ls_raw_order_box-exec_nonrev_duration_avg_secs ).
      cl_abap_unit_assert=>assert_equals(
        exp = CONV decfloat34( '0' )
        act = ls_raw_order_box-exec_nonrev_excess_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = 1
          act = ls_raw_order_box-exec_reversed_duration_count ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_raw_order_box-exec_reversed_total_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_raw_order_box-exec_rev_duration_avg_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_raw_order_box-exec_reversed_covered_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_raw_order_box-exec_reversed_excess_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '33.33' )
          act = ls_raw_order_box-exec_nonrev_duration_pct ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '66.67' )
          act = ls_raw_order_box-exec_reversed_duration_pct ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '5400' )
          act = ls_raw_order_box-exec_duration_seconds_median ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_raw_order_box-exec_duration_seconds_p90 ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_raw_order_box-exec_duration_seconds_p95 ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '3600' )
          act = ls_raw_order_box-exec_nonrev_p90_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_raw_order_box-exec_reversed_p90_secs ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_raw_order_box-exec_nonrev_mad_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_raw_order_box-exec_reversed_mad_secs ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '3600' )
          act = ls_raw_order_box-exec_nonrev_median_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_raw_order_box-exec_reversed_median_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_order_box-exec_overlap_excess_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_raw_order_box-exec_peak_concurrency ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_order_box-exec_peak_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '50.00' )
      act = ls_raw_order_box-exec_peak_concurrency_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_raw_order_box-exec_peak_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_order_box-exec_longest_peak_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_order_box-exec_peak_episode_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1.5' )
      act = ls_raw_order_box-exec_avg_concurrency ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_box-exec_idle_gap_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_box-exec_longest_idle_gap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_raw_order_box-exec_idle_gap_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_box-exec_idle_gap_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '100.00' )
      act = ls_raw_order_box-exec_interval_coverage_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '50.00' )
      act = ls_raw_order_box-exec_overlap_wall_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_order_box-exec_single_active_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_raw_order_box-exec_single_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_raw_order_box-exec_longest_single_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_raw_order_box-exec_single_active_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_box-exec_high_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_order_box-exec_exactly_two_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_order_box-exec_pairwise_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_raw_order_box-exec_overlap_pair_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_order_box-exec_overlap_pair_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_order_box-exec_longest_pair_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '50.00' )
      act = ls_raw_order_box-exec_exactly_two_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_box-exec_3plus_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_raw_order_box-exec_3plus_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_box-exec_longest_3plus_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_box-exec_3plus_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '50.00' )
      act = ls_raw_order_box-exec_single_active_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_order_box-exec_overlap_wall_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_raw_order_box-exec_overlap_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_order_box-exec_longest_overlap_secs ).

    DATA(ls_base_result) = lo_cut->search_conf_window_base_unit(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        posting_date_from = '20261001'
        posting_date_to   = '20261031'
        maximum_results   = 10 ) ).
    DATA(ls_base_work_center_summary) =
      ls_base_result-base_work_center_summaries[ 1 ].
    DATA(ls_base_operation_summary) =
      ls_base_result-base_operation_summaries[ 1 ].
    DATA(ls_base_order_summary) = ls_base_result-base_order_summaries[ 1 ].
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '16200' )
      act = ls_base_work_center_summary-exec_covered_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '14400' )
      act = ls_base_work_center_summary-exec_nonrev_covered_secs ).
      cl_abap_unit_assert=>assert_equals(
        exp = 7
        act = ls_base_work_center_summary-exec_nonrev_duration_count ).
      cl_abap_unit_assert=>assert_equals(
        exp = CONV decfloat34( '16200' )
        act = ls_base_work_center_summary-exec_nonrev_total_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '16200' ) / 7
          act = ls_base_work_center_summary-exec_nonrev_duration_avg_secs ).
      cl_abap_unit_assert=>assert_equals(
        exp = CONV decfloat34( '1800' )
        act = ls_base_work_center_summary-exec_nonrev_excess_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = 1
          act = ls_base_work_center_summary-exec_reversed_duration_count ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_base_work_center_summary-exec_reversed_total_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_base_work_center_summary-exec_rev_duration_avg_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_base_work_center_summary-exec_reversed_covered_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_base_work_center_summary-exec_reversed_excess_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '69.23' )
          act = ls_base_work_center_summary-exec_nonrev_duration_pct ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '30.77' )
          act = ls_base_work_center_summary-exec_reversed_duration_pct ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '2700' )
          act = ls_base_work_center_summary-exec_duration_seconds_median ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_base_work_center_summary-exec_duration_seconds_p90 ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_base_work_center_summary-exec_duration_seconds_p95 ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_base_work_center_summary-exec_nonrev_p90_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_base_work_center_summary-exec_reversed_p90_secs ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '1800' )
          act = ls_base_work_center_summary-exec_nonrev_mad_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_base_work_center_summary-exec_reversed_mad_secs ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '1800' )
          act = ls_base_work_center_summary-exec_nonrev_median_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_base_work_center_summary-exec_reversed_median_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_base_work_center_summary-exec_overlap_excess_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = ls_base_work_center_summary-exec_peak_concurrency ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_base_work_center_summary-exec_peak_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3.13' )
      act = ls_base_work_center_summary-exec_peak_concurrency_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_base_work_center_summary-exec_peak_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_base_work_center_summary-exec_longest_peak_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_base_work_center_summary-exec_peak_episode_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0.40625' )
      act = ls_base_work_center_summary-exec_avg_concurrency ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '41400' )
      act = ls_base_work_center_summary-exec_idle_gap_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '37800' )
      act = ls_base_work_center_summary-exec_longest_idle_gap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_base_work_center_summary-exec_idle_gap_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '20700' )
      act = ls_base_work_center_summary-exec_idle_gap_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '28.13' )
      act = ls_base_work_center_summary-exec_interval_coverage_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '9.38' )
      act = ls_base_work_center_summary-exec_overlap_wall_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '10800' )
      act = ls_base_work_center_summary-exec_single_active_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = ls_base_work_center_summary-exec_single_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_base_work_center_summary-exec_longest_single_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '2700' )
      act = ls_base_work_center_summary-exec_single_active_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_base_work_center_summary-exec_high_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_base_work_center_summary-exec_exactly_two_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '9000' )
      act = ls_base_work_center_summary-exec_pairwise_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = ls_base_work_center_summary-exec_overlap_pair_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3000' )
      act = ls_base_work_center_summary-exec_overlap_pair_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_base_work_center_summary-exec_longest_pair_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '6.25' )
      act = ls_base_work_center_summary-exec_exactly_two_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3.13' )
      act = ls_base_work_center_summary-exec_3plus_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_base_work_center_summary-exec_3plus_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_base_work_center_summary-exec_longest_3plus_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_base_work_center_summary-exec_3plus_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '18.75' )
      act = ls_base_work_center_summary-exec_single_active_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '5400' )
      act = ls_base_work_center_summary-exec_overlap_wall_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_base_work_center_summary-exec_overlap_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '5400' )
      act = ls_base_work_center_summary-exec_longest_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '16200' )
      act = ls_base_operation_summary-exec_covered_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '14400' )
      act = ls_base_operation_summary-exec_nonrev_covered_secs ).
      cl_abap_unit_assert=>assert_equals(
        exp = 7
        act = ls_base_operation_summary-exec_nonrev_duration_count ).
      cl_abap_unit_assert=>assert_equals(
        exp = CONV decfloat34( '16200' )
        act = ls_base_operation_summary-exec_nonrev_total_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '16200' ) / 7
          act = ls_base_operation_summary-exec_nonrev_duration_avg_secs ).
      cl_abap_unit_assert=>assert_equals(
        exp = CONV decfloat34( '1800' )
        act = ls_base_operation_summary-exec_nonrev_excess_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = 1
          act = ls_base_operation_summary-exec_reversed_duration_count ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_base_operation_summary-exec_reversed_total_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_base_operation_summary-exec_rev_duration_avg_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_base_operation_summary-exec_reversed_covered_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_base_operation_summary-exec_reversed_excess_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '69.23' )
          act = ls_base_operation_summary-exec_nonrev_duration_pct ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '30.77' )
          act = ls_base_operation_summary-exec_reversed_duration_pct ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '2700' )
          act = ls_base_operation_summary-exec_duration_seconds_median ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_base_operation_summary-exec_duration_seconds_p90 ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_base_operation_summary-exec_duration_seconds_p95 ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_base_operation_summary-exec_nonrev_p90_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_base_operation_summary-exec_reversed_p90_secs ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '1800' )
          act = ls_base_operation_summary-exec_nonrev_mad_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_base_operation_summary-exec_reversed_mad_secs ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '1800' )
          act = ls_base_operation_summary-exec_nonrev_median_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_base_operation_summary-exec_reversed_median_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_base_operation_summary-exec_overlap_excess_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = ls_base_operation_summary-exec_peak_concurrency ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_base_operation_summary-exec_peak_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3.13' )
      act = ls_base_operation_summary-exec_peak_concurrency_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_base_operation_summary-exec_peak_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_base_operation_summary-exec_longest_peak_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_base_operation_summary-exec_peak_episode_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0.40625' )
      act = ls_base_operation_summary-exec_avg_concurrency ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '41400' )
      act = ls_base_operation_summary-exec_idle_gap_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '37800' )
      act = ls_base_operation_summary-exec_longest_idle_gap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_base_operation_summary-exec_idle_gap_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '20700' )
      act = ls_base_operation_summary-exec_idle_gap_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '28.13' )
      act = ls_base_operation_summary-exec_interval_coverage_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '9.38' )
      act = ls_base_operation_summary-exec_overlap_wall_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '10800' )
      act = ls_base_operation_summary-exec_single_active_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = ls_base_operation_summary-exec_single_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_base_operation_summary-exec_longest_single_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '2700' )
      act = ls_base_operation_summary-exec_single_active_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_base_operation_summary-exec_high_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_base_operation_summary-exec_exactly_two_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '9000' )
      act = ls_base_operation_summary-exec_pairwise_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = ls_base_operation_summary-exec_overlap_pair_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3000' )
      act = ls_base_operation_summary-exec_overlap_pair_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_base_operation_summary-exec_longest_pair_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '6.25' )
      act = ls_base_operation_summary-exec_exactly_two_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3.13' )
      act = ls_base_operation_summary-exec_3plus_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_base_operation_summary-exec_3plus_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_base_operation_summary-exec_longest_3plus_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_base_operation_summary-exec_3plus_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '18.75' )
      act = ls_base_operation_summary-exec_single_active_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '5400' )
      act = ls_base_operation_summary-exec_overlap_wall_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_base_operation_summary-exec_overlap_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '5400' )
      act = ls_base_operation_summary-exec_longest_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '16200' )
      act = ls_base_order_summary-exec_covered_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '14400' )
      act = ls_base_order_summary-exec_nonrev_covered_secs ).
      cl_abap_unit_assert=>assert_equals(
        exp = 7
        act = ls_base_order_summary-exec_nonrev_duration_count ).
      cl_abap_unit_assert=>assert_equals(
        exp = CONV decfloat34( '16200' )
        act = ls_base_order_summary-exec_nonrev_total_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '16200' ) / 7
          act = ls_base_order_summary-exec_nonrev_duration_avg_secs ).
      cl_abap_unit_assert=>assert_equals(
        exp = CONV decfloat34( '1800' )
        act = ls_base_order_summary-exec_nonrev_excess_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = 1
          act = ls_base_order_summary-exec_reversed_duration_count ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_base_order_summary-exec_reversed_total_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_base_order_summary-exec_rev_duration_avg_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_base_order_summary-exec_reversed_covered_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_base_order_summary-exec_reversed_excess_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '69.23' )
          act = ls_base_order_summary-exec_nonrev_duration_pct ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '30.77' )
          act = ls_base_order_summary-exec_reversed_duration_pct ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '2700' )
          act = ls_base_order_summary-exec_duration_seconds_median ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_base_order_summary-exec_duration_seconds_p90 ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_base_order_summary-exec_duration_seconds_p95 ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_base_order_summary-exec_nonrev_p90_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_base_order_summary-exec_reversed_p90_secs ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '1800' )
          act = ls_base_order_summary-exec_nonrev_mad_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '0' )
          act = ls_base_order_summary-exec_reversed_mad_secs ).

        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '1800' )
          act = ls_base_order_summary-exec_nonrev_median_secs ).
        cl_abap_unit_assert=>assert_equals(
          exp = CONV decfloat34( '7200' )
          act = ls_base_order_summary-exec_reversed_median_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_base_order_summary-exec_overlap_excess_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = ls_base_order_summary-exec_peak_concurrency ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_base_order_summary-exec_peak_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3.13' )
      act = ls_base_order_summary-exec_peak_concurrency_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_base_order_summary-exec_peak_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_base_order_summary-exec_longest_peak_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_base_order_summary-exec_peak_episode_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0.40625' )
      act = ls_base_order_summary-exec_avg_concurrency ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '41400' )
      act = ls_base_order_summary-exec_idle_gap_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '37800' )
      act = ls_base_order_summary-exec_longest_idle_gap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_base_order_summary-exec_idle_gap_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '20700' )
      act = ls_base_order_summary-exec_idle_gap_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '28.13' )
      act = ls_base_order_summary-exec_interval_coverage_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '9.38' )
      act = ls_base_order_summary-exec_overlap_wall_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '10800' )
      act = ls_base_order_summary-exec_single_active_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = ls_base_order_summary-exec_single_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_base_order_summary-exec_longest_single_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '2700' )
      act = ls_base_order_summary-exec_single_active_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_base_order_summary-exec_high_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_base_order_summary-exec_exactly_two_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '9000' )
      act = ls_base_order_summary-exec_pairwise_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = ls_base_order_summary-exec_overlap_pair_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3000' )
      act = ls_base_order_summary-exec_overlap_pair_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_base_order_summary-exec_longest_pair_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '6.25' )
      act = ls_base_order_summary-exec_exactly_two_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3.13' )
      act = ls_base_order_summary-exec_3plus_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_base_order_summary-exec_3plus_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_base_order_summary-exec_longest_3plus_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_base_order_summary-exec_3plus_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '18.75' )
      act = ls_base_order_summary-exec_single_active_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '5400' )
      act = ls_base_order_summary-exec_overlap_wall_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_base_order_summary-exec_overlap_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '5400' )
      act = ls_base_order_summary-exec_longest_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '5400' )
      act = ls_base_order_summary-exec_overlap_avg_secs ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-exec_nonrev_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_work_center_summary-exec_nonrev_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_work_center_summary-exec_reversed_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_work_center_summary-exec_reversed_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_nonrev_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_nonrev_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_reversed_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_reversed_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_nonrev_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_nonrev_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_reversed_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_reversed_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_ea-exec_nonrev_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_raw_operation_ea-exec_nonrev_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_ea-exec_reversed_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_ea-exec_reversed_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_operation_box-exec_nonrev_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_operation_box-exec_nonrev_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_raw_operation_box-exec_reversed_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_raw_operation_box-exec_reversed_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_ea-exec_nonrev_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_raw_order_ea-exec_nonrev_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_ea-exec_reversed_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_ea-exec_reversed_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_order_box-exec_nonrev_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_order_box-exec_nonrev_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_raw_order_box-exec_reversed_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_raw_order_box-exec_reversed_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_work_center_summary-exec_nonrev_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_base_work_center_summary-exec_nonrev_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_base_work_center_summary-exec_reversed_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_base_work_center_summary-exec_reversed_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_operation_summary-exec_nonrev_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_base_operation_summary-exec_nonrev_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_base_operation_summary-exec_reversed_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_base_operation_summary-exec_reversed_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_order_summary-exec_nonrev_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_base_order_summary-exec_nonrev_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_base_order_summary-exec_reversed_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_base_order_summary-exec_reversed_max_secs ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_work_center_summary-exec_duration_seconds_p99 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_work_center_summary-exec_nonrev_p99_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_work_center_summary-exec_reversed_p99_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_duration_seconds_p99 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_nonrev_p99_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_reversed_p99_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_duration_seconds_p99 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_nonrev_p99_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_reversed_p99_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_raw_operation_ea-exec_duration_seconds_p99 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_raw_operation_ea-exec_nonrev_p99_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_ea-exec_reversed_p99_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_raw_operation_box-exec_duration_seconds_p99 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_operation_box-exec_nonrev_p99_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_raw_operation_box-exec_reversed_p99_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_raw_order_ea-exec_duration_seconds_p99 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_raw_order_ea-exec_nonrev_p99_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_ea-exec_reversed_p99_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_raw_order_box-exec_duration_seconds_p99 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_order_box-exec_nonrev_p99_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_raw_order_box-exec_reversed_p99_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_base_work_center_summary-exec_duration_seconds_p99 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_base_work_center_summary-exec_nonrev_p99_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_base_work_center_summary-exec_reversed_p99_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_base_operation_summary-exec_duration_seconds_p99 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_base_operation_summary-exec_nonrev_p99_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_base_operation_summary-exec_reversed_p99_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_base_order_summary-exec_duration_seconds_p99 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_base_order_summary-exec_nonrev_p99_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_base_order_summary-exec_reversed_p99_secs ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-exec_duration_seconds_iqr ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-exec_nonrev_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-exec_reversed_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_duration_seconds_iqr ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_nonrev_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_reversed_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_duration_seconds_iqr ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_nonrev_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_reversed_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_operation_ea-exec_duration_seconds_iqr ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_operation_ea-exec_nonrev_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_ea-exec_reversed_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_operation_box-exec_duration_seconds_iqr ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_box-exec_nonrev_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_box-exec_reversed_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_order_ea-exec_duration_seconds_iqr ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_order_ea-exec_nonrev_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_ea-exec_reversed_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_order_box-exec_duration_seconds_iqr ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_box-exec_nonrev_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_box-exec_reversed_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_base_work_center_summary-exec_duration_seconds_iqr ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_base_work_center_summary-exec_nonrev_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_work_center_summary-exec_reversed_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_base_operation_summary-exec_duration_seconds_iqr ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_base_operation_summary-exec_nonrev_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_operation_summary-exec_reversed_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_base_order_summary-exec_duration_seconds_iqr ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_base_order_summary-exec_nonrev_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_order_summary-exec_reversed_iqr_secs ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-exec_duration_seconds_p25 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-exec_duration_seconds_p75 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-exec_nonrev_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-exec_nonrev_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_work_center_summary-exec_reversed_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_work_center_summary-exec_reversed_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_duration_seconds_p25 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_duration_seconds_p75 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_nonrev_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_nonrev_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_reversed_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_reversed_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_duration_seconds_p25 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_duration_seconds_p75 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_nonrev_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_nonrev_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_reversed_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_reversed_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_ea-exec_duration_seconds_p25 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_operation_ea-exec_duration_seconds_p75 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_ea-exec_nonrev_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_operation_ea-exec_nonrev_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_ea-exec_reversed_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_ea-exec_reversed_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_operation_box-exec_duration_seconds_p25 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_raw_operation_box-exec_duration_seconds_p75 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_operation_box-exec_nonrev_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_operation_box-exec_nonrev_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_raw_operation_box-exec_reversed_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_raw_operation_box-exec_reversed_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_ea-exec_duration_seconds_p25 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_order_ea-exec_duration_seconds_p75 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_ea-exec_nonrev_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_order_ea-exec_nonrev_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_ea-exec_reversed_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_ea-exec_reversed_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_order_box-exec_duration_seconds_p25 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_raw_order_box-exec_duration_seconds_p75 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_order_box-exec_nonrev_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_raw_order_box-exec_nonrev_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_raw_order_box-exec_reversed_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_raw_order_box-exec_reversed_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_work_center_summary-exec_duration_seconds_p25 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_base_work_center_summary-exec_duration_seconds_p75 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_work_center_summary-exec_nonrev_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_base_work_center_summary-exec_nonrev_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_base_work_center_summary-exec_reversed_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_base_work_center_summary-exec_reversed_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_operation_summary-exec_duration_seconds_p25 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_base_operation_summary-exec_duration_seconds_p75 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_operation_summary-exec_nonrev_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_base_operation_summary-exec_nonrev_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_base_operation_summary-exec_reversed_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_base_operation_summary-exec_reversed_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_order_summary-exec_duration_seconds_p25 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_base_order_summary-exec_duration_seconds_p75 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_order_summary-exec_nonrev_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3600' )
      act = ls_base_order_summary-exec_nonrev_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_base_order_summary-exec_reversed_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_base_order_summary-exec_reversed_p75_secs ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_work_center_summary-exec_duration_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-exec_duration_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_work_center_summary-exec_nonrev_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-exec_nonrev_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_work_center_summary-exec_reversed_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-exec_reversed_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_duration_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_duration_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_nonrev_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_nonrev_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_reversed_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ]-exec_reversed_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_duration_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_duration_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_nonrev_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_nonrev_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_reversed_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-quantity_summaries[
        quantity_unit = 'BOX' ]-exec_reversed_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_raw_operation_ea-exec_duration_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_ea-exec_duration_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_raw_operation_ea-exec_nonrev_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_ea-exec_nonrev_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_raw_operation_ea-exec_reversed_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_ea-exec_reversed_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_raw_operation_box-exec_duration_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_box-exec_duration_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_raw_operation_box-exec_nonrev_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_box-exec_nonrev_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_raw_operation_box-exec_reversed_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_operation_box-exec_reversed_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_raw_order_ea-exec_duration_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_ea-exec_duration_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_raw_order_ea-exec_nonrev_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_ea-exec_nonrev_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_raw_order_ea-exec_reversed_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_ea-exec_reversed_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_raw_order_box-exec_duration_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_box-exec_duration_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_raw_order_box-exec_nonrev_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_box-exec_nonrev_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_raw_order_box-exec_reversed_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_raw_order_box-exec_reversed_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_base_work_center_summary-exec_duration_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_work_center_summary-exec_duration_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_base_work_center_summary-exec_nonrev_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_work_center_summary-exec_nonrev_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_base_work_center_summary-exec_reversed_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_work_center_summary-exec_reversed_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_base_operation_summary-exec_duration_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_operation_summary-exec_duration_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_base_operation_summary-exec_nonrev_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_operation_summary-exec_nonrev_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_base_operation_summary-exec_reversed_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_operation_summary-exec_reversed_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_base_order_summary-exec_duration_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_order_summary-exec_duration_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_base_order_summary-exec_nonrev_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_order_summary-exec_nonrev_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_base_order_summary-exec_reversed_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_order_summary-exec_reversed_p95_exceed_pct ).

    lo_repository->order_confirmations = VALUE #(
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = '0000000001'
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '080000'
        execution_finish_date = '20261010'
        execution_finish_time = '090000'
        quantity_unit         = 'EA' )
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = '0000000002'
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '090000'
        execution_finish_date = '20261010'
        execution_finish_time = '100000'
        quantity_unit         = 'EA' ) ).
    DATA(ls_touching_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        posting_date_from = '20261001'
        posting_date_to   = '20261031'
        maximum_results   = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_peak_concurrency ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_peak_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '100.00' )
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_peak_concurrency_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_peak_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_longest_peak_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_peak_episode_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1' )
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_avg_concurrency ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_overlap_excess_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_covered_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_idle_gap_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_longest_idle_gap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_idle_gap_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_idle_gap_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '100.00' )
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_interval_coverage_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0.00' )
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_overlap_wall_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_single_active_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_single_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_longest_single_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '7200' )
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_single_active_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_high_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_exactly_two_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_pairwise_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_overlap_pair_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_overlap_pair_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_longest_pair_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_exactly_two_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_3plus_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_3plus_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_longest_3plus_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_3plus_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '100.00' )
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_single_active_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_overlap_wall_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_overlap_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_longest_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_touching_result-work_center_summaries[
        1 ]-exec_overlap_avg_secs ).

    lo_repository->order_confirmations = VALUE #(
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = '0000000003'
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '120000'
        execution_finish_date = '20261010'
        execution_finish_time = '130000'
        quantity_unit         = 'EA' )
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = '0000000004'
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '123000'
        execution_finish_date = '20261010'
        execution_finish_time = '133000'
        quantity_unit         = 'EA' )
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = '0000000005'
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '150000'
        execution_finish_date = '20261010'
        execution_finish_time = '160000'
        quantity_unit         = 'EA' )
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = '0000000006'
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '154459'
        execution_finish_date = '20261010'
        execution_finish_time = '163000'
        quantity_unit         = 'EA' ) ).
    DATA(ls_overlap_episodes_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        posting_date_from = '20261001'
        posting_date_to   = '20261031'
        maximum_results   = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_peak_concurrency ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '2701' )
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_peak_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '16.67' )
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_peak_concurrency_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_peak_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_longest_peak_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1350.5' )
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_peak_episode_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '13501' ) / 16200
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_avg_concurrency ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '10800' )
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_covered_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '2701' )
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_overlap_excess_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '5400' )
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_idle_gap_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '5400' )
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_longest_idle_gap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_idle_gap_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '5400' )
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_idle_gap_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '66.67' )
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_interval_coverage_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '16.67' )
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_overlap_wall_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '8099' )
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_single_active_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_single_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '2699' )
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_longest_single_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '2024.75' )
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_single_active_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_high_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '2701' )
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_exactly_two_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '2701' )
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_pairwise_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_overlap_pair_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1350.5' )
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_overlap_pair_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_longest_pair_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '16.67' )
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_exactly_two_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_3plus_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_3plus_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_longest_3plus_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_3plus_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '49.99' )
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_single_active_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '2701' )
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_overlap_wall_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_overlap_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1800' )
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_longest_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1350.5' )
      act = ls_overlap_episodes_result-work_center_summaries[
        1 ]-exec_overlap_avg_secs ).  ENDMETHOD.

  METHOD checks_exec_percentiles.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order = '0000000001'
        production_item  = '0001'
        order_category   = '10'
        material         = 'MAT-1'
        plant            = '1000' ) ).
    DATA lv_confirmation_number TYPE n LENGTH 12.
    DATA lv_finish_minute TYPE n LENGTH 2.
    DO 20 TIMES.
      lv_confirmation_number = sy-index.
      lv_finish_minute = sy-index.
      APPEND VALUE #(
        production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = lv_confirmation_number
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '080000'
        execution_finish_date = '20261010'
        execution_finish_time = '08' && lv_finish_minute && '00'
        yield_quantity        = '1.000'
        quantity_unit         = 'EA'
        is_reversed           = xsdbool( sy-index = 20 ) )
        TO lo_repository->order_confirmations.
    ENDDO.
    APPEND VALUE #(
      production_order      = '0000000001'
      order_category        = '10'
      operation_counter     = '00000001'
      operation_number      = '0020'
      operation_sequence    = '000000'
      work_center           = 'WC-02'
      work_center_plant     = '1000'
      confirmation          = '000000000021'
      confirmation_counter  = '00000001'
      posting_date          = '20261010'
      execution_start_date  = '20261010'
      execution_start_time  = '080000'
      execution_finish_date = '20261010'
      execution_finish_time = '080100'
      quantity_unit         = 'EA' ) TO lo_repository->order_confirmations.
    APPEND VALUE #(
      production_order      = '0000000001'
      order_category        = '10'
      operation_counter     = '00000001'
      operation_number      = '0020'
      operation_sequence    = '000000'
      work_center           = 'WC-02'
      work_center_plant     = '1000'
      confirmation          = '000000000022'
      confirmation_counter  = '00000001'
      posting_date          = '20261010'
      execution_start_date  = '20261010'
      execution_start_time  = '080000'
      execution_finish_date = '20261010'
      execution_finish_time = '080100'
      quantity_unit         = 'EA' ) TO lo_repository->order_confirmations.
    APPEND VALUE #(
      production_order      = '0000000001'
      order_category        = '10'
      operation_counter     = '00000001'
      operation_number      = '0020'
      operation_sequence    = '000000'
      work_center           = 'WC-02'
      work_center_plant     = '1000'
      confirmation          = '000000000023'
      confirmation_counter  = '00000001'
      posting_date          = '20261010'
      execution_start_date  = '20261010'
      execution_start_time  = '080000'
      execution_finish_date = '20261010'
      execution_finish_time = '081000'
      quantity_unit         = 'EA' ) TO lo_repository->order_confirmations.
    APPEND VALUE #(
      production_order      = '0000000001'
      order_category        = '10'
      operation_counter     = '00000001'
      operation_number      = '0020'
      operation_sequence    = '000000'
      work_center           = 'WC-02'
      work_center_plant     = '1000'
      confirmation          = '000000000024'
      confirmation_counter  = '00000001'
      posting_date          = '20261010'
      execution_start_date  = '20261010'
      execution_start_time  = '090000'
      execution_finish_date = '20261010'
      execution_finish_time = '090000'
      quantity_unit         = 'EA' ) TO lo_repository->order_confirmations.
    APPEND VALUE #(
      production_order      = '0000000001'
      order_category        = '10'
      operation_counter     = '00000001'
      operation_number      = '0020'
      operation_sequence    = '000000'
      work_center           = 'WC-02'
      work_center_plant     = '1000'
      confirmation          = '000000000025'
      confirmation_counter  = '00000001'
      posting_date          = '20261010'
      execution_start_date  = '20261010'
      execution_start_time  = '080000'
      execution_finish_date = '20261010'
      execution_finish_time = '075900'
      quantity_unit         = 'EA' ) TO lo_repository->order_confirmations.
    APPEND VALUE #(
      production_order     = '0000000001'
      order_category       = '10'
      operation_counter    = '00000001'
      operation_number     = '0020'
      operation_sequence   = '000000'
      work_center          = 'WC-02'
      work_center_plant    = '1000'
      confirmation         = '000000000026'
      confirmation_counter = '00000001'
      posting_date         = '20261010'
      execution_start_date = '20261010'
      execution_start_time = '080000'
      quantity_unit        = 'EA' ) TO lo_repository->order_confirmations.

    APPEND VALUE #(
      production_order      = '0000000001'
      order_category        = '10'
      operation_counter     = '00000001'
      operation_number      = '0030'
      operation_sequence    = '000000'
      work_center           = 'WC-03'
      work_center_plant     = '1000'
      confirmation          = '000000000027'
      confirmation_counter  = '00000001'
      posting_date          = '20261010'
      execution_start_date  = '20261010'
      execution_start_time  = '080000'
      execution_finish_date = '20261010'
      execution_finish_time = '075900'
      quantity_unit         = 'EA'
      is_reversed           = abap_true ) TO lo_repository->order_confirmations.
    APPEND VALUE #(
      production_order     = '0000000001'
      order_category       = '10'
      operation_counter    = '00000001'
      operation_number     = '0030'
      operation_sequence   = '000000'
      work_center          = 'WC-03'
      work_center_plant    = '1000'
      confirmation         = '000000000028'
      confirmation_counter = '00000001'
      posting_date         = '20261010'
      execution_start_date = '20261010'
      execution_start_time = '080000'
      quantity_unit        = 'EA'
      is_reversed          = abap_true ) TO lo_repository->order_confirmations.
    APPEND VALUE #(
      production_order      = '0000000001'
      order_category        = '10'
      operation_counter     = '00000001'
      operation_number      = '0030'
      operation_sequence    = '000000'
      work_center           = 'WC-03'
      work_center_plant     = '1000'
      confirmation          = '000000000029'
      confirmation_counter  = '00000001'
      posting_date          = '20261010'
      execution_start_date  = '20261010'
      execution_start_time  = '080000'
      execution_finish_date = '20261010'
      execution_finish_time = '075900'
      quantity_unit         = 'EA' ) TO lo_repository->order_confirmations.
    APPEND VALUE #(
      production_order     = '0000000001'
      order_category       = '10'
      operation_counter    = '00000001'
      operation_number     = '0030'
      operation_sequence   = '000000'
      work_center          = 'WC-03'
      work_center_plant    = '1000'
      confirmation         = '000000000030'
      confirmation_counter = '00000001'
      posting_date         = '20261010'
      execution_start_date = '20261010'
      execution_start_time = '080000'
      quantity_unit        = 'EA' ) TO lo_repository->order_confirmations.
    DATA(lo_cut) = NEW zcl_prod_order_read_service(
      io_repository = lo_repository ).
    DATA(ls_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        posting_date_from = '20261001'
        posting_date_to   = '20261031'
        maximum_results   = 30 ) ).
    DATA(ls_summary) = ls_result-work_center_summaries[ 1 ].
    DATA(ls_skew_summary) = ls_result-work_center_summaries[
      work_center_plant = '1000' work_center = 'WC-02' ].
    DATA(ls_quality_summary) = ls_result-work_center_summaries[
      work_center_plant = '1000' work_center = 'WC-03' ].
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_quality_summary-exec_nonrev_invalid_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_quality_summary-exec_rev_invalid_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_quality_summary-exec_nonrev_missing_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_quality_summary-exec_rev_missing_count ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3' )
      act = ls_skew_summary-exec_duration_avg_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3' )
      act = ls_skew_summary-exec_nonrev_avg_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_reversed_avg_median_ratio ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = ls_skew_summary-exec_pos_duration_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '60' )
      act = ls_skew_summary-exec_pos_median_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '600' )
      act = ls_skew_summary-exec_pos_p90_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = ls_skew_summary-exec_nonrev_pos_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '60' )
      act = ls_skew_summary-exec_nonrev_pos_median_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '600' )
      act = ls_skew_summary-exec_nonrev_pos_p90_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_skew_summary-exec_reversed_pos_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_reversed_pos_median_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_reversed_pos_p90_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '10' )
      act = ls_skew_summary-exec_pos_p90_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '10' )
      act = ls_skew_summary-exec_nonrev_pos_p90_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_rev_pos_p90_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '600' )
      act = ls_skew_summary-exec_pos_p95_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '600' )
      act = ls_skew_summary-exec_pos_p99_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '600' )
      act = ls_skew_summary-exec_nonrev_pos_p95_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '600' )
      act = ls_skew_summary-exec_nonrev_pos_p99_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_rev_pos_p95_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_rev_pos_p99_secs ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1080' )
      act = ls_summary-exec_duration_seconds_p90 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1140' )
      act = ls_summary-exec_duration_seconds_p95 ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_summary-exec_duration_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '5.00' )
      act = ls_summary-exec_duration_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1200' )
      act = ls_summary-exec_p95_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '9.52' )
      act = ls_summary-exec_p95_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_summary-exec_pos_p90_gt_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '10.00' )
      act = ls_summary-exec_pos_p90_gt_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '2340' )
      act = ls_summary-exec_pos_p90_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '18.57' )
      act = ls_summary-exec_pos_p90_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_summary-exec_nonrev_pos_p90_gt_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '5.26' )
      act = ls_summary-exec_nonrev_pos_p90_gt_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1140' )
      act = ls_summary-exec_nonrev_pos_p90_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '10.00' )
      act = ls_summary-exec_nonrev_pos_p90_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_rev_pos_p90_gt_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_p90_gt_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_p90_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_p90_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1140' )
      act = ls_summary-exec_pos_p95_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1200' )
      act = ls_summary-exec_pos_p99_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1140' )
      act = ls_summary-exec_nonrev_pos_p95_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1140' )
      act = ls_summary-exec_nonrev_pos_p99_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1200' )
      act = ls_summary-exec_rev_pos_p95_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1200' )
      act = ls_summary-exec_rev_pos_p99_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '60' )
      act = ls_skew_summary-exec_pos_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '600' )
      act = ls_skew_summary-exec_pos_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '540' )
      act = ls_skew_summary-exec_pos_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_pos_mad_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '60' )
      act = ls_skew_summary-exec_nonrev_pos_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '600' )
      act = ls_skew_summary-exec_nonrev_pos_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '540' )
      act = ls_skew_summary-exec_nonrev_pos_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_nonrev_pos_mad_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_rev_pos_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_rev_pos_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_rev_pos_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_rev_pos_mad_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '9' )
      act = ls_skew_summary-exec_pos_iqr_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '9' )
      act = ls_skew_summary-exec_nonrev_pos_iqr_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_rev_pos_iqr_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_pos_mad_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_nonrev_pos_mad_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_rev_pos_mad_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '300' )
      act = ls_summary-exec_pos_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '900' )
      act = ls_summary-exec_pos_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '600' )
      act = ls_summary-exec_pos_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '300' )
      act = ls_summary-exec_pos_mad_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '300' )
      act = ls_summary-exec_nonrev_pos_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '900' )
      act = ls_summary-exec_nonrev_pos_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '600' )
      act = ls_summary-exec_nonrev_pos_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '300' )
      act = ls_summary-exec_nonrev_pos_mad_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1200' )
      act = ls_summary-exec_rev_pos_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1200' )
      act = ls_summary-exec_rev_pos_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_mad_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '600' ) / CONV decfloat34( '630' )
      act = ls_summary-exec_pos_iqr_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1' )
      act = ls_summary-exec_nonrev_pos_iqr_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_iqr_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '300' ) / CONV decfloat34( '630' )
      act = ls_summary-exec_pos_mad_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0.5' )
      act = ls_summary-exec_nonrev_pos_mad_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_mad_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '240' )
      act = ls_skew_summary-exec_pos_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '240' )
      act = ls_skew_summary-exec_nonrev_pos_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_rev_pos_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '4' )
      act = ls_skew_summary-exec_pos_avg_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '4' )
      act = ls_skew_summary-exec_nonrev_pos_avg_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_rev_pos_avg_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '630' )
      act = ls_summary-exec_pos_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '600' )
      act = ls_summary-exec_nonrev_pos_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1200' )
      act = ls_summary-exec_rev_pos_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1' )
      act = ls_summary-exec_pos_avg_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1' )
      act = ls_summary-exec_nonrev_pos_avg_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1' )
      act = ls_summary-exec_rev_pos_avg_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '60' )
      act = ls_skew_summary-exec_pos_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '600' )
      act = ls_skew_summary-exec_pos_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '540' )
      act = ls_skew_summary-exec_pos_range_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '60' )
      act = ls_skew_summary-exec_nonrev_pos_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '600' )
      act = ls_skew_summary-exec_nonrev_pos_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '540' )
      act = ls_skew_summary-exec_nonrev_pos_range_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_rev_pos_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_rev_pos_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_rev_pos_range_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '60' )
      act = ls_summary-exec_pos_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1200' )
      act = ls_summary-exec_pos_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1140' )
      act = ls_summary-exec_pos_range_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '60' )
      act = ls_summary-exec_nonrev_pos_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1140' )
      act = ls_summary-exec_nonrev_pos_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1080' )
      act = ls_summary-exec_nonrev_pos_range_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1200' )
      act = ls_summary-exec_rev_pos_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1200' )
      act = ls_summary-exec_rev_pos_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_range_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_skew_summary-exec_pos_p95_gt_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_pos_p95_gt_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_pos_p95_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_pos_p95_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_skew_summary-exec_nonrev_pos_p95_gt_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_nonrev_pos_p95_gt_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_nonrev_pos_p95_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_nonrev_pos_p95_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_skew_summary-exec_rev_pos_p95_gt_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_rev_pos_p95_gt_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_rev_pos_p95_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_rev_pos_p95_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_skew_summary-exec_pos_p99_gt_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_pos_p99_gt_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_pos_p99_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_pos_p99_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_skew_summary-exec_nonrev_pos_p99_gt_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_nonrev_pos_p99_gt_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_nonrev_pos_p99_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_nonrev_pos_p99_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_skew_summary-exec_rev_pos_p99_gt_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_rev_pos_p99_gt_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_rev_pos_p99_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_rev_pos_p99_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_summary-exec_pos_p95_gt_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '5.00' )
      act = ls_summary-exec_pos_p95_gt_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1200' )
      act = ls_summary-exec_pos_p95_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '9.52' )
      act = ls_summary-exec_pos_p95_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_nonrev_pos_p95_gt_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_p95_gt_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_p95_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_p95_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_rev_pos_p95_gt_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_p95_gt_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_p95_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_p95_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_pos_p99_gt_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_p99_gt_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_p99_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_p99_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_nonrev_pos_p99_gt_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_p99_gt_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_p99_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_p99_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_rev_pos_p99_gt_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_p99_gt_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_p99_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_p99_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '10' )
      act = ls_skew_summary-exec_pos_p95_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '10' )
      act = ls_skew_summary-exec_nonrev_pos_p95_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_rev_pos_p95_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '10' )
      act = ls_skew_summary-exec_pos_p99_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '10' )
      act = ls_skew_summary-exec_nonrev_pos_p99_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_rev_pos_p99_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1140' ) / CONV decfloat34( '630' )
      act = ls_summary-exec_pos_p95_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1140' ) / CONV decfloat34( '600' )
      act = ls_summary-exec_nonrev_pos_p95_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1' )
      act = ls_summary-exec_rev_pos_p95_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1200' ) / CONV decfloat34( '630' )
      act = ls_summary-exec_pos_p99_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1140' ) / CONV decfloat34( '600' )
      act = ls_summary-exec_nonrev_pos_p99_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1' )
      act = ls_summary-exec_rev_pos_p99_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '50.00' )
      act = ls_skew_summary-exec_pos_duration_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '50.00' )
      act = ls_skew_summary-exec_nonrev_pos_duration_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_reversed_pos_duration_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '100.00' )
      act = ls_summary-exec_pos_duration_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '100.00' )
      act = ls_summary-exec_nonrev_pos_duration_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '100.00' )
      act = ls_summary-exec_reversed_pos_duration_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '75.00' )
      act = ls_skew_summary-exec_pos_valid_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '75.00' )
      act = ls_skew_summary-exec_nonrev_pos_valid_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_rev_pos_valid_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '100.00' )
      act = ls_summary-exec_pos_valid_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '100.00' )
      act = ls_summary-exec_nonrev_pos_valid_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '100.00' )
      act = ls_summary-exec_rev_pos_valid_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '25.00' )
      act = ls_skew_summary-exec_zero_valid_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '25.00' )
      act = ls_skew_summary-exec_nonrev_zero_valid_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_skew_summary-exec_rev_zero_valid_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_skew_summary-exec_zero_valid_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_skew_summary-exec_nonrev_zero_valid_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_skew_summary-exec_rev_zero_valid_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_zero_valid_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_zero_valid_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_zero_valid_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_zero_valid_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_nonrev_zero_valid_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_rev_zero_valid_count ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1200' )
      act = ls_summary-exec_duration_seconds_p99 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1140' )
      act = ls_summary-exec_nonrev_p99_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1200' )
      act = ls_summary-exec_reversed_p99_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1200' ) / CONV decfloat34( '630' )
      act = ls_summary-exec_duration_p99_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1140' ) / CONV decfloat34( '600' )
      act = ls_summary-exec_nonrev_p99_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1' )
      act = ls_summary-exec_reversed_p99_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '600' )
      act = ls_summary-exec_duration_seconds_iqr ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '300' )
      act = ls_summary-exec_duration_seconds_p25 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '900' )
      act = ls_summary-exec_duration_seconds_p75 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '300' )
      act = ls_summary-exec_nonrev_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '900' )
      act = ls_summary-exec_nonrev_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1200' )
      act = ls_summary-exec_reversed_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1200' )
      act = ls_summary-exec_reversed_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '600' )
      act = ls_summary-exec_nonrev_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '600' ) / CONV decfloat34( '630' )
      act = ls_summary-exec_duration_iqr_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1' )
      act = ls_summary-exec_nonrev_iqr_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_iqr_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1080' )
      act = ls_summary-exec_nonrev_p90_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1200' )
      act = ls_summary-exec_reversed_p90_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1080' ) / CONV decfloat34( '630' )
      act = ls_summary-exec_duration_p90_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1080' ) / CONV decfloat34( '600' )
      act = ls_summary-exec_nonrev_p90_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1' )
      act = ls_summary-exec_reversed_p90_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_summary-exec_duration_p90_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '10.00' )
      act = ls_summary-exec_duration_p90_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '2340' )
      act = ls_summary-exec_p90_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '18.57' )
      act = ls_summary-exec_p90_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_summary-exec_nonrev_p90_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '5.26' )
      act = ls_summary-exec_nonrev_p90_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1140' )
      act = ls_summary-exec_nonrev_p90_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '10.00' )
      act = ls_summary-exec_nonrev_p90_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_reversed_p90_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_p90_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_p90_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_p90_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1140' )
      act = ls_summary-exec_nonrev_p95_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1200' )
      act = ls_summary-exec_reversed_p95_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1140' ) / CONV decfloat34( '630' )
      act = ls_summary-exec_duration_p95_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1.9' )
      act = ls_summary-exec_nonrev_p95_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1' )
      act = ls_summary-exec_reversed_p95_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '60' )
      act = ls_summary-exec_nonrev_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1140' )
      act = ls_summary-exec_nonrev_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1200' )
      act = ls_summary-exec_reversed_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1200' )
      act = ls_summary-exec_reversed_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '300' )
      act = ls_summary-exec_nonrev_mad_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_mad_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '300' ) / CONV decfloat34( '630' )
      act = ls_summary-exec_duration_mad_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0.5' )
      act = ls_summary-exec_nonrev_mad_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_mad_median_ratio ).


    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '600' )
      act = ls_summary-exec_nonrev_median_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1200' )
      act = ls_summary-exec_reversed_median_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '300' )
      act = ls_summary-exec_duration_seconds_mad ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_nonrev_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_reversed_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_p95_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_p95_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_p95_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_p95_tail_pct ).
  ENDMETHOD.

  METHOD checks_exec_p99_tails.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order = '0000000001'
        production_item  = '0001'
        order_category   = '10'
        material         = 'MAT-1'
        plant            = '1000' ) ).
    DATA lv_confirmation_number TYPE n LENGTH 12.
    DATA lv_finish_hour TYPE n LENGTH 2.
    DATA lv_finish_minute TYPE n LENGTH 2.
    DO 101 TIMES.
      lv_finish_hour = 8 + ( sy-index DIV 60 ).
      lv_finish_minute = sy-index MOD 60.
      lv_confirmation_number = sy-index.
      APPEND VALUE #(
        production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = lv_confirmation_number
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '080000'
        execution_finish_date = '20261010'
        execution_finish_time = lv_finish_hour && lv_finish_minute && '00'
        yield_quantity        = '1.000'
        quantity_unit         = 'EA' )
        TO lo_repository->order_confirmations.
      lv_confirmation_number = 101 + sy-index.
      APPEND VALUE #(
        production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = lv_confirmation_number
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '080000'
        execution_finish_date = '20261010'
        execution_finish_time = lv_finish_hour && lv_finish_minute && '00'
        yield_quantity        = '1.000'
        quantity_unit         = 'EA'
        is_reversed           = abap_true )
        TO lo_repository->order_confirmations.
    ENDDO.

    DATA(lo_uom_repository) = NEW lcl_prod_order_uom_repo( ).
    lo_uom_repository->base_unit = 'EA'.
    lo_uom_repository->alternative_unit = 'EA'.
    lo_uom_repository->numerator = 1.
    lo_uom_repository->denominator = 1.
    DATA(lo_uom_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service(
      io_repository    = lo_repository
      io_uom_converter = lo_uom_converter ).
    DATA(ls_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        posting_date_from = '20261001'
        posting_date_to   = '20261031'
        maximum_results   = 250 ) ).
    DATA(ls_summary) = ls_result-work_center_summaries[ 1 ].
    DATA(ls_unit_summary) = ls_summary-quantity_summaries[
      quantity_unit = 'EA' ].
    DATA(ls_operation_summary) = ls_result-operation_summaries[ 1 ].
    DATA(ls_order_summary) = ls_result-order_summaries[ 1 ].

    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '6000' )
      act = ls_summary-exec_duration_seconds_p99 ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_summary-exec_duration_p99_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0.99' )
      act = ls_summary-exec_duration_p99_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '12120' )
      act = ls_summary-exec_p99_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1.96' )
      act = ls_summary-exec_p99_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_summary-exec_nonrev_p99_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0.99' )
      act = ls_summary-exec_nonrev_p99_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '6060' )
      act = ls_summary-exec_nonrev_p99_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1.96' )
      act = ls_summary-exec_nonrev_p99_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_summary-exec_reversed_p99_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0.99' )
      act = ls_summary-exec_reversed_p99_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '6060' )
      act = ls_summary-exec_reversed_p99_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1.96' )
      act = ls_summary-exec_reversed_p99_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = ls_summary-exec_p99_tail_secs
      act = ls_unit_summary-exec_p99_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = ls_summary-exec_nonrev_p99_tail_secs
      act = ls_unit_summary-exec_nonrev_p99_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = ls_summary-exec_reversed_p99_tail_secs
      act = ls_unit_summary-exec_reversed_p99_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = ls_summary-exec_p90_tail_secs
      act = ls_operation_summary-exec_p90_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = ls_summary-exec_p95_tail_secs
      act = ls_operation_summary-exec_p95_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = ls_summary-exec_p99_tail_secs
      act = ls_operation_summary-exec_p99_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = ls_summary-exec_p99_tail_pct
      act = ls_operation_summary-exec_p99_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = ls_summary-exec_p90_tail_secs
      act = ls_order_summary-exec_p90_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = ls_summary-exec_p95_tail_secs
      act = ls_order_summary-exec_p95_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = ls_summary-exec_p99_tail_secs
      act = ls_order_summary-exec_p99_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = ls_summary-exec_p99_tail_pct
      act = ls_order_summary-exec_p99_tail_pct ).

    DATA(ls_base_result) = lo_cut->search_conf_window_base_unit(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        posting_date_from = '20261001'
        posting_date_to   = '20261031'
        maximum_results   = 250 ) ).
    DATA(ls_base_work_center_summary) =
      ls_base_result-base_work_center_summaries[ 1 ].
    DATA(ls_base_operation_summary) =
      ls_base_result-base_operation_summaries[ 1 ].
    DATA(ls_base_order_summary) = ls_base_result-base_order_summaries[ 1 ].
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_base_work_center_summary-exec_duration_p99_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '12120' )
      act = ls_base_work_center_summary-exec_p99_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1.96' )
      act = ls_base_work_center_summary-exec_p99_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '12120' )
      act = ls_base_operation_summary-exec_p99_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '12120' )
      act = ls_base_order_summary-exec_p99_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1.96' )
      act = ls_base_order_summary-exec_p99_tail_pct ).
  ENDMETHOD.

  METHOD checks_exec_3plus_avg.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order = '0000000001'
        production_item  = '0001'
        order_category   = '10'
        material         = 'MAT-1'
        plant            = '1000' ) ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = '0000000001'
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '000000'
        execution_finish_date = '20261010'
        execution_finish_time = '000005'
        yield_quantity        = '1.000'
        quantity_unit         = 'EA' )
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = '0000000002'
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '000000'
        execution_finish_date = '20261010'
        execution_finish_time = '000003'
        yield_quantity        = '1.000'
        quantity_unit         = 'EA' )
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = '0000000003'
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '000000'
        execution_finish_date = '20261010'
        execution_finish_time = '000002'
        yield_quantity        = '1.000'
        quantity_unit         = 'EA' )
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = '0000000004'
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '000002'
        execution_finish_date = '20261010'
        execution_finish_time = '000005'
        yield_quantity        = '1.000'
        quantity_unit         = 'EA' )
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = '0000000005'
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '000010'
        execution_finish_date = '20261010'
        execution_finish_time = '000012'
        yield_quantity        = '1.000'
        quantity_unit         = 'EA' )
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = '0000000006'
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '000010'
        execution_finish_date = '20261010'
        execution_finish_time = '000012'
        yield_quantity        = '1.000'
        quantity_unit         = 'EA' )
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = '0000000007'
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '000010'
        execution_finish_date = '20261010'
        execution_finish_time = '000012'
        yield_quantity        = '1.000'
        quantity_unit         = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service(
      io_repository = lo_repository ).
    DATA(ls_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        posting_date_from = '20261010'
        posting_date_to   = '20261010'
        maximum_results   = 10 ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-work_center_summaries[ 1 ]-exec_3plus_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '5' )
      act = ls_result-work_center_summaries[ 1 ]-exec_high_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '2' )
      act = ls_result-work_center_summaries[ 1 ]-exec_exactly_two_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '17' )
      act = ls_result-work_center_summaries[ 1 ]-exec_pairwise_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 8
      act = ls_result-work_center_summaries[ 1 ]-exec_overlap_pair_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '2.125' )
      act = ls_result-work_center_summaries[ 1 ]-exec_overlap_pair_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3' )
      act = ls_result-work_center_summaries[ 1 ]-exec_longest_pair_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '16.67' )
      act = ls_result-work_center_summaries[ 1 ]-exec_exactly_two_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '41.67' )
      act = ls_result-work_center_summaries[ 1 ]-exec_3plus_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '41.67' )
      act = ls_result-work_center_summaries[ 1 ]-exec_peak_concurrency_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-work_center_summaries[ 1 ]-exec_peak_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3' )
      act = ls_result-work_center_summaries[ 1 ]-exec_longest_peak_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '2.5' )
      act = ls_result-work_center_summaries[ 1 ]-exec_peak_episode_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '19' ) / 12
      act = ls_result-work_center_summaries[ 1 ]-exec_avg_concurrency ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3' )
      act = ls_result-work_center_summaries[ 1 ]-exec_longest_3plus_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '2.5' )
      act = ls_result-work_center_summaries[ 1 ]-exec_3plus_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '2.5' )
      act = ls_result-work_center_summaries[ 1 ]-quantity_summaries[
        quantity_unit = 'EA' ]-exec_3plus_avg_secs ).
  ENDMETHOD.

  METHOD checks_exec_idle_gap_average.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order = '0000000001'
        production_item  = '0001'
        order_category   = '10'
        material         = 'MAT-1'
        plant            = '1000' ) ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = '0000000001'
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '080000'
        execution_finish_date = '20261010'
        execution_finish_time = '080001'
        quantity_unit         = 'EA' )
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = '0000000002'
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '080002'
        execution_finish_date = '20261010'
        execution_finish_time = '080003'
        quantity_unit         = 'EA' )
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        work_center           = 'WC-01'
        work_center_plant     = '1000'
        confirmation          = '0000000003'
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '080005'
        execution_finish_date = '20261010'
        execution_finish_time = '080006'
        quantity_unit         = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service(
      io_repository = lo_repository ).
    DATA(ls_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        posting_date_from = '20261010'
        posting_date_to   = '20261010'
        maximum_results   = 10 ) ).
    DATA(ls_summary) = ls_result-work_center_summaries[ 1 ].

    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3' )
      act = ls_summary-exec_idle_gap_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_summary-exec_idle_gap_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '2' )
      act = ls_summary-exec_longest_idle_gap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1.5' )
      act = ls_summary-exec_idle_gap_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '50.00' )
      act = ls_summary-exec_interval_coverage_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0.00' )
      act = ls_summary-exec_overlap_wall_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '3' )
      act = ls_summary-exec_single_active_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = ls_summary-exec_single_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1' )
      act = ls_summary-exec_longest_single_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1' )
      act = ls_summary-exec_single_active_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '50.00' )
      act = ls_summary-exec_single_active_pct ).
  ENDMETHOD.

  METHOD checks_zero_exec_duration.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order = '0000000001'
        production_item  = '0001'
        order_category   = '10'
        material         = 'MAT-1'
        plant            = '1000' ) ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        confirmation          = '0000000001'
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
        execution_start_date  = '20261010'
        execution_start_time  = '080000'
        execution_finish_date = '20261010'
        execution_finish_time = '080000'
        yield_quantity        = '1.000'
        quantity_unit         = 'EA' ) ).
    DATA(lo_uom_repository) = NEW lcl_prod_order_uom_repo( ).
    lo_uom_repository->base_unit = 'EA'.
    DATA(lo_uom_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service(
      io_repository    = lo_repository
      io_uom_converter = lo_uom_converter ).

    DATA(ls_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        posting_date_from = '20261001'
        posting_date_to   = '20261031'
        maximum_results   = 10 ) ).
    DATA(ls_summary) = ls_result-operation_summaries[ 1 ].
    DATA(ls_bulk_result) = lo_cut->read_confirmations_bulk(
      it_production_orders = VALUE #( ( '0000000001' ) ) ).
    DATA(ls_bulk_order) = ls_bulk_result-orders[ 1 ].
    DATA(ls_bulk_confirmation) = ls_bulk_order-confirmations[ 1 ].

    cl_abap_unit_assert=>assert_equals(
      exp = 'V'
      act = ls_result-confirmations[ 1 ]-exec_duration_status ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_result-confirmations[ 1 ]-exec_duration_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'V'
      act = ls_bulk_confirmation-exec_duration_status ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_bulk_confirmation-exec_duration_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_summary-exec_duration_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_duration_seconds_median ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_duration_avg_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_avg_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_avg_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_pos_duration_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_median_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_p90_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_nonrev_pos_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_median_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_p90_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_reversed_pos_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_pos_median_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_pos_p90_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_p90_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_p90_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_p90_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_p95_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_p99_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_p95_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_p99_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_p95_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_p99_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_mad_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_mad_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_mad_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_iqr_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_iqr_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_iqr_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_mad_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_mad_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_mad_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_avg_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_avg_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_avg_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_range_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_range_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_range_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_pos_p95_gt_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_p95_gt_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_p95_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_p95_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_nonrev_pos_p95_gt_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_p95_gt_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_p95_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_p95_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_rev_pos_p95_gt_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_p95_gt_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_p95_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_p95_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_pos_p99_gt_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_p99_gt_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_p99_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_p99_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_nonrev_pos_p99_gt_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_p99_gt_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_p99_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_p99_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_rev_pos_p99_gt_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_p99_gt_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_p99_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_p99_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_p95_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_p95_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_p95_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_p99_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_p99_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_p99_med_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_duration_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_duration_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_pos_duration_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_valid_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_valid_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_valid_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '100.00' )
      act = ls_summary-exec_zero_valid_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '100.00' )
      act = ls_summary-exec_nonrev_zero_valid_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_zero_valid_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_summary-exec_zero_valid_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_summary-exec_nonrev_zero_valid_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_rev_zero_valid_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_pos_p90_gt_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_p90_gt_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_p90_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pos_p90_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_nonrev_pos_p90_gt_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_p90_gt_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_p90_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_pos_p90_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_rev_pos_p90_gt_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_p90_gt_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_p90_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_rev_pos_p90_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_duration_seconds_p90 ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_duration_seconds_p95 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_duration_p95_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_p95_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_p95_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_duration_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_duration_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_p95_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_p95_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_p95_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_p95_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_p95_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_p95_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_nonrev_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_reversed_p95_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_p95_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_duration_seconds_p99 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_p99_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_p99_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_duration_p99_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_p99_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_p99_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_duration_p99_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_duration_p99_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_p99_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_p99_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_nonrev_p99_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_p99_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_p99_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_p99_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_reversed_p99_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_p99_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_p99_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_p99_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_duration_seconds_iqr ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_duration_seconds_p25 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_duration_seconds_p75 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_p25_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_p75_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_iqr_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_duration_iqr_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_iqr_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_iqr_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_median_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_median_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_min_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_max_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_p90_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_p90_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_duration_p90_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_p90_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_p90_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_duration_p90_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_duration_p90_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_p90_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_p90_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_nonrev_p90_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_p90_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_p90_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_p90_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_reversed_p90_exceed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_p90_exceed_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_p90_tail_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_p90_tail_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_mad_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_mad_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_duration_mad_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_nonrev_mad_median_ratio ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_reversed_mad_median_ratio ).


    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_duration_seconds_mad ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_summary-zero_exec_duration_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_peak_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_peak_concurrency_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_peak_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_longest_peak_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_peak_episode_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_avg_concurrency ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_peak_concurrency ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_longest_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_overlap_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_longest_idle_gap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_idle_gap_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_idle_gap_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0.00' )
      act = ls_summary-exec_interval_coverage_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0.00' )
      act = ls_summary-exec_overlap_wall_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_single_active_seconds ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_longest_single_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_single_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_single_active_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_high_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_exactly_two_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_pairwise_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_overlap_pair_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_overlap_pair_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_longest_pair_overlap_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_exactly_two_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_3plus_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-exec_3plus_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_longest_3plus_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_3plus_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0.00' )
      act = ls_summary-exec_single_active_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '100.00' )
      act = ls_summary-zero_exec_duration_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_duration_seconds_total ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_summary-exec_duration_seconds_avg ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-missing_exec_duration_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_summary-invalid_exec_duration_count ).
    DATA(ls_order_summary) = ls_result-order_summaries[ 1 ].
    DATA(ls_work_center_summary) = ls_result-work_center_summaries[ 1 ].
    DATA(ls_work_center_unit_summary) =
      ls_work_center_summary-quantity_summaries[
        quantity_unit = 'EA' ].
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_order_summary-zero_exec_duration_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_work_center_unit_summary-zero_exec_duration_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-exec_peak_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-exec_peak_concurrency_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_work_center_summary-exec_peak_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-exec_longest_peak_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-exec_peak_episode_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_summary-exec_avg_concurrency ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_unit_summary-exec_peak_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_unit_summary-exec_peak_concurrency_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_work_center_unit_summary-exec_peak_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_unit_summary-exec_longest_peak_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_unit_summary-exec_peak_episode_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_work_center_unit_summary-exec_avg_concurrency ).

    DATA(ls_base_result) = lo_cut->search_conf_window_base_unit(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        posting_date_from = '20261001'
        posting_date_to   = '20261031'
        maximum_results   = 10 ) ).
    DATA(ls_base_operation_summary) =
      ls_base_result-base_operation_summaries[ 1 ].
    DATA(ls_base_order_summary) = ls_base_result-base_order_summaries[ 1 ].
    DATA(ls_base_work_center_summary) =
      ls_base_result-base_work_center_summaries[ 1 ].
    DATA(ls_base_quantity) = ls_base_result-base_quantities[ 1 ].
    DATA(ls_base_confirmation) = ls_base_quantity-confirmation_row.
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_base_operation_summary-zero_exec_duration_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '100.00' )
      act = ls_base_order_summary-zero_exec_duration_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_base_work_center_summary-zero_exec_duration_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_operation_summary-exec_peak_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_operation_summary-exec_peak_concurrency_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_base_operation_summary-exec_peak_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_operation_summary-exec_longest_peak_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_operation_summary-exec_peak_episode_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_operation_summary-exec_avg_concurrency ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_order_summary-exec_peak_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_order_summary-exec_peak_concurrency_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_base_order_summary-exec_peak_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_order_summary-exec_longest_peak_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_order_summary-exec_peak_episode_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_order_summary-exec_avg_concurrency ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_work_center_summary-exec_peak_concurrency_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_work_center_summary-exec_peak_concurrency_pct ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_base_work_center_summary-exec_peak_episode_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_work_center_summary-exec_longest_peak_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_work_center_summary-exec_peak_episode_avg_secs ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_work_center_summary-exec_avg_concurrency ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'V'
      act = ls_base_confirmation-exec_duration_status ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '0' )
      act = ls_base_confirmation-exec_duration_seconds ).
  ENDMETHOD.

  METHOD rejects_unknown_conf_uom.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order = '0000000001'
        production_item  = '0001'
        order_category   = '10'
        material         = 'MAT-1'
        plant            = '1000' ) ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order     = '0000000001'
        order_category       = '10'
        confirmation         = '0000000001'
        confirmation_counter = '00000001'
        posting_date         = '20261010'
        yield_quantity       = '2.000'
        quantity_unit        = 'PAL' ) ).
    DATA(lo_uom_repository) = NEW lcl_prod_order_uom_repo( ).
    lo_uom_repository->base_unit = 'EA'.
    lo_uom_repository->alternative_unit = 'BOX'.
    lo_uom_repository->numerator = 12.
    lo_uom_repository->denominator = 1.
    DATA(lo_cut) = NEW zcl_prod_order_read_service(
      io_repository    = lo_repository
      io_uom_converter = NEW zcl_material_uom_converter(
        io_repository = lo_uom_repository ) ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->search_conf_window_base_unit(
          is_selection = VALUE #(
            material          = 'MAT-1'
            plant             = '1000'
            posting_date_from = '20261001'
            posting_date_to   = '20261031'
            maximum_results   = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD rejects_conf_base_loss.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order = '0000000001'
        production_item  = '0001'
        order_category   = '10'
        material         = 'MAT-1'
        plant            = '1000' ) ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order     = '0000000001'
        order_category       = '10'
        confirmation         = '0000000001'
        confirmation_counter = '00000001'
        posting_date         = '20261010'
        yield_quantity       = '9999999999.999'
        quantity_unit        = 'BOX' ) ).
    DATA(lo_uom_repository) = NEW lcl_prod_order_uom_repo( ).
    lo_uom_repository->base_unit = 'EA'.
    lo_uom_repository->alternative_unit = 'BOX'.
    lo_uom_repository->numerator = 12.
    lo_uom_repository->denominator = 1.
    DATA(lo_cut) = NEW zcl_prod_order_read_service(
      io_repository    = lo_repository
      io_uom_converter = NEW zcl_material_uom_converter(
        io_repository = lo_uom_repository ) ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->search_conf_window_base_unit(
          is_selection = VALUE #(
            material          = 'MAT-1'
            plant             = '1000'
            posting_date_from = '20261001'
            posting_date_to   = '20261031'
            maximum_results   = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    lo_repository->order_confirmations = VALUE #(
      ( production_order     = '0000000001'
        order_category       = '10'
        confirmation         = '0000000002'
        confirmation_counter = '00000001'
        posting_date         = '20261010'
        yield_quantity       = '0.001'
        quantity_unit        = 'BOX' ) ).
    lo_uom_repository->numerator = 1.
    lo_uom_repository->denominator = 1000.
    TRY.
        lo_cut->search_conf_window_base_unit(
          is_selection = VALUE #(
            material          = 'MAT-1'
            plant             = '1000'
            posting_date_from = '20261001'
            posting_date_to   = '20261031'
            maximum_results   = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD filters_confirmation_operation.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order = '0000000001'
        production_item  = '0001'
        order_category   = '10'
        material         = 'MAT-1'
        plant            = '1000' ) ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order     = '0000000001'
        operation_number     = '0010'
        confirmation         = '0000000001'
        confirmation_counter = '00000001'
        posting_date         = '20261011' )
      ( production_order     = '0000000001'
        operation_number     = '0020'
        confirmation         = '0000000002'
        confirmation_counter = '00000001'
        posting_date         = '20261011' )
      ( production_order     = '0000000001'
        operation_number     = '0020'
        confirmation         = '0000000003'
        confirmation_counter = '00000001'
        posting_date         = '20261012' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        operation_number  = '0020'
        posting_date_from = '20261001'
        posting_date_to   = '20261031'
        maximum_results   = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-returned_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-confirmations[ 1 ]-operation_number
      exp = '0020' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-confirmations[ 2 ]-operation_number
      exp = '0020' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->requested_conf_selection-operation_number
      exp = '0020' ).
  ENDMETHOD.

  METHOD filters_final_confirmations.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order = '0000000001'
        production_item  = '0001'
        order_category   = '10'
        material         = 'MAT-1'
        plant            = '1000' ) ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order     = '0000000001'
        confirmation         = '0000000001'
        confirmation_counter = '00000001'
        posting_date         = '20261011' )
      ( production_order     = '0000000001'
        confirmation         = '0000000002'
        confirmation_counter = '00000001'
        posting_date         = '20261012'
        is_final             = abap_true ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        posting_date_from = '20261001'
        posting_date_to   = '20261031'
        final_only        = abap_true
        maximum_results   = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-returned_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-confirmations[ 1 ]-confirmation
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_true(
      ls_result-confirmations[ 1 ]-is_final ).
    cl_abap_unit_assert=>assert_true(
      lo_repository->requested_conf_selection-final_only ).
  ENDMETHOD.

  METHOD filters_partial_confirmations.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order = '0000000001'
        production_item  = '0001'
        order_category   = '10'
        material         = 'MAT-1'
        plant            = '1000' ) ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order     = '0000000001'
        confirmation         = '0000000001'
        confirmation_counter = '00000001'
        posting_date         = '20261011' )
      ( production_order     = '0000000001'
        confirmation         = '0000000002'
        confirmation_counter = '00000001'
        posting_date         = '20261012'
        is_final             = abap_true ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        posting_date_from = '20261001'
        posting_date_to   = '20261031'
        partial_only      = abap_true
        maximum_results   = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-returned_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-confirmations[ 1 ]-confirmation
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_false(
      ls_result-confirmations[ 1 ]-is_final ).
    cl_abap_unit_assert=>assert_true(
      lo_repository->requested_conf_selection-partial_only ).
  ENDMETHOD.

  METHOD filters_conf_routing.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order = '0000000001'
        production_item  = '0001'
        order_category   = '10'
        material         = 'MAT-1'
        plant            = '1000' ) ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order       = '0000000001'
        operation_number       = '0020'
        operation_sequence     = '000001'
        operation_suboperation = '0001'
        control_key            = 'QM01'
        confirmation           = '0000000001'
        confirmation_counter   = '00000001'
        posting_date           = '20261011' )
      ( production_order       = '0000000001'
        operation_number       = '0020'
        operation_sequence     = '000002'
        operation_suboperation = '0002'
        control_key            = 'QM02'
        confirmation           = '0000000002'
        confirmation_counter   = '00000001'
        posting_date           = '20261011' )
      ( production_order       = '0000000001'
        operation_number       = '0010'
        operation_sequence     = '000002'
        operation_suboperation = ''
        control_key            = 'PP01'
        quantity_unit          = 'BOX'
        confirmation           = '0000000003'
        confirmation_counter   = '00000001'
        posting_date           = '20261011' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material               = 'MAT-1'
        plant                  = '1000'
        operation_number       = '0020'
        operation_sequence     = '000001'
        operation_suboperation = '0001'
        control_key            = 'QM01'
        posting_date_from      = '20261001'
        posting_date_to        = '20261031'
        maximum_results        = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-returned_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-confirmations[ 1 ]-operation_suboperation
      exp = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-confirmations[ 1 ]-operation_sequence
      exp = '000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-operation_summaries )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-operation_suboperation
      exp = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->requested_conf_selection-operation_suboperation
      exp = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-confirmations[ 1 ]-control_key
      exp = 'QM01' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->requested_conf_selection-control_key
      exp = 'QM01' ).

    CLEAR ls_result.
    ls_result = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        operation_number  = '0020'
        posting_date_from = '20261001'
        posting_date_to   = '20261031'
        maximum_results   = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-operation_summaries )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-operation_suboperation
      exp = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 2 ]-operation_suboperation
      exp = '0002' ).

    ls_result = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material           = 'MAT-1'
        plant              = '1000'
        operation_sequence = '000002'
        posting_date_from  = '20261001'
        posting_date_to    = '20261031'
        maximum_results    = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-returned_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-confirmations[ 1 ]-operation_sequence
      exp = '000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-confirmations[ 2 ]-operation_number
      exp = '0010' ).

    ls_result = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        control_key       = 'PP01'
        posting_date_from = '20261001'
        posting_date_to   = '20261031'
        maximum_results   = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-returned_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-confirmations[ 1 ]-control_key
      exp = 'PP01' ).

    ls_result = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        quantity_unit     = 'BOX'
        posting_date_from = '20261001'
        posting_date_to   = '20261031'
        maximum_results   = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-returned_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-confirmations[ 1 ]-quantity_unit
      exp = 'BOX' ).
  ENDMETHOD.

  METHOD summarizes_confirmation_page.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order = '0000000001'
        production_item  = '0001'
        order_category   = '10'
        material         = 'MAT-1'
        plant            = '1000' )
      ( production_order = '0000000002'
        production_item  = '0001'
        order_category   = '10'
        material         = 'MAT-1'
        plant            = '1000' ) ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        confirmation          = '0000000001'
        confirmation_counter  = '00000001'
        operation_description = 'Make component'
        control_key           = 'PP01'
        resource_object_id    = '00000001'
        posting_date          = '20261010'
        yield_quantity        = '2.000'
        rework_quantity       = '0.100'
        scrap_quantity        = '0.300'
        quantity_unit         = 'EA'
        is_reversed           = abap_true )
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        confirmation          = '0000000002'
        confirmation_counter  = '00000001'
        operation_description = 'Make component'
        control_key           = 'PP01'
        resource_object_id    = '00000001'
        posting_date          = '20261012'
        yield_quantity        = '3.000'
        quantity_unit         = 'EA'
        is_final              = abap_true )
      ( production_order      = '0000000002'
        order_category        = '10'
        operation_counter     = '00000002'
        operation_number      = '0010'
        operation_sequence    = '000000'
        confirmation          = '0000000003'
        confirmation_counter  = '00000001'
        operation_description = 'Inspect component'
        control_key           = 'QM01'
        resource_object_id    = '00000002'
        posting_date          = '20261013'
        yield_quantity        = '5.000'
        quantity_unit         = 'EA' )
      ( production_order      = '0000000002'
        order_category        = '10'
        operation_counter     = '00000002'
        operation_number      = '0010'
        operation_sequence    = '000000'
        confirmation          = '0000000004'
        confirmation_counter  = '00000001'
        operation_description = 'Inspect component'
        control_key           = 'QM01'
        resource_object_id    = '00000002'
        posting_date          = '20261014'
        yield_quantity        = '100.000'
        quantity_unit         = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        posting_date_from = '20261001'
        posting_date_to   = '20261031'
        maximum_results   = 3 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_truncated ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-returned_count
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-operation_summaries )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-order_summaries )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-order_summaries[ 1 ]-production_order
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-order_summaries[ 1 ]-order_category
      exp = '10' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-order_summaries[ 1 ]-quantity_unit
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-order_summaries[ 1 ]-confirmation_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-order_summaries[ 1 ]-final_confirmation_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-order_summaries[ 1 ]-partial_confirmation_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-order_summaries[ 1 ]-final_confirmation_pct
      exp = CONV decfloat34( '50.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-order_summaries[ 1 ]-partial_confirmation_pct
      exp = CONV decfloat34( '50.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-order_summaries[ 1 ]-reversed_confirmation_pct
      exp = CONV decfloat34( '50.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-order_summaries[ 1 ]-reversed_confirmation_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-order_summaries[ 1 ]-first_posting_date
      exp = '20261010' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-order_summaries[ 1 ]-last_posting_date
      exp = '20261012' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-order_summaries[ 1 ]-yield_quantity_total
      exp = CONV decfloat34( '5.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-order_summaries[ 1 ]-yield_non_reversed_total
      exp = CONV decfloat34( '3.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-order_summaries[ 1 ]-rework_quantity_total
      exp = CONV decfloat34( '0.100' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-order_summaries[ 1 ]-scrap_quantity_total
      exp = CONV decfloat34( '0.300' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-order_summaries[ 1 ]-rework_non_reversed_total
      exp = CONV decfloat34( '0.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-order_summaries[ 1 ]-scrap_non_reversed_total
      exp = CONV decfloat34( '0.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-order_summaries[ 2 ]-production_order
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-order_summaries[ 2 ]-confirmation_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-order_summaries[ 2 ]-partial_confirmation_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-order_summaries[ 2 ]-partial_confirmation_pct
      exp = CONV decfloat34( '100.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-order_summaries[ 2 ]-yield_quantity_total
      exp = CONV decfloat34( '5.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-production_order
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-order_category
      exp = '10' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-operation_number
      exp = '0010' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-operation_counter
      exp = '00000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-operation_sequence
      exp = '000000' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-operation_description
      exp = 'Make component' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-control_key
      exp = 'PP01' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-resource_object_id
      exp = '00000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-quantity_unit
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-first_posting_date
      exp = '20261010' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-last_posting_date
      exp = '20261012' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-confirmation_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-final_confirmation_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-partial_confirmation_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-final_confirmation_pct
      exp = CONV decfloat34( '50.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-partial_confirmation_pct
      exp = CONV decfloat34( '50.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-reversed_confirmation_pct
      exp = CONV decfloat34( '50.00' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-reversed_confirmation_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-yield_quantity_total
      exp = CONV decfloat34( '5.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-rework_quantity_total
      exp = CONV decfloat34( '0.100' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-scrap_quantity_total
      exp = CONV decfloat34( '0.300' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-yield_non_reversed_total
      exp = CONV decfloat34( '3.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-rework_non_reversed_total
      exp = CONV decfloat34( '0.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-scrap_non_reversed_total
      exp = CONV decfloat34( '0.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 2 ]-production_order
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 2 ]-order_category
      exp = '10' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 2 ]-operation_number
      exp = '0010' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 2 ]-operation_description
      exp = 'Inspect component' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 2 ]-control_key
      exp = 'QM01' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 2 ]-resource_object_id
      exp = '00000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 2 ]-confirmation_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 2 ]-first_posting_date
      exp = '20261013' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 2 ]-last_posting_date
      exp = '20261013' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 2 ]-yield_quantity_total
      exp = CONV decfloat34( '5.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 2 ]-yield_non_reversed_total
      exp = CONV decfloat34( '5.000' ) ).

    lo_repository->order_confirmations = VALUE #(
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        confirmation          = '0000000011'
        confirmation_counter  = '00000001'
        operation_description = 'Make component'
        control_key           = 'PP01'
        posting_date          = '20261020'
        quantity_unit         = 'EA' )
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000002'
        operation_number      = '0010'
        operation_sequence    = '000000'
        confirmation          = '0000000012'
        confirmation_counter  = '00000001'
        operation_description = 'Make component'
        control_key           = 'PP01'
        posting_date          = '20261021'
        quantity_unit         = 'EA' ) ).
    ls_result = lo_cut->search_confirmations_by_window(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        posting_date_from = '20261001'
        posting_date_to   = '20261031'
        maximum_results   = 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-operation_summaries )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 1 ]-operation_counter
      exp = '00000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operation_summaries[ 2 ]-operation_counter
      exp = '00000002' ).
  ENDMETHOD.

  METHOD rejects_bad_conf_window.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material          = 'MAT-1'
            plant             = '1000'
            posting_date_from = '20260230'
            posting_date_to   = '20260331'
            maximum_results   = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material               = 'MAT-1'
            plant                  = '1000'
            operation_suboperation = '0001'
            posting_date_from      = '20261001'
            posting_date_to        = '20261031'
            maximum_results        = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material               = 'MAT-1'
            plant                  = '1000'
            posting_date_from      = '20260301'
            posting_date_to        = '20260331'
            after_posting_date     = '20260315'
            after_production_order = '0000000001'
            after_confirmation     = '0000000001'
            maximum_results        = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material          = 'MAT-1'
            plant             = '1000'
            posting_date_from = '20260301'
            posting_date_to   = '20260331'
            maximum_results   = 501 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_window_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material           = 'MAT-1'
            plant              = '1000'
            posting_date_from  = '20260301'
            posting_date_to    = '20260331'
            filter_work_center = 'Y'
            maximum_results    = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_window_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material                 = 'MAT-1'
            plant                    = '1000'
            posting_date_from        = '20260301'
            posting_date_to          = '20260331'
            filter_work_center_plant = 'Y'
            maximum_results          = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_window_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material                  = 'MAT-1'
            plant                     = '1000'
            posting_date_from         = '20260301'
            posting_date_to           = '20260331'
            filter_resource_object_id = 'Y'
            maximum_results           = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_window_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material            = 'MAT-1'
            plant               = '1000'
            posting_date_from   = '20260301'
            posting_date_to     = '20260331'
            positive_yield_only = 'Y'
            maximum_results     = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_window_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material          = 'MAT-1'
            plant             = '1000'
            posting_date_from = '20260301'
            posting_date_to   = '20260331'
            exclude_reversed  = 'Y'
            maximum_results   = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_window_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material          = 'MAT-1'
            plant             = '1000'
            posting_date_from = '20260301'
            posting_date_to   = '20260331'
            final_only        = 'Y'
            maximum_results   = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_window_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material          = 'MAT-1'
            plant             = '1000'
            posting_date_from = '20260301'
            posting_date_to   = '20260331'
            partial_only      = 'Y'
            maximum_results   = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_window_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material          = 'MAT-1'
            plant             = '1000'
            posting_date_from = '20260301'
            posting_date_to   = '20260331'
            final_only        = abap_true
            partial_only      = abap_true
            maximum_results   = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_window_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material             = 'MAT-1'
            plant                = '1000'
            posting_date_from    = '20260301'
            posting_date_to      = '20260331'
            confirmation_counter = '00000002'
            maximum_results      = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_window_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material          = 'MAT-1'
            plant             = '1000'
            order_category    = '99'
            posting_date_from = '20260301'
            posting_date_to   = '20260331'
            maximum_results   = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_window_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material          = 'MAT-1'
            plant             = '1000'
            operation_counter = '00000002'
            posting_date_from = '20260301'
            posting_date_to   = '20260331'
            maximum_results   = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_window_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material          = 'MAT-1'
            plant             = '1000'
            posting_date_from = '20260301'
            posting_date_to   = '20260331'
            reversed_only     = 'Y'
            maximum_results   = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_window_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material          = 'MAT-1'
            plant             = '1000'
            posting_date_from = '20260301'
            posting_date_to   = '20260331'
            exclude_reversed  = abap_true
            reversed_only     = abap_true
            maximum_results   = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_window_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material             = 'MAT-1'
            plant                = '1000'
            posting_date_from    = '20260301'
            posting_date_to      = '20260331'
            positive_rework_only = 'Y'
            maximum_results      = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_window_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->search_confirmations_by_window(
          is_selection = VALUE #(
            material            = 'MAT-1'
            plant               = '1000'
            posting_date_from   = '20260301'
            posting_date_to     = '20260331'
            positive_scrap_only = 'Y'
            maximum_results     = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_window_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_bad_window_results.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).
    DATA ls_selection TYPE
      zif_prod_order_read_repo=>ty_confirmation_window_selection.
    DATA lt_bad_confirmations TYPE
      zif_prod_order_read_repo=>ty_order_confirmations.

    ls_selection = VALUE #(
      material          = 'MAT-1'
      plant             = '1000'
      posting_date_from = '20261001'
      posting_date_to   = '20261031'
      maximum_results   = 10 ).
    ls_selection-production_order = '0000000001'.
    lt_bad_confirmations = VALUE #(
      ( production_order     = '0000000002'
        operation_number     = '0020'
        confirmation         = '0000000001'
        confirmation_counter = '00000001'
        posting_date         = '20261011' ) ).
    assert_bad_window_result(
      io_cut           = lo_cut
      io_repository    = lo_repository
      is_selection     = ls_selection
      it_confirmations = lt_bad_confirmations ).

    CLEAR ls_selection-production_order.
    ls_selection-order_category = '40'.
    lt_bad_confirmations = VALUE #(
      ( production_order     = '0000000001'
        order_category       = '10'
        operation_number     = '0020'
        confirmation         = '0000000001'
        confirmation_counter = '00000001'
        posting_date         = '20261011' ) ).
    assert_bad_window_result(
      io_cut           = lo_cut
      io_repository    = lo_repository
      is_selection     = ls_selection
      it_confirmations = lt_bad_confirmations ).

    CLEAR ls_selection-order_category.
    ls_selection-production_order = '0000000001'.
    ls_selection-operation_counter = '00000002'.
    lt_bad_confirmations = VALUE #(
      ( production_order     = '0000000001'
        operation_counter    = '00000001'
        operation_number     = '0020'
        confirmation         = '0000000001'
        confirmation_counter = '00000001'
        posting_date         = '20261011' ) ).
    assert_bad_window_result(
      io_cut           = lo_cut
      io_repository    = lo_repository
      is_selection     = ls_selection
      it_confirmations = lt_bad_confirmations ).

    CLEAR ls_selection-production_order.
    CLEAR ls_selection-operation_counter.
    ls_selection-filter_resource_object_id = abap_true.
    ls_selection-resource_object_id = '00000001'.
    lt_bad_confirmations = VALUE #(
      ( production_order     = '0000000001'
        operation_number     = '0020'
        resource_object_id   = '00000002'
        confirmation         = '0000000001'
        confirmation_counter = '00000001'
        posting_date         = '20261011' ) ).
    assert_bad_window_result(
      io_cut           = lo_cut
      io_repository    = lo_repository
      is_selection     = ls_selection
      it_confirmations = lt_bad_confirmations ).

    CLEAR ls_selection-filter_resource_object_id.
    CLEAR ls_selection-resource_object_id.
    CLEAR ls_selection-production_order.
    CLEAR ls_selection-operation_counter.
    ls_selection-confirmation_number = '0000000001'.
    ls_selection-confirmation_counter = '00000002'.
    lt_bad_confirmations = VALUE #(
      ( production_order     = '0000000001'
        operation_number     = '0020'
        confirmation         = '0000000001'
        confirmation_counter = '00000001'
        posting_date         = '20261011' ) ).
    assert_bad_window_result(
      io_cut           = lo_cut
      io_repository    = lo_repository
      is_selection     = ls_selection
      it_confirmations = lt_bad_confirmations ).

    CLEAR ls_selection-confirmation_number.
    CLEAR ls_selection-confirmation_counter.
    lt_bad_confirmations = VALUE #(
      ( production_order     = '0000000001'
        operation_number     = '0020'
        confirmation         = '0000000001'
        confirmation_counter = '00000001'
        posting_date         = '20260930' ) ).
    assert_bad_window_result(
      io_cut           = lo_cut
      io_repository    = lo_repository
      is_selection     = ls_selection
      it_confirmations = lt_bad_confirmations ).

    ls_selection-operation_number = '0020'.
    lt_bad_confirmations = VALUE #(
      ( production_order     = '0000000001'
        operation_number     = '0010'
        confirmation         = '0000000002'
        confirmation_counter = '00000001'
        posting_date         = '20261011' ) ).
    assert_bad_window_result(
      io_cut           = lo_cut
      io_repository    = lo_repository
      is_selection     = ls_selection
      it_confirmations = lt_bad_confirmations ).

    CLEAR ls_selection-operation_number.
    ls_selection-operation_number_from = '0020'.
    ls_selection-operation_number_to = '0030'.
    lt_bad_confirmations = VALUE #(
      ( production_order     = '0000000001'
        operation_number     = '0010'
        confirmation         = '0000000002'
        confirmation_counter = '00000001'
        posting_date         = '20261011' ) ).
    assert_bad_window_result(
      io_cut           = lo_cut
      io_repository    = lo_repository
      is_selection     = ls_selection
      it_confirmations = lt_bad_confirmations ).
    CLEAR ls_selection-operation_number_from.
    CLEAR ls_selection-operation_number_to.
    ls_selection-operation_sequence_from = '000001'.
    ls_selection-operation_sequence_to = '000002'.
    lt_bad_confirmations = VALUE #(
      ( production_order     = '0000000001'
        operation_sequence   = '000003'
        operation_number     = '0020'
        confirmation         = '0000000002'
        confirmation_counter = '00000001'
        posting_date         = '20261011' ) ).
    assert_bad_window_result(
      io_cut           = lo_cut
      io_repository    = lo_repository
      is_selection     = ls_selection
      it_confirmations = lt_bad_confirmations ).
    CLEAR ls_selection-operation_sequence_from.
    CLEAR ls_selection-operation_sequence_to.
    ls_selection-operation_suboperation_from = '0001'.
    ls_selection-operation_suboperation_to = '0002'.
    lt_bad_confirmations = VALUE #(
      ( production_order       = '0000000001'
        operation_number       = '0020'
        operation_suboperation = '0003'
        confirmation           = '0000000002'
        confirmation_counter   = '00000001'
        posting_date           = '20261011' ) ).
    assert_bad_window_result(
      io_cut           = lo_cut
      io_repository    = lo_repository
      is_selection     = ls_selection
      it_confirmations = lt_bad_confirmations ).
    CLEAR ls_selection-operation_suboperation_from.
    CLEAR ls_selection-operation_suboperation_to.
    ls_selection-operation_counter_from = '00000002'.
    ls_selection-operation_counter_to = '00000003'.
    ls_selection-production_order = '0000000001'.
    lt_bad_confirmations = VALUE #(
      ( production_order     = '0000000001'
        operation_counter    = '00000001'
        operation_number     = '0020'
        confirmation         = '0000000002'
        confirmation_counter = '00000001'
        posting_date         = '20261011' ) ).
    assert_bad_window_result(
      io_cut           = lo_cut
      io_repository    = lo_repository
      is_selection     = ls_selection
      it_confirmations = lt_bad_confirmations ).
    CLEAR ls_selection-operation_counter_from.
    CLEAR ls_selection-operation_counter_to.
    CLEAR ls_selection-production_order.
    ls_selection-confirmation_counter_from = '00000002'.
    ls_selection-confirmation_counter_to = '00000003'.
    ls_selection-confirmation_number = '0000000001'.
    lt_bad_confirmations = VALUE #(
      ( production_order     = '0000000001'
        confirmation         = '0000000001'
        confirmation_counter = '00000001'
        operation_number     = '0020'
        posting_date         = '20261011' ) ).
    assert_bad_window_result(
      io_cut           = lo_cut
      io_repository    = lo_repository
      is_selection     = ls_selection
      it_confirmations = lt_bad_confirmations ).
    CLEAR ls_selection-confirmation_counter_from.
    CLEAR ls_selection-confirmation_counter_to.
    CLEAR ls_selection-confirmation_number.
    ls_selection-work_center = 'WC-01'.
    lt_bad_confirmations = VALUE #(
      ( production_order     = '0000000001'
        work_center          = 'WC-02'
        confirmation         = '0000000001'
        confirmation_counter = '00000001'
        posting_date         = '20261011' ) ).
    assert_bad_window_result(
      io_cut           = lo_cut
      io_repository    = lo_repository
      is_selection     = ls_selection
      it_confirmations = lt_bad_confirmations ).
    CLEAR ls_selection-work_center.
    ls_selection-final_only = abap_true.
    lt_bad_confirmations = VALUE #(
      ( production_order     = '0000000001'
        operation_number     = '0020'
        confirmation         = '0000000003'
        confirmation_counter = '00000001'
        posting_date         = '20261011' ) ).
    assert_bad_window_result(
      io_cut           = lo_cut
      io_repository    = lo_repository
      is_selection     = ls_selection
      it_confirmations = lt_bad_confirmations ).

    ls_selection-final_only = abap_false.
    ls_selection-exclude_reversed = abap_true.
    lt_bad_confirmations = VALUE #(
      ( production_order     = '0000000001'
        operation_number     = '0020'
        confirmation         = '0000000004'
        confirmation_counter = '00000001'
        posting_date         = '20261011'
        is_reversed          = abap_true ) ).
    assert_bad_window_result(
      io_cut           = lo_cut
      io_repository    = lo_repository
      is_selection     = ls_selection
      it_confirmations = lt_bad_confirmations ).

    ls_selection-exclude_reversed = abap_false.
    ls_selection-reversed_only = abap_true.
    lt_bad_confirmations = VALUE #(
      ( production_order     = '0000000001'
        operation_number     = '0020'
        confirmation         = '0000000004'
        confirmation_counter = '00000001'
        posting_date         = '20261011' ) ).
    assert_bad_window_result(
      io_cut           = lo_cut
      io_repository    = lo_repository
      is_selection     = ls_selection
      it_confirmations = lt_bad_confirmations ).
    ls_selection-reversed_only = abap_false.
    ls_selection-positive_rework_only = abap_true.
    ls_selection-positive_scrap_only = abap_true.
    lt_bad_confirmations = VALUE #(
      ( production_order     = '0000000001'
        operation_number     = '0020'
        confirmation         = '0000000004'
        confirmation_counter = '00000001'
        posting_date         = '20261011'
        rework_quantity      = '1.000'
        scrap_quantity       = '0.000' ) ).
    assert_bad_window_result(
      io_cut           = lo_cut
      io_repository    = lo_repository
      is_selection     = ls_selection
      it_confirmations = lt_bad_confirmations ).
    ls_selection-positive_rework_only = abap_false.
    ls_selection-positive_scrap_only = abap_false.
    ls_selection-positive_yield_only = abap_true.
    lt_bad_confirmations = VALUE #(
      ( production_order     = '0000000001'
        operation_number     = '0020'
        confirmation         = '0000000004'
        confirmation_counter = '00000001'
        posting_date         = '20261011'
        yield_quantity       = '0.000' ) ).
    assert_bad_window_result(
      io_cut           = lo_cut
      io_repository    = lo_repository
      is_selection     = ls_selection
      it_confirmations = lt_bad_confirmations ).
    ls_selection-positive_yield_only = abap_false.
    ls_selection-after_posting_date = '20261011'.
    ls_selection-after_production_order = '0000000001'.
    ls_selection-after_confirmation = '0000000005'.
    ls_selection-after_confirmation_counter = '00000001'.
    lt_bad_confirmations = VALUE #(
      ( production_order     = '0000000001'
        operation_number     = '0020'
        confirmation         = '0000000005'
        confirmation_counter = '00000001'
        posting_date         = '20261011' ) ).
    assert_bad_window_result(
      io_cut           = lo_cut
      io_repository    = lo_repository
      is_selection     = ls_selection
      it_confirmations = lt_bad_confirmations ).

    CLEAR ls_selection-after_posting_date.
    CLEAR ls_selection-after_production_order.
    CLEAR ls_selection-after_confirmation.
    CLEAR ls_selection-after_confirmation_counter.
    ls_selection-control_key = 'PP01'.
    lt_bad_confirmations = VALUE #(
      ( production_order     = '0000000001'
        operation_number     = '0020'
        control_key          = 'QM01'
        confirmation         = '0000000005'
        confirmation_counter = '00000001'
        posting_date         = '20261011' ) ).
    assert_bad_window_result(
      io_cut           = lo_cut
      io_repository    = lo_repository
      is_selection     = ls_selection
      it_confirmations = lt_bad_confirmations ).

    CLEAR ls_selection-control_key.
    ls_selection-partial_only = abap_true.
    lt_bad_confirmations = VALUE #(
      ( production_order     = '0000000001'
        operation_number     = '0020'
        confirmation         = '0000000005'
        confirmation_counter = '00000001'
        posting_date         = '20261011'
        is_final             = abap_true ) ).
    assert_bad_window_result(
      io_cut           = lo_cut
      io_repository    = lo_repository
      is_selection     = ls_selection
      it_confirmations = lt_bad_confirmations ).

    CLEAR ls_selection-partial_only.
    lt_bad_confirmations = VALUE #(
      ( production_order     = '0000000001'
        operation_number     = '0020'
        confirmation         = '0000000007'
        confirmation_counter = '00000001'
        posting_date         = '20261011' )
      ( production_order     = '0000000001'
        operation_number     = '0020'
        confirmation         = '0000000006'
        confirmation_counter = '00000001'
        posting_date         = '20261011' ) ).
    assert_bad_window_result(
      io_cut           = lo_cut
      io_repository    = lo_repository
      is_selection     = ls_selection
      it_confirmations = lt_bad_confirmations ).

    ls_selection-maximum_results = 1.
    lt_bad_confirmations = VALUE #(
      ( production_order     = '0000000001'
        operation_number     = '0020'
        confirmation         = '0000000008'
        confirmation_counter = '00000001'
        posting_date         = '20261011' )
      ( production_order     = '0000000001'
        operation_number     = '0020'
        confirmation         = '0000000009'
        confirmation_counter = '00000001'
        posting_date         = '20261011' )
      ( production_order     = '0000000001'
        operation_number     = '0020'
        confirmation         = '0000000010'
        confirmation_counter = '00000001'
        posting_date         = '20261011' ) ).
    assert_bad_window_result(
      io_cut           = lo_cut
      io_repository    = lo_repository
      is_selection     = ls_selection
      it_confirmations = lt_bad_confirmations ).
  ENDMETHOD.

  METHOD assert_bad_window_result.
    DATA lv_raised TYPE abap_bool.

    io_repository->use_conf_window_override = abap_true.
    io_repository->conf_window_override = it_confirmations.
    TRY.
        io_cut->search_confirmations_by_window(
          is_selection = is_selection ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.
ENDCLASS.
