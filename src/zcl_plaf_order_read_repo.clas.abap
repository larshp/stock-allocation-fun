CLASS zcl_plaf_order_read_repo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_planned_order_read_repo.
  PRIVATE SECTION.
    METHODS enrich_order_units
      IMPORTING
        it_orders        TYPE zif_planned_order_read_repo=>ty_order_headers
      RETURNING
        VALUE(rt_orders) TYPE zif_planned_order_read_repo=>ty_order_headers.
ENDCLASS.

CLASS zcl_plaf_order_read_repo IMPLEMENTATION.

  METHOD zif_planned_order_read_repo~read_orders.
    DATA lt_orders TYPE zif_planned_order_read_repo=>ty_order_headers.

    IF it_planned_orders IS INITIAL.
      RETURN.
    ENDIF.

    SELECT plnum AS planned_order,
           matnr AS material,
           pwwrk AS plant,
           plwrk AS planning_plant,
           pertr AS creation_date,
           puser AS planned_order_user,
           pstmp AS last_change_timestamp,
           gstrs AS scheduled_start_date,
           gsuzs AS scheduled_start_time,
           gltrs AS scheduled_finish_date,
           gluzs AS scheduled_finish_time,
           psttr AS start_date,
           pedtr AS finish_date,
           gsmng AS quantity,
           meins AS order_unit,
           paart AS order_type,
           lgort AS storage_location,
           beskz AS procurement_indicator,
           dispo AS mrp_controller,
           plgrp AS production_supervisor,
           verid AS production_version,
           berid AS mrp_area,
           knttp AS account_assignment_category,
           auffx AS fixed_indicator,
           plscn AS planning_scenario,
           sobkz AS special_stock_indicator,
           kdauf AS sales_order,
           kdpos AS sales_order_item,
           kdein AS sales_order_schedule_line
      FROM plaf
      FOR ALL ENTRIES IN @it_planned_orders
      WHERE plnum = @it_planned_orders-table_line
      INTO CORRESPONDING FIELDS OF TABLE @lt_orders.

    IF lt_orders IS INITIAL.
      RETURN.
    ENDIF.

    rt_orders = enrich_order_units( it_orders = lt_orders ).
    SORT rt_orders BY planned_order.
  ENDMETHOD.

  METHOD zif_planned_order_read_repo~read_orders_by_finish_window.
    DATA lt_orders TYPE zif_planned_order_read_repo=>ty_order_headers.
    DATA lv_fetch_limit TYPE i.
    DATA lv_filter_sales_order TYPE abap_bool.
    DATA lv_sales_order TYPE plaf-kdauf.
    DATA lv_blank_sales_order TYPE plaf-kdauf.
    DATA lv_filter_planning_plant TYPE abap_bool.
    DATA lv_planning_plant TYPE plaf-plwrk.
    DATA lv_blank_planning_plant TYPE plaf-plwrk.
    DATA lv_creation_date_from TYPE plaf-pertr.
    DATA lv_creation_date_to TYPE plaf-pertr.
    DATA lv_blank_creation_date TYPE plaf-pertr.
    DATA lv_last_change_timestamp_from TYPE plaf-pstmp.
    DATA lv_last_change_timestamp_to TYPE plaf-pstmp.
    DATA lv_blank_last_change_timestamp TYPE plaf-pstmp.
    DATA lv_filter_planned_order_user TYPE abap_bool.
    DATA lv_planned_order_user TYPE plaf-puser.
    DATA lv_blank_planned_order_user TYPE plaf-puser.
    DATA lv_filter_sales_order_item TYPE abap_bool.
    DATA lv_sales_order_item TYPE plaf-kdpos.
    DATA lv_filter_sales_schedule_line TYPE abap_bool.
    DATA lv_sales_order_schedule_line TYPE plaf-kdein.
    DATA lv_filter_planning_scenario TYPE abap_bool.
    DATA lv_planning_scenario TYPE plaf-plscn.
    DATA lv_blank_planning_scenario TYPE plaf-plscn.
    DATA lv_filter_order_type TYPE abap_bool.
    DATA lv_order_type TYPE plaf-paart.
    DATA lv_blank_order_type TYPE plaf-paart.
    DATA lv_filter_storage_location TYPE abap_bool.
    DATA lv_storage_location TYPE plaf-lgort.
    DATA lv_filter_proc_indicator TYPE abap_bool.
    DATA lv_procurement_indicator TYPE plaf-beskz.
    DATA lv_filter_order_unit TYPE abap_bool.
    DATA lv_order_unit TYPE plaf-meins.
    DATA lv_blank_order_unit TYPE plaf-meins.
    DATA lv_positive_quantity_only TYPE abap_bool.
    DATA lv_filter_quantity_from TYPE abap_bool.
    DATA lv_quantity_from TYPE plaf-gsmng.
    DATA lv_filter_quantity_to TYPE abap_bool.
    DATA lv_quantity_to TYPE plaf-gsmng.
    DATA lv_filter_mrp_controller TYPE abap_bool.
    DATA lv_mrp_controller TYPE plaf-dispo.
    DATA lv_filter_prod_supervisor TYPE abap_bool.
    DATA lv_production_supervisor TYPE plaf-plgrp.
    DATA lv_filter_prod_version TYPE abap_bool.
    DATA lv_production_version TYPE plaf-verid.
    DATA lv_filter_mrp_area TYPE abap_bool.
    DATA lv_mrp_area TYPE plaf-berid.
    DATA lv_filter_account_category TYPE abap_bool.
    DATA lv_account_category TYPE plaf-knttp.
    DATA lv_filter_start_date TYPE abap_bool.
    DATA lv_exact_start_date TYPE plaf-psttr.
    DATA lv_start_date_from TYPE plaf-psttr.
    DATA lv_start_date_to TYPE plaf-psttr.
    DATA lv_blank_start_date TYPE plaf-psttr.
    DATA lv_filter_sched_start_date TYPE abap_bool.
    DATA lv_sched_start_date TYPE plaf-gstrs.
    DATA lv_scheduled_start_date_from TYPE plaf-gstrs.
    DATA lv_scheduled_start_date_to TYPE plaf-gstrs.
    DATA lv_blank_scheduled_start_date TYPE plaf-gstrs.
    DATA lv_filter_scheduled_start_time TYPE abap_bool.
    DATA lv_scheduled_start_time_from TYPE plaf-gsuzs.
    DATA lv_scheduled_start_time_to TYPE plaf-gsuzs.
    DATA lv_filter_sched_finish_date TYPE abap_bool.
    DATA lv_sched_finish_date TYPE plaf-gltrs.
    DATA lv_scheduled_finish_date_from TYPE plaf-gltrs.
    DATA lv_scheduled_finish_date_to TYPE plaf-gltrs.
    DATA lv_blank_scheduled_finish_date TYPE plaf-gltrs.
    DATA lv_filter_sched_finish_time TYPE abap_bool.
    DATA lv_scheduled_finish_time_from TYPE plaf-gluzs.
    DATA lv_scheduled_finish_time_to TYPE plaf-gluzs.
    DATA lv_filter_special_stock TYPE abap_bool.
    DATA lv_false TYPE abap_bool.
    DATA lv_special_stock_indicator TYPE plaf-sobkz.
    DATA lv_filter_fixed_indicator TYPE abap_bool.
    DATA lv_fixed_indicator TYPE plaf-auffx.

    IF is_selection-maximum_results < 1
        OR is_selection-maximum_results > 500.
      RETURN.
    ENDIF.

    lv_fetch_limit = is_selection-maximum_results + 1.
    lv_filter_sales_order = is_selection-filter_sales_order.
    lv_sales_order = is_selection-sales_order.
    lv_filter_planning_plant = is_selection-filter_planning_plant.
    lv_planning_plant = is_selection-planning_plant.
    lv_creation_date_from = is_selection-creation_date_from.
    lv_creation_date_to = is_selection-creation_date_to.
    lv_last_change_timestamp_from =
      is_selection-last_change_timestamp_from.
    lv_last_change_timestamp_to =
      is_selection-last_change_timestamp_to.
    lv_filter_planned_order_user =
      is_selection-filter_planned_order_user.
    lv_planned_order_user = is_selection-planned_order_user.
    lv_filter_sales_order_item = is_selection-filter_sales_order_item.
    lv_sales_order_item = is_selection-sales_order_item.
    lv_filter_sales_schedule_line =
      is_selection-filter_sales_schedule_line.
    lv_sales_order_schedule_line = is_selection-sales_order_schedule_line.
    lv_filter_planning_scenario = is_selection-filter_planning_scenario.
    lv_planning_scenario = is_selection-planning_scenario.
    lv_filter_order_type = is_selection-filter_order_type.
    lv_order_type = is_selection-order_type.
    lv_filter_storage_location = is_selection-filter_storage_location.
    lv_storage_location = is_selection-storage_location.
    lv_filter_proc_indicator =
      is_selection-filter_procurement_indicator.
    lv_procurement_indicator = is_selection-procurement_indicator.
    lv_filter_order_unit = is_selection-filter_order_unit.
    lv_order_unit = is_selection-order_unit.
    lv_positive_quantity_only = is_selection-positive_quantity_only.
    lv_filter_quantity_from = is_selection-filter_quantity_from.
    lv_quantity_from = is_selection-quantity_from.
    lv_filter_quantity_to = is_selection-filter_quantity_to.
    lv_quantity_to = is_selection-quantity_to.
    lv_filter_mrp_controller = is_selection-filter_mrp_controller.
    lv_mrp_controller = is_selection-mrp_controller.
    lv_filter_prod_supervisor =
      is_selection-filter_production_supervisor.
    lv_production_supervisor = is_selection-production_supervisor.
    lv_filter_prod_version = is_selection-filter_production_version.
    lv_production_version = is_selection-production_version.
    lv_filter_mrp_area = is_selection-filter_mrp_area.
    lv_mrp_area = is_selection-mrp_area.
    lv_filter_account_category = is_selection-filter_account_category.
    lv_account_category = is_selection-account_assignment_category.
    lv_filter_start_date = is_selection-filter_start_date.
    lv_exact_start_date = is_selection-start_date.
    lv_start_date_from = is_selection-start_date_from.
    lv_start_date_to = is_selection-start_date_to.
    lv_filter_sched_start_date =
      is_selection-filter_scheduled_start_date.
    lv_sched_start_date = is_selection-scheduled_start_date.
    lv_scheduled_start_date_from =
      is_selection-scheduled_start_date_from.
    lv_scheduled_start_date_to = is_selection-scheduled_start_date_to.
    lv_filter_scheduled_start_time =
      is_selection-filter_scheduled_start_time.
    lv_scheduled_start_time_from =
      is_selection-scheduled_start_time_from.
    lv_scheduled_start_time_to = is_selection-scheduled_start_time_to.
    lv_filter_sched_finish_date =
      is_selection-filter_scheduled_finish_date.
    lv_sched_finish_date = is_selection-scheduled_finish_date.
    lv_scheduled_finish_date_from =
      is_selection-scheduled_finish_date_from.
    lv_scheduled_finish_date_to = is_selection-scheduled_finish_date_to.
    lv_filter_sched_finish_time =
      is_selection-filter_scheduled_finish_time.
    lv_scheduled_finish_time_from =
      is_selection-scheduled_finish_time_from.
    lv_scheduled_finish_time_to = is_selection-scheduled_finish_time_to.
    lv_filter_special_stock = is_selection-filter_special_stock.
    lv_special_stock_indicator = is_selection-special_stock_indicator.
    lv_filter_fixed_indicator = is_selection-filter_fixed_indicator.
    lv_fixed_indicator = is_selection-fixed_indicator.
    IF is_selection-after_finish_date IS INITIAL.
      SELECT plnum AS planned_order,
             matnr AS material,
             pwwrk AS plant,
             plwrk AS planning_plant,
             pertr AS creation_date,
             puser AS planned_order_user,
             pstmp AS last_change_timestamp,
             gstrs AS scheduled_start_date,
             gsuzs AS scheduled_start_time,
             gltrs AS scheduled_finish_date,
             gluzs AS scheduled_finish_time,
             psttr AS start_date,
             pedtr AS finish_date,
             gsmng AS quantity,
             meins AS order_unit,
             paart AS order_type,
             lgort AS storage_location,
             beskz AS procurement_indicator,
             dispo AS mrp_controller,
             plgrp AS production_supervisor,
             verid AS production_version,
             berid AS mrp_area,
             knttp AS account_assignment_category,
             auffx AS fixed_indicator,
             plscn AS planning_scenario,
             sobkz AS special_stock_indicator,
             kdauf AS sales_order,
             kdpos AS sales_order_item,
             kdein AS sales_order_schedule_line
        FROM plaf
        WHERE matnr = @is_selection-material
          AND pwwrk = @is_selection-plant
          AND ( ( @lv_filter_planning_plant = @lv_false
              AND @lv_planning_plant = @lv_blank_planning_plant )
            OR plwrk = @lv_planning_plant )
          AND ( ( @lv_filter_sales_order = @lv_false
              AND @lv_sales_order = @lv_blank_sales_order )
            OR kdauf = @lv_sales_order )
          AND ( @lv_filter_sales_order_item = @lv_false
            OR kdpos = @lv_sales_order_item )
          AND ( @lv_filter_sales_schedule_line = @lv_false
            OR kdein = @lv_sales_order_schedule_line )
          AND ( ( @lv_filter_planning_scenario = @lv_false
              AND @lv_planning_scenario = @lv_blank_planning_scenario )
            OR plscn = @lv_planning_scenario )
          AND ( ( @lv_filter_order_type = @lv_false
              AND @lv_order_type = @lv_blank_order_type )
            OR paart = @lv_order_type )
          AND ( @lv_filter_storage_location = @lv_false
            OR lgort = @lv_storage_location )
          AND ( @lv_filter_proc_indicator = @lv_false
            OR beskz = @lv_procurement_indicator )
          AND ( ( @lv_filter_order_unit = @lv_false
              AND @lv_order_unit = @lv_blank_order_unit )
            OR meins = @lv_order_unit )
          AND ( @lv_positive_quantity_only = @lv_false
            OR gsmng > 0 )
          AND ( @lv_filter_quantity_from = @lv_false
            OR gsmng >= @lv_quantity_from )
          AND ( @lv_filter_quantity_to = @lv_false
            OR gsmng <= @lv_quantity_to )
          AND ( @lv_filter_mrp_controller = @lv_false
            OR dispo = @lv_mrp_controller )
          AND ( @lv_filter_prod_supervisor = @lv_false
            OR plgrp = @lv_production_supervisor )
          AND ( @lv_filter_prod_version = @lv_false
            OR verid = @lv_production_version )
          AND ( @lv_filter_mrp_area = @lv_false
            OR berid = @lv_mrp_area )
          AND ( @lv_filter_account_category = @lv_false
            OR knttp = @lv_account_category )
          AND ( ( @lv_filter_start_date = @lv_false
              AND @lv_exact_start_date = @lv_blank_start_date )
            OR psttr = @lv_exact_start_date )
          AND ( @lv_start_date_from = @lv_blank_start_date
            OR psttr BETWEEN @lv_start_date_from AND @lv_start_date_to )
          AND ( ( @lv_filter_sched_start_date = @lv_false
              AND @lv_sched_start_date = @lv_blank_scheduled_start_date )
            OR gstrs = @lv_sched_start_date )
          AND ( @lv_scheduled_start_date_from =
              @lv_blank_scheduled_start_date
            OR gstrs BETWEEN @lv_scheduled_start_date_from
              AND @lv_scheduled_start_date_to )
          AND ( @lv_filter_scheduled_start_time = @lv_false
            OR gsuzs BETWEEN @lv_scheduled_start_time_from
              AND @lv_scheduled_start_time_to )
          AND ( ( @lv_filter_sched_finish_date = @lv_false
              AND @lv_sched_finish_date = @lv_blank_scheduled_finish_date )
            OR gltrs = @lv_sched_finish_date )
          AND ( @lv_creation_date_from = @lv_blank_creation_date
            OR pertr BETWEEN @lv_creation_date_from
              AND @lv_creation_date_to )
          AND ( @lv_last_change_timestamp_from =
              @lv_blank_last_change_timestamp
            OR pstmp >= @lv_last_change_timestamp_from )
          AND ( @lv_last_change_timestamp_to =
              @lv_blank_last_change_timestamp
            OR pstmp <= @lv_last_change_timestamp_to )
          AND ( ( @lv_filter_planned_order_user = @lv_false
              AND @lv_planned_order_user = @lv_blank_planned_order_user )
            OR puser = @lv_planned_order_user )
          AND ( @lv_filter_special_stock = @lv_false
            OR sobkz = @lv_special_stock_indicator )
          AND ( @lv_filter_fixed_indicator = @lv_false
            OR auffx = @lv_fixed_indicator )
          AND ( @lv_scheduled_finish_date_from =
              @lv_blank_scheduled_finish_date
            OR gltrs BETWEEN @lv_scheduled_finish_date_from
              AND @lv_scheduled_finish_date_to )
          AND ( @lv_filter_sched_finish_time = @lv_false
            OR gluzs BETWEEN @lv_scheduled_finish_time_from
              AND @lv_scheduled_finish_time_to )
          AND pedtr BETWEEN @is_selection-finish_date_from
            AND @is_selection-finish_date_to
        ORDER BY pedtr, plnum
        INTO CORRESPONDING FIELDS OF TABLE @lt_orders
        UP TO @lv_fetch_limit ROWS.
    ELSE.
      SELECT plnum AS planned_order,
             matnr AS material,
             pwwrk AS plant,
             plwrk AS planning_plant,
             pertr AS creation_date,
             puser AS planned_order_user,
             pstmp AS last_change_timestamp,
             gstrs AS scheduled_start_date,
             gsuzs AS scheduled_start_time,
             gltrs AS scheduled_finish_date,
             gluzs AS scheduled_finish_time,
             psttr AS start_date,
             pedtr AS finish_date,
             gsmng AS quantity,
             meins AS order_unit,
             paart AS order_type,
             lgort AS storage_location,
             beskz AS procurement_indicator,
             dispo AS mrp_controller,
             plgrp AS production_supervisor,
             verid AS production_version,
             berid AS mrp_area,
             knttp AS account_assignment_category,
             auffx AS fixed_indicator,
             plscn AS planning_scenario,
             sobkz AS special_stock_indicator,
             kdauf AS sales_order,
             kdpos AS sales_order_item,
             kdein AS sales_order_schedule_line
        FROM plaf
        WHERE matnr = @is_selection-material
          AND pwwrk = @is_selection-plant
          AND ( ( @lv_filter_planning_plant = @lv_false
              AND @lv_planning_plant = @lv_blank_planning_plant )
            OR plwrk = @lv_planning_plant )
          AND ( ( @lv_filter_sales_order = @lv_false
              AND @lv_sales_order = @lv_blank_sales_order )
            OR kdauf = @lv_sales_order )
          AND ( @lv_filter_sales_order_item = @lv_false
            OR kdpos = @lv_sales_order_item )
          AND ( @lv_filter_sales_schedule_line = @lv_false
            OR kdein = @lv_sales_order_schedule_line )
          AND ( ( @lv_filter_planning_scenario = @lv_false
              AND @lv_planning_scenario = @lv_blank_planning_scenario )
            OR plscn = @lv_planning_scenario )
          AND ( ( @lv_filter_order_type = @lv_false
              AND @lv_order_type = @lv_blank_order_type )
            OR paart = @lv_order_type )
          AND ( @lv_filter_storage_location = @lv_false
            OR lgort = @lv_storage_location )
          AND ( @lv_filter_proc_indicator = @lv_false
            OR beskz = @lv_procurement_indicator )
          AND ( ( @lv_filter_order_unit = @lv_false
              AND @lv_order_unit = @lv_blank_order_unit )
            OR meins = @lv_order_unit )
          AND ( @lv_positive_quantity_only = @lv_false
            OR gsmng > 0 )
          AND ( @lv_filter_quantity_from = @lv_false
            OR gsmng >= @lv_quantity_from )
          AND ( @lv_filter_quantity_to = @lv_false
            OR gsmng <= @lv_quantity_to )
          AND ( @lv_filter_mrp_controller = @lv_false
            OR dispo = @lv_mrp_controller )
          AND ( @lv_filter_prod_supervisor = @lv_false
            OR plgrp = @lv_production_supervisor )
          AND ( @lv_filter_prod_version = @lv_false
            OR verid = @lv_production_version )
          AND ( @lv_filter_mrp_area = @lv_false
            OR berid = @lv_mrp_area )
          AND ( @lv_filter_account_category = @lv_false
            OR knttp = @lv_account_category )
          AND ( ( @lv_filter_start_date = @lv_false
              AND @lv_exact_start_date = @lv_blank_start_date )
            OR psttr = @lv_exact_start_date )
          AND ( @lv_start_date_from = @lv_blank_start_date
            OR psttr BETWEEN @lv_start_date_from AND @lv_start_date_to )
          AND ( ( @lv_filter_sched_start_date = @lv_false
              AND @lv_sched_start_date = @lv_blank_scheduled_start_date )
            OR gstrs = @lv_sched_start_date )
          AND ( @lv_scheduled_start_date_from =
              @lv_blank_scheduled_start_date
            OR gstrs BETWEEN @lv_scheduled_start_date_from
              AND @lv_scheduled_start_date_to )
          AND ( @lv_filter_scheduled_start_time = @lv_false
            OR gsuzs BETWEEN @lv_scheduled_start_time_from
              AND @lv_scheduled_start_time_to )
          AND ( ( @lv_filter_sched_finish_date = @lv_false
              AND @lv_sched_finish_date = @lv_blank_scheduled_finish_date )
            OR gltrs = @lv_sched_finish_date )
          AND ( @lv_creation_date_from = @lv_blank_creation_date
            OR pertr BETWEEN @lv_creation_date_from
              AND @lv_creation_date_to )
          AND ( @lv_last_change_timestamp_from =
              @lv_blank_last_change_timestamp
            OR pstmp >= @lv_last_change_timestamp_from )
          AND ( @lv_last_change_timestamp_to =
              @lv_blank_last_change_timestamp
            OR pstmp <= @lv_last_change_timestamp_to )
          AND ( ( @lv_filter_planned_order_user = @lv_false
              AND @lv_planned_order_user = @lv_blank_planned_order_user )
            OR puser = @lv_planned_order_user )
          AND ( @lv_filter_special_stock = @lv_false
            OR sobkz = @lv_special_stock_indicator )
          AND ( @lv_filter_fixed_indicator = @lv_false
            OR auffx = @lv_fixed_indicator )
          AND ( @lv_scheduled_finish_date_from =
              @lv_blank_scheduled_finish_date
            OR gltrs BETWEEN @lv_scheduled_finish_date_from
              AND @lv_scheduled_finish_date_to )
          AND ( @lv_filter_sched_finish_time = @lv_false
            OR gluzs BETWEEN @lv_scheduled_finish_time_from
              AND @lv_scheduled_finish_time_to )
          AND pedtr BETWEEN @is_selection-finish_date_from
            AND @is_selection-finish_date_to
          AND ( pedtr > @is_selection-after_finish_date
            OR ( pedtr = @is_selection-after_finish_date
              AND plnum > @is_selection-after_planned_order ) )
        ORDER BY pedtr, plnum
        INTO CORRESPONDING FIELDS OF TABLE @lt_orders
        UP TO @lv_fetch_limit ROWS.
    ENDIF.

    rt_orders = enrich_order_units( it_orders = lt_orders ).
  ENDMETHOD.

  METHOD enrich_order_units.
    TYPES:
      BEGIN OF ty_material_key,
        material TYPE mara-matnr,
      END OF ty_material_key,
      ty_material_keys TYPE SORTED TABLE OF ty_material_key
        WITH UNIQUE KEY material,
      BEGIN OF ty_base_unit,
        material  TYPE mara-matnr,
        base_unit TYPE mara-meins,
      END OF ty_base_unit,
      ty_base_units TYPE HASHED TABLE OF ty_base_unit
        WITH UNIQUE KEY material,
      BEGIN OF ty_unit_conversion,
        material    TYPE marm-matnr,
        unit        TYPE marm-meinh,
        numerator   TYPE marm-umrez,
        denominator TYPE marm-umren,
      END OF ty_unit_conversion,
      ty_unit_conversions TYPE HASHED TABLE OF ty_unit_conversion
        WITH UNIQUE KEY material unit.
    DATA lt_material_keys TYPE ty_material_keys.
    DATA lt_base_units TYPE ty_base_units.
    DATA lt_unit_conversions TYPE ty_unit_conversions.

    IF it_orders IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_orders INTO DATA(ls_order).
      INSERT VALUE #( material = ls_order-material )
        INTO TABLE lt_material_keys.
    ENDLOOP.

    SELECT matnr AS material,
           meins AS base_unit
      FROM mara
      FOR ALL ENTRIES IN @lt_material_keys
      WHERE matnr = @lt_material_keys-material
      INTO TABLE @lt_base_units.

    SELECT matnr AS material,
           meinh AS unit,
           umrez AS numerator,
           umren AS denominator
      FROM marm
      FOR ALL ENTRIES IN @lt_material_keys
      WHERE matnr = @lt_material_keys-material
      INTO TABLE @lt_unit_conversions.

    LOOP AT it_orders INTO ls_order.
      READ TABLE lt_base_units INTO DATA(ls_base_unit)
        WITH TABLE KEY material = ls_order-material.
      IF sy-subrc = 0.
        ls_order-base_unit = ls_base_unit-base_unit.
      ENDIF.

      READ TABLE lt_unit_conversions INTO DATA(ls_unit_conversion)
        WITH TABLE KEY
          material = ls_order-material
          unit = ls_order-order_unit.
      IF sy-subrc = 0.
        ls_order-unit_to_base_numerator = ls_unit_conversion-numerator.
        ls_order-unit_to_base_denominator = ls_unit_conversion-denominator.
      ENDIF.

      APPEND ls_order TO rt_orders.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
