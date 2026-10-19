CLASS lcl_planned_order_read_repo DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_planned_order_read_repo.
    DATA orders TYPE zif_planned_order_read_repo=>ty_order_headers.
    DATA requested_orders TYPE zif_planned_order_read_repo=>ty_order_numbers.
    DATA read_calls TYPE i.
    DATA use_bulk_override TYPE abap_bool.
    DATA bulk_override TYPE
      zif_planned_order_read_repo=>ty_order_headers.
    DATA requested_selection TYPE
      zif_planned_order_read_repo=>ty_order_selection.
    DATA selection_read_calls TYPE i.
    DATA use_finish_window_override TYPE abap_bool.
    DATA finish_window_override TYPE
      zif_planned_order_read_repo=>ty_order_headers.
ENDCLASS.

CLASS lcl_planned_order_read_repo IMPLEMENTATION.
  METHOD zif_planned_order_read_repo~read_orders.
    ADD 1 TO read_calls.
    requested_orders = it_planned_orders.
    IF use_bulk_override = abap_true.
      rt_orders = bulk_override.
      RETURN.
    ENDIF.
    rt_orders = orders.
  ENDMETHOD.

  METHOD zif_planned_order_read_repo~read_orders_by_finish_window.
    DATA lt_sorted_orders TYPE zif_planned_order_read_repo=>ty_order_headers.

    ADD 1 TO selection_read_calls.
    requested_selection = is_selection.
    IF use_finish_window_override = abap_true.
      rt_orders = finish_window_override.
      RETURN.
    ENDIF.
    lt_sorted_orders = orders.
    SORT lt_sorted_orders BY finish_date planned_order.

    LOOP AT lt_sorted_orders INTO DATA(ls_order).
      IF ls_order-material <> is_selection-material
          OR ls_order-plant <> is_selection-plant
          OR ( ( is_selection-filter_planning_plant = abap_true
              OR is_selection-planning_plant IS NOT INITIAL )
            AND ls_order-planning_plant <>
              is_selection-planning_plant )
          OR ( ( is_selection-filter_planned_order_user = abap_true
              OR is_selection-planned_order_user IS NOT INITIAL )
            AND ls_order-planned_order_user <>
              is_selection-planned_order_user )
          OR ( is_selection-creation_date_from IS NOT INITIAL
            AND ( ls_order-creation_date <
                is_selection-creation_date_from
              OR ls_order-creation_date >
                is_selection-creation_date_to ) )
          OR ( is_selection-last_change_timestamp_from IS NOT INITIAL
            AND ls_order-last_change_timestamp <
              is_selection-last_change_timestamp_from )
          OR ( is_selection-last_change_timestamp_to IS NOT INITIAL
            AND ls_order-last_change_timestamp >
              is_selection-last_change_timestamp_to )
          OR ( ( is_selection-filter_sales_order = abap_true
              OR is_selection-sales_order IS NOT INITIAL )
            AND ls_order-sales_order <> is_selection-sales_order )
          OR ( ( is_selection-filter_planning_scenario = abap_true
              OR is_selection-planning_scenario IS NOT INITIAL )
            AND ls_order-planning_scenario <>
              is_selection-planning_scenario )
          OR ( ( is_selection-filter_order_type = abap_true
              OR is_selection-order_type IS NOT INITIAL )
            AND ls_order-order_type <> is_selection-order_type )
          OR ( is_selection-filter_storage_location = abap_true
            AND ls_order-storage_location <>
              is_selection-storage_location )
          OR ( is_selection-filter_procurement_indicator = abap_true
            AND ls_order-procurement_indicator <>
              is_selection-procurement_indicator )
          OR ( ( is_selection-filter_order_unit = abap_true
              OR is_selection-order_unit IS NOT INITIAL )
            AND ls_order-order_unit <> is_selection-order_unit )
          OR ( is_selection-positive_quantity_only = abap_true
            AND ls_order-quantity <= 0 )
          OR ( is_selection-filter_quantity_from = abap_true
            AND ls_order-quantity < is_selection-quantity_from )
          OR ( is_selection-filter_quantity_to = abap_true
            AND ls_order-quantity > is_selection-quantity_to )
          OR ( is_selection-filter_mrp_controller = abap_true
            AND ls_order-mrp_controller <> is_selection-mrp_controller )
          OR ( is_selection-filter_production_supervisor = abap_true
            AND ls_order-production_supervisor <>
              is_selection-production_supervisor )
          OR ( is_selection-filter_production_version = abap_true
            AND ls_order-production_version <>
              is_selection-production_version )
          OR ( is_selection-filter_mrp_area = abap_true
            AND ls_order-mrp_area <> is_selection-mrp_area )
          OR ( is_selection-filter_account_category = abap_true
            AND ls_order-account_assignment_category <>
              is_selection-account_assignment_category )
          OR ( is_selection-filter_sales_order_item = abap_true
            AND ls_order-sales_order_item <>
              is_selection-sales_order_item )
          OR ( is_selection-filter_sales_schedule_line = abap_true
            AND ls_order-sales_order_schedule_line <>
              is_selection-sales_order_schedule_line )
          OR ( is_selection-filter_special_stock = abap_true
            AND ls_order-special_stock_indicator <>
              is_selection-special_stock_indicator )
          OR ( is_selection-filter_fixed_indicator = abap_true
            AND ls_order-fixed_indicator <>
              is_selection-fixed_indicator )
          OR ( ( is_selection-filter_start_date = abap_true
              OR is_selection-start_date IS NOT INITIAL )
            AND ls_order-start_date <> is_selection-start_date )
          OR ( is_selection-start_date_from IS NOT INITIAL
            AND ( ls_order-start_date < is_selection-start_date_from
              OR ls_order-start_date > is_selection-start_date_to ) )
          OR ( ( is_selection-filter_scheduled_start_date = abap_true
              OR is_selection-scheduled_start_date IS NOT INITIAL )
            AND ls_order-scheduled_start_date <>
              is_selection-scheduled_start_date )
          OR ( is_selection-scheduled_start_date_from IS NOT INITIAL
            AND ( ls_order-scheduled_start_date <
                is_selection-scheduled_start_date_from
              OR ls_order-scheduled_start_date >
                is_selection-scheduled_start_date_to ) )
          OR ( ( is_selection-filter_scheduled_finish_date = abap_true
              OR is_selection-scheduled_finish_date IS NOT INITIAL )
            AND ls_order-scheduled_finish_date <>
              is_selection-scheduled_finish_date )
          OR ( is_selection-scheduled_finish_date_from IS NOT INITIAL
            AND ( ls_order-scheduled_finish_date <
                is_selection-scheduled_finish_date_from
              OR ls_order-scheduled_finish_date >
                is_selection-scheduled_finish_date_to ) )
          OR ( is_selection-filter_scheduled_start_time = abap_true
            AND ( ls_order-scheduled_start_time <
                is_selection-scheduled_start_time_from
              OR ls_order-scheduled_start_time >
                is_selection-scheduled_start_time_to ) )
          OR ( is_selection-filter_scheduled_finish_time = abap_true
            AND ( ls_order-scheduled_finish_time <
                is_selection-scheduled_finish_time_from
              OR ls_order-scheduled_finish_time >
                is_selection-scheduled_finish_time_to ) )
          OR ls_order-finish_date < is_selection-finish_date_from
          OR ls_order-finish_date > is_selection-finish_date_to
          OR ( is_selection-after_finish_date IS NOT INITIAL
            AND ( ls_order-finish_date < is_selection-after_finish_date
              OR ( ls_order-finish_date =
                is_selection-after_finish_date
                AND ls_order-planned_order <=
                  is_selection-after_planned_order ) ) ).
        CONTINUE.
      ENDIF.

      APPEND ls_order TO rt_orders.
      IF lines( rt_orders ) > is_selection-maximum_results.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_planned_order_read DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS reads_in_request_order FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_duplicate_bulk_headers FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_extra_bulk_header FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_blank_bulk_header FOR TESTING
      RAISING cx_static_check.
    METHODS reports_missing_order FOR TESTING
      RAISING cx_static_check.
    METHODS reports_missing_unit_ratio FOR TESTING
      RAISING cx_static_check.
    METHODS validates_numbers_before_read FOR TESTING
      RAISING cx_static_check.
    METHODS empty_read_skips_repository FOR TESTING
      RAISING cx_static_check.
    METHODS searches_bounded_finish_window FOR TESTING
      RAISING cx_static_check.
    METHODS filters_sales_order_window FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_sales_order_scope_loss FOR TESTING
      RAISING cx_static_check.
    METHODS filters_blank_sales_order FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_bad_sales_order_filter FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_blank_sales_drift FOR TESTING
      RAISING cx_static_check.
    METHODS filters_sales_order_item FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_bad_sales_item_filter FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_sales_item_scope_drift FOR TESTING
      RAISING cx_static_check.
    METHODS filters_sales_schedule_line FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_bad_sales_schedule FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_sales_schedule_drift FOR TESTING
      RAISING cx_static_check.
    METHODS filters_planned_order_user FOR TESTING
      RAISING cx_static_check.
    METHODS filters_blank_user FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_bad_user_filter FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_blank_user_scope_drift FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_user_scope_drift FOR TESTING
      RAISING cx_static_check.
    METHODS filters_planning_plant FOR TESTING
      RAISING cx_static_check.
    METHODS filters_blank_planning_plant FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_bad_plan_plant_filter FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_blank_plan_plant_drift FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_planning_plant_drift FOR TESTING
      RAISING cx_static_check.
    METHODS filters_planning_scenario FOR TESTING
      RAISING cx_static_check.
    METHODS filters_blank_scenario FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_bad_scenario_filter FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_blank_scenario_drift FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_scenario_scope_loss FOR TESTING
      RAISING cx_static_check.
    METHODS filters_order_type_window FOR TESTING
      RAISING cx_static_check.
    METHODS filters_blank_order_type FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_bad_order_type_filter FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_blank_order_type_drift FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_order_type_scope_drift FOR TESTING
      RAISING cx_static_check.
    METHODS filters_storage_location FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_bad_storage_filter FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_storage_scope_drift FOR TESTING
      RAISING cx_static_check.
    METHODS filters_procurement_indicator FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_bad_procurement_filter FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_procurement_scope FOR TESTING
      RAISING cx_static_check.
    METHODS filters_positive_quantity FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_bad_quantity_flag FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_quantity_scope_drift FOR TESTING
      RAISING cx_static_check.
    METHODS filters_mrp_controller FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_bad_mrp_filter FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_mrp_scope FOR TESTING
      RAISING cx_static_check.
    METHODS filters_production_supervisor FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_bad_supervisor_filter FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_supervisor_scope FOR TESTING
      RAISING cx_static_check.
    METHODS filters_production_version FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_bad_version_filter FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_version_scope FOR TESTING
      RAISING cx_static_check.
    METHODS filters_mrp_area FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_bad_mrp_area_filter FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_mrp_area_scope FOR TESTING
      RAISING cx_static_check.
    METHODS filters_account_category FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_bad_account_flag FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_account_scope FOR TESTING
      RAISING cx_static_check.
    METHODS filters_creation_date_window FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_partial_creation_dates FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_creation_date_drift FOR TESTING
      RAISING cx_static_check.
    METHODS filters_start_date_window FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_partial_start_dates FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_start_date_scope_loss FOR TESTING
      RAISING cx_static_check.
    METHODS filters_sched_finish_window FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_partial_sched_finish FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_invalid_sched_finish FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_sched_finish_scope FOR TESTING
      RAISING cx_static_check.
    METHODS filters_sched_start_window FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_partial_sched_start FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_invalid_sched_start FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_sched_start_scope FOR TESTING
      RAISING cx_static_check.
    METHODS filters_sched_time_windows FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_bad_sched_time_window FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_sched_time_scope FOR TESTING
      RAISING cx_static_check.
    METHODS filters_special_stock_window FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_bad_stock_filter FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_stock_scope_drift FOR TESTING
      RAISING cx_static_check.
    METHODS filters_fixed_indicator_window FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_bad_fixed_filter FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_fixed_scope_drift FOR TESTING
      RAISING cx_static_check.
    METHODS searches_empty_finish_window FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_bad_finish_headers FOR TESTING
      RAISING cx_static_check.
    METHODS exact_limit_not_truncated FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_bad_window_before_read FOR TESTING
      RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_planned_order_read IMPLEMENTATION.
  METHOD reads_in_request_order.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order            = '0000000002'
        material                 = 'MAT-2'
        plant                    = '1000'
        quantity                 = '3.000'
        order_unit               = 'CS'
        base_unit                = 'EA'
        unit_to_base_numerator   = 12
        unit_to_base_denominator = 1 )
      ( planned_order         = '0000000001'
        material              = 'MAT-1'
        plant                 = '2000'
        scheduled_start_date  = '20261109'
        scheduled_start_time  = '080000'
        scheduled_finish_date = '20261110'
        scheduled_finish_time = '170000'
        last_change_timestamp = '20261108153045'
        quantity              = '2.000'
        order_unit            = 'EA'
        base_unit             = 'EA'
        fixed_indicator       = abap_true ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_bulk(
      it_planned_orders = VALUE #(
        ( '0000000001' )
        ( '0000000002' ) ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_not_initial(
      act = ls_result-snapshot_timestamp ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->read_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->requested_orders[ 2 ]
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-planned_order
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 1 ]-order_header-fixed_indicator ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-order_header-scheduled_start_date
      exp = '20261109' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-order_header-scheduled_start_time
      exp = '080000' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-order_header-scheduled_finish_date
      exp = '20261110' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-order_header-scheduled_finish_time
      exp = '170000' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-order_header-last_change_timestamp
      exp = CONV plaf-pstmp( '20261108153045' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-quantity_in_base_unit
      exp = CONV decfloat34( '2.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-quantity_in_base_unit
      exp = CONV decfloat34( '36.000' ) ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 2 ]-is_quantity_converted ).
  ENDMETHOD.

  METHOD rejects_duplicate_bulk_headers.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->use_bulk_override = abap_true.
    lo_repository->bulk_override = VALUE #(
      ( planned_order = '0000000001' )
      ( planned_order = '0000000001' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_bulk(
          it_planned_orders = VALUE #( ( '0000000001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->read_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD rejects_extra_bulk_header.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->use_bulk_override = abap_true.
    lo_repository->bulk_override = VALUE #(
      ( planned_order = '0000000002' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_bulk(
          it_planned_orders = VALUE #( ( '0000000001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->read_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD rejects_blank_bulk_header.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->use_bulk_override = abap_true.
    lo_repository->bulk_override = VALUE #(
      ( planned_order = space ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_bulk(
          it_planned_orders = VALUE #( ( '0000000001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->read_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD reports_missing_order.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order = '0000000001'
        material      = 'MAT-1'
        plant         = '1000'
        quantity      = '2.000'
        order_unit    = 'EA'
        base_unit     = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_bulk(
      it_planned_orders = VALUE #(
        ( '0000000001' )
        ( '0000000002' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-not_found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_true( ls_result-orders[ 1 ]-is_found ).
    cl_abap_unit_assert=>assert_false( ls_result-orders[ 2 ]-is_found ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-request_index
      exp = 2 ).
  ENDMETHOD.

  METHOD reports_missing_unit_ratio.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order = '0000000001'
        material      = 'MAT-1'
        plant         = '1000'
        quantity      = '5.000'
        order_unit    = 'BOX'
        base_unit     = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_bulk(
      it_planned_orders = VALUE #( ( '0000000001' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-conversion_failed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_true( ls_result-orders[ 1 ]-is_found ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-is_quantity_converted ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-order_header-quantity
      exp = '5.000' ).
  ENDMETHOD.

  METHOD validates_numbers_before_read.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_bulk(
          it_planned_orders = VALUE #(
            ( '0000000001' )
            ( '0000000001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_bulk(
          it_planned_orders = VALUE #(
            ( '0000000001' )
            ( ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD empty_read_skips_repository.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_bulk(
      it_planned_orders = VALUE #( ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_initial( ls_result-orders ).
    cl_abap_unit_assert=>assert_initial( ls_result-snapshot_timestamp ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_bad_finish_headers.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( planned_order = '0000000001'
        material      = 'MAT-1'
        plant         = '1000'
        finish_date   = '20261110' )
      ( planned_order = '0000000001'
        material      = 'MAT-1'
        plant         = '1000'
        finish_date   = '20261110' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
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
      act = lo_repository->selection_read_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD searches_empty_finish_window.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

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
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD searches_bounded_finish_window.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order = '0000000003'
        material      = 'MAT-1'
        plant         = '1000'
        finish_date   = '20261111'
        quantity      = '2.000'
        order_unit    = 'EA'
        base_unit     = 'EA' )
      ( planned_order            = '0000000002'
        material                 = 'MAT-1'
        plant                    = '1000'
        finish_date              = '20261110'
        quantity                 = '3.000'
        order_unit               = 'CS'
        base_unit                = 'EA'
        unit_to_base_numerator   = 12
        unit_to_base_denominator = 1 )
      ( planned_order = '0000000005'
        material      = 'MAT-1'
        plant         = '1000'
        finish_date   = '20261110'
        quantity      = '4.000'
        order_unit    = 'EA'
        base_unit     = 'EA' )
      ( planned_order = '0000000001'
        material      = 'MAT-1'
        plant         = '1000'
        finish_date   = '20261201'
        quantity      = '5.000'
        order_unit    = 'EA'
        base_unit     = 'EA' )
      ( planned_order = '0000000004'
        material      = 'MAT-2'
        plant         = '1000'
        finish_date   = '20261109'
        quantity      = '7.000'
        order_unit    = 'EA'
        base_unit     = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

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
    cl_abap_unit_assert=>assert_true( ls_result-is_truncated ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-orders )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-planned_order
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-quantity_in_base_unit
      exp = CONV decfloat34( '36.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->requested_selection-material
      exp = 'MAT-1' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->requested_selection-finish_date_from
      exp = '20261101' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-next_finish_date
      exp = '20261110' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-next_planned_order
      exp = '0000000002' ).

    DATA(ls_next_page) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material            = 'MAT-1'
        plant               = '1000'
        finish_date_from    = '20261101'
        finish_date_to      = '20261130'
        after_finish_date   = ls_result-next_finish_date
        after_planned_order = ls_result-next_planned_order
        maximum_results     = 1 ) ).

    cl_abap_unit_assert=>assert_true( ls_next_page-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_next_page-is_truncated ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_next_page-orders[ 1 ]-planned_order
      exp = '0000000005' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_next_page-next_planned_order
      exp = '0000000005' ).
  ENDMETHOD.

  METHOD filters_sales_order_window.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order = '0000000001'
        material      = 'MAT-1'
        plant         = '1000'
        sales_order   = '0000000100'
        finish_date   = '20261110'
        quantity      = '4.000'
        order_unit    = 'EA'
        base_unit     = 'EA' )
      ( planned_order = '0000000002'
        material      = 'MAT-1'
        plant         = '1000'
        sales_order   = '0000000200'
        finish_date   = '20261110'
        quantity      = '5.000'
        order_unit    = 'EA'
        base_unit     = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material         = 'MAT-1'
        plant            = '1000'
        sales_order      = '0000000200'
        finish_date_from = '20261101'
        finish_date_to   = '20261130'
        maximum_results  = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->requested_selection-sales_order
      exp = '0000000200' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-planned_order
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-order_header-sales_order
      exp = '0000000200' ).
  ENDMETHOD.

  METHOD rejects_sales_order_scope_loss.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( planned_order = '0000000001'
        material      = 'MAT-1'
        plant         = '1000'
        sales_order   = '0000000100'
        finish_date   = '20261110' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material         = 'MAT-1'
            plant            = '1000'
            sales_order      = '0000000200'
            finish_date_from = '20261101'
            finish_date_to   = '20261130'
            maximum_results  = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD filters_blank_sales_order.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order = '0000000001'
        material      = 'MAT-1'
        plant         = '1000'
        sales_order   = '0000000100'
        finish_date   = '20261110'
        quantity      = '4.000'
        order_unit    = 'EA'
        base_unit     = 'EA' )
      ( planned_order = '0000000002'
        material      = 'MAT-1'
        plant         = '1000'
        sales_order   = space
        finish_date   = '20261110'
        quantity      = '5.000'
        order_unit    = 'EA'
        base_unit     = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material           = 'MAT-1'
        plant              = '1000'
        filter_sales_order = abap_true
        sales_order        = space
        finish_date_from   = '20261101'
        finish_date_to     = '20261130'
        maximum_results    = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-planned_order
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 1 ]-order_header-sales_order ).
  ENDMETHOD.

  METHOD rejects_bad_sales_order_filter.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material           = 'MAT-1'
            plant              = '1000'
            filter_sales_order = 'Y'
            finish_date_from   = '20261101'
            finish_date_to     = '20261130'
            maximum_results    = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).

  ENDMETHOD.

  METHOD rejects_blank_sales_drift.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( planned_order = '0000000001'
        material      = 'MAT-1'
        plant         = '1000'
        sales_order   = '0000000100'
        finish_date   = '20261110' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material           = 'MAT-1'
            plant              = '1000'
            filter_sales_order = abap_true
            sales_order        = space
            finish_date_from   = '20261101'
            finish_date_to     = '20261130'
            maximum_results    = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD filters_sales_order_item.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order    = '0000000001'
        material         = 'MAT-1'
        plant            = '1000'
        sales_order      = '0000000200'
        sales_order_item = '000010'
        finish_date      = '20261110'
        quantity         = '4.000'
        order_unit       = 'EA'
        base_unit        = 'EA' )
      ( planned_order    = '0000000002'
        material         = 'MAT-1'
        plant            = '1000'
        sales_order      = '0000000200'
        sales_order_item = '000020'
        finish_date      = '20261110'
        quantity         = '5.000'
        order_unit       = 'EA'
        base_unit        = 'EA' )
      ( planned_order    = '0000000003'
        material         = 'MAT-1'
        plant            = '1000'
        sales_order      = '0000000200'
        sales_order_item = '000000'
        finish_date      = '20261110'
        quantity         = '6.000'
        order_unit       = 'EA'
        base_unit        = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material                = 'MAT-1'
        plant                   = '1000'
        sales_order             = '0000000200'
        filter_sales_order_item = abap_true
        sales_order_item        = '000020'
        finish_date_from        = '20261101'
        finish_date_to          = '20261130'
        maximum_results         = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-planned_order
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-order_header-sales_order_item
      exp = '000020' ).

    DATA(ls_initial_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material                = 'MAT-1'
        plant                   = '1000'
        sales_order             = '0000000200'
        filter_sales_order_item = abap_true
        sales_order_item        = '000000'
        finish_date_from        = '20261101'
        finish_date_to          = '20261130'
        maximum_results         = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_initial_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_initial_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_initial_result-orders[ 1 ]-planned_order
      exp = '0000000003' ).
  ENDMETHOD.

  METHOD rejects_bad_sales_item_filter.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                = 'MAT-1'
            plant                   = '1000'
            sales_order             = '0000000200'
            filter_sales_order_item = 'Y'
            finish_date_from        = '20261101'
            finish_date_to          = '20261130'
            maximum_results         = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material         = 'MAT-1'
            plant            = '1000'
            sales_order      = '0000000200'
            sales_order_item = '000020'
            finish_date_from = '20261101'
            finish_date_to   = '20261130'
            maximum_results  = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                = 'MAT-1'
            plant                   = '1000'
            filter_sales_order_item = abap_true
            sales_order_item        = '000020'
            finish_date_from        = '20261101'
            finish_date_to          = '20261130'
            maximum_results         = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_sales_item_scope_drift.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( planned_order    = '0000000001'
        material         = 'MAT-1'
        plant            = '1000'
        sales_order      = '0000000200'
        sales_order_item = '000020'
        finish_date      = '20261110' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                = 'MAT-1'
            plant                   = '1000'
            sales_order             = '0000000200'
            filter_sales_order_item = abap_true
            sales_order_item        = '000010'
            finish_date_from        = '20261101'
            finish_date_to          = '20261130'
            maximum_results         = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD filters_sales_schedule_line.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order             = '0000000001'
        material                  = 'MAT-1'
        plant                     = '1000'
        sales_order               = '0000000200'
        sales_order_item          = '000020'
        sales_order_schedule_line = '0001'
        finish_date               = '20261110'
        quantity                  = '4.000'
        order_unit                = 'EA'
        base_unit                 = 'EA' )
      ( planned_order             = '0000000002'
        material                  = 'MAT-1'
        plant                     = '1000'
        sales_order               = '0000000200'
        sales_order_item          = '000020'
        sales_order_schedule_line = '0002'
        finish_date               = '20261110'
        quantity                  = '5.000'
        order_unit                = 'EA'
        base_unit                 = 'EA' )
      ( planned_order             = '0000000003'
        material                  = 'MAT-1'
        plant                     = '1000'
        sales_order               = '0000000200'
        sales_order_item          = '000020'
        sales_order_schedule_line = '0000'
        finish_date               = '20261110'
        quantity                  = '6.000'
        order_unit                = 'EA'
        base_unit                 = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material                   = 'MAT-1'
        plant                      = '1000'
        sales_order                = '0000000200'
        filter_sales_order_item    = abap_true
        sales_order_item           = '000020'
        filter_sales_schedule_line = abap_true
        sales_order_schedule_line  = '0002'
        finish_date_from           = '20261101'
        finish_date_to             = '20261130'
        maximum_results            = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-planned_order
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-order_header-sales_order_schedule_line
      exp = '0002' ).

    DATA(ls_initial_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material                   = 'MAT-1'
        plant                      = '1000'
        sales_order                = '0000000200'
        filter_sales_order_item    = abap_true
        sales_order_item           = '000020'
        filter_sales_schedule_line = abap_true
        sales_order_schedule_line  = '0000'
        finish_date_from           = '20261101'
        finish_date_to             = '20261130'
        maximum_results            = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_initial_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_initial_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_initial_result-orders[ 1 ]-planned_order
      exp = '0000000003' ).
  ENDMETHOD.

  METHOD rejects_bad_sales_schedule.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                   = 'MAT-1'
            plant                      = '1000'
            sales_order                = '0000000200'
            filter_sales_order_item    = abap_true
            sales_order_item           = '000020'
            filter_sales_schedule_line = 'Y'
            finish_date_from           = '20261101'
            finish_date_to             = '20261130'
            maximum_results            = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                  = 'MAT-1'
            plant                     = '1000'
            sales_order               = '0000000200'
            filter_sales_order_item   = abap_true
            sales_order_item          = '000020'
            sales_order_schedule_line = '0002'
            finish_date_from          = '20261101'
            finish_date_to            = '20261130'
            maximum_results           = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                   = 'MAT-1'
            plant                      = '1000'
            sales_order                = '0000000200'
            filter_sales_schedule_line = abap_true
            sales_order_schedule_line  = '0002'
            finish_date_from           = '20261101'
            finish_date_to             = '20261130'
            maximum_results            = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_sales_schedule_drift.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( planned_order             = '0000000001'
        material                  = 'MAT-1'
        plant                     = '1000'
        sales_order               = '0000000200'
        sales_order_item          = '000020'
        sales_order_schedule_line = '0002'
        finish_date               = '20261110' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                   = 'MAT-1'
            plant                      = '1000'
            sales_order                = '0000000200'
            filter_sales_order_item    = abap_true
            sales_order_item           = '000020'
            filter_sales_schedule_line = abap_true
            sales_order_schedule_line  = '0001'
            finish_date_from           = '20261101'
            finish_date_to             = '20261130'
            maximum_results            = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD filters_planned_order_user.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order      = '0000000001'
        material           = 'MAT-1'
        plant              = '3000'
        planned_order_user = 'MRPUSER'
        finish_date        = '20261110'
        quantity           = '1.000'
        order_unit         = 'EA'
        base_unit          = 'EA' )
      ( planned_order         = '0000000002'
        material              = 'MAT-1'
        plant                 = '3000'
        planned_order_user    = 'PLANNER'
        finish_date           = '20261110'
        quantity              = '1.000'
        order_unit            = 'EA'
        base_unit             = 'EA'
        last_change_timestamp = '20261110120000' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material           = 'MAT-1'
        plant              = '3000'
        planned_order_user = 'PLANNER'
        finish_date_from   = '20261101'
        finish_date_to     = '20261130'
        maximum_results    = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-planned_order
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-order_header-planned_order_user
      exp = 'PLANNER' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-order_header-last_change_timestamp
      exp = CONV plaf-pstmp( '20261110120000' ) ).
  ENDMETHOD.

  METHOD filters_blank_user.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order = '0000000001'
        material      = 'MAT-1'
        plant         = '3000'
        finish_date   = '20261110'
        quantity      = '1.000'
        order_unit    = 'EA'
        base_unit     = 'EA' )
      ( planned_order      = '0000000002'
        material           = 'MAT-1'
        plant              = '3000'
        planned_order_user = 'PLANNER'
        finish_date        = '20261110'
        quantity           = '1.000'
        order_unit         = 'EA'
        base_unit          = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material                  = 'MAT-1'
        plant                     = '3000'
        filter_planned_order_user = abap_true
        finish_date_from          = '20261101'
        finish_date_to            = '20261130'
        maximum_results           = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-planned_order
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 1 ]-order_header-planned_order_user ).
  ENDMETHOD.

  METHOD rejects_bad_user_filter.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                  = 'MAT-1'
            plant                     = '3000'
            filter_planned_order_user = 'Y'
            finish_date_from          = '20261101'
            finish_date_to            = '20261130'
            maximum_results           = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_blank_user_scope_drift.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( planned_order      = '0000000001'
        material           = 'MAT-1'
        plant              = '3000'
        planned_order_user = 'PLANNER'
        finish_date        = '20261110' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                  = 'MAT-1'
            plant                     = '3000'
            filter_planned_order_user = abap_true
            finish_date_from          = '20261101'
            finish_date_to            = '20261130'
            maximum_results           = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD rejects_user_scope_drift.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( planned_order      = '0000000001'
        material           = 'MAT-1'
        plant              = '3000'
        planned_order_user = 'MRPUSER'
        finish_date        = '20261110' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material           = 'MAT-1'
            plant              = '3000'
            planned_order_user = 'PLANNER'
            finish_date_from   = '20261101'
            finish_date_to     = '20261130'
            maximum_results    = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD filters_blank_planning_plant.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order = '0000000001'
        material      = 'MAT-1'
        plant         = '3000'
        finish_date   = '20261110'
        quantity      = '1.000'
        order_unit    = 'EA'
        base_unit     = 'EA' )
      ( planned_order  = '0000000002'
        material       = 'MAT-1'
        plant          = '3000'
        planning_plant = '2000'
        finish_date    = '20261110'
        quantity       = '1.000'
        order_unit     = 'EA'
        base_unit      = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material              = 'MAT-1'
        plant                 = '3000'
        filter_planning_plant = abap_true
        finish_date_from      = '20261101'
        finish_date_to        = '20261130'
        maximum_results       = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-planned_order
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 1 ]-order_header-planning_plant ).
  ENDMETHOD.

  METHOD rejects_bad_plan_plant_filter.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material              = 'MAT-1'
            plant                 = '3000'
            filter_planning_plant = 'Y'
            finish_date_from      = '20261101'
            finish_date_to        = '20261130'
            maximum_results       = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_blank_plan_plant_drift.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( planned_order  = '0000000001'
        material       = 'MAT-1'
        plant          = '3000'
        planning_plant = '2000'
        finish_date    = '20261110' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material              = 'MAT-1'
            plant                 = '3000'
            filter_planning_plant = abap_true
            finish_date_from      = '20261101'
            finish_date_to        = '20261130'
            maximum_results       = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD filters_planning_plant.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order  = '0000000001'
        material       = 'MAT-1'
        plant          = '3000'
        planning_plant = '1000'
        finish_date    = '20261110'
        quantity       = '1.000'
        order_unit     = 'EA'
        base_unit      = 'EA' )
      ( planned_order  = '0000000002'
        material       = 'MAT-1'
        plant          = '3000'
        planning_plant = '2000'
        finish_date    = '20261110'
        quantity       = '1.000'
        order_unit     = 'EA'
        base_unit      = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material         = 'MAT-1'
        plant            = '3000'
        planning_plant   = '2000'
        finish_date_from = '20261101'
        finish_date_to   = '20261130'
        maximum_results  = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-planned_order
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-order_header-planning_plant
      exp = '2000' ).
  ENDMETHOD.

  METHOD rejects_planning_plant_drift.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( planned_order  = '0000000001'
        material       = 'MAT-1'
        plant          = '3000'
        planning_plant = '1000'
        finish_date    = '20261110' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material         = 'MAT-1'
            plant            = '3000'
            planning_plant   = '2000'
            finish_date_from = '20261101'
            finish_date_to   = '20261130'
            maximum_results  = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD filters_planning_scenario.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order     = '0000000001'
        material          = 'MAT-1'
        plant             = '1000'
        planning_scenario = '001'
        finish_date       = '20261110'
        quantity          = '4.000'
        order_unit        = 'EA'
        base_unit         = 'EA' )
      ( planned_order     = '0000000002'
        material          = 'MAT-1'
        plant             = '1000'
        planning_scenario = '002'
        finish_date       = '20261110'
        quantity          = '5.000'
        order_unit        = 'EA'
        base_unit         = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        planning_scenario = '002'
        finish_date_from  = '20261101'
        finish_date_to    = '20261130'
        maximum_results   = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->requested_selection-planning_scenario
      exp = '002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-planned_order
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-order_header-planning_scenario
      exp = '002' ).
  ENDMETHOD.

  METHOD rejects_scenario_scope_loss.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( planned_order     = '0000000001'
        material          = 'MAT-1'
        plant             = '1000'
        planning_scenario = '001'
        finish_date       = '20261110' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material          = 'MAT-1'
            plant             = '1000'
            planning_scenario = '002'
            finish_date_from  = '20261101'
            finish_date_to    = '20261130'
            maximum_results   = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD filters_blank_scenario.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order     = '0000000001'
        material          = 'MAT-1'
        plant             = '1000'
        planning_scenario = '001'
        finish_date       = '20261110'
        quantity          = '4.000'
        order_unit        = 'EA'
        base_unit         = 'EA' )
      ( planned_order     = '0000000002'
        material          = 'MAT-1'
        plant             = '1000'
        planning_scenario = space
        finish_date       = '20261110'
        quantity          = '5.000'
        order_unit        = 'EA'
        base_unit         = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material                 = 'MAT-1'
        plant                    = '1000'
        filter_planning_scenario = abap_true
        planning_scenario        = space
        finish_date_from         = '20261101'
        finish_date_to           = '20261130'
        maximum_results          = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-planned_order
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 1 ]-order_header-planning_scenario ).
  ENDMETHOD.

  METHOD rejects_bad_scenario_filter.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                 = 'MAT-1'
            plant                    = '1000'
            filter_planning_scenario = 'Y'
            finish_date_from         = '20261101'
            finish_date_to           = '20261130'
            maximum_results          = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_blank_scenario_drift.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( planned_order     = '0000000001'
        material          = 'MAT-1'
        plant             = '1000'
        planning_scenario = '001'
        finish_date       = '20261110' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                 = 'MAT-1'
            plant                    = '1000'
            filter_planning_scenario = abap_true
            finish_date_from         = '20261101'
            finish_date_to           = '20261130'
            maximum_results          = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD filters_blank_order_type.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order = '0000000001'
        material      = 'MAT-1'
        plant         = '3000'
        finish_date   = '20261110'
        quantity      = '1.000'
        order_unit    = 'EA'
        base_unit     = 'EA' )
      ( planned_order = '0000000002'
        material      = 'MAT-1'
        plant         = '3000'
        order_type    = 'NB'
        finish_date   = '20261110'
        quantity      = '1.000'
        order_unit    = 'EA'
        base_unit     = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material          = 'MAT-1'
        plant             = '3000'
        filter_order_type = abap_true
        finish_date_from  = '20261101'
        finish_date_to    = '20261130'
        maximum_results   = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-planned_order
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 1 ]-order_header-order_type ).
  ENDMETHOD.

  METHOD rejects_bad_order_type_filter.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material          = 'MAT-1'
            plant             = '3000'
            filter_order_type = 'Y'
            finish_date_from  = '20261101'
            finish_date_to    = '20261130'
            maximum_results   = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_blank_order_type_drift.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( planned_order = '0000000001'
        material      = 'MAT-1'
        plant         = '3000'
        order_type    = 'NB'
        finish_date   = '20261110' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material          = 'MAT-1'
            plant             = '3000'
            filter_order_type = abap_true
            finish_date_from  = '20261101'
            finish_date_to    = '20261130'
            maximum_results   = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD filters_order_type_window.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order = '0000000001'
        material      = 'MAT-1'
        plant         = '1000'
        order_type    = 'LA'
        finish_date   = '20261110'
        quantity      = '4.000'
        order_unit    = 'EA'
        base_unit     = 'EA' )
      ( planned_order = '0000000002'
        material      = 'MAT-1'
        plant         = '1000'
        order_type    = 'NB'
        finish_date   = '20261110'
        quantity      = '5.000'
        order_unit    = 'EA'
        base_unit     = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material         = 'MAT-1'
        plant            = '1000'
        order_type       = 'NB'
        finish_date_from = '20261101'
        finish_date_to   = '20261130'
        maximum_results  = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->requested_selection-order_type
      exp = 'NB' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-planned_order
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-order_header-order_type
      exp = 'NB' ).
  ENDMETHOD.

  METHOD rejects_order_type_scope_drift.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( planned_order = '0000000001'
        material      = 'MAT-1'
        plant         = '1000'
        order_type    = 'LA'
        finish_date   = '20261110' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material         = 'MAT-1'
            plant            = '1000'
            order_type       = 'NB'
            finish_date_from = '20261101'
            finish_date_to   = '20261130'
            maximum_results  = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD filters_storage_location.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order    = '0000000001'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        finish_date      = '20261110'
        quantity         = '4.000'
        order_unit       = 'EA'
        base_unit        = 'EA' )
      ( planned_order    = '0000000002'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = space
        finish_date      = '20261110'
        quantity         = '5.000'
        order_unit       = 'EA'
        base_unit        = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_unassigned_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material                = 'MAT-1'
        plant                   = '1000'
        filter_storage_location = abap_true
        storage_location        = space
        finish_date_from        = '20261101'
        finish_date_to          = '20261130'
        maximum_results         = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_unassigned_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_unassigned_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_unassigned_result-orders[ 1 ]-planned_order
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_initial(
      ls_unassigned_result-orders[ 1 ]-order_header-storage_location ).

    DATA(ls_assigned_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material                = 'MAT-1'
        plant                   = '1000'
        filter_storage_location = abap_true
        storage_location        = '0001'
        finish_date_from        = '20261101'
        finish_date_to          = '20261130'
        maximum_results         = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_assigned_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_assigned_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_assigned_result-orders[ 1 ]-planned_order
      exp = '0000000001' ).
  ENDMETHOD.

  METHOD rejects_bad_storage_filter.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                = 'MAT-1'
            plant                   = '1000'
            filter_storage_location = 'Y'
            finish_date_from        = '20261101'
            finish_date_to          = '20261130'
            maximum_results         = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material         = 'MAT-1'
            plant            = '1000'
            storage_location = '0001'
            finish_date_from = '20261101'
            finish_date_to   = '20261130'
            maximum_results  = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_storage_scope_drift.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( planned_order    = '0000000001'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        finish_date      = '20261110' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                = 'MAT-1'
            plant                   = '1000'
            filter_storage_location = abap_true
            storage_location        = space
            finish_date_from        = '20261101'
            finish_date_to          = '20261130'
            maximum_results         = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD filters_procurement_indicator.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order         = '0000000001'
        material              = 'MAT-1'
        plant                 = '1000'
        procurement_indicator = 'E'
        finish_date           = '20261110'
        quantity              = '4.000'
        order_unit            = 'EA'
        base_unit             = 'EA' )
      ( planned_order         = '0000000002'
        material              = 'MAT-1'
        plant                 = '1000'
        procurement_indicator = 'F'
        finish_date           = '20261110'
        quantity              = '5.000'
        order_unit            = 'EA'
        base_unit             = 'EA' )
      ( planned_order         = '0000000003'
        material              = 'MAT-1'
        plant                 = '1000'
        procurement_indicator = space
        finish_date           = '20261110'
        quantity              = '6.000'
        order_unit            = 'EA'
        base_unit             = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_external_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material                     = 'MAT-1'
        plant                        = '1000'
        filter_procurement_indicator = abap_true
        procurement_indicator        = 'F'
        finish_date_from             = '20261101'
        finish_date_to               = '20261130'
        maximum_results              = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_external_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_external_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_external_result-orders[ 1 ]-planned_order
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_external_result-orders[ 1 ]-order_header-procurement_indicator
      exp = 'F' ).

    DATA(ls_blank_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material                     = 'MAT-1'
        plant                        = '1000'
        filter_procurement_indicator = abap_true
        procurement_indicator        = space
        finish_date_from             = '20261101'
        finish_date_to               = '20261130'
        maximum_results              = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_blank_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_blank_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_blank_result-orders[ 1 ]-planned_order
      exp = '0000000003' ).
  ENDMETHOD.

  METHOD rejects_bad_procurement_filter.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                     = 'MAT-1'
            plant                        = '1000'
            filter_procurement_indicator = 'Y'
            finish_date_from             = '20261101'
            finish_date_to               = '20261130'
            maximum_results              = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material              = 'MAT-1'
            plant                 = '1000'
            procurement_indicator = 'E'
            finish_date_from      = '20261101'
            finish_date_to        = '20261130'
            maximum_results       = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_procurement_scope.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( planned_order         = '0000000001'
        material              = 'MAT-1'
        plant                 = '1000'
        procurement_indicator = 'F'
        finish_date           = '20261110' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                     = 'MAT-1'
            plant                        = '1000'
            filter_procurement_indicator = abap_true
            procurement_indicator        = 'E'
            finish_date_from             = '20261101'
            finish_date_to               = '20261130'
            maximum_results              = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD filters_positive_quantity.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order = '0000000001'
        material      = 'MAT-1'
        plant         = '1000'
        finish_date   = '20261110'
        quantity      = '0.000'
        order_unit    = 'EA'
        base_unit     = 'EA' )
      ( planned_order = '0000000002'
        material      = 'MAT-1'
        plant         = '1000'
        finish_date   = '20261110'
        quantity      = '5.000'
        order_unit    = 'EA'
        base_unit     = 'EA' )
      ( planned_order = '0000000003'
        material      = 'MAT-1'
        plant         = '1000'
        finish_date   = '20261110'
        quantity      = '-1.000'
        order_unit    = 'EA'
        base_unit     = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material               = 'MAT-1'
        plant                  = '1000'
        positive_quantity_only = abap_true
        finish_date_from       = '20261101'
        finish_date_to         = '20261130'
        maximum_results        = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->requested_selection-positive_quantity_only
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-planned_order
      exp = '0000000002' ).
  ENDMETHOD.

  METHOD rejects_bad_quantity_flag.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material               = 'MAT-1'
            plant                  = '1000'
            positive_quantity_only = 'Y'
            finish_date_from       = '20261101'
            finish_date_to         = '20261130'
            maximum_results        = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_quantity_scope_drift.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( planned_order = '0000000001'
        material      = 'MAT-1'
        plant         = '1000'
        finish_date   = '20261110'
        quantity      = '0.000' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material               = 'MAT-1'
            plant                  = '1000'
            positive_quantity_only = abap_true
            finish_date_from       = '20261101'
            finish_date_to         = '20261130'
            maximum_results        = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD filters_mrp_controller.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order  = '0000000001'
        material       = 'MAT-1'
        plant          = '1000'
        mrp_controller = '001'
        finish_date    = '20261110'
        quantity       = '4.000'
        order_unit     = 'EA'
        base_unit      = 'EA' )
      ( planned_order  = '0000000002'
        material       = 'MAT-1'
        plant          = '1000'
        mrp_controller = '002'
        finish_date    = '20261110'
        quantity       = '5.000'
        order_unit     = 'EA'
        base_unit      = 'EA' )
      ( planned_order  = '0000000003'
        material       = 'MAT-1'
        plant          = '1000'
        mrp_controller = space
        finish_date    = '20261110'
        quantity       = '6.000'
        order_unit     = 'EA'
        base_unit      = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material              = 'MAT-1'
        plant                 = '1000'
        filter_mrp_controller = abap_true
        mrp_controller        = '002'
        finish_date_from      = '20261101'
        finish_date_to        = '20261130'
        maximum_results       = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-planned_order
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-order_header-mrp_controller
      exp = '002' ).

    DATA(ls_blank_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material              = 'MAT-1'
        plant                 = '1000'
        filter_mrp_controller = abap_true
        mrp_controller        = space
        finish_date_from      = '20261101'
        finish_date_to        = '20261130'
        maximum_results       = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_blank_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_blank_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_blank_result-orders[ 1 ]-planned_order
      exp = '0000000003' ).
  ENDMETHOD.

  METHOD rejects_bad_mrp_filter.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material              = 'MAT-1'
            plant                 = '1000'
            filter_mrp_controller = 'Y'
            finish_date_from      = '20261101'
            finish_date_to        = '20261130'
            maximum_results       = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material         = 'MAT-1'
            plant            = '1000'
            mrp_controller   = '002'
            finish_date_from = '20261101'
            finish_date_to   = '20261130'
            maximum_results  = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_mrp_scope.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( planned_order  = '0000000001'
        material       = 'MAT-1'
        plant          = '1000'
        mrp_controller = '001'
        finish_date    = '20261110' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material              = 'MAT-1'
            plant                 = '1000'
            filter_mrp_controller = abap_true
            mrp_controller        = '002'
            finish_date_from      = '20261101'
            finish_date_to        = '20261130'
            maximum_results       = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD filters_production_supervisor.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order         = '0000000001'
        material              = 'MAT-1'
        plant                 = '1000'
        production_supervisor = '001'
        finish_date           = '20261110'
        quantity              = '4.000'
        order_unit            = 'EA'
        base_unit             = 'EA' )
      ( planned_order         = '0000000002'
        material              = 'MAT-1'
        plant                 = '1000'
        production_supervisor = '002'
        finish_date           = '20261110'
        quantity              = '5.000'
        order_unit            = 'EA'
        base_unit             = 'EA' )
      ( planned_order         = '0000000003'
        material              = 'MAT-1'
        plant                 = '1000'
        production_supervisor = space
        finish_date           = '20261110'
        quantity              = '6.000'
        order_unit            = 'EA'
        base_unit             = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material                     = 'MAT-1'
        plant                        = '1000'
        filter_production_supervisor = abap_true
        production_supervisor        = '002'
        finish_date_from             = '20261101'
        finish_date_to               = '20261130'
        maximum_results              = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-planned_order
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-order_header-production_supervisor
      exp = '002' ).

    DATA(ls_blank_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material                     = 'MAT-1'
        plant                        = '1000'
        filter_production_supervisor = abap_true
        production_supervisor        = space
        finish_date_from             = '20261101'
        finish_date_to               = '20261130'
        maximum_results              = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_blank_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_blank_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_blank_result-orders[ 1 ]-planned_order
      exp = '0000000003' ).
  ENDMETHOD.

  METHOD rejects_bad_supervisor_filter.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                     = 'MAT-1'
            plant                        = '1000'
            filter_production_supervisor = 'Y'
            finish_date_from             = '20261101'
            finish_date_to               = '20261130'
            maximum_results              = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material              = 'MAT-1'
            plant                 = '1000'
            production_supervisor = '002'
            finish_date_from      = '20261101'
            finish_date_to        = '20261130'
            maximum_results       = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_supervisor_scope.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( planned_order         = '0000000001'
        material              = 'MAT-1'
        plant                 = '1000'
        production_supervisor = '001'
        finish_date           = '20261110' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                     = 'MAT-1'
            plant                        = '1000'
            filter_production_supervisor = abap_true
            production_supervisor        = '002'
            finish_date_from             = '20261101'
            finish_date_to               = '20261130'
            maximum_results              = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD filters_production_version.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order      = '0000000001'
        material           = 'MAT-1'
        plant              = '1000'
        production_version = '0001'
        finish_date        = '20261110'
        quantity           = '4.000'
        order_unit         = 'EA'
        base_unit          = 'EA' )
      ( planned_order      = '0000000002'
        material           = 'MAT-1'
        plant              = '1000'
        production_version = '0002'
        finish_date        = '20261110'
        quantity           = '5.000'
        order_unit         = 'EA'
        base_unit          = 'EA' )
      ( planned_order      = '0000000003'
        material           = 'MAT-1'
        plant              = '1000'
        production_version = space
        finish_date        = '20261110'
        quantity           = '6.000'
        order_unit         = 'EA'
        base_unit          = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material                  = 'MAT-1'
        plant                     = '1000'
        filter_production_version = abap_true
        production_version        = '0002'
        finish_date_from          = '20261101'
        finish_date_to            = '20261130'
        maximum_results           = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-planned_order
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-order_header-production_version
      exp = '0002' ).

    DATA(ls_blank_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material                  = 'MAT-1'
        plant                     = '1000'
        filter_production_version = abap_true
        production_version        = space
        finish_date_from          = '20261101'
        finish_date_to            = '20261130'
        maximum_results           = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_blank_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_blank_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_blank_result-orders[ 1 ]-planned_order
      exp = '0000000003' ).
  ENDMETHOD.

  METHOD rejects_bad_version_filter.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                  = 'MAT-1'
            plant                     = '1000'
            filter_production_version = 'Y'
            finish_date_from          = '20261101'
            finish_date_to            = '20261130'
            maximum_results           = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material           = 'MAT-1'
            plant              = '1000'
            production_version = '0002'
            finish_date_from   = '20261101'
            finish_date_to     = '20261130'
            maximum_results    = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_version_scope.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( planned_order      = '0000000001'
        material           = 'MAT-1'
        plant              = '1000'
        production_version = '0001'
        finish_date        = '20261110' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                  = 'MAT-1'
            plant                     = '1000'
            filter_production_version = abap_true
            production_version        = '0002'
            finish_date_from          = '20261101'
            finish_date_to            = '20261130'
            maximum_results           = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD filters_mrp_area.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order = '0000000001'
        material      = 'MAT-1'
        plant         = '1000'
        mrp_area      = 'AREA-0001'
        finish_date   = '20261110'
        quantity      = '4.000'
        order_unit    = 'EA'
        base_unit     = 'EA' )
      ( planned_order = '0000000002'
        material      = 'MAT-1'
        plant         = '1000'
        mrp_area      = 'AREA-0002'
        finish_date   = '20261110'
        quantity      = '5.000'
        order_unit    = 'EA'
        base_unit     = 'EA' )
      ( planned_order = '0000000003'
        material      = 'MAT-1'
        plant         = '1000'
        mrp_area      = space
        finish_date   = '20261110'
        quantity      = '6.000'
        order_unit    = 'EA'
        base_unit     = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material         = 'MAT-1'
        plant            = '1000'
        filter_mrp_area  = abap_true
        mrp_area         = 'AREA-0002'
        finish_date_from = '20261101'
        finish_date_to   = '20261130'
        maximum_results  = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-planned_order
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-order_header-mrp_area
      exp = 'AREA-0002' ).

    DATA(ls_blank_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material         = 'MAT-1'
        plant            = '1000'
        filter_mrp_area  = abap_true
        mrp_area         = space
        finish_date_from = '20261101'
        finish_date_to   = '20261130'
        maximum_results  = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_blank_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_blank_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_blank_result-orders[ 1 ]-planned_order
      exp = '0000000003' ).
  ENDMETHOD.

  METHOD rejects_bad_mrp_area_filter.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material         = 'MAT-1'
            plant            = '1000'
            filter_mrp_area  = 'Y'
            finish_date_from = '20261101'
            finish_date_to   = '20261130'
            maximum_results  = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material         = 'MAT-1'
            plant            = '1000'
            mrp_area         = 'AREA-0002'
            finish_date_from = '20261101'
            finish_date_to   = '20261130'
            maximum_results  = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_mrp_area_scope.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( planned_order = '0000000001'
        material      = 'MAT-1'
        plant         = '1000'
        mrp_area      = 'AREA-0001'
        finish_date   = '20261110' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material         = 'MAT-1'
            plant            = '1000'
            filter_mrp_area  = abap_true
            mrp_area         = 'AREA-0002'
            finish_date_from = '20261101'
            finish_date_to   = '20261130'
            maximum_results  = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD filters_account_category.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order               = '0000000001'
        material                    = 'MAT-1'
        plant                       = '1000'
        account_assignment_category = 'K'
        finish_date                 = '20261110'
        quantity                    = '4.000'
        order_unit                  = 'EA'
        base_unit                   = 'EA' )
      ( planned_order               = '0000000002'
        material                    = 'MAT-1'
        plant                       = '1000'
        account_assignment_category = 'P'
        finish_date                 = '20261110'
        quantity                    = '5.000'
        order_unit                  = 'EA'
        base_unit                   = 'EA' )
      ( planned_order               = '0000000003'
        material                    = 'MAT-1'
        plant                       = '1000'
        account_assignment_category = space
        finish_date                 = '20261110'
        quantity                    = '6.000'
        order_unit                  = 'EA'
        base_unit                   = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material                    = 'MAT-1'
        plant                       = '1000'
        filter_account_category     = abap_true
        account_assignment_category = 'K'
        finish_date_from            = '20261101'
        finish_date_to              = '20261130'
        maximum_results             = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-planned_order
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-order_header-account_assignment_category
      exp = 'K' ).

    DATA(ls_blank_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material                    = 'MAT-1'
        plant                       = '1000'
        filter_account_category     = abap_true
        account_assignment_category = space
        finish_date_from            = '20261101'
        finish_date_to              = '20261130'
        maximum_results             = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_blank_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_blank_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_blank_result-orders[ 1 ]-planned_order
      exp = '0000000003' ).
  ENDMETHOD.

  METHOD rejects_bad_account_flag.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                = 'MAT-1'
            plant                   = '1000'
            filter_account_category = 'Y'
            finish_date_from        = '20261101'
            finish_date_to          = '20261130'
            maximum_results         = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                    = 'MAT-1'
            plant                       = '1000'
            account_assignment_category = 'K'
            finish_date_from            = '20261101'
            finish_date_to              = '20261130'
            maximum_results             = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_account_scope.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( planned_order               = '0000000001'
        material                    = 'MAT-1'
        plant                       = '1000'
        account_assignment_category = 'P'
        finish_date                 = '20261110' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                    = 'MAT-1'
            plant                       = '1000'
            filter_account_category     = abap_true
            account_assignment_category = 'K'
            finish_date_from            = '20261101'
            finish_date_to              = '20261130'
            maximum_results             = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD filters_creation_date_window.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order = '0000000001'
        material      = 'MAT-1'
        plant         = '1000'
        creation_date = '20261015'
        finish_date   = '20261110'
        quantity      = '1.000'
        order_unit    = 'EA'
        base_unit     = 'EA' )
      ( planned_order = '0000000002'
        material      = 'MAT-1'
        plant         = '1000'
        creation_date = '20261105'
        finish_date   = '20261110'
        quantity      = '1.000'
        order_unit    = 'EA'
        base_unit     = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material           = 'MAT-1'
        plant              = '1000'
        creation_date_from = '20261001'
        creation_date_to   = '20261031'
        finish_date_from   = '20261101'
        finish_date_to     = '20261130'
        maximum_results    = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-planned_order
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-order_header-creation_date
      exp = '20261015' ).
  ENDMETHOD.

  METHOD rejects_partial_creation_dates.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material           = 'MAT-1'
            plant              = '1000'
            creation_date_from = '20261001'
            finish_date_from   = '20261101'
            finish_date_to     = '20261130'
            maximum_results    = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material           = 'MAT-1'
            plant              = '1000'
            creation_date_from = '20260230'
            creation_date_to   = '20260331'
            finish_date_from   = '20261101'
            finish_date_to     = '20261130'
            maximum_results    = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material           = 'MAT-1'
            plant              = '1000'
            creation_date_from = '20261101'
            creation_date_to   = '20261031'
            finish_date_from   = '20261101'
            finish_date_to     = '20261130'
            maximum_results    = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_creation_date_drift.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( planned_order = '0000000001'
        material      = 'MAT-1'
        plant         = '1000'
        creation_date = '20261105'
        finish_date   = '20261110' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material           = 'MAT-1'
            plant              = '1000'
            creation_date_from = '20261001'
            creation_date_to   = '20261031'
            finish_date_from   = '20261101'
            finish_date_to     = '20261130'
            maximum_results    = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD filters_start_date_window.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order = '0000000001'
        material      = 'MAT-1'
        plant         = '1000'
        start_date    = '20261105'
        finish_date   = '20261125'
        quantity      = '4.000'
        order_unit    = 'EA'
        base_unit     = 'EA' )
      ( planned_order = '0000000002'
        material      = 'MAT-1'
        plant         = '1000'
        start_date    = '20261115'
        finish_date   = '20261125'
        quantity      = '5.000'
        order_unit    = 'EA'
        base_unit     = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material         = 'MAT-1'
        plant            = '1000'
        start_date_from  = '20261110'
        start_date_to    = '20261120'
        finish_date_from = '20261101'
        finish_date_to   = '20261130'
        maximum_results  = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-planned_order
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-order_header-start_date
      exp = '20261115' ).
  ENDMETHOD.

  METHOD rejects_partial_start_dates.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material         = 'MAT-1'
            plant            = '1000'
            start_date_from  = '20261110'
            finish_date_from = '20261101'
            finish_date_to   = '20261130'
            maximum_results  = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_start_date_scope_loss.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( planned_order = '0000000001'
        material      = 'MAT-1'
        plant         = '1000'
        start_date    = '20261105'
        finish_date   = '20261125' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material         = 'MAT-1'
            plant            = '1000'
            start_date_from  = '20261110'
            start_date_to    = '20261120'
            finish_date_from = '20261101'
            finish_date_to   = '20261130'
            maximum_results  = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD filters_sched_finish_window.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order         = '0000000001'
        material              = 'MAT-1'
        plant                 = '1000'
        scheduled_finish_date = '20261115'
        finish_date           = '20261125'
        quantity              = '1.000'
        order_unit            = 'EA'
        base_unit             = 'EA' )
      ( planned_order         = '0000000002'
        material              = 'MAT-1'
        plant                 = '1000'
        scheduled_finish_date = '20261125'
        finish_date           = '20261125'
        quantity              = '1.000'
        order_unit            = 'EA'
        base_unit             = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material                   = 'MAT-1'
        plant                      = '1000'
        scheduled_finish_date_from = '20261110'
        scheduled_finish_date_to   = '20261120'
        finish_date_from           = '20261101'
        finish_date_to             = '20261130'
        maximum_results            = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-planned_order
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-order_header-scheduled_finish_date
      exp = '20261115' ).
  ENDMETHOD.

  METHOD rejects_partial_sched_finish.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                   = 'MAT-1'
            plant                      = '1000'
            scheduled_finish_date_from = '20261110'
            finish_date_from           = '20261101'
            finish_date_to             = '20261130'
            maximum_results            = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_invalid_sched_finish.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                   = 'MAT-1'
            plant                      = '1000'
            scheduled_finish_date_from = '20261131'
            scheduled_finish_date_to   = '20261205'
            finish_date_from           = '20261101'
            finish_date_to             = '20261130'
            maximum_results            = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                   = 'MAT-1'
            plant                      = '1000'
            scheduled_finish_date_from = '20261120'
            scheduled_finish_date_to   = '20261110'
            finish_date_from           = '20261101'
            finish_date_to             = '20261130'
            maximum_results            = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_sched_finish_scope.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( planned_order         = '0000000001'
        material              = 'MAT-1'
        plant                 = '1000'
        scheduled_finish_date = '20261125'
        finish_date           = '20261125' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                   = 'MAT-1'
            plant                      = '1000'
            scheduled_finish_date_from = '20261110'
            scheduled_finish_date_to   = '20261120'
            finish_date_from           = '20261101'
            finish_date_to             = '20261130'
            maximum_results            = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD filters_sched_start_window.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order        = '0000000001'
        material             = 'MAT-1'
        plant                = '1000'
        scheduled_start_date = '20261105'
        finish_date          = '20261125'
        quantity             = '1.000'
        order_unit           = 'EA'
        base_unit            = 'EA' )
      ( planned_order        = '0000000002'
        material             = 'MAT-1'
        plant                = '1000'
        scheduled_start_date = '20261115'
        finish_date          = '20261125'
        quantity             = '1.000'
        order_unit           = 'EA'
        base_unit            = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material                  = 'MAT-1'
        plant                     = '1000'
        scheduled_start_date_from = '20261110'
        scheduled_start_date_to   = '20261120'
        finish_date_from          = '20261101'
        finish_date_to            = '20261130'
        maximum_results           = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-planned_order
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-order_header-scheduled_start_date
      exp = '20261115' ).
  ENDMETHOD.

  METHOD rejects_partial_sched_start.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                  = 'MAT-1'
            plant                     = '1000'
            scheduled_start_date_from = '20261110'
            finish_date_from          = '20261101'
            finish_date_to            = '20261130'
            maximum_results           = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_invalid_sched_start.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                  = 'MAT-1'
            plant                     = '1000'
            scheduled_start_date_from = '20261131'
            scheduled_start_date_to   = '20261205'
            finish_date_from          = '20261101'
            finish_date_to            = '20261130'
            maximum_results           = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                  = 'MAT-1'
            plant                     = '1000'
            scheduled_start_date_from = '20261120'
            scheduled_start_date_to   = '20261110'
            finish_date_from          = '20261101'
            finish_date_to            = '20261130'
            maximum_results           = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_sched_start_scope.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( planned_order        = '0000000001'
        material             = 'MAT-1'
        plant                = '1000'
        scheduled_start_date = '20261105'
        finish_date          = '20261125' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                  = 'MAT-1'
            plant                     = '1000'
            scheduled_start_date_from = '20261110'
            scheduled_start_date_to   = '20261120'
            finish_date_from          = '20261101'
            finish_date_to            = '20261130'
            maximum_results           = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD filters_sched_time_windows.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order         = '0000000001'
        material              = 'MAT-1'
        plant                 = '1000'
        scheduled_start_time  = '081500'
        scheduled_finish_time = '151000'
        finish_date           = '20261125'
        quantity              = '1.000'
        order_unit            = 'EA'
        base_unit             = 'EA' )
      ( planned_order         = '0000000002'
        material              = 'MAT-1'
        plant                 = '1000'
        scheduled_start_time  = '070000'
        scheduled_finish_time = '151000'
        finish_date           = '20261125'
        quantity              = '1.000'
        order_unit            = 'EA'
        base_unit             = 'EA' )
      ( planned_order         = '0000000003'
        material              = 'MAT-1'
        plant                 = '1000'
        scheduled_start_time  = '081500'
        scheduled_finish_time = '163000'
        finish_date           = '20261125'
        quantity              = '1.000'
        order_unit            = 'EA'
        base_unit             = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material                     = 'MAT-1'
        plant                        = '1000'
        filter_scheduled_start_time  = abap_true
        scheduled_start_time_from    = '080000'
        scheduled_start_time_to      = '120000'
        filter_scheduled_finish_time = abap_true
        scheduled_finish_time_from   = '140000'
        scheduled_finish_time_to     = '160000'
        finish_date_from             = '20261101'
        finish_date_to               = '20261130'
        maximum_results              = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-planned_order
      exp = '0000000001' ).
  ENDMETHOD.

  METHOD rejects_bad_sched_time_window.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                    = 'MAT-1'
            plant                       = '1000'
            filter_scheduled_start_time = abap_true
            scheduled_start_time_from   = '240000'
            scheduled_start_time_to     = '250000'
            finish_date_from            = '20261101'
            finish_date_to              = '20261130'
            maximum_results             = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                     = 'MAT-1'
            plant                        = '1000'
            filter_scheduled_finish_time = abap_true
            scheduled_finish_time_from   = '200000'
            scheduled_finish_time_to     = '080000'
            finish_date_from             = '20261101'
            finish_date_to               = '20261130'
            maximum_results              = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                    = 'MAT-1'
            plant                       = '1000'
            filter_scheduled_start_time = 'Y'
            scheduled_start_time_from   = '080000'
            scheduled_start_time_to     = '100000'
            finish_date_from            = '20261101'
            finish_date_to              = '20261130'
            maximum_results             = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                     = 'MAT-1'
            plant                        = '1000'
            filter_scheduled_finish_time = abap_false
            scheduled_finish_time_from   = '080000'
            finish_date_from             = '20261101'
            finish_date_to               = '20261130'
            maximum_results              = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_sched_time_scope.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( planned_order         = '0000000001'
        material              = 'MAT-1'
        plant                 = '1000'
        scheduled_start_time  = '070000'
        scheduled_finish_time = '150000'
        finish_date           = '20261125' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA ls_selection TYPE zif_planned_order_read_repo=>ty_order_selection.
    DATA lv_raised TYPE abap_bool.

    ls_selection = VALUE #(
      material                     = 'MAT-1'
      plant                        = '1000'
      filter_scheduled_start_time  = abap_true
      scheduled_start_time_from    = '080000'
      scheduled_start_time_to      = '100000'
      filter_scheduled_finish_time = abap_true
      scheduled_finish_time_from   = '140000'
      scheduled_finish_time_to     = '160000'
      finish_date_from             = '20261101'
      finish_date_to               = '20261130'
      maximum_results              = 10 ).

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = ls_selection ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 1 ).

    lo_repository->finish_window_override[ 1 ]-scheduled_start_time =
      '09AB00'.
    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = ls_selection ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 2 ).

    lo_repository->finish_window_override[ 1 ]-scheduled_start_time =
      '090000'.
    lo_repository->finish_window_override[ 1 ]-scheduled_finish_time =
      '170000'.
    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = ls_selection ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 3 ).

    lo_repository->finish_window_override[ 1 ]-scheduled_finish_time =
      '15AB00'.
    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = ls_selection ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 4 ).
  ENDMETHOD.

  METHOD filters_special_stock_window.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order           = '0000000001'
        material                = 'MAT-1'
        plant                   = '1000'
        special_stock_indicator = 'E'
        finish_date             = '20261110'
        quantity                = '4.000'
        order_unit              = 'EA'
        base_unit               = 'EA' )
      ( planned_order = '0000000002'
        material      = 'MAT-1'
        plant         = '1000'
        finish_date   = '20261110'
        quantity      = '5.000'
        order_unit    = 'EA'
        base_unit     = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material                = 'MAT-1'
        plant                   = '1000'
        filter_special_stock    = abap_true
        special_stock_indicator = space
        finish_date_from        = '20261101'
        finish_date_to          = '20261130'
        maximum_results         = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->requested_selection-filter_special_stock
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-planned_order
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 1 ]-order_header-special_stock_indicator ).
  ENDMETHOD.

  METHOD rejects_bad_stock_filter.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material             = 'MAT-1'
            plant                = '1000'
            filter_special_stock = 'Y'
            finish_date_from     = '20261101'
            finish_date_to       = '20261130'
            maximum_results      = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                = 'MAT-1'
            plant                   = '1000'
            special_stock_indicator = 'E'
            finish_date_from        = '20261101'
            finish_date_to          = '20261130'
            maximum_results         = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_stock_scope_drift.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( planned_order           = '0000000001'
        material                = 'MAT-1'
        plant                   = '1000'
        special_stock_indicator = 'E'
        finish_date             = '20261110' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material                = 'MAT-1'
            plant                   = '1000'
            filter_special_stock    = abap_true
            special_stock_indicator = space
            finish_date_from        = '20261101'
            finish_date_to          = '20261130'
            maximum_results         = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD filters_fixed_indicator_window.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order   = '0000000001'
        material        = 'MAT-1'
        plant           = '1000'
        fixed_indicator = abap_true
        finish_date     = '20261110'
        quantity        = '4.000'
        order_unit      = 'EA'
        base_unit       = 'EA' )
      ( planned_order   = '0000000002'
        material        = 'MAT-1'
        plant           = '1000'
        fixed_indicator = abap_false
        finish_date     = '20261110'
        quantity        = '5.000'
        order_unit      = 'EA'
        base_unit       = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_unfixed_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material               = 'MAT-1'
        plant                  = '1000'
        filter_fixed_indicator = abap_true
        fixed_indicator        = abap_false
        finish_date_from       = '20261101'
        finish_date_to         = '20261130'
        maximum_results        = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_unfixed_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_unfixed_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_unfixed_result-orders[ 1 ]-planned_order
      exp = '0000000002' ).

    DATA(ls_fixed_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material               = 'MAT-1'
        plant                  = '1000'
        filter_fixed_indicator = abap_true
        fixed_indicator        = abap_true
        finish_date_from       = '20261101'
        finish_date_to         = '20261130'
        maximum_results        = 10 ) ).

    cl_abap_unit_assert=>assert_true( ls_fixed_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_fixed_result-found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_fixed_result-orders[ 1 ]-planned_order
      exp = '0000000001' ).
  ENDMETHOD.

  METHOD rejects_bad_fixed_filter.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material               = 'MAT-1'
            plant                  = '1000'
            filter_fixed_indicator = 'Y'
            finish_date_from       = '20261101'
            finish_date_to         = '20261130'
            maximum_results        = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material         = 'MAT-1'
            plant            = '1000'
            fixed_indicator  = abap_true
            finish_date_from = '20261101'
            finish_date_to   = '20261130'
            maximum_results  = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material               = 'MAT-1'
            plant                  = '1000'
            filter_fixed_indicator = abap_true
            fixed_indicator        = 'Y'
            finish_date_from       = '20261101'
            finish_date_to         = '20261130'
            maximum_results        = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_fixed_scope_drift.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->use_finish_window_override = abap_true.
    lo_repository->finish_window_override = VALUE #(
      ( planned_order   = '0000000001'
        material        = 'MAT-1'
        plant           = '1000'
        fixed_indicator = abap_true
        finish_date     = '20261110' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material               = 'MAT-1'
            plant                  = '1000'
            filter_fixed_indicator = abap_true
            fixed_indicator        = abap_false
            finish_date_from       = '20261101'
            finish_date_to         = '20261130'
            maximum_results        = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD exact_limit_not_truncated.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order = '0000000001'
        material      = 'MAT-1'
        plant         = '1000'
        finish_date   = '20261110'
        quantity      = '5.000'
        order_unit    = 'EA'
        base_unit     = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_by_finish_window(
      is_selection = VALUE #(
        material         = 'MAT-1'
        plant            = '1000'
        finish_date_from = '20261101'
        finish_date_to   = '20261130'
        maximum_results  = 1 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_false( ls_result-is_truncated ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 1 ).
  ENDMETHOD.

  METHOD rejects_bad_window_before_read.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
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
      act = lo_repository->selection_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material         = 'MAT-1'
            plant            = '1000'
            finish_date_from = '20260401'
            finish_date_to   = '20260331'
            maximum_results  = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material         = 'MAT-1'
            plant            = '1000'
            finish_date_from = '20260301'
            finish_date_to   = '20260401'
            maximum_results  = 501 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_by_finish_window(
          is_selection = VALUE #(
            material          = 'MAT-1'
            plant             = '1000'
            finish_date_from  = '20260301'
            finish_date_to    = '20260401'
            after_finish_date = '20260315'
            maximum_results   = 10 ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->selection_read_calls
      exp = 0 ).
  ENDMETHOD.
ENDCLASS.
