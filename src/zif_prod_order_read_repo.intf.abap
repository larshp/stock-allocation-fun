INTERFACE zif_prod_order_read_repo PUBLIC.

  TYPES ty_order_number TYPE aufk-aufnr.
  TYPES ty_order_numbers TYPE STANDARD TABLE OF ty_order_number
    WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_finish_search_key,
      production_order      TYPE ty_order_number,
      basic_start_date      TYPE afko-gstrp,
      basic_finish_date     TYPE afko-gltrp,
      scheduled_start_date  TYPE afko-gstrs,
      scheduled_finish_date TYPE afko-gltrs,
      scheduled_start_time  TYPE afko-gsuzs,
      scheduled_finish_time TYPE afko-gluzs,
    END OF ty_finish_search_key.
  TYPES ty_finish_search_keys TYPE STANDARD TABLE OF
    ty_finish_search_key WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_order_selection,
      material                       TYPE afpo-matnr,
      plant                          TYPE afpo-werks,
      filter_planning_plant          TYPE abap_bool,
      planning_plant                 TYPE afpo-pwerk,
      filter_delivery_plant          TYPE abap_bool,
      delivery_plant                 TYPE afpo-dwerk,
      filter_special_stock           TYPE abap_bool,
      special_stock_indicator        TYPE afpo-sobkz,
      filter_stock_type              TYPE abap_bool,
      stock_type                     TYPE afpo-insmk,
      filter_goods_recipient         TYPE abap_bool,
      goods_recipient                TYPE afpo-wempf,
      filter_unloading_point         TYPE abap_bool,
      unloading_point                TYPE afpo-ablad,
      filter_production_version      TYPE abap_bool,
      production_version             TYPE afpo-verid,
      filter_plan_start_date         TYPE abap_bool,
      planned_order_start_date       TYPE afpo-strmp,
      filter_sales_order             TYPE abap_bool,
      sales_order                    TYPE afpo-kdauf,
      filter_sales_order_item        TYPE abap_bool,
      sales_order_item               TYPE afpo-kdpos,
      filter_sales_schedule_line     TYPE abap_bool,
      sales_order_schedule_line      TYPE afpo-kdein,
      filter_storage_location        TYPE abap_bool,
      storage_location               TYPE afpo-lgort,
      filter_batch                   TYPE abap_bool,
      batch                          TYPE afpo-charg,
      filter_assignment_category     TYPE abap_bool,
      account_assignment_category    TYPE afpo-knttp,
      filter_mrp_area                TYPE abap_bool,
      mrp_area                       TYPE afpo-berid,
      filter_wbs_element             TYPE abap_bool,
      wbs_element                    TYPE prps-posid,
      filter_planned_order           TYPE abap_bool,
      planned_order                  TYPE afpo-plnum,
      production_item                TYPE afpo-posnr,
      order_unit                     TYPE afpo-amein,
      basic_start_date_from          TYPE afko-gstrp,
      basic_start_date_to            TYPE afko-gstrp,
      filter_basic_start_date        TYPE abap_bool,
      basic_start_date               TYPE afko-gstrp,
      scheduled_start_date_from      TYPE afko-gstrs,
      scheduled_start_date_to        TYPE afko-gstrs,
      filter_scheduled_start_date    TYPE abap_bool,
      scheduled_start_date           TYPE afko-gstrs,
      filter_scheduled_start_time    TYPE abap_bool,
      scheduled_start_time_from      TYPE afko-gsuzs,
      scheduled_start_time_to        TYPE afko-gsuzs,
      scheduled_finish_date_from     TYPE afko-gltrs,
      scheduled_finish_date_to       TYPE afko-gltrs,
      filter_scheduled_finish_date   TYPE abap_bool,
      scheduled_finish_date          TYPE afko-gltrs,
      filter_scheduled_finish_time   TYPE abap_bool,
      scheduled_finish_time_from     TYPE afko-gluzs,
      scheduled_finish_time_to       TYPE afko-gluzs,
      finish_date_from               TYPE afko-gltrp,
      finish_date_to                 TYPE afko-gltrp,
      after_finish_date              TYPE afko-gltrp,
      after_order                    TYPE ty_order_number,
      order_category                 TYPE aufk-autyp,
      order_type                     TYPE aufk-auart,
      filter_order_description       TYPE abap_bool,
      order_description              TYPE aufk-ktext,
      order_created_by               TYPE aufk-ernam,
      filter_order_created_by        TYPE abap_bool,
      created_date_from              TYPE aufk-erdat,
      created_date_to                TYPE aufk-erdat,
      order_changed_by               TYPE aufk-aenam,
      filter_order_changed_by        TYPE abap_bool,
      changed_date_from              TYPE aufk-aedat,
      changed_date_to                TYPE aufk-aedat,
      required_phase                 TYPE c LENGTH 1,
      exclude_deleted                TYPE abap_bool,
      receipt_expected_only          TYPE abap_bool,
      receipt_not_expected_only      TYPE abap_bool,
      delivery_complete_only         TYPE abap_bool,
      delivery_not_complete_only     TYPE abap_bool,
      active_status_code             TYPE jest-stat,
      active_status_codes            TYPE STANDARD TABLE OF jest-stat
        WITH EMPTY KEY,
      unreceived_quantity_only       TYPE abap_bool,
      filter_receipt_progress_status TYPE abap_bool,
      receipt_progress_status        TYPE c LENGTH 1,
      filter_order_qty_from          TYPE abap_bool,
      order_qty_from                 TYPE afpo-psmng,
      filter_order_qty_to            TYPE abap_bool,
      order_qty_to                   TYPE afpo-psmng,
      filter_order_qty_base_from     TYPE abap_bool,
      order_qty_base_from            TYPE decfloat34,
      filter_order_qty_base_to       TYPE abap_bool,
      order_qty_base_to              TYPE decfloat34,
      filter_received_qty_from       TYPE abap_bool,
      received_qty_from              TYPE afpo-wemng,
      filter_received_qty_to         TYPE abap_bool,
      received_qty_to                TYPE afpo-wemng,
      filter_over_receipt_qty_from   TYPE abap_bool,
      over_receipt_qty_from          TYPE afpo-wemng,
      filter_over_receipt_qty_to     TYPE abap_bool,
      over_receipt_qty_to            TYPE afpo-wemng,
      filter_over_receipt_pct_from   TYPE abap_bool,
      over_receipt_pct_from          TYPE p LENGTH 8 DECIMALS 2,
      filter_over_receipt_pct_to     TYPE abap_bool,
      over_receipt_pct_to            TYPE p LENGTH 8 DECIMALS 2,
      filter_received_qty_base_from  TYPE abap_bool,
      received_qty_base_from         TYPE decfloat34,
      filter_received_qty_base_to    TYPE abap_bool,
      received_qty_base_to           TYPE decfloat34,
      filter_over_rcpt_qty_base_from TYPE abap_bool,
      over_rcpt_qty_base_from        TYPE decfloat34,
      filter_over_rcpt_qty_base_to   TYPE abap_bool,
      over_rcpt_qty_base_to          TYPE decfloat34,
      filter_unrecv_qty_base_from    TYPE abap_bool,
      unrecv_qty_base_from           TYPE decfloat34,
      filter_unrecv_qty_base_to      TYPE abap_bool,
      unrecv_qty_base_to             TYPE decfloat34,
      filter_received_pct_from       TYPE abap_bool,
      received_pct_from              TYPE p LENGTH 8 DECIMALS 2,
      filter_received_pct_to         TYPE abap_bool,
      received_pct_to                TYPE p LENGTH 8 DECIMALS 2,
      filter_unreceived_qty_from     TYPE abap_bool,
      unreceived_qty_from            TYPE afpo-psmng,
      filter_unreceived_qty_to       TYPE abap_bool,
      unreceived_qty_to              TYPE afpo-psmng,
      filter_unreceived_pct_from     TYPE abap_bool,
      unreceived_pct_from            TYPE p LENGTH 8 DECIMALS 2,
      filter_unreceived_pct_to       TYPE abap_bool,
      unreceived_pct_to              TYPE p LENGTH 8 DECIMALS 2,
      maximum_results                TYPE i,
    END OF ty_order_selection.
  TYPES:
    BEGIN OF ty_order_item,
      production_order            TYPE afpo-aufnr,
      production_item             TYPE afpo-posnr,
      sales_order                 TYPE afpo-kdauf,
      sales_order_item            TYPE afpo-kdpos,
      sales_order_schedule_line   TYPE afpo-kdein,
      storage_location            TYPE afpo-lgort,
      batch                       TYPE afpo-charg,
      account_assignment_category TYPE afpo-knttp,
      mrp_area                    TYPE afpo-berid,
      wbs_element                 TYPE prps-posid,
      wbs_element_internal_id     TYPE afpo-projn,
      planned_order               TYPE afpo-plnum,
      order_category              TYPE aufk-autyp,
      order_type                  TYPE aufk-auart,
      order_description           TYPE aufk-ktext,
      order_created_by            TYPE aufk-ernam,
      created_date                TYPE aufk-erdat,
      order_changed_by            TYPE aufk-aenam,
      changed_date                TYPE aufk-aedat,
      material                    TYPE afpo-matnr,
      plant                       TYPE afpo-werks,
      planning_plant              TYPE afpo-pwerk,
      delivery_plant              TYPE afpo-dwerk,
      special_stock_indicator     TYPE afpo-sobkz,
      stock_type                  TYPE afpo-insmk,
      goods_recipient             TYPE afpo-wempf,
      unloading_point             TYPE afpo-ablad,
      production_version          TYPE afpo-verid,
      planned_order_start_date    TYPE afpo-strmp,
      order_unit                  TYPE afpo-amein,
      base_unit                   TYPE afpo-meins,
      basic_start_date            TYPE afko-gstrp,
      basic_finish_date           TYPE afko-gltrp,
      scheduled_start_date        TYPE afko-gstrs,
      scheduled_finish_date       TYPE afko-gltrs,
      scheduled_start_time        TYPE afko-gsuzs,
      scheduled_finish_time       TYPE afko-gluzs,
      order_quantity              TYPE afpo-psmng,
      received_quantity           TYPE afpo-wemng,
      order_to_base_numerator     TYPE afpo-umrez,
      order_to_base_denominator   TYPE afpo-umren,
      phase_1_indicator           TYPE aufk-phas1,
      phase_2_indicator           TYPE aufk-phas2,
      phase_3_indicator           TYPE aufk-phas3,
      order_deletion_indicator    TYPE aufk-loekz,
      receipt_expected            TYPE afpo-wepos,
      item_deletion_indicator     TYPE afpo-xloek,
      delivery_complete           TYPE afpo-elikz,
    END OF ty_order_item.
  TYPES ty_order_items TYPE STANDARD TABLE OF ty_order_item WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_order_status,
      production_order  TYPE ty_order_number,
      status_code       TYPE jest-stat,
      status_profile    TYPE aufk-stsma,
      is_user_status    TYPE abap_bool,
      status_short_name TYPE tj02t-txt04,
      status_name       TYPE tj02t-txt30,
    END OF ty_order_status.
  TYPES ty_order_statuses TYPE STANDARD TABLE OF ty_order_status
    WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_order_confirmation,
      production_order         TYPE afru-aufnr,
      scope_material           TYPE afpo-matnr,
      scope_plant              TYPE afpo-werks,
      order_category           TYPE aufk-autyp,
      order_type               TYPE aufk-auart,
      order_deletion_indicator TYPE aufk-loekz,
      operation_counter        TYPE afvc-aplzl,
      operation_number         TYPE afvc-vornr,
      operation_sequence       TYPE afvc-plnfl,
      operation_suboperation   TYPE afvc-uvorn,
      operation_description    TYPE afvc-ltxa1,
      control_key              TYPE afvc-steus,
      resource_object_id       TYPE afvc-arbid,
      work_center              TYPE crhd-arbpl,
      work_center_plant        TYPE crhd-werks,
      confirmation             TYPE afru-rueck,
      confirmation_counter     TYPE afru-rmzhl,
      entered_by               TYPE afru-ernam,
      entry_date               TYPE afru-ersda,
      entry_time               TYPE afru-erzet,
      changed_by               TYPE afru-aenam,
      last_change_date         TYPE afru-laeda,
      posting_date             TYPE afru-budat,
      execution_start_date     TYPE afru-isdd,
      execution_start_time     TYPE afru-isdz,
      execution_finish_date    TYPE afru-iedd,
      execution_finish_time    TYPE afru-iedz,
      exec_duration_status     TYPE c LENGTH 1,
      exec_duration_issue_code TYPE c LENGTH 2,
      exec_duration_seconds    TYPE decfloat34,
      yield_quantity           TYPE afru-lmnga,
      rework_quantity          TYPE afru-rmnga,
      scrap_quantity           TYPE afru-xmnga,
      quantity_unit            TYPE afru-meinh,
      is_final                 TYPE afru-aueru,
      is_reversed              TYPE afru-stokz,
    END OF ty_order_confirmation.
  TYPES ty_order_confirmations TYPE STANDARD TABLE OF
    ty_order_confirmation WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_confirmation_window_selection,
      material                      TYPE afpo-matnr,
      plant                         TYPE afpo-werks,
      production_order              TYPE ty_order_number,
      order_category                TYPE aufk-autyp,
      order_type                    TYPE aufk-auart,
      filter_order_type             TYPE abap_bool,
      exclude_deleted               TYPE abap_bool,
      operation_number              TYPE afvc-vornr,
      operation_number_from         TYPE afvc-vornr,
      operation_number_to           TYPE afvc-vornr,
      operation_counter             TYPE afvc-aplzl,
      operation_counter_from        TYPE afvc-aplzl,
      operation_counter_to          TYPE afvc-aplzl,
      filter_operation_sequence     TYPE abap_bool,
      operation_sequence            TYPE afvc-plnfl,
      operation_sequence_from       TYPE afvc-plnfl,
      operation_sequence_to         TYPE afvc-plnfl,
      filter_operation_suboperation TYPE abap_bool,
      operation_suboperation        TYPE afvc-uvorn,
      operation_suboperation_from   TYPE afvc-uvorn,
      operation_suboperation_to     TYPE afvc-uvorn,
      filter_control_key            TYPE abap_bool,
      control_key                   TYPE afvc-steus,
      filter_operation_description  TYPE abap_bool,
      operation_description         TYPE afvc-ltxa1,
      filter_resource_object_id     TYPE abap_bool,
      resource_object_id            TYPE afvc-arbid,
      filter_work_center            TYPE abap_bool,
      work_center                   TYPE crhd-arbpl,
      filter_work_center_plant      TYPE abap_bool,
      work_center_plant             TYPE crhd-werks,
      filter_quantity_unit          TYPE abap_bool,
      quantity_unit                 TYPE afru-meinh,
      filter_entered_by             TYPE abap_bool,
      entered_by                    TYPE afru-ernam,
      filter_changed_by             TYPE abap_bool,
      changed_by                    TYPE afru-aenam,
      confirmation_number           TYPE afru-rueck,
      confirmation_counter          TYPE afru-rmzhl,
      confirmation_counter_from     TYPE afru-rmzhl,
      confirmation_counter_to       TYPE afru-rmzhl,
      posting_date_from             TYPE afru-budat,
      posting_date_to               TYPE afru-budat,
      entry_date_from               TYPE afru-ersda,
      entry_date_to                 TYPE afru-ersda,
      filter_entry_time             TYPE abap_bool,
      entry_time_from               TYPE afru-erzet,
      entry_time_to                 TYPE afru-erzet,
      last_change_date_from         TYPE afru-laeda,
      last_change_date_to           TYPE afru-laeda,
      execution_start_date_from     TYPE afru-isdd,
      execution_start_date_to       TYPE afru-isdd,
      filter_execution_start_time   TYPE abap_bool,
      execution_start_time_from     TYPE afru-isdz,
      execution_start_time_to       TYPE afru-isdz,
      execution_finish_date_from    TYPE afru-iedd,
      execution_finish_date_to      TYPE afru-iedd,
      filter_execution_finish_time  TYPE abap_bool,
      execution_finish_time_from    TYPE afru-iedz,
      execution_finish_time_to      TYPE afru-iedz,
      exclude_reversed              TYPE abap_bool,
      reversed_only                 TYPE abap_bool,
      positive_yield_only           TYPE abap_bool,
      positive_rework_only          TYPE abap_bool,
      positive_scrap_only           TYPE abap_bool,
      filter_yield_quantity_from    TYPE abap_bool,
      yield_quantity_from           TYPE afru-lmnga,
      filter_yield_quantity_to      TYPE abap_bool,
      yield_quantity_to             TYPE afru-lmnga,
      filter_rework_quantity_from   TYPE abap_bool,
      rework_quantity_from          TYPE afru-rmnga,
      filter_rework_quantity_to     TYPE abap_bool,
      rework_quantity_to            TYPE afru-rmnga,
      filter_scrap_quantity_from    TYPE abap_bool,
      scrap_quantity_from           TYPE afru-xmnga,
      filter_scrap_quantity_to      TYPE abap_bool,
      scrap_quantity_to             TYPE afru-xmnga,
      final_only                    TYPE abap_bool,
      partial_only                  TYPE abap_bool,
      after_posting_date            TYPE afru-budat,
      after_production_order        TYPE ty_order_number,
      after_confirmation            TYPE afru-rueck,
      after_confirmation_counter    TYPE afru-rmzhl,
      maximum_results               TYPE i,
    END OF ty_confirmation_window_selection.
  TYPES:
    BEGIN OF ty_confirmation_page_selection,
      maximum_results            TYPE i,
      has_cursor                 TYPE abap_bool,
      after_production_order     TYPE afru-aufnr,
      after_posting_date         TYPE afru-budat,
      after_confirmation         TYPE afru-rueck,
      after_confirmation_counter TYPE afru-rmzhl,
    END OF ty_confirmation_page_selection.
  TYPES:
    BEGIN OF ty_order_operation,
      production_order      TYPE afko-aufnr,
      order_category        TYPE aufk-autyp,
      order_type            TYPE aufk-auart,
      operation_counter     TYPE afvc-aplzl,
      operation_sequence    TYPE afvc-plnfl,
      operation_number      TYPE afvc-vornr,
      suboperation_number   TYPE afvc-uvorn,
      operation_description TYPE afvc-ltxa1,
      control_key           TYPE afvc-steus,
      resource_object_id    TYPE afvc-arbid,
      work_center           TYPE crhd-arbpl,
      work_center_plant     TYPE crhd-werks,
    END OF ty_order_operation.
  TYPES ty_order_operations TYPE STANDARD TABLE OF ty_order_operation
    WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_operation_page_selection,
      maximum_results           TYPE i,
      has_cursor                TYPE abap_bool,
      after_production_order    TYPE aufk-aufnr,
      after_operation_sequence  TYPE afvc-plnfl,
      after_operation_number    TYPE afvc-vornr,
      after_suboperation_number TYPE afvc-uvorn,
      after_operation_counter   TYPE afvc-aplzl,
    END OF ty_operation_page_selection.

  METHODS read_orders
    IMPORTING
      it_production_orders  TYPE ty_order_numbers
    RETURNING
      VALUE(rt_order_items) TYPE ty_order_items.

  METHODS read_orders_by_finish_window
    IMPORTING
      is_selection         TYPE ty_order_selection
    RETURNING
      VALUE(rt_order_keys) TYPE ty_finish_search_keys.

  METHODS read_order_statuses
    IMPORTING
      it_production_orders TYPE ty_order_numbers
    RETURNING
      VALUE(rt_statuses)   TYPE ty_order_statuses.

  METHODS read_confirmations
    IMPORTING
      it_production_orders           TYPE ty_order_numbers
      iv_order_category              TYPE aufk-autyp OPTIONAL
      iv_order_type                  TYPE aufk-auart OPTIONAL
      iv_operation_counter           TYPE afvc-aplzl OPTIONAL
      iv_operation_counter_from      TYPE afvc-aplzl OPTIONAL
      iv_operation_counter_to        TYPE afvc-aplzl OPTIONAL
      iv_operation_number            TYPE afvc-vornr OPTIONAL
      iv_operation_number_from       TYPE afvc-vornr OPTIONAL
      iv_operation_number_to         TYPE afvc-vornr OPTIONAL
      iv_filter_control_key          TYPE abap_bool OPTIONAL
      iv_control_key                 TYPE afvc-steus OPTIONAL
      iv_filter_op_description       TYPE abap_bool OPTIONAL
      iv_operation_description       TYPE afvc-ltxa1 OPTIONAL
      iv_filter_resource_object_id   TYPE abap_bool OPTIONAL
      iv_resource_object_id          TYPE afvc-arbid OPTIONAL
      iv_filter_work_center          TYPE abap_bool OPTIONAL
      iv_work_center                 TYPE crhd-arbpl OPTIONAL
      iv_filter_work_center_plant    TYPE abap_bool OPTIONAL
      iv_work_center_plant           TYPE crhd-werks OPTIONAL
      iv_filter_operation_sequence   TYPE abap_bool OPTIONAL
      iv_operation_sequence          TYPE afvc-plnfl OPTIONAL
      iv_operation_sequence_from     TYPE afvc-plnfl OPTIONAL
      iv_operation_sequence_to       TYPE afvc-plnfl OPTIONAL
      iv_filter_suboperation_number  TYPE abap_bool OPTIONAL
      iv_suboperation_number         TYPE afvc-uvorn OPTIONAL
      iv_suboperation_number_from    TYPE afvc-uvorn OPTIONAL
      iv_suboperation_number_to      TYPE afvc-uvorn OPTIONAL
      iv_confirmation_number         TYPE afru-rueck OPTIONAL
      iv_confirmation_counter        TYPE afru-rmzhl OPTIONAL
      iv_posting_date_from           TYPE afru-budat OPTIONAL
      iv_posting_date_to             TYPE afru-budat OPTIONAL
      iv_entry_date_from             TYPE afru-ersda OPTIONAL
      iv_entry_date_to               TYPE afru-ersda OPTIONAL
      iv_execution_start_date_from   TYPE afru-isdd OPTIONAL
      iv_execution_start_date_to     TYPE afru-isdd OPTIONAL
      iv_execution_finish_date_from  TYPE afru-iedd OPTIONAL
      iv_execution_finish_date_to    TYPE afru-iedd OPTIONAL
      iv_filter_execution_start_time TYPE abap_bool OPTIONAL
      iv_execution_start_time_from   TYPE afru-isdz OPTIONAL
      iv_execution_start_time_to     TYPE afru-isdz OPTIONAL
      iv_filter_exec_finish_time     TYPE abap_bool OPTIONAL
      iv_execution_finish_time_from  TYPE afru-iedz OPTIONAL
      iv_execution_finish_time_to    TYPE afru-iedz OPTIONAL
      iv_filter_entry_time           TYPE abap_bool OPTIONAL
      iv_entry_time_from             TYPE afru-erzet OPTIONAL
      iv_entry_time_to               TYPE afru-erzet OPTIONAL
      iv_filter_entered_by           TYPE abap_bool OPTIONAL
      iv_entered_by                  TYPE afru-ernam OPTIONAL
      iv_filter_changed_by           TYPE abap_bool OPTIONAL
      iv_changed_by                  TYPE afru-aenam OPTIONAL
      iv_last_change_date_from       TYPE afru-laeda OPTIONAL
      iv_last_change_date_to         TYPE afru-laeda OPTIONAL
      iv_filter_quantity_unit        TYPE abap_bool OPTIONAL
      iv_quantity_unit               TYPE afru-meinh OPTIONAL
      iv_positive_yield_only         TYPE abap_bool OPTIONAL
      iv_positive_rework_only        TYPE abap_bool OPTIONAL
      iv_positive_scrap_only         TYPE abap_bool OPTIONAL
      iv_filter_yield_quantity_from  TYPE abap_bool OPTIONAL
      iv_yield_quantity_from         TYPE afru-lmnga OPTIONAL
      iv_filter_yield_quantity_to    TYPE abap_bool OPTIONAL
      iv_yield_quantity_to           TYPE afru-lmnga OPTIONAL
      iv_filter_rework_quantity_from TYPE abap_bool OPTIONAL
      iv_rework_quantity_from        TYPE afru-rmnga OPTIONAL
      iv_filter_rework_quantity_to   TYPE abap_bool OPTIONAL
      iv_rework_quantity_to          TYPE afru-rmnga OPTIONAL
      iv_filter_scrap_quantity_from  TYPE abap_bool OPTIONAL
      iv_scrap_quantity_from         TYPE afru-xmnga OPTIONAL
      iv_filter_scrap_quantity_to    TYPE abap_bool OPTIONAL
      iv_scrap_quantity_to           TYPE afru-xmnga OPTIONAL
      iv_exclude_reversed            TYPE abap_bool OPTIONAL
      iv_reversed_only               TYPE abap_bool OPTIONAL
      iv_final_only                  TYPE abap_bool OPTIONAL
      iv_partial_only                TYPE abap_bool OPTIONAL
      is_page_selection              TYPE ty_confirmation_page_selection OPTIONAL
    RETURNING
      VALUE(rt_confirmations)        TYPE ty_order_confirmations.

  METHODS search_confirmations_by_window
    IMPORTING
      is_selection            TYPE ty_confirmation_window_selection
    RETURNING
      VALUE(rt_confirmations) TYPE ty_order_confirmations.

  METHODS read_operations
    IMPORTING
      it_production_orders          TYPE ty_order_numbers
      iv_filter_resource_object_id  TYPE abap_bool OPTIONAL
      iv_resource_object_id         TYPE afvc-arbid OPTIONAL
      iv_filter_work_center         TYPE abap_bool OPTIONAL
      iv_work_center                TYPE crhd-arbpl OPTIONAL
      iv_filter_work_center_plant   TYPE abap_bool OPTIONAL
      iv_work_center_plant          TYPE crhd-werks OPTIONAL
      iv_filter_control_key         TYPE abap_bool OPTIONAL
      iv_control_key                TYPE afvc-steus OPTIONAL
      iv_filter_op_description      TYPE abap_bool OPTIONAL
      iv_operation_description      TYPE afvc-ltxa1 OPTIONAL
      iv_operation_number           TYPE afvc-vornr OPTIONAL
      iv_operation_number_from      TYPE afvc-vornr OPTIONAL
      iv_operation_number_to        TYPE afvc-vornr OPTIONAL
      iv_operation_counter          TYPE afvc-aplzl OPTIONAL
      iv_operation_counter_from     TYPE afvc-aplzl OPTIONAL
      iv_operation_counter_to       TYPE afvc-aplzl OPTIONAL
      iv_filter_operation_sequence  TYPE abap_bool OPTIONAL
      iv_operation_sequence         TYPE afvc-plnfl OPTIONAL
      iv_operation_sequence_from    TYPE afvc-plnfl OPTIONAL
      iv_operation_sequence_to      TYPE afvc-plnfl OPTIONAL
      iv_filter_suboperation_number TYPE abap_bool OPTIONAL
      iv_suboperation_number        TYPE afvc-uvorn OPTIONAL
      iv_suboperation_number_from   TYPE afvc-uvorn OPTIONAL
      iv_suboperation_number_to     TYPE afvc-uvorn OPTIONAL
      iv_order_category             TYPE aufk-autyp OPTIONAL
      iv_order_type                 TYPE aufk-auart OPTIONAL
      is_page_selection             TYPE ty_operation_page_selection OPTIONAL
    RETURNING
      VALUE(rt_operations)          TYPE ty_order_operations.

ENDINTERFACE.
