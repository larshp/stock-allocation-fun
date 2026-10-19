CLASS zcl_prod_order_read_repo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_prod_order_read_repo.
ENDCLASS.

CLASS zcl_prod_order_read_repo IMPLEMENTATION.

  METHOD zif_prod_order_read_repo~read_orders.
    TYPES:
      BEGIN OF ty_order_item_data,
        aufnr TYPE afpo-aufnr,
        posnr TYPE afpo-posnr,
        kdauf TYPE afpo-kdauf,
        kdpos TYPE afpo-kdpos,
        kdein TYPE afpo-kdein,
        lgort TYPE afpo-lgort,
        charg TYPE afpo-charg,
        knttp TYPE afpo-knttp,
        berid TYPE afpo-berid,
        projn TYPE afpo-projn,
        plnum TYPE afpo-plnum,
        matnr TYPE afpo-matnr,
        werks TYPE afpo-werks,
        pwerk TYPE afpo-pwerk,
        dwerk TYPE afpo-dwerk,
        sobkz TYPE afpo-sobkz,
        insmk TYPE afpo-insmk,
        wempf TYPE afpo-wempf,
        ablad TYPE afpo-ablad,
        verid TYPE afpo-verid,
        strmp TYPE afpo-strmp,
        amein TYPE afpo-amein,
        meins TYPE afpo-meins,
        psmng TYPE afpo-psmng,
        wemng TYPE afpo-wemng,
        umrez TYPE afpo-umrez,
        umren TYPE afpo-umren,
        wepos TYPE afpo-wepos,
        xloek TYPE afpo-xloek,
        elikz TYPE afpo-elikz,
      END OF ty_order_item_data,
      ty_order_item_rows TYPE STANDARD TABLE OF ty_order_item_data
        WITH EMPTY KEY,
      BEGIN OF ty_wbs_data,
        pspnr TYPE prps-pspnr,
        posid TYPE prps-posid,
      END OF ty_wbs_data,
      ty_wbs_rows TYPE HASHED TABLE OF ty_wbs_data
        WITH UNIQUE KEY pspnr,
      BEGIN OF ty_order_header_data,
        aufnr TYPE afko-aufnr,
        gstrp TYPE afko-gstrp,
        gltrp TYPE afko-gltrp,
        gstrs TYPE afko-gstrs,
        gltrs TYPE afko-gltrs,
        gsuzs TYPE afko-gsuzs,
        gluzs TYPE afko-gluzs,
      END OF ty_order_header_data,
      ty_order_header_rows TYPE HASHED TABLE OF ty_order_header_data
        WITH UNIQUE KEY aufnr,
      BEGIN OF ty_order_control_data,
        aufnr TYPE aufk-aufnr,
        autyp TYPE aufk-autyp,
        auart TYPE aufk-auart,
        ktext TYPE aufk-ktext,
        ernam TYPE aufk-ernam,
        erdat TYPE aufk-erdat,
        aenam TYPE aufk-aenam,
        aedat TYPE aufk-aedat,
        phas1 TYPE aufk-phas1,
        phas2 TYPE aufk-phas2,
        phas3 TYPE aufk-phas3,
        loekz TYPE aufk-loekz,
      END OF ty_order_control_data,
      ty_order_control_rows TYPE HASHED TABLE OF ty_order_control_data
        WITH UNIQUE KEY aufnr.
    DATA lt_afpo TYPE ty_order_item_rows.
    DATA lt_afko TYPE ty_order_header_rows.
    DATA lt_aufk TYPE ty_order_control_rows.
    DATA lt_wbs TYPE ty_wbs_rows.
    DATA ls_order_item TYPE zif_prod_order_read_repo=>ty_order_item.

    IF it_production_orders IS INITIAL.
      RETURN.
    ENDIF.

    SELECT aufnr,
           posnr,
           kdauf,
           kdpos,
           kdein,
           lgort,
           charg,
           knttp,
           berid,
           projn,
           plnum,
           matnr,
           werks,
           pwerk,
           dwerk,
           sobkz,
           insmk,
           wempf,
           ablad,
           verid,
           strmp,
           amein,
           meins,
           psmng,
           wemng,
           umrez,
           umren,
           wepos,
           xloek,
           elikz
      FROM afpo
      FOR ALL ENTRIES IN @it_production_orders
      WHERE aufnr = @it_production_orders-table_line
      INTO CORRESPONDING FIELDS OF TABLE @lt_afpo.

    IF lt_afpo IS INITIAL.
      RETURN.
    ENDIF.

    SELECT pspnr,
           posid
      FROM prps
      FOR ALL ENTRIES IN @lt_afpo
      WHERE pspnr = @lt_afpo-projn
      INTO TABLE @lt_wbs.

    SELECT aufnr,
           gstrp,
           gltrp,
           gstrs,
           gltrs,
           gsuzs,
           gluzs
      FROM afko
      FOR ALL ENTRIES IN @lt_afpo
      WHERE aufnr = @lt_afpo-aufnr
      INTO CORRESPONDING FIELDS OF TABLE @lt_afko.

    SELECT aufnr,
           autyp,
           auart,
           ktext,
           ernam,
           erdat,
           aenam,
           aedat,
           phas1,
           phas2,
           phas3,
           loekz
      FROM aufk
      FOR ALL ENTRIES IN @lt_afpo
      WHERE aufnr = @lt_afpo-aufnr
        AND ( autyp = '10' OR autyp = '40' )
      INTO CORRESPONDING FIELDS OF TABLE @lt_aufk.

    LOOP AT lt_afpo INTO DATA(ls_afpo).
      READ TABLE lt_afko INTO DATA(ls_afko)
        WITH TABLE KEY aufnr = ls_afpo-aufnr.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      READ TABLE lt_aufk INTO DATA(ls_aufk)
        WITH TABLE KEY aufnr = ls_afpo-aufnr.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      CLEAR ls_order_item.
      ls_order_item-production_order = ls_afpo-aufnr.
      ls_order_item-production_item = ls_afpo-posnr.
      ls_order_item-sales_order = ls_afpo-kdauf.
      ls_order_item-sales_order_item = ls_afpo-kdpos.
      ls_order_item-sales_order_schedule_line = ls_afpo-kdein.
      ls_order_item-storage_location = ls_afpo-lgort.
      ls_order_item-batch = ls_afpo-charg.
      ls_order_item-account_assignment_category = ls_afpo-knttp.
      ls_order_item-mrp_area = ls_afpo-berid.
      ls_order_item-wbs_element_internal_id = ls_afpo-projn.
      ls_order_item-planned_order = ls_afpo-plnum.
      IF ls_afpo-projn IS NOT INITIAL.
        READ TABLE lt_wbs INTO DATA(ls_wbs)
          WITH TABLE KEY pspnr = ls_afpo-projn.
        IF sy-subrc = 0.
          ls_order_item-wbs_element = ls_wbs-posid.
        ENDIF.
      ENDIF.
      ls_order_item-order_category = ls_aufk-autyp.
      ls_order_item-order_type = ls_aufk-auart.
      ls_order_item-order_description = ls_aufk-ktext.
      ls_order_item-order_created_by = ls_aufk-ernam.
      ls_order_item-created_date = ls_aufk-erdat.
      ls_order_item-order_changed_by = ls_aufk-aenam.
      ls_order_item-changed_date = ls_aufk-aedat.
      ls_order_item-material = ls_afpo-matnr.
      ls_order_item-plant = ls_afpo-werks.
      ls_order_item-planning_plant = ls_afpo-pwerk.
      ls_order_item-delivery_plant = ls_afpo-dwerk.
      ls_order_item-special_stock_indicator = ls_afpo-sobkz.
      ls_order_item-stock_type = ls_afpo-insmk.
      ls_order_item-goods_recipient = ls_afpo-wempf.
      ls_order_item-unloading_point = ls_afpo-ablad.
      ls_order_item-production_version = ls_afpo-verid.
      ls_order_item-planned_order_start_date = ls_afpo-strmp.
      ls_order_item-order_unit = ls_afpo-amein.
      ls_order_item-base_unit = ls_afpo-meins.
      ls_order_item-basic_start_date = ls_afko-gstrp.
      ls_order_item-basic_finish_date = ls_afko-gltrp.
      ls_order_item-scheduled_start_date = ls_afko-gstrs.
      ls_order_item-scheduled_finish_date = ls_afko-gltrs.
      ls_order_item-scheduled_start_time = ls_afko-gsuzs.
      ls_order_item-scheduled_finish_time = ls_afko-gluzs.
      ls_order_item-order_quantity = ls_afpo-psmng.
      ls_order_item-received_quantity = ls_afpo-wemng.
      ls_order_item-order_to_base_numerator = ls_afpo-umrez.
      ls_order_item-order_to_base_denominator = ls_afpo-umren.
      ls_order_item-phase_1_indicator = ls_aufk-phas1.
      ls_order_item-phase_2_indicator = ls_aufk-phas2.
      ls_order_item-phase_3_indicator = ls_aufk-phas3.
      ls_order_item-order_deletion_indicator = ls_aufk-loekz.
      ls_order_item-receipt_expected = ls_afpo-wepos.
      ls_order_item-item_deletion_indicator = ls_afpo-xloek.
      ls_order_item-delivery_complete = ls_afpo-elikz.
      APPEND ls_order_item TO rt_order_items.
    ENDLOOP.

    SORT rt_order_items BY production_order production_item.
  ENDMETHOD.

  METHOD zif_prod_order_read_repo~read_orders_by_finish_window.
    DATA lv_fetch_limit TYPE i.
    DATA lv_active_indicator TYPE jest-inact.
    DATA lv_order_category TYPE aufk-autyp.
    DATA lv_blank_order_category TYPE aufk-autyp.
    DATA lv_filter_sales_order TYPE abap_bool.
    DATA lv_sales_order TYPE afpo-kdauf.
    DATA lv_blank_sales_order TYPE afpo-kdauf.
    DATA lv_filter_sales_order_item TYPE abap_bool.
    DATA lv_sales_order_item TYPE afpo-kdpos.
    DATA lv_filter_sales_schedule_line TYPE abap_bool.
    DATA lv_sales_order_schedule_line TYPE afpo-kdein.
    DATA lv_blank_sales_schedule_line TYPE afpo-kdein.
    DATA lv_filter_planned_order TYPE abap_bool.
    DATA lv_planned_order TYPE afpo-plnum.
    DATA lv_blank_planned_order TYPE afpo-plnum.
    DATA lv_filter_planning_plant TYPE abap_bool.
    DATA lv_planning_plant TYPE afpo-pwerk.
    DATA lv_blank_planning_plant TYPE afpo-pwerk.
    DATA lv_filter_delivery_plant TYPE abap_bool.
    DATA lv_delivery_plant TYPE afpo-dwerk.
    DATA lv_blank_delivery_plant TYPE afpo-dwerk.
    DATA lv_filter_special_stock TYPE abap_bool.
    DATA lv_special_stock_indicator TYPE afpo-sobkz.
    DATA lv_blank_special_stock TYPE afpo-sobkz.
    DATA lv_filter_stock_type TYPE abap_bool.
    DATA lv_stock_type TYPE afpo-insmk.
    DATA lv_blank_stock_type TYPE afpo-insmk.
    DATA lv_filter_goods_recipient TYPE abap_bool.
    DATA lv_goods_recipient TYPE afpo-wempf.
    DATA lv_blank_goods_recipient TYPE afpo-wempf.
    DATA lv_filter_unloading_point TYPE abap_bool.
    DATA lv_unloading_point TYPE afpo-ablad.
    DATA lv_blank_unloading_point TYPE afpo-ablad.
    DATA lv_filter_production_version TYPE abap_bool.
    DATA lv_production_version TYPE afpo-verid.
    DATA lv_blank_production_version TYPE afpo-verid.
    DATA lv_filter_plan_start_date TYPE abap_bool.
    DATA lv_planned_order_start_date TYPE afpo-strmp.
    DATA lv_blank_plan_start_date TYPE afpo-strmp.
    DATA lv_blank_sales_order_item TYPE afpo-kdpos.
    DATA lv_filter_storage_location TYPE abap_bool.
    DATA lv_storage_location TYPE afpo-lgort.
    DATA lv_blank_storage_location TYPE afpo-lgort.
    DATA lv_filter_batch TYPE abap_bool.
    DATA lv_batch TYPE afpo-charg.
    DATA lv_blank_batch TYPE afpo-charg.
    DATA lv_filter_assignment_category TYPE abap_bool.
    DATA lv_account_assignment_category TYPE afpo-knttp.
    DATA lv_blank_assignment_category TYPE afpo-knttp.
    DATA lv_filter_mrp_area TYPE abap_bool.
    DATA lv_mrp_area TYPE afpo-berid.
    DATA lv_blank_mrp_area TYPE afpo-berid.
    DATA lv_filter_wbs_element TYPE abap_bool.
    DATA lv_wbs_element TYPE prps-posid.
    DATA lv_blank_wbs_element TYPE prps-posid.
    DATA lv_blank_wbs_internal_id TYPE afpo-projn.
    DATA lv_production_item TYPE afpo-posnr.
    DATA lv_blank_production_item TYPE afpo-posnr.
    DATA lv_order_unit TYPE afpo-amein.
    DATA lv_blank_order_unit TYPE afpo-amein.
    DATA lv_order_type TYPE aufk-auart.
    DATA lv_blank_order_type TYPE aufk-auart.
    DATA lv_order_description TYPE aufk-ktext.
    DATA lv_blank_order_description TYPE aufk-ktext.
    DATA lv_filter_order_description TYPE abap_bool.
    DATA lv_order_created_by TYPE aufk-ernam.
    DATA lv_blank_order_created_by TYPE aufk-ernam.
    DATA lv_filter_created_by TYPE abap_bool.
    DATA lv_order_changed_by TYPE aufk-aenam.
    DATA lv_blank_order_changed_by TYPE aufk-aenam.
    DATA lv_filter_changed_by TYPE abap_bool.
    DATA lv_required_phase TYPE c LENGTH 1.
    DATA lv_blank_required_phase TYPE c LENGTH 1.
    DATA lv_created_date_from TYPE aufk-erdat.
    DATA lv_created_date_to TYPE aufk-erdat.
    DATA lv_blank_created_date TYPE aufk-erdat.
    DATA lv_changed_date_from TYPE aufk-aedat.
    DATA lv_changed_date_to TYPE aufk-aedat.
    DATA lv_blank_changed_date TYPE aufk-aedat.
    DATA lv_exclude_deleted TYPE abap_bool.
    DATA lv_blank_deletion_indicator TYPE afpo-xloek.
    DATA lv_receipt_expected_only TYPE abap_bool.
    DATA lv_receipt_not_expected_only TYPE abap_bool.
    DATA lv_delivery_complete_only TYPE abap_bool.
    DATA lv_delivery_not_complete_only TYPE abap_bool.
    DATA lv_blank_receipt_expected TYPE afpo-wepos.
    DATA lv_blank_delivery_complete TYPE afpo-elikz.
    DATA lv_basic_start_date_from TYPE afko-gstrp.
    DATA lv_basic_start_date_to TYPE afko-gstrp.
    DATA lv_blank_basic_start_date TYPE afko-gstrp.
    DATA lv_filter_basic_start_date TYPE abap_bool.
    DATA lv_basic_start_date TYPE afko-gstrp.
    DATA lv_scheduled_start_date_from TYPE afko-gstrs.
    DATA lv_scheduled_start_date_to TYPE afko-gstrs.
    DATA lv_blank_scheduled_start_date TYPE afko-gstrs.
    DATA lv_filter_sched_start_date TYPE abap_bool.
    DATA lv_sched_start_date TYPE afko-gstrs.
    DATA lv_filter_scheduled_start_time TYPE abap_bool.
    DATA lv_scheduled_start_time_from TYPE afko-gsuzs.
    DATA lv_scheduled_start_time_to TYPE afko-gsuzs.
    DATA lv_scheduled_finish_date_from TYPE afko-gltrs.
    DATA lv_scheduled_finish_date_to TYPE afko-gltrs.
    DATA lv_blank_scheduled_finish_date TYPE afko-gltrs.
    DATA lv_filter_sched_finish_date TYPE abap_bool.
    DATA lv_sched_finish_date TYPE afko-gltrs.
    DATA lv_filter_sched_finish_time TYPE abap_bool.
    DATA lv_scheduled_finish_time_from TYPE afko-gluzs.
    DATA lv_scheduled_finish_time_to TYPE afko-gluzs.
    DATA lv_unreceived_quantity_only TYPE abap_bool.
    DATA lv_filter_order_qty_from TYPE abap_bool.
    DATA lv_order_qty_from TYPE afpo-psmng.
    DATA lv_filter_order_qty_to TYPE abap_bool.
    DATA lv_order_qty_to TYPE afpo-psmng.
    DATA lv_filter_unreceived_qty_from TYPE abap_bool.
    DATA lv_unreceived_qty_from TYPE afpo-psmng.
    DATA lv_filter_unreceived_qty_to TYPE abap_bool.
    DATA lv_unreceived_qty_to TYPE afpo-psmng.
    DATA lv_false_indicator TYPE abap_bool.
    DATA lv_true_indicator TYPE abap_bool.

    IF is_selection-maximum_results < 1
        OR is_selection-maximum_results > 500.
      RETURN.
    ENDIF.

    lv_fetch_limit = is_selection-maximum_results + 1.
    lv_order_category = is_selection-order_category.
    lv_filter_sales_order = is_selection-filter_sales_order.
    lv_sales_order = is_selection-sales_order.
    lv_filter_sales_order_item = is_selection-filter_sales_order_item.
    lv_sales_order_item = is_selection-sales_order_item.
    lv_filter_sales_schedule_line =
      is_selection-filter_sales_schedule_line.
    lv_sales_order_schedule_line =
      is_selection-sales_order_schedule_line.
    lv_filter_planned_order = is_selection-filter_planned_order.
    lv_planned_order = is_selection-planned_order.
    lv_filter_planning_plant = is_selection-filter_planning_plant.
    lv_planning_plant = is_selection-planning_plant.
    lv_filter_delivery_plant = is_selection-filter_delivery_plant.
    lv_delivery_plant = is_selection-delivery_plant.
    lv_filter_special_stock =
      is_selection-filter_special_stock.
    lv_special_stock_indicator = is_selection-special_stock_indicator.
    lv_filter_stock_type = is_selection-filter_stock_type.
    lv_stock_type = is_selection-stock_type.
    lv_filter_goods_recipient = is_selection-filter_goods_recipient.
    lv_goods_recipient = is_selection-goods_recipient.
    lv_filter_unloading_point = is_selection-filter_unloading_point.
    lv_unloading_point = is_selection-unloading_point.
    lv_filter_production_version =
      is_selection-filter_production_version.
    lv_production_version = is_selection-production_version.
    lv_filter_plan_start_date =
      is_selection-filter_plan_start_date.
    lv_planned_order_start_date = is_selection-planned_order_start_date.
    lv_filter_storage_location = is_selection-filter_storage_location.
    lv_storage_location = is_selection-storage_location.
    lv_filter_batch = is_selection-filter_batch.
    lv_batch = is_selection-batch.
    lv_filter_assignment_category =
      is_selection-filter_assignment_category.
    lv_account_assignment_category = is_selection-account_assignment_category.
    lv_filter_mrp_area = is_selection-filter_mrp_area.
    lv_mrp_area = is_selection-mrp_area.
    lv_filter_wbs_element = is_selection-filter_wbs_element.
    lv_wbs_element = is_selection-wbs_element.
    lv_production_item = is_selection-production_item.
    lv_order_unit = is_selection-order_unit.
    lv_order_type = is_selection-order_type.
    lv_order_description = is_selection-order_description.
    lv_filter_order_description = is_selection-filter_order_description.
    lv_order_created_by = is_selection-order_created_by.
    lv_filter_created_by = is_selection-filter_order_created_by.
    lv_order_changed_by = is_selection-order_changed_by.
    lv_filter_changed_by = is_selection-filter_order_changed_by.
    lv_required_phase = is_selection-required_phase.
    lv_created_date_from = is_selection-created_date_from.
    lv_created_date_to = is_selection-created_date_to.
    lv_changed_date_from = is_selection-changed_date_from.
    lv_changed_date_to = is_selection-changed_date_to.
    lv_exclude_deleted = is_selection-exclude_deleted.
    lv_receipt_expected_only = is_selection-receipt_expected_only.
    lv_receipt_not_expected_only =
      is_selection-receipt_not_expected_only.
    lv_delivery_complete_only = is_selection-delivery_complete_only.
    lv_delivery_not_complete_only =
      is_selection-delivery_not_complete_only.
    lv_true_indicator = abap_true.
    CLEAR lv_blank_production_item.
    CLEAR lv_blank_order_unit.
    lv_basic_start_date_from = is_selection-basic_start_date_from.
    lv_basic_start_date_to = is_selection-basic_start_date_to.
    lv_filter_basic_start_date = is_selection-filter_basic_start_date.
    lv_basic_start_date = is_selection-basic_start_date.
    lv_scheduled_start_date_from =
      is_selection-scheduled_start_date_from.
    lv_scheduled_start_date_to =
      is_selection-scheduled_start_date_to.
    CLEAR lv_blank_scheduled_start_date.
    lv_filter_sched_start_date =
      is_selection-filter_scheduled_start_date.
    lv_sched_start_date = is_selection-scheduled_start_date.
    lv_filter_scheduled_start_time =
      is_selection-filter_scheduled_start_time.
    lv_scheduled_start_time_from =
      is_selection-scheduled_start_time_from.
    lv_scheduled_start_time_to =
      is_selection-scheduled_start_time_to.
    lv_scheduled_finish_date_from =
      is_selection-scheduled_finish_date_from.
    lv_scheduled_finish_date_to =
      is_selection-scheduled_finish_date_to.
    CLEAR lv_blank_scheduled_finish_date.
    lv_filter_sched_finish_date =
      is_selection-filter_scheduled_finish_date.
    lv_sched_finish_date = is_selection-scheduled_finish_date.
    lv_filter_sched_finish_time =
      is_selection-filter_scheduled_finish_time.
    lv_scheduled_finish_time_from =
      is_selection-scheduled_finish_time_from.
    lv_scheduled_finish_time_to =
      is_selection-scheduled_finish_time_to.
    lv_unreceived_quantity_only =
      is_selection-unreceived_quantity_only.
    lv_filter_order_qty_from = is_selection-filter_order_qty_from.
    lv_order_qty_from = is_selection-order_qty_from.
    lv_filter_order_qty_to = is_selection-filter_order_qty_to.
    lv_order_qty_to = is_selection-order_qty_to.
    lv_filter_unreceived_qty_from =
      is_selection-filter_unreceived_qty_from.
    lv_unreceived_qty_from =
      is_selection-unreceived_qty_from.
    lv_filter_unreceived_qty_to =
      is_selection-filter_unreceived_qty_to.
    lv_unreceived_qty_to =
      is_selection-unreceived_qty_to.
    IF is_selection-active_status_code IS INITIAL.
      IF is_selection-after_finish_date IS INITIAL.
        SELECT DISTINCT afpo_row~aufnr AS production_order,
               afko_row~gltrp AS basic_finish_date,
               afko_row~gstrp AS basic_start_date,
               afko_row~gstrs AS scheduled_start_date,
               afko_row~gltrs AS scheduled_finish_date,
               afko_row~gsuzs AS scheduled_start_time,
               afko_row~gluzs AS scheduled_finish_time
          FROM afpo AS afpo_row
          INNER JOIN afko AS afko_row
            ON afko_row~aufnr = afpo_row~aufnr
          INNER JOIN aufk AS aufk_row
            ON aufk_row~aufnr = afpo_row~aufnr
          LEFT OUTER JOIN prps AS prps_row
            ON prps_row~pspnr = afpo_row~projn
          WHERE afpo_row~matnr = @is_selection-material
            AND afpo_row~werks = @is_selection-plant
            AND ( ( @lv_filter_planning_plant = @lv_false_indicator
                AND @lv_planning_plant = @lv_blank_planning_plant )
              OR afpo_row~pwerk = @lv_planning_plant )
            AND ( ( @lv_filter_delivery_plant = @lv_false_indicator
                AND @lv_delivery_plant = @lv_blank_delivery_plant )
              OR afpo_row~dwerk = @lv_delivery_plant )
            AND ( ( @lv_filter_special_stock = @lv_false_indicator
                AND @lv_special_stock_indicator = @lv_blank_special_stock )
              OR afpo_row~sobkz = @lv_special_stock_indicator )
            AND ( ( @lv_filter_stock_type = @lv_false_indicator
                AND @lv_stock_type = @lv_blank_stock_type )
              OR afpo_row~insmk = @lv_stock_type )
            AND ( ( @lv_filter_goods_recipient = @lv_false_indicator
                AND @lv_goods_recipient = @lv_blank_goods_recipient )
              OR afpo_row~wempf = @lv_goods_recipient )
            AND ( ( @lv_filter_unloading_point = @lv_false_indicator
                AND @lv_unloading_point = @lv_blank_unloading_point )
              OR afpo_row~ablad = @lv_unloading_point )
            AND ( ( @lv_filter_production_version = @lv_false_indicator
                AND @lv_production_version = @lv_blank_production_version )
              OR afpo_row~verid = @lv_production_version )
            AND ( ( @lv_filter_plan_start_date = @lv_false_indicator
                AND @lv_planned_order_start_date = @lv_blank_plan_start_date )
              OR afpo_row~strmp = @lv_planned_order_start_date )
            AND ( ( @lv_filter_sales_order = @lv_false_indicator
                AND @lv_sales_order = @lv_blank_sales_order )
              OR afpo_row~kdauf = @lv_sales_order )
            AND ( ( @lv_filter_sales_order_item = @lv_false_indicator
                AND @lv_sales_order_item = @lv_blank_sales_order_item )
              OR afpo_row~kdpos = @lv_sales_order_item )
            AND ( ( @lv_filter_sales_schedule_line = @lv_false_indicator
                AND @lv_sales_order_schedule_line = @lv_blank_sales_schedule_line )
              OR afpo_row~kdein = @lv_sales_order_schedule_line )
            AND ( ( @lv_filter_planned_order = @lv_false_indicator
                AND @lv_planned_order = @lv_blank_planned_order )
              OR afpo_row~plnum = @lv_planned_order )
            AND ( ( @lv_filter_storage_location = @lv_false_indicator
                AND @lv_storage_location = @lv_blank_storage_location )
              OR afpo_row~lgort = @lv_storage_location )
            AND ( ( @lv_filter_batch = @lv_false_indicator
                AND @lv_batch = @lv_blank_batch )
              OR afpo_row~charg = @lv_batch )
            AND ( ( @lv_filter_assignment_category = @lv_false_indicator
                AND @lv_account_assignment_category = @lv_blank_assignment_category )
              OR afpo_row~knttp = @lv_account_assignment_category )
            AND ( ( @lv_filter_mrp_area = @lv_false_indicator
                AND @lv_mrp_area = @lv_blank_mrp_area )
              OR afpo_row~berid = @lv_mrp_area )
            AND ( ( @lv_filter_wbs_element = @lv_false_indicator
                AND @lv_wbs_element = @lv_blank_wbs_element )
              OR ( @lv_wbs_element = @lv_blank_wbs_element
                AND afpo_row~projn = @lv_blank_wbs_internal_id )
              OR prps_row~posid = @lv_wbs_element )
            AND ( @lv_production_item = @lv_blank_production_item
              OR afpo_row~posnr = @lv_production_item )
            AND ( @lv_order_unit = @lv_blank_order_unit
              OR afpo_row~amein = @lv_order_unit )
            AND ( @lv_unreceived_quantity_only = @lv_false_indicator
              OR afpo_row~psmng > afpo_row~wemng )
            AND ( @lv_filter_order_qty_from = @lv_false_indicator
              OR afpo_row~psmng >= @lv_order_qty_from )
            AND ( @lv_filter_order_qty_to = @lv_false_indicator
              OR afpo_row~psmng <= @lv_order_qty_to )
            AND ( @lv_filter_unreceived_qty_from =
                @lv_false_indicator
              OR ( afpo_row~psmng > afpo_row~wemng
                AND afpo_row~psmng - afpo_row~wemng >=
                  @lv_unreceived_qty_from ) )
            AND ( @lv_filter_unreceived_qty_to =
                @lv_false_indicator
              OR ( afpo_row~psmng > afpo_row~wemng
                AND afpo_row~psmng - afpo_row~wemng <=
                  @lv_unreceived_qty_to ) )
            AND afko_row~gltrp BETWEEN @is_selection-finish_date_from
              AND @is_selection-finish_date_to
            AND ( ( @lv_filter_sched_start_date = @lv_false_indicator
                AND @lv_sched_start_date = @lv_blank_scheduled_start_date )
              OR afko_row~gstrs = @lv_sched_start_date )
            AND ( @lv_scheduled_start_date_from =
              @lv_blank_scheduled_start_date
              OR afko_row~gstrs BETWEEN @lv_scheduled_start_date_from
                AND @lv_scheduled_start_date_to )
            AND ( @lv_filter_scheduled_start_time = @lv_false_indicator
              OR afko_row~gsuzs BETWEEN @lv_scheduled_start_time_from
                AND @lv_scheduled_start_time_to )
            AND ( ( @lv_filter_sched_finish_date =
                @lv_false_indicator
                AND @lv_sched_finish_date =
                  @lv_blank_scheduled_finish_date )
              OR afko_row~gltrs = @lv_sched_finish_date )
            AND ( @lv_scheduled_finish_date_from =
              @lv_blank_scheduled_finish_date
              OR afko_row~gltrs BETWEEN @lv_scheduled_finish_date_from
                AND @lv_scheduled_finish_date_to )
            AND ( @lv_filter_sched_finish_time = @lv_false_indicator
              OR afko_row~gluzs BETWEEN @lv_scheduled_finish_time_from
                AND @lv_scheduled_finish_time_to )
            AND ( aufk_row~autyp = '10' OR aufk_row~autyp = '40' )
            AND ( @lv_order_category = @lv_blank_order_category
              OR aufk_row~autyp = @lv_order_category )
            AND ( @lv_order_type = @lv_blank_order_type
              OR aufk_row~auart = @lv_order_type )
            AND ( ( @lv_filter_order_description =
                @lv_false_indicator
                AND @lv_order_description = @lv_blank_order_description )
              OR aufk_row~ktext = @lv_order_description )
            AND ( ( @lv_filter_created_by = @lv_false_indicator
                AND @lv_order_created_by = @lv_blank_order_created_by )
              OR aufk_row~ernam = @lv_order_created_by )
            AND ( ( @lv_filter_changed_by = @lv_false_indicator
                AND @lv_order_changed_by = @lv_blank_order_changed_by )
              OR aufk_row~aenam = @lv_order_changed_by )
            AND ( @lv_required_phase = @lv_blank_required_phase
              OR ( @lv_required_phase = '1'
                AND aufk_row~phas1 = @lv_true_indicator )
              OR ( @lv_required_phase = '2'
                AND aufk_row~phas2 = @lv_true_indicator )
              OR ( @lv_required_phase = '3'
                AND aufk_row~phas3 = @lv_true_indicator ) )
            AND ( @lv_created_date_from = @lv_blank_created_date
              OR aufk_row~erdat BETWEEN @lv_created_date_from
                AND @lv_created_date_to )
            AND ( @lv_changed_date_from = @lv_blank_changed_date
              OR aufk_row~aedat BETWEEN @lv_changed_date_from
                AND @lv_changed_date_to )
            AND ( @lv_exclude_deleted = @lv_false_indicator
              OR ( aufk_row~loekz = @lv_blank_deletion_indicator
                AND afpo_row~xloek = @lv_blank_deletion_indicator ) )
            AND ( @lv_receipt_expected_only = @lv_false_indicator
              OR afpo_row~wepos = @lv_true_indicator )
            AND ( @lv_receipt_not_expected_only = @lv_false_indicator
              OR afpo_row~wepos = @lv_blank_receipt_expected )
            AND ( @lv_delivery_complete_only = @lv_false_indicator
              OR afpo_row~elikz = @lv_true_indicator )
            AND ( @lv_delivery_not_complete_only = @lv_false_indicator
              OR afpo_row~elikz = @lv_blank_delivery_complete )
            AND ( ( @lv_filter_basic_start_date = @lv_false_indicator
                AND @lv_basic_start_date = @lv_blank_basic_start_date )
              OR afko_row~gstrp = @lv_basic_start_date )
            AND ( @lv_basic_start_date_from =
              @lv_blank_basic_start_date
              OR afko_row~gstrp BETWEEN @lv_basic_start_date_from
                AND @lv_basic_start_date_to )
          ORDER BY basic_finish_date, production_order
          INTO TABLE @rt_order_keys
          UP TO @lv_fetch_limit ROWS.
      ELSE.
        SELECT DISTINCT afpo_row~aufnr AS production_order,
               afko_row~gltrp AS basic_finish_date,
               afko_row~gstrp AS basic_start_date,
               afko_row~gstrs AS scheduled_start_date,
               afko_row~gltrs AS scheduled_finish_date,
               afko_row~gsuzs AS scheduled_start_time,
               afko_row~gluzs AS scheduled_finish_time
          FROM afpo AS afpo_row
          INNER JOIN afko AS afko_row
            ON afko_row~aufnr = afpo_row~aufnr
          INNER JOIN aufk AS aufk_row
            ON aufk_row~aufnr = afpo_row~aufnr
          LEFT OUTER JOIN prps AS prps_row
            ON prps_row~pspnr = afpo_row~projn
          WHERE afpo_row~matnr = @is_selection-material
            AND afpo_row~werks = @is_selection-plant
            AND ( ( @lv_filter_planning_plant = @lv_false_indicator
                AND @lv_planning_plant = @lv_blank_planning_plant )
              OR afpo_row~pwerk = @lv_planning_plant )
            AND ( ( @lv_filter_delivery_plant = @lv_false_indicator
                AND @lv_delivery_plant = @lv_blank_delivery_plant )
              OR afpo_row~dwerk = @lv_delivery_plant )
            AND ( ( @lv_filter_special_stock = @lv_false_indicator
                AND @lv_special_stock_indicator = @lv_blank_special_stock )
              OR afpo_row~sobkz = @lv_special_stock_indicator )
            AND ( ( @lv_filter_stock_type = @lv_false_indicator
                AND @lv_stock_type = @lv_blank_stock_type )
              OR afpo_row~insmk = @lv_stock_type )
            AND ( ( @lv_filter_goods_recipient = @lv_false_indicator
                AND @lv_goods_recipient = @lv_blank_goods_recipient )
              OR afpo_row~wempf = @lv_goods_recipient )
            AND ( ( @lv_filter_unloading_point = @lv_false_indicator
                AND @lv_unloading_point = @lv_blank_unloading_point )
              OR afpo_row~ablad = @lv_unloading_point )
            AND ( ( @lv_filter_production_version = @lv_false_indicator
                AND @lv_production_version = @lv_blank_production_version )
              OR afpo_row~verid = @lv_production_version )
            AND ( ( @lv_filter_plan_start_date = @lv_false_indicator
                AND @lv_planned_order_start_date = @lv_blank_plan_start_date )
              OR afpo_row~strmp = @lv_planned_order_start_date )
            AND ( ( @lv_filter_sales_order = @lv_false_indicator
                AND @lv_sales_order = @lv_blank_sales_order )
              OR afpo_row~kdauf = @lv_sales_order )
            AND ( ( @lv_filter_sales_order_item = @lv_false_indicator
                AND @lv_sales_order_item = @lv_blank_sales_order_item )
              OR afpo_row~kdpos = @lv_sales_order_item )
            AND ( ( @lv_filter_sales_schedule_line = @lv_false_indicator
                AND @lv_sales_order_schedule_line = @lv_blank_sales_schedule_line )
              OR afpo_row~kdein = @lv_sales_order_schedule_line )
            AND ( ( @lv_filter_planned_order = @lv_false_indicator
                AND @lv_planned_order = @lv_blank_planned_order )
              OR afpo_row~plnum = @lv_planned_order )
            AND ( ( @lv_filter_storage_location = @lv_false_indicator
                AND @lv_storage_location = @lv_blank_storage_location )
              OR afpo_row~lgort = @lv_storage_location )
            AND ( ( @lv_filter_batch = @lv_false_indicator
                AND @lv_batch = @lv_blank_batch )
              OR afpo_row~charg = @lv_batch )
            AND ( ( @lv_filter_assignment_category = @lv_false_indicator
                AND @lv_account_assignment_category = @lv_blank_assignment_category )
              OR afpo_row~knttp = @lv_account_assignment_category )
            AND ( ( @lv_filter_mrp_area = @lv_false_indicator
                AND @lv_mrp_area = @lv_blank_mrp_area )
              OR afpo_row~berid = @lv_mrp_area )
            AND ( ( @lv_filter_wbs_element = @lv_false_indicator
                AND @lv_wbs_element = @lv_blank_wbs_element )
              OR ( @lv_wbs_element = @lv_blank_wbs_element
                AND afpo_row~projn = @lv_blank_wbs_internal_id )
              OR prps_row~posid = @lv_wbs_element )
            AND ( @lv_production_item = @lv_blank_production_item
              OR afpo_row~posnr = @lv_production_item )
            AND ( @lv_order_unit = @lv_blank_order_unit
              OR afpo_row~amein = @lv_order_unit )
            AND ( @lv_unreceived_quantity_only = @lv_false_indicator
              OR afpo_row~psmng > afpo_row~wemng )
            AND ( @lv_filter_order_qty_from = @lv_false_indicator
              OR afpo_row~psmng >= @lv_order_qty_from )
            AND ( @lv_filter_order_qty_to = @lv_false_indicator
              OR afpo_row~psmng <= @lv_order_qty_to )
            AND ( @lv_filter_unreceived_qty_from =
                @lv_false_indicator
              OR ( afpo_row~psmng > afpo_row~wemng
                AND afpo_row~psmng - afpo_row~wemng >=
                  @lv_unreceived_qty_from ) )
            AND ( @lv_filter_unreceived_qty_to =
                @lv_false_indicator
              OR ( afpo_row~psmng > afpo_row~wemng
                AND afpo_row~psmng - afpo_row~wemng <=
                  @lv_unreceived_qty_to ) )
            AND afko_row~gltrp BETWEEN @is_selection-finish_date_from
              AND @is_selection-finish_date_to
            AND ( ( @lv_filter_sched_start_date = @lv_false_indicator
                AND @lv_sched_start_date = @lv_blank_scheduled_start_date )
              OR afko_row~gstrs = @lv_sched_start_date )
            AND ( @lv_scheduled_start_date_from =
              @lv_blank_scheduled_start_date
              OR afko_row~gstrs BETWEEN @lv_scheduled_start_date_from
                AND @lv_scheduled_start_date_to )
            AND ( @lv_filter_scheduled_start_time = @lv_false_indicator
              OR afko_row~gsuzs BETWEEN @lv_scheduled_start_time_from
                AND @lv_scheduled_start_time_to )
            AND ( ( @lv_filter_sched_finish_date =
                @lv_false_indicator
                AND @lv_sched_finish_date =
                  @lv_blank_scheduled_finish_date )
              OR afko_row~gltrs = @lv_sched_finish_date )
            AND ( @lv_scheduled_finish_date_from =
              @lv_blank_scheduled_finish_date
              OR afko_row~gltrs BETWEEN @lv_scheduled_finish_date_from
                AND @lv_scheduled_finish_date_to )
            AND ( @lv_filter_sched_finish_time = @lv_false_indicator
              OR afko_row~gluzs BETWEEN @lv_scheduled_finish_time_from
                AND @lv_scheduled_finish_time_to )
            AND ( aufk_row~autyp = '10' OR aufk_row~autyp = '40' )
            AND ( @lv_order_category = @lv_blank_order_category
              OR aufk_row~autyp = @lv_order_category )
            AND ( @lv_order_type = @lv_blank_order_type
              OR aufk_row~auart = @lv_order_type )
            AND ( ( @lv_filter_order_description =
                @lv_false_indicator
                AND @lv_order_description = @lv_blank_order_description )
              OR aufk_row~ktext = @lv_order_description )
            AND ( ( @lv_filter_created_by = @lv_false_indicator
                AND @lv_order_created_by = @lv_blank_order_created_by )
              OR aufk_row~ernam = @lv_order_created_by )
            AND ( ( @lv_filter_changed_by = @lv_false_indicator
                AND @lv_order_changed_by = @lv_blank_order_changed_by )
              OR aufk_row~aenam = @lv_order_changed_by )
            AND ( @lv_required_phase = @lv_blank_required_phase
              OR ( @lv_required_phase = '1'
                AND aufk_row~phas1 = @lv_true_indicator )
              OR ( @lv_required_phase = '2'
                AND aufk_row~phas2 = @lv_true_indicator )
              OR ( @lv_required_phase = '3'
                AND aufk_row~phas3 = @lv_true_indicator ) )
            AND ( @lv_created_date_from = @lv_blank_created_date
              OR aufk_row~erdat BETWEEN @lv_created_date_from
                AND @lv_created_date_to )
            AND ( @lv_changed_date_from = @lv_blank_changed_date
              OR aufk_row~aedat BETWEEN @lv_changed_date_from
                AND @lv_changed_date_to )
            AND ( @lv_exclude_deleted = @lv_false_indicator
              OR ( aufk_row~loekz = @lv_blank_deletion_indicator
                AND afpo_row~xloek = @lv_blank_deletion_indicator ) )
            AND ( @lv_receipt_expected_only = @lv_false_indicator
              OR afpo_row~wepos = @lv_true_indicator )
            AND ( @lv_receipt_not_expected_only = @lv_false_indicator
              OR afpo_row~wepos = @lv_blank_receipt_expected )
            AND ( @lv_delivery_complete_only = @lv_false_indicator
              OR afpo_row~elikz = @lv_true_indicator )
            AND ( @lv_delivery_not_complete_only = @lv_false_indicator
              OR afpo_row~elikz = @lv_blank_delivery_complete )
            AND ( ( @lv_filter_basic_start_date = @lv_false_indicator
                AND @lv_basic_start_date = @lv_blank_basic_start_date )
              OR afko_row~gstrp = @lv_basic_start_date )
            AND ( @lv_basic_start_date_from =
              @lv_blank_basic_start_date
              OR afko_row~gstrp BETWEEN @lv_basic_start_date_from
                AND @lv_basic_start_date_to )
            AND ( afko_row~gltrp > @is_selection-after_finish_date
              OR ( afko_row~gltrp = @is_selection-after_finish_date
                AND afpo_row~aufnr > @is_selection-after_order ) )
          ORDER BY basic_finish_date, production_order
          INTO TABLE @rt_order_keys
          UP TO @lv_fetch_limit ROWS.
      ENDIF.
    ELSE.
      IF is_selection-after_finish_date IS INITIAL.
        SELECT DISTINCT afpo_row~aufnr AS production_order,
               afko_row~gltrp AS basic_finish_date,
               afko_row~gstrp AS basic_start_date,
               afko_row~gstrs AS scheduled_start_date,
               afko_row~gltrs AS scheduled_finish_date,
               afko_row~gsuzs AS scheduled_start_time,
               afko_row~gluzs AS scheduled_finish_time
          FROM afpo AS afpo_row
          INNER JOIN afko AS afko_row
            ON afko_row~aufnr = afpo_row~aufnr
          INNER JOIN aufk AS aufk_row
            ON aufk_row~aufnr = afpo_row~aufnr
          LEFT OUTER JOIN prps AS prps_row
            ON prps_row~pspnr = afpo_row~projn
          INNER JOIN jest AS jest_row
            ON jest_row~objnr = aufk_row~objnr
          WHERE afpo_row~matnr = @is_selection-material
            AND afpo_row~werks = @is_selection-plant
            AND ( ( @lv_filter_planning_plant = @lv_false_indicator
                AND @lv_planning_plant = @lv_blank_planning_plant )
              OR afpo_row~pwerk = @lv_planning_plant )
            AND ( ( @lv_filter_delivery_plant = @lv_false_indicator
                AND @lv_delivery_plant = @lv_blank_delivery_plant )
              OR afpo_row~dwerk = @lv_delivery_plant )
            AND ( ( @lv_filter_special_stock = @lv_false_indicator
                AND @lv_special_stock_indicator = @lv_blank_special_stock )
              OR afpo_row~sobkz = @lv_special_stock_indicator )
            AND ( ( @lv_filter_stock_type = @lv_false_indicator
                AND @lv_stock_type = @lv_blank_stock_type )
              OR afpo_row~insmk = @lv_stock_type )
            AND ( ( @lv_filter_goods_recipient = @lv_false_indicator
                AND @lv_goods_recipient = @lv_blank_goods_recipient )
              OR afpo_row~wempf = @lv_goods_recipient )
            AND ( ( @lv_filter_unloading_point = @lv_false_indicator
                AND @lv_unloading_point = @lv_blank_unloading_point )
              OR afpo_row~ablad = @lv_unloading_point )
            AND ( ( @lv_filter_production_version = @lv_false_indicator
                AND @lv_production_version = @lv_blank_production_version )
              OR afpo_row~verid = @lv_production_version )
            AND ( ( @lv_filter_plan_start_date = @lv_false_indicator
                AND @lv_planned_order_start_date = @lv_blank_plan_start_date )
              OR afpo_row~strmp = @lv_planned_order_start_date )
            AND ( ( @lv_filter_sales_order = @lv_false_indicator
                AND @lv_sales_order = @lv_blank_sales_order )
              OR afpo_row~kdauf = @lv_sales_order )
            AND ( ( @lv_filter_sales_order_item = @lv_false_indicator
                AND @lv_sales_order_item = @lv_blank_sales_order_item )
              OR afpo_row~kdpos = @lv_sales_order_item )
            AND ( ( @lv_filter_sales_schedule_line = @lv_false_indicator
                AND @lv_sales_order_schedule_line = @lv_blank_sales_schedule_line )
              OR afpo_row~kdein = @lv_sales_order_schedule_line )
            AND ( ( @lv_filter_planned_order = @lv_false_indicator
                AND @lv_planned_order = @lv_blank_planned_order )
              OR afpo_row~plnum = @lv_planned_order )
            AND ( ( @lv_filter_storage_location = @lv_false_indicator
                AND @lv_storage_location = @lv_blank_storage_location )
              OR afpo_row~lgort = @lv_storage_location )
            AND ( ( @lv_filter_batch = @lv_false_indicator
                AND @lv_batch = @lv_blank_batch )
              OR afpo_row~charg = @lv_batch )
            AND ( ( @lv_filter_assignment_category = @lv_false_indicator
                AND @lv_account_assignment_category = @lv_blank_assignment_category )
              OR afpo_row~knttp = @lv_account_assignment_category )
            AND ( ( @lv_filter_mrp_area = @lv_false_indicator
                AND @lv_mrp_area = @lv_blank_mrp_area )
              OR afpo_row~berid = @lv_mrp_area )
            AND ( ( @lv_filter_wbs_element = @lv_false_indicator
                AND @lv_wbs_element = @lv_blank_wbs_element )
              OR ( @lv_wbs_element = @lv_blank_wbs_element
                AND afpo_row~projn = @lv_blank_wbs_internal_id )
              OR prps_row~posid = @lv_wbs_element )
            AND ( @lv_production_item = @lv_blank_production_item
              OR afpo_row~posnr = @lv_production_item )
            AND ( @lv_order_unit = @lv_blank_order_unit
              OR afpo_row~amein = @lv_order_unit )
            AND ( @lv_unreceived_quantity_only = @lv_false_indicator
              OR afpo_row~psmng > afpo_row~wemng )
            AND ( @lv_filter_order_qty_from = @lv_false_indicator
              OR afpo_row~psmng >= @lv_order_qty_from )
            AND ( @lv_filter_order_qty_to = @lv_false_indicator
              OR afpo_row~psmng <= @lv_order_qty_to )
            AND ( @lv_filter_unreceived_qty_from =
                @lv_false_indicator
              OR ( afpo_row~psmng > afpo_row~wemng
                AND afpo_row~psmng - afpo_row~wemng >=
                  @lv_unreceived_qty_from ) )
            AND ( @lv_filter_unreceived_qty_to =
                @lv_false_indicator
              OR ( afpo_row~psmng > afpo_row~wemng
                AND afpo_row~psmng - afpo_row~wemng <=
                  @lv_unreceived_qty_to ) )
            AND afko_row~gltrp BETWEEN @is_selection-finish_date_from
              AND @is_selection-finish_date_to
            AND ( ( @lv_filter_sched_start_date = @lv_false_indicator
                AND @lv_sched_start_date = @lv_blank_scheduled_start_date )
              OR afko_row~gstrs = @lv_sched_start_date )
            AND ( @lv_scheduled_start_date_from =
              @lv_blank_scheduled_start_date
              OR afko_row~gstrs BETWEEN @lv_scheduled_start_date_from
                AND @lv_scheduled_start_date_to )
            AND ( @lv_filter_scheduled_start_time = @lv_false_indicator
              OR afko_row~gsuzs BETWEEN @lv_scheduled_start_time_from
                AND @lv_scheduled_start_time_to )
            AND ( ( @lv_filter_sched_finish_date =
                @lv_false_indicator
                AND @lv_sched_finish_date =
                  @lv_blank_scheduled_finish_date )
              OR afko_row~gltrs = @lv_sched_finish_date )
            AND ( @lv_scheduled_finish_date_from =
              @lv_blank_scheduled_finish_date
              OR afko_row~gltrs BETWEEN @lv_scheduled_finish_date_from
                AND @lv_scheduled_finish_date_to )
            AND ( @lv_filter_sched_finish_time = @lv_false_indicator
              OR afko_row~gluzs BETWEEN @lv_scheduled_finish_time_from
                AND @lv_scheduled_finish_time_to )
            AND ( aufk_row~autyp = '10' OR aufk_row~autyp = '40' )
            AND ( @lv_order_category = @lv_blank_order_category
              OR aufk_row~autyp = @lv_order_category )
            AND ( @lv_order_type = @lv_blank_order_type
              OR aufk_row~auart = @lv_order_type )
            AND ( ( @lv_filter_order_description =
                @lv_false_indicator
                AND @lv_order_description = @lv_blank_order_description )
              OR aufk_row~ktext = @lv_order_description )
            AND ( ( @lv_filter_created_by = @lv_false_indicator
                AND @lv_order_created_by = @lv_blank_order_created_by )
              OR aufk_row~ernam = @lv_order_created_by )
            AND ( ( @lv_filter_changed_by = @lv_false_indicator
                AND @lv_order_changed_by = @lv_blank_order_changed_by )
              OR aufk_row~aenam = @lv_order_changed_by )
            AND ( @lv_required_phase = @lv_blank_required_phase
              OR ( @lv_required_phase = '1'
                AND aufk_row~phas1 = @lv_true_indicator )
              OR ( @lv_required_phase = '2'
                AND aufk_row~phas2 = @lv_true_indicator )
              OR ( @lv_required_phase = '3'
                AND aufk_row~phas3 = @lv_true_indicator ) )
            AND ( @lv_created_date_from = @lv_blank_created_date
              OR aufk_row~erdat BETWEEN @lv_created_date_from
                AND @lv_created_date_to )
            AND ( @lv_changed_date_from = @lv_blank_changed_date
              OR aufk_row~aedat BETWEEN @lv_changed_date_from
                AND @lv_changed_date_to )
            AND ( @lv_exclude_deleted = @lv_false_indicator
              OR ( aufk_row~loekz = @lv_blank_deletion_indicator
                AND afpo_row~xloek = @lv_blank_deletion_indicator ) )
            AND ( @lv_receipt_expected_only = @lv_false_indicator
              OR afpo_row~wepos = @lv_true_indicator )
            AND ( @lv_receipt_not_expected_only = @lv_false_indicator
              OR afpo_row~wepos = @lv_blank_receipt_expected )
            AND ( @lv_delivery_complete_only = @lv_false_indicator
              OR afpo_row~elikz = @lv_true_indicator )
            AND ( @lv_delivery_not_complete_only = @lv_false_indicator
              OR afpo_row~elikz = @lv_blank_delivery_complete )
            AND ( ( @lv_filter_basic_start_date = @lv_false_indicator
                AND @lv_basic_start_date = @lv_blank_basic_start_date )
              OR afko_row~gstrp = @lv_basic_start_date )
            AND ( @lv_basic_start_date_from =
              @lv_blank_basic_start_date
              OR afko_row~gstrp BETWEEN @lv_basic_start_date_from
                AND @lv_basic_start_date_to )
            AND jest_row~stat = @is_selection-active_status_code
            AND jest_row~inact = @lv_active_indicator
          ORDER BY basic_finish_date, production_order
          INTO TABLE @rt_order_keys
          UP TO @lv_fetch_limit ROWS.
      ELSE.
        SELECT DISTINCT afpo_row~aufnr AS production_order,
               afko_row~gltrp AS basic_finish_date,
               afko_row~gstrp AS basic_start_date,
               afko_row~gstrs AS scheduled_start_date,
               afko_row~gltrs AS scheduled_finish_date,
               afko_row~gsuzs AS scheduled_start_time,
               afko_row~gluzs AS scheduled_finish_time
          FROM afpo AS afpo_row
          INNER JOIN afko AS afko_row
            ON afko_row~aufnr = afpo_row~aufnr
          INNER JOIN aufk AS aufk_row
            ON aufk_row~aufnr = afpo_row~aufnr
          LEFT OUTER JOIN prps AS prps_row
            ON prps_row~pspnr = afpo_row~projn
          INNER JOIN jest AS jest_row
            ON jest_row~objnr = aufk_row~objnr
          WHERE afpo_row~matnr = @is_selection-material
            AND afpo_row~werks = @is_selection-plant
            AND ( ( @lv_filter_planning_plant = @lv_false_indicator
                AND @lv_planning_plant = @lv_blank_planning_plant )
              OR afpo_row~pwerk = @lv_planning_plant )
            AND ( ( @lv_filter_delivery_plant = @lv_false_indicator
                AND @lv_delivery_plant = @lv_blank_delivery_plant )
              OR afpo_row~dwerk = @lv_delivery_plant )
            AND ( ( @lv_filter_special_stock = @lv_false_indicator
                AND @lv_special_stock_indicator = @lv_blank_special_stock )
              OR afpo_row~sobkz = @lv_special_stock_indicator )
            AND ( ( @lv_filter_stock_type = @lv_false_indicator
                AND @lv_stock_type = @lv_blank_stock_type )
              OR afpo_row~insmk = @lv_stock_type )
            AND ( ( @lv_filter_goods_recipient = @lv_false_indicator
                AND @lv_goods_recipient = @lv_blank_goods_recipient )
              OR afpo_row~wempf = @lv_goods_recipient )
            AND ( ( @lv_filter_unloading_point = @lv_false_indicator
                AND @lv_unloading_point = @lv_blank_unloading_point )
              OR afpo_row~ablad = @lv_unloading_point )
            AND ( ( @lv_filter_production_version = @lv_false_indicator
                AND @lv_production_version = @lv_blank_production_version )
              OR afpo_row~verid = @lv_production_version )
            AND ( ( @lv_filter_plan_start_date = @lv_false_indicator
                AND @lv_planned_order_start_date = @lv_blank_plan_start_date )
              OR afpo_row~strmp = @lv_planned_order_start_date )
            AND ( ( @lv_filter_sales_order = @lv_false_indicator
                AND @lv_sales_order = @lv_blank_sales_order )
              OR afpo_row~kdauf = @lv_sales_order )
            AND ( ( @lv_filter_sales_order_item = @lv_false_indicator
                AND @lv_sales_order_item = @lv_blank_sales_order_item )
              OR afpo_row~kdpos = @lv_sales_order_item )
            AND ( ( @lv_filter_sales_schedule_line = @lv_false_indicator
                AND @lv_sales_order_schedule_line = @lv_blank_sales_schedule_line )
              OR afpo_row~kdein = @lv_sales_order_schedule_line )
            AND ( ( @lv_filter_planned_order = @lv_false_indicator
                AND @lv_planned_order = @lv_blank_planned_order )
              OR afpo_row~plnum = @lv_planned_order )
            AND ( ( @lv_filter_storage_location = @lv_false_indicator
                AND @lv_storage_location = @lv_blank_storage_location )
              OR afpo_row~lgort = @lv_storage_location )
            AND ( ( @lv_filter_batch = @lv_false_indicator
                AND @lv_batch = @lv_blank_batch )
              OR afpo_row~charg = @lv_batch )
            AND ( ( @lv_filter_assignment_category = @lv_false_indicator
                AND @lv_account_assignment_category = @lv_blank_assignment_category )
              OR afpo_row~knttp = @lv_account_assignment_category )
            AND ( ( @lv_filter_mrp_area = @lv_false_indicator
                AND @lv_mrp_area = @lv_blank_mrp_area )
              OR afpo_row~berid = @lv_mrp_area )
            AND ( ( @lv_filter_wbs_element = @lv_false_indicator
                AND @lv_wbs_element = @lv_blank_wbs_element )
              OR ( @lv_wbs_element = @lv_blank_wbs_element
                AND afpo_row~projn = @lv_blank_wbs_internal_id )
              OR prps_row~posid = @lv_wbs_element )
            AND ( @lv_production_item = @lv_blank_production_item
              OR afpo_row~posnr = @lv_production_item )
            AND ( @lv_order_unit = @lv_blank_order_unit
              OR afpo_row~amein = @lv_order_unit )
            AND ( @lv_unreceived_quantity_only = @lv_false_indicator
              OR afpo_row~psmng > afpo_row~wemng )
            AND ( @lv_filter_order_qty_from = @lv_false_indicator
              OR afpo_row~psmng >= @lv_order_qty_from )
            AND ( @lv_filter_order_qty_to = @lv_false_indicator
              OR afpo_row~psmng <= @lv_order_qty_to )
            AND ( @lv_filter_unreceived_qty_from =
                @lv_false_indicator
              OR ( afpo_row~psmng > afpo_row~wemng
                AND afpo_row~psmng - afpo_row~wemng >=
                  @lv_unreceived_qty_from ) )
            AND ( @lv_filter_unreceived_qty_to =
                @lv_false_indicator
              OR ( afpo_row~psmng > afpo_row~wemng
                AND afpo_row~psmng - afpo_row~wemng <=
                  @lv_unreceived_qty_to ) )
            AND afko_row~gltrp BETWEEN @is_selection-finish_date_from
              AND @is_selection-finish_date_to
            AND ( ( @lv_filter_sched_start_date = @lv_false_indicator
                AND @lv_sched_start_date = @lv_blank_scheduled_start_date )
              OR afko_row~gstrs = @lv_sched_start_date )
            AND ( @lv_scheduled_start_date_from =
              @lv_blank_scheduled_start_date
              OR afko_row~gstrs BETWEEN @lv_scheduled_start_date_from
                AND @lv_scheduled_start_date_to )
            AND ( @lv_filter_scheduled_start_time = @lv_false_indicator
              OR afko_row~gsuzs BETWEEN @lv_scheduled_start_time_from
                AND @lv_scheduled_start_time_to )
            AND ( ( @lv_filter_sched_finish_date =
                @lv_false_indicator
                AND @lv_sched_finish_date =
                  @lv_blank_scheduled_finish_date )
              OR afko_row~gltrs = @lv_sched_finish_date )
            AND ( @lv_scheduled_finish_date_from =
              @lv_blank_scheduled_finish_date
              OR afko_row~gltrs BETWEEN @lv_scheduled_finish_date_from
                AND @lv_scheduled_finish_date_to )
            AND ( @lv_filter_sched_finish_time = @lv_false_indicator
              OR afko_row~gluzs BETWEEN @lv_scheduled_finish_time_from
                AND @lv_scheduled_finish_time_to )
            AND ( aufk_row~autyp = '10' OR aufk_row~autyp = '40' )
            AND ( @lv_order_category = @lv_blank_order_category
              OR aufk_row~autyp = @lv_order_category )
            AND ( @lv_order_type = @lv_blank_order_type
              OR aufk_row~auart = @lv_order_type )
            AND ( ( @lv_filter_order_description =
                @lv_false_indicator
                AND @lv_order_description = @lv_blank_order_description )
              OR aufk_row~ktext = @lv_order_description )
            AND ( ( @lv_filter_created_by = @lv_false_indicator
                AND @lv_order_created_by = @lv_blank_order_created_by )
              OR aufk_row~ernam = @lv_order_created_by )
            AND ( ( @lv_filter_changed_by = @lv_false_indicator
                AND @lv_order_changed_by = @lv_blank_order_changed_by )
              OR aufk_row~aenam = @lv_order_changed_by )
            AND ( @lv_required_phase = @lv_blank_required_phase
              OR ( @lv_required_phase = '1'
                AND aufk_row~phas1 = @lv_true_indicator )
              OR ( @lv_required_phase = '2'
                AND aufk_row~phas2 = @lv_true_indicator )
              OR ( @lv_required_phase = '3'
                AND aufk_row~phas3 = @lv_true_indicator ) )
            AND ( @lv_created_date_from = @lv_blank_created_date
              OR aufk_row~erdat BETWEEN @lv_created_date_from
                AND @lv_created_date_to )
            AND ( @lv_changed_date_from = @lv_blank_changed_date
              OR aufk_row~aedat BETWEEN @lv_changed_date_from
                AND @lv_changed_date_to )
            AND ( @lv_exclude_deleted = @lv_false_indicator
              OR ( aufk_row~loekz = @lv_blank_deletion_indicator
                AND afpo_row~xloek = @lv_blank_deletion_indicator ) )
            AND ( @lv_receipt_expected_only = @lv_false_indicator
              OR afpo_row~wepos = @lv_true_indicator )
            AND ( @lv_receipt_not_expected_only = @lv_false_indicator
              OR afpo_row~wepos = @lv_blank_receipt_expected )
            AND ( @lv_delivery_complete_only = @lv_false_indicator
              OR afpo_row~elikz = @lv_true_indicator )
            AND ( @lv_delivery_not_complete_only = @lv_false_indicator
              OR afpo_row~elikz = @lv_blank_delivery_complete )
            AND ( ( @lv_filter_basic_start_date = @lv_false_indicator
                AND @lv_basic_start_date = @lv_blank_basic_start_date )
              OR afko_row~gstrp = @lv_basic_start_date )
            AND ( @lv_basic_start_date_from =
              @lv_blank_basic_start_date
              OR afko_row~gstrp BETWEEN @lv_basic_start_date_from
                AND @lv_basic_start_date_to )
            AND jest_row~stat = @is_selection-active_status_code
            AND jest_row~inact = @lv_active_indicator
            AND ( afko_row~gltrp > @is_selection-after_finish_date
              OR ( afko_row~gltrp = @is_selection-after_finish_date
                AND afpo_row~aufnr > @is_selection-after_order ) )
          ORDER BY basic_finish_date, production_order
          INTO TABLE @rt_order_keys
          UP TO @lv_fetch_limit ROWS.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD zif_prod_order_read_repo~read_order_statuses.
    TYPES:
      BEGIN OF ty_order_status_header,
        aufnr TYPE aufk-aufnr,
        objnr TYPE aufk-objnr,
        stsma TYPE aufk-stsma,
      END OF ty_order_status_header,
      ty_order_status_headers TYPE HASHED TABLE OF ty_order_status_header
        WITH UNIQUE KEY aufnr,
      BEGIN OF ty_active_order_status,
        objnr TYPE jest-objnr,
        stat  TYPE jest-stat,
      END OF ty_active_order_status,
      ty_active_order_statuses TYPE SORTED TABLE OF
        ty_active_order_status WITH NON-UNIQUE KEY objnr.
    DATA lt_order_headers TYPE ty_order_status_headers.
    DATA lt_active_statuses TYPE ty_active_order_statuses.
    DATA lv_active TYPE jest-inact.

    IF it_production_orders IS INITIAL.
      RETURN.
    ENDIF.

    SELECT aufnr,
           objnr,
           stsma
      FROM aufk
      FOR ALL ENTRIES IN @it_production_orders
      WHERE aufnr = @it_production_orders-table_line
        AND ( autyp = '10' OR autyp = '40' )
      INTO CORRESPONDING FIELDS OF TABLE @lt_order_headers.

    IF lt_order_headers IS INITIAL.
      RETURN.
    ENDIF.

    SELECT objnr,
           stat
      FROM jest
      FOR ALL ENTRIES IN @lt_order_headers
      WHERE objnr = @lt_order_headers-objnr
        AND inact = @lv_active
      INTO CORRESPONDING FIELDS OF TABLE @lt_active_statuses.

    LOOP AT lt_order_headers INTO DATA(ls_order_header).
      LOOP AT lt_active_statuses INTO DATA(ls_active_status)
          WHERE objnr = ls_order_header-objnr.
        APPEND VALUE #(
          production_order = ls_order_header-aufnr
          status_profile   = ls_order_header-stsma
          status_code      = ls_active_status-stat ) TO rt_statuses.
      ENDLOOP.
    ENDLOOP.

    IF rt_statuses IS INITIAL.
      RETURN.
    ENDIF.

    TYPES:
      BEGIN OF ty_system_status_text,
        status_code       TYPE tj02t-istat,
        status_short_name TYPE tj02t-txt04,
        status_name       TYPE tj02t-txt30,
      END OF ty_system_status_text.
    TYPES ty_system_status_texts TYPE HASHED TABLE OF
      ty_system_status_text WITH UNIQUE KEY status_code.
    TYPES:
      BEGIN OF ty_user_status_text,
        status_profile    TYPE tj30t-stsma,
        status_code       TYPE tj30t-estat,
        status_short_name TYPE tj30t-txt04,
        status_name       TYPE tj30t-txt30,
      END OF ty_user_status_text.
    TYPES ty_user_status_texts TYPE HASHED TABLE OF
      ty_user_status_text WITH UNIQUE KEY status_profile status_code.
    DATA lt_system_texts TYPE ty_system_status_texts.
    DATA lt_user_texts TYPE ty_user_status_texts.

    SELECT istat AS status_code,
           txt04 AS status_short_name,
           txt30 AS status_name
      FROM tj02t
      FOR ALL ENTRIES IN @rt_statuses
      WHERE istat = @rt_statuses-status_code
        AND spras = @sy-langu
      INTO TABLE @lt_system_texts.

    SELECT stsma AS status_profile,
           estat AS status_code,
           txt04 AS status_short_name,
           txt30 AS status_name
      FROM tj30t
      FOR ALL ENTRIES IN @rt_statuses
      WHERE stsma = @rt_statuses-status_profile
        AND estat = @rt_statuses-status_code
        AND spras = @sy-langu
      INTO TABLE @lt_user_texts.

    LOOP AT rt_statuses ASSIGNING FIELD-SYMBOL(<ls_status>).
      IF <ls_status>-status_code(1) = 'E'.
        <ls_status>-is_user_status = abap_true.
        READ TABLE lt_user_texts INTO DATA(ls_user_text)
          WITH TABLE KEY
            status_profile = <ls_status>-status_profile
            status_code = <ls_status>-status_code.
        IF sy-subrc = 0.
          <ls_status>-status_short_name =
            ls_user_text-status_short_name.
          <ls_status>-status_name = ls_user_text-status_name.
        ENDIF.
      ELSE.
        READ TABLE lt_system_texts INTO DATA(ls_system_text)
          WITH TABLE KEY status_code = <ls_status>-status_code.
        IF sy-subrc = 0.
          <ls_status>-status_short_name =
            ls_system_text-status_short_name.
          <ls_status>-status_name = ls_system_text-status_name.
        ENDIF.
      ENDIF.
    ENDLOOP.

    SORT rt_statuses BY production_order status_code.
  ENDMETHOD.

  METHOD zif_prod_order_read_repo~read_confirmations.
    TYPES:
      BEGIN OF ty_confirmation_data,
        aufnr TYPE afru-aufnr,
        aufpl TYPE afru-aufpl,
        aplzl TYPE afru-aplzl,
        rueck TYPE afru-rueck,
        rmzhl TYPE afru-rmzhl,
        ernam TYPE afru-ernam,
        ersda TYPE afru-ersda,
        erzet TYPE afru-erzet,
        aenam TYPE afru-aenam,
        laeda TYPE afru-laeda,
        budat TYPE afru-budat,
        lmnga TYPE afru-lmnga,
        rmnga TYPE afru-rmnga,
        xmnga TYPE afru-xmnga,
        meinh TYPE afru-meinh,
        aueru TYPE afru-aueru,
        stokz TYPE afru-stokz,
      END OF ty_confirmation_data,
      ty_confirmation_rows TYPE STANDARD TABLE OF ty_confirmation_data
        WITH EMPTY KEY,
      BEGIN OF ty_operation_confirmation_key,
        aufpl TYPE afvc-aufpl,
        aplzl TYPE afvc-aplzl,
        vornr TYPE afvc-vornr,
        plnfl TYPE afvc-plnfl,
        uvorn TYPE afvc-uvorn,
        ltxa1 TYPE afvc-ltxa1,
        steus TYPE afvc-steus,
      END OF ty_operation_confirmation_key,
      ty_operation_confirmation_keys TYPE HASHED TABLE OF
        ty_operation_confirmation_key WITH UNIQUE KEY aufpl aplzl,
      BEGIN OF ty_confirmation_order_key,
        aufnr TYPE aufk-aufnr,
        autyp TYPE aufk-autyp,
      END OF ty_confirmation_order_key,
      ty_confirmation_order_keys TYPE HASHED TABLE OF
        ty_confirmation_order_key WITH UNIQUE KEY aufnr.
    DATA lt_afru TYPE ty_confirmation_rows.
    DATA lt_afvc TYPE ty_operation_confirmation_keys.
    DATA lt_aufk TYPE ty_confirmation_order_keys.
    DATA ls_confirmation TYPE
      zif_prod_order_read_repo=>ty_order_confirmation.

    IF it_production_orders IS INITIAL.
      RETURN.
    ENDIF.

    SELECT aufnr,
           aufpl,
           aplzl,
           rueck,
           rmzhl,
           ernam,
           ersda,
           erzet,
           aenam,
           laeda,
           budat,
           lmnga,
           rmnga,
           xmnga,
           meinh,
           aueru,
           stokz
      FROM afru
      FOR ALL ENTRIES IN @it_production_orders
      WHERE aufnr = @it_production_orders-table_line
      INTO CORRESPONDING FIELDS OF TABLE @lt_afru.

    IF lt_afru IS INITIAL.
      RETURN.
    ENDIF.

    SELECT aufnr,
           autyp
      FROM aufk
      FOR ALL ENTRIES IN @lt_afru
      WHERE aufnr = @lt_afru-aufnr
        AND ( autyp = '10' OR autyp = '40' )
      INTO CORRESPONDING FIELDS OF TABLE @lt_aufk.

    SELECT aufpl,
           aplzl,
           vornr,
           plnfl,
           uvorn,
           ltxa1,
           steus
      FROM afvc
      FOR ALL ENTRIES IN @lt_afru
      WHERE aufpl = @lt_afru-aufpl
        AND aplzl = @lt_afru-aplzl
      INTO CORRESPONDING FIELDS OF TABLE @lt_afvc.

    LOOP AT lt_afru INTO DATA(ls_afru).
      READ TABLE lt_aufk INTO DATA(ls_aufk)
        WITH TABLE KEY aufnr = ls_afru-aufnr.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      READ TABLE lt_afvc INTO DATA(ls_afvc)
        WITH TABLE KEY aufpl = ls_afru-aufpl aplzl = ls_afru-aplzl.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      CLEAR ls_confirmation.
      ls_confirmation-production_order = ls_afru-aufnr.
      ls_confirmation-order_category = ls_aufk-autyp.
      ls_confirmation-operation_counter = ls_afvc-aplzl.
      ls_confirmation-operation_number = ls_afvc-vornr.
      ls_confirmation-operation_sequence = ls_afvc-plnfl.
      ls_confirmation-operation_suboperation = ls_afvc-uvorn.
      ls_confirmation-operation_description = ls_afvc-ltxa1.
      ls_confirmation-control_key = ls_afvc-steus.
      ls_confirmation-confirmation = ls_afru-rueck.
      ls_confirmation-confirmation_counter = ls_afru-rmzhl.
      ls_confirmation-entered_by = ls_afru-ernam.
      ls_confirmation-entry_date = ls_afru-ersda.
      ls_confirmation-entry_time = ls_afru-erzet.
      ls_confirmation-changed_by = ls_afru-aenam.
      ls_confirmation-last_change_date = ls_afru-laeda.
      ls_confirmation-posting_date = ls_afru-budat.
      ls_confirmation-yield_quantity = ls_afru-lmnga.
      ls_confirmation-rework_quantity = ls_afru-rmnga.
      ls_confirmation-scrap_quantity = ls_afru-xmnga.
      ls_confirmation-quantity_unit = ls_afru-meinh.
      ls_confirmation-is_final = ls_afru-aueru.
      ls_confirmation-is_reversed = ls_afru-stokz.
      APPEND ls_confirmation TO rt_confirmations.
    ENDLOOP.

    SORT rt_confirmations BY production_order posting_date DESCENDING
      confirmation DESCENDING confirmation_counter DESCENDING.
  ENDMETHOD.

  METHOD zif_prod_order_read_repo~search_confirmations_by_window.
    DATA lv_fetch_limit TYPE i.
    DATA lv_material TYPE afpo-matnr.
    DATA lv_plant TYPE afpo-werks.
    DATA lv_production_order TYPE afru-aufnr.
    DATA lv_blank_production_order TYPE afru-aufnr.
    DATA lv_order_category TYPE aufk-autyp.
    DATA lv_blank_order_category TYPE aufk-autyp.
    DATA lv_operation_counter TYPE afvc-aplzl.
    DATA lv_blank_operation_counter TYPE afvc-aplzl.
    DATA lv_filter_control_key TYPE abap_bool.
    DATA lv_control_key TYPE afvc-steus.
    DATA lv_blank_control_key TYPE afvc-steus.
    DATA lv_filter_quantity_unit TYPE abap_bool.
    DATA lv_quantity_unit TYPE afru-meinh.
    DATA lv_filter_entered_by TYPE abap_bool.
    DATA lv_entered_by TYPE afru-ernam.
    DATA lv_blank_entered_by TYPE afru-ernam.
    DATA lv_filter_changed_by TYPE abap_bool.
    DATA lv_changed_by TYPE afru-aenam.
    DATA lv_blank_changed_by TYPE afru-aenam.
    DATA lv_blank_quantity_unit TYPE afru-meinh.
    DATA lv_confirmation_number TYPE afru-rueck.
    DATA lv_blank_confirmation_number TYPE afru-rueck.
    DATA lv_confirmation_counter TYPE afru-rmzhl.
    DATA lv_blank_confirmation_counter TYPE afru-rmzhl.
    DATA lv_filter_operation_sequence TYPE abap_bool.
    DATA lv_filter_operation_subop TYPE abap_bool.
    DATA lv_positive_yield_only TYPE abap_bool.
    DATA lv_positive_rework_only TYPE abap_bool.
    DATA lv_positive_scrap_only TYPE abap_bool.
    DATA lv_false_indicator TYPE abap_bool.
    DATA lv_zero_yield_quantity TYPE afru-lmnga.
    DATA lv_zero_rework_quantity TYPE afru-rmnga.
    DATA lv_zero_scrap_quantity TYPE afru-xmnga.
    DATA lv_posting_date_from TYPE afru-budat.
    DATA lv_posting_date_to TYPE afru-budat.
    DATA lv_entry_date_from TYPE afru-ersda.
    DATA lv_entry_date_to TYPE afru-ersda.
    DATA lv_filter_entry_time TYPE abap_bool.
    DATA lv_entry_time_from TYPE afru-erzet.
    DATA lv_entry_time_to TYPE afru-erzet.
    DATA lv_blank_entry_date TYPE afru-ersda.
    DATA lv_last_change_date_from TYPE afru-laeda.
    DATA lv_last_change_date_to TYPE afru-laeda.
    DATA lv_blank_last_change_date TYPE afru-laeda.
    DATA lv_after_posting_date TYPE afru-budat.
    DATA lv_after_production_order TYPE afru-aufnr.
    DATA lv_after_confirmation TYPE afru-rueck.
    DATA lv_after_confirmation_counter TYPE afru-rmzhl.
    DATA lr_operation_numbers TYPE RANGE OF afvc-vornr.
    DATA lr_operation_sequences TYPE RANGE OF afvc-plnfl.
    DATA lr_suboperation_numbers TYPE RANGE OF afvc-uvorn.
    DATA lr_final_indicators TYPE RANGE OF afru-aueru.
    DATA lr_reversal_indicators TYPE RANGE OF afru-stokz.

    IF is_selection-maximum_results < 1
        OR is_selection-maximum_results > 500.
      RETURN.
    ENDIF.

    lv_fetch_limit = is_selection-maximum_results + 1.
    lv_material = is_selection-material.
    lv_plant = is_selection-plant.
    lv_production_order = is_selection-production_order.
    lv_order_category = is_selection-order_category.
    lv_operation_counter = is_selection-operation_counter.
    lv_filter_control_key = is_selection-filter_control_key.
    lv_control_key = is_selection-control_key.
    lv_filter_quantity_unit = is_selection-filter_quantity_unit.
    lv_quantity_unit = is_selection-quantity_unit.
    lv_filter_entry_time = is_selection-filter_entry_time.
    lv_entry_time_from = is_selection-entry_time_from.
    lv_entry_time_to = is_selection-entry_time_to.
    lv_filter_entered_by = is_selection-filter_entered_by.
    lv_entered_by = is_selection-entered_by.
    lv_filter_changed_by = is_selection-filter_changed_by.
    lv_changed_by = is_selection-changed_by.
    lv_filter_operation_sequence =
      is_selection-filter_operation_sequence.
    lv_filter_operation_subop =
      is_selection-filter_operation_suboperation.
    lv_confirmation_number = is_selection-confirmation_number.
    lv_confirmation_counter = is_selection-confirmation_counter.
    lv_positive_yield_only = is_selection-positive_yield_only.
    lv_positive_rework_only = is_selection-positive_rework_only.
    lv_positive_scrap_only = is_selection-positive_scrap_only.
    lv_posting_date_from = is_selection-posting_date_from.
    lv_posting_date_to = is_selection-posting_date_to.
    lv_entry_date_from = is_selection-entry_date_from.
    lv_entry_date_to = is_selection-entry_date_to.
    lv_last_change_date_from = is_selection-last_change_date_from.
    lv_last_change_date_to = is_selection-last_change_date_to.
    lv_after_posting_date = is_selection-after_posting_date.
    lv_after_production_order = is_selection-after_production_order.
    lv_after_confirmation = is_selection-after_confirmation.
    lv_after_confirmation_counter =
      is_selection-after_confirmation_counter.
    IF is_selection-operation_number IS INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'BT'
        low    = '0000'
        high   = '9999' ) TO lr_operation_numbers.
    ELSE.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = is_selection-operation_number ) TO lr_operation_numbers.
    ENDIF.
    IF is_selection-operation_sequence IS INITIAL
        AND lv_filter_operation_sequence = lv_false_indicator.
      APPEND VALUE #(
        sign   = 'I'
        option = 'BT'
        low    = '000000'
        high   = '999999' ) TO lr_operation_sequences.
    ELSE.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = is_selection-operation_sequence )
        TO lr_operation_sequences.
    ENDIF.
    IF is_selection-operation_suboperation IS INITIAL
        AND lv_filter_operation_subop = lv_false_indicator.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = space ) TO lr_suboperation_numbers.
      APPEND VALUE #(
        sign   = 'I'
        option = 'BT'
        low    = '0000'
        high   = '9999' ) TO lr_suboperation_numbers.
    ELSE.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = is_selection-operation_suboperation )
        TO lr_suboperation_numbers.
    ENDIF.

    IF is_selection-final_only = abap_true.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = abap_true ) TO lr_final_indicators.
    ELSEIF is_selection-partial_only = abap_true.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = abap_false ) TO lr_final_indicators.
    ELSE.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = abap_false ) TO lr_final_indicators.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = abap_true ) TO lr_final_indicators.
    ENDIF.

    IF is_selection-exclude_reversed = abap_true.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = abap_false ) TO lr_reversal_indicators.
    ELSEIF is_selection-reversed_only = abap_true.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = abap_true ) TO lr_reversal_indicators.
    ELSE.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = abap_false ) TO lr_reversal_indicators.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = abap_true ) TO lr_reversal_indicators.
    ENDIF.
    IF is_selection-after_posting_date IS INITIAL.
      SELECT DISTINCT afru_row~aufnr AS production_order,
             afpo_row~matnr AS scope_material,
             afpo_row~werks AS scope_plant,
             aufk_row~autyp AS order_category,
             afvc_row~aplzl AS operation_counter,
             afvc_row~vornr AS operation_number,
             afvc_row~plnfl AS operation_sequence,
             afvc_row~uvorn AS operation_suboperation,
             afvc_row~ltxa1 AS operation_description,
             afvc_row~steus AS control_key,
             afru_row~rueck AS confirmation,
             afru_row~rmzhl AS confirmation_counter,
             afru_row~ernam AS entered_by,
             afru_row~ersda AS entry_date,
             afru_row~erzet AS entry_time,
             afru_row~aenam AS changed_by,
             afru_row~laeda AS last_change_date,
             afru_row~budat AS posting_date,
             afru_row~lmnga AS yield_quantity,
             afru_row~rmnga AS rework_quantity,
             afru_row~xmnga AS scrap_quantity,
             afru_row~meinh AS quantity_unit,
             afru_row~aueru AS is_final,
             afru_row~stokz AS is_reversed
        FROM afru AS afru_row
        INNER JOIN afvc AS afvc_row
          ON afvc_row~aufpl = afru_row~aufpl
          AND afvc_row~aplzl = afru_row~aplzl
        INNER JOIN afpo AS afpo_row
          ON afpo_row~aufnr = afru_row~aufnr
        INNER JOIN aufk AS aufk_row
          ON aufk_row~aufnr = afru_row~aufnr
        WHERE afpo_row~matnr = @lv_material
          AND afpo_row~werks = @lv_plant
          AND ( @lv_production_order = @lv_blank_production_order
            OR afru_row~aufnr = @lv_production_order )
          AND afvc_row~vornr IN @lr_operation_numbers
          AND afvc_row~plnfl IN @lr_operation_sequences
          AND afvc_row~uvorn IN @lr_suboperation_numbers
          AND ( ( @lv_filter_control_key = @lv_false_indicator
              AND @lv_control_key = @lv_blank_control_key )
            OR afvc_row~steus = @lv_control_key )
          AND ( ( @lv_filter_quantity_unit = @lv_false_indicator
              AND @lv_quantity_unit = @lv_blank_quantity_unit )
            OR afru_row~meinh = @lv_quantity_unit )
          AND ( ( @lv_filter_entered_by = @lv_false_indicator
              AND @lv_entered_by = @lv_blank_entered_by )
            OR afru_row~ernam = @lv_entered_by )
          AND ( ( @lv_filter_changed_by = @lv_false_indicator
              AND @lv_changed_by = @lv_blank_changed_by )
            OR afru_row~aenam = @lv_changed_by )
          AND ( @lv_confirmation_number =
              @lv_blank_confirmation_number
            OR afru_row~rueck = @lv_confirmation_number )
          AND ( @lv_confirmation_counter =
              @lv_blank_confirmation_counter
            OR afru_row~rmzhl = @lv_confirmation_counter )
          AND afru_row~budat BETWEEN @lv_posting_date_from
            AND @lv_posting_date_to
          AND ( @lv_entry_date_from = @lv_blank_entry_date
            OR afru_row~ersda BETWEEN @lv_entry_date_from
              AND @lv_entry_date_to )
          AND ( @lv_filter_entry_time = @lv_false_indicator
            OR afru_row~erzet BETWEEN @lv_entry_time_from
              AND @lv_entry_time_to )
          AND ( @lv_last_change_date_from =
              @lv_blank_last_change_date
            OR afru_row~laeda BETWEEN @lv_last_change_date_from
              AND @lv_last_change_date_to )
          AND ( aufk_row~autyp = '10' OR aufk_row~autyp = '40' )
          AND ( @lv_order_category = @lv_blank_order_category
            OR aufk_row~autyp = @lv_order_category )
          AND ( @lv_operation_counter = @lv_blank_operation_counter
            OR afvc_row~aplzl = @lv_operation_counter )
          AND afru_row~aueru IN @lr_final_indicators
          AND afru_row~stokz IN @lr_reversal_indicators
          AND ( @lv_positive_rework_only = @lv_false_indicator
            OR afru_row~rmnga > @lv_zero_rework_quantity )
          AND ( @lv_positive_yield_only = @lv_false_indicator
            OR afru_row~lmnga > @lv_zero_yield_quantity )
          AND ( @lv_positive_scrap_only = @lv_false_indicator
            OR afru_row~xmnga > @lv_zero_scrap_quantity )
        ORDER BY posting_date, production_order, confirmation,
          confirmation_counter
        INTO TABLE @rt_confirmations
        UP TO @lv_fetch_limit ROWS.
    ELSE.
      SELECT DISTINCT afru_row~aufnr AS production_order,
             afpo_row~matnr AS scope_material,
             afpo_row~werks AS scope_plant,
             aufk_row~autyp AS order_category,
             afvc_row~aplzl AS operation_counter,
             afvc_row~vornr AS operation_number,
             afvc_row~plnfl AS operation_sequence,
             afvc_row~uvorn AS operation_suboperation,
             afvc_row~ltxa1 AS operation_description,
             afvc_row~steus AS control_key,
             afru_row~rueck AS confirmation,
             afru_row~rmzhl AS confirmation_counter,
             afru_row~ernam AS entered_by,
             afru_row~ersda AS entry_date,
             afru_row~erzet AS entry_time,
             afru_row~aenam AS changed_by,
             afru_row~laeda AS last_change_date,
             afru_row~budat AS posting_date,
             afru_row~lmnga AS yield_quantity,
             afru_row~rmnga AS rework_quantity,
             afru_row~xmnga AS scrap_quantity,
             afru_row~meinh AS quantity_unit,
             afru_row~aueru AS is_final,
             afru_row~stokz AS is_reversed
        FROM afru AS afru_row
        INNER JOIN afvc AS afvc_row
          ON afvc_row~aufpl = afru_row~aufpl
          AND afvc_row~aplzl = afru_row~aplzl
        INNER JOIN afpo AS afpo_row
          ON afpo_row~aufnr = afru_row~aufnr
        INNER JOIN aufk AS aufk_row
          ON aufk_row~aufnr = afru_row~aufnr
        WHERE afpo_row~matnr = @lv_material
          AND afpo_row~werks = @lv_plant
          AND ( @lv_production_order = @lv_blank_production_order
            OR afru_row~aufnr = @lv_production_order )
          AND afvc_row~vornr IN @lr_operation_numbers
          AND afvc_row~plnfl IN @lr_operation_sequences
          AND afvc_row~uvorn IN @lr_suboperation_numbers
          AND ( ( @lv_filter_control_key = @lv_false_indicator
              AND @lv_control_key = @lv_blank_control_key )
            OR afvc_row~steus = @lv_control_key )
          AND ( ( @lv_filter_quantity_unit = @lv_false_indicator
              AND @lv_quantity_unit = @lv_blank_quantity_unit )
            OR afru_row~meinh = @lv_quantity_unit )
          AND ( ( @lv_filter_entered_by = @lv_false_indicator
              AND @lv_entered_by = @lv_blank_entered_by )
            OR afru_row~ernam = @lv_entered_by )
          AND ( ( @lv_filter_changed_by = @lv_false_indicator
              AND @lv_changed_by = @lv_blank_changed_by )
            OR afru_row~aenam = @lv_changed_by )
          AND ( @lv_confirmation_number =
              @lv_blank_confirmation_number
            OR afru_row~rueck = @lv_confirmation_number )
          AND ( @lv_confirmation_counter =
              @lv_blank_confirmation_counter
            OR afru_row~rmzhl = @lv_confirmation_counter )
          AND afru_row~budat BETWEEN @lv_posting_date_from
            AND @lv_posting_date_to
          AND ( @lv_entry_date_from = @lv_blank_entry_date
            OR afru_row~ersda BETWEEN @lv_entry_date_from
              AND @lv_entry_date_to )
          AND ( @lv_filter_entry_time = @lv_false_indicator
            OR afru_row~erzet BETWEEN @lv_entry_time_from
              AND @lv_entry_time_to )
          AND ( @lv_last_change_date_from =
              @lv_blank_last_change_date
            OR afru_row~laeda BETWEEN @lv_last_change_date_from
              AND @lv_last_change_date_to )
          AND ( aufk_row~autyp = '10' OR aufk_row~autyp = '40' )
          AND ( @lv_order_category = @lv_blank_order_category
            OR aufk_row~autyp = @lv_order_category )
          AND ( @lv_operation_counter = @lv_blank_operation_counter
            OR afvc_row~aplzl = @lv_operation_counter )
          AND afru_row~aueru IN @lr_final_indicators
          AND afru_row~stokz IN @lr_reversal_indicators
          AND ( @lv_positive_rework_only = @lv_false_indicator
            OR afru_row~rmnga > @lv_zero_rework_quantity )
          AND ( @lv_positive_yield_only = @lv_false_indicator
            OR afru_row~lmnga > @lv_zero_yield_quantity )
          AND ( @lv_positive_scrap_only = @lv_false_indicator
            OR afru_row~xmnga > @lv_zero_scrap_quantity )
          AND ( afru_row~budat > @lv_after_posting_date
            OR ( afru_row~budat = @lv_after_posting_date
              AND afru_row~aufnr > @lv_after_production_order )
            OR ( afru_row~budat = @lv_after_posting_date
              AND afru_row~aufnr = @lv_after_production_order
              AND afru_row~rueck > @lv_after_confirmation )
            OR ( afru_row~budat = @lv_after_posting_date
              AND afru_row~aufnr = @lv_after_production_order
              AND afru_row~rueck = @lv_after_confirmation
              AND afru_row~rmzhl >
                @lv_after_confirmation_counter ) )
        ORDER BY posting_date, production_order, confirmation,
          confirmation_counter
        INTO TABLE @rt_confirmations
        UP TO @lv_fetch_limit ROWS.
    ENDIF.
  ENDMETHOD.

  METHOD zif_prod_order_read_repo~read_operations.
    TYPES:
      BEGIN OF ty_operation_order,
        aufnr TYPE aufk-aufnr,
        autyp TYPE aufk-autyp,
      END OF ty_operation_order,
      ty_operation_orders TYPE HASHED TABLE OF ty_operation_order
        WITH UNIQUE KEY aufnr,
      BEGIN OF ty_order_routing,
        aufnr TYPE afko-aufnr,
        aufpl TYPE afko-aufpl,
      END OF ty_order_routing,
      ty_order_routings TYPE SORTED TABLE OF ty_order_routing
        WITH NON-UNIQUE KEY aufpl,
      BEGIN OF ty_operation_data,
        aufpl TYPE afvc-aufpl,
        aplzl TYPE afvc-aplzl,
        plnfl TYPE afvc-plnfl,
        vornr TYPE afvc-vornr,
        uvorn TYPE afvc-uvorn,
        ltxa1 TYPE afvc-ltxa1,
        steus TYPE afvc-steus,
      END OF ty_operation_data,
      ty_operation_rows TYPE STANDARD TABLE OF ty_operation_data
        WITH EMPTY KEY.
    DATA lt_aufk TYPE ty_operation_orders.
    DATA lt_afko TYPE ty_order_routings.
    DATA lt_afvc TYPE ty_operation_rows.
    DATA ls_operation TYPE zif_prod_order_read_repo=>ty_order_operation.

    IF it_production_orders IS INITIAL.
      RETURN.
    ENDIF.

    SELECT aufnr,
           autyp
      FROM aufk
      FOR ALL ENTRIES IN @it_production_orders
      WHERE aufnr = @it_production_orders-table_line
        AND ( autyp = '10' OR autyp = '40' )
      INTO CORRESPONDING FIELDS OF TABLE @lt_aufk.

    IF lt_aufk IS INITIAL.
      RETURN.
    ENDIF.

    SELECT aufnr,
           aufpl
      FROM afko
      FOR ALL ENTRIES IN @lt_aufk
      WHERE aufnr = @lt_aufk-aufnr
      INTO CORRESPONDING FIELDS OF TABLE @lt_afko.

    IF lt_afko IS INITIAL.
      RETURN.
    ENDIF.

    SELECT aufpl,
           aplzl,
           plnfl,
           vornr,
           uvorn,
           ltxa1,
           steus
      FROM afvc
      FOR ALL ENTRIES IN @lt_afko
      WHERE aufpl = @lt_afko-aufpl
      INTO CORRESPONDING FIELDS OF TABLE @lt_afvc.

    LOOP AT lt_afvc INTO DATA(ls_afvc).
      LOOP AT lt_afko INTO DATA(ls_afko)
          WHERE aufpl = ls_afvc-aufpl.
        READ TABLE lt_aufk TRANSPORTING NO FIELDS
          WITH TABLE KEY aufnr = ls_afko-aufnr.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        CLEAR ls_operation.
        ls_operation-production_order = ls_afko-aufnr.
        ls_operation-operation_counter = ls_afvc-aplzl.
        ls_operation-operation_sequence = ls_afvc-plnfl.
        ls_operation-operation_number = ls_afvc-vornr.
        ls_operation-suboperation_number = ls_afvc-uvorn.
        ls_operation-operation_description = ls_afvc-ltxa1.
        ls_operation-control_key = ls_afvc-steus.
        APPEND ls_operation TO rt_operations.
      ENDLOOP.
    ENDLOOP.

    SORT rt_operations BY production_order operation_sequence
      operation_number suboperation_number operation_counter.
  ENDMETHOD.

ENDCLASS.
