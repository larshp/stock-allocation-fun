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
          OR ( is_selection-filter_order_qty_from = abap_true
            AND ls_order_item-order_quantity <
              is_selection-order_qty_from )
          OR ( is_selection-filter_order_qty_to = abap_true
            AND ls_order_item-order_quantity >
              is_selection-order_qty_to )
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
    rt_confirmations = order_confirmations.
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
            OR ls_order_item-order_category = '40' ).
        INSERT ls_order_item-production_order INTO TABLE lt_matching_orders.
      ENDIF.
    ENDLOOP.

    LOOP AT order_confirmations INTO DATA(ls_confirmation).
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
          AND ( is_selection-order_category IS INITIAL
            OR ls_confirmation-order_category =
              is_selection-order_category )
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
    ADD 1 TO operation_read_calls.
    requested_operation_orders = it_production_orders.
    rt_operations = order_operations.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_prod_order_read DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS reads_multiple_items_and_units FOR TESTING
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
    METHODS rejects_invalid_finish_keys FOR TESTING
      RAISING cx_static_check.
    METHODS reads_exact_finish_limit FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_bad_finish_search FOR TESTING
      RAISING cx_static_check.
    METHODS searches_confirmation_window FOR TESTING
      RAISING cx_static_check.
    METHODS excludes_reversed_confirmation FOR TESTING
      RAISING cx_static_check.
    METHODS filters_quality_quantities FOR TESTING
      RAISING cx_static_check.
    METHODS converts_conf_window_base_unit FOR TESTING
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
      act = ls_result-orders[ 1 ]-production_order
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-orders[ 2 ]-items )
      exp = 2 ).
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
      act = ls_result-orders[ 2 ]-items[ 2 ]-open_quantity_base
      exp = CONV decfloat34( 0 ) ).
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
      exp = 2 ).
    cl_abap_unit_assert=>assert_true( ls_result-orders[ 1 ]-is_found ).
    cl_abap_unit_assert=>assert_false( ls_result-orders[ 2 ]-is_found ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-items[ 1 ]-is_quantity_converted ).
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
        yield_quantity         = '2.000'
        rework_quantity        = '0.100'
        scrap_quantity         = '0.300'
        quantity_unit          = 'EA'
        is_reversed            = 'X' )
      ( production_order     = '0000000001'
        operation_number     = '0010'
        operation_sequence   = '000000'
        confirmation         = '0000000001'
        confirmation_counter = '00000001'
        posting_date         = '20261009' )
      ( production_order     = '0000000002'
        operation_number     = '0020'
        operation_sequence   = '000000'
        confirmation         = '0000000002'
        confirmation_counter = '00000002'
        posting_date         = '20261010'
        is_final             = 'X' ) ).
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
        control_key           = 'PP02' )
      ( production_order      = '0000000002'
        operation_counter     = '00000001'
        operation_sequence    = '000000'
        operation_number      = '0010'
        operation_description = 'Cut'
        control_key           = 'PP01' )
      ( production_order      = '0000000002'
        operation_counter     = '00000002'
        operation_sequence    = '000001'
        operation_number      = '0020'
        operation_description = 'Assembly'
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
      act = lines( ls_result-orders[ 2 ]-operations )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-operations[ 1 ]-operation_number
      exp = '0010' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-operations[ 2 ]-operation_number
      exp = '0020' ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 3 ]-is_found ).
  ENDMETHOD.

  METHOD validates_operation_reads.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_operations_bulk(
          it_production_orders = VALUE #(
            ( '0000000001' )
            ( '0000000001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->operation_read_calls
      exp = 0 ).

    lo_repository->order_operations = VALUE #(
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
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-items[ 1 ]-open_quantity_base
      exp = CONV decfloat34( '7.000' ) ).
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
        confirmation          = '0000000001'
        confirmation_counter  = '00000001'
        posting_date          = '20261010'
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
        confirmation          = '0000000002'
        confirmation_counter  = '00000001'
        posting_date          = '20261011'
        yield_quantity        = '3.000'
        rework_quantity       = '0.250'
        scrap_quantity        = '1.000'
        quantity_unit         = 'BOX'
        is_final              = abap_true )
      ( production_order      = '0000000001'
        order_category        = '10'
        operation_counter     = '00000001'
        operation_number      = '0010'
        operation_sequence    = '000000'
        operation_description = 'Make component'
        control_key           = 'PP01'
        confirmation          = '0000000003'
        confirmation_counter  = '00000001'
        posting_date          = '20261012'
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

    cl_abap_unit_assert=>assert_true(
      ls_result-raw_result-is_successful ).
    cl_abap_unit_assert=>assert_not_initial(
      act = ls_result-raw_result-snapshot_timestamp ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-raw_result-confirmations )
      exp = 3 ).
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
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_operation_summaries[ 1 ]-base_quantity_unit
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_operation_summaries[ 1 ]-confirmation_count
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_operation_summaries[ 1 ]-final_confirmation_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_operation_summaries[ 1 ]-reversed_confirmation_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_operation_summaries[ 1 ]-first_posting_date
      exp = '20261010' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_operation_summaries[ 1 ]-last_posting_date
      exp = '20261012' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_operation_summaries[ 1 ]-yield_quantity_base_total
      exp = CONV decfloat34( '50.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_operation_summaries[ 1 ]-yield_base_non_reversed_total
      exp = CONV decfloat34( '48.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_operation_summaries[ 1 ]-rework_quantity_base_total
      exp = CONV decfloat34( '5.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_operation_summaries[ 1 ]-rework_base_non_reversed_total
      exp = CONV decfloat34( '4.500' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_operation_summaries[ 1 ]-scrap_quantity_base_total
      exp = CONV decfloat34( '18.250' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-base_operation_summaries[ 1 ]-scrap_base_non_reversed_total
      exp = CONV decfloat34( '18.000' ) ).
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
