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
        AND ( @lv_filter_from = @abap_false
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
            AND bdter < @lv_as_of_date ) )
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
        AND ( @lv_filter_from = @abap_false
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
            AND bdter < @lv_as_of_date ) )
      ORDER BY plnum, rsnum, rspos
      INTO CORRESPONDING FIELDS OF TABLE @rt_items.
  ENDMETHOD.

ENDCLASS.
