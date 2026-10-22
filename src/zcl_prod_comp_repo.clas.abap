CLASS zcl_prod_comp_repo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_prod_comp_repo.
ENDCLASS.

CLASS zcl_prod_comp_repo IMPLEMENTATION.

  METHOD zif_prod_comp_repo~get_components.
    DATA lt_production_orders TYPE zif_prod_comp_repo=>ty_production_orders.

    APPEND iv_production_order TO lt_production_orders.
    rt_items = zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = lt_production_orders
      is_required_date_range = is_required_date_range ).
  ENDMETHOD.

  METHOD zif_prod_comp_repo~get_components_bulk.
    DATA(lv_filter_from) = is_required_date_range-filter_from.
    DATA(lv_required_date_from) =
      is_required_date_range-required_date_from.
    DATA(lv_filter_through) = is_required_date_range-filter_through.
    DATA(lv_required_date_through) =
      is_required_date_range-required_date_through.
    DATA(lv_filter_bucket) = is_required_date_range-filter_bucket.
    DATA(lv_required_date_bucket) =
      is_required_date_range-required_date_bucket.
    DATA(lv_as_of_date) = is_required_date_range-as_of_date.
    DATA(lv_include_undated) = is_required_date_range-include_undated.
    DATA(lv_filter_material) = is_required_date_range-filter_material.
    DATA(lv_material) = is_required_date_range-material.
    DATA(lv_filter_plant) = is_required_date_range-filter_plant.
    DATA(lv_plant) = is_required_date_range-plant.
    DATA(lv_filter_storage_location) =
      is_required_date_range-filter_storage_location.
    DATA(lv_storage_location) = is_required_date_range-storage_location.
    DATA(lv_filter_batch) = is_required_date_range-filter_batch.
    DATA(lv_batch) = is_required_date_range-batch.
    DATA(lv_filter_movement_type) =
      is_required_date_range-filter_movement_type.
    DATA(lv_movement_type) = is_required_date_range-movement_type.
    DATA(lv_filter_unit) = is_required_date_range-filter_unit.
    DATA(lv_unit) = is_required_date_range-unit.
    DATA(lv_filter_sales_order_item) =
      is_required_date_range-filter_sales_order_item.
    DATA(lv_sales_order_number) = is_required_date_range-sales_order_number.
    DATA(lv_sales_order_item) = is_required_date_range-sales_order_item.
    DATA(lv_filter_sales_schedule_line) =
      is_required_date_range-filter_sales_schedule_line.
    DATA(lv_sales_order_schedule_line) =
      is_required_date_range-sales_order_schedule_line.
    DATA(lv_filter_wbs_internal_id) =
      is_required_date_range-filter_wbs_internal_id.
    DATA(lv_wbs_internal_id) = is_required_date_range-wbs_internal_id.
    DATA(lv_filter_sobkz) =
      is_required_date_range-filter_special_stock_indicator.
    DATA(lv_sobkz) =
      is_required_date_range-special_stock_indicator.
    DATA(lv_filter_requirement_type) =
      is_required_date_range-filter_requirement_type.
    DATA(lv_requirement_type) =
      is_required_date_range-requirement_type.
    DATA(lv_filter_staging_indicator) =
      is_required_date_range-filter_staging_indicator.
    DATA(lv_staging_indicator) =
      is_required_date_range-staging_indicator.
    DATA(lv_filter_mrp_relevance) =
      is_required_date_range-filter_mrp_relevance.
    DATA(lv_mrp_relevance) =
      is_required_date_range-mrp_relevance.
    DATA(lv_filter_bom_item) =
      is_required_date_range-filter_bom_item.
    DATA(lv_bom_item_number) =
      is_required_date_range-bom_item_number.
    DATA(lv_filter_required_qty_from) =
      is_required_date_range-filter_required_qty_from.
    DATA(lv_required_quantity_from) =
      is_required_date_range-required_quantity_from.
    DATA(lv_filter_required_qty_through) =
      is_required_date_range-filter_required_qty_through.
    DATA(lv_required_quantity_through) =
      is_required_date_range-required_quantity_through.
    DATA(lv_wdr_from) =
      is_required_date_range-filter_withdrawn_qty_from.
    DATA(lv_withdrawn_quantity_from) =
      is_required_date_range-withdrawn_quantity_from.
    DATA(lv_wdr_to) =
      is_required_date_range-filter_withdrawn_qty_through.
    DATA(lv_withdrawn_quantity_through) =
      is_required_date_range-withdrawn_quantity_through.
    DATA(lv_filter_reservation_number) =
      is_required_date_range-filter_reservation_number.
    DATA(lv_reservation_number) = is_required_date_range-reservation_number.
    DATA(lv_filter_res_num_from) =
      is_required_date_range-filter_res_num_from.
    DATA(lv_reservation_number_from) =
      is_required_date_range-reservation_number_from.
    DATA(lv_filter_res_num_through) =
      is_required_date_range-filter_res_num_through.
    DATA(lv_reservation_number_through) =
      is_required_date_range-reservation_number_through.
    DATA(lv_filter_reservation_item) =
      is_required_date_range-filter_reservation_item.
    DATA(lv_reservation_item) = is_required_date_range-reservation_item.
    DATA(lv_filter_res_item_from) =
      is_required_date_range-filter_res_item_from.
    DATA(lv_reservation_item_from) =
      is_required_date_range-reservation_item_from.
    DATA(lv_filter_res_item_through) =
      is_required_date_range-filter_res_item_through.
    DATA(lv_reservation_item_through) =
      is_required_date_range-reservation_item_through.
    DATA(lv_horizon_days) =
      is_required_date_range-required_date_horizon_days.
    DATA(lv_horizon_to) = zcl_date_validation=>add_days(
      iv_date = lv_as_of_date
      iv_days = lv_horizon_days ).
    DATA(lv_horizon_past_days) = 0 - lv_horizon_days.
    DATA(lv_horizon_from) = zcl_date_validation=>add_days(
      iv_date = lv_as_of_date
      iv_days = lv_horizon_past_days ).
    DATA lv_initial_date TYPE resb-bdter.

    IF it_production_orders IS INITIAL.
      RETURN.
    ENDIF.

    SELECT aufnr AS production_order,
           plnum AS planned_order,
           kdauf AS sales_order_number,
           kdpos AS sales_order_item,
           kdein AS sales_order_schedule_line,
           pspel AS wbs_internal_id,
           sobkz AS special_stock_indicator,
           bdart AS requirement_type,
           berkz AS staging_indicator,
           no_disp AS mrp_relevance,
           posnr AS bom_item_number,
           potx1 AS bom_item_text,
           rsnum AS reservation_number,
           rspos AS reservation_item,
           matnr AS material,
           werks AS plant,
           lgort AS storage_location,
           charg AS batch,
           bwart AS movement_type,
           bdter AS required_date,
           bdmng AS required_quantity,
           enmng AS withdrawn_quantity,
           meins AS unit,
           xloek AS is_deleted,
           kzear AS is_final_issue
      FROM resb
      FOR ALL ENTRIES IN @it_production_orders
      WHERE aufnr = @it_production_orders-table_line
        AND ( @lv_filter_material = @abap_false
          OR matnr = @lv_material )
        AND ( @lv_filter_plant = @abap_false
          OR werks = @lv_plant )
        AND ( @lv_filter_storage_location = @abap_false
          OR lgort = @lv_storage_location )
        AND ( @lv_filter_batch = @abap_false
          OR charg = @lv_batch )
        AND ( @lv_filter_movement_type = @abap_false
          OR bwart = @lv_movement_type )
        AND ( @lv_filter_unit = @abap_false
          OR meins = @lv_unit )
        AND ( @lv_filter_sales_order_item = @abap_false
          OR kdauf = @lv_sales_order_number )
        AND ( @lv_filter_sales_order_item = @abap_false
          OR kdpos = @lv_sales_order_item )
        AND ( @lv_filter_sales_schedule_line = @abap_false
          OR kdein = @lv_sales_order_schedule_line )
        AND ( @lv_filter_wbs_internal_id = @abap_false
          OR pspel = @lv_wbs_internal_id )
        AND ( @lv_filter_sobkz = @abap_false
          OR sobkz = @lv_sobkz )
        AND ( @lv_filter_requirement_type = @abap_false
          OR bdart = @lv_requirement_type )
        AND ( @lv_filter_staging_indicator = @abap_false
          OR berkz = @lv_staging_indicator )
        AND ( @lv_filter_mrp_relevance = @abap_false
          OR no_disp = @lv_mrp_relevance )
        AND ( @lv_filter_bom_item = @abap_false
          OR posnr = @lv_bom_item_number )
        AND ( @lv_filter_reservation_number = @abap_false
          OR rsnum = @lv_reservation_number )
        AND ( @lv_filter_res_num_from = @abap_false
          OR rsnum >= @lv_reservation_number_from )
        AND ( @lv_filter_res_num_through = @abap_false
          OR rsnum <= @lv_reservation_number_through )
        AND ( @lv_filter_reservation_item = @abap_false
          OR rspos = @lv_reservation_item )
        AND ( @lv_filter_res_item_from = @abap_false
          OR rspos >= @lv_reservation_item_from )
        AND ( @lv_filter_res_item_through = @abap_false
          OR rspos <= @lv_reservation_item_through )
        AND ( @lv_filter_required_qty_from = @abap_false
          OR bdmng >= @lv_required_quantity_from )
        AND ( @lv_filter_required_qty_through = @abap_false
          OR bdmng <= @lv_required_quantity_through )
        AND ( @lv_wdr_from = @abap_false
          OR enmng >= @lv_withdrawn_quantity_from )
        AND ( @lv_wdr_to = @abap_false
          OR enmng <= @lv_withdrawn_quantity_through )
        AND ( ( ( @lv_filter_from = @abap_false
              OR bdter >= @lv_required_date_from )
            AND ( @lv_filter_through = @abap_false
              OR ( bdter <> @lv_initial_date
                AND bdter <= @lv_required_date_through ) )
            AND ( @lv_filter_bucket = @abap_false
              OR ( @lv_required_date_bucket = 'O'
                AND bdter <> @lv_initial_date
                AND bdter < @lv_as_of_date )
              OR ( @lv_required_date_bucket = 'T'
                AND bdter = @lv_as_of_date )
              OR ( @lv_required_date_bucket = 'F'
                AND bdter > @lv_as_of_date )
              OR ( @lv_required_date_bucket = 'U'
                AND bdter = @lv_initial_date )
              OR ( @lv_required_date_bucket = 'N'
                AND bdter > @lv_as_of_date
                AND bdter <= @lv_horizon_to )
              OR ( @lv_required_date_bucket = 'R'
                AND bdter >= @lv_horizon_from
                AND bdter < @lv_as_of_date )
              OR ( @lv_required_date_bucket = 'D'
                AND bdter <> @lv_initial_date ) ) )
          OR ( @lv_include_undated = @abap_true
            AND bdter = @lv_initial_date ) )
      ORDER BY aufnr, rsnum, rspos
      INTO CORRESPONDING FIELDS OF TABLE @rt_items.
  ENDMETHOD.

  METHOD zif_prod_comp_repo~get_planned_comp.
    DATA lt_planned_orders TYPE zif_prod_comp_repo=>ty_planned_orders.

    APPEND iv_planned_order TO lt_planned_orders.
    rt_items = zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = lt_planned_orders
      is_required_date_range = is_required_date_range ).
  ENDMETHOD.

  METHOD zif_prod_comp_repo~get_planned_comp_bulk.
    DATA(lv_filter_from) = is_required_date_range-filter_from.
    DATA(lv_required_date_from) =
      is_required_date_range-required_date_from.
    DATA(lv_filter_through) = is_required_date_range-filter_through.
    DATA(lv_required_date_through) =
      is_required_date_range-required_date_through.
    DATA(lv_filter_bucket) = is_required_date_range-filter_bucket.
    DATA(lv_required_date_bucket) =
      is_required_date_range-required_date_bucket.
    DATA(lv_as_of_date) = is_required_date_range-as_of_date.
    DATA(lv_include_undated) = is_required_date_range-include_undated.
    DATA(lv_filter_material) = is_required_date_range-filter_material.
    DATA(lv_material) = is_required_date_range-material.
    DATA(lv_filter_plant) = is_required_date_range-filter_plant.
    DATA(lv_plant) = is_required_date_range-plant.
    DATA(lv_filter_storage_location) =
      is_required_date_range-filter_storage_location.
    DATA(lv_storage_location) = is_required_date_range-storage_location.
    DATA(lv_filter_batch) = is_required_date_range-filter_batch.
    DATA(lv_batch) = is_required_date_range-batch.
    DATA(lv_filter_movement_type) =
      is_required_date_range-filter_movement_type.
    DATA(lv_movement_type) = is_required_date_range-movement_type.
    DATA(lv_filter_unit) = is_required_date_range-filter_unit.
    DATA(lv_unit) = is_required_date_range-unit.
    DATA(lv_filter_sales_order_item) =
      is_required_date_range-filter_sales_order_item.
    DATA(lv_sales_order_number) = is_required_date_range-sales_order_number.
    DATA(lv_sales_order_item) = is_required_date_range-sales_order_item.
    DATA(lv_filter_sales_schedule_line) =
      is_required_date_range-filter_sales_schedule_line.
    DATA(lv_sales_order_schedule_line) =
      is_required_date_range-sales_order_schedule_line.
    DATA(lv_filter_wbs_internal_id) =
      is_required_date_range-filter_wbs_internal_id.
    DATA(lv_wbs_internal_id) = is_required_date_range-wbs_internal_id.
    DATA(lv_filter_sobkz) =
      is_required_date_range-filter_special_stock_indicator.
    DATA(lv_sobkz) =
      is_required_date_range-special_stock_indicator.
    DATA(lv_filter_requirement_type) =
      is_required_date_range-filter_requirement_type.
    DATA(lv_requirement_type) =
      is_required_date_range-requirement_type.
    DATA(lv_filter_staging_indicator) =
      is_required_date_range-filter_staging_indicator.
    DATA(lv_staging_indicator) =
      is_required_date_range-staging_indicator.
    DATA(lv_filter_mrp_relevance) =
      is_required_date_range-filter_mrp_relevance.
    DATA(lv_mrp_relevance) =
      is_required_date_range-mrp_relevance.
    DATA(lv_filter_bom_item) =
      is_required_date_range-filter_bom_item.
    DATA(lv_bom_item_number) =
      is_required_date_range-bom_item_number.
    DATA(lv_filter_required_qty_from) =
      is_required_date_range-filter_required_qty_from.
    DATA(lv_required_quantity_from) =
      is_required_date_range-required_quantity_from.
    DATA(lv_filter_required_qty_through) =
      is_required_date_range-filter_required_qty_through.
    DATA(lv_required_quantity_through) =
      is_required_date_range-required_quantity_through.
    DATA(lv_wdr_from) =
      is_required_date_range-filter_withdrawn_qty_from.
    DATA(lv_withdrawn_quantity_from) =
      is_required_date_range-withdrawn_quantity_from.
    DATA(lv_wdr_to) =
      is_required_date_range-filter_withdrawn_qty_through.
    DATA(lv_withdrawn_quantity_through) =
      is_required_date_range-withdrawn_quantity_through.
    DATA(lv_filter_reservation_number) =
      is_required_date_range-filter_reservation_number.
    DATA(lv_reservation_number) = is_required_date_range-reservation_number.
    DATA(lv_filter_res_num_from) =
      is_required_date_range-filter_res_num_from.
    DATA(lv_reservation_number_from) =
      is_required_date_range-reservation_number_from.
    DATA(lv_filter_res_num_through) =
      is_required_date_range-filter_res_num_through.
    DATA(lv_reservation_number_through) =
      is_required_date_range-reservation_number_through.
    DATA(lv_filter_reservation_item) =
      is_required_date_range-filter_reservation_item.
    DATA(lv_reservation_item) = is_required_date_range-reservation_item.
    DATA(lv_filter_res_item_from) =
      is_required_date_range-filter_res_item_from.
    DATA(lv_reservation_item_from) =
      is_required_date_range-reservation_item_from.
    DATA(lv_filter_res_item_through) =
      is_required_date_range-filter_res_item_through.
    DATA(lv_reservation_item_through) =
      is_required_date_range-reservation_item_through.
    DATA(lv_horizon_days) =
      is_required_date_range-required_date_horizon_days.
    DATA(lv_horizon_to) = zcl_date_validation=>add_days(
      iv_date = lv_as_of_date
      iv_days = lv_horizon_days ).
    DATA(lv_horizon_past_days) = 0 - lv_horizon_days.
    DATA(lv_horizon_from) = zcl_date_validation=>add_days(
      iv_date = lv_as_of_date
      iv_days = lv_horizon_past_days ).
    DATA lv_initial_date TYPE resb-bdter.

    IF it_planned_orders IS INITIAL.
      RETURN.
    ENDIF.

    SELECT plnum AS planned_order,
           kdauf AS sales_order_number,
           kdpos AS sales_order_item,
           kdein AS sales_order_schedule_line,
           pspel AS wbs_internal_id,
           sobkz AS special_stock_indicator,
           bdart AS requirement_type,
           berkz AS staging_indicator,
           no_disp AS mrp_relevance,
           posnr AS bom_item_number,
           potx1 AS bom_item_text,
           rsnum AS reservation_number,
           rspos AS reservation_item,
           matnr AS material,
           werks AS plant,
           lgort AS storage_location,
           charg AS batch,
           bwart AS movement_type,
           bdter AS required_date,
           bdmng AS required_quantity,
           enmng AS withdrawn_quantity,
           meins AS unit,
           xloek AS is_deleted,
           kzear AS is_final_issue
      FROM resb
      FOR ALL ENTRIES IN @it_planned_orders
      WHERE plnum = @it_planned_orders-table_line
        AND ( @lv_filter_material = @abap_false
          OR matnr = @lv_material )
        AND ( @lv_filter_plant = @abap_false
          OR werks = @lv_plant )
        AND ( @lv_filter_storage_location = @abap_false
          OR lgort = @lv_storage_location )
        AND ( @lv_filter_batch = @abap_false
          OR charg = @lv_batch )
        AND ( @lv_filter_movement_type = @abap_false
          OR bwart = @lv_movement_type )
        AND ( @lv_filter_unit = @abap_false
          OR meins = @lv_unit )
        AND ( @lv_filter_sales_order_item = @abap_false
          OR kdauf = @lv_sales_order_number )
        AND ( @lv_filter_sales_order_item = @abap_false
          OR kdpos = @lv_sales_order_item )
        AND ( @lv_filter_sales_schedule_line = @abap_false
          OR kdein = @lv_sales_order_schedule_line )
        AND ( @lv_filter_wbs_internal_id = @abap_false
          OR pspel = @lv_wbs_internal_id )
        AND ( @lv_filter_sobkz = @abap_false
          OR sobkz = @lv_sobkz )
        AND ( @lv_filter_requirement_type = @abap_false
          OR bdart = @lv_requirement_type )
        AND ( @lv_filter_staging_indicator = @abap_false
          OR berkz = @lv_staging_indicator )
        AND ( @lv_filter_mrp_relevance = @abap_false
          OR no_disp = @lv_mrp_relevance )
        AND ( @lv_filter_bom_item = @abap_false
          OR posnr = @lv_bom_item_number )
        AND ( @lv_filter_reservation_number = @abap_false
          OR rsnum = @lv_reservation_number )
        AND ( @lv_filter_res_num_from = @abap_false
          OR rsnum >= @lv_reservation_number_from )
        AND ( @lv_filter_res_num_through = @abap_false
          OR rsnum <= @lv_reservation_number_through )
        AND ( @lv_filter_reservation_item = @abap_false
          OR rspos = @lv_reservation_item )
        AND ( @lv_filter_res_item_from = @abap_false
          OR rspos >= @lv_reservation_item_from )
        AND ( @lv_filter_res_item_through = @abap_false
          OR rspos <= @lv_reservation_item_through )
        AND ( @lv_filter_required_qty_from = @abap_false
          OR bdmng >= @lv_required_quantity_from )
        AND ( @lv_filter_required_qty_through = @abap_false
          OR bdmng <= @lv_required_quantity_through )
        AND ( @lv_wdr_from = @abap_false
          OR enmng >= @lv_withdrawn_quantity_from )
        AND ( @lv_wdr_to = @abap_false
          OR enmng <= @lv_withdrawn_quantity_through )
        AND ( ( ( @lv_filter_from = @abap_false
              OR bdter >= @lv_required_date_from )
            AND ( @lv_filter_through = @abap_false
              OR ( bdter <> @lv_initial_date
                AND bdter <= @lv_required_date_through ) )
            AND ( @lv_filter_bucket = @abap_false
              OR ( @lv_required_date_bucket = 'O'
                AND bdter <> @lv_initial_date
                AND bdter < @lv_as_of_date )
              OR ( @lv_required_date_bucket = 'T'
                AND bdter = @lv_as_of_date )
              OR ( @lv_required_date_bucket = 'F'
                AND bdter > @lv_as_of_date )
              OR ( @lv_required_date_bucket = 'U'
                AND bdter = @lv_initial_date )
              OR ( @lv_required_date_bucket = 'N'
                AND bdter > @lv_as_of_date
                AND bdter <= @lv_horizon_to )
              OR ( @lv_required_date_bucket = 'R'
                AND bdter >= @lv_horizon_from
                AND bdter < @lv_as_of_date )
              OR ( @lv_required_date_bucket = 'D'
                AND bdter <> @lv_initial_date ) ) )
          OR ( @lv_include_undated = @abap_true
            AND bdter = @lv_initial_date ) )
      ORDER BY plnum, rsnum, rspos
      INTO CORRESPONDING FIELDS OF TABLE @rt_items.
  ENDMETHOD.

ENDCLASS.
