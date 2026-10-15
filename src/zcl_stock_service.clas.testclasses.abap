CLASS lcl_stock_uom_repo_double DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_material_uom_repository.
    METHODS set_conversion
      IMPORTING
        iv_base_unit        TYPE mara-meins
        iv_alternative_unit TYPE marm-meinh
        iv_numerator        TYPE marm-umrez
        iv_denominator      TYPE marm-umren.
    METHODS get_read_count
      RETURNING
        VALUE(rv_count) TYPE i.
  PRIVATE SECTION.
    DATA mv_base_unit TYPE mara-meins.
    DATA mv_alternative_unit TYPE marm-meinh.
    DATA ms_ratio TYPE zif_material_uom_repository=>ty_alt_unit_ratio.
    DATA mv_read_count TYPE i.
ENDCLASS.

CLASS lcl_stock_uom_repo_double IMPLEMENTATION.
  METHOD set_conversion.
    mv_base_unit = iv_base_unit.
    mv_alternative_unit = iv_alternative_unit.
    ms_ratio-numerator = iv_numerator.
    ms_ratio-denominator = iv_denominator.
  ENDMETHOD.

  METHOD zif_material_uom_repository~get_base_unit.
    ADD 1 TO mv_read_count.
    rv_base_unit = mv_base_unit.
  ENDMETHOD.

  METHOD zif_material_uom_repository~get_alt_unit_ratio.
    ADD 1 TO mv_read_count.
    IF iv_alternative_unit = mv_alternative_unit.
      rs_ratio = ms_ratio.
    ENDIF.
  ENDMETHOD.

  METHOD get_read_count.
    rv_count = mv_read_count.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_stock_repository_double DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_repository.
    METHODS set_projected_receipts
      IMPORTING
        it_receipts TYPE zif_stock_repository=>ty_projected_receipts.
    METHODS set_stock
      IMPORTING
        iv_quantity TYPE mard-labst.
    METHODS set_date_stock
      IMPORTING
        iv_quantity                 TYPE mard-labst
        iv_date                     TYPE resb-bdter
        iv_material                 TYPE mard-matnr DEFAULT 'MAT-1'
        iv_plant                    TYPE mard-werks DEFAULT '1000'
        iv_receipt_quantity         TYPE mard-labst DEFAULT 0
        iv_sto_in_transit_quantity  TYPE mard-labst DEFAULT 0
        iv_unissued_sto_quantity    TYPE mard-labst DEFAULT 0
        iv_outgoing_sto_quantity    TYPE mard-labst DEFAULT 0
        iv_prod_receipt_quantity    TYPE mard-labst DEFAULT 0
        iv_pr_receipt_quantity      TYPE mard-labst DEFAULT 0
        iv_sto_pr_receipt_quantity  TYPE mard-labst DEFAULT 0
        iv_planned_receipt_quantity TYPE mard-labst DEFAULT 0
        iv_fixed_plan_receipt_qty   TYPE mard-labst DEFAULT 0.
    METHODS set_plant_stock
      IMPORTING
        iv_material TYPE mard-matnr
        iv_plant    TYPE mard-werks
        iv_quantity TYPE mard-labst.
    METHODS set_plant_location_stock
      IMPORTING
        iv_material         TYPE mard-matnr
        iv_plant            TYPE mard-werks
        iv_storage_location TYPE mard-lgort
        iv_quantity         TYPE mard-labst.
    METHODS set_location_stocks
      IMPORTING
        it_stock TYPE zif_stock_repository=>ty_location_stocks.
    METHODS set_batch_stocks
      IMPORTING
        it_stock TYPE zif_stock_repository=>ty_batch_stocks.
    METHODS set_safety_stock
      IMPORTING
        iv_quantity TYPE marc-eisbe.
    METHODS set_stock_status
      IMPORTING
        is_status TYPE zif_stock_repository=>ty_stock_status.
    METHODS set_stock_status_bulk_response
      IMPORTING
        it_status TYPE zif_stock_repository=>ty_stock_status_results.
    METHODS set_sales_order_reservations
      IMPORTING
        it_reservations TYPE zif_stock_repository=>ty_sales_order_reservations.
    METHODS set_location_stock_status
      IMPORTING
        it_status TYPE zif_stock_repository=>ty_stock_status_locations.
    METHODS set_batch_stock_status
      IMPORTING
        it_status TYPE zif_stock_repository=>ty_batch_stock_statuses.
    METHODS get_read_count
      RETURNING
        VALUE(rv_count) TYPE i.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_plant_stock,
        material TYPE mard-matnr,
        plant    TYPE mard-werks,
        quantity TYPE mard-labst,
      END OF ty_plant_stock.
    TYPES ty_plant_stocks TYPE STANDARD TABLE OF ty_plant_stock
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_plant_location_stock,
        material         TYPE mard-matnr,
        plant            TYPE mard-werks,
        storage_location TYPE mard-lgort,
        quantity         TYPE mard-labst,
      END OF ty_plant_location_stock.
    TYPES ty_plant_location_stocks TYPE STANDARD TABLE OF
      ty_plant_location_stock WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_date_stock,
        material                 TYPE mard-matnr,
        plant                    TYPE mard-werks,
        required_date            TYPE resb-bdter,
        available_quantity       TYPE mard-labst,
        receipt_quantity         TYPE mard-labst,
        sto_in_transit_quantity  TYPE mard-labst,
        unissued_sto_quantity    TYPE mard-labst,
        outgoing_sto_quantity    TYPE mard-labst,
        prod_receipt_quantity    TYPE mard-labst,
        pr_receipt_quantity      TYPE mard-labst,
        sto_pr_receipt_quantity  TYPE mard-labst,
        planned_receipt_quantity TYPE mard-labst,
        fixed_plan_receipt_qty   TYPE mard-labst,
      END OF ty_date_stock.
    TYPES ty_date_stocks TYPE STANDARD TABLE OF ty_date_stock
      WITH EMPTY KEY.
    DATA mv_quantity TYPE mard-labst.
    DATA mt_projected_receipts TYPE
      zif_stock_repository=>ty_projected_receipts.
    DATA mt_date_stocks TYPE ty_date_stocks.
    DATA mv_safety_stock TYPE marc-eisbe.
    DATA ms_stock_status TYPE zif_stock_repository=>ty_stock_status.
    DATA mt_bulk_stock_status TYPE
      zif_stock_repository=>ty_stock_status_results.
    DATA mv_use_bulk_status_override TYPE abap_bool.
    DATA mt_location_stock_status TYPE zif_stock_repository=>ty_stock_status_locations.
    DATA mt_batch_stock_status TYPE zif_stock_repository=>ty_batch_stock_statuses.
    DATA mt_sales_order_reservations TYPE
      zif_stock_repository=>ty_sales_order_reservations.
    DATA mv_read_count TYPE i.
    DATA mt_location_stock TYPE zif_stock_repository=>ty_location_stocks.
    DATA mt_batch_stock TYPE zif_stock_repository=>ty_batch_stocks.
    DATA mt_plant_stock TYPE ty_plant_stocks.
    DATA mt_plant_location_stock TYPE ty_plant_location_stocks.
ENDCLASS.

CLASS lcl_stock_repository_double IMPLEMENTATION.
  METHOD set_projected_receipts.
    mt_projected_receipts = it_receipts.
  ENDMETHOD.

  METHOD set_stock.
    mv_quantity = iv_quantity.
    mt_location_stock = VALUE #(
      ( storage_location   = '0001'
        available_quantity = iv_quantity ) ).
  ENDMETHOD.

  METHOD set_date_stock.
    DELETE mt_date_stocks WHERE material = iv_material
      AND plant = iv_plant
      AND required_date = iv_date.
    APPEND VALUE #(
      material                 = iv_material
      plant                    = iv_plant
      required_date            = iv_date
      available_quantity       = iv_quantity
      receipt_quantity         = iv_receipt_quantity
      sto_in_transit_quantity  = iv_sto_in_transit_quantity
      unissued_sto_quantity    = iv_unissued_sto_quantity
      outgoing_sto_quantity    = iv_outgoing_sto_quantity
      prod_receipt_quantity    = iv_prod_receipt_quantity
      pr_receipt_quantity      = iv_pr_receipt_quantity
      sto_pr_receipt_quantity  = iv_sto_pr_receipt_quantity
      planned_receipt_quantity = iv_planned_receipt_quantity
      fixed_plan_receipt_qty   =
        iv_fixed_plan_receipt_qty )
      TO mt_date_stocks.
  ENDMETHOD.

  METHOD set_plant_stock.
    DELETE mt_plant_stock WHERE material = iv_material
      AND plant = iv_plant.
    APPEND VALUE #(
      material = iv_material
      plant    = iv_plant
      quantity = iv_quantity ) TO mt_plant_stock.
    DELETE mt_plant_location_stock WHERE material = iv_material
      AND plant = iv_plant.
    APPEND VALUE #(
      material         = iv_material
      plant            = iv_plant
      storage_location = '0001'
      quantity         = iv_quantity ) TO mt_plant_location_stock.
  ENDMETHOD.

  METHOD set_plant_location_stock.
    DELETE mt_plant_location_stock WHERE material = iv_material
      AND plant = iv_plant
      AND storage_location = iv_storage_location.
    APPEND VALUE #(
      material         = iv_material
      plant            = iv_plant
      storage_location = iv_storage_location
      quantity         = iv_quantity ) TO mt_plant_location_stock.
  ENDMETHOD.

  METHOD set_location_stocks.
    mt_location_stock = it_stock.
    CLEAR mv_quantity.
    LOOP AT it_stock INTO DATA(ls_stock).
      mv_quantity = mv_quantity + ls_stock-available_quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD set_batch_stocks.
    mt_batch_stock = it_stock.
  ENDMETHOD.

  METHOD set_safety_stock.
    mv_safety_stock = iv_quantity.
  ENDMETHOD.

  METHOD set_stock_status.
    ms_stock_status = is_status.
  ENDMETHOD.

  METHOD set_stock_status_bulk_response.
    mt_bulk_stock_status = it_status.
    mv_use_bulk_status_override = abap_true.
  ENDMETHOD.

  METHOD set_sales_order_reservations.
    mt_sales_order_reservations = it_reservations.
  ENDMETHOD.

  METHOD set_location_stock_status.
    mt_location_stock_status = it_status.
  ENDMETHOD.

  METHOD set_batch_stock_status.
    mt_batch_stock_status = it_status.
  ENDMETHOD.

  METHOD get_read_count.
    rv_count = mv_read_count.
  ENDMETHOD.

  METHOD zif_stock_repository~get_unrestricted_stock.
    ADD 1 TO mv_read_count.
    READ TABLE mt_plant_stock INTO DATA(ls_plant_stock)
      WITH KEY material = iv_material
               plant = iv_plant.
    IF sy-subrc = 0.
      rv_quantity = ls_plant_stock-quantity.
    ELSE.
      rv_quantity = mv_quantity.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_repository~get_available_stock_by_date.
    ADD 1 TO mv_read_count.
    READ TABLE mt_date_stocks INTO DATA(ls_date_stock)
      WITH KEY material = iv_material
               plant = iv_plant
               required_date = iv_required_date.
    IF sy-subrc = 0.
      rv_quantity = ls_date_stock-available_quantity.
      IF iv_include_po_receipts = abap_true.
        rv_quantity = rv_quantity + ls_date_stock-receipt_quantity.
      ENDIF.
      IF iv_include_sto_in_transit = abap_true.
        rv_quantity = rv_quantity + ls_date_stock-sto_in_transit_quantity.
      ENDIF.
      IF iv_include_unissued_sto = abap_true.
        rv_quantity = rv_quantity + ls_date_stock-unissued_sto_quantity.
      ENDIF.
      IF iv_subtract_unissued_sto = abap_true.
        rv_quantity = rv_quantity - ls_date_stock-outgoing_sto_quantity.
      ENDIF.
      IF iv_include_prod_receipts = abap_true.
        rv_quantity = rv_quantity + ls_date_stock-prod_receipt_quantity.
      ENDIF.
      IF iv_include_pr_receipts = abap_true.
        rv_quantity = rv_quantity + ls_date_stock-pr_receipt_quantity.
      ENDIF.
      IF iv_include_sto_pr_receipts = abap_true.
        rv_quantity = rv_quantity + ls_date_stock-sto_pr_receipt_quantity.
      ENDIF.
      IF iv_include_planned_receipts = abap_true.
        rv_quantity = rv_quantity + ls_date_stock-planned_receipt_quantity.
      ENDIF.
      IF iv_include_fixed_planned       = abap_true.
        rv_quantity = rv_quantity
          + ls_date_stock-fixed_plan_receipt_qty.
      ENDIF.
      IF iv_include_sched_agmt_receipts = abap_true.
        LOOP AT mt_projected_receipts INTO DATA(ls_sched_agreement_receipt)
            WHERE material = iv_material
              AND plant = iv_plant
              AND receipt_date <= iv_required_date
              AND source_type = 'SCHED_AGREEMENT'.
          rv_quantity = rv_quantity + ls_sched_agreement_receipt-quantity.
        ENDLOOP.
      ENDIF.
      IF rv_quantity < 0.
        CLEAR rv_quantity.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_repository~get_projected_receipts.
    ADD 1 TO mv_read_count.
    LOOP AT mt_projected_receipts INTO DATA(ls_receipt)
        WHERE material = iv_material
          AND plant = iv_plant
          AND receipt_date <= iv_through_date.
      CASE ls_receipt-source_type.
        WHEN 'PO'.
          IF iv_include_po_receipts = abap_true.
            APPEND ls_receipt TO rt_receipts.
          ENDIF.
        WHEN 'STO_IN_TRANSIT'.
          IF iv_include_sto_in_transit = abap_true.
            APPEND ls_receipt TO rt_receipts.
          ENDIF.
        WHEN 'STO_UNISSUED'.
          IF iv_include_unissued_sto = abap_true.
            APPEND ls_receipt TO rt_receipts.
          ENDIF.
        WHEN 'PRODUCTION' OR 'PROCESS_ORDER'.
          IF iv_include_prod_receipts = abap_true.
            APPEND ls_receipt TO rt_receipts.
          ENDIF.
        WHEN 'PR'.
          IF iv_include_pr_receipts = abap_true.
            APPEND ls_receipt TO rt_receipts.
          ENDIF.
        WHEN 'STO_PR'.
          IF iv_include_sto_pr_receipts = abap_true.
            APPEND ls_receipt TO rt_receipts.
          ENDIF.
        WHEN 'PLANNED_ORDER'.
          IF iv_include_planned_receipts = abap_true.
            APPEND ls_receipt TO rt_receipts.
          ENDIF.
        WHEN 'FIXED_PLAN_ORDER'.
          IF iv_include_fixed_planned       = abap_true.
            APPEND ls_receipt TO rt_receipts.
          ENDIF.
        WHEN 'SCHED_AGREEMENT'.
          IF iv_include_sched_agmt_receipts = abap_true.
            APPEND ls_receipt TO rt_receipts.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_po_confirmed_receipts.
    ADD 1 TO mv_read_count.
    LOOP AT mt_projected_receipts INTO DATA(ls_receipt)
        WHERE material = iv_material
          AND plant = iv_plant
          AND receipt_date <= iv_through_date.
      IF ls_receipt-source_type = 'PO'
          OR ls_receipt-source_type = 'PO_CONFIRMATION'.
        APPEND ls_receipt TO rt_receipts.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_safety_stock.
    ADD 1 TO mv_read_count.
    rv_quantity = mv_safety_stock.
  ENDMETHOD.

  METHOD zif_stock_repository~get_sales_order_reservations.
    ADD 1 TO mv_read_count.
    rt_reservations = mt_sales_order_reservations.
  ENDMETHOD.

  METHOD zif_stock_repository~get_order_reservations_bulk.
    ADD 1 TO mv_read_count.
    rt_reservations = mt_sales_order_reservations.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status.
    ADD 1 TO mv_read_count.
    rs_status = ms_stock_status.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status_bulk.
    ADD 1 TO mv_read_count.
    IF mv_use_bulk_status_override = abap_true.
      rt_status = mt_bulk_stock_status.
      RETURN.
    ENDIF.
    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        request_id   = ls_request-request_id
        material     = ls_request-material
        plant        = ls_request-plant
        stock_status = ms_stock_status )
        TO rt_status.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status_by_location.
    ADD 1 TO mv_read_count.
    rt_status = mt_location_stock_status.
  ENDMETHOD.

  METHOD zif_stock_repository~get_location_stock_status_bulk.
    ADD 1 TO mv_read_count.
    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        request_id = ls_request-request_id
        material   = ls_request-material
        plant      = ls_request-plant
        locations  = mt_location_stock_status )
        TO rt_status.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status_by_batch.
    ADD 1 TO mv_read_count.
    rt_status = mt_batch_stock_status.
  ENDMETHOD.

  METHOD zif_stock_repository~get_batch_stock_status_bulk.
    ADD 1 TO mv_read_count.
    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        request_id = ls_request-request_id
        material   = ls_request-material
        plant      = ls_request-plant
        batches    = mt_batch_stock_status )
        TO rt_status.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_by_location.
    ADD 1 TO mv_read_count.
    LOOP AT mt_plant_location_stock INTO DATA(ls_plant_location_stock)
      WHERE material = iv_material
        AND plant = iv_plant.
      APPEND VALUE #(
        storage_location   = ls_plant_location_stock-storage_location
        available_quantity = ls_plant_location_stock-quantity ) TO rt_stock.
    ENDLOOP.
    IF rt_stock IS INITIAL.
      rt_stock = mt_location_stock.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_by_batch.
    ADD 1 TO mv_read_count.
    rt_stock = mt_batch_stock.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_availability_api_double DEFINITION FINAL.
  PUBLIC SECTION.
    TYPES ty_requests TYPE STANDARD TABLE OF
      zif_material_availability_api=>ty_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_result_override,
        call_number TYPE i,
        result      TYPE zif_material_availability_api=>ty_result,
      END OF ty_result_override.
    TYPES ty_result_overrides TYPE STANDARD TABLE OF ty_result_override
      WITH EMPTY KEY.
    INTERFACES zif_material_availability_api.
    METHODS set_result
      IMPORTING
        is_result TYPE zif_material_availability_api=>ty_result.
    METHODS set_result_for_call
      IMPORTING
        iv_call_number TYPE i
        is_result      TYPE zif_material_availability_api=>ty_result.
    METHODS get_requests
      RETURNING
        VALUE(rt_requests) TYPE ty_requests.
    METHODS get_request
      RETURNING
        VALUE(rs_request) TYPE zif_material_availability_api=>ty_request.
    METHODS get_check_count
      RETURNING
        VALUE(rv_count) TYPE i.
  PRIVATE SECTION.
    DATA mt_requests TYPE ty_requests.
    DATA mt_result_overrides TYPE ty_result_overrides.
    DATA ms_result TYPE zif_material_availability_api=>ty_result.
    DATA ms_request TYPE zif_material_availability_api=>ty_request.
    DATA mv_check_count TYPE i.
ENDCLASS.

CLASS lcl_availability_api_double IMPLEMENTATION.
  METHOD set_result.
    ms_result = is_result.
  ENDMETHOD.

  METHOD set_result_for_call.
    APPEND VALUE #(
      call_number = iv_call_number
      result      = is_result ) TO mt_result_overrides.
  ENDMETHOD.

  METHOD get_request.
    rs_request = ms_request.
  ENDMETHOD.

  METHOD get_requests.
    rt_requests = mt_requests.
  ENDMETHOD.

  METHOD get_check_count.
    rv_count = mv_check_count.
  ENDMETHOD.

  METHOD zif_material_availability_api~check_availability.
    ADD 1 TO mv_check_count.
    ms_request = is_request.
    APPEND is_request TO mt_requests.
    READ TABLE mt_result_overrides INTO DATA(ls_override)
      WITH KEY call_number = mv_check_count.
    IF sy-subrc = 0.
      rs_result = ls_override-result.
    ELSE.
      rs_result = ms_result.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_stock_service DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS returns_available_quantity FOR TESTING
      RAISING zcx_invalid_stock_request.
    METHODS rejects_blank_stock_read_keys FOR TESTING.
    METHODS returns_stock_status FOR TESTING
      RAISING zcx_invalid_stock_request.
    METHODS rejects_blank_status_keys FOR TESTING.
    METHODS returns_bulk_stock_status FOR TESTING
      RAISING zcx_invalid_stock_request.
    METHODS rejects_bad_bulk_stock_status FOR TESTING.
    METHODS rejects_bad_bulk_result FOR TESTING.
    METHODS returns_bulk_location_status FOR TESTING
      RAISING zcx_invalid_stock_request.
    METHODS rejects_bad_bulk_location FOR TESTING.
    METHODS rejects_blank_order_res_keys FOR TESTING.
    METHODS returns_order_res_bulk_uom FOR TESTING
      RAISING zcx_invalid_stock_request.
    METHODS rejects_bad_order_res_bulk_uom FOR TESTING.
    METHODS reads_projected_receipts FOR TESTING.
    METHODS returns_proj_po_conf_single FOR TESTING
      RAISING zcx_invalid_stock_request.
    METHODS returns_projected_po_conf_bulk FOR TESTING
      RAISING zcx_invalid_stock_request.
    METHODS returns_proj_po_conf_opts FOR TESTING
      RAISING zcx_invalid_stock_request.
    METHODS rejects_projected_po_conflict FOR TESTING.
    METHODS reads_confirmed_po_receipts FOR TESTING
      RAISING zcx_invalid_stock_request.
    METHODS returns_proj_receipts_bulk FOR TESTING
      RAISING zcx_invalid_stock_request.
    METHODS returns_po_conf_bulk FOR TESTING
      RAISING zcx_invalid_stock_request.
    METHODS rejects_proj_receipts_bulk FOR TESTING.
    METHODS returns_proj_opts_bulk FOR TESTING
      RAISING zcx_invalid_stock_request.
    METHODS rejects_proj_opts_bulk FOR TESTING.
    METHODS returns_proj_opts_uom FOR TESTING
      RAISING zcx_invalid_stock_request.
    METHODS rejects_proj_opts_uom FOR TESTING.
    METHODS returns_proj_bulk_uom FOR TESTING
      RAISING zcx_invalid_stock_request.
    METHODS returns_po_conf_bulk_uom FOR TESTING
      RAISING zcx_invalid_stock_request.
    METHODS rejects_proj_bulk_uom FOR TESTING.
    METHODS returns_proj_receipts_uom FOR TESTING
      RAISING zcx_invalid_stock_request.
    METHODS returns_po_conf_receipts_uom FOR TESTING
      RAISING zcx_invalid_stock_request.
    METHODS rejects_bad_proj_receipts_uom FOR TESTING.
    METHODS returns_stock_status_in_unit FOR TESTING.
    METHODS returns_bulk_status_unit FOR TESTING
      RAISING zcx_invalid_stock_request.
    METHODS rejects_bad_bulk_status_unit FOR TESTING.
    METHODS returns_location_stock_status FOR TESTING
      RAISING zcx_invalid_stock_request.
    METHODS returns_location_status_unit FOR TESTING.
    METHODS returns_location_bulk_uom FOR TESTING
      RAISING zcx_invalid_stock_request.
    METHODS rejects_bad_location_bulk_uom FOR TESTING.
    METHODS returns_batch_stock_status FOR TESTING
      RAISING zcx_invalid_stock_request.
    METHODS returns_bulk_batch_status FOR TESTING
      RAISING zcx_invalid_stock_request.
    METHODS rejects_bad_bulk_batch_status FOR TESTING.
    METHODS returns_bulk_batch_uom FOR TESTING
      RAISING zcx_invalid_stock_request.
    METHODS rejects_bad_bulk_batch_uom FOR TESTING.
    METHODS returns_batch_status_in_unit FOR TESTING.
    METHODS returns_fefo_eligible_status FOR TESTING.
    METHODS returns_fefo_bulk_status FOR TESTING
      RAISING zcx_invalid_stock_request.
    METHODS rejects_bad_fefo_bulk FOR TESTING.
    METHODS returns_fefo_bulk_uom FOR TESTING
      RAISING zcx_invalid_stock_request.
    METHODS rejects_bad_fefo_bulk_uom FOR TESTING.
    METHODS returns_fefo_status_in_unit FOR TESTING.
    METHODS rejects_invalid_fefo_status FOR TESTING.
    METHODS returns_zero_when_no_stock FOR TESTING
      RAISING zcx_invalid_stock_request.
    METHODS allocates_requested_quantity FOR TESTING.
    METHODS requires_full_local_quantity FOR TESTING.
    METHODS allocates_request_by_date FOR TESTING.
    METHODS requires_full_local_date FOR TESTING.
    METHODS requires_full_detailed_local FOR TESTING.
    METHODS excludes_undated_fefo_local FOR TESTING.
    METHODS excludes_undated_fefo_xplant FOR TESTING.
    METHODS allocates_sched_agmt_receipts FOR TESTING.
    METHODS allocates_with_pr_receipts FOR TESTING.
    METHODS allocates_with_sto_pr_receipts FOR TESTING.
    METHODS allocates_plan_supply FOR TESTING.
    METHODS allocates_with_po_receipts FOR TESTING.
    METHODS allocates_po_confirmations FOR TESTING
      RAISING zcx_invalid_stock_request.
    METHODS allocates_with_sto_in_transit FOR TESTING.
    METHODS includes_unissued_sto_receipts FOR TESTING.
    METHODS subtracts_unissued_sto_demand FOR TESTING.
    METHODS allocates_with_prod_receipts FOR TESTING.
    METHODS allocates_demands_by_date FOR TESTING.
    METHODS allocates_dated_po_conf FOR TESTING
      RAISING zcx_invalid_stock_request.
    METHODS allocates_po_conf_unit FOR TESTING
      RAISING zcx_invalid_stock_request.
    METHODS prioritizes_dated_demands FOR TESTING.
    METHODS allocates_dated_unit_demands FOR TESTING.
    METHODS prioritizes_unit_date_demands FOR TESTING.
    METHODS rejects_unknown_date_unit FOR TESTING.
    METHODS rejects_invalid_dated_list FOR TESTING.
    METHODS protects_dated_safety_stock FOR TESTING.
    METHODS rejects_missing_demand_date FOR TESTING.
    METHODS rejects_invalid_calendar_date FOR TESTING.
    METHODS rejects_bad_calendar_uom_date FOR TESTING.
    METHODS rejects_invalid_calendar_fefo FOR TESTING.
    METHODS compares_dated_bulk_atp FOR TESTING.
    METHODS rejects_bulk_atp_without_rule FOR TESTING.
    METHODS compares_dated_stock_with_atp FOR TESTING.
    METHODS compares_dated_alt_unit_atp FOR TESTING.
    METHODS limits_atp_confirmation_date FOR TESTING.
    METHODS rejects_bad_atp_split_inputs FOR TESTING.
    METHODS rejects_incomplete_atp_request FOR TESTING.
    METHODS reports_partial_shortfall FOR TESTING.
    METHODS negative_stock_is_unavailable FOR TESTING.
    METHODS rejects_negative_request FOR TESTING.
    METHODS allocates_demands_in_order FOR TESTING.
    METHODS keeps_plant_stock_separate FOR TESTING.
    METHODS allocates_across_plants FOR TESTING.
    METHODS filters_cross_plant_locations FOR TESTING.
    METHODS filters_cross_plant_batches FOR TESTING.
    METHODS filters_cross_plant_fefo FOR TESTING.
    METHODS filters_cross_plant_units FOR TESTING.
    METHODS scopes_cross_plant_locations FOR TESTING.
    METHODS rejects_bad_plant_loc_scopes FOR TESTING.
    METHODS requires_full_plant_quantity FOR TESTING.
    METHODS requires_full_plant_units FOR TESTING.
    METHODS requires_full_dated_plant FOR TESTING.
    METHODS allocates_plants_by_date FOR TESTING.
    METHODS allocates_plants_by_date_loc FOR TESTING.
    METHODS allocates_plant_loc_receipts FOR TESTING.
    METHODS alloc_plant_loc_rcpt_uom FOR TESTING.
    METHODS allocates_plants_date_loc_uom FOR TESTING.
    METHODS rejects_unknown_date_loc_uom FOR TESTING.
    METHODS compares_plants_date_loc_atp FOR TESTING.
    METHODS rejects_loc_date_atp_rule FOR TESTING.
    METHODS allocates_plants_with_po_conf FOR TESTING
      RAISING zcx_invalid_stock_request.
    METHODS prioritizes_plant_date_demands FOR TESTING.
    METHODS allocates_dated_plant_units FOR TESTING.
    METHODS prioritizes_plant_unit_dates FOR TESTING.
    METHODS compares_dated_plant_atp FOR TESTING.
    METHODS rejects_dated_plant_atp_rule FOR TESTING.
    METHODS compares_cross_plant_atp FOR TESTING.
    METHODS compares_cross_plant_batch_atp FOR TESTING.
    METHODS rejects_batch_plant_atp_rule FOR TESTING.
    METHODS compares_dated_batch_atp FOR TESTING
      RAISING zcx_invalid_stock_request.
    METHODS rejects_dated_batch_atp_rule FOR TESTING.
    METHODS compares_cross_plant_fefo_atp FOR TESTING.
    METHODS rejects_cross_plant_atp_rule FOR TESTING.
    METHODS rejects_dated_plant_uom FOR TESTING.
    METHODS rejects_missing_dated_source FOR TESTING.
    METHODS protects_cross_plant_safety FOR TESTING.
    METHODS rejects_bad_plant_protection FOR TESTING.
    METHODS rejects_invalid_plant_sources FOR TESTING.
    METHODS allocates_plants_in_units FOR TESTING.
    METHODS rejects_unknown_plant_uom FOR TESTING.
    METHODS allocates_plants_by_expiry FOR TESTING.
    METHODS allocates_expiry_receipts FOR TESTING.
    METHODS alloc_exp_rcpt_uom_atp FOR TESTING.
    METHODS rejects_invalid_expiry_receipt FOR TESTING.
    METHODS reject_exp_rcpt_pre_uom FOR TESTING.
    METHODS allocates_plants_fefo_by_date FOR TESTING.
    METHODS allocates_dated_fefo_receipts FOR TESTING.
    METHODS rejects_invalid_fefo_receipt FOR TESTING.
    METHODS protects_fefo_receipt_buffer FOR TESTING.
    METHODS prioritizes_dated_fefo_locs FOR TESTING.
    METHODS rejects_bad_dated_fefo_prio FOR TESTING.
    METHODS protects_dated_fefo_buffer FOR TESTING.
    METHODS rejects_missing_fefo_date FOR TESTING.
    METHODS allocates_fefo_from_locations FOR TESTING.
    METHODS rejects_invalid_fefo_locations FOR TESTING.
    METHODS allocates_source_scoped_fefo FOR TESTING.
    METHODS rejects_bad_scoped_locations FOR TESTING.
    METHODS allocates_plants_fefo_date_uom FOR TESTING.
    METHODS allocates_fefo_receipt_uom FOR TESTING.
    METHODS rejects_missing_fefo_uom_date FOR TESTING.
    METHODS compares_dated_fefo_atp FOR TESTING.
    METHODS compares_fefo_receipt_atp FOR TESTING.
    METHODS compares_fefo_atp FOR TESTING.
    METHODS compares_fefo_priority_atp FOR TESTING.
    METHODS compares_batch_atp FOR TESTING.
    METHODS rejects_dated_fefo_atp_rule FOR TESTING.
    METHODS allocates_plants_fefo_units FOR TESTING.
    METHODS prioritizes_plant_fefo FOR TESTING.
    METHODS prioritizes_plant_fefo_atp FOR TESTING.
    METHODS prioritizes_plant_demands FOR TESTING.
    METHODS rejects_invalid_plant_fefo FOR TESTING.
    METHODS rejects_unknown_plant_fefo_uom FOR TESTING.
    METHODS rejects_invalid_fefo_plant_uom FOR TESTING.
    METHODS allocates_plants_by_batch FOR TESTING.
    METHODS prioritizes_plant_batch FOR TESTING.
    METHODS prioritizes_plant_batch_atp FOR TESTING.
    METHODS allocates_plant_batch_receipts FOR TESTING.
    METHODS filters_plant_batch_life FOR TESTING.
    METHODS filters_undated_plant_batch FOR TESTING.
    METHODS allocates_dated_plant_batches FOR TESTING.
    METHODS rejects_batch_date FOR TESTING.
    METHODS allocates_dated_batch_uom FOR TESTING.
    METHODS rejects_batch_uom_date FOR TESTING.
    METHODS allocates_plants_batch_units FOR TESTING.
    METHODS allocates_plant_receipt_uom FOR TESTING.
    METHODS rejects_unmapped_receipt_uom FOR TESTING.
    METHODS protects_plant_batch_buffer FOR TESTING.
    METHODS protects_projected_plant_batch FOR TESTING.
    METHODS rejects_unknown_batch_uom FOR TESTING.
    METHODS rejects_missing_plant_batch FOR TESTING.
    METHODS splits_allocations_by_location FOR TESTING.
    METHODS allocates_loc_priority FOR TESTING.
    METHODS prioritizes_location_rows FOR TESTING.
    METHODS allocates_allowed_locations FOR TESTING.
    METHODS rejects_bad_allowed_locations FOR TESTING.
    METHODS rejects_bad_fallback_flags FOR TESTING.
    METHODS rejects_bad_date_receipt_flags FOR TESTING.
    METHODS allocates_batch_fefo_allowlist FOR TESTING.
    METHODS rejects_bad_loc_priority FOR TESTING.
    METHODS rejects_bad_protection_flags FOR TESTING.
    METHODS rejects_bad_protection_inputs FOR TESTING.
    METHODS rejects_bad_full_qty_flags FOR TESTING.
    METHODS allocates_location_units FOR TESTING.
    METHODS allocates_location_by_date FOR TESTING.
    METHODS allocates_dated_loc_receipts FOR TESTING.
    METHODS alloc_dated_loc_rcpt_uom FOR TESTING.
    METHODS allocates_dated_location_units FOR TESTING.
    METHODS compares_dated_location_atp FOR TESTING.
    METHODS compares_dated_loc_base_atp FOR TESTING.
    METHODS compares_location_atp FOR TESTING.
    METHODS allocates_loc_uom_priority FOR TESTING.
    METHODS allocates_only_requested_batch FOR TESTING.
    METHODS prioritizes_batch_demands FOR TESTING.
    METHODS allocates_batch_receipts FOR TESTING.
    METHODS alloc_batch_rcpt_uom_atp FOR TESTING.
    METHODS reject_batch_rcpt_pre_uom FOR TESTING.
    METHODS allocates_batch_units FOR TESTING.
    METHODS splits_requested_batch FOR TESTING.
    METHODS prefers_batch_location_first FOR TESTING.
    METHODS allocates_batch_location_order FOR TESTING.
    METHODS rejects_missing_batch FOR TESTING.
    METHODS allocates_by_expiry_date FOR TESTING.
    METHODS allocates_fefo_row_full_qty FOR TESTING.
    METHODS allocates_fefo_by_priority FOR TESTING.
    METHODS allocates_single_fefo_receipts FOR TESTING.
    METHODS protects_due_fefo_buffer FOR TESTING.
    METHODS alloc_single_fefo_rcpt_uom FOR TESTING.
    METHODS reject_single_fefo_pre_uom FOR TESTING.
    METHODS allocates_fefo_exact_batch FOR TESTING.
    METHODS allocates_quality_by_expiry FOR TESTING.
    METHODS alloc_quality_fefo_row_full FOR TESTING.
    METHODS allocates_quality_fefo_rcpts FOR TESTING.
    METHODS rejects_quality_rcpt_pre_uom FOR TESTING.
    METHODS allocates_quality_batch FOR TESTING.
    METHODS allocates_quality_loc_order FOR TESTING.
    METHODS filters_quality_locations FOR TESTING.
    METHODS rejects_quality_loc_filter FOR TESTING.
    METHODS allocates_quality_fefo_units FOR TESTING.
    METHODS alloc_quality_fefo_priority FOR TESTING.
    METHODS compares_quality_fefo_atp FOR TESTING.
    METHODS requires_full_quality_quantity FOR TESTING.
    METHODS allocates_fefo_units FOR TESTING.
    METHODS allocates_fefo_uom_batch FOR TESTING.
    METHODS filters_fefo_min_days FOR TESTING.
    METHODS rejects_negative_fefo_days FOR TESTING.
    METHODS restricts_fefo_to_location FOR TESTING.
    METHODS prefers_fefo_location_first FOR TESTING.
    METHODS allocates_fefo_loc_order FOR TESTING.
    METHODS protects_safety_stock_in_alloc FOR TESTING.
    METHODS protects_location_safety_stock FOR TESTING.
    METHODS protects_batch_safety_stock FOR TESTING.
    METHODS protects_fefo_safety_stock FOR TESTING.
    METHODS rejects_invalid_fefo_input FOR TESTING.
    METHODS allocates_in_alternative_unit FOR TESTING.
    METHODS allocates_demands_in_units FOR TESTING.
    METHODS compares_uom_demand_atp FOR TESTING.
    METHODS defaults_uom_demand_atp_date FOR TESTING.
    METHODS rejects_uom_demand_atp_opts FOR TESTING.
    METHODS prioritizes_uom_demand_atp FOR TESTING.
    METHODS rejects_uom_rounding_to_zero FOR TESTING.
    METHODS rejects_unknown_alloc_unit FOR TESTING.
    METHODS rejects_unknown_bulk_unit FOR TESTING.
    METHODS rejects_unknown_batch_unit FOR TESTING.
    METHODS rejects_unknown_fefo_unit FOR TESTING.
    METHODS rejects_unknown_location_unit FOR TESTING.
    METHODS rejects_unknown_status_unit FOR TESTING.
    METHODS rejects_unknown_location_units FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_service IMPLEMENTATION.
  METHOD rejects_blank_status_keys.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->get_stock_status(
          iv_material = space
          iv_plant    = '1000' ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_stock_status(
          iv_material = 'MAT-1'
          iv_plant    = space ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_stock_status_by_location(
          iv_material = 'MAT-1'
          iv_plant    = space ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_stock_status_by_location(
          iv_material = space
          iv_plant    = '1000' ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_stock_status_by_batch(
          iv_material = 'MAT-1'
          iv_plant    = space ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_stock_status_by_batch(
          iv_material = space
          iv_plant    = '1000' ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

  ENDMETHOD.

  METHOD rejects_blank_order_res_keys.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->get_sales_order_reservations(
          iv_sales_document = space ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_order_reservations_bulk(
          it_sales_documents = VALUE #( ( space ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    DATA(lt_result) = lo_cut->get_order_reservations_bulk(
      it_sales_documents = VALUE #( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_result ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_order_res_bulk_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_sales_order_reservations(
      it_reservations = VALUE #(
        ( sales_document   = 'SO-1'
          material         = 'MAT-1'
          plant            = '1000'
          item_number      = '000010'
          schedule_line    = '0001'
          requirement_date = '20261015'
          open_quantity    = '24.000' )
        ( sales_document   = 'SO-2'
          material         = 'MAT-1'
          plant            = '1000'
          item_number      = '000020'
          schedule_line    = '0002'
          requirement_date = '20261020'
          open_quantity    = '12.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(lt_results) = lo_cut->get_order_res_bulk_uom(
      it_requests = VALUE #(
        ( request_id     = 'RES-2'
          sales_document = 'SO-2'
          material       = 'MAT-1'
          plant          = '1000'
          unit           = 'BOX' )
        ( request_id     = 'RES-1'
          sales_document = 'SO-1'
          material       = 'MAT-1'
          plant          = '1000'
          unit           = 'BOX' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'RES-2'
      act = lt_results[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SO-2'
      act = lt_results[ 1 ]-sales_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_results[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lt_results[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_results[ 1 ]-reservations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '000020'
      act = lt_results[ 1 ]-reservations[ 1 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '1.000' )
      act = lt_results[ 1 ]-reservations[ 1 ]-open_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261020'
      act = lt_results[ 1 ]-reservations[ 1 ]-requirement_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SO-1'
      act = lt_results[ 2 ]-sales_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '2.000' )
      act = lt_results[ 2 ]-reservations[ 1 ]-open_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_order_res_bulk_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->get_order_res_bulk_uom(
          it_requests = VALUE #(
            ( request_id     = 'RES-1'
              sales_document = 'SO-1'
              material       = 'MAT-1'
              plant          = '1000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_order_res_bulk_uom(
          it_requests = VALUE #(
            ( request_id     = 'RES-1'
              sales_document = 'SO-1'
              material       = 'MAT-1'
              plant          = '1000'
              unit           = 'BOX' )
            ( request_id     = 'RES-1'
              sales_document = 'SO-2'
              material       = 'MAT-1'
              plant          = '1000'
              unit           = 'BOX' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_order_res_bulk_uom(
          it_requests = VALUE #(
            ( request_id     = 'RES-1'
              sales_document = 'SO-1'
              material       = 'MAT-1'
              plant          = '1000'
              unit           = 'CASE' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    DATA(lt_empty_results) = lo_cut->get_order_res_bulk_uom(
      it_requests = VALUE #( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_empty_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_bulk_stock_status.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_stock_status(
      is_status = VALUE #(
        unrestricted_quantity       = '18.000'
        reserved_quantity           = '3.000'
        available_unrestricted_qty  = '15.000'
        safety_stock_quantity       = '2.000'
        available_after_safety_qty  = '13.000'
        quality_inspection_quantity = '1.000'
        blocked_quantity            = '0.500' ) ).

    DATA(lt_status) = lo_cut->get_stock_status_bulk(
      it_requests = VALUE #(
        ( request_id = 'REQ-1' material = 'MAT-1' plant = '1000' )
        ( request_id = 'REQ-2' material = 'MAT-2' plant = '2000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_status ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-1'
      act = lt_status[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MAT-2'
      act = lt_status[ 2 ]-material ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '13.000' )
      act = lt_status[ 2 ]-stock_status-available_after_safety_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).

  ENDMETHOD.

  METHOD rejects_bad_bulk_stock_status.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->get_stock_status_bulk(
          it_requests = VALUE #( ( material = 'MAT-1' plant = '1000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_stock_status_bulk(
          it_requests = VALUE #(
            ( request_id = 'REQ-1' plant = '1000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_stock_status_bulk(
          it_requests = VALUE #(
            ( request_id = 'REQ-1' material = 'MAT-1' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_stock_status_bulk(
          it_requests = VALUE #(
            ( request_id = 'REQ-1' material = 'MAT-1' plant = '1000' )
            ( request_id = 'REQ-1' material = 'MAT-2' plant = '2000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    DATA(lt_empty_result) = lo_cut->get_stock_status_bulk(
      it_requests = VALUE #( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_empty_result ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_bulk_result.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_rejected TYPE abap_bool.
    DATA(lt_requests) = VALUE zif_stock_repository=>ty_stock_status_requests(
      ( request_id = 'REQ-1' material = 'MAT-1' plant = '1000' ) ).

    lo_repository->set_stock_status_bulk_response(
      it_status = VALUE #(
        ( request_id = 'REQ-1' material = 'MAT-1' plant = '2000' ) ) ).
    TRY.
        lo_cut->get_stock_status_bulk( it_requests = lt_requests ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    lo_repository->set_stock_status_bulk_response(
      it_status = VALUE #( ) ).
    TRY.
        lo_cut->get_stock_status_bulk( it_requests = lt_requests ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
  ENDMETHOD.

  METHOD returns_bulk_location_status.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_location_stock_status(
      it_status = VALUE #(
        ( storage_location           = '0001'
          unrestricted_quantity      = '12.000'
          available_unrestricted_qty = '8.000'
          quality_inspection_qty     = '1.000'
          blocked_quantity           = '0.500' ) ) ).

    DATA(lt_status) = lo_cut->get_location_stock_status_bulk(
      it_requests = VALUE #(
        ( request_id = 'LOC-1' material = 'MAT-1' plant = '1000' )
        ( request_id = 'LOC-2' material = 'MAT-2' plant = '2000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_status ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LOC-1'
      act = lt_status[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MAT-2'
      act = lt_status[ 2 ]-material ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_status[ 2 ]-locations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = lt_status[ 2 ]-locations[ 1 ]-available_unrestricted_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).

  ENDMETHOD.

  METHOD rejects_bad_bulk_location.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->get_location_stock_status_bulk(
          it_requests = VALUE #(
            ( request_id = 'LOC-1' plant = '1000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_location_stock_status_bulk(
          it_requests = VALUE #(
            ( request_id = 'LOC-1' material = 'MAT-1' plant = '1000' )
            ( request_id = 'LOC-1' material = 'MAT-2' plant = '2000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    DATA(lt_empty_status) = lo_cut->get_location_stock_status_bulk(
      it_requests = VALUE #( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_empty_status ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_stock_status.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_stock_status(
      is_status = VALUE #(
        unrestricted_quantity       = '8.000'
        reserved_quantity           = '2.000'
        available_unrestricted_qty  = '6.000'
        safety_stock_quantity       = '2.000'
        available_after_safety_qty  = '4.000'
        quality_inspection_quantity = '2.000'
        blocked_quantity            = '1.500' ) ).

    DATA(ls_status) = lo_cut->get_stock_status(
      iv_material = 'MAT-1'
      iv_plant    = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_status-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '2.000' )
      act = ls_status-reserved_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_status-available_unrestricted_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV marc-eisbe( '2.000' )
      act = ls_status-safety_stock_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_status-available_after_safety_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-insme( '2.000' )
      act = ls_status-quality_inspection_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-speme( '1.500' )
      act = ls_status-blocked_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).

  ENDMETHOD.

  METHOD reads_projected_receipts.
    DATA lv_invalid_request_rejected TYPE abap_bool.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_projected_receipts(
      it_receipts = VALUE #(
        ( material     = 'MAT-1'
          plant        = '1000'
          base_unit    = 'EA'
          receipt_date = '20261024'
          quantity     = '1.000'
          source_type  = 'STO_IN_TRANSIT' )
        ( material             = 'MAT-1'
          plant                = '1000'
          base_unit            = 'EA'
          receipt_date         = '20261022'
          quantity             = '2.500'
          source_type          = 'PO'
          source_document      = '4500000010'
          source_item          = '00020'
          source_schedule_line = '0002' )
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261023'
          quantity        = '3.000'
          source_type     = 'PRODUCTION'
          source_document = '0000004711'
          source_item     = '0010' )
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261023'
          quantity        = '4.000'
          source_type     = 'PROCESS_ORDER'
          source_document = '0000004811'
          source_item     = '0010' )
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261022'
          quantity        = '0.500'
          source_type     = 'PR'
          source_document = '0010001234'
          source_item     = '00010' )
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261023'
          quantity        = '4.000'
          source_type     = 'STO_PR'
          source_document = '0010001235'
          source_item     = '00020'
          source_plant    = '2000' )
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261023'
          quantity        = '5.000'
          source_type     = 'PLANNED_ORDER'
          source_document = '0000001236' )
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261023'
          quantity        = '2.000'
          source_type     = 'FIXED_PLAN_ORDER'
          source_document = '0000001237' )
        ( material             = 'MAT-1'
          plant                = '1000'
          base_unit            = 'EA'
          receipt_date         = '20261023'
          quantity             = '6.000'
          source_type          = 'SCHED_AGREEMENT'
          source_document      = '5500000010'
          source_item          = '00030'
          source_schedule_line = '0004' ) ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    DATA(lt_receipts) = lo_cut->get_projected_receipts(
      iv_material              = 'MAT-1'
      iv_plant                 = '1000'
      iv_through_date          = '20261023'
      iv_include_po_receipts   = abap_true
      iv_include_prod_receipts = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PO'
      act = lt_receipts[ 1 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000010'
      act = lt_receipts[ 1 ]-source_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_receipts[ 1 ]-source_schedule_line ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRODUCTION'
      act = lt_receipts[ 2 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261023' )
      act = lt_receipts[ 2 ]-receipt_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PROCESS_ORDER'
      act = lt_receipts[ 3 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004811'
      act = lt_receipts[ 3 ]-source_document ).
    DATA(lt_pr_receipts) = lo_cut->get_projected_receipts(
      iv_material            = 'MAT-1'
      iv_plant               = '1000'
      iv_through_date        = '20261023'
      iv_include_pr_receipts = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_pr_receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0010001234'
      act = lt_pr_receipts[ 1 ]-source_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PR'
      act = lt_pr_receipts[ 1 ]-source_type ).
    DATA(lt_sto_pr_receipts) = lo_cut->get_projected_receipts(
      iv_material                = 'MAT-1'
      iv_plant                   = '1000'
      iv_through_date            = '20261023'
      iv_include_sto_pr_receipts = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_sto_pr_receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'STO_PR'
      act = lt_sto_pr_receipts[ 1 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = lt_sto_pr_receipts[ 1 ]-source_plant ).
    DATA(lt_planned_receipts) = lo_cut->get_projected_receipts(
      iv_material                 = 'MAT-1'
      iv_plant                    = '1000'
      iv_through_date             = '20261023'
      iv_include_planned_receipts = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_planned_receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PLANNED_ORDER'
      act = lt_planned_receipts[ 1 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001236'
      act = lt_planned_receipts[ 1 ]-source_document ).
    DATA(lt_fixed_planned_receipts) = lo_cut->get_projected_receipts(
      iv_material              = 'MAT-1'
      iv_plant                 = '1000'
      iv_through_date          = '20261023'
      iv_include_fixed_planned = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_fixed_planned_receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'FIXED_PLAN_ORDER'
      act = lt_fixed_planned_receipts[ 1 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001237'
      act = lt_fixed_planned_receipts[ 1 ]-source_document ).
    DATA(lt_all_planned_receipts) = lo_cut->get_projected_receipts(
      iv_material                 = 'MAT-1'
      iv_plant                    = '1000'
      iv_through_date             = '20261023'
      iv_include_planned_receipts = abap_true
      iv_include_fixed_planned    = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_all_planned_receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PLANNED_ORDER'
      act = lt_all_planned_receipts[ 1 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'FIXED_PLAN_ORDER'
      act = lt_all_planned_receipts[ 2 ]-source_type ).
    DATA(lt_sched_agreement_receipts) = lo_cut->get_projected_receipts(
      iv_material                    = 'MAT-1'
      iv_plant                       = '1000'
      iv_through_date                = '20261023'
      iv_include_sched_agmt_receipts = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_sched_agreement_receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SCHED_AGREEMENT'
      act = lt_sched_agreement_receipts[ 1 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = '5500000010'
      act = lt_sched_agreement_receipts[ 1 ]-source_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00030'
      act = lt_sched_agreement_receipts[ 1 ]-source_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0004'
      act = lt_sched_agreement_receipts[ 1 ]-source_schedule_line ).
    DATA(lo_prod_comp) = NEW zcl_prod_comp_service( ).
    DATA(lt_suggestions) = lo_prod_comp->suggest_comp_replenishment(
      it_shortages          = VALUE #(
        ( material                = 'MAT-1'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261023'
          component_count         = 1
          affected_order_count    = 1
          requested_base_quantity = '0.500'
          allocated_base_quantity = '0.000'
          shortfall_base_quantity = '0.500' ) )
      it_policies           = VALUE #(
        ( material           = 'MAT-1'
          plant              = '1000'
          base_unit          = 'EA'
          lot_size_procedure = 'EX'
          procurement_type   = 'F' ) )
      it_projected_receipts = CORRESPONDING #( lt_receipts )
      iv_as_of_date         = '20261020' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_suggestions[ 1 ]-projected_receipt_used_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_suggestions[ 1 ]-suggested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000010'
      act = lt_suggestions[ 1 ]-projected_receipt_uses[ 1 ]-source_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = 7
      act = lo_repository->get_read_count( ) ).
    TRY.
        DATA(lt_invalid_receipts) = lo_cut->get_projected_receipts(
          iv_material     = 'MAT-1'
          iv_plant        = '1000'
          iv_through_date = '00000000' ).
      CATCH zcx_invalid_stock_request.
        lv_invalid_request_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_invalid_request_rejected ).
    CLEAR lv_invalid_request_rejected.
    TRY.
        DATA(lt_invalid_fixed_option) = lo_cut->get_projected_receipts(
          iv_material              = 'MAT-1'
          iv_plant                 = '1000'
          iv_through_date          = '20261023'
          iv_include_fixed_planned = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_invalid_request_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_invalid_request_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 7
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD reads_confirmed_po_receipts.
    DATA lv_invalid_request_rejected TYPE abap_bool.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_projected_receipts(
      it_receipts = VALUE #(
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261023'
          quantity        = '4.000'
          source_type     = 'PO'
          source_document = '4500000010'
          source_item     = '00010' )
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261024'
          quantity        = '2.500'
          source_type     = 'PO_CONFIRMATION'
          source_document = '4500000011'
          source_item     = '00020' )
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261024'
          quantity        = '8.000'
          source_type     = 'PR'
          source_document = '0010001234' ) ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    DATA(lt_receipts) =
      lo_cut->get_po_confirmed_receipts(
        iv_material     = 'MAT-1'
        iv_plant        = '1000'
        iv_through_date = '20261024' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PO'
      act = lt_receipts[ 1 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PO_CONFIRMATION'
      act = lt_receipts[ 2 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.500' )
      act = lt_receipts[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
    TRY.
        DATA(lt_invalid_receipts) = lo_cut->get_po_confirmed_receipts(
          iv_material     = 'MAT-1'
          iv_plant        = '1000'
          iv_through_date = '00000000' ).
      CATCH zcx_invalid_stock_request.
        lv_invalid_request_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_invalid_request_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).

  ENDMETHOD.

  METHOD returns_proj_po_conf_single.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_projected_receipts(
      it_receipts = VALUE #(
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261022'
          quantity        = '12.000'
          source_type     = 'PO'
          source_document = '4500000010' )
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261023'
          quantity        = '24.000'
          source_type     = 'PO_CONFIRMATION'
          source_document = '4500000010' )
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261023'
          quantity        = '6.000'
          source_type     = 'PRODUCTION'
          source_document = '0000004711' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(lt_receipts) = lo_cut->get_projected_receipts(
      iv_material                 = 'MAT-1'
      iv_plant                    = '1000'
      iv_through_date             = '20261023'
      iv_include_po_confirmations = abap_true
      iv_include_prod_receipts    = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRODUCTION'
      act = lt_receipts[ 1 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PO'
      act = lt_receipts[ 2 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PO_CONFIRMATION'
      act = lt_receipts[ 3 ]-source_type ).

    DATA(lt_unit_receipts) = lo_cut->get_projected_receipts_in_unit(
      iv_material                 = 'MAT-1'
      iv_plant                    = '1000'
      iv_through_date             = '20261023'
      iv_unit                     = 'BOX'
      iv_include_po_confirmations = abap_true
      iv_include_prod_receipts    = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_unit_receipts[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_unit_receipts[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_unit_receipts[ 3 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PO_CONFIRMATION'
      act = lt_unit_receipts[ 3 ]-source_type ).
  ENDMETHOD.

  METHOD returns_projected_po_conf_bulk.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_projected_receipts(
      it_receipts = VALUE #(
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261022'
          quantity        = '12.000'
          source_type     = 'PO'
          source_document = '4500000010' )
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261025'
          quantity        = '24.000'
          source_type     = 'PO_CONFIRMATION'
          source_document = '4500000010' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(lt_results) = lo_cut->get_projected_receipts_bulk(
      it_requests                 = VALUE #(
        ( request_id   = 'CONF-EARLY'
          material     = 'MAT-1'
          plant        = '1000'
          through_date = '20261023' )
        ( request_id   = 'CONF-LATE'
          material     = 'MAT-1'
          plant        = '1000'
          through_date = '20261026' ) )
      iv_include_po_confirmations = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_results[ 1 ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CONF-LATE'
      act = lt_results[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results[ 2 ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PO_CONFIRMATION'
      act = lt_results[ 2 ]-receipts[ 2 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).

    DATA(lt_unit_results) = lo_cut->get_proj_receipts_bulk_uom(
      it_requests                 = VALUE #(
        ( request_id   = 'CONF-UOM'
          material     = 'MAT-1'
          plant        = '1000'
          through_date = '20261026'
          unit         = 'BOX' ) )
      iv_include_po_confirmations = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_unit_results[ 1 ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_unit_results[ 1 ]-receipts[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_proj_po_conf_opts.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_projected_receipts(
      it_receipts = VALUE #(
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261022'
          quantity        = '12.000'
          source_type     = 'PO'
          source_document = '4500000010' )
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261025'
          quantity        = '24.000'
          source_type     = 'PO_CONFIRMATION'
          source_document = '4500000010' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(lt_results) = lo_cut->get_proj_receipts_opts_bulk(
      it_requests = VALUE #(
        ( request_id   = 'OPT-REGULAR'
          material     = 'MAT-1'
          plant        = '1000'
          through_date = '20261023'
          options      = VALUE #( include_po_receipts = abap_true ) )
        ( request_id   = 'OPT-CONFIRMED'
          material     = 'MAT-1'
          plant        = '1000'
          through_date = '20261026'
          options      = VALUE #( include_po_confirmations = abap_true ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_results[ 1 ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results[ 2 ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PO_CONFIRMATION'
      act = lt_results[ 2 ]-receipts[ 2 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).

    DATA(lt_unit_results) = lo_cut->get_proj_receipts_opts_uom(
      it_requests = VALUE #(
        ( request_id   = 'OPT-UOM'
          material     = 'MAT-1'
          plant        = '1000'
          through_date = '20261026'
          unit         = 'BOX'
          options      = VALUE #(
            include_po_confirmations = abap_true ) ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_unit_results[ 1 ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_unit_results[ 1 ]-receipts[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_projected_po_conflict.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->get_projected_receipts(
          iv_material                 = 'MAT-1'
          iv_plant                    = '1000'
          iv_through_date             = '20261023'
          iv_include_po_receipts      = abap_true
          iv_include_po_confirmations = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_projected_receipts_bulk(
          it_requests                 = VALUE #( )
          iv_include_po_receipts      = abap_true
          iv_include_po_confirmations = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_proj_receipts_opts_bulk(
          it_requests = VALUE #(
            ( request_id   = 'OPT-CONFLICT'
              material     = 'MAT-1'
              plant        = '1000'
              through_date = '20261023'
              options      = VALUE #(
                include_po_receipts      = abap_true
                include_po_confirmations = abap_true ) ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_proj_receipts_bulk.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_projected_receipts(
      it_receipts = VALUE #(
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261022'
          quantity        = '12.000'
          source_type     = 'PO'
          source_document = '4500000010' )
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261025'
          quantity        = '24.000'
          source_type     = 'PO'
          source_document = '4500000020' )
        ( material        = 'MAT-2'
          plant           = '2000'
          base_unit       = 'KG'
          receipt_date    = '20261024'
          quantity        = '6.000'
          source_type     = 'PO'
          source_document = '4500000030' ) ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    DATA(lt_results) = lo_cut->get_projected_receipts_bulk(
      it_requests            = VALUE #(
        ( request_id   = 'PROJ-EARLY'
          material     = 'MAT-1'
          plant        = '1000'
          through_date = '20261024' )
        ( request_id   = 'PROJ-LATE'
          material     = 'MAT-1'
          plant        = '1000'
          through_date = '20261026' )
        ( request_id   = 'PROJ-OTHER'
          material     = 'MAT-2'
          plant        = '2000'
          through_date = '20261024' ) )
      iv_include_po_receipts = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PROJ-EARLY'
      act = lt_results[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_results[ 1 ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000010'
      act = lt_results[ 1 ]-receipts[ 1 ]-source_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PROJ-LATE'
      act = lt_results[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results[ 2 ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000020'
      act = lt_results[ 2 ]-receipts[ 2 ]-source_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PROJ-OTHER'
      act = lt_results[ 3 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'KG'
      act = lt_results[ 3 ]-receipts[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_po_conf_bulk.
    DATA lv_rejected TYPE abap_bool.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_projected_receipts(
      it_receipts = VALUE #(
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261022'
          quantity        = '12.000'
          source_type     = 'PO'
          source_document = '4500000010' )
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261025'
          quantity        = '24.000'
          source_type     = 'PO_CONFIRMATION'
          source_document = '4500000020' )
        ( material        = 'MAT-2'
          plant           = '2000'
          base_unit       = 'KG'
          receipt_date    = '20261024'
          quantity        = '6.000'
          source_type     = 'PO_CONFIRMATION'
          source_document = '4500000030' ) ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    DATA(lt_results) = lo_cut->get_po_conf_receipts_bulk(
      it_requests = VALUE #(
        ( request_id   = 'CONF-EARLY'
          material     = 'MAT-1'
          plant        = '1000'
          through_date = '20261024' )
        ( request_id   = 'CONF-LATE'
          material     = 'MAT-1'
          plant        = '1000'
          through_date = '20261026' )
        ( request_id   = 'CONF-OTHER'
          material     = 'MAT-2'
          plant        = '2000'
          through_date = '20261024' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CONF-EARLY'
      act = lt_results[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_results[ 1 ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PO'
      act = lt_results[ 1 ]-receipts[ 1 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CONF-LATE'
      act = lt_results[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PO_CONFIRMATION'
      act = lt_results[ 2 ]-receipts[ 2 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CONF-OTHER'
      act = lt_results[ 3 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'KG'
      act = lt_results[ 3 ]-receipts[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).

    TRY.
        lo_cut->get_po_conf_receipts_bulk(
          it_requests = VALUE #(
            ( request_id   = 'DUP'
              material     = 'MAT-1'
              plant        = '1000'
              through_date = '20261024' )
            ( request_id   = 'DUP'
              material     = 'MAT-2'
              plant        = '2000'
              through_date = '20261024' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_proj_receipts_bulk.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->get_projected_receipts_bulk(
          it_requests            = VALUE #( )
          iv_include_po_receipts = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_projected_receipts_bulk(
          it_requests            = VALUE #(
            ( request_id   = 'PROJ-1'
              material     = 'MAT-1'
              plant        = '1000'
              through_date = '20261023' )
            ( request_id   = 'PROJ-1'
              material     = 'MAT-2'
              plant        = '2000'
              through_date = '20261024' ) )
          iv_include_po_receipts = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_projected_receipts_bulk(
          it_requests            = VALUE #(
            ( request_id = 'PROJ-1'
              material   = 'MAT-1'
              plant      = '1000' ) )
          iv_include_po_receipts = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    DATA(lt_empty_results) = lo_cut->get_projected_receipts_bulk(
      it_requests = VALUE #( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_empty_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    DATA(lt_no_source_results) = lo_cut->get_projected_receipts_bulk(
      it_requests = VALUE #(
        ( request_id   = 'PROJ-EMPTY'
          material     = 'MAT-1'
          plant        = '1000'
          through_date = '20261023' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_no_source_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_no_source_results[ 1 ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_proj_opts_bulk.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_projected_receipts(
      it_receipts = VALUE #(
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261022'
          quantity        = '12.000'
          source_type     = 'PO'
          source_document = '4500000010' )
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261023'
          quantity        = '24.000'
          source_type     = 'PRODUCTION'
          source_document = '0000004711' )
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261023'
          quantity        = '6.000'
          source_type     = 'PR'
          source_document = '0010001234' )
        ( material        = 'MAT-2'
          plant           = '2000'
          base_unit       = 'KG'
          receipt_date    = '20261024'
          quantity        = '30.000'
          source_type     = 'SCHED_AGREEMENT'
          source_document = '5500000010' ) ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    DATA(lt_results) = lo_cut->get_proj_receipts_opts_bulk(
      it_requests = VALUE #(
        ( request_id   = 'SRC-PROD'
          material     = 'MAT-1'
          plant        = '1000'
          through_date = '20261024'
          options      = VALUE #( include_prod_receipts = abap_true ) )
        ( request_id   = 'SRC-PO'
          material     = 'MAT-1'
          plant        = '1000'
          through_date = '20261022'
          options      = VALUE #( include_po_receipts = abap_true ) )
        ( request_id   = 'SRC-NONE'
          material     = 'MAT-3'
          plant        = '3000'
          through_date = '20261024' )
        ( request_id   = 'SRC-AGMT'
          material     = 'MAT-2'
          plant        = '2000'
          through_date = '20261024'
          options      = VALUE #(
            include_sched_agmt_receipts = abap_true ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SRC-PROD'
      act = lt_results[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_results[ 1 ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRODUCTION'
      act = lt_results[ 1 ]-receipts[ 1 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711'
      act = lt_results[ 1 ]-receipts[ 1 ]-source_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SRC-PO'
      act = lt_results[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_results[ 2 ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PO'
      act = lt_results[ 2 ]-receipts[ 1 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_results[ 3 ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SCHED_AGREEMENT'
      act = lt_results[ 4 ]-receipts[ 1 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_proj_opts_bulk.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->get_proj_receipts_opts_bulk(
          it_requests = VALUE #(
            ( request_id   = 'SRC-1'
              material     = 'MAT-1'
              plant        = '1000'
              through_date = '20261023'
              options      = VALUE #( include_po_receipts = 'Y' ) ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_proj_receipts_opts_bulk(
          it_requests = VALUE #(
            ( request_id   = 'SRC-1'
              material     = 'MAT-1'
              plant        = '1000'
              through_date = '20261023'
              options      = VALUE #( include_po_receipts = abap_true ) )
            ( request_id   = 'SRC-1'
              material     = 'MAT-2'
              plant        = '2000'
              through_date = '20261024'
              options      = VALUE #( include_prod_receipts = abap_true ) ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_proj_receipts_opts_bulk(
          it_requests = VALUE #(
            ( request_id = 'SRC-1'
              material   = 'MAT-1'
              plant      = '1000'
              options    = VALUE #( include_po_receipts = abap_true ) ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    DATA(lt_empty_results) = lo_cut->get_proj_receipts_opts_bulk(
      it_requests = VALUE #( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_empty_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    DATA(lt_no_source_results) = lo_cut->get_proj_receipts_opts_bulk(
      it_requests = VALUE #(
        ( request_id   = 'SRC-NONE'
          material     = 'MAT-1'
          plant        = '1000'
          through_date = '20261023' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_no_source_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_no_source_results[ 1 ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_proj_bulk_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_projected_receipts(
      it_receipts = VALUE #(
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261022'
          quantity        = '24.000'
          source_type     = 'PO'
          source_document = '4500000010' )
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261025'
          quantity        = '12.000'
          source_type     = 'PO'
          source_document = '4500000020' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(lt_results) = lo_cut->get_proj_receipts_bulk_uom(
      it_requests            = VALUE #(
        ( request_id   = 'UOM-EARLY'
          material     = 'MAT-1'
          plant        = '1000'
          through_date = '20261024'
          unit         = 'BOX' )
        ( request_id   = 'UOM-LATE'
          material     = 'MAT-1'
          plant        = '1000'
          through_date = '20261026'
          unit         = 'BOX' ) )
      iv_include_po_receipts = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'UOM-EARLY'
      act = lt_results[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_results[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lt_results[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_results[ 1 ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_results[ 1 ]-receipts[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000010'
      act = lt_results[ 1 ]-receipts[ 1 ]-source_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'UOM-LATE'
      act = lt_results[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results[ 2 ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_results[ 2 ]-receipts[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lt_results[ 2 ]-receipts[ 2 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_po_conf_bulk_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_projected_receipts(
      it_receipts = VALUE #(
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261022'
          quantity        = '24.000'
          source_type     = 'PO'
          source_document = '4500000010' )
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261025'
          quantity        = '12.000'
          source_type     = 'PO_CONFIRMATION'
          source_document = '4500000020' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(lt_results) = lo_cut->get_po_conf_receipts_bulk_uom(
      it_requests = VALUE #(
        ( request_id   = 'CONF-UOM-EARLY'
          material     = 'MAT-1'
          plant        = '1000'
          through_date = '20261024'
          unit         = 'BOX' )
        ( request_id   = 'CONF-UOM-LATE'
          material     = 'MAT-1'
          plant        = '1000'
          through_date = '20261026'
          unit         = 'BOX' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CONF-UOM-EARLY'
      act = lt_results[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_results[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lt_results[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_results[ 1 ]-receipts[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CONF-UOM-LATE'
      act = lt_results[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PO_CONFIRMATION'
      act = lt_results[ 2 ]-receipts[ 2 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_results[ 2 ]-receipts[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_proj_bulk_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->get_proj_receipts_bulk_uom(
          it_requests            = VALUE #( )
          iv_include_po_receipts = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_proj_receipts_bulk_uom(
          it_requests            = VALUE #(
            ( request_id   = 'UOM-1'
              material     = 'MAT-1'
              plant        = '1000'
              through_date = '20261023' ) )
          iv_include_po_receipts = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_proj_receipts_bulk_uom(
          it_requests            = VALUE #(
            ( request_id   = 'UOM-1'
              material     = 'MAT-1'
              plant        = '1000'
              through_date = '20261023'
              unit         = 'BOX' )
            ( request_id   = 'UOM-1'
              material     = 'MAT-1'
              plant        = '1000'
              through_date = '20261024'
              unit         = 'BOX' ) )
          iv_include_po_receipts = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_proj_receipts_bulk_uom(
          it_requests            = VALUE #(
            ( request_id   = 'UOM-1'
              material     = 'MAT-1'
              plant        = '1000'
              through_date = '20261023'
              unit         = 'ZZZ' ) )
          iv_include_po_receipts = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    DATA(lt_empty_results) = lo_cut->get_proj_receipts_bulk_uom(
      it_requests = VALUE #( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_empty_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_proj_opts_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_projected_receipts(
      it_receipts = VALUE #(
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261022'
          quantity        = '24.000'
          source_type     = 'PO'
          source_document = '4500000010' )
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261023'
          quantity        = '12.000'
          source_type     = 'PRODUCTION'
          source_document = '0000004711' )
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261023'
          quantity        = '6.000'
          source_type     = 'PR'
          source_document = '0010001234' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(lt_results) = lo_cut->get_proj_receipts_opts_uom(
      it_requests = VALUE #(
        ( request_id   = 'UOM-PROD'
          material     = 'MAT-1'
          plant        = '1000'
          through_date = '20261024'
          unit         = 'BOX'
          options      = VALUE #( include_prod_receipts = abap_true ) )
        ( request_id   = 'UOM-PO'
          material     = 'MAT-1'
          plant        = '1000'
          through_date = '20261022'
          unit         = 'BOX'
          options      = VALUE #( include_po_receipts = abap_true ) )
        ( request_id   = 'UOM-NONE'
          material     = 'MAT-1'
          plant        = '1000'
          through_date = '20261024'
          unit         = 'BOX' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'UOM-PROD'
      act = lt_results[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_results[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lt_results[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRODUCTION'
      act = lt_results[ 1 ]-receipts[ 1 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_results[ 1 ]-receipts[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'UOM-PO'
      act = lt_results[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PO'
      act = lt_results[ 2 ]-receipts[ 1 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_results[ 2 ]-receipts[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_results[ 3 ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_proj_opts_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->get_proj_receipts_opts_uom(
          it_requests = VALUE #(
            ( request_id   = 'UOM-1'
              material     = 'MAT-1'
              plant        = '1000'
              through_date = '20261023'
              unit         = 'BOX'
              options      = VALUE #( include_po_receipts = 'Y' ) ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_proj_receipts_opts_uom(
          it_requests = VALUE #(
            ( request_id   = 'UOM-1'
              material     = 'MAT-1'
              plant        = '1000'
              through_date = '20261023'
              options      = VALUE #( include_po_receipts = abap_true ) ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_proj_receipts_opts_uom(
          it_requests = VALUE #(
            ( request_id   = 'UOM-1'
              material     = 'MAT-1'
              plant        = '1000'
              through_date = '20261023'
              unit         = 'BOX'
              options      = VALUE #( include_po_receipts = abap_true ) )
            ( request_id   = 'UOM-1'
              material     = 'MAT-1'
              plant        = '1000'
              through_date = '20261024'
              unit         = 'BOX'
              options      = VALUE #( include_prod_receipts = abap_true ) ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_proj_receipts_opts_uom(
          it_requests = VALUE #(
            ( request_id   = 'UOM-1'
              material     = 'MAT-1'
              plant        = '1000'
              through_date = '20261023'
              unit         = 'ZZZ'
              options      = VALUE #( include_po_receipts = abap_true ) ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    DATA(lt_empty_results) = lo_cut->get_proj_receipts_opts_uom(
      it_requests = VALUE #( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_empty_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_proj_receipts_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_projected_receipts(
      it_receipts = VALUE #(
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261022'
          quantity        = '24.000'
          source_type     = 'PO'
          source_document = '4500000010'
          source_item     = '00020' )
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261023'
          quantity        = '12.000'
          source_type     = 'PRODUCTION'
          source_document = '0000004711'
          source_item     = '0010' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(lt_receipts) = lo_cut->get_projected_receipts_in_unit(
      iv_material              = 'MAT-1'
      iv_plant                 = '1000'
      iv_through_date          = '20261023'
      iv_unit                  = 'BOX'
      iv_include_po_receipts   = abap_true
      iv_include_prod_receipts = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_receipts[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lt_receipts[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_receipts[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PO'
      act = lt_receipts[ 1 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000010'
      act = lt_receipts[ 1 ]-source_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00020'
      act = lt_receipts[ 1 ]-source_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_receipts[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_po_conf_receipts_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_projected_receipts(
      it_receipts = VALUE #(
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261023'
          quantity        = '24.000'
          source_type     = 'PO'
          source_document = '4500000010'
          source_item     = '00010' )
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261024'
          quantity        = '12.000'
          source_type     = 'PO_CONFIRMATION'
          source_document = '4500000011'
          source_item     = '00020' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(lt_receipts) = lo_cut->get_po_conf_receipts_in_unit(
      iv_material     = 'MAT-1'
      iv_plant        = '1000'
      iv_through_date = '20261024'
      iv_unit         = 'BOX' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_receipts[ 2 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lt_receipts[ 2 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_receipts[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PO_CONFIRMATION'
      act = lt_receipts[ 2 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_proj_receipts_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->get_projected_receipts_in_unit(
          iv_material              = 'MAT-1'
          iv_plant                 = '1000'
          iv_through_date          = '20261023'
          iv_unit                  = 'BOX'
          iv_include_fixed_planned = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_projected_receipts_in_unit(
          iv_material            = 'MAT-1'
          iv_plant               = '1000'
          iv_through_date        = '20261023'
          iv_unit                = 'ZZZ'
          iv_include_po_receipts = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_stock_status_in_unit.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_stock_status(
      is_status = VALUE #(
        unrestricted_quantity       = '24.000'
        reserved_quantity           = '6.000'
        available_unrestricted_qty  = '18.000'
        safety_stock_quantity       = '12.000'
        available_after_safety_qty  = '6.000'
        quality_inspection_quantity = '12.000'
        blocked_quantity            = '6.000' ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_status) = lo_cut->get_stock_status_in_unit(
      iv_material = 'MAT-1'
      iv_plant    = '1000'
      iv_unit     = 'BOX' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_status-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = ls_status-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_status-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = ls_status-reserved_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.500' )
      act = ls_status-available_unrestricted_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_status-safety_stock_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = ls_status-available_after_safety_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_status-quality_inspection_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = ls_status-blocked_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_bulk_status_unit.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_stock_status(
      is_status = VALUE #(
        unrestricted_quantity       = '24.000'
        reserved_quantity           = '6.000'
        available_unrestricted_qty  = '18.000'
        safety_stock_quantity       = '12.000'
        available_after_safety_qty  = '6.000'
        quality_inspection_quantity = '12.000'
        blocked_quantity            = '6.000' ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(lt_status) = lo_cut->get_stock_status_bulk_in_unit(
      it_requests = VALUE #(
        ( request_id = 'STAT-1'
          material   = 'MAT-1'
          plant      = '1000'
          unit       = 'BOX' )
        ( request_id = 'STAT-2'
          material   = 'MAT-1'
          plant      = '2000'
          unit       = 'BOX' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_status ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'STAT-1'
      act = lt_status[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_status[ 1 ]-status-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lt_status[ 1 ]-status-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = lt_status[ 2 ]-status-plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_status[ 2 ]-status-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_status[ 2 ]-status-reserved_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.500' )
      act = lt_status[ 2 ]-status-available_unrestricted_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_status[ 2 ]-status-safety_stock_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_status[ 2 ]-status-available_after_safety_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_status[ 2 ]-status-quality_inspection_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_status[ 2 ]-status-blocked_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_bulk_status_unit.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->get_stock_status_bulk_in_unit(
          it_requests = VALUE #(
            ( request_id = 'STAT-1'
              material   = 'MAT-1'
              plant      = '1000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_stock_status_bulk_in_unit(
          it_requests = VALUE #(
            ( request_id = 'STAT-1'
              material   = 'MAT-1'
              plant      = '1000'
              unit       = 'BOX' )
            ( request_id = 'STAT-1'
              material   = 'MAT-2'
              plant      = '2000'
              unit       = 'BOX' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_stock_status_bulk_in_unit(
          it_requests = VALUE #(
            ( request_id = 'STAT-1'
              material   = 'MAT-1'
              plant      = '1000'
              unit       = 'BOX' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    DATA(lt_empty_status) = lo_cut->get_stock_status_bulk_in_unit(
      it_requests = VALUE #( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_empty_status ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_location_stock_status.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_location_stock_status(
      it_status = VALUE #(
        ( storage_location           = '0001'
          unrestricted_quantity      = '5.000'
          available_unrestricted_qty = '3.000'
          quality_inspection_qty     = '1.000'
          blocked_quantity           = '2.000' )
        ( storage_location           = '0002'
          unrestricted_quantity      = '4.000'
          available_unrestricted_qty = '0.000'
          quality_inspection_qty     = '0.500'
          blocked_quantity           = '0.000' ) ) ).

    DATA(lt_status) = lo_cut->get_stock_status_by_location(
      iv_material = 'MAT-1'
      iv_plant    = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_status ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_status[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lt_status[ 1 ]-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_status[ 1 ]-available_unrestricted_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-speme( '2.000' )
      act = lt_status[ 1 ]-blocked_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-insme( '0.500' )
      act = lt_status[ 2 ]-quality_inspection_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_status[ 2 ]-available_unrestricted_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_location_status_unit.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_location_stock_status(
      it_status = VALUE #(
        ( storage_location           = '0001'
          unrestricted_quantity      = '24.000'
          available_unrestricted_qty = '18.000'
          quality_inspection_qty     = '12.000'
          blocked_quantity           = '6.000' )
        ( storage_location           = '0002'
          unrestricted_quantity      = '12.000'
          available_unrestricted_qty = '6.000'
          quality_inspection_qty     = '0.000'
          blocked_quantity           = '3.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(lt_status) = lo_cut->get_stock_by_location_in_unit(
      iv_material = 'MAT-1'
      iv_plant    = '1000'
      iv_unit     = 'BOX' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_status ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_status[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_status[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lt_status[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_status[ 1 ]-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.500' )
      act = lt_status[ 1 ]-available_unrestricted_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_status[ 1 ]-quality_inspection_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_status[ 1 ]-blocked_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_status[ 2 ]-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_location_bulk_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_location_stock_status(
      it_status = VALUE #(
        ( storage_location           = '0001'
          unrestricted_quantity      = '24.000'
          available_unrestricted_qty = '18.000'
          quality_inspection_qty     = '12.000'
          blocked_quantity           = '6.000' )
        ( storage_location           = '0002'
          unrestricted_quantity      = '12.000'
          available_unrestricted_qty = '0.000'
          quality_inspection_qty     = '0.000'
          blocked_quantity           = '0.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(lt_status) = lo_cut->get_location_stock_bulk_uom(
      it_requests = VALUE #(
        ( request_id = 'LOC-UNIT-1'
          material   = 'MAT-1'
          plant      = '1000'
          unit       = 'BOX' )
        ( request_id = 'LOC-UNIT-2'
          material   = 'MAT-1'
          plant      = '2000'
          unit       = 'BOX' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_status ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LOC-UNIT-1'
      act = lt_status[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_status[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lt_status[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_status[ 1 ]-locations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_status[ 1 ]-locations[ 1 ]-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.500' )
      act = lt_status[ 1 ]-locations[ 1 ]-available_unrestricted_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_status[ 1 ]-locations[ 1 ]-quality_inspection_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_status[ 1 ]-locations[ 1 ]-blocked_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_status[ 2 ]-locations[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_status[ 2 ]-locations[ 2 ]-available_unrestricted_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_location_bulk_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->get_location_stock_bulk_uom(
          it_requests = VALUE #(
            ( request_id = 'LOC-UNIT-1'
              material   = 'MAT-1'
              plant      = '1000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_location_stock_bulk_uom(
          it_requests = VALUE #(
            ( request_id = 'LOC-UNIT-1'
              material   = 'MAT-1'
              plant      = '1000'
              unit       = 'BOX' )
            ( request_id = 'LOC-UNIT-1'
              material   = 'MAT-2'
              plant      = '2000'
              unit       = 'BOX' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_location_stock_bulk_uom(
          it_requests = VALUE #(
            ( request_id = 'LOC-UNIT-1'
              material   = 'MAT-1'
              plant      = '1000'
              unit       = 'BOX' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    DATA(lt_empty_status) = lo_cut->get_location_stock_bulk_uom(
      it_requests = VALUE #( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_empty_status ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_batch_stock_status.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stock_status(
      it_status = VALUE #(
        ( storage_location            = '0001'
          batch                       = 'B-1'
          expiration_date             = '20261231'
          unrestricted_quantity       = '5.000'
          available_quantity          = '2.000'
          quality_inspection_quantity = '7.000'
          blocked_quantity            = '1.000' )
        ( storage_location      = '0002'
          batch                 = 'B-2'
          expiration_date       = '20270131'
          unrestricted_quantity = '3.000'
          available_quantity    = '0.000' ) ) ).

    DATA(lt_status) = lo_cut->get_stock_status_by_batch(
      iv_material = 'MAT-1'
      iv_plant    = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_status ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = lt_status[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '5.000' )
      act = lt_status[ 1 ]-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '2.000' )
      act = lt_status[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-cinsm( '7.000' )
      act = lt_status[ 1 ]-quality_inspection_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-cspem( '1.000' )
      act = lt_status[ 1 ]-blocked_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20270131'
      act = lt_status[ 2 ]-expiration_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( 0 )
      act = lt_status[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_bulk_batch_status.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stock_status(
      it_status = VALUE #(
        ( storage_location      = '0001'
          batch                 = 'B-1'
          expiration_date       = '20261231'
          unrestricted_quantity = '5.000'
          available_quantity    = '2.000' )
        ( storage_location      = '0002'
          batch                 = 'B-2'
          expiration_date       = '20270131'
          unrestricted_quantity = '3.000'
          available_quantity    = '0.000' ) ) ).

    DATA(lt_status) = lo_cut->get_batch_stock_status_bulk(
      it_requests = VALUE #(
        ( request_id = 'BAT-1' material = 'MAT-1' plant = '1000' )
        ( request_id = 'BAT-2' material = 'MAT-2' plant = '2000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_status ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BAT-1'
      act = lt_status[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MAT-2'
      act = lt_status[ 2 ]-material ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_status[ 2 ]-batches ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-2'
      act = lt_status[ 2 ]-batches[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20270131'
      act = lt_status[ 2 ]-batches[ 2 ]-expiration_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_bulk_batch_status.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->get_batch_stock_status_bulk(
          it_requests = VALUE #(
            ( material = 'MAT-1' plant = '1000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_batch_stock_status_bulk(
          it_requests = VALUE #(
            ( request_id = 'BAT-1' material = 'MAT-1' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_batch_stock_status_bulk(
          it_requests = VALUE #(
            ( request_id = 'BAT-1' material = 'MAT-1' plant = '1000' )
            ( request_id = 'BAT-1' material = 'MAT-2' plant = '2000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    DATA(lt_empty_status) = lo_cut->get_batch_stock_status_bulk(
      it_requests = VALUE #( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_empty_status ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_bulk_batch_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stock_status(
      it_status = VALUE #(
        ( storage_location            = '0001'
          batch                       = 'B-1'
          expiration_date             = '20261231'
          unrestricted_quantity       = '24.000'
          available_quantity          = '12.000'
          quality_inspection_quantity = '6.000'
          blocked_quantity            = '12.000' )
        ( storage_location      = '0002'
          batch                 = 'B-2'
          expiration_date       = '20270131'
          unrestricted_quantity = '6.000'
          available_quantity    = '0.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(lt_status) = lo_cut->get_batch_stock_bulk_uom(
      it_requests = VALUE #(
        ( request_id = 'UOM-BAT-1'
          material   = 'MAT-1'
          plant      = '1000'
          unit       = 'BOX' )
        ( request_id = 'UOM-BAT-2'
          material   = 'MAT-1'
          plant      = '2000'
          unit       = 'BOX' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_status ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'UOM-BAT-1'
      act = lt_status[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_status[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lt_status[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_status[ 1 ]-batches ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_status[ 1 ]-batches[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = lt_status[ 1 ]-batches[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_status[ 1 ]-batches[ 1 ]-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_status[ 1 ]-batches[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_status[ 1 ]-batches[ 1 ]-quality_inspection_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_status[ 1 ]-batches[ 1 ]-blocked_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = lt_status[ 1 ]-batches[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20270131'
      act = lt_status[ 1 ]-batches[ 2 ]-expiration_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'UOM-BAT-2'
      act = lt_status[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_bulk_batch_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->get_batch_stock_bulk_uom(
          it_requests = VALUE #(
            ( request_id = 'UOM-BAT-1'
              material   = 'MAT-1'
              plant      = '1000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_batch_stock_bulk_uom(
          it_requests = VALUE #(
            ( request_id = 'UOM-BAT-1'
              material   = 'MAT-1'
              plant      = '1000'
              unit       = 'BOX' )
            ( request_id = 'UOM-BAT-1'
              material   = 'MAT-2'
              plant      = '2000'
              unit       = 'BOX' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_batch_stock_bulk_uom(
          it_requests = VALUE #(
            ( request_id = 'UOM-BAT-1'
              material   = 'MAT-1'
              plant      = '1000'
              unit       = 'CASE' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    DATA(lt_empty_status) = lo_cut->get_batch_stock_bulk_uom(
      it_requests = VALUE #( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_empty_status ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_batch_status_in_unit.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stock_status(
      it_status = VALUE #(
        ( storage_location      = '0001'
          batch                 = 'B-1'
          expiration_date       = '20261231'
          unrestricted_quantity = '24.000'
          available_quantity    = '12.000' )
        ( storage_location      = '0002'
          batch                 = 'B-2'
          expiration_date       = '20270131'
          unrestricted_quantity = '6.000'
          available_quantity    = '0.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(lt_status) = lo_cut->get_stock_by_batch_in_unit(
      iv_material = 'MAT-1'
      iv_plant    = '1000'
      iv_unit     = 'BOX' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_status ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = lt_status[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_status[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261231'
      act = lt_status[ 1 ]-expiration_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_status[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lt_status[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_status[ 1 ]-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_status[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_status[ 2 ]-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_fefo_eligible_status.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stock_status(
      it_status = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-EXPIRED'
          expiration_date    = '20260922'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          batch              = 'B-LATER'
          expiration_date    = '20261005'
          available_quantity = '0.000' )
        ( storage_location   = '0003'
          batch              = 'B-UNDATED'
          available_quantity = '4.000' )
        ( storage_location   = '0002'
          batch              = 'B-MINIMUM'
          expiration_date    = '20260930'
          available_quantity = '1.000' )
        ( storage_location   = '0001'
          batch              = 'B-SOON'
          expiration_date    = '20260929'
          available_quantity = '3.000' ) ) ).

    DATA(lt_status) = lo_cut->get_fefo_batch_status(
      iv_material   = 'MAT-1'
      iv_plant      = '1000'
      iv_as_of_date = '20260923'
      iv_min_days   = 7 ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_status ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-MINIMUM'
      act = lt_status[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '1.000' )
      act = lt_status[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = lt_status[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '0.000' )
      act = lt_status[ 2 ]-available_quantity ).

    DATA(lt_all_shelf_life_status) = lo_cut->get_fefo_batch_status(
      iv_material   = 'MAT-1'
      iv_plant      = '1000'
      iv_as_of_date = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_all_shelf_life_status ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-SOON'
      act = lt_all_shelf_life_status[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-MINIMUM'
      act = lt_all_shelf_life_status[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = lt_all_shelf_life_status[ 3 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-UNDATED'
      act = lt_all_shelf_life_status[ 4 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_fefo_bulk_status.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stock_status(
      it_status = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-EXPIRED'
          expiration_date    = '20260922'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          batch              = 'B-LATER'
          expiration_date    = '20261005'
          available_quantity = '0.000' )
        ( storage_location   = '0003'
          batch              = 'B-UNDATED'
          available_quantity = '4.000' )
        ( storage_location   = '0002'
          batch              = 'B-MINIMUM'
          expiration_date    = '20260930'
          available_quantity = '1.000' )
        ( storage_location   = '0001'
          batch              = 'B-SOON'
          expiration_date    = '20260929'
          available_quantity = '3.000' ) ) ).

    DATA(lt_status) = lo_cut->get_fefo_batch_status_bulk(
      it_requests = VALUE #(
        ( request_id = 'FEFO-ALL'
          material   = 'MAT-1'
          plant      = '1000'
          as_of_date = '20260923'
          min_days   = 0 )
        ( request_id = 'FEFO-MIN'
          material   = 'MAT-2'
          plant      = '2000'
          as_of_date = '20260923'
          min_days   = 7 ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_status ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'FEFO-ALL'
      act = lt_status[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_status[ 1 ]-batches ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-SOON'
      act = lt_status[ 1 ]-batches[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-UNDATED'
      act = lt_status[ 1 ]-batches[ 4 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_status[ 2 ]-batches ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-MINIMUM'
      act = lt_status[ 2 ]-batches[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 7
      act = lt_status[ 2 ]-min_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_fefo_bulk.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->get_fefo_batch_status_bulk(
          it_requests = VALUE #(
            ( material   = 'MAT-1'
              plant      = '1000'
              as_of_date = '20260923' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_fefo_batch_status_bulk(
          it_requests = VALUE #(
            ( request_id = 'FEFO-1'
              material   = 'MAT-1'
              plant      = '1000'
              min_days   = 0 ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_fefo_batch_status_bulk(
          it_requests = VALUE #(
            ( request_id = 'FEFO-1'
              material   = 'MAT-1'
              plant      = '1000'
              as_of_date = '20260923'
              min_days   = -1 ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_fefo_batch_status_bulk(
          it_requests = VALUE #(
            ( request_id = 'FEFO-1'
              material   = 'MAT-1'
              plant      = '1000'
              as_of_date = '20260923'
              min_days   = 0 )
            ( request_id = 'FEFO-1'
              material   = 'MAT-2'
              plant      = '2000'
              as_of_date = '20260923'
              min_days   = 0 ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    DATA(lt_empty_status) = lo_cut->get_fefo_batch_status_bulk(
      it_requests = VALUE #( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_empty_status ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_fefo_bulk_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stock_status(
      it_status = VALUE #(
        ( storage_location      = '0001'
          batch                 = 'B-SOON'
          expiration_date       = '20260929'
          unrestricted_quantity = '24.000'
          available_quantity    = '12.000' )
        ( storage_location      = '0002'
          batch                 = 'B-LATER'
          expiration_date       = '20261005'
          unrestricted_quantity = '36.000'
          available_quantity    = '24.000' )
        ( storage_location      = '0003'
          batch                 = 'B-UNDATED'
          unrestricted_quantity = '12.000'
          available_quantity    = '12.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(lt_status) = lo_cut->get_fefo_batch_status_bulk_uom(
      it_requests = VALUE #(
        ( request_id = 'UOM-ALL'
          material   = 'MAT-1'
          plant      = '1000'
          as_of_date = '20260923'
          min_days   = 0
          unit       = 'BOX' )
        ( request_id = 'UOM-MIN'
          material   = 'MAT-1'
          plant      = '1000'
          as_of_date = '20260923'
          min_days   = 7
          unit       = 'BOX' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_status ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'UOM-ALL'
      act = lt_status[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_status[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lt_status[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_status[ 1 ]-batches ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-SOON'
      act = lt_status[ 1 ]-batches[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_status[ 1 ]-batches[ 1 ]-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_status[ 1 ]-batches[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_status[ 2 ]-batches ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = lt_status[ 2 ]-batches[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_status[ 2 ]-batches[ 1 ]-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_fefo_bulk_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->get_fefo_batch_status_bulk_uom(
          it_requests = VALUE #(
            ( request_id = 'UOM-1'
              material   = 'MAT-1'
              plant      = '1000'
              as_of_date = '20260923'
              min_days   = 0 ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_fefo_batch_status_bulk_uom(
          it_requests = VALUE #(
            ( request_id = 'UOM-1'
              material   = 'MAT-1'
              plant      = '1000'
              as_of_date = '20260923'
              min_days   = 0
              unit       = 'BOX' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    DATA(lt_empty_status) = lo_cut->get_fefo_batch_status_bulk_uom(
      it_requests = VALUE #( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_empty_status ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_fefo_status_in_unit.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stock_status(
      it_status = VALUE #(
        ( storage_location      = '0001'
          batch                 = 'B-EXPIRED'
          expiration_date       = '20260922'
          unrestricted_quantity = '12.000'
          available_quantity    = '12.000' )
        ( storage_location      = '0002'
          batch                 = 'B-LATER'
          expiration_date       = '20261005'
          unrestricted_quantity = '24.000'
          available_quantity    = '12.000' )
        ( storage_location      = '0003'
          batch                 = 'B-SOON'
          expiration_date       = '20260929'
          unrestricted_quantity = '36.000'
          available_quantity    = '24.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(lt_status) = lo_cut->get_fefo_batch_status_in_unit(
      iv_material   = 'MAT-1'
      iv_plant      = '1000'
      iv_unit       = 'BOX'
      iv_as_of_date = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_status ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-SOON'
      act = lt_status[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_status[ 1 ]-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_status[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lt_status[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = lt_status[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_invalid_fefo_status.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->get_fefo_batch_status(
          iv_material = 'MAT-1'
          iv_plant    = '1000'
          iv_min_days = -1 ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_available_quantity.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    lo_repository->set_stock( iv_quantity = '17.250' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '17.250' )
      act = lo_cut->get_unrestricted_stock(
        iv_material = 'MAT-1'
        iv_plant    = '1000' ) ).
  ENDMETHOD.

  METHOD rejects_blank_stock_read_keys.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->get_unrestricted_stock(
          iv_material = space
          iv_plant    = '1000' ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_unrestricted_stock(
          iv_material = 'MAT-1'
          iv_plant    = space ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_unrestricted_stock(
          iv_material             = 'MAT-1'
          iv_plant                = '1000'
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD returns_zero_when_no_stock.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = lo_cut->get_unrestricted_stock(
        iv_material = 'MAT-1'
        iv_plant    = '1000' ) ).
  ENDMETHOD.

  METHOD allocates_requested_quantity.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    lo_repository->set_stock( iv_quantity = '17.250' ).

    DATA(ls_allocation) = lo_cut->allocate_request(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_requested_quantity = '10.000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '17.250' )
      act = ls_allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = ls_allocation-shortfall_quantity ).
  ENDMETHOD.

  METHOD requires_full_local_quantity.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_stock( iv_quantity = '3.000' ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA(lv_rejected) = abap_false.

    TRY.
        lo_cut->allocate_demands_in_units(
          it_demands               = VALUE #(
            ( request_id         = 'INVALID'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          iv_require_full_quantity = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    DATA(lt_allocations) = lo_cut->allocate_demands(
      it_demands               = VALUE #(
        ( request_id         = 'SHORT'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '4.000' )
        ( request_id         = 'FULL'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '3.000' ) )
      iv_require_full_quantity = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_allocations[ 2 ]-allocated_quantity ).

    DATA(lt_row_allocations) = lo_cut->allocate_demands(
      it_demands = VALUE #(
        ( request_id            = 'ROW-SHORT'
          material              = 'MAT-1'
          plant                 = '1000'
          requested_quantity    = '4.000'
          require_full_quantity = abap_true )
        ( request_id         = 'ROW-PARTIAL'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '2.000' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_row_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_row_allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_row_allocations[ 2 ]-allocated_quantity ).

    DATA(lt_row_unit_allocations) = lo_cut->allocate_demands_in_units(
      it_demands = VALUE #(
        ( request_id            = 'ROW-BOX-SHORT'
          material              = 'MAT-1'
          plant                 = '1000'
          requested_quantity    = '2.000'
          requested_unit        = 'BOX'
          require_full_quantity = abap_true )
        ( request_id         = 'ROW-BOX-PARTIAL'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_row_unit_allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_row_unit_allocations[ 2 ]-allocation-allocated_quantity ).

    DATA(lt_unit_allocations) = lo_cut->allocate_demands_in_units(
      it_demands               = VALUE #(
        ( request_id         = 'BOX-DEMAND'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' ) )
      iv_require_full_quantity = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_unit_allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_unit_allocations[ 1 ]-allocation-shortfall_quantity ).

    DATA(ls_unit_allocation) = lo_cut->allocate_request_in_unit(
      iv_material              = 'MAT-1'
      iv_plant                 = '1000'
      iv_requested_quantity    = '2.000'
      iv_requested_unit        = 'BOX'
      iv_require_full_quantity = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_unit_allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_unit_allocation-allocation-shortfall_quantity ).
  ENDMETHOD.

  METHOD allocates_request_by_date.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_date_stock(
      iv_quantity = '12.000'
      iv_date     = '20261231' ).

    DATA(ls_allocation) = lo_cut->allocate_request_by_date(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_required_date      = '20261231'
      iv_requested_quantity = '15.000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = '20261231'
      act = ls_allocation-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD requires_full_local_date.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_date_stock(
      iv_material = 'MAT-4'
      iv_plant    = '1000'
      iv_date     = '20261001'
      iv_quantity = '3.000' ).
    lo_repository->set_date_stock(
      iv_material = 'MAT-4'
      iv_plant    = '1000'
      iv_date     = '20261101'
      iv_quantity = '3.000' ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).

    DATA(ls_request_result) = lo_cut->allocate_request_by_date(
      iv_material              = 'MAT-4'
      iv_plant                 = '1000'
      iv_required_date         = '20261001'
      iv_requested_quantity    = '4.000'
      iv_require_full_quantity = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_request_result-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_request_result-shortfall_quantity ).

    DATA(lt_date_result) = lo_cut->allocate_demands_by_date(
      it_demands               = VALUE #(
        ( request_id         = 'DATE-SHORT'
          material           = 'MAT-4'
          plant              = '1000'
          required_date      = '20261001'
          requested_quantity = '4.000' )
        ( request_id         = 'DATE-FULL'
          material           = 'MAT-4'
          plant              = '1000'
          required_date      = '20261101'
          requested_quantity = '3.000' ) )
      iv_require_full_quantity = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_date_result[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_date_result[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_date_result[ 2 ]-allocated_quantity ).

    DATA(lt_row_date_result) = lo_cut->allocate_demands_by_date(
      it_demands = VALUE #(
        ( request_id            = 'DATE-ROW-SHORT'
          material              = 'MAT-4'
          plant                 = '1000'
          required_date         = '20261001'
          priority              = 2
          requested_quantity    = '4.000'
          require_full_quantity = abap_true )
        ( request_id         = 'DATE-ROW-PARTIAL'
          material           = 'MAT-4'
          plant              = '1000'
          required_date      = '20261001'
          priority           = 1
          requested_quantity = '2.000' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_row_date_result[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_row_date_result[ 2 ]-allocated_quantity ).

    DATA(lt_row_date_uom_result) = lo_cut->allocate_date_demands_in_units(
      it_demands = VALUE #(
        ( request_id            = 'DATE-UOM-ROW-SHORT'
          material              = 'MAT-4'
          plant                 = '1000'
          required_date         = '20261001'
          priority              = 2
          requested_quantity    = '2.000'
          requested_unit        = 'BOX'
          require_full_quantity = abap_true )
        ( request_id         = 'DATE-UOM-ROW-PARTIAL'
          material           = 'MAT-4'
          plant              = '1000'
          required_date      = '20261001'
          priority           = 1
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_row_date_uom_result[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_row_date_uom_result[ 2 ]-allocated_source_quantity ).

    DATA(lt_atp_result) = lo_cut->allocate_date_demands_atp(
      it_demands               = VALUE #(
        ( request_id         = 'DATE-ATP'
          material           = 'MAT-4'
          plant              = '1000'
          required_date      = '20261001'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' ) )
      iv_check_rule            = 'A'
      iv_require_full_quantity = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_atp_result[ 1 ]-local_estimate-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_atp_result[ 1 ]-local_estimate-allocation-shortfall_quantity ).

    DATA(ls_atp_request) = lo_cut->allocate_request_date_atp(
      iv_material              = 'MAT-4'
      iv_plant                 = '1000'
      iv_unit                  = 'BOX'
      iv_check_rule            = 'A'
      iv_required_date         = '20261001'
      iv_requested_quantity    = '2.000'
      iv_require_full_quantity = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_atp_request-local_estimate-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_atp_request-local_estimate-shortfall_quantity ).
  ENDMETHOD.

  METHOD requires_full_detailed_local.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_stock( iv_quantity = '3.000' ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          expiration_date    = '20261010'
          available_quantity = '3.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_location_result) = lo_cut->allocate_by_storage_location(
      it_demands               = VALUE #(
        ( request_id         = 'LOC-SHORT'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '4.000' ) )
      iv_require_full_quantity = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_location_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_location_result-allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_location_result-storage_allocations ) ).

    DATA(ls_location_row_result) = lo_cut->allocate_by_storage_location(
      it_demands = VALUE #(
        ( request_id            = 'LOC-ROW-FULL'
          material              = 'MAT-1'
          plant                 = '1000'
          requested_quantity    = '4.000'
          require_full_quantity = abap_true )
        ( request_id         = 'LOC-ROW-PARTIAL'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '2.000' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_location_row_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_location_row_result-allocations[ 2 ]-allocated_quantity ).

    DATA(ls_location_unit_row_result) = lo_cut->allocate_by_location_in_units(
      it_demands = VALUE #(
        ( request_id            = 'LOC-ROW-FULL-BOX'
          material              = 'MAT-1'
          plant                 = '1000'
          requested_quantity    = '2.000'
          requested_unit        = 'BOX'
          require_full_quantity = abap_true )
        ( request_id         = 'LOC-ROW-PARTIAL-BOX'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_location_unit_row_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_location_unit_row_result-allocations[ 2 ]-allocation-allocated_quantity ).

    DATA(ls_batch_result) = lo_cut->allocate_by_batch(
      it_demands               = VALUE #(
        ( request_id         = 'BATCH-SHORT'
          material           = 'MAT-1'
          plant              = '1000'
          batch              = 'B-1'
          requested_quantity = '4.000' ) )
      iv_require_full_quantity = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_batch_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_batch_result-allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_batch_result-batch_allocations ) ).

    DATA(ls_batch_row_result) = lo_cut->allocate_by_batch(
      it_demands = VALUE #(
        ( request_id            = 'BATCH-ROW-FULL'
          material              = 'MAT-1'
          plant                 = '1000'
          batch                 = 'B-1'
          requested_quantity    = '4.000'
          require_full_quantity = abap_true )
        ( request_id         = 'BATCH-ROW-PARTIAL'
          material           = 'MAT-1'
          plant              = '1000'
          batch              = 'B-1'
          requested_quantity = '2.000' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_batch_row_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_batch_row_result-allocations[ 2 ]-allocated_quantity ).

    DATA(ls_fefo_result) = lo_cut->allocate_by_expiry(
      it_demands               = VALUE #(
        ( request_id         = 'FEFO-SHORT'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '4.000' ) )
      iv_as_of_date            = '20261001'
      iv_require_full_quantity = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_fefo_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_fefo_result-allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_fefo_result-batch_allocations ) ).

    DATA(ls_location_unit_result) = lo_cut->allocate_by_location_in_units(
      it_demands               = VALUE #(
        ( request_id         = 'LOC-BOX-SHORT'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' ) )
      iv_require_full_quantity = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_location_unit_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_location_unit_result-allocations[ 1 ]-allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_location_unit_result-allocations[ 1 ]-shortfall_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_location_unit_result-storage_allocations ) ).

    DATA(ls_batch_unit_result) = lo_cut->allocate_by_batch_in_units(
      it_demands               = VALUE #(
        ( request_id         = 'BATCH-BOX-SHORT'
          material           = 'MAT-1'
          plant              = '1000'
          batch              = 'B-1'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' ) )
      iv_require_full_quantity = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_batch_unit_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_batch_unit_result-allocations[ 1 ]-allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_batch_unit_result-allocations[ 1 ]-shortfall_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_batch_unit_result-batch_allocations ) ).

    DATA(ls_batch_unit_row_result) = lo_cut->allocate_by_batch_in_units(
      it_demands = VALUE #(
        ( request_id            = 'BATCH-ROW-FULL-BOX'
          material              = 'MAT-1'
          plant                 = '1000'
          batch                 = 'B-1'
          requested_quantity    = '2.000'
          requested_unit        = 'BOX'
          require_full_quantity = abap_true )
        ( request_id         = 'BATCH-ROW-PARTIAL-BOX'
          material           = 'MAT-1'
          plant              = '1000'
          batch              = 'B-1'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_batch_unit_row_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_batch_unit_row_result-allocations[ 2 ]-allocation-allocated_quantity ).

    DATA(ls_fefo_unit_result) = lo_cut->allocate_by_expiry_in_units(
      it_demands               = VALUE #(
        ( request_id         = 'FEFO-BOX-SHORT'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' ) )
      iv_as_of_date            = '20261001'
      iv_require_full_quantity = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_fefo_unit_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_fefo_unit_result-allocations[ 1 ]-allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_fefo_unit_result-allocations[ 1 ]-shortfall_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_fefo_unit_result-batch_allocations ) ).
  ENDMETHOD.

  METHOD excludes_undated_fefo_local.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-DATED'
          expiration_date    = '20261010'
          available_quantity = '2.000' )
        ( storage_location   = '0001'
          batch              = 'B-UNDATED'
          available_quantity = '5.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA(lv_rejected) = abap_false.

    TRY.
        lo_cut->allocate_by_expiry_in_units(
          it_demands                 = VALUE #(
            ( request_id         = 'BAD-FEFO-FLAG'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '2.000'
              requested_unit     = 'BOX' ) )
          iv_include_undated_batches = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    DATA(ls_excluded) = lo_cut->allocate_by_expiry(
      it_demands                 = VALUE #(
        ( request_id         = 'DATED-ONLY'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '4.000' ) )
      iv_as_of_date              = '20261001'
      iv_include_undated_batches = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_excluded-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_excluded-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_excluded-allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_excluded-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-DATED'
      act = ls_excluded-batch_allocations[ 1 ]-batch ).

    DATA(ls_strict_excluded) = lo_cut->allocate_by_expiry(
      it_demands                 = VALUE #(
        ( request_id         = 'STRICT-DATED-ONLY'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '4.000' ) )
      iv_as_of_date              = '20261001'
      iv_include_undated_batches = abap_false
      iv_require_full_quantity   = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_strict_excluded-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_strict_excluded-allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_strict_excluded-batch_allocations ) ).

    DATA(ls_default) = lo_cut->allocate_by_expiry(
      it_demands    = VALUE #(
        ( request_id         = 'DEFAULT-UNDATED'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '4.000' ) )
      iv_as_of_date = '20261001' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_default-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_default-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-UNDATED'
      act = ls_default-batch_allocations[ 2 ]-batch ).

    DATA(ls_unit_excluded) = lo_cut->allocate_by_expiry_in_units(
      it_demands                 = VALUE #(
        ( request_id         = 'BOX-DATED-ONLY'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' ) )
      iv_as_of_date              = '20261001'
      iv_include_undated_batches = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_unit_excluded-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_unit_excluded-allocations[ 1 ]-allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_unit_excluded-allocations[ 1 ]-shortfall_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_unit_excluded-batch_allocations ) ).
  ENDMETHOD.

  METHOD excludes_undated_fefo_xplant.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-DATED'
          expiration_date    = '20261010'
          available_quantity = '2.000' )
        ( storage_location   = '0001'
          batch              = 'B-UNDATED'
          available_quantity = '5.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA(lo_atp_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).
    DATA(lv_rejected) = abap_false.

    TRY.
        lo_cut->allocate_plants_fefo_in_units(
          it_demands                 = VALUE #(
            ( request_id         = 'BAD-FEFO-FLAG'
              material           = 'MAT-1'
              target_plant       = '9000'
              requested_quantity = '2.000'
              requested_unit     = 'BOX' ) )
          it_sources                 = VALUE #(
            ( request_id = 'BAD-FEFO-FLAG' source_plant = '2000' ) )
          iv_include_undated_batches = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    DATA(ls_plant_result) = lo_cut->allocate_plants_by_expiry(
      it_demands                 = VALUE #(
        ( request_id         = 'PLANT-FEFO'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '4.000' ) )
      it_sources                 = VALUE #(
        ( request_id = 'PLANT-FEFO' source_plant = '2000' ) )
      iv_as_of_date              = '20261001'
      iv_include_undated_batches = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_plant_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_plant_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_plant_result-batch_allocations ) ).

    DATA(ls_unit_result) = lo_cut->allocate_plants_fefo_in_units(
      it_demands                 = VALUE #(
        ( request_id         = 'PLANT-FEFO-BOX'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' ) )
      it_sources                 = VALUE #(
        ( request_id = 'PLANT-FEFO-BOX' source_plant = '2000' ) )
      iv_as_of_date              = '20261001'
      iv_include_undated_batches = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_unit_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_unit_result-allocations[ 1 ]-shortfall_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_unit_result-batch_allocations ) ).

    DATA(ls_date_result) = lo_cut->allocate_plants_fefo_by_date(
      it_demands                 = VALUE #(
        ( request_id         = 'DATE-FEFO'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261001'
          requested_quantity = '4.000' ) )
      it_sources                 = VALUE #(
        ( request_id = 'DATE-FEFO' source_plant = '2000' ) )
      iv_include_undated_batches = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_date_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_date_result-allocations[ 1 ]-allocated_quantity ).

    DATA(ls_date_unit_result) = lo_cut->allocate_plants_fefo_date_uom(
      it_demands                 = VALUE #(
        ( request_id         = 'DATE-FEFO-BOX'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261001'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' ) )
      it_sources                 = VALUE #(
        ( request_id = 'DATE-FEFO-BOX' source_plant = '2000' ) )
      iv_include_undated_batches = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_date_unit_result-allocations[ 1 ]-allocation-allocated_quantity ).

    DATA(ls_atp_result) = lo_atp_cut->allocate_plants_fefo_date_atp(
      it_demands                 = VALUE #(
        ( request_id         = 'DATE-FEFO-ATP'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261001'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' ) )
      it_sources                 = VALUE #(
        ( request_id = 'DATE-FEFO-ATP' source_plant = '2000' ) )
      iv_check_rule              = 'A'
      iv_include_undated_batches = abap_false
      iv_require_full_quantity   = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_atp_result-local_estimate-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_availability_api->get_check_count( ) ).
  ENDMETHOD.

  METHOD allocates_sched_agmt_receipts.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_date_stock(
      iv_quantity = '8.000'
      iv_date     = '20261231' ).
    lo_repository->set_projected_receipts(
      it_receipts = VALUE #(
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261230'
          quantity        = '4.000'
          source_type     = 'SCHED_AGREEMENT'
          source_document = '5500000010' ) ) ).

    DATA(ls_local) = lo_cut->allocate_request_by_date(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_required_date      = '20261231'
      iv_requested_quantity = '12.000' ).
    DATA(ls_projected) = lo_cut->allocate_request_by_date(
      iv_material                    = 'MAT-1'
      iv_plant                       = '1000'
      iv_required_date               = '20261231'
      iv_requested_quantity          = '12.000'
      iv_include_sched_agmt_receipts = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_local-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_projected-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_projected-allocated_quantity ).
  ENDMETHOD.

  METHOD allocates_with_pr_receipts.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_date_stock(
      iv_quantity            = '8.000'
      iv_pr_receipt_quantity = '3.000'
      iv_date                = '20261231' ).

    DATA(ls_local) = lo_cut->allocate_request_by_date(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_required_date      = '20261231'
      iv_requested_quantity = '10.000' ).
    DATA(ls_projected) = lo_cut->allocate_request_by_date(
      iv_material            = 'MAT-1'
      iv_plant               = '1000'
      iv_required_date       = '20261231'
      iv_requested_quantity  = '10.000'
      iv_include_pr_receipts = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_local-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '11.000' )
      act = ls_projected-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_projected-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = ls_projected-shortfall_quantity ).
  ENDMETHOD.

  METHOD allocates_with_sto_pr_receipts.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_date_stock(
      iv_quantity                = '5.000'
      iv_sto_pr_receipt_quantity = '4.000'
      iv_date                    = '20261231' ).

    DATA(ls_local) = lo_cut->allocate_request_by_date(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_required_date      = '20261231'
      iv_requested_quantity = '8.000' ).
    DATA(ls_projected) = lo_cut->allocate_request_by_date(
      iv_material                = 'MAT-1'
      iv_plant                   = '1000'
      iv_required_date           = '20261231'
      iv_requested_quantity      = '8.000'
      iv_include_sto_pr_receipts = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_local-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '9.000' )
      act = ls_projected-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_projected-allocated_quantity ).
  ENDMETHOD.

  METHOD allocates_plan_supply.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_date_stock(
      iv_quantity                 = '5.000'
      iv_planned_receipt_quantity = '4.000'
      iv_fixed_plan_receipt_qty   = '2.000'
      iv_date                     = '20261231' ).

    DATA(ls_local) = lo_cut->allocate_request_by_date(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_required_date      = '20261231'
      iv_requested_quantity = '8.000' ).
    DATA(ls_projected) = lo_cut->allocate_request_by_date(
      iv_material                 = 'MAT-1'
      iv_plant                    = '1000'
      iv_required_date            = '20261231'
      iv_requested_quantity       = '8.000'
      iv_include_planned_receipts = abap_true ).
    DATA(ls_fixed_projected) = lo_cut->allocate_request_by_date(
      iv_material              = 'MAT-1'
      iv_plant                 = '1000'
      iv_required_date         = '20261231'
      iv_requested_quantity    = '8.000'
      iv_include_fixed_planned = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_local-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '9.000' )
      act = ls_projected-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_projected-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = ls_fixed_projected-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = ls_projected-shortfall_quantity ).
  ENDMETHOD.

  METHOD allocates_with_po_receipts.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_date_stock(
      iv_quantity         = '8.000'
      iv_receipt_quantity = '3.000'
      iv_date             = '20261231' ).

    DATA(ls_local) = lo_cut->allocate_request_by_date(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_required_date      = '20261231'
      iv_requested_quantity = '10.000' ).
    DATA(ls_projected) = lo_cut->allocate_request_by_date(
      iv_material            = 'MAT-1'
      iv_plant               = '1000'
      iv_required_date       = '20261231'
      iv_requested_quantity  = '10.000'
      iv_include_po_receipts = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_local-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_local-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '11.000' )
      act = ls_projected-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_projected-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = ls_projected-shortfall_quantity ).
  ENDMETHOD.

  METHOD allocates_po_confirmations.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_date_stock(
      iv_quantity = '8.000'
      iv_date     = '20261231' ).
    lo_repository->set_projected_receipts(
      it_receipts = VALUE #(
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261222'
          quantity        = '2.000'
          source_type     = 'PO'
          source_document = '4500000010' )
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261225'
          quantity        = '5.000'
          source_type     = 'PO_CONFIRMATION'
          source_document = '4500000010' ) ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    DATA(ls_allocation) = lo_cut->allocate_request_by_date(
      iv_material                 = 'MAT-1'
      iv_plant                    = '1000'
      iv_required_date            = '20261231'
      iv_requested_quantity       = '14.000'
      iv_include_po_confirmations = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '15.000' )
      act = ls_allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '14.000' )
      act = ls_allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = ls_allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).
    DATA lv_conflict_rejected TYPE abap_bool.
    TRY.
        lo_cut->allocate_request_by_date(
          iv_material                 = 'MAT-1'
          iv_plant                    = '1000'
          iv_required_date            = '20261231'
          iv_requested_quantity       = '1.000'
          iv_include_po_receipts      = abap_true
          iv_include_po_confirmations = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_conflict_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_conflict_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_with_sto_in_transit.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_date_stock(
      iv_quantity                = '8.000'
      iv_receipt_quantity        = '3.000'
      iv_sto_in_transit_quantity = '4.000'
      iv_date                    = '20261231' ).

    DATA(ls_local) = lo_cut->allocate_request_by_date(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_required_date      = '20261231'
      iv_requested_quantity = '10.000' ).
    DATA(ls_po_projected) = lo_cut->allocate_request_by_date(
      iv_material            = 'MAT-1'
      iv_plant               = '1000'
      iv_required_date       = '20261231'
      iv_requested_quantity  = '10.000'
      iv_include_po_receipts = abap_true ).
    DATA(ls_sto_projected) = lo_cut->allocate_request_by_date(
      iv_material               = 'MAT-1'
      iv_plant                  = '1000'
      iv_required_date          = '20261231'
      iv_requested_quantity     = '10.000'
      iv_include_sto_in_transit = abap_true ).
    DATA(ls_all_projected) = lo_cut->allocate_request_by_date(
      iv_material               = 'MAT-1'
      iv_plant                  = '1000'
      iv_required_date          = '20261231'
      iv_requested_quantity     = '10.000'
      iv_include_po_receipts    = abap_true
      iv_include_sto_in_transit = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_local-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '11.000' )
      act = ls_po_projected-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_sto_projected-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '15.000' )
      act = ls_all_projected-available_quantity ).
  ENDMETHOD.

  METHOD includes_unissued_sto_receipts.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_date_stock(
      iv_quantity                = '8.000'
      iv_sto_in_transit_quantity = '4.000'
      iv_unissued_sto_quantity   = '5.000'
      iv_date                    = '20261231' ).

    DATA(ls_local) = lo_cut->allocate_request_by_date(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_required_date      = '20261231'
      iv_requested_quantity = '20.000' ).
    DATA(ls_unissued) = lo_cut->allocate_request_by_date(
      iv_material             = 'MAT-1'
      iv_plant                = '1000'
      iv_required_date        = '20261231'
      iv_requested_quantity   = '20.000'
      iv_include_unissued_sto = abap_true ).
    DATA(ls_both_sto_states) = lo_cut->allocate_request_by_date(
      iv_material               = 'MAT-1'
      iv_plant                  = '1000'
      iv_required_date          = '20261231'
      iv_requested_quantity     = '20.000'
      iv_include_sto_in_transit = abap_true
      iv_include_unissued_sto   = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_local-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '13.000' )
      act = ls_unissued-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '17.000' )
      act = ls_both_sto_states-available_quantity ).
  ENDMETHOD.

  METHOD subtracts_unissued_sto_demand.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_date_stock(
      iv_material              = 'MAT-1'
      iv_plant                 = '1000'
      iv_date                  = '20261210'
      iv_quantity              = '20.000'
      iv_outgoing_sto_quantity = '5.000' ).
    lo_repository->set_date_stock(
      iv_material              = 'MAT-1'
      iv_plant                 = '2000'
      iv_date                  = '20261210'
      iv_quantity              = '20.000'
      iv_outgoing_sto_quantity = '5.000' ).

    DATA(ls_local) = lo_cut->allocate_request_by_date(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_required_date      = '20261210'
      iv_requested_quantity = '18.000' ).
    DATA(ls_projected) = lo_cut->allocate_request_by_date(
      iv_material              = 'MAT-1'
      iv_plant                 = '1000'
      iv_required_date         = '20261210'
      iv_requested_quantity    = '18.000'
      iv_subtract_unissued_sto = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '20.000' )
      act = ls_local-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '15.000' )
      act = ls_projected-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_projected-shortfall_quantity ).

    DATA(lt_bulk_allocations) = lo_cut->allocate_demands_by_date(
      it_demands               = VALUE zcl_stock_service=>ty_dated_demands(
        ( request_id         = 'FIRST'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = '20261210'
          requested_quantity = '8.000' )
        ( request_id         = 'SECOND'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = '20261210'
          requested_quantity = '8.000' ) )
      iv_subtract_unissued_sto = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '15.000' )
      act = lt_bulk_allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = lt_bulk_allocations[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = lt_bulk_allocations[ 2 ]-allocated_quantity ).

    DATA(ls_plant_result) = lo_cut->allocate_plants_by_date(
      it_demands               = VALUE zcl_stock_service=>ty_date_plant_demands(
        ( request_id         = 'PLANT'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261210'
          requested_quantity = '18.000' ) )
      it_sources               = VALUE zcl_stock_service=>ty_plant_sources(
        ( request_id = 'PLANT' source_plant = '2000' ) )
      iv_subtract_unissued_sto = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '15.000' )
      act = ls_plant_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '15.000' )
      act = ls_plant_result-allocations[ 1 ]-allocated_quantity ).
  ENDMETHOD.

  METHOD allocates_with_prod_receipts.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_date_stock(
      iv_quantity              = '8.000'
      iv_prod_receipt_quantity = '6.000'
      iv_date                  = '20261231' ).

    DATA(ls_local) = lo_cut->allocate_request_by_date(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_required_date      = '20261231'
      iv_requested_quantity = '15.000' ).
    DATA(ls_projected) = lo_cut->allocate_request_by_date(
      iv_material              = 'MAT-1'
      iv_plant                 = '1000'
      iv_required_date         = '20261231'
      iv_requested_quantity    = '15.000'
      iv_include_prod_receipts = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_local-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '14.000' )
      act = ls_projected-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '14.000' )
      act = ls_projected-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_projected-shortfall_quantity ).
  ENDMETHOD.

  METHOD allocates_demands_by_date.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_date_stock(
      iv_quantity = '4.000'
      iv_date     = '20261201' ).
    lo_repository->set_date_stock(
      iv_quantity                = '8.000'
      iv_date                    = '20261231'
      iv_receipt_quantity        = '5.000'
      iv_sto_in_transit_quantity = '2.000'
      iv_prod_receipt_quantity   = '1.000' ).
    lo_repository->set_safety_stock( iv_quantity = '1.000' ).

    DATA(lt_allocations) = lo_cut->allocate_demands_by_date(
      it_demands                = VALUE zcl_stock_service=>ty_dated_demands(
        ( request_id         = 'LATE-1'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = '20261231'
          requested_quantity = '5.000' )
        ( request_id         = 'EARLY'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = '20261201'
          requested_quantity = '4.000' )
        ( request_id         = 'LATE-2'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = '20261231'
          requested_quantity = '4.000' ) )
      iv_include_po_receipts    = abap_true
      iv_include_sto_in_transit = abap_true
      iv_include_prod_receipts  = abap_true
      iv_protect_safety_stock   = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LATE-1'
      act = lt_allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = lt_allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lt_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = lt_allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY'
      act = lt_allocations[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LATE-2'
      act = lt_allocations[ 3 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = lt_allocations[ 3 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_dated_po_conf.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_date_stock(
      iv_material = 'MAT-1'
      iv_plant    = '1000'
      iv_quantity = '8.000'
      iv_date     = '20261223' ).
    lo_repository->set_date_stock(
      iv_material = 'MAT-1'
      iv_plant    = '1000'
      iv_quantity = '10.000'
      iv_date     = '20261226' ).
    lo_repository->set_projected_receipts(
      it_receipts = VALUE #(
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261222'
          quantity        = '2.000'
          source_type     = 'PO'
          source_document = '4500000010' )
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261225'
          quantity        = '5.000'
          source_type     = 'PO_CONFIRMATION'
          source_document = '4500000010' ) ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    DATA(lt_allocations) = lo_cut->allocate_demands_by_date(
      it_demands                  = VALUE #(
        ( request_id         = 'LATE'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = '20261226'
          requested_quantity = '8.000' )
        ( request_id         = 'EARLY'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = '20261223'
          requested_quantity = '10.000' ) )
      iv_include_po_confirmations = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'LATE'
      act = lt_allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = lt_allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = lt_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY'
      act = lt_allocations[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lt_allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD prioritizes_dated_demands.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_date_stock(
      iv_quantity = '5.000'
      iv_date     = '20261201' ).
    lo_repository->set_date_stock(
      iv_quantity = '15.000'
      iv_date     = '20261231' ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    DATA(lt_allocations) = lo_cut->allocate_demands_by_date(
      it_demands = VALUE #(
        ( request_id         = 'LATE-HIGH'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = '20261231'
          priority           = 1000
          requested_quantity = '5.000' )
        ( request_id         = 'EARLY-LOW'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = '20261201'
          priority           = 0
          requested_quantity = '5.000' )
        ( request_id         = 'LATE-A'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = '20261231'
          priority           = 50
          requested_quantity = '5.000' )
        ( request_id         = 'LATE-B'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = '20261231'
          priority           = 50
          requested_quantity = '5.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LATE-HIGH'
      act = lt_allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lt_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1000
      act = lt_allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY-LOW'
      act = lt_allocations[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lt_allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LATE-A'
      act = lt_allocations[ 3 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lt_allocations[ 3 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LATE-B'
      act = lt_allocations[ 4 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = lt_allocations[ 4 ]-allocated_quantity ).
  ENDMETHOD.

  METHOD allocates_po_conf_unit.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_date_stock(
      iv_material = 'MAT-1'
      iv_plant    = '1000'
      iv_quantity = '8.000'
      iv_date     = '20261231' ).
    lo_repository->set_projected_receipts(
      it_receipts = VALUE #(
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261222'
          quantity        = '2.000'
          source_type     = 'PO'
          source_document = '4500000010' )
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261225'
          quantity        = '2.000'
          source_type     = 'PO_CONFIRMATION'
          source_document = '4500000010' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(lt_allocations) = lo_cut->allocate_date_demands_in_units(
      it_demands                  = VALUE #(
        ( request_id         = 'UNIT-CONF'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = '20261231'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) )
      iv_include_po_confirmations = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = lt_allocations[ 1 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_allocations[ 1 ]-available_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD prioritizes_unit_date_demands.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_date_stock(
      iv_quantity = '12.000'
      iv_date     = '20261231' ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(lt_allocations) = lo_cut->allocate_date_demands_in_units(
      it_demands = VALUE #(
        ( request_id         = 'LOW'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = '20261231'
          priority           = 0
          requested_quantity = '1.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'HIGH'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = '20261231'
          priority           = 20
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'LOW'
      act = lt_allocations[ 1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = lt_allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'HIGH'
      act = lt_allocations[ 2 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = lt_allocations[ 2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 20
      act = lt_allocations[ 2 ]-allocation-priority ).
  ENDMETHOD.

  METHOD allocates_dated_unit_demands.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_date_stock(
      iv_quantity = '8.000'
      iv_date     = '20261201' ).
    lo_repository->set_date_stock(
      iv_quantity                = '20.000'
      iv_date                    = '20261231'
      iv_receipt_quantity        = '5.000'
      iv_sto_in_transit_quantity = '2.000'
      iv_prod_receipt_quantity   = '1.000' ).
    lo_repository->set_safety_stock( iv_quantity = '1.000' ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(lt_allocations) = lo_cut->allocate_date_demands_in_units(
      it_demands                = VALUE #(
        ( request_id         = 'LATE-BOX'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = '20261231'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'EARLY-EA'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = '20261201'
          requested_quantity = '4.000'
          requested_unit     = 'EA' )
        ( request_id         = 'LATE-EA'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = '20261231'
          requested_quantity = '3.000'
          requested_unit     = 'EA' ) )
      iv_include_po_receipts    = abap_true
      iv_include_sto_in_transit = abap_true
      iv_include_prod_receipts  = abap_true
      iv_protect_safety_stock   = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LATE-BOX'
      act = lt_allocations[ 1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = lt_allocations[ 1 ]-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '23.000' )
      act = lt_allocations[ 1 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.917' )
      act = lt_allocations[ 1 ]-available_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = lt_allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY-EA'
      act = lt_allocations[ 2 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = lt_allocations[ 2 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_allocations[ 2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LATE-EA'
      act = lt_allocations[ 3 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '11.000' )
      act = lt_allocations[ 3 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_allocations[ 3 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_unknown_date_unit.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_date_demands_in_units(
          it_demands = VALUE #(
            ( request_id         = 'VALID'
              material           = 'MAT-1'
              plant              = '1000'
              required_date      = '20261201'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' )
            ( request_id         = 'UNKNOWN'
              material           = 'MAT-1'
              plant              = '1000'
              required_date      = '20261231'
              requested_quantity = '1.000'
              requested_unit     = 'CASE' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_invalid_dated_list.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_demands_by_date(
          it_demands = VALUE zcl_stock_service=>ty_dated_demands(
            ( request_id         = 'VALID'
              material           = 'MAT-1'
              plant              = '1000'
              required_date      = '20261201'
              requested_quantity = '2.000' )
            ( request_id         = 'NO-DATE'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD protects_dated_safety_stock.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_date_stock(
      iv_quantity = '12.000'
      iv_date     = '20261231' ).
    lo_repository->set_safety_stock( iv_quantity = '3.000' ).

    DATA(ls_allocation) = lo_cut->allocate_request_by_date(
      iv_material             = 'MAT-1'
      iv_plant                = '1000'
      iv_required_date        = '20261231'
      iv_requested_quantity   = '10.000'
      iv_protect_safety_stock = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '9.000' )
      act = ls_allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '9.000' )
      act = ls_allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_missing_demand_date.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_exception_raised TYPE abap_bool.
    DATA lv_required_date TYPE resb-bdter.

    TRY.
        lo_cut->allocate_request_by_date(
          iv_material           = 'MAT-1'
          iv_plant              = '1000'
          iv_required_date      = lv_required_date
          iv_requested_quantity = '1.000' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_invalid_calendar_date.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_demands_by_date(
          it_demands = VALUE zcl_stock_service=>ty_dated_demands(
            ( request_id         = 'VALID'
              material           = 'MAT-1'
              plant              = '1000'
              required_date      = '20260228'
              requested_quantity = '2.000' )
            ( request_id         = 'INVALID'
              material           = 'MAT-1'
              plant              = '1000'
              required_date      = '20260230'
              requested_quantity = '1.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_calendar_uom_date.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_date_demands_in_units(
          it_demands = VALUE #(
            ( request_id         = 'INVALID'
              material           = 'MAT-1'
              plant              = '1000'
              required_date      = '20260230'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_invalid_calendar_fefo.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->get_fefo_batch_status(
          iv_material   = 'MAT-1'
          iv_plant      = '1000'
          iv_as_of_date = '20260230' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD compares_dated_stock_with_atp.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).
    lo_repository->set_date_stock(
      iv_quantity                = '12.000'
      iv_date                    = '20261231'
      iv_receipt_quantity        = '2.000'
      iv_sto_in_transit_quantity = '4.000'
      iv_prod_receipt_quantity   = '3.000' ).
    lo_repository->set_projected_receipts(
      it_receipts = VALUE #(
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261222'
          quantity        = '2.000'
          source_type     = 'PO'
          source_document = '4500000010' ) ) ).
    lo_availability_api->set_result(
      is_result = VALUE #(
        material                       = 'MAT-1'
        plant                          = '1000'
        unit                           = 'EA'
        check_rule                     = 'A'
        required_date                  = '20261231'
        requested_quantity             = '10.000'
        available_at_plant_quantity    = '6.000'
        end_of_replenishment_lead_time = '20270115'
        confirmation_lines             = VALUE #(
          ( requested_date     = '20261231'
            requested_quantity = '10.000'
            confirmed_date     = '20270102'
            confirmed_quantity = '6.000' )
          ( requested_date     = '20270107'
            requested_quantity = '4.000'
            confirmed_date     = '20270109'
            confirmed_quantity = '4.000' ) )
        confirmed_date                 = '20270102'
        confirmed_quantity             = '6.000'
        dialog_flag                    = 'X'
        is_fully_available             = abap_false
        is_check_relevant              = abap_true ) ).

    DATA(ls_result) = lo_cut->allocate_request_date_atp(
      iv_material                 = 'MAT-1'
      iv_plant                    = '1000'
      iv_unit                     = 'EA'
      iv_check_rule               = 'A'
      iv_required_date            = '20261231'
      iv_requested_quantity       = '10.000'
      iv_include_po_confirmations = abap_true
      iv_include_sto_in_transit   = abap_true
      iv_include_prod_receipts    = abap_true ).
    DATA(ls_request) = lo_availability_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '21.000' )
      act = ls_result-local_estimate-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_result-local_estimate-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-atp_result-available_at_plant_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20270115'
      act = ls_result-atp_result-end_of_replenishment_lead_time ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20270102'
      act = ls_result-atp_result-confirmed_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-atp_result-confirmed_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_result-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-atp_result-confirmation_lines ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20270109'
      act = ls_result-atp_result-confirmation_lines[ 2 ]-confirmed_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-atp_result-confirmation_lines[ 2 ]-confirmed_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MAT-1'
      act = ls_request-material ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_request-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'A'
      act = ls_request-check_rule ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261231'
      act = ls_request-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_request-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_availability_api->get_check_count( ) ).
  ENDMETHOD.

  METHOD compares_dated_bulk_atp.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    lo_repository->set_date_stock(
      iv_quantity = '50.000'
      iv_date     = '20261201' ).
    lo_repository->set_date_stock(
      iv_quantity = '50.000'
      iv_date     = '20261231' ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    lo_availability_api->set_result(
      is_result = VALUE #(
        available_at_plant_quantity = '15.000'
        confirmed_quantity          = '9.000'
        confirmation_lines          = VALUE #(
          ( confirmed_date = '20261201' confirmed_quantity = '6.000' )
          ( confirmed_date = '20261201' confirmed_quantity = '3.000' ) )
        dialog_flag                 = 'X'
        is_fully_available          = abap_false
        is_check_relevant           = abap_true ) ).
    lo_availability_api->set_result_for_call(
      iv_call_number = 2
      is_result      = VALUE #(
        available_at_plant_quantity = '15.000'
        confirmed_quantity          = '23.000'
        confirmation_lines          = VALUE #(
          ( confirmed_date = '20261231' confirmed_quantity = '23.000' )
          ( confirmed_date = '20261231' confirmed_quantity = '22.000' ) )
        is_fully_available          = abap_false
        is_check_relevant           = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).

    DATA(lt_allocations) = lo_cut->allocate_date_demands_atp(
      it_demands    = VALUE zcl_stock_service=>ty_date_unit_demands(
        ( request_id         = 'LATE'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = '20261231'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'EARLY-EA'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = '20261201'
          requested_quantity = '4.000'
          requested_unit     = 'EA' )
        ( request_id         = 'EARLY-BOX'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = '20261201'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) )
      iv_check_rule = 'A' ).
    DATA(lt_requests) = lo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LATE'
      act = lt_allocations[ 1 ]-local_estimate-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '40.000' )
      act = lt_allocations[ 1 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '40.000' )
      act = lt_allocations[ 1 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_allocations[ 1 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '34.000' )
      act = lt_allocations[ 1 ]-local_estimate-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY-EA'
      act = lt_allocations[ 2 ]-local_estimate-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '16.000' )
      act = lt_allocations[ 2 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '9.000' )
      act = lt_allocations[ 2 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = lt_allocations[ 2 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '16.000' )
      act = lt_allocations[ 3 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '9.000' )
      act = lt_allocations[ 3 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = lt_allocations[ 3 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '15.000' )
      act = lt_allocations[ 3 ]-atp_result-available_at_plant_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261201'
      act = lt_requests[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_requests[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '16.000' )
      act = lt_requests[ 1 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261231'
      act = lt_requests[ 2 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '40.000' )
      act = lt_requests[ 2 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_availability_api->get_check_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_bulk_atp_without_rule.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_date_demands_atp(
          it_demands    = VALUE zcl_stock_service=>ty_date_unit_demands(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              plant              = '1000'
              required_date      = '20261231'
              requested_quantity = '1.000'
              requested_unit     = 'EA' ) )
          iv_check_rule = space ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_availability_api->get_check_count( ) ).
  ENDMETHOD.

  METHOD compares_dated_alt_unit_atp.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    lo_repository->set_date_stock(
      iv_quantity = '20.000'
      iv_date     = '20261231' ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).
    lo_availability_api->set_result(
      is_result = VALUE #(
        confirmed_quantity = '0.500'
        confirmation_lines = VALUE #(
          ( confirmed_date = '20261231' confirmed_quantity = '0.500' )
          ( confirmed_date = '20261231' confirmed_quantity = '0.500' ) )
        is_fully_available = abap_false
        is_check_relevant  = abap_true ) ).

    DATA(ls_result) = lo_cut->allocate_request_date_atp(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_unit               = 'BOX'
      iv_check_rule         = 'A'
      iv_required_date      = '20261231'
      iv_requested_quantity = '2.000' ).
    DATA(ls_request) = lo_availability_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '24.000' )
      act = ls_result-local_estimate-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '20.000' )
      act = ls_result-local_estimate-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-local_estimate-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = ls_request-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_request-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_availability_api->get_check_count( ) ).
  ENDMETHOD.

  METHOD limits_atp_confirmation_date.
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = NEW lcl_stock_repository_double( ) ).
    DATA(ls_atp_result) = VALUE zif_material_availability_api=>ty_result(
      confirmation_lines = VALUE #(
        ( confirmed_date = '20261005' confirmed_quantity = '4.000' )
        ( confirmed_date = '20261007' confirmed_quantity = '3.000' )
        ( confirmed_quantity = '2.000' ) )
      is_check_relevant  = abap_true ).

    DATA(ls_due_split) = lo_cut->get_atp_confirmation_split(
      iv_requested_base_quantity = '10.000'
      iv_required_date           = '20261005'
      is_atp_result              = ls_atp_result ).
    DATA(ls_later_split) = lo_cut->get_atp_confirmation_split(
      iv_requested_base_quantity = '10.000'
      iv_required_date           = '20261007'
      is_atp_result              = ls_atp_result ).
    DATA(ls_all_split) = lo_cut->get_atp_confirmation_split(
      iv_requested_base_quantity = '10.000'
      is_atp_result              = ls_atp_result ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_due_split-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_due_split-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = ls_later_split-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '9.000' )
      act = ls_all_split-confirmed_base_quantity ).
  ENDMETHOD.

  METHOD rejects_bad_atp_split_inputs.
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = NEW lcl_stock_repository_double( ) ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->get_atp_confirmation_split(
          iv_requested_base_quantity = '1.000'
          iv_numerator               = 12
          iv_denominator             = 0
          is_atp_result              = VALUE #(
            confirmation_lines = VALUE #(
              ( confirmed_quantity = '1.000' ) )
            is_check_relevant  = abap_true ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    CLEAR lv_exception_raised.

    TRY.
        lo_cut->get_atp_confirmation_split(
          iv_requested_base_quantity = '-1.000'
          is_atp_result              = VALUE #(
            is_check_relevant = abap_true ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
  ENDMETHOD.

  METHOD rejects_incomplete_atp_request.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_material_availability_api = lo_availability_api ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_request_date_atp(
          iv_material           = 'MAT-1'
          iv_plant              = '1000'
          iv_unit               = 'EA'
          iv_check_rule         = space
          iv_required_date      = '20261231'
          iv_requested_quantity = '1.000' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_availability_api->get_check_count( ) ).
  ENDMETHOD.

  METHOD reports_partial_shortfall.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    lo_repository->set_stock( iv_quantity = '17.250' ).

    DATA(ls_allocation) = lo_cut->allocate_request(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_requested_quantity = '20.000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '17.250' )
      act = ls_allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.750' )
      act = ls_allocation-shortfall_quantity ).
  ENDMETHOD.

  METHOD negative_stock_is_unavailable.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    lo_repository->set_stock( iv_quantity = '-4.000' ).

    DATA(ls_allocation) = lo_cut->allocate_request(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_requested_quantity = '5.000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = ls_allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = ls_allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_allocation-shortfall_quantity ).
  ENDMETHOD.

  METHOD rejects_negative_request.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_request(
          iv_material           = 'MAT-1'
          iv_plant              = '1000'
          iv_requested_quantity = '-1.000' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
  ENDMETHOD.

  METHOD allocates_demands_in_order.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_stock( iv_quantity = '17.250' ).

    DATA(lt_demands) = VALUE zcl_stock_service=>ty_demands(
      ( request_id         = 'SO-1/10'
        material           = 'MAT-1'
        plant              = '1000'
        requested_quantity = '10.000' )
      ( request_id         = 'SO-2/10'
        material           = 'MAT-1'
        plant              = '1000'
        requested_quantity = '10.000' ) ).
    DATA(lt_allocations) = lo_cut->allocate_demands(
      it_demands = lt_demands ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SO-1/10'
      act = lt_allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lt_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.250' )
      act = lt_allocations[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.250' )
      act = lt_allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.750' )
      act = lt_allocations[ 2 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).

    lo_repository->set_stock( iv_quantity = '3.000' ).
    DATA(lt_priority_allocations) = lo_cut->allocate_demands_by_priority(
      it_demands = VALUE zcl_stock_service=>ty_priority_demands(
        ( request_id         = 'LOW-PRIORITY'
          material           = 'MAT-1'
          plant              = '1000'
          priority           = 1
          requested_quantity = '3.000' )
        ( request_id         = 'HIGH-PRIORITY'
          material           = 'MAT-1'
          plant              = '1000'
          priority           = 10
          requested_quantity = '3.000' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LOW-PRIORITY'
      act = lt_priority_allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lt_priority_allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_priority_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'HIGH-PRIORITY'
      act = lt_priority_allocations[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = lt_priority_allocations[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_priority_allocations[ 2 ]-allocated_quantity ).

    lo_repository->set_stock( iv_quantity = '3.000' ).
    DATA(lt_equal_priority_allocations) = lo_cut->allocate_demands_by_priority(
      it_demands = VALUE zcl_stock_service=>ty_priority_demands(
        ( request_id         = 'FIRST-TIE'
          material           = 'MAT-1'
          plant              = '1000'
          priority           = 5
          requested_quantity = '3.000' )
        ( request_id         = 'SECOND-TIE'
          material           = 'MAT-1'
          plant              = '1000'
          priority           = 5
          requested_quantity = '3.000' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'FIRST-TIE'
      act = lt_equal_priority_allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_equal_priority_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SECOND-TIE'
      act = lt_equal_priority_allocations[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_equal_priority_allocations[ 2 ]-allocated_quantity ).

    DATA lv_duplicate_rejected TYPE abap_bool.
    TRY.
        lo_cut->allocate_demands_by_priority(
          it_demands = VALUE #(
            ( request_id         = 'DUPLICATE'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000' )
            ( request_id         = 'DUPLICATE'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_duplicate_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_duplicate_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD keeps_plant_stock_separate.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_stock( iv_quantity = '17.250' ).

    DATA(lt_demands) = VALUE zcl_stock_service=>ty_demands(
      ( request_id         = 'SO-1/10'
        material           = 'MAT-1'
        plant              = '1000'
        requested_quantity = '10.000' )
      ( request_id         = 'SO-2/10'
        material           = 'MAT-1'
        plant              = '2000'
        requested_quantity = '10.000' ) ).
    DATA(lt_allocations) = lo_cut->allocate_demands(
      it_demands = lt_demands ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lt_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lt_allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_across_plants.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_exception_raised TYPE abap_bool.
    lo_repository->set_plant_stock(
      iv_material = 'MAT-1'
      iv_plant    = '2000'
      iv_quantity = '4.000' ).
    lo_repository->set_plant_stock(
      iv_material = 'MAT-1'
      iv_plant    = '1000'
      iv_quantity = '3.000' ).
    lo_repository->set_plant_location_stock(
      iv_material         = 'MAT-1'
      iv_plant            = '2000'
      iv_storage_location = '0001'
      iv_quantity         = '2.000' ).
    lo_repository->set_plant_location_stock(
      iv_material         = 'MAT-1'
      iv_plant            = '2000'
      iv_storage_location = '0002'
      iv_quantity         = '2.000' ).

    DATA(ls_result) = lo_cut->allocate_across_plants(
      it_demands = VALUE #(
        ( request_id         = 'REQ-1'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '6.000' )
        ( request_id         = 'REQ-2'
          material           = 'MAT-1'
          target_plant       = '9001'
          requested_quantity = '4.000' ) )
      it_sources = VALUE #(
        ( request_id = 'REQ-1' source_plant = '2000' )
        ( request_id = 'REQ-1' source_plant = '1000' )
        ( request_id = 'REQ-2' source_plant = '1000' )
        ( request_id = 'REQ-2' source_plant = '2000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 2 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-plant_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = ls_result-plant_allocations[ 1 ]-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-plant_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = ls_result-plant_allocations[ 2 ]-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-plant_allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-2'
      act = ls_result-plant_allocations[ 3 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-plant_allocations[ 3 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( ls_result-location_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = ls_result-location_allocations[ 1 ]-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-location_allocations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-location_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-location_allocations[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-location_allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = ls_result-location_allocations[ 3 ]-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-2'
      act = ls_result-location_allocations[ 4 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).
    TRY.
        DATA(ls_ignored_result) = lo_cut->allocate_across_plants(
          it_demands = VALUE #(
            ( request_id              = 'REQ-FEFO-OPTION'
              material                = 'MAT-1'
              target_plant            = '9000'
              requested_quantity      = '1.000'
              minimum_shelf_life_days = 1 ) )
          it_sources = VALUE #(
            ( request_id = 'REQ-FEFO-OPTION' source_plant = '2000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD filters_cross_plant_locations.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_plant_location_stock(
      iv_material         = 'MAT-1'
      iv_plant            = '2000'
      iv_storage_location = '0001'
      iv_quantity         = '2.000' ).
    lo_repository->set_plant_location_stock(
      iv_material         = 'MAT-1'
      iv_plant            = '2000'
      iv_storage_location = '0002'
      iv_quantity         = '50.000' ).
    lo_repository->set_plant_location_stock(
      iv_material         = 'MAT-1'
      iv_plant            = '2000'
      iv_storage_location = '0003'
      iv_quantity         = '100.000' ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    DATA(ls_result) = lo_cut->allocate_across_plants(
      it_demands                   = VALUE #(
        ( request_id         = 'ALLOW-PLANT-LOC'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '3.000' ) )
      it_sources                   = VALUE #(
        ( request_id   = 'ALLOW-PLANT-LOC'
          source_plant = '2000' ) )
      it_allowed_storage_locations = VALUE #(
        ( '0001' )
        ( '0002' ) )
      it_storage_location_priority = VALUE #(
        ( '0002' )
        ( '0001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '52.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-location_allocations ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-location_allocations[ 1 ]-storage_location ).
  ENDMETHOD.

  METHOD filters_cross_plant_batches.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          expiration_date    = '20261231'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          batch              = 'B-1'
          expiration_date    = '20261231'
          available_quantity = '50.000' )
        ( storage_location   = '0003'
          batch              = 'B-1'
          expiration_date    = '20261231'
          available_quantity = '100.000' )
        ( storage_location   = '0001'
          batch              = 'B-2'
          available_quantity = '100.000' ) ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    DATA(ls_result) = lo_cut->allocate_plants_by_batch(
      it_demands                   = VALUE #(
        ( request_id         = 'ALLOW-PLANT-BATCH'
          material           = 'MAT-1'
          target_plant       = '9000'
          batch              = 'B-1'
          requested_quantity = '3.000' ) )
      it_sources                   = VALUE #(
        ( request_id   = 'ALLOW-PLANT-BATCH'
          source_plant = '2000' ) )
      it_allowed_storage_locations = VALUE #(
        ( '0001' )
        ( '0002' ) )
      it_storage_location_priority = VALUE #(
        ( '0002' )
        ( '0001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '52.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-location_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-location_allocations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-location_allocations[ 1 ]-batch ).
  ENDMETHOD.

  METHOD filters_cross_plant_fefo.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-ELIGIBLE'
          expiration_date    = '20260930'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          batch              = 'B-ELIGIBLE'
          expiration_date    = '20260930'
          available_quantity = '50.000' )
        ( storage_location   = '0003'
          batch              = 'B-ELIGIBLE'
          expiration_date    = '20260930'
          available_quantity = '100.000' )
        ( storage_location   = '0001'
          batch              = 'B-EXPIRED'
          expiration_date    = '20260922'
          available_quantity = '100.000' ) ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    DATA(ls_result) = lo_cut->allocate_plants_by_expiry(
      it_demands                   = VALUE #(
        ( request_id         = 'ALLOW-PLANT-FEFO'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '3.000' ) )
      it_sources                   = VALUE #(
        ( request_id   = 'ALLOW-PLANT-FEFO'
          source_plant = '2000' ) )
      it_allowed_storage_locations = VALUE #(
        ( '0001' )
        ( '0002' ) )
      it_storage_location_priority = VALUE #(
        ( '0002' )
        ( '0001' ) )
      iv_as_of_date                = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '52.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-batch_allocations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-ELIGIBLE'
      act = ls_result-batch_allocations[ 1 ]-batch ).
  ENDMETHOD.

  METHOD rejects_invalid_plant_sources.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_across_plants(
          it_demands = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              requested_quantity = '2.000' ) )
          it_sources = VALUE #(
            ( request_id = 'UNKNOWN' source_plant = '1000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_plants_by_date.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_date_stock(
      iv_material = 'MAT-1'
      iv_plant    = '2000'
      iv_date     = '20261201'
      iv_quantity = '5.000' ).
    lo_repository->set_date_stock(
      iv_material = 'MAT-1'
      iv_plant    = '3000'
      iv_date     = '20261201'
      iv_quantity = '10.000' ).
    lo_repository->set_date_stock(
      iv_material         = 'MAT-1'
      iv_plant            = '2000'
      iv_date             = '20261231'
      iv_quantity         = '15.000'
      iv_receipt_quantity = '4.000' ).
    lo_repository->set_date_stock(
      iv_material = 'MAT-1'
      iv_plant    = '3000'
      iv_date     = '20261231'
      iv_quantity = '10.000' ).
    lo_repository->set_safety_stock( iv_quantity = '1.000' ).

    DATA(ls_result) = lo_cut->allocate_plants_by_date(
      it_demands              = VALUE zcl_stock_service=>ty_date_plant_demands(
        ( request_id         = 'LATE'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261231'
          priority           = 1000
          requested_quantity = '12.000' )
        ( request_id         = 'EARLY'
          material           = 'MAT-1'
          target_plant       = '9001'
          required_date      = '20261201'
          priority           = 0
          requested_quantity = '8.000' ) )
      it_sources              = VALUE zcl_stock_service=>ty_plant_sources(
        ( request_id = 'LATE' source_plant = '3000' )
        ( request_id = 'LATE' source_plant = '2000' )
        ( request_id = 'EARLY' source_plant = '2000' )
        ( request_id = 'EARLY' source_plant = '3000' ) )
      iv_include_po_receipts  = abap_true
      iv_protect_safety_stock = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LATE'
      act = ls_result-allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '19.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY'
      act = ls_result-allocations[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '13.000' )
      act = ls_result-allocations[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_result-allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( ls_result-plant_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '3000'
      act = ls_result-plant_allocations[ 1 ]-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-plant_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = ls_result-plant_allocations[ 2 ]-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = ls_result-plant_allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY'
      act = ls_result-plant_allocations[ 3 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-plant_allocations[ 3 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-plant_allocations[ 3 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 6
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_plants_with_po_conf.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_date_stock(
      iv_material = 'MAT-1'
      iv_plant    = '2000'
      iv_date     = '20261231'
      iv_quantity = '5.000' ).
    lo_repository->set_date_stock(
      iv_material = 'MAT-1'
      iv_plant    = '3000'
      iv_date     = '20261231'
      iv_quantity = '5.000' ).
    lo_repository->set_projected_receipts(
      it_receipts = VALUE #(
        ( material        = 'MAT-1'
          plant           = '2000'
          base_unit       = 'EA'
          receipt_date    = '20261222'
          quantity        = '2.000'
          source_type     = 'PO'
          source_document = '4500000010' )
        ( material        = 'MAT-1'
          plant           = '2000'
          base_unit       = 'EA'
          receipt_date    = '20261225'
          quantity        = '3.000'
          source_type     = 'PO_CONFIRMATION'
          source_document = '4500000010' ) ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    DATA(ls_result) = lo_cut->allocate_plants_by_date(
      it_demands                  = VALUE #(
        ( request_id         = 'CONF-XPLANT'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261231'
          requested_quantity = '15.000' ) )
      it_sources                  = VALUE #(
        ( request_id = 'CONF-XPLANT' source_plant = '2000' )
        ( request_id = 'CONF-XPLANT' source_plant = '3000' ) )
      iv_include_po_confirmations = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '15.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '15.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-plant_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = ls_result-plant_allocations[ 1 ]-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_result-plant_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '3000'
      act = ls_result-plant_allocations[ 2 ]-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-plant_allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD prioritizes_plant_date_demands.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_date_stock(
      iv_material = 'MAT-1'
      iv_plant    = '2000'
      iv_date     = '20261231'
      iv_quantity = '5.000' ).
    lo_repository->set_date_stock(
      iv_material = 'MAT-1'
      iv_plant    = '3000'
      iv_date     = '20261231'
      iv_quantity = '5.000' ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    DATA(ls_result) = lo_cut->allocate_plants_by_date(
      it_demands = VALUE #(
        ( request_id         = 'LOW'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261231'
          priority           = 0
          requested_quantity = '8.000' )
        ( request_id         = 'HIGH'
          material           = 'MAT-1'
          target_plant       = '9001'
          required_date      = '20261231'
          priority           = 20
          requested_quantity = '8.000' ) )
      it_sources = VALUE #(
        ( request_id = 'LOW' source_plant = '2000' )
        ( request_id = 'LOW' source_plant = '3000' )
        ( request_id = 'HIGH' source_plant = '2000' )
        ( request_id = 'HIGH' source_plant = '3000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'LOW'
      act = ls_result-allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_result-allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'HIGH'
      act = ls_result-allocations[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_result-allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 20
      act = ls_result-allocations[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-plant_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '3000'
      act = ls_result-plant_allocations[ 1 ]-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = ls_result-plant_allocations[ 2 ]-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-plant_allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '3000'
      act = ls_result-plant_allocations[ 3 ]-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-plant_allocations[ 3 ]-allocated_quantity ).
  ENDMETHOD.

  METHOD allocates_plants_by_date_loc.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_plant_location_stock(
      iv_material         = 'MAT-1'
      iv_plant            = '2000'
      iv_storage_location = '0001'
      iv_quantity         = '2.000' ).
    lo_repository->set_plant_location_stock(
      iv_material         = 'MAT-1'
      iv_plant            = '2000'
      iv_storage_location = '0002'
      iv_quantity         = '1.000' ).
    lo_repository->set_plant_location_stock(
      iv_material         = 'MAT-1'
      iv_plant            = '3000'
      iv_storage_location = '0001'
      iv_quantity         = '1.000' ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_bad_date_rejected TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_by_date_loc(
          it_demands = VALUE #(
            ( request_id         = 'BAD-DATE'
              material           = 'MAT-1'
              target_plant       = '9000'
              required_date      = '20260230'
              requested_quantity = '1.000' ) )
          it_sources = VALUE #(
            ( request_id = 'BAD-DATE' source_plant = '2000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_bad_date_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_date_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    DATA(ls_result) = lo_cut->allocate_plants_by_date_loc(
      it_demands = VALUE #(
        ( request_id         = 'LATE'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261220'
          priority           = 99
          requested_quantity = '1.000' )
        ( request_id         = 'EARLY-LOW'
          material           = 'MAT-1'
          target_plant       = '9001'
          required_date      = '20261210'
          priority           = 1
          requested_quantity = '1.000' )
        ( request_id         = 'EARLY-TIE'
          material           = 'MAT-1'
          target_plant       = '9002'
          required_date      = '20261210'
          priority           = 1
          requested_quantity = '2.000' )
        ( request_id         = 'EARLY-HIGH'
          material           = 'MAT-1'
          target_plant       = '9003'
          required_date      = '20261210'
          priority           = 5
          requested_quantity = '2.000' ) )
      it_sources = VALUE #(
        ( request_id = 'LATE'       source_plant = '2000' )
        ( request_id = 'LATE'       source_plant = '3000' )
        ( request_id = 'EARLY-LOW'  source_plant = '2000' )
        ( request_id = 'EARLY-LOW'  source_plant = '3000' )
        ( request_id = 'EARLY-TIE'  source_plant = '2000' )
        ( request_id = 'EARLY-TIE'  source_plant = '3000' )
        ( request_id = 'EARLY-HIGH' source_plant = '2000' )
        ( request_id = 'EARLY-HIGH' source_plant = '3000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'LATE'
      act = ls_result-allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 99
      act = ls_result-allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 3 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 4 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = ls_result-allocations[ 4 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-plant_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY-LOW'
      act = ls_result-plant_allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = ls_result-plant_allocations[ 1 ]-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY-TIE'
      act = ls_result-plant_allocations[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '3000'
      act = ls_result-plant_allocations[ 2 ]-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY-HIGH'
      act = ls_result-plant_allocations[ 3 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-location_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY-LOW'
      act = ls_result-location_allocations[ 1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-location_allocations[
        1 ]-allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY-TIE'
      act = ls_result-location_allocations[ 2 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY-HIGH'
      act = ls_result-location_allocations[ 3 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_plant_loc_receipts.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_plant_location_stock(
      iv_material         = 'MAT-1'
      iv_plant            = '2000'
      iv_storage_location = '0001'
      iv_quantity         = '2.000' ).
    lo_repository->set_safety_stock( iv_quantity = '3.000' ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA(lt_demands) = VALUE zcl_stock_service=>ty_dated_plant_location_demands(
        ( request_id         = 'LATE-RECEIPT'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261210'
          requested_quantity = '2.000' )
        ( request_id         = 'EARLY-RECEIPT'
          material           = 'MAT-1'
          target_plant       = '9001'
          required_date      = '20261205'
          requested_quantity = '1.000' ) ).
    DATA(lt_sources) = VALUE zcl_stock_service=>ty_plant_sources(
      ( request_id = 'LATE-RECEIPT'  source_plant = '2000' )
      ( request_id = 'EARLY-RECEIPT' source_plant = '2000' ) ).
    DATA(lt_receipts) = VALUE zcl_stock_service=>ty_dated_location_receipts(
      ( material         = 'MAT-1'
        plant            = '2000'
        storage_location = '0002'
        receipt_date     = '20261210'
        base_quantity    = '3.000' ) ).
    DATA lv_bad_receipt_rejected TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_by_date_loc(
          it_demands            = lt_demands
          it_sources            = lt_sources
          it_projected_receipts = VALUE #(
            ( material         = 'MAT-1'
              plant            = '2000'
              storage_location = '0002'
              receipt_date     = '20260230'
              base_quantity    = '3.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_bad_receipt_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_receipt_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    DATA(ls_result) = lo_cut->allocate_plants_by_date_loc(
      it_demands               = lt_demands
      it_sources               = lt_sources
      it_projected_receipts    = lt_receipts
      iv_protect_safety_stock  = abap_true
      iv_require_full_quantity = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LATE-RECEIPT'
      act = ls_result-allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY-RECEIPT'
      act = ls_result-allocations[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = ls_result-allocations[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = ls_result-allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 2 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-location_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-location_allocations[
        1 ]-allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LATE-RECEIPT'
      act = ls_result-location_allocations[
        1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD alloc_plant_loc_rcpt_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_plant_location_stock(
      iv_material         = 'MAT-1'
      iv_plant            = '2000'
      iv_storage_location = '0001'
      iv_quantity         = '2.000' ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    lo_availability_api->set_result(
      is_result = VALUE #(
        available_at_plant_quantity = '10.000'
        confirmed_quantity          = '10.000'
        is_fully_available          = abap_true
        is_check_relevant           = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).
    DATA(lt_demands) = VALUE zcl_stock_service=>ty_unit_date_plant_location_demands(
        ( request_id         = 'UOM-LATE-RECEIPT'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261210'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'UOM-EARLY-RECEIPT'
          material           = 'MAT-1'
          target_plant       = '9001'
          required_date      = '20261205'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) ).
    DATA(lt_sources) = VALUE zcl_stock_service=>ty_plant_sources(
      ( request_id = 'UOM-LATE-RECEIPT'  source_plant = '2000' )
      ( request_id = 'UOM-LATE-RECEIPT'  source_plant = '3000' )
      ( request_id = 'UOM-EARLY-RECEIPT' source_plant = '2000' )
      ( request_id = 'UOM-EARLY-RECEIPT' source_plant = '3000' ) ).
    DATA(lt_receipts) = VALUE zcl_stock_service=>ty_dated_location_receipts(
      ( material         = 'MAT-1'
        plant            = '3000'
        storage_location = '0002'
        receipt_date     = '20261210'
        base_quantity    = '4.000' ) ).
    DATA lv_bad_receipt_rejected TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_date_loc_uom(
          it_demands            = lt_demands
          it_sources            = lt_sources
          it_projected_receipts = VALUE #(
            ( material         = 'MAT-1'
              plant            = '3000'
              storage_location = '0002'
              receipt_date     = '20260230'
              base_quantity    = '4.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_bad_receipt_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_receipt_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    DATA(ls_result) = lo_cut->allocate_plants_date_loc_uom(
      it_demands               = lt_demands
      it_sources               = lt_sources
      it_projected_receipts    = lt_receipts
      iv_require_full_quantity = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-allocations[
        1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[
        1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '3000'
      act = ls_result-plant_allocations[
        1 ]-allocation-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-location_allocations[
        1 ]-allocation-allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[
        2 ]-allocation-allocated_quantity ).

    DATA(ls_atp_result) = lo_cut->allocate_plants_date_loc_atp(
      it_demands               = lt_demands
      it_sources               = lt_sources
      it_projected_receipts    = lt_receipts
      iv_check_rule            = 'A'
      iv_require_full_quantity = abap_true ).
    DATA(lt_atp_requests) = lo_availability_api->get_requests( ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_atp_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = lt_atp_requests[ 1 ]-plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_atp_requests[ 1 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '3000'
      act = lt_atp_requests[ 2 ]-plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_atp_requests[ 2 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_availability_api->get_check_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_plants_date_loc_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_plant_location_stock(
      iv_material         = 'MAT-1'
      iv_plant            = '2000'
      iv_storage_location = '0001'
      iv_quantity         = '12.000' ).
    lo_repository->set_plant_location_stock(
      iv_material         = 'MAT-1'
      iv_plant            = '2000'
      iv_storage_location = '0002'
      iv_quantity         = '12.000' ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_result) = lo_cut->allocate_plants_date_loc_uom(
      it_demands = VALUE #(
        ( request_id         = 'LATE'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261220'
          priority           = 100
          requested_quantity = '1.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'EARLY-LOW'
          material           = 'MAT-1'
          target_plant       = '9001'
          required_date      = '20261210'
          priority           = 1
          requested_quantity = '0.500'
          requested_unit     = 'BOX' )
        ( request_id         = 'EARLY-HIGH'
          material           = 'MAT-1'
          target_plant       = '9002'
          required_date      = '20261210'
          priority           = 5
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) )
      it_sources = VALUE #(
        ( request_id = 'LATE'       source_plant = '2000' )
        ( request_id = 'EARLY-LOW'  source_plant = '2000' )
        ( request_id = 'EARLY-HIGH' source_plant = '2000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'LATE'
      act = ls_result-allocations[ 1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = ls_result-allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = ls_result-allocations[ 1 ]-source_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-allocations[ 1 ]-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-allocations[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY-LOW'
      act = ls_result-allocations[ 2 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-allocations[ 2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY-HIGH'
      act = ls_result-allocations[ 3 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-allocations[ 3 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-plant_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = ls_result-plant_allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-location_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LATE'
      act = ls_result-location_allocations[
        1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = ls_result-location_allocations[
        1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY-LOW'
      act = ls_result-location_allocations[
        2 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY-HIGH'
      act = ls_result-location_allocations[
        3 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_uom_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_unknown_date_loc_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'CS'
      iv_numerator        = 24
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_date_loc_uom(
          it_demands = VALUE #(
            ( request_id         = 'UNKNOWN-UOM'
              material           = 'MAT-1'
              target_plant       = '9000'
              required_date      = '20261210'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources = VALUE #(
            ( request_id = 'UNKNOWN-UOM' source_plant = '2000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD compares_plants_date_loc_atp.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_plant_location_stock(
      iv_material         = 'MAT-1'
      iv_plant            = '2000'
      iv_storage_location = '0001'
      iv_quantity         = '24.000' ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    lo_availability_api->set_result(
      is_result = VALUE #(
        available_at_plant_quantity = '24.000'
        confirmed_quantity          = '12.000'
        confirmed_date              = '20261231'
        dialog_flag                 = 'X'
        is_fully_available          = abap_true
        is_check_relevant           = abap_true ) ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).

    DATA(ls_result) = lo_cut->allocate_plants_date_loc_atp(
      it_demands    = VALUE #(
        ( request_id         = 'LATE'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261220'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'EARLY'
          material           = 'MAT-1'
          target_plant       = '9001'
          required_date      = '20261210'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'SHORT'
          material           = 'MAT-1'
          target_plant       = '9002'
          required_date      = '20261230'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) )
      it_sources    = VALUE #(
        ( request_id = 'LATE'  source_plant = '2000' )
        ( request_id = 'EARLY' source_plant = '2000' )
        ( request_id = 'SHORT' source_plant = '2000' ) )
      iv_check_rule = 'A' ).

    DATA(lt_requests) = lo_availability_api->get_requests( ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-local_estimate-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SHORT'
      act = ls_result-local_estimate-allocations[ 3 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-local_estimate-allocations[
        3 ]-allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261210'
      act = lt_requests[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = lt_requests[ 1 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261220'
      act = lt_requests[ 2 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '24.000' )
      act = lt_requests[ 2 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LATE'
      act = ls_result-atp_checks[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '24.000' )
      act = ls_result-atp_checks[ 1 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY'
      act = ls_result-atp_checks[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-atp_checks[ 2 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_availability_api->get_check_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_loc_date_atp_rule.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_date_loc_atp(
          it_demands    = VALUE #(
            ( request_id         = 'BAD-RULE'
              material           = 'MAT-1'
              target_plant       = '9000'
              required_date      = '20261210'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources    = VALUE #(
            ( request_id = 'BAD-RULE' source_plant = '2000' ) )
          iv_check_rule = '' ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_availability_api->get_check_count( ) ).
  ENDMETHOD.

  METHOD prioritizes_plant_unit_dates.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_date_stock(
      iv_material = 'MAT-1'
      iv_plant    = '2000'
      iv_date     = '20261231'
      iv_quantity = '12.000' ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_result) = lo_cut->allocate_plants_date_units(
      it_demands = VALUE #(
        ( request_id         = 'LOW'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261231'
          priority           = 0
          requested_quantity = '1.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'HIGH'
          material           = 'MAT-1'
          target_plant       = '9001'
          required_date      = '20261231'
          priority           = 20
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) )
      it_sources = VALUE #(
        ( request_id = 'LOW' source_plant = '2000' )
        ( request_id = 'HIGH' source_plant = '2000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'LOW'
      act = ls_result-allocations[ 1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = ls_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'HIGH'
      act = ls_result-allocations[ 2 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-allocations[ 2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 20
      act = ls_result-allocations[ 2 ]-allocation-priority ).
  ENDMETHOD.

  METHOD allocates_dated_plant_units.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_repository->set_date_stock(
      iv_material = 'MAT-1'
      iv_plant    = '2000'
      iv_date     = '20261201'
      iv_quantity = '10.000' ).
    lo_repository->set_date_stock(
      iv_material = 'MAT-1'
      iv_plant    = '3000'
      iv_date     = '20261201'
      iv_quantity = '20.000' ).
    lo_repository->set_date_stock(
      iv_material         = 'MAT-1'
      iv_plant            = '2000'
      iv_date             = '20261231'
      iv_quantity         = '20.000'
      iv_receipt_quantity = '2.000' ).
    lo_repository->set_date_stock(
      iv_material = 'MAT-1'
      iv_plant    = '3000'
      iv_date     = '20261231'
      iv_quantity = '20.000' ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_result) = lo_cut->allocate_plants_date_units(
      it_demands             = VALUE zcl_stock_service=>ty_unit_date_plant_demands(
        ( request_id         = 'LATE'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261231'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'EARLY'
          material           = 'MAT-1'
          target_plant       = '9001'
          required_date      = '20261201'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' ) )
      it_sources             = VALUE zcl_stock_service=>ty_plant_sources(
        ( request_id = 'LATE' source_plant = '3000' )
        ( request_id = 'LATE' source_plant = '2000' )
        ( request_id = 'EARLY' source_plant = '2000' )
        ( request_id = 'EARLY' source_plant = '3000' ) )
      iv_include_po_receipts = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LATE'
      act = ls_result-allocations[ 1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-allocations[ 1 ]-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '18.000' )
      act = ls_result-allocations[ 1 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.500' )
      act = ls_result-allocations[ 1 ]-available_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY'
      act = ls_result-allocations[ 2 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '24.000' )
      act = ls_result-allocations[ 2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( ls_result-plant_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '3000'
      act = ls_result-plant_allocations[ 1 ]-allocation-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-plant_allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = ls_result-plant_allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = ls_result-plant_allocations[ 2 ]-allocation-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-plant_allocations[ 2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY'
      act = ls_result-plant_allocations[ 3 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD compares_dated_plant_atp.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    lo_repository->set_date_stock(
      iv_material = 'MAT-1'
      iv_plant    = '2000'
      iv_date     = '20261201'
      iv_quantity = '10.000' ).
    lo_repository->set_date_stock(
      iv_material = 'MAT-1'
      iv_plant    = '3000'
      iv_date     = '20261201'
      iv_quantity = '20.000' ).
    lo_repository->set_date_stock(
      iv_material = 'MAT-1'
      iv_plant    = '2000'
      iv_date     = '20261231'
      iv_quantity = '20.000' ).
    lo_repository->set_date_stock(
      iv_material = 'MAT-1'
      iv_plant    = '3000'
      iv_date     = '20261231'
      iv_quantity = '20.000' ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    lo_availability_api->set_result(
      is_result = VALUE #(
        available_at_plant_quantity = '9.000'
        confirmed_quantity          = '9.000'
        confirmed_date              = '20261201'
        dialog_flag                 = 'X'
        is_fully_available          = abap_false
        is_check_relevant           = abap_true ) ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).

    DATA(ls_result) = lo_cut->allocate_plants_date_atp(
      it_demands    = VALUE zcl_stock_service=>ty_unit_date_plant_demands(
        ( request_id         = 'REQ-A'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261201'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'REQ-B'
          material           = 'MAT-1'
          target_plant       = '9001'
          required_date      = '20261201'
          requested_quantity = '4.000'
          requested_unit     = 'EA' )
        ( request_id         = 'REQ-C'
          material           = 'MAT-1'
          target_plant       = '9002'
          required_date      = '20261231'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) )
      it_sources    = VALUE zcl_stock_service=>ty_plant_sources(
        ( request_id = 'REQ-A' source_plant = '2000' )
        ( request_id = 'REQ-A' source_plant = '3000' )
        ( request_id = 'REQ-B' source_plant = '2000' )
        ( request_id = 'REQ-B' source_plant = '3000' )
        ( request_id = 'REQ-C' source_plant = '2000' )
        ( request_id = 'REQ-C' source_plant = '3000' ) )
      iv_check_rule = 'A' ).
    DATA(lt_requests) = lo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-local_estimate-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = lines( ls_result-local_estimate-plant_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-A'
      act = ls_result-atp_checks[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = ls_result-atp_checks[ 1 ]-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_result-atp_checks[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_result-atp_checks[ 1 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '9.000' )
      act = ls_result-atp_checks[ 1 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-atp_checks[ 1 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-B'
      act = ls_result-atp_checks[ 3 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '3000'
      act = ls_result-atp_checks[ 3 ]-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-atp_checks[ 3 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '20.000' )
      act = ls_result-atp_checks[ 4 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_result-atp_checks[ 5 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '9.000' )
      act = ls_result-atp_checks[ 5 ]-atp_result-available_at_plant_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = lt_requests[ 1 ]-plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261201'
      act = lt_requests[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lt_requests[ 1 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261231'
      act = lt_requests[ 2 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '20.000' )
      act = lt_requests[ 2 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '3000'
      act = lt_requests[ 3 ]-plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = lt_requests[ 3 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = lt_requests[ 4 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_dated_plant_atp_rule.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_date_atp(
          it_demands    = VALUE zcl_stock_service=>ty_unit_date_plant_demands(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              required_date      = '20261231'
              requested_quantity = '1.000'
              requested_unit     = 'EA' ) )
          it_sources    = VALUE zcl_stock_service=>ty_plant_sources(
            ( request_id = 'REQ-1' source_plant = '2000' ) )
          iv_check_rule = space ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_availability_api->get_check_count( ) ).
  ENDMETHOD.

  METHOD compares_cross_plant_atp.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_plant_location_stock(
      iv_material         = 'MAT-1'
      iv_plant            = '2000'
      iv_storage_location = '0001'
      iv_quantity         = '10.000' ).
    lo_repository->set_plant_location_stock(
      iv_material         = 'MAT-1'
      iv_plant            = '2000'
      iv_storage_location = '0002'
      iv_quantity         = '50.000' ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    lo_availability_api->set_result(
      is_result = VALUE #(
        available_at_plant_quantity = '20.000'
        confirmed_quantity          = '5.000'
        confirmation_lines          = VALUE #(
          ( confirmed_date = sy-datum confirmed_quantity = '5.000' ) )
        is_fully_available          = abap_false
        is_check_relevant           = abap_true ) ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).

    DATA(ls_result) = lo_cut->allocate_plants_atp(
      it_demands                   = VALUE #(
        ( request_id         = 'REQ-BOX'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'REQ-EA'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '3.000'
          requested_unit     = 'EA' ) )
      it_sources                   = VALUE #(
        ( request_id = 'REQ-BOX' source_plant = '2000' )
        ( request_id = 'REQ-EA' source_plant = '2000' ) )
      iv_check_rule                = 'A'
      it_allowed_storage_locations = VALUE #(
        ( '0001' )
        ( '0002' ) )
      it_storage_location_priority = VALUE #(
        ( '0002' )
        ( '0001' ) )
      it_source_locations          = VALUE #(
        ( request_id = 'REQ-BOX' source_plant = '2000'
          storage_location = '0001' )
        ( request_id = 'REQ-EA' source_plant = '2000'
          storage_location = '0001' ) ) ).
    DATA(lt_requests) = lo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-local_estimate-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-local_estimate-location_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-local_estimate-location_allocations[ 1 ]-allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-local_estimate-location_allocations[ 2 ]-allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = ls_result-atp_checks[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-atp_checks[ 1 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 1 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-atp_checks[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = sy-datum
      act = ls_result-atp_checks[ 1 ]-check_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = lt_requests[ 1 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = lt_requests[ 1 ]-plant ).
  ENDMETHOD.

  METHOD compares_cross_plant_batch_atp.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          expiration_date    = '20261231'
          available_quantity = '10.000' )
        ( storage_location   = '0002'
          batch              = 'B-2'
          expiration_date    = '20270131'
          available_quantity = '20.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    lo_availability_api->set_result(
      is_result = VALUE #(
        available_at_plant_quantity = '7.000'
        confirmed_quantity          = '4.000'
        confirmation_lines          = VALUE #(
          ( confirmed_date = sy-datum confirmed_quantity = '4.000' ) )
        is_fully_available          = abap_false
        is_check_relevant           = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).

    DATA(ls_result) = lo_cut->allocate_plants_batch_atp(
      it_demands                  = VALUE #(
        ( request_id         = 'BATCH-BOX'
          material           = 'MAT-1'
          target_plant       = '9000'
          batch              = 'B-1'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'BATCH-EA'
          material           = 'MAT-1'
          target_plant       = '9000'
          batch              = 'B-2'
          requested_quantity = '3.000'
          requested_unit     = 'EA' ) )
      it_sources                  = VALUE #(
        ( request_id = 'BATCH-BOX' source_plant = '2000' )
        ( request_id = 'BATCH-EA' source_plant = '2000' ) )
      it_projected_batch_receipts = VALUE #(
        ( material         = 'MAT-1'
          plant            = '2000'
          storage_location = '0001'
          batch            = 'B-1'
          expiration_date  = '20261231'
          receipt_date     = sy-datum
          base_quantity    = '5.000' ) )
      iv_check_rule               = 'A' ).
    DATA(lt_requests) = lo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-local_estimate-location_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-local_estimate-location_allocations[ 1 ]-allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '15.000' )
      act = ls_result-local_estimate-allocations[ 1 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-2'
      act = ls_result-local_estimate-location_allocations[ 2 ]-allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = ls_result-atp_checks[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-atp_checks[ 1 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-atp_checks[ 1 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = lt_requests[ 1 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_requests[ 1 ]-unit ).
  ENDMETHOD.

  METHOD rejects_batch_plant_atp_rule.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_batch_atp(
          it_demands    = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              batch              = 'B-1'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources    = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000' ) )
          iv_check_rule = space ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_availability_api->get_check_count( ) ).
  ENDMETHOD.

  METHOD compares_dated_batch_atp.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          expiration_date    = '20261231'
          available_quantity = '10.000' )
        ( storage_location   = '0001'
          batch              = 'B-2'
          expiration_date    = '20270131'
          available_quantity = '20.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    lo_availability_api->set_result(
      is_result = VALUE #(
        available_at_plant_quantity = '20.000'
        confirmed_quantity          = '5.000'
        confirmation_lines          = VALUE #(
          ( confirmed_date = '20261231' confirmed_quantity = '5.000' ) )
        is_fully_available          = abap_false
        is_check_relevant           = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).

    DATA(ls_result) = lo_cut->allocate_plants_date_batch_atp(
      it_demands                  = VALUE #(
        ( request_id         = 'LATE-BOX'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261231'
          batch              = 'B-1'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'EARLY-LOW'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261201'
          priority           = 0
          batch              = 'B-2'
          requested_quantity = '5.000'
          requested_unit     = 'EA' )
        ( request_id              = 'EARLY-HIGH'
          material                = 'MAT-1'
          target_plant            = '9000'
          required_date           = '20261201'
          priority                = 10
          batch                   = 'B-1'
          minimum_shelf_life_days = 30
          requested_quantity      = '2.000'
          requested_unit          = 'EA' ) )
      it_sources                  = VALUE #(
        ( request_id = 'LATE-BOX' source_plant = '2000' )
        ( request_id = 'EARLY-LOW' source_plant = '2000' )
        ( request_id = 'EARLY-HIGH' source_plant = '2000' ) )
      it_projected_batch_receipts = VALUE #(
        ( material         = 'MAT-1'
          plant            = '2000'
          storage_location = '0001'
          batch            = 'B-1'
          expiration_date  = '20261231'
          receipt_date     = '20261215'
          base_quantity    = '14.000' ) )
      iv_check_rule               = 'A' ).
    DATA(lt_requests) = lo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-local_estimate-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY-HIGH'
      act = ls_result-local_estimate-allocations[ 3 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '22.000' )
      act = ls_result-local_estimate-allocations[ 1 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-local_estimate-allocations[ 3 ]-allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 30
      act = ls_result-local_estimate-allocations[ 3 ]-allocation-minimum_shelf_life_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261201' )
      act = ls_result-atp_checks[ 1 ]-check_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = ls_result-atp_checks[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = ls_result-atp_checks[ 1 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261231' )
      act = ls_result-atp_checks[ 2 ]-check_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-atp_checks[ 2 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '11.000' )
      act = ls_result-atp_checks[ 2 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-atp_checks[ 2 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = lt_requests[ 1 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261201' )
      act = lt_requests[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '11.000' )
      act = lt_requests[ 2 ]-requested_quantity ).
  ENDMETHOD.

  METHOD rejects_dated_batch_atp_rule.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_date_batch_atp(
          it_demands    = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              required_date      = '20261231'
              batch              = 'B-1'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources    = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000' ) )
          iv_check_rule = space ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_availability_api->get_check_count( ) ).
  ENDMETHOD.

  METHOD compares_cross_plant_fefo_atp.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-DATED'
          expiration_date    = '20261231'
          available_quantity = '10.000' )
        ( storage_location   = '0001'
          batch              = 'B-UNDATED'
          available_quantity = '20.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    lo_availability_api->set_result_for_call(
      iv_call_number = 1
      is_result      = VALUE #(
        available_at_plant_quantity = '10.000'
        confirmed_quantity          = '4.000'
        confirmation_lines          = VALUE #(
          ( confirmed_date = sy-datum confirmed_quantity = '4.000' ) )
        is_fully_available          = abap_false
        is_check_relevant           = abap_true ) ).
    lo_availability_api->set_result_for_call(
      iv_call_number = 2
      is_result      = VALUE #(
        available_at_plant_quantity = '10.000'
        confirmed_quantity          = '2.000'
        confirmation_lines          = VALUE #(
          ( confirmed_date = sy-datum confirmed_quantity = '2.000' ) )
        is_fully_available          = abap_true
        is_check_relevant           = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).
    DATA(lv_rejected) = abap_false.
    TRY.
        lo_cut->allocate_plants_fefo_atp(
          it_demands    = VALUE #(
            ( request_id         = 'BAD-RULE'
              material           = 'MAT-1'
              target_plant       = '9000'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources    = VALUE #(
            ( request_id = 'BAD-RULE' source_plant = '2000' ) )
          iv_check_rule = space ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_availability_api->get_check_count( ) ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->allocate_plants_fefo_atp(
          it_demands                 = VALUE #(
            ( request_id         = 'BAD-UNDATED-FLAG'
              material           = 'MAT-1'
              target_plant       = '9000'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources                 = VALUE #(
            ( request_id = 'BAD-UNDATED-FLAG' source_plant = '2000' ) )
          iv_check_rule              = 'A'
          iv_include_undated_batches = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).

    DATA(ls_short_result) = lo_cut->allocate_plants_fefo_atp(
      it_demands                 = VALUE #(
        ( request_id         = 'STRICT-SHORT'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '11.000'
          requested_unit     = 'EA' ) )
      it_sources                 = VALUE #(
        ( request_id = 'STRICT-SHORT' source_plant = '2000' ) )
      iv_check_rule              = 'A'
      iv_as_of_date              = '20261001'
      iv_include_undated_batches = abap_false
      iv_require_full_quantity   = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_short_result-local_estimate-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_short_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_availability_api->get_check_count( ) ).

    DATA(ls_result) = lo_cut->allocate_plants_fefo_atp(
      it_demands                 = VALUE #(
        ( request_id         = 'BOX-SOURCE-2000'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'EA-SOURCE-2000'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '3.000'
          requested_unit     = 'EA' )
        ( request_id         = 'EA-SOURCE-3000'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '2.000'
          requested_unit     = 'EA' ) )
      it_sources                 = VALUE #(
        ( request_id = 'BOX-SOURCE-2000' source_plant = '2000' )
        ( request_id = 'EA-SOURCE-2000' source_plant = '2000' )
        ( request_id = 'EA-SOURCE-3000' source_plant = '3000' ) )
      iv_check_rule              = 'A'
      iv_as_of_date              = '20261001'
      iv_include_undated_batches = abap_false ).
    DATA(lt_requests) = lo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-local_estimate-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-local_estimate-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-DATED'
      act = ls_result-local_estimate-batch_allocations[ 1 ]-allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = ls_result-atp_checks[ 1 ]-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-atp_checks[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-atp_checks[ 1 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-atp_checks[ 1 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-atp_checks[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = sy-datum
      act = ls_result-atp_checks[ 1 ]-check_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '3000'
      act = ls_result-atp_checks[ 2 ]-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 2 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 2 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-atp_checks[ 2 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lt_requests[ 1 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = lt_requests[ 1 ]-plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_requests[ 2 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '3000'
      act = lt_requests[ 2 ]-plant ).
    DATA(ls_restricted_result) = lo_cut->allocate_plants_fefo_atp(
      it_demands                 = VALUE #(
        ( request_id              = 'STRICT-SHELF'
          material                = 'MAT-1'
          target_plant            = '9000'
          requested_quantity      = '1.000'
          requested_unit          = 'EA'
          minimum_shelf_life_days = 100 ) )
      it_sources                 = VALUE #(
        ( request_id = 'STRICT-SHELF' source_plant = '2000' ) )
      iv_check_rule              = 'A'
      iv_as_of_date              = '20261001'
      iv_include_undated_batches = abap_false
      iv_min_days                = 5 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_restricted_result-local_estimate-allocations[ 1 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_restricted_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_availability_api->get_check_count( ) ).

  ENDMETHOD.

  METHOD rejects_cross_plant_atp_rule.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_atp(
          it_demands    = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources    = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000' ) )
          iv_check_rule = space ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_availability_api->get_check_count( ) ).
  ENDMETHOD.

  METHOD rejects_dated_plant_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_date_units(
          it_demands = VALUE zcl_stock_service=>ty_unit_date_plant_demands(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              required_date      = '20261231'
              requested_quantity = '1.000'
              requested_unit     = 'CASE' ) )
          it_sources = VALUE zcl_stock_service=>ty_plant_sources(
            ( request_id = 'REQ-1' source_plant = '2000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_missing_dated_source.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_by_date(
          it_demands = VALUE zcl_stock_service=>ty_date_plant_demands(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              required_date      = '20261231'
              requested_quantity = '2.000' ) )
          it_sources = VALUE zcl_stock_service=>ty_plant_sources( ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_plants_by_expiry.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-URGENT'
          expiration_date    = '20260925'
          available_quantity = '20.000' )
        ( storage_location   = '0002'
          batch              = 'B-ELIGIBLE'
          expiration_date    = '20260928'
          available_quantity = '3.000' )
        ( storage_location   = '0001'
          batch              = 'B-LATER'
          expiration_date    = '20261010'
          available_quantity = '5.000' )
        ( storage_location   = '0001'
          batch              = 'B-UNDATED'
          available_quantity = '10.000' )
        ( storage_location   = '0001'
          batch              = 'B-OLD'
          expiration_date    = '20260922'
          available_quantity = '10.000' ) ) ).

    DATA(ls_result) = lo_cut->allocate_plants_by_expiry(
      it_demands    = VALUE #(
        ( request_id         = 'REQ-1'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '4.000' ) )
      it_sources    = VALUE #(
        ( request_id = 'REQ-1' source_plant = '2000' ) )
      iv_as_of_date = '20260923'
      iv_min_days   = 5 ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_result-allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-plant_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = ls_result-plant_allocations[ 1 ]-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-ELIGIBLE'
      act = ls_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '3.000' )
      act = ls_result-batch_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = ls_result-batch_allocations[ 1 ]-minimum_shelf_life_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_result-batch_allocations[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '1.000' )
      act = ls_result-batch_allocations[ 2 ]-allocated_quantity ).
    DATA(ls_restricted_result) = lo_cut->allocate_plants_by_expiry(
      it_demands    = VALUE #(
        ( request_id              = 'REQ-STRICT'
          material                = 'MAT-1'
          target_plant            = '9000'
          requested_quantity      = '4.000'
          minimum_shelf_life_days = 8 ) )
      it_sources    = VALUE #(
        ( request_id = 'REQ-STRICT' source_plant = '2000' ) )
      iv_as_of_date = '20260923'
      iv_min_days   = 5 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_restricted_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_restricted_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_restricted_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 8
      act = ls_restricted_result-batch_allocations[ 1 ]-minimum_shelf_life_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_expiry_receipts.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-CURRENT'
          expiration_date    = '20261130'
          available_quantity = '1.000' ) ) ).
    lo_repository->set_safety_stock( iv_quantity = '2.000' ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    DATA(ls_result) = lo_cut->allocate_plants_by_expiry(
      it_demands                  = VALUE #(
        ( request_id         = 'REQ-EXPIRY-RECEIPT'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '2.000' ) )
      it_sources                  = VALUE #(
        ( request_id = 'REQ-EXPIRY-RECEIPT' source_plant = '2000' ) )
      it_projected_batch_receipts = VALUE #(
        ( material         = 'MAT-1'
          plant            = '2000'
          storage_location = '0002'
          batch            = 'B-RECEIPT'
          expiration_date  = '20261215'
          receipt_date     = '20261020'
          base_quantity    = '3.000' )
        ( material         = 'MAT-1'
          plant            = '2000'
          storage_location = '0003'
          batch            = 'B-FUTURE'
          expiration_date  = '20261231'
          receipt_date     = '20261021'
          base_quantity    = '100.000' ) )
      iv_as_of_date               = '20261020'
      iv_min_days                 = 5
      iv_protect_safety_stock     = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-CURRENT'
      act = ls_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-RECEIPT'
      act = ls_result-batch_allocations[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-batch_allocations[ 2 ]-allocated_quantity ).
  ENDMETHOD.

  METHOD rejects_invalid_expiry_receipt.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_by_expiry(
          it_demands                  = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              requested_quantity = '1.000' ) )
          it_sources                  = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000' ) )
          it_projected_batch_receipts = VALUE #(
            ( material         = 'MAT-1'
              plant            = '2000'
              storage_location = '0002'
              batch            = 'B-RECEIPT'
              expiration_date  = '20261215'
              receipt_date     = '20261301'
              base_quantity    = '1.000' ) )
          iv_as_of_date               = '20261020' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_plants_fefo_by_date.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-EARLY'
          expiration_date    = '20261020'
          available_quantity = '3.000' )
        ( storage_location   = '0002'
          batch              = 'B-LATE'
          expiration_date    = '20261130'
          available_quantity = '5.000' ) ) ).

    DATA(ls_result) = lo_cut->allocate_plants_fefo_by_date(
      it_demands  = VALUE #(
        ( request_id         = 'REQ-LATE'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261030'
          priority           = 1000
          requested_quantity = '4.000' )
        ( request_id         = 'REQ-EARLY-1'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261010'
          priority           = 0
          requested_quantity = '3.000' )
        ( request_id         = 'REQ-EARLY-2'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261010'
          priority           = 10
          requested_quantity = '3.000' ) )
      it_sources  = VALUE #(
        ( request_id = 'REQ-LATE' source_plant = '2000' )
        ( request_id = 'REQ-EARLY-1' source_plant = '2000' )
        ( request_id = 'REQ-EARLY-2' source_plant = '2000' ) )
      iv_min_days = 5 ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-LATE'
      act = ls_result-allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1000
      act = ls_result-allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-EARLY-1'
      act = ls_result-allocations[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-allocations[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_result-allocations[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-EARLY-2'
      act = ls_result-allocations[ 3 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_result-allocations[ 3 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_result-allocations[ 3 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-LATE'
      act = ls_result-batch_allocations[ 1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATE'
      act = ls_result-batch_allocations[ 1 ]-allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1000
      act = ls_result-batch_allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-EARLY-1'
      act = ls_result-batch_allocations[ 2 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATE'
      act = ls_result-batch_allocations[ 2 ]-allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_result-batch_allocations[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-EARLY-2'
      act = ls_result-batch_allocations[ 3 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EARLY'
      act = ls_result-batch_allocations[ 3 ]-allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_result-batch_allocations[ 3 ]-priority ).
    DATA(ls_restricted_result) = lo_cut->allocate_plants_fefo_by_date(
      it_demands  = VALUE #(
        ( request_id              = 'REQ-STRICT'
          material                = 'MAT-1'
          target_plant            = '9000'
          required_date           = '20261010'
          requested_quantity      = '2.000'
          minimum_shelf_life_days = 20 ) )
      it_sources  = VALUE #(
        ( request_id = 'REQ-STRICT' source_plant = '2000' ) )
      iv_min_days = 5 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_restricted_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATE'
      act = ls_restricted_result-batch_allocations[ 1 ]-allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 20
      act = ls_restricted_result-batch_allocations[ 1 ]-allocation-minimum_shelf_life_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_dated_fefo_receipts.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-OPEN'
          expiration_date    = '20261130'
          available_quantity = '1.000' ) ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    DATA(ls_result) = lo_cut->allocate_plants_fefo_by_date(
      it_demands                  = VALUE #(
        ( request_id         = 'REQ-RECEIPT-DAY'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261020'
          requested_quantity = '2.000' )
        ( request_id         = 'REQ-BEFORE'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261010'
          requested_quantity = '2.000' )
        ( request_id         = 'REQ-AFTER'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261025'
          requested_quantity = '2.000' ) )
      it_sources                  = VALUE #(
        ( request_id = 'REQ-RECEIPT-DAY' source_plant = '2000' )
        ( request_id = 'REQ-BEFORE' source_plant = '2000' )
        ( request_id = 'REQ-AFTER' source_plant = '2000' ) )
      it_projected_batch_receipts = VALUE #(
        ( material         = 'MAT-1'
          plant            = '2000'
          storage_location = '0002'
          batch            = 'B-INCOMING'
          expiration_date  = '20261215'
          receipt_date     = '20261020'
          base_quantity    = '3.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-RECEIPT-DAY'
      act = ls_result-allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-BEFORE'
      act = ls_result-allocations[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-AFTER'
      act = ls_result-allocations[ 3 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 3 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-INCOMING'
      act = ls_result-batch_allocations[ 1 ]-allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-batch_allocations[ 1 ]-allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-batch_allocations[ 1 ]-allocation-allocated_quantity ).
  ENDMETHOD.

  METHOD rejects_invalid_fefo_receipt.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_fefo_by_date(
          it_demands                  = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              required_date      = '20261020'
              requested_quantity = '1.000' ) )
          it_sources                  = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000' ) )
          it_projected_batch_receipts = VALUE #(
            ( material         = 'MAT-1'
              plant            = '2000'
              storage_location = '0002'
              batch            = 'B-INCOMING'
              expiration_date  = '20261215'
              receipt_date     = '20261301'
              base_quantity    = '1.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD protects_fefo_receipt_buffer.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-OPEN'
          expiration_date    = '20261130'
          available_quantity = '1.000' ) ) ).
    lo_repository->set_safety_stock( iv_quantity = '2.000' ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    DATA(ls_result) = lo_cut->allocate_plants_fefo_by_date(
      it_demands                  = VALUE #(
        ( request_id         = 'REQ-EARLY'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261010'
          requested_quantity = '1.000' )
        ( request_id         = 'REQ-AFTER-RECEIPT'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261020'
          requested_quantity = '2.000' ) )
      it_sources                  = VALUE #(
        ( request_id = 'REQ-EARLY' source_plant = '2000' )
        ( request_id = 'REQ-AFTER-RECEIPT' source_plant = '2000' ) )
      it_projected_batch_receipts = VALUE #(
        ( material         = 'MAT-1'
          plant            = '2000'
          storage_location = '0002'
          batch            = 'B-INCOMING'
          expiration_date  = '20261215'
          receipt_date     = '20261020'
          base_quantity    = '3.000' ) )
      iv_protect_safety_stock     = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-batch_allocations[ 1 ]-allocation-available_quantity ).
  ENDMETHOD.

  METHOD prioritizes_dated_fefo_locs.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-SAME'
          expiration_date    = '20261020'
          available_quantity = '4.000' )
        ( storage_location   = '0002'
          batch              = 'B-SAME'
          expiration_date    = '20261020'
          available_quantity = '5.000' )
        ( storage_location   = '0003'
          batch              = 'B-SAME'
          expiration_date    = '20261020'
          available_quantity = '100.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA(lt_sources) = VALUE zcl_stock_service=>ty_plant_sources(
      ( request_id = 'REQ-1' source_plant = '2000' ) ).
    DATA(lt_allowed_locations) = VALUE zcl_stock_service=>ty_storage_locations(
      ( '0001' )
      ( '0002' ) ).
    DATA(lt_location_priority) = VALUE zcl_stock_service=>ty_storage_locations(
      ( '0002' )
      ( '0001' ) ).

    DATA(ls_base_result) = lo_cut->allocate_plants_fefo_by_date(
      it_demands                   = VALUE #(
        ( request_id         = 'REQ-1'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261010'
          requested_quantity = '3.000' ) )
      it_sources                   = lt_sources
      it_allowed_storage_locations = lt_allowed_locations
      it_storage_location_priority = lt_location_priority ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '9.000' )
      act = ls_base_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_base_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_base_result-batch_allocations[ 1 ]-allocation-storage_location ).

    DATA(ls_uom_result) = lo_cut->allocate_plants_fefo_date_uom(
      it_demands                   = VALUE #(
        ( request_id         = 'REQ-1'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261010'
          requested_quantity = '1.500'
          requested_unit     = 'BOX' ) )
      it_sources                   = lt_sources
      it_allowed_storage_locations = lt_allowed_locations
      it_storage_location_priority = lt_location_priority ).

    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_uom_result-batch_allocations[ 1 ]-allocation-allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_uom_result-batch_allocations[ 1 ]-allocation-allocation-allocated_quantity ).

    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    DATA(lo_atp_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).
    DATA(ls_atp_result) = lo_atp_cut->allocate_plants_fefo_date_atp(
      it_demands                   = VALUE #(
        ( request_id         = 'REQ-1'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261010'
          requested_quantity = '1.500'
          requested_unit     = 'BOX' ) )
      it_sources                   = lt_sources
      iv_check_rule                = 'A'
      it_allowed_storage_locations = lt_allowed_locations
      it_storage_location_priority = lt_location_priority ).

    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_atp_result-local_estimate-batch_allocations[ 1 ]-allocation-allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lo_availability_api->get_requests( ) ) ).
  ENDMETHOD.

  METHOD rejects_bad_dated_fefo_prio.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_fefo_by_date(
          it_demands                   = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              required_date      = '20261010'
              requested_quantity = '1.000' ) )
          it_sources                   = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000' ) )
          it_storage_location_priority = VALUE #(
            ( '0001' )
            ( '0001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->allocate_plants_fefo_date_uom(
          it_demands                   = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              required_date      = '20261010'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources                   = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000' ) )
          it_storage_location_priority = VALUE #(
            ( '0001' )
            ( '0001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD protects_dated_fefo_buffer.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-EARLY'
          expiration_date    = '20261020'
          available_quantity = '4.000' )
        ( storage_location   = '0002'
          batch              = 'B-LATE'
          expiration_date    = '20261201'
          available_quantity = '6.000' ) ) ).
    lo_repository->set_safety_stock( iv_quantity = '2.000' ).

    DATA(ls_result) = lo_cut->allocate_plants_fefo_by_date(
      it_demands              = VALUE #(
        ( request_id         = 'REQ-EARLY'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261010'
          requested_quantity = '5.000' )
        ( request_id         = 'REQ-LATE'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261030'
          requested_quantity = '4.000' ) )
      it_sources              = VALUE #(
        ( request_id = 'REQ-EARLY' source_plant = '2000' )
        ( request_id = 'REQ-LATE' source_plant = '2000' ) )
      iv_protect_safety_stock = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 2 ]-shortfall_quantity ).
  ENDMETHOD.

  METHOD rejects_missing_fefo_date.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_fefo_by_date(
          it_demands = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              requested_quantity = '2.000' ) )
          it_sources = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_fefo_from_locations.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-OTHER'
          expiration_date    = '20261011'
          available_quantity = '20.000' )
        ( storage_location   = '0002'
          batch              = 'B-ALLOWED'
          expiration_date    = '20261020'
          available_quantity = '8.000' ) ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    DATA(ls_result) = lo_cut->allocate_plants_fefo_by_date(
      it_demands                   = VALUE #(
        ( request_id         = 'REQ-1'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261010'
          requested_quantity = '5.000' ) )
      it_sources                   = VALUE #(
        ( request_id = 'REQ-1' source_plant = '2000' ) )
      it_allowed_storage_locations = VALUE #( ( '0002' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-ALLOWED'
      act = ls_result-batch_allocations[ 1 ]-allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-batch_allocations[ 1 ]-allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_invalid_fefo_locations.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_fefo_by_date(
          it_demands                   = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              required_date      = '20261010'
              requested_quantity = '5.000' ) )
          it_sources                   = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000' ) )
          it_allowed_storage_locations = VALUE #( ( '' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    CLEAR lv_exception_raised.
    TRY.
        lo_cut->allocate_plants_fefo_by_date(
          it_demands                   = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              required_date      = '20261010'
              requested_quantity = '5.000' ) )
          it_sources                   = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000' ) )
          it_allowed_storage_locations = VALUE #(
            ( '0001' )
            ( '0001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_source_scoped_fefo.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-REQ-A'
          expiration_date    = '20261020'
          available_quantity = '10.000' )
        ( storage_location   = '0002'
          batch              = 'B-REQ-B'
          expiration_date    = '20261021'
          available_quantity = '10.000' ) ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    DATA(ls_result) = lo_cut->allocate_plants_fefo_by_date(
      it_demands          = VALUE #(
        ( request_id         = 'REQ-A'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261010'
          requested_quantity = '5.000' )
        ( request_id         = 'REQ-B'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261011'
          requested_quantity = '4.000' ) )
      it_sources          = VALUE #(
        ( request_id = 'REQ-A' source_plant = '2000' )
        ( request_id = 'REQ-B' source_plant = '2000' ) )
      it_source_locations = VALUE #(
        ( request_id = 'REQ-A' source_plant = '2000'
          storage_location = '0001' )
        ( request_id = 'REQ-B' source_plant = '2000'
          storage_location = '0002' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-A'
      act = ls_result-batch_allocations[ 1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-REQ-A'
      act = ls_result-batch_allocations[ 1 ]-allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-batch_allocations[ 1 ]-allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-B'
      act = ls_result-batch_allocations[ 2 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-REQ-B'
      act = ls_result-batch_allocations[ 2 ]-allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-batch_allocations[ 2 ]-allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-batch_allocations[ 2 ]-allocation-allocated_quantity ).
  ENDMETHOD.

  METHOD rejects_bad_scoped_locations.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_fefo_by_date(
          it_demands          = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              required_date      = '20261010'
              requested_quantity = '5.000' ) )
          it_sources          = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000' ) )
          it_source_locations = VALUE #(
            ( request_id = 'REQ-1' source_plant = '3000'
              storage_location = '0001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    CLEAR lv_exception_raised.
    TRY.
        lo_cut->allocate_plants_fefo_by_date(
          it_demands          = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              required_date      = '20261010'
              requested_quantity = '5.000' ) )
          it_sources          = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000' )
            ( request_id = 'REQ-1' source_plant = '3000' ) )
          it_source_locations = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000'
              storage_location = '0001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_plants_fefo_date_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-EARLY'
          expiration_date    = '20261020'
          available_quantity = '3.000' )
        ( storage_location   = '0002'
          batch              = 'B-LATE'
          expiration_date    = '20261130'
          available_quantity = '12.000' )
        ( storage_location   = '0003'
          batch              = 'B-EXCLUDED'
          expiration_date    = '20261015'
          available_quantity = '100.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_result) = lo_cut->allocate_plants_fefo_date_uom(
      it_demands                   = VALUE #(
        ( request_id         = 'REQ-LATE'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261030'
          priority           = 1000
          requested_quantity = '1.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'REQ-EARLY'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261010'
          priority           = 0
          requested_quantity = '0.250'
          requested_unit     = 'BOX' )
        ( request_id              = 'REQ-STRICT'
          material                = 'MAT-1'
          target_plant            = '9000'
          required_date           = '20261010'
          priority                = 0
          requested_quantity      = '0.500'
          requested_unit          = 'BOX'
          minimum_shelf_life_days = 55 ) )
      it_sources                   = VALUE #(
        ( request_id = 'REQ-LATE' source_plant = '2000' )
        ( request_id = 'REQ-EARLY' source_plant = '2000' )
        ( request_id = 'REQ-STRICT' source_plant = '2000' ) )
      iv_min_days                  = 5
      it_allowed_storage_locations = VALUE #(
        ( '0001' )
        ( '0002' )
        ( '0003' ) )
      it_source_locations          = VALUE #(
        ( request_id = 'REQ-LATE' source_plant = '2000'
          storage_location = '0002' )
        ( request_id = 'REQ-EARLY' source_plant = '2000'
          storage_location = '0001' )
        ( request_id = 'REQ-STRICT' source_plant = '2000'
          storage_location = '0002' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-LATE'
      act = ls_result-allocations[ 1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261030'
      act = ls_result-allocations[ 1 ]-allocation-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-allocations[ 1 ]-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-EARLY'
      act = ls_result-allocations[ 2 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 2 ]-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-allocations[ 3 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1000
      act = ls_result-allocations[ 1 ]-allocation-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_result-allocations[ 2 ]-allocation-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATE'
      act = ls_result-batch_allocations[ 1 ]-allocation-allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1000
      act = ls_result-batch_allocations[ 1 ]-allocation-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-batch_allocations[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EARLY'
      act = ls_result-batch_allocations[ 2 ]-allocation-allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.250' )
      act = ls_result-batch_allocations[ 2 ]-allocated_source_quantity ).
    DATA(ls_restricted_result) = lo_cut->allocate_plants_fefo_date_uom(
      it_demands          = VALUE #(
        ( request_id              = 'REQ-STRICT'
          material                = 'MAT-1'
          target_plant            = '9000'
          required_date           = '20261030'
          requested_quantity      = '0.500'
          requested_unit          = 'BOX'
          minimum_shelf_life_days = 40 ) )
      it_sources          = VALUE #(
        ( request_id = 'REQ-STRICT' source_plant = '2000' ) )
      iv_min_days         = 5
      it_source_locations = VALUE #(
        ( request_id = 'REQ-STRICT' source_plant = '2000'
          storage_location = '0002' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_restricted_result-allocations[ 1 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = ls_restricted_result-allocations[ 1 ]-shortfall_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_fefo_receipt_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_result) = lo_cut->allocate_plants_fefo_date_uom(
      it_demands                  = VALUE #(
        ( request_id         = 'REQ-UOM-RECEIPT'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261020'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' ) )
      it_sources                  = VALUE #(
        ( request_id = 'REQ-UOM-RECEIPT' source_plant = '2000' ) )
      it_projected_batch_receipts = VALUE #(
        ( material         = 'MAT-1'
          plant            = '2000'
          storage_location = '0002'
          batch            = 'B-UOM-INCOMING'
          expiration_date  = '20261215'
          receipt_date     = '20261020'
          base_quantity    = '4.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-batch_allocations[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-batch_allocations[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-batch_allocations[ 1 ]-allocated_source_quantity ).
  ENDMETHOD.

  METHOD rejects_missing_fefo_uom_date.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_fefo_date_uom(
          it_demands = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD compares_dated_fefo_atp.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-EARLY'
          expiration_date    = '20261020'
          available_quantity = '3.000' )
        ( storage_location   = '0002'
          batch              = 'B-LATE'
          expiration_date    = '20261130'
          available_quantity = '12.000' )
        ( storage_location   = '0003'
          batch              = 'B-EXCLUDED'
          expiration_date    = '20261015'
          available_quantity = '100.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    lo_availability_api->set_result(
      is_result = VALUE #(
        available_at_plant_quantity = '9.000'
        confirmed_quantity          = '2.000'
        confirmation_lines          = VALUE #(
          ( confirmed_date = '20261030' confirmed_quantity = '1.250' )
          ( confirmed_date = '20261030' confirmed_quantity = '0.750' ) )
        is_fully_available          = abap_false
        is_check_relevant           = abap_true ) ).
    lo_availability_api->set_result_for_call(
      iv_call_number = 1
      is_result      = VALUE #(
        available_at_plant_quantity = '9.000'
        confirmed_quantity          = '3.000'
        is_fully_available          = abap_true
        is_check_relevant           = abap_true ) ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).

    DATA(ls_result) = lo_cut->allocate_plants_fefo_date_atp(
      it_demands                   = VALUE #(
        ( request_id         = 'REQ-LATE'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261030'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'REQ-EARLY'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261010'
          requested_quantity = '0.250'
          requested_unit     = 'BOX' )
        ( request_id              = 'REQ-STRICT'
          material                = 'MAT-1'
          target_plant            = '9000'
          required_date           = '20261010'
          requested_quantity      = '0.500'
          requested_unit          = 'BOX'
          minimum_shelf_life_days = 55 ) )
      it_sources                   = VALUE #(
        ( request_id = 'REQ-LATE' source_plant = '2000' )
        ( request_id = 'REQ-EARLY' source_plant = '2000' )
        ( request_id = 'REQ-STRICT' source_plant = '2000' ) )
      iv_check_rule                = 'A'
      iv_min_days                  = 5
      it_allowed_storage_locations = VALUE #(
        ( '0001' )
        ( '0002' )
        ( '0003' ) )
      it_source_locations          = VALUE #(
        ( request_id = 'REQ-LATE' source_plant = '2000'
          storage_location = '0002' )
        ( request_id = 'REQ-EARLY' source_plant = '2000'
          storage_location = '0001' )
        ( request_id = 'REQ-STRICT' source_plant = '2000'
          storage_location = '0002' ) ) ).
    DATA(lt_requests) = lo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-LATE'
      act = ls_result-local_estimate-allocations[ 1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-local_estimate-allocations[ 3 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATE'
      act = ls_result-local_estimate-batch_allocations[ 1 ]-allocation-allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EARLY'
      act = ls_result-local_estimate-batch_allocations[ 2 ]-allocation-allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261010'
      act = lt_requests[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_requests[ 1 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261030'
      act = lt_requests[ 2 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '15.000' )
      act = lt_requests[ 2 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 15
      act = ls_result-atp_checks[ 1 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 1 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '13.000' )
      act = ls_result-atp_checks[ 1 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = ls_result-atp_checks[ 2 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-EARLY'
      act = ls_result-atp_checks[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-atp_checks[ 2 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-atp_checks[ 2 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '9.000' )
      act = ls_result-atp_checks[ 1 ]-atp_result-available_at_plant_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
    DATA(ls_restricted_result) = lo_cut->allocate_plants_fefo_date_atp(
      it_demands                 = VALUE #(
        ( request_id              = 'STRICT-SHELF'
          material                = 'MAT-1'
          target_plant            = '9000'
          required_date           = '20261030'
          requested_quantity      = '0.500'
          requested_unit          = 'BOX'
          minimum_shelf_life_days = 40 ) )
      it_sources                 = VALUE #(
        ( request_id = 'STRICT-SHELF' source_plant = '2000' ) )
      iv_check_rule              = 'A'
      iv_min_days                = 5
      iv_include_undated_batches = abap_false
      it_source_locations        = VALUE #(
        ( request_id = 'STRICT-SHELF' source_plant = '2000'
          storage_location = '0002' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_restricted_result-local_estimate-allocations[ 1 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_restricted_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_availability_api->get_check_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD compares_fefo_receipt_atp.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    lo_availability_api->set_result(
      is_result = VALUE #(
        available_at_plant_quantity = '4.000'
        confirmed_quantity          = '4.000'
        confirmation_lines          = VALUE #(
          ( confirmed_date = '20261020' confirmed_quantity = '4.000' ) )
        is_fully_available          = abap_true
        is_check_relevant           = abap_true ) ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).

    DATA(ls_result) = lo_cut->allocate_plants_fefo_date_atp(
      it_demands                  = VALUE #(
        ( request_id         = 'REQ-ATP-RECEIPT'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261020'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' ) )
      it_sources                  = VALUE #(
        ( request_id = 'REQ-ATP-RECEIPT' source_plant = '2000' ) )
      it_projected_batch_receipts = VALUE #(
        ( material         = 'MAT-1'
          plant            = '2000'
          storage_location = '0002'
          batch            = 'B-ATP-INCOMING'
          expiration_date  = '20261215'
          receipt_date     = '20261020'
          base_quantity    = '4.000' ) )
      iv_check_rule               = 'A' ).
    DATA(lt_requests) = lo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-local_estimate-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_requests[ 1 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-atp_checks[ 1 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-atp_checks[ 1 ]-confirmed_base_quantity ).
  ENDMETHOD.

  METHOD rejects_dated_fefo_atp_rule.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_fefo_date_atp(
          it_demands    = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              required_date      = '20261010'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources    = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000' ) )
          iv_check_rule = '' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_availability_api->get_check_count( ) ).
  ENDMETHOD.

  METHOD allocates_plants_fefo_units.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-EARLY'
          expiration_date    = '20260928'
          available_quantity = '10.000' )
        ( storage_location   = '0001'
          batch              = 'B-LATER'
          expiration_date    = '20261010'
          available_quantity = '15.000' )
        ( storage_location   = '0001'
          batch              = 'B-TOO-SOON'
          expiration_date    = '20260927'
          available_quantity = '100.000' )
        ( storage_location   = '0001'
          batch              = 'B-UNDATED'
          available_quantity = '100.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_result) = lo_cut->allocate_plants_fefo_in_units(
      it_demands    = VALUE #(
        ( request_id         = 'REQ-1'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '1.500'
          requested_unit     = 'BOX' )
        ( request_id         = 'REQ-2'
          material           = 'MAT-1'
          target_plant       = '9001'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) )
      it_sources    = VALUE #(
        ( request_id = 'REQ-1' source_plant = '2000' )
        ( request_id = 'REQ-1' source_plant = '1000' )
        ( request_id = 'REQ-2' source_plant = '2000' )
        ( request_id = 'REQ-2' source_plant = '1000' ) )
      iv_as_of_date = '20260923'
      iv_min_days   = 5 ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-allocations[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '18.000' )
      act = ls_result-allocations[ 1 ]-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.500' )
      act = ls_result-allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-plant_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EARLY'
      act = ls_result-batch_allocations[ 1 ]-allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_result-batch_allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.833' )
      act = ls_result-batch_allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_result-batch_allocations[ 2 ]-allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-2'
      act = ls_result-batch_allocations[ 3 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = ls_result-batch_allocations[ 4 ]-allocation-source_plant ).
    DATA(ls_restricted_result) = lo_cut->allocate_plants_fefo_in_units(
      it_demands    = VALUE #(
        ( request_id              = 'REQ-STRICT'
          material                = 'MAT-1'
          target_plant            = '9000'
          requested_quantity      = '1.000'
          requested_unit          = 'BOX'
          minimum_shelf_life_days = 10 ) )
      it_sources    = VALUE #(
        ( request_id = 'REQ-STRICT' source_plant = '2000' ) )
      iv_as_of_date = '20260923'
      iv_min_days   = 5 ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_restricted_result-batch_allocations[ 1 ]-allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_restricted_result-batch_allocations[ 1 ]-allocation-minimum_shelf_life_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD prioritizes_plant_fefo.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-EARLY'
          expiration_date    = '20261001'
          available_quantity = '10.000' )
        ( storage_location   = '0002'
          batch              = 'B-LATER'
          expiration_date    = '20261015'
          available_quantity = '10.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA(lt_sources) = VALUE zcl_stock_service=>ty_plant_sources(
      ( request_id = 'REQ-LOW'  source_plant = '2000' )
      ( request_id = 'REQ-HIGH' source_plant = '2000' ) ).

    DATA(ls_result) = lo_cut->allocate_plants_fefo_priority(
      it_demands    = VALUE #(
        ( request_id         = 'REQ-LOW'
          material           = 'MAT-1'
          target_plant       = '9000'
          priority           = 0
          requested_quantity = '15.000' )
        ( request_id         = 'REQ-HIGH'
          material           = 'MAT-1'
          target_plant       = '9001'
          priority           = 10
          requested_quantity = '15.000' ) )
      it_sources    = lt_sources
      iv_as_of_date = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-LOW'
      act = ls_result-allocations[ 1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_result-allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-HIGH'
      act = ls_result-allocations[ 2 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_result-allocations[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '15.000' )
      act = ls_result-allocations[ 2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-plant_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-LOW'
      act = ls_result-plant_allocations[ 1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-LOW'
      act = ls_result-batch_allocations[ 1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_result-batch_allocations[ 1 ]-allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_result-batch_allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-HIGH'
      act = ls_result-batch_allocations[ 2 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EARLY'
      act = ls_result-batch_allocations[ 2 ]-allocation-batch ).

    DATA(ls_uom_result) = lo_cut->allocate_plants_fefo_uom_prio(
      it_demands    = VALUE #(
        ( request_id         = 'REQ-LOW-UOM'
          material           = 'MAT-1'
          target_plant       = '9000'
          priority           = 0
          requested_quantity = '7.500'
          requested_unit     = 'BOX' )
        ( request_id         = 'REQ-HIGH-UOM'
          material           = 'MAT-1'
          target_plant       = '9001'
          priority           = 10
          requested_quantity = '7.500'
          requested_unit     = 'BOX' ) )
      it_sources    = VALUE #(
        ( request_id = 'REQ-LOW-UOM'  source_plant = '2000' )
        ( request_id = 'REQ-HIGH-UOM' source_plant = '2000' ) )
      iv_as_of_date = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-LOW-UOM'
      act = ls_uom_result-allocations[ 1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_uom_result-allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_uom_result-allocations[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.500' )
      act = ls_uom_result-allocations[ 1 ]-allocation-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-HIGH-UOM'
      act = ls_uom_result-allocations[ 2 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '15.000' )
      act = ls_uom_result-allocations[ 2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-LOW-UOM'
      act = ls_uom_result-batch_allocations[ 1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_uom_result-batch_allocations[ 1 ]-allocation-allocation-batch ).

    DATA(lv_stock_read_count) = lo_repository->get_read_count( ).
    DATA(lv_uom_read_count) =
      lo_uom_repository->get_read_count( ).
    DATA lv_exception_raised TYPE abap_bool.
    TRY.
        lo_cut->allocate_plants_fefo_priority(
          it_demands = VALUE #(
            ( request_id         = 'REQ-DUP'
              material           = 'MAT-1'
              target_plant       = '9000'
              priority           = 0
              requested_quantity = '1.000' )
            ( request_id         = 'REQ-DUP'
              material           = 'MAT-1'
              target_plant       = '9001'
              priority           = 10
              requested_quantity = '1.000' ) )
          it_sources = VALUE #(
            ( request_id = 'REQ-DUP' source_plant = '2000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_stock_read_count
      act = lo_repository->get_read_count( ) ).

    CLEAR lv_exception_raised.
    TRY.
        lo_cut->allocate_plants_fefo_uom_prio(
          it_demands = VALUE #(
            ( request_id         = 'REQ-DUP-UOM'
              material           = 'MAT-1'
              target_plant       = '9000'
              priority           = 0
              requested_quantity = '1.000'
              requested_unit     = 'BOX' )
            ( request_id         = 'REQ-DUP-UOM'
              material           = 'MAT-1'
              target_plant       = '9001'
              priority           = 10
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources = VALUE #(
            ( request_id = 'REQ-DUP-UOM' source_plant = '2000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_stock_read_count
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_uom_read_count
      act = lo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD prioritizes_plant_fefo_atp.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-EARLY'
          expiration_date    = '20261001'
          available_quantity = '10.000' )
        ( storage_location   = '0002'
          batch              = 'B-LATER'
          expiration_date    = '20261015'
          available_quantity = '10.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    lo_availability_api->set_result(
      is_result = VALUE #(
        available_at_plant_quantity = '20.000'
        confirmed_quantity          = '12.000'
        confirmation_lines          = VALUE #(
          ( confirmed_date = sy-datum confirmed_quantity = '12.000' ) )
        is_fully_available          = abap_false
        is_check_relevant           = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).

    DATA(ls_result) = lo_cut->allocate_plants_fefo_uom_atp(
      it_demands    = VALUE #(
        ( request_id         = 'REQ-LOW'
          material           = 'MAT-1'
          target_plant       = '9000'
          priority           = 0
          requested_quantity = '7.500'
          requested_unit     = 'BOX' )
        ( request_id         = 'REQ-HIGH'
          material           = 'MAT-1'
          target_plant       = '9001'
          priority           = 10
          requested_quantity = '7.500'
          requested_unit     = 'BOX' ) )
      it_sources    = VALUE #(
        ( request_id = 'REQ-LOW'  source_plant = '2000' )
        ( request_id = 'REQ-HIGH' source_plant = '2000' ) )
      iv_check_rule = 'A'
      iv_as_of_date = '20260923' ).
    DATA(lt_atp_requests) = lo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-LOW'
      act = ls_result-local_estimate-allocations[ 1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_result-local_estimate-allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-local_estimate-allocations[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-HIGH'
      act = ls_result-local_estimate-allocations[ 2 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '15.000' )
      act = ls_result-local_estimate-allocations[ 2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = ls_result-atp_checks[ 1 ]-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '20.000' )
      act = ls_result-atp_checks[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-atp_checks[ 1 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_result-atp_checks[ 1 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_availability_api->get_check_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '20.000' )
      act = lt_atp_requests[ 1 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_atp_requests[ 1 ]-unit ).
  ENDMETHOD.

  METHOD prioritizes_plant_demands.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_plant_location_stock(
      iv_material         = 'MAT-1'
      iv_plant            = '2000'
      iv_storage_location = '0001'
      iv_quantity         = '10.000' ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    lo_availability_api->set_result(
      is_result = VALUE #(
        available_at_plant_quantity = '25.000'
        confirmed_quantity          = '18.000'
        confirmation_lines          = VALUE #(
          ( confirmed_date = sy-datum confirmed_quantity = '18.000' ) )
        is_fully_available          = abap_false
        is_check_relevant           = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).
    DATA(lt_sources) = VALUE zcl_stock_service=>ty_plant_sources(
      ( request_id = 'REQ-LOW'   source_plant = '2000' )
      ( request_id = 'REQ-HIGH1' source_plant = '2000' )
      ( request_id = 'REQ-HIGH2' source_plant = '2000' ) ).
    DATA(lt_receipts) = VALUE zcl_stock_service=>ty_dated_location_receipts(
      ( material         = 'MAT-1'
        plant            = '2000'
        storage_location = '0002'
        receipt_date     = sy-datum
        base_quantity    = '15.000' ) ).
    DATA(lt_cutoffs) = VALUE
      zcl_stock_service=>ty_dated_plant_location_request_indexes(
        ( request_id = 'REQ-LOW'   required_date = sy-datum )
        ( request_id = 'REQ-HIGH1' required_date = sy-datum )
        ( request_id = 'REQ-HIGH2' required_date = sy-datum ) ).

    DATA(ls_result) = lo_cut->allocate_plants_priority(
      it_demands            = VALUE #(
        ( request_id         = 'REQ-LOW'
          material           = 'MAT-1'
          target_plant       = '9000'
          priority           = 0
          requested_quantity = '15.000' )
        ( request_id         = 'REQ-HIGH1'
          material           = 'MAT-1'
          target_plant       = '9001'
          priority           = 10
          requested_quantity = '10.000' )
        ( request_id         = 'REQ-HIGH2'
          material           = 'MAT-1'
          target_plant       = '9002'
          priority           = 10
          requested_quantity = '10.000' ) )
      it_sources            = lt_sources
      it_projected_receipts = lt_receipts
      it_demand_cutoffs     = lt_cutoffs ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-LOW'
      act = ls_result-allocations[ 1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_result-allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-HIGH1'
      act = ls_result-allocations[ 2 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_result-allocations[ 2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-HIGH2'
      act = ls_result-allocations[ 3 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_result-allocations[ 3 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-LOW'
      act = ls_result-location_allocations[ 1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-HIGH1'
      act = ls_result-location_allocations[ 2 ]-allocation-request_id ).

    DATA(ls_uom_result) = lo_cut->allocate_plants_uom_priority(
      it_demands            = VALUE #(
        ( request_id         = 'REQ-LOW-UOM'
          material           = 'MAT-1'
          target_plant       = '9000'
          priority           = 0
          requested_quantity = '7.500'
          requested_unit     = 'BOX' )
        ( request_id         = 'REQ-HIGH1-UOM'
          material           = 'MAT-1'
          target_plant       = '9001'
          priority           = 10
          requested_quantity = '5.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'REQ-HIGH2-UOM'
          material           = 'MAT-1'
          target_plant       = '9002'
          priority           = 10
          requested_quantity = '5.000'
          requested_unit     = 'BOX' ) )
      it_sources            = VALUE #(
        ( request_id = 'REQ-LOW-UOM'   source_plant = '2000' )
        ( request_id = 'REQ-HIGH1-UOM' source_plant = '2000' )
        ( request_id = 'REQ-HIGH2-UOM' source_plant = '2000' ) )
      it_projected_receipts = lt_receipts
      it_demand_cutoffs     = VALUE
        zcl_stock_service=>ty_dated_plant_location_request_indexes(
          ( request_id = 'REQ-LOW-UOM'   required_date = sy-datum )
          ( request_id = 'REQ-HIGH1-UOM' required_date = sy-datum )
          ( request_id = 'REQ-HIGH2-UOM' required_date = sy-datum ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-LOW-UOM'
      act = ls_uom_result-allocations[ 1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_uom_result-allocations[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.500' )
      act = ls_uom_result-allocations[ 1 ]-allocation-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-HIGH1-UOM'
      act = ls_uom_result-allocations[ 2 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-HIGH2-UOM'
      act = ls_uom_result-allocations[ 3 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_uom_result-allocations[ 3 ]-priority ).

    DATA(ls_atp_result) = lo_cut->allocate_plants_uom_atp_prio(
      it_demands            = VALUE #(
        ( request_id         = 'REQ-LOW-ATP'
          material           = 'MAT-1'
          target_plant       = '9000'
          priority           = 0
          requested_quantity = '7.500'
          requested_unit     = 'BOX' )
        ( request_id         = 'REQ-HIGH-ATP'
          material           = 'MAT-1'
          target_plant       = '9001'
          priority           = 10
          requested_quantity = '10.000'
          requested_unit     = 'BOX' ) )
      it_sources            = VALUE #(
        ( request_id = 'REQ-LOW-ATP'  source_plant = '2000' )
        ( request_id = 'REQ-HIGH-ATP' source_plant = '2000' ) )
      it_projected_receipts = lt_receipts
      it_demand_cutoffs     = VALUE
        zcl_stock_service=>ty_dated_plant_location_request_indexes(
          ( request_id = 'REQ-LOW-ATP'  required_date = sy-datum )
          ( request_id = 'REQ-HIGH-ATP' required_date = sy-datum ) )
      iv_check_rule         = 'A' ).
    DATA(lt_atp_requests) = lo_availability_api->get_requests( ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_atp_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '25.000' )
      act = ls_atp_result-atp_checks[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_atp_requests ) ).

    DATA(lv_stock_reads) = lo_repository->get_read_count( ).
    DATA(lv_uom_reads) = lo_uom_repository->get_read_count( ).
    DATA lv_duplicate_rejected TYPE abap_bool.
    TRY.
        lo_cut->allocate_plants_uom_priority(
          it_demands = VALUE #(
            ( request_id         = 'REQ-DUP'
              material           = 'MAT-1'
              target_plant       = '9000'
              priority           = 0
              requested_quantity = '1.000'
              requested_unit     = 'BOX' )
            ( request_id         = 'REQ-DUP'
              material           = 'MAT-1'
              target_plant       = '9001'
              priority           = 10
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources = VALUE #(
            ( request_id = 'REQ-DUP' source_plant = '2000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_duplicate_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_duplicate_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_stock_reads
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_uom_reads
      act = lo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD alloc_exp_rcpt_uom_atp.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).
    DATA(lt_receipts) = VALUE zcl_stock_service=>ty_dated_batch_receipts(
      ( material         = 'MAT-1'
        plant            = '2000'
        storage_location = '0002'
        batch            = 'B-RECEIPT'
        expiration_date  = '20261215'
        receipt_date     = '20261020'
        base_quantity    = '4.000' )
      ( material         = 'MAT-1'
        plant            = '2000'
        storage_location = '0003'
        batch            = 'B-FUTURE'
        expiration_date  = '20261231'
        receipt_date     = '20261021'
        base_quantity    = '100.000' ) ).
    DATA(lt_demands) = VALUE zcl_stock_service=>ty_unit_plant_demands(
      ( request_id         = 'REQ-EXPIRY-UOM'
        material           = 'MAT-1'
        target_plant       = '9000'
        requested_quantity = '1.000'
        requested_unit     = 'BOX' ) ).
    DATA(lt_sources) = VALUE zcl_stock_service=>ty_plant_sources(
      ( request_id = 'REQ-EXPIRY-UOM' source_plant = '2000' ) ).

    DATA(ls_uom_result) = lo_cut->allocate_plants_fefo_in_units(
      it_demands                  = lt_demands
      it_sources                  = lt_sources
      it_projected_batch_receipts = lt_receipts
      iv_as_of_date               = '20261020'
      iv_min_days                 = 5 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_uom_result-allocations[ 1 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_uom_result-allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-RECEIPT'
      act = ls_uom_result-batch_allocations[ 1 ]-allocation-batch ).

    DATA(ls_atp_result) = lo_cut->allocate_plants_fefo_atp(
      it_demands                  = lt_demands
      it_sources                  = lt_sources
      it_projected_batch_receipts = lt_receipts
      iv_check_rule               = 'A'
      iv_as_of_date               = '20261020'
      iv_min_days                 = 5 ).
    DATA(lt_atp_requests) = lo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_atp_result-local_estimate-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_atp_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_atp_requests[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_atp_requests[ 1 ]-requested_quantity ).
  ENDMETHOD.

  METHOD reject_exp_rcpt_pre_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_fefo_in_units(
          it_demands                  = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources                  = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000' ) )
          it_projected_batch_receipts = VALUE #(
            ( material         = 'MAT-1'
              plant            = '2000'
              storage_location = '0002'
              batch            = 'B-RECEIPT'
              expiration_date  = '20261215'
              receipt_date     = '20261301'
              base_quantity    = '1.000' ) )
          iv_as_of_date               = '20261020' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_unknown_plant_fefo_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_fefo_in_units(
          it_demands    = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources    = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000' ) )
          iv_as_of_date = '20260923' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_invalid_fefo_plant_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_fefo_in_units(
          it_demands    = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources    = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000' ) )
          iv_as_of_date = '20260923'
          iv_min_days   = -1 ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_invalid_plant_fefo.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_by_expiry(
          it_demands  = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              requested_quantity = '1.000' ) )
          it_sources  = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000' ) )
          iv_min_days = -1 ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_plants_by_batch.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          expiration_date    = '20261231'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          batch              = 'B-1'
          expiration_date    = '20261231'
          available_quantity = '3.000' )
        ( storage_location   = '0001'
          batch              = 'B-2'
          available_quantity = '100.000' ) ) ).

    DATA(ls_result) = lo_cut->allocate_plants_by_batch(
      it_demands = VALUE #(
        ( request_id         = 'REQ-1'
          material           = 'MAT-1'
          target_plant       = '9000'
          batch              = 'B-1'
          requested_quantity = '6.000' )
        ( request_id         = 'REQ-2'
          material           = 'MAT-1'
          target_plant       = '9001'
          batch              = 'B-1'
          requested_quantity = '5.000' ) )
      it_sources = VALUE #(
        ( request_id = 'REQ-1' source_plant = '2000' )
        ( request_id = 'REQ-1' source_plant = '1000' )
        ( request_id = 'REQ-2' source_plant = '2000' )
        ( request_id = 'REQ-2' source_plant = '1000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-allocations[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 2 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-plant_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = ls_result-plant_allocations[ 1 ]-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-plant_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = lines( ls_result-location_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-location_allocations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-location_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261231'
      act = ls_result-location_allocations[ 1 ]-expiration_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-2'
      act = ls_result-location_allocations[ 4 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD prioritizes_plant_batch.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-SHARED'
          expiration_date    = '20261231'
          available_quantity = '10.000' )
        ( storage_location   = '0002'
          batch              = 'B-SHARED'
          expiration_date    = '20261231'
          available_quantity = '10.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_result) = lo_cut->allocate_plants_batch_priority(
      it_demands = VALUE #(
        ( request_id         = 'REQ-LOW'
          material           = 'MAT-1'
          target_plant       = '9000'
          batch              = 'B-SHARED'
          priority           = 0
          requested_quantity = '15.000' )
        ( request_id         = 'REQ-HIGH'
          material           = 'MAT-1'
          target_plant       = '9001'
          batch              = 'B-SHARED'
          priority           = 10
          requested_quantity = '15.000' ) )
      it_sources = VALUE #(
        ( request_id = 'REQ-LOW'  source_plant = '2000' )
        ( request_id = 'REQ-HIGH' source_plant = '2000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-LOW'
      act = ls_result-allocations[ 1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_result-allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-HIGH'
      act = ls_result-allocations[ 2 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '15.000' )
      act = ls_result-allocations[ 2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-LOW'
      act = ls_result-location_allocations[ 1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-location_allocations[ 1 ]-allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_result-location_allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-HIGH'
      act = ls_result-location_allocations[ 2 ]-allocation-request_id ).

    DATA(ls_uom_result) = lo_cut->allocate_plants_batch_uom_prio(
      it_demands = VALUE #(
        ( request_id         = 'REQ-LOW-UOM'
          material           = 'MAT-1'
          target_plant       = '9000'
          batch              = 'B-SHARED'
          priority           = 0
          requested_quantity = '7.500'
          requested_unit     = 'BOX' )
        ( request_id         = 'REQ-HIGH-UOM'
          material           = 'MAT-1'
          target_plant       = '9001'
          batch              = 'B-SHARED'
          priority           = 10
          requested_quantity = '7.500'
          requested_unit     = 'BOX' ) )
      it_sources = VALUE #(
        ( request_id = 'REQ-LOW-UOM'  source_plant = '2000' )
        ( request_id = 'REQ-HIGH-UOM' source_plant = '2000' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-LOW-UOM'
      act = ls_uom_result-allocations[ 1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_uom_result-allocations[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.500' )
      act = ls_uom_result-allocations[ 1 ]-allocation-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-HIGH-UOM'
      act = ls_uom_result-allocations[ 2 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '15.000' )
      act = ls_uom_result-allocations[ 2 ]-allocation-allocation-allocated_quantity ).

    DATA(lv_stock_read_count) = lo_repository->get_read_count( ).
    DATA(lv_uom_read_count) = lo_uom_repository->get_read_count( ).
    DATA lv_exception_raised TYPE abap_bool.
    TRY.
        lo_cut->allocate_plants_batch_uom_prio(
          it_demands = VALUE #(
            ( request_id         = 'REQ-DUP'
              material           = 'MAT-1'
              target_plant       = '9000'
              batch              = 'B-SHARED'
              priority           = 0
              requested_quantity = '1.000'
              requested_unit     = 'BOX' )
            ( request_id         = 'REQ-DUP'
              material           = 'MAT-1'
              target_plant       = '9001'
              batch              = 'B-SHARED'
              priority           = 10
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources = VALUE #(
            ( request_id = 'REQ-DUP' source_plant = '2000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_stock_read_count
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_uom_read_count
      act = lo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD prioritizes_plant_batch_atp.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-SHARED'
          expiration_date    = '20261231'
          available_quantity = '10.000' )
        ( storage_location   = '0002'
          batch              = 'B-SHARED'
          expiration_date    = '20261231'
          available_quantity = '10.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    lo_availability_api->set_result(
      is_result = VALUE #(
        available_at_plant_quantity = '20.000'
        confirmed_quantity          = '12.000'
        confirmation_lines          = VALUE #(
          ( confirmed_date = sy-datum confirmed_quantity = '12.000' ) )
        is_fully_available          = abap_false
        is_check_relevant           = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).

    DATA(ls_result) = lo_cut->allocate_plants_batch_uom_atp(
      it_demands    = VALUE #(
        ( request_id         = 'REQ-LOW'
          material           = 'MAT-1'
          target_plant       = '9000'
          batch              = 'B-SHARED'
          priority           = 0
          requested_quantity = '7.500'
          requested_unit     = 'BOX' )
        ( request_id         = 'REQ-HIGH'
          material           = 'MAT-1'
          target_plant       = '9001'
          batch              = 'B-SHARED'
          priority           = 10
          requested_quantity = '7.500'
          requested_unit     = 'BOX' ) )
      it_sources    = VALUE #(
        ( request_id = 'REQ-LOW'  source_plant = '2000' )
        ( request_id = 'REQ-HIGH' source_plant = '2000' ) )
      iv_check_rule = 'A' ).
    DATA(lt_atp_requests) = lo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-LOW'
      act = ls_result-local_estimate-allocations[ 1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-local_estimate-allocations[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '20.000' )
      act = ls_result-atp_checks[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_atp_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_atp_requests[ 1 ]-unit ).
  ENDMETHOD.

  METHOD allocates_plant_batch_receipts.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_receipt_date TYPE d.
    DATA lv_receipt_expiration_date TYPE mcha-vfdat.
    DATA lv_early_date TYPE d.
    DATA lv_late_date TYPE d.
    lv_receipt_date = sy-datum + 2.
    lv_receipt_expiration_date = sy-datum + 4.
    lv_early_date = sy-datum + 1.
    lv_late_date = sy-datum + 3.

    DATA(ls_not_yet_available) = lo_cut->allocate_plants_by_batch(
      it_demands                  = VALUE #(
        ( request_id         = 'REQ-TODAY'
          material           = 'MAT-1'
          target_plant       = '9000'
          batch              = 'B-1'
          as_of_date         = sy-datum
          requested_quantity = '4.000' ) )
      it_sources                  = VALUE #(
        ( request_id = 'REQ-TODAY' source_plant = '2000' ) )
      it_projected_batch_receipts = VALUE #(
        ( material         = 'MAT-1'
          plant            = '2000'
          storage_location = '0001'
          batch            = 'B-1'
          receipt_date     = lv_receipt_date
          base_quantity    = '4.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_not_yet_available-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_not_yet_available-allocations[ 1 ]-shortfall_quantity ).

    DATA(ls_available_on_receipt_date) = lo_cut->allocate_plants_by_batch(
      it_demands                  = VALUE #(
        ( request_id         = 'REQ-RECEIPT'
          material           = 'MAT-1'
          target_plant       = '9000'
          batch              = 'B-1'
          as_of_date         = lv_receipt_date
          requested_quantity = '4.000' ) )
      it_sources                  = VALUE #(
        ( request_id = 'REQ-RECEIPT' source_plant = '2000' ) )
      it_projected_batch_receipts = VALUE #(
        ( material         = 'MAT-1'
          plant            = '2000'
          storage_location = '0001'
          batch            = 'B-1'
          receipt_date     = lv_receipt_date
          base_quantity    = '4.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_available_on_receipt_date-allocations[ 1 ]-allocated_quantity ).

    DATA(ls_unsorted_result) = lo_cut->allocate_plants_by_batch(
      it_demands                  = VALUE #(
        ( request_id         = 'LATE'
          material           = 'MAT-1'
          target_plant       = '9000'
          batch              = 'B-1'
          as_of_date         = lv_late_date
          requested_quantity = '4.000' )
        ( request_id         = 'EARLY'
          material           = 'MAT-1'
          target_plant       = '9000'
          batch              = 'B-1'
          as_of_date         = lv_early_date
          requested_quantity = '4.000' ) )
      it_sources                  = VALUE #(
        ( request_id = 'LATE' source_plant = '2000' )
        ( request_id = 'EARLY' source_plant = '2000' ) )
      it_projected_batch_receipts = VALUE #(
        ( material         = 'MAT-1'
          plant            = '2000'
          storage_location = '0001'
          batch            = 'B-1'
          receipt_date     = lv_receipt_date
          base_quantity    = '4.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY'
      act = ls_unsorted_result-allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_unsorted_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LATE'
      act = ls_unsorted_result-allocations[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_unsorted_result-allocations[ 2 ]-allocated_quantity ).

    DATA(ls_dated_result) = lo_cut->allocate_plants_batch_by_date(
      it_demands                  = VALUE #(
        ( request_id              = 'LATE'
          material                = 'MAT-1'
          target_plant            = '9000'
          required_date           = lv_late_date
          batch                   = 'B-1'
          minimum_shelf_life_days = 1
          requested_quantity      = '4.000' )
        ( request_id         = 'EARLY'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = lv_early_date
          batch              = 'B-1'
          requested_quantity = '4.000' ) )
      it_sources                  = VALUE #(
        ( request_id = 'LATE' source_plant = '2000' )
        ( request_id = 'EARLY' source_plant = '2000' ) )
      it_projected_batch_receipts = VALUE #(
        ( material         = 'MAT-1'
          plant            = '2000'
          storage_location = '0001'
          batch            = 'B-1'
          expiration_date  = lv_receipt_expiration_date
          receipt_date     = lv_receipt_date
          base_quantity    = '4.000' ) )
      iv_require_full_quantity    = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'LATE'
      act = ls_dated_result-allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_dated_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY'
      act = ls_dated_result-allocations[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_dated_result-allocations[ 2 ]-allocated_quantity ).
  ENDMETHOD.

  METHOD filters_plant_batch_life.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_eligible_date TYPE d.
    DATA lv_expiration_date TYPE mcha-vfdat.
    DATA lv_expired_date TYPE d.
    DATA lv_rejected TYPE abap_bool.
    lv_eligible_date = sy-datum + 9.
    lv_expiration_date = sy-datum + 10.
    lv_expired_date = sy-datum + 10.
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          expiration_date    = lv_expiration_date
          available_quantity = '10.000' ) ) ).

    DATA(ls_result) = lo_cut->allocate_plants_by_batch(
      it_demands = VALUE #(
        ( request_id              = 'EXPIRED'
          material                = 'MAT-1'
          target_plant            = '9000'
          batch                   = 'B-1'
          as_of_date              = lv_expired_date
          minimum_shelf_life_days = 1
          requested_quantity      = '5.000' )
        ( request_id              = 'ELIGIBLE'
          material                = 'MAT-1'
          target_plant            = '9000'
          batch                   = 'B-1'
          as_of_date              = lv_eligible_date
          minimum_shelf_life_days = 1
          requested_quantity      = '5.000' ) )
      it_sources = VALUE #(
        ( request_id = 'EXPIRED' source_plant = '2000' )
        ( request_id = 'ELIGIBLE' source_plant = '2000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'ELIGIBLE'
      act = ls_result-allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-allocations[ 1 ]-minimum_shelf_life_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EXPIRED'
      act = ls_result-allocations[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-allocations[ 2 ]-available_quantity ).

    TRY.
        lo_cut->allocate_plants_by_batch(
          it_demands = VALUE #(
            ( request_id              = 'NO-CUTOFF'
              material                = 'MAT-1'
              target_plant            = '9000'
              batch                   = 'B-1'
              minimum_shelf_life_days = 1
              requested_quantity      = '1.000' ) )
          it_sources = VALUE #(
            ( request_id = 'NO-CUTOFF' source_plant = '2000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD filters_undated_plant_batch.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          available_quantity = '10.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    lo_availability_api->set_result(
      is_result = VALUE #(
        available_at_plant_quantity = '10.000'
        confirmed_quantity          = '10.000'
        is_fully_available          = abap_true
        is_check_relevant           = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).

    DATA(ls_included) = lo_cut->allocate_plants_by_batch(
      it_demands = VALUE #(
        ( request_id         = 'INCLUDED'
          material           = 'MAT-1'
          target_plant       = '9000'
          batch              = 'B-1'
          requested_quantity = '4.000' ) )
      it_sources = VALUE #(
        ( request_id = 'INCLUDED' source_plant = '2000' ) ) ).
    DATA(ls_excluded) = lo_cut->allocate_plants_by_batch(
      it_demands                 = VALUE #(
        ( request_id         = 'EXCLUDED'
          material           = 'MAT-1'
          target_plant       = '9000'
          batch              = 'B-1'
          requested_quantity = '4.000' ) )
      it_sources                 = VALUE #(
        ( request_id = 'EXCLUDED' source_plant = '2000' ) )
      iv_include_undated_batches = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_included-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_excluded-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_excluded-allocations[ 1 ]-allocated_quantity ).

    DATA(ls_projected_included) = lo_cut->allocate_plants_by_batch(
      it_demands                  = VALUE #(
        ( request_id         = 'RECEIPT-INCLUDED'
          material           = 'MAT-1'
          target_plant       = '9000'
          batch              = 'B-2'
          requested_quantity = '3.000' ) )
      it_sources                  = VALUE #(
        ( request_id = 'RECEIPT-INCLUDED' source_plant = '2000' ) )
      it_projected_batch_receipts = VALUE #(
        ( material         = 'MAT-1'
          plant            = '2000'
          storage_location = '0002'
          batch            = 'B-2'
          receipt_date     = sy-datum
          base_quantity    = '6.000' ) ) ).
    DATA(ls_projected_excluded) = lo_cut->allocate_plants_by_batch(
      it_demands                  = VALUE #(
        ( request_id         = 'RECEIPT-EXCLUDED'
          material           = 'MAT-1'
          target_plant       = '9000'
          batch              = 'B-2'
          requested_quantity = '3.000' ) )
      it_sources                  = VALUE #(
        ( request_id = 'RECEIPT-EXCLUDED' source_plant = '2000' ) )
      it_projected_batch_receipts = VALUE #(
        ( material         = 'MAT-1'
          plant            = '2000'
          storage_location = '0002'
          batch            = 'B-2'
          receipt_date     = sy-datum
          base_quantity    = '6.000' ) )
      iv_include_undated_batches  = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_projected_included-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_projected_excluded-allocations[ 1 ]-available_quantity ).

    DATA(lv_required_date) = CONV d( sy-datum + 2 ).
    DATA(ls_dated_result) = lo_cut->allocate_plants_batch_by_date(
      it_demands                 = VALUE #(
        ( request_id         = 'DATED'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = lv_required_date
          batch              = 'B-1'
          requested_quantity = '4.000' ) )
      it_sources                 = VALUE #(
        ( request_id = 'DATED' source_plant = '2000' ) )
      iv_include_undated_batches = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_dated_result-allocations[ 1 ]-available_quantity ).

    DATA(ls_unit_result) = lo_cut->allocate_plants_batch_in_units(
      it_demands                 = VALUE #(
        ( request_id         = 'UNIT'
          material           = 'MAT-1'
          target_plant       = '9000'
          batch              = 'B-1'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' ) )
      it_sources                 = VALUE #(
        ( request_id = 'UNIT' source_plant = '2000' ) )
      iv_include_undated_batches = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_unit_result-allocations[ 1 ]-available_source_quantity ).

    DATA(ls_dated_unit_result) = lo_cut->allocate_plants_date_batch_uom(
      it_demands                 = VALUE #(
        ( request_id         = 'DATED-UNIT'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = lv_required_date
          batch              = 'B-1'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' ) )
      it_sources                 = VALUE #(
        ( request_id = 'DATED-UNIT' source_plant = '2000' ) )
      iv_include_undated_batches = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_dated_unit_result-allocations[ 1 ]-allocation-available_quantity ).

    DATA(ls_atp_result) = lo_cut->allocate_plants_batch_atp(
      it_demands                 = VALUE #(
        ( request_id         = 'ATP'
          material           = 'MAT-1'
          target_plant       = '9000'
          batch              = 'B-1'
          requested_quantity = '2.000'
          requested_unit     = 'EA' ) )
      it_sources                 = VALUE #(
        ( request_id = 'ATP' source_plant = '2000' ) )
      iv_check_rule              = 'A'
      iv_include_undated_batches = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_atp_result-local_estimate-allocations[ 1 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_atp_result-atp_checks ) ).

    DATA(ls_dated_atp_result) = lo_cut->allocate_plants_date_batch_atp(
      it_demands                 = VALUE #(
        ( request_id         = 'DATED-ATP'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = lv_required_date
          batch              = 'B-1'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' ) )
      it_sources                 = VALUE #(
        ( request_id = 'DATED-ATP' source_plant = '2000' ) )
      iv_check_rule              = 'A'
      iv_include_undated_batches = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_dated_atp_result-local_estimate-allocations[ 1 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_dated_atp_result-atp_checks ) ).

    DATA(ls_single_included) = lo_cut->allocate_by_batch(
      it_demands = VALUE #(
        ( request_id         = 'SINGLE-INCLUDED'
          material           = 'MAT-1'
          plant              = '2000'
          batch              = 'B-1'
          requested_quantity = '4.000' ) ) ).
    DATA(ls_single_excluded) = lo_cut->allocate_by_batch(
      it_demands                 = VALUE #(
        ( request_id         = 'SINGLE-EXCLUDED'
          material           = 'MAT-1'
          plant              = '2000'
          batch              = 'B-1'
          requested_quantity = '4.000' ) )
      iv_include_undated_batches = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_single_included-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_single_excluded-allocations[ 1 ]-available_quantity ).

    DATA(ls_single_unit_excluded) = lo_cut->allocate_by_batch_in_units(
      it_demands                 = VALUE #(
        ( request_id         = 'SINGLE-UNIT'
          material           = 'MAT-1'
          plant              = '2000'
          batch              = 'B-1'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' ) )
      iv_include_undated_batches = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_single_unit_excluded-allocations[ 1 ]-allocation-available_quantity ).

    DATA(ls_single_atp_excluded) = lo_cut->allocate_by_batch_atp(
      it_demands                 = VALUE #(
        ( request_id         = 'SINGLE-ATP'
          material           = 'MAT-1'
          plant              = '2000'
          batch              = 'B-1'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' ) )
      iv_check_rule              = 'A'
      iv_include_undated_batches = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_single_atp_excluded-local_estimate-allocations[ 1 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_single_atp_excluded-atp_checks ) ).

    DATA(lv_uom_reads) = lo_uom_repository->get_read_count( ).
    DATA(lv_stock_reads) = lo_repository->get_read_count( ).
    DATA lv_rejected TYPE abap_bool.
    TRY.
        lo_cut->allocate_plants_batch_in_units(
          it_demands                 = VALUE #(
            ( request_id         = 'INVALID'
              material           = 'MAT-1'
              target_plant       = '9000'
              batch              = 'B-1'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources                 = VALUE #(
            ( request_id = 'INVALID' source_plant = '2000' ) )
          iv_include_undated_batches = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_uom_reads
      act = lo_uom_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_stock_reads
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_missing_plant_batch.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_by_batch(
          it_demands = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              requested_quantity = '1.000' ) )
          it_sources = VALUE #(
            ( request_id = 'REQ-1' source_plant = '1000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_dated_plant_batches.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          expiration_date    = '20261231'
          available_quantity = '6.000' ) ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    DATA(ls_result) = lo_cut->allocate_plants_batch_by_date(
      it_demands               = VALUE #(
        ( request_id         = 'LATE'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261231'
          priority           = 100
          batch              = 'B-1'
          requested_quantity = '4.000' )
        ( request_id         = 'EARLY'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261201'
          priority           = 0
          batch              = 'B-1'
          requested_quantity = '6.000' )
        ( request_id         = 'SAME-LOW'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261210'
          priority           = 0
          batch              = 'B-1'
          requested_quantity = '5.000' )
        ( request_id         = 'SAME-HIGH'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261210'
          priority           = 10
          batch              = 'B-1'
          requested_quantity = '5.000' ) )
      it_sources               = VALUE #(
        ( request_id = 'LATE' source_plant = '2000' )
        ( request_id = 'LATE' source_plant = '1000' )
        ( request_id = 'EARLY' source_plant = '2000' )
        ( request_id = 'EARLY' source_plant = '1000' )
        ( request_id = 'SAME-LOW' source_plant = '2000' )
        ( request_id = 'SAME-LOW' source_plant = '1000' )
        ( request_id = 'SAME-HIGH' source_plant = '2000' )
        ( request_id = 'SAME-HIGH' source_plant = '1000' ) )
      iv_require_full_quantity = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LATE'
      act = ls_result-allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261201' )
      act = ls_result-allocations[ 2 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_result-allocations[ 3 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-allocations[ 3 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_result-allocations[ 4 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-allocations[ 4 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SAME-HIGH'
      act = ls_result-location_allocations[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-location_allocations[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_batch_date.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_batch_by_date(
          it_demands = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              batch              = 'B-1'
              requested_quantity = '1.000' ) )
          it_sources = VALUE #(
            ( request_id = 'REQ-1' source_plant = '1000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_dated_batch_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          expiration_date    = '20261231'
          available_quantity = '10.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_result) = lo_cut->allocate_plants_date_batch_uom(
      it_demands               = VALUE #(
        ( request_id         = 'LATE'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261231'
          priority           = 100
          batch              = 'B-1'
          requested_quantity = '3.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'EARLY'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261201'
          priority           = 0
          batch              = 'B-1'
          requested_quantity = '3.000'
          requested_unit     = 'EA' ) )
      it_sources               = VALUE #(
        ( request_id = 'LATE' source_plant = '2000' )
        ( request_id = 'EARLY' source_plant = '2000' ) )
      iv_require_full_quantity = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'LATE'
      act = ls_result-allocations[ 1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = ls_result-allocations[ 1 ]-source_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-allocations[ 1 ]-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261231' )
      act = ls_result-allocations[ 1 ]-allocation-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-allocations[ 2 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 2 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-location_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY'
      act = ls_result-location_allocations[ 1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lo_uom_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_batch_uom_date.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_date_batch_uom(
          it_demands = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              batch              = 'B-1'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_plants_batch_units.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          expiration_date    = '20261231'
          available_quantity = '10.000' )
        ( storage_location   = '0002'
          batch              = 'B-1'
          expiration_date    = '20261231'
          available_quantity = '14.000' )
        ( storage_location   = '0001'
          batch              = 'B-2'
          available_quantity = '100.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_result) = lo_cut->allocate_plants_batch_in_units(
      it_demands = VALUE #(
        ( request_id         = 'REQ-1'
          material           = 'MAT-1'
          target_plant       = '9000'
          batch              = 'B-1'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'REQ-2'
          material           = 'MAT-1'
          target_plant       = '9001'
          batch              = 'B-1'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' ) )
      it_sources = VALUE #(
        ( request_id = 'REQ-1' source_plant = '2000' )
        ( request_id = 'REQ-2' source_plant = '2000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-allocations[ 1 ]-allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = ls_result-allocations[ 1 ]-source_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-allocations[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-available_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 2 ]-available_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 2 ]-shortfall_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-plant_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-plant_allocations[ 2 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-location_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.833' )
      act = ls_result-location_allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.167' )
      act = ls_result-location_allocations[ 2 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-location_allocations[ 3 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_plant_receipt_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_expiration_date TYPE mcha-vfdat.
    lv_expiration_date = sy-datum + 100.

    DATA(ls_result) = lo_cut->allocate_plants_batch_in_units(
      it_demands                  = VALUE #(
        ( request_id              = 'REQ-1'
          material                = 'MAT-1'
          target_plant            = '9000'
          batch                   = 'B-1'
          minimum_shelf_life_days = 30
          requested_quantity      = '2.000'
          requested_unit          = 'BOX' ) )
      it_sources                  = VALUE #(
        ( request_id = 'REQ-1' source_plant = '2000' ) )
      it_projected_batch_receipts = VALUE #(
        ( material         = 'MAT-1'
          plant            = '2000'
          storage_location = '0001'
          batch            = 'B-1'
          expiration_date  = lv_expiration_date
          receipt_date     = sy-datum
          base_quantity    = '4.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-available_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 30
      act = ls_result-allocations[ 1 ]-allocation-minimum_shelf_life_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_unmapped_receipt_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_batch_in_units(
          it_demands                  = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              batch              = 'B-1'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources                  = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000' ) )
          it_projected_batch_receipts = VALUE #(
            ( material         = 'MAT-1'
              plant            = '9999'
              storage_location = '0001'
              batch            = 'B-1'
              receipt_date     = sy-datum
              base_quantity    = '4.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_unknown_batch_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_batch_in_units(
          it_demands = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              batch              = 'B-1'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD protects_plant_batch_buffer.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          available_quantity = '5.000' )
        ( storage_location   = '0001'
          batch              = 'B-2'
          available_quantity = '5.000' ) ) ).
    lo_repository->set_safety_stock( iv_quantity = '2.000' ).

    DATA(ls_result) = lo_cut->allocate_plants_by_batch(
      it_demands              = VALUE #(
        ( request_id         = 'REQ-1'
          material           = 'MAT-1'
          target_plant       = '9000'
          batch              = 'B-1'
          requested_quantity = '5.000' ) )
      it_sources              = VALUE #(
        ( request_id = 'REQ-1' source_plant = '1000' ) )
      iv_protect_safety_stock = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD protects_projected_plant_batch.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          expiration_date    = '20261231'
          available_quantity = '1.000' ) ) ).
    lo_repository->set_safety_stock( iv_quantity = '3.000' ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_receipt_date TYPE d.
    lv_receipt_date = sy-datum + 2.

    DATA(ls_result) = lo_cut->allocate_plants_by_batch(
      it_demands                  = VALUE #(
        ( request_id         = 'REQ-1'
          material           = 'MAT-1'
          target_plant       = '9000'
          batch              = 'B-1'
          as_of_date         = lv_receipt_date
          requested_quantity = '5.000' ) )
      it_sources                  = VALUE #(
        ( request_id = 'REQ-1' source_plant = '2000' ) )
      it_projected_batch_receipts = VALUE #(
        ( material         = 'MAT-1'
          plant            = '2000'
          storage_location = '0001'
          batch            = 'B-1'
          expiration_date  = '20261231'
          receipt_date     = lv_receipt_date
          base_quantity    = '5.000' ) )
      iv_protect_safety_stock     = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-shortfall_quantity ).
  ENDMETHOD.

  METHOD protects_cross_plant_safety.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_plant_stock(
      iv_material = 'MAT-1'
      iv_plant    = '1000'
      iv_quantity = '5.000' ).
    lo_repository->set_safety_stock( iv_quantity = '2.000' ).

    DATA(ls_result) = lo_cut->allocate_across_plants(
      it_demands              = VALUE #(
        ( request_id         = 'REQ-1'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '5.000' ) )
      it_sources              = VALUE #(
        ( request_id = 'REQ-1' source_plant = '1000' ) )
      iv_protect_safety_stock = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-location_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD filters_cross_plant_units.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_plant_location_stock(
      iv_material         = 'MAT-1'
      iv_plant            = '2000'
      iv_storage_location = '0001'
      iv_quantity         = '4.000' ).
    lo_repository->set_plant_location_stock(
      iv_material         = 'MAT-1'
      iv_plant            = '2000'
      iv_storage_location = '0002'
      iv_quantity         = '50.000' ).
    lo_repository->set_plant_location_stock(
      iv_material         = 'MAT-1'
      iv_plant            = '2000'
      iv_storage_location = '0003'
      iv_quantity         = '100.000' ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          expiration_date    = '20261001'
          available_quantity = '4.000' )
        ( storage_location   = '0002'
          batch              = 'B-1'
          expiration_date    = '20261001'
          available_quantity = '50.000' )
        ( storage_location   = '0003'
          batch              = 'B-1'
          expiration_date    = '20261001'
          available_quantity = '100.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_location_result) = lo_cut->allocate_plants_in_units(
      it_demands                   = VALUE #(
        ( request_id         = 'ALLOW-PLANT-BOX'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) )
      it_sources                   = VALUE #(
        ( request_id   = 'ALLOW-PLANT-BOX'
          source_plant = '2000' ) )
      it_allowed_storage_locations = VALUE #(
        ( '0001' )
        ( '0002' ) )
      it_storage_location_priority = VALUE #(
        ( '0002' )
        ( '0001' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '54.000' )
      act = ls_location_result-allocations[ 1 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_location_result-location_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_location_result-location_allocations[ 1 ]-allocation-storage_location ).

    DATA(ls_batch_result) = lo_cut->allocate_plants_batch_in_units(
      it_demands                   = VALUE #(
        ( request_id         = 'ALLOW-PLANT-BATCH-BOX'
          material           = 'MAT-1'
          target_plant       = '9000'
          batch              = 'B-1'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) )
      it_sources                   = VALUE #(
        ( request_id   = 'ALLOW-PLANT-BATCH-BOX'
          source_plant = '2000' ) )
      it_allowed_storage_locations = VALUE #(
        ( '0001' )
        ( '0002' ) )
      it_storage_location_priority = VALUE #(
        ( '0002' )
        ( '0001' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '54.000' )
      act = ls_batch_result-allocations[ 1 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_batch_result-location_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_batch_result-location_allocations[ 1 ]-allocation-storage_location ).

    DATA(ls_fefo_result) = lo_cut->allocate_plants_fefo_in_units(
      it_demands                   = VALUE #(
        ( request_id         = 'ALLOW-PLANT-FEFO-BOX'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) )
      it_sources                   = VALUE #(
        ( request_id   = 'ALLOW-PLANT-FEFO-BOX'
          source_plant = '2000' ) )
      it_allowed_storage_locations = VALUE #(
        ( '0001' )
        ( '0002' ) )
      it_storage_location_priority = VALUE #(
        ( '0002' )
        ( '0001' ) )
      iv_as_of_date                = '20260923' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '54.000' )
      act = ls_fefo_result-allocations[ 1 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_fefo_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_fefo_result-batch_allocations[ 1 ]-allocation-storage_location ).
  ENDMETHOD.

  METHOD scopes_cross_plant_locations.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_plant_location_stock(
      iv_material         = 'MAT-1'
      iv_plant            = '2000'
      iv_storage_location = '0001'
      iv_quantity         = '4.000' ).
    lo_repository->set_plant_location_stock(
      iv_material         = 'MAT-1'
      iv_plant            = '2000'
      iv_storage_location = '0002'
      iv_quantity         = '50.000' ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          expiration_date    = '20261001'
          available_quantity = '4.000' )
        ( storage_location   = '0002'
          batch              = 'B-1'
          expiration_date    = '20261001'
          available_quantity = '50.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA(lt_allowed_locations) = VALUE zcl_stock_service=>ty_storage_locations(
      ( '0001' )
      ( '0002' ) ).
    DATA(lt_location_priority) = VALUE zcl_stock_service=>ty_storage_locations(
      ( '0002' )
      ( '0001' ) ).

    DATA(ls_location_result) = lo_cut->allocate_across_plants(
      it_demands                   = VALUE #(
        ( request_id         = 'ORD-1'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '3.000' )
        ( request_id         = 'ORD-2'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '3.000' ) )
      it_sources                   = VALUE #(
        ( request_id = 'ORD-1' source_plant = '2000' )
        ( request_id = 'ORD-2' source_plant = '2000' ) )
      it_allowed_storage_locations = lt_allowed_locations
      it_storage_location_priority = lt_location_priority
      it_source_locations          = VALUE #(
        ( request_id = 'ORD-1' source_plant = '2000'
          storage_location = '0001' )
        ( request_id = 'ORD-2' source_plant = '2000'
          storage_location = '0002' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_location_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_location_result-location_allocations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '50.000' )
      act = ls_location_result-allocations[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_location_result-location_allocations[ 2 ]-storage_location ).

    DATA(ls_batch_result) = lo_cut->allocate_plants_by_batch(
      it_demands                   = VALUE #(
        ( request_id         = 'BATCH-1'
          material           = 'MAT-1'
          target_plant       = '9000'
          batch              = 'B-1'
          requested_quantity = '3.000' ) )
      it_sources                   = VALUE #(
        ( request_id = 'BATCH-1' source_plant = '2000' ) )
      it_allowed_storage_locations = lt_allowed_locations
      it_storage_location_priority = lt_location_priority
      it_source_locations          = VALUE #(
        ( request_id = 'BATCH-1' source_plant = '2000'
          storage_location = '0001' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_batch_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_batch_result-location_allocations[ 1 ]-storage_location ).

    DATA(ls_fefo_result) = lo_cut->allocate_plants_by_expiry(
      it_demands                   = VALUE #(
        ( request_id         = 'FEFO-1'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '3.000' ) )
      it_sources                   = VALUE #(
        ( request_id = 'FEFO-1' source_plant = '2000' ) )
      it_allowed_storage_locations = lt_allowed_locations
      it_storage_location_priority = lt_location_priority
      it_source_locations          = VALUE #(
        ( request_id = 'FEFO-1' source_plant = '2000'
          storage_location = '0001' ) )
      iv_as_of_date                = '20260923' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_fefo_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_fefo_result-batch_allocations[ 1 ]-storage_location ).

    DATA(ls_location_uom_result) = lo_cut->allocate_plants_in_units(
      it_demands                   = VALUE #(
        ( request_id         = 'ORD-BOX'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) )
      it_sources                   = VALUE #(
        ( request_id = 'ORD-BOX' source_plant = '2000' ) )
      it_allowed_storage_locations = lt_allowed_locations
      it_storage_location_priority = lt_location_priority
      it_source_locations          = VALUE #(
        ( request_id = 'ORD-BOX' source_plant = '2000'
          storage_location = '0001' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_location_uom_result-location_allocations[ 1 ]-allocation-storage_location ).

    DATA(ls_batch_uom_result) = lo_cut->allocate_plants_batch_in_units(
      it_demands                   = VALUE #(
        ( request_id         = 'BATCH-BOX'
          material           = 'MAT-1'
          target_plant       = '9000'
          batch              = 'B-1'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) )
      it_sources                   = VALUE #(
        ( request_id = 'BATCH-BOX' source_plant = '2000' ) )
      it_allowed_storage_locations = lt_allowed_locations
      it_storage_location_priority = lt_location_priority
      it_source_locations          = VALUE #(
        ( request_id = 'BATCH-BOX' source_plant = '2000'
          storage_location = '0001' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_batch_uom_result-location_allocations[ 1 ]-allocation-storage_location ).

    DATA(ls_fefo_uom_result) = lo_cut->allocate_plants_fefo_in_units(
      it_demands                   = VALUE #(
        ( request_id         = 'FEFO-BOX'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) )
      it_sources                   = VALUE #(
        ( request_id = 'FEFO-BOX' source_plant = '2000' ) )
      it_allowed_storage_locations = lt_allowed_locations
      it_storage_location_priority = lt_location_priority
      it_source_locations          = VALUE #(
        ( request_id = 'FEFO-BOX' source_plant = '2000'
          storage_location = '0001' ) )
      iv_as_of_date                = '20260923' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_fefo_uom_result-batch_allocations[ 1 ]-allocation-storage_location ).

    lo_repository->set_safety_stock( iv_quantity = '6.000' ).
    DATA(ls_scoped_safety_result) = lo_cut->allocate_across_plants(
      it_demands                   = VALUE #(
        ( request_id         = 'ORD-SAFE'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '1.000' ) )
      it_sources                   = VALUE #(
        ( request_id = 'ORD-SAFE' source_plant = '2000' ) )
      iv_protect_safety_stock      = abap_true
      it_allowed_storage_locations = lt_allowed_locations
      it_source_locations          = VALUE #(
        ( request_id = 'ORD-SAFE' source_plant = '2000'
          storage_location = '0002' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '48.000' )
      act = ls_scoped_safety_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_scoped_safety_result-location_allocations[ 1 ]-storage_location ).
  ENDMETHOD.

  METHOD rejects_bad_plant_loc_scopes.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->allocate_across_plants(
          it_demands          = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              requested_quantity = '1.000' ) )
          it_sources          = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000' ) )
          it_source_locations = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000'
              storage_location = '0001' )
            ( request_id = 'REQ-1' source_plant = '2000'
              storage_location = '0001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_unit_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    CLEAR lv_rejected.
    TRY.
        lo_unit_cut->allocate_plants_batch_in_units(
          it_demands          = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              batch              = 'B-1'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources          = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000' ) )
          it_source_locations = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000'
              storage_location = '0001' )
            ( request_id = 'REQ-1' source_plant = '2000'
              storage_location = '0001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD requires_full_plant_quantity.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_plant_location_stock(
      iv_material         = 'MAT-1'
      iv_plant            = '2000'
      iv_storage_location = '0001'
      iv_quantity         = '3.000' ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          expiration_date    = '20261231'
          available_quantity = '3.000' ) ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    DATA(ls_result) = lo_cut->allocate_across_plants(
      it_demands               = VALUE #(
        ( request_id         = 'REQ-SHORT'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '4.000' )
        ( request_id         = 'REQ-FULL'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '3.000' ) )
      it_sources               = VALUE #(
        ( request_id = 'REQ-SHORT' source_plant = '2000' )
        ( request_id = 'REQ-FULL' source_plant = '2000' ) )
      iv_require_full_quantity = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-plant_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-FULL'
      act = ls_result-plant_allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-location_allocations ) ).

    DATA(ls_row_result) = lo_cut->allocate_across_plants(
      it_demands = VALUE #(
        ( request_id            = 'REQ-ROW-SHORT'
          material              = 'MAT-1'
          target_plant          = '9000'
          requested_quantity    = '4.000'
          require_full_quantity = abap_true )
        ( request_id         = 'REQ-ROW-PARTIAL'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '3.000' ) )
      it_sources = VALUE #(
        ( request_id = 'REQ-ROW-SHORT' source_plant = '2000' )
        ( request_id = 'REQ-ROW-PARTIAL' source_plant = '2000' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_row_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_row_result-allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_row_result-allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-ROW-PARTIAL'
      act = ls_row_result-plant_allocations[ 1 ]-request_id ).

    DATA(ls_batch_result) = lo_cut->allocate_plants_by_batch(
      it_demands               = VALUE #(
        ( request_id         = 'REQ-BATCH'
          material           = 'MAT-1'
          target_plant       = '9000'
          batch              = 'B-1'
          requested_quantity = '4.000' ) )
      it_sources               = VALUE #(
        ( request_id = 'REQ-BATCH' source_plant = '2000' ) )
      iv_require_full_quantity = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_batch_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_batch_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_batch_result-allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_batch_result-plant_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_batch_result-location_allocations ) ).

    DATA(ls_batch_row_result) = lo_cut->allocate_plants_by_batch(
      it_demands = VALUE #(
        ( request_id            = 'REQ-BATCH-ROW-FULL'
          material              = 'MAT-1'
          target_plant          = '9000'
          batch                 = 'B-1'
          requested_quantity    = '4.000'
          require_full_quantity = abap_true )
        ( request_id         = 'REQ-BATCH-ROW-PARTIAL'
          material           = 'MAT-1'
          target_plant       = '9000'
          batch              = 'B-1'
          requested_quantity = '2.000' ) )
      it_sources = VALUE #(
        ( request_id = 'REQ-BATCH-ROW-FULL' source_plant = '2000' )
        ( request_id = 'REQ-BATCH-ROW-PARTIAL' source_plant = '2000' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_batch_row_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_batch_row_result-allocations[ 2 ]-allocated_quantity ).

    DATA(ls_fefo_result) = lo_cut->allocate_plants_by_expiry(
      it_demands    = VALUE #(
        ( request_id            = 'REQ-FEFO-SHORT'
          material              = 'MAT-1'
          target_plant          = '9000'
          requested_quantity    = '4.000'
          require_full_quantity = abap_true )
        ( request_id         = 'REQ-FEFO-PARTIAL'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '2.000' ) )
      it_sources    = VALUE #(
        ( request_id   = 'REQ-FEFO-SHORT' source_plant = '2000' )
        ( request_id   = 'REQ-FEFO-PARTIAL' source_plant = '2000' ) )
      iv_as_of_date = '20261001' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_fefo_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_fefo_result-allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_fefo_result-allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_fefo_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-FEFO-PARTIAL'
      act = ls_fefo_result-batch_allocations[ 1 ]-request_id ).
  ENDMETHOD.

  METHOD requires_full_plant_units.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_plant_location_stock(
      iv_material         = 'MAT-2'
      iv_plant            = '2000'
      iv_storage_location = '0001'
      iv_quantity         = '3.000' ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          expiration_date    = '20261231'
          available_quantity = '3.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).
    DATA(lv_rejected) = abap_false.
    DATA lv_bad_row_flags TYPE i.

    TRY.
        lo_cut->allocate_plants_atp(
          it_demands               = VALUE #(
            ( request_id         = 'REQ-INVALID'
              material           = 'MAT-2'
              target_plant       = '9000'
              requested_quantity = '2.000'
              requested_unit     = 'BOX' ) )
          it_sources               = VALUE #(
            ( request_id = 'REQ-INVALID' source_plant = '2000' ) )
          iv_check_rule            = 'A'
          iv_require_full_quantity = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lo_availability_api->get_requests( ) ) ).

    TRY.
        lo_cut->allocate_plants_in_units(
          it_demands = VALUE #(
            ( request_id            = 'REQ-BAD-ROW'
              material              = 'MAT-2'
              target_plant          = '9000'
              requested_quantity    = '1.000'
              requested_unit        = 'BOX'
              require_full_quantity = 'Y' ) )
          it_sources = VALUE #(
            ( request_id = 'REQ-BAD-ROW' source_plant = '2000' ) ) ).
      CATCH zcx_invalid_stock_request.
        ADD 1 TO lv_bad_row_flags.
    ENDTRY.
    TRY.
        lo_cut->allocate_plants_fefo_in_units(
          it_demands    = VALUE #(
            ( request_id            = 'REQ-BAD-FEFO-ROW'
              material              = 'MAT-2'
              target_plant          = '9000'
              requested_quantity    = '1.000'
              requested_unit        = 'BOX'
              require_full_quantity = 'Y' ) )
          it_sources    = VALUE #(
            ( request_id   = 'REQ-BAD-FEFO-ROW'
              source_plant = '2000' ) )
          iv_as_of_date = '20261001' ).
      CATCH zcx_invalid_stock_request.
        ADD 1 TO lv_bad_row_flags.
    ENDTRY.
    TRY.
        lo_cut->allocate_across_plants(
          it_demands = VALUE #(
            ( request_id            = 'REQ-BAD-BASE-ROW'
              material              = 'MAT-2'
              target_plant          = '9000'
              requested_quantity    = '1.000'
              require_full_quantity = 'Y' ) )
          it_sources = VALUE #(
            ( request_id   = 'REQ-BAD-BASE-ROW'
              source_plant = '2000' ) ) ).
      CATCH zcx_invalid_stock_request.
        ADD 1 TO lv_bad_row_flags.
    ENDTRY.
    TRY.
        lo_cut->allocate_plants_by_expiry(
          it_demands    = VALUE #(
            ( request_id            = 'REQ-BAD-FEFO-BASE-ROW'
              material              = 'MAT-2'
              target_plant          = '9000'
              requested_quantity    = '1.000'
              require_full_quantity = 'Y' ) )
          it_sources    = VALUE #(
            ( request_id   = 'REQ-BAD-FEFO-BASE-ROW'
              source_plant = '2000' ) )
          iv_as_of_date = '20261001' ).
      CATCH zcx_invalid_stock_request.
        ADD 1 TO lv_bad_row_flags.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lv_bad_row_flags ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).

    DATA(ls_atp_result) = lo_cut->allocate_plants_atp(
      it_demands               = VALUE #(
        ( request_id         = 'REQ-ATP'
          material           = 'MAT-2'
          target_plant       = '9000'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' ) )
      it_sources               = VALUE #(
        ( request_id = 'REQ-ATP' source_plant = '2000' ) )
      iv_check_rule            = 'A'
      iv_require_full_quantity = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_atp_result-local_estimate-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_atp_result-local_estimate-allocations[ 1 ]-allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_atp_result-local_estimate-location_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_atp_result-atp_checks ) ).

    DATA(ls_batch_result) = lo_cut->allocate_plants_batch_in_units(
      it_demands               = VALUE #(
        ( request_id         = 'REQ-BATCH-UOM'
          material           = 'MAT-2'
          target_plant       = '9000'
          batch              = 'B-1'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' ) )
      it_sources               = VALUE #(
        ( request_id = 'REQ-BATCH-UOM' source_plant = '2000' ) )
      iv_require_full_quantity = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_batch_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_batch_result-location_allocations ) ).

    DATA(ls_batch_row_unit_result) = lo_cut->allocate_plants_batch_in_units(
      it_demands = VALUE #(
        ( request_id            = 'REQ-BATCH-ROW-FULL-UOM'
          material              = 'MAT-2'
          target_plant          = '9000'
          batch                 = 'B-1'
          requested_quantity    = '2.000'
          requested_unit        = 'BOX'
          require_full_quantity = abap_true )
        ( request_id         = 'REQ-BATCH-ROW-PARTIAL-UOM'
          material           = 'MAT-2'
          target_plant       = '9000'
          batch              = 'B-1'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) )
      it_sources = VALUE #(
        ( request_id = 'REQ-BATCH-ROW-FULL-UOM' source_plant = '2000' )
        ( request_id = 'REQ-BATCH-ROW-PARTIAL-UOM' source_plant = '2000' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_batch_row_unit_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_batch_row_unit_result-allocations[ 2 ]-allocation-allocated_quantity ).

    DATA(ls_batch_atp_row_result) = lo_cut->allocate_plants_batch_atp(
      it_demands    = VALUE #(
        ( request_id            = 'REQ-BATCH-ATP-FULL-UOM'
          material              = 'MAT-2'
          target_plant          = '9000'
          batch                 = 'B-1'
          requested_quantity    = '2.000'
          requested_unit        = 'BOX'
          require_full_quantity = abap_true )
        ( request_id         = 'REQ-BATCH-ATP-PART-UOM'
          material           = 'MAT-2'
          target_plant       = '9000'
          batch              = 'B-1'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) )
      it_sources    = VALUE #(
        ( request_id = 'REQ-BATCH-ATP-FULL-UOM' source_plant = '2000' )
        ( request_id = 'REQ-BATCH-ATP-PART-UOM' source_plant = '2000' ) )
      iv_check_rule = 'A' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_batch_atp_row_result-local_estimate-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_batch_atp_row_result-local_estimate-allocations[ 2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_batch_atp_row_result-atp_checks ) ).

    DATA(ls_row_unit_result) = lo_cut->allocate_plants_in_units(
      it_demands = VALUE #(
        ( request_id            = 'REQ-UNIT-FULL'
          material              = 'MAT-2'
          target_plant          = '9000'
          requested_quantity    = '2.000'
          requested_unit        = 'BOX'
          require_full_quantity = abap_true )
        ( request_id         = 'REQ-UNIT-PARTIAL'
          material           = 'MAT-2'
          target_plant       = '9000'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) )
      it_sources = VALUE #(
        ( request_id = 'REQ-UNIT-FULL' source_plant = '2000' )
        ( request_id = 'REQ-UNIT-PARTIAL' source_plant = '2000' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_row_unit_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_row_unit_result-allocations[ 2 ]-allocation-allocated_quantity ).

    DATA(ls_fefo_result) = lo_cut->allocate_plants_fefo_in_units(
      it_demands    = VALUE #(
        ( request_id            = 'REQ-FEFO-FULL-UOM'
          material              = 'MAT-2'
          target_plant          = '9000'
          requested_quantity    = '2.000'
          requested_unit        = 'BOX'
          require_full_quantity = abap_true )
        ( request_id         = 'REQ-FEFO-PART-UOM'
          material           = 'MAT-2'
          target_plant       = '9000'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) )
      it_sources    = VALUE #(
        ( request_id   = 'REQ-FEFO-FULL-UOM' source_plant = '2000' )
        ( request_id   = 'REQ-FEFO-PART-UOM' source_plant = '2000' ) )
      iv_as_of_date = '20261001' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_fefo_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_fefo_result-allocations[ 2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_fefo_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-FEFO-PART-UOM'
      act = ls_fefo_result-batch_allocations[ 1 ]-allocation-request_id ).

    DATA(ls_atp_row_result) = lo_cut->allocate_plants_atp(
      it_demands    = VALUE #(
        ( request_id            = 'REQ-ATP-FULL-UOM'
          material              = 'MAT-2'
          target_plant          = '9000'
          requested_quantity    = '2.000'
          requested_unit        = 'BOX'
          require_full_quantity = abap_true )
        ( request_id         = 'REQ-ATP-PART-UOM'
          material           = 'MAT-2'
          target_plant       = '9000'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) )
      it_sources    = VALUE #(
        ( request_id = 'REQ-ATP-FULL-UOM' source_plant = '2000' )
        ( request_id = 'REQ-ATP-PART-UOM' source_plant = '2000' ) )
      iv_check_rule = 'A' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_atp_row_result-local_estimate-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_atp_row_result-local_estimate-allocations[ 2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_atp_row_result-atp_checks ) ).

    DATA(ls_fefo_atp_row_result) = lo_cut->allocate_plants_fefo_atp(
      it_demands    = VALUE #(
        ( request_id            = 'REQ-FEFO-ATP-FULL-UOM'
          material              = 'MAT-2'
          target_plant          = '9000'
          requested_quantity    = '2.000'
          requested_unit        = 'BOX'
          require_full_quantity = abap_true )
        ( request_id         = 'REQ-FEFO-ATP-PART-UOM'
          material           = 'MAT-2'
          target_plant       = '9000'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) )
      it_sources    = VALUE #(
        ( request_id = 'REQ-FEFO-ATP-FULL-UOM' source_plant = '2000' )
        ( request_id = 'REQ-FEFO-ATP-PART-UOM' source_plant = '2000' ) )
      iv_check_rule = 'A'
      iv_as_of_date = '20261001' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_fefo_atp_row_result-local_estimate-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_fefo_atp_row_result-local_estimate-allocations[ 2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_fefo_atp_row_result-atp_checks ) ).
  ENDMETHOD.

  METHOD requires_full_dated_plant.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_date_stock(
      iv_material = 'MAT-3'
      iv_plant    = '2000'
      iv_date     = '20261001'
      iv_quantity = '3.000' ).
    lo_repository->set_date_stock(
      iv_material = 'MAT-3'
      iv_plant    = '2000'
      iv_date     = '20261101'
      iv_quantity = '3.000' ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          expiration_date    = '20261231'
          available_quantity = '3.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).

    DATA(ls_date_result) = lo_cut->allocate_plants_by_date(
      it_demands               = VALUE #(
        ( request_id         = 'DATE-SHORT'
          material           = 'MAT-3'
          target_plant       = '9000'
          required_date      = '20261001'
          requested_quantity = '4.000' )
        ( request_id         = 'DATE-FULL'
          material           = 'MAT-3'
          target_plant       = '9000'
          required_date      = '20261101'
          requested_quantity = '3.000' ) )
      it_sources               = VALUE #(
        ( request_id = 'DATE-SHORT' source_plant = '2000' )
        ( request_id = 'DATE-FULL' source_plant = '2000' ) )
      iv_require_full_quantity = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_date_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_date_result-allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_date_result-allocations[ 2 ]-allocated_quantity ).

    DATA(ls_date_row_result) = lo_cut->allocate_plants_by_date(
      it_demands = VALUE #(
        ( request_id            = 'DATE-ROW-FULL'
          material              = 'MAT-3'
          target_plant          = '9000'
          required_date         = '20261001'
          requested_quantity    = '4.000'
          require_full_quantity = abap_true )
        ( request_id         = 'DATE-ROW-PARTIAL'
          material           = 'MAT-3'
          target_plant       = '9000'
          required_date      = '20261001'
          requested_quantity = '2.000' ) )
      it_sources = VALUE #(
        ( request_id = 'DATE-ROW-FULL' source_plant = '2000' )
        ( request_id = 'DATE-ROW-PARTIAL' source_plant = '2000' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_date_row_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_date_row_result-allocations[ 2 ]-allocated_quantity ).

    DATA(ls_date_unit_row_result) = lo_cut->allocate_plants_date_units(
      it_demands = VALUE #(
        ( request_id            = 'DATE-ROW-FULL-BOX'
          material              = 'MAT-3'
          target_plant          = '9000'
          required_date         = '20261001'
          requested_quantity    = '2.000'
          requested_unit        = 'BOX'
          require_full_quantity = abap_true )
        ( request_id         = 'DATE-ROW-PARTIAL-BOX'
          material           = 'MAT-3'
          target_plant       = '9000'
          required_date      = '20261001'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) )
      it_sources = VALUE #(
        ( request_id = 'DATE-ROW-FULL-BOX' source_plant = '2000' )
        ( request_id = 'DATE-ROW-PARTIAL-BOX' source_plant = '2000' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_date_unit_row_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_date_unit_row_result-allocations[ 2 ]-allocation-allocated_quantity ).

    DATA(ls_fefo_result) = lo_cut->allocate_plants_fefo_by_date(
      it_demands               = VALUE #(
        ( request_id         = 'FEFO-DATE'
          material           = 'MAT-3'
          target_plant       = '9000'
          required_date      = '20261001'
          requested_quantity = '4.000' ) )
      it_sources               = VALUE #(
        ( request_id = 'FEFO-DATE' source_plant = '2000' ) )
      iv_require_full_quantity = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_fefo_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_fefo_result-allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_fefo_result-batch_allocations ) ).

    DATA(ls_fefo_row_result) = lo_cut->allocate_plants_fefo_by_date(
      it_demands  = VALUE #(
        ( request_id            = 'FEFO-DATE-ROW-FULL'
          material              = 'MAT-3'
          target_plant          = '9000'
          required_date         = '20261001'
          requested_quantity    = '4.000'
          require_full_quantity = abap_true )
        ( request_id         = 'FEFO-DATE-ROW-PARTIAL'
          material           = 'MAT-3'
          target_plant       = '9000'
          required_date      = '20261001'
          requested_quantity = '2.000' ) )
      it_sources  = VALUE #(
        ( request_id = 'FEFO-DATE-ROW-FULL' source_plant = '2000' )
        ( request_id = 'FEFO-DATE-ROW-PARTIAL' source_plant = '2000' ) )
      iv_min_days = 0 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_fefo_row_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_fefo_row_result-allocations[ 2 ]-allocated_quantity ).

    DATA(ls_fefo_unit_row_result) = lo_cut->allocate_plants_fefo_date_uom(
      it_demands  = VALUE #(
        ( request_id            = 'FEFO-DATE-ROW-FULL-BOX'
          material              = 'MAT-3'
          target_plant          = '9000'
          required_date         = '20261001'
          requested_quantity    = '2.000'
          requested_unit        = 'BOX'
          require_full_quantity = abap_true )
        ( request_id         = 'FEFO-DATE-ROW-PARTIAL-BOX'
          material           = 'MAT-3'
          target_plant       = '9000'
          required_date      = '20261001'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) )
      it_sources  = VALUE #(
        ( request_id   = 'FEFO-DATE-ROW-FULL-BOX'
          source_plant = '2000' )
        ( request_id   = 'FEFO-DATE-ROW-PARTIAL-BOX'
          source_plant = '2000' ) )
      iv_min_days = 0 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_fefo_unit_row_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_fefo_unit_row_result-allocations[ 2 ]-allocation-allocated_quantity ).

    DATA(ls_date_batch_row_result) = lo_cut->allocate_plants_batch_by_date(
      it_demands = VALUE #(
        ( request_id            = 'DATE-BATCH-ROW-FULL'
          material              = 'MAT-3'
          target_plant          = '9000'
          required_date         = '20261001'
          batch                 = 'B-1'
          requested_quantity    = '4.000'
          require_full_quantity = abap_true )
        ( request_id         = 'DATE-BATCH-ROW-PARTIAL'
          material           = 'MAT-3'
          target_plant       = '9000'
          required_date      = '20261001'
          batch              = 'B-1'
          requested_quantity = '2.000' ) )
      it_sources = VALUE #(
        ( request_id = 'DATE-BATCH-ROW-FULL' source_plant = '2000' )
        ( request_id = 'DATE-BATCH-ROW-PARTIAL' source_plant = '2000' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_date_batch_row_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_date_batch_row_result-allocations[ 2 ]-allocated_quantity ).

    DATA(ls_date_batch_unit_row_result) = lo_cut->allocate_plants_date_batch_uom(
      it_demands = VALUE #(
        ( request_id            = 'DATE-BATCH-ROW-FULL-BOX'
          material              = 'MAT-3'
          target_plant          = '9000'
          required_date         = '20261001'
          batch                 = 'B-1'
          requested_quantity    = '2.000'
          requested_unit        = 'BOX'
          require_full_quantity = abap_true )
        ( request_id         = 'DATE-BATCH-ROW-PARTIAL-BOX'
          material           = 'MAT-3'
          target_plant       = '9000'
          required_date      = '20261001'
          batch              = 'B-1'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) )
      it_sources = VALUE #(
        ( request_id = 'DATE-BATCH-ROW-FULL-BOX' source_plant = '2000' )
        ( request_id   = 'DATE-BATCH-ROW-PARTIAL-BOX'
          source_plant = '2000' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_date_batch_unit_row_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_date_batch_unit_row_result-allocations[ 2 ]-allocation-allocated_quantity ).

    DATA(ls_date_batch_atp_row_result) = lo_cut->allocate_plants_date_batch_atp(
      it_demands    = VALUE #(
        ( request_id            = 'DATE-BATCH-ATP-FULL'
          material              = 'MAT-3'
          target_plant          = '9000'
          required_date         = '20261001'
          batch                 = 'B-1'
          requested_quantity    = '2.000'
          requested_unit        = 'BOX'
          require_full_quantity = abap_true )
        ( request_id         = 'DATE-BATCH-ATP-PARTIAL'
          material           = 'MAT-3'
          target_plant       = '9000'
          required_date      = '20261001'
          batch              = 'B-1'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) )
      it_sources    = VALUE #(
        ( request_id = 'DATE-BATCH-ATP-FULL' source_plant = '2000' )
        ( request_id = 'DATE-BATCH-ATP-PARTIAL' source_plant = '2000' ) )
      iv_check_rule = 'A' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_date_batch_atp_row_result-local_estimate-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_date_batch_atp_row_result-local_estimate-allocations[ 2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_date_batch_atp_row_result-atp_checks ) ).

    DATA(ls_atp_result) = lo_cut->allocate_plants_date_atp(
      it_demands               = VALUE #(
        ( request_id         = 'DATE-ATP'
          material           = 'MAT-3'
          target_plant       = '9000'
          required_date      = '20261001'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' ) )
      it_sources               = VALUE #(
        ( request_id = 'DATE-ATP' source_plant = '2000' ) )
      iv_check_rule            = 'A'
      iv_require_full_quantity = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_atp_result-local_estimate-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_atp_result-local_estimate-allocations[ 1 ]-allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_atp_result-atp_checks ) ).

    DATA(ls_date_atp_row_result) = lo_cut->allocate_plants_date_atp(
      it_demands    = VALUE #(
        ( request_id            = 'DATE-ATP-ROW-FULL'
          material              = 'MAT-3'
          target_plant          = '9000'
          required_date         = '20261001'
          requested_quantity    = '2.000'
          requested_unit        = 'BOX'
          require_full_quantity = abap_true )
        ( request_id         = 'DATE-ATP-ROW-PARTIAL'
          material           = 'MAT-3'
          target_plant       = '9000'
          required_date      = '20261001'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) )
      it_sources    = VALUE #(
        ( request_id = 'DATE-ATP-ROW-FULL' source_plant = '2000' )
        ( request_id = 'DATE-ATP-ROW-PARTIAL' source_plant = '2000' ) )
      iv_check_rule = 'A' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_date_atp_row_result-local_estimate-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_date_atp_row_result-local_estimate-allocations[ 2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_date_atp_row_result-atp_checks ) ).

    DATA(ls_fefo_date_atp_row_result) = lo_cut->allocate_plants_fefo_date_atp(
      it_demands    = VALUE #(
        ( request_id            = 'FEFO-DATE-ATP-FULL'
          material              = 'MAT-3'
          target_plant          = '9000'
          required_date         = '20261001'
          requested_quantity    = '2.000'
          requested_unit        = 'BOX'
          require_full_quantity = abap_true )
        ( request_id         = 'FEFO-DATE-ATP-PARTIAL'
          material           = 'MAT-3'
          target_plant       = '9000'
          required_date      = '20261001'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) )
      it_sources    = VALUE #(
        ( request_id = 'FEFO-DATE-ATP-FULL' source_plant = '2000' )
        ( request_id = 'FEFO-DATE-ATP-PARTIAL' source_plant = '2000' ) )
      iv_check_rule = 'A'
      iv_min_days   = 0 ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_fefo_date_atp_row_result-local_estimate-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_fefo_date_atp_row_result-local_estimate-allocations[ 2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_fefo_date_atp_row_result-atp_checks ) ).
  ENDMETHOD.

  METHOD allocates_plants_in_units.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_plant_location_stock(
      iv_material         = 'MAT-1'
      iv_plant            = '2000'
      iv_storage_location = '0001'
      iv_quantity         = '10.000' ).
    lo_repository->set_plant_location_stock(
      iv_material         = 'MAT-1'
      iv_plant            = '2000'
      iv_storage_location = '0002'
      iv_quantity         = '14.000' ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_result) = lo_cut->allocate_plants_in_units(
      it_demands = VALUE #(
        ( request_id         = 'REQ-1'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'REQ-2'
          material           = 'MAT-1'
          target_plant       = '9001'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) )
      it_sources = VALUE #(
        ( request_id = 'REQ-1' source_plant = '2000' )
        ( request_id = 'REQ-2' source_plant = '2000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = ls_result-allocations[ 1 ]-source_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-allocations[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '24.000' )
      act = ls_result-allocations[ 1 ]-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 2 ]-shortfall_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-plant_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-plant_allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-location_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.833' )
      act = ls_result-location_allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.167' )
      act = ls_result-location_allocations[ 2 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_unknown_plant_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_plants_in_units(
          it_demands = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD splits_allocations_by_location.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          available_quantity = '3.000' ) ) ).

    DATA(ls_result) = lo_cut->allocate_by_storage_location(
      it_demands = VALUE #(
        ( request_id         = 'SO-1/10'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '4.000' )
        ( request_id         = 'SO-2/10'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '3.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 2 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-storage_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-storage_allocations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-storage_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-storage_allocations[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-storage_allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SO-2/10'
      act = ls_result-storage_allocations[ 3 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-storage_allocations[ 3 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-storage_allocations[ 3 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_loc_priority.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          available_quantity = '3.000' )
        ( storage_location   = '0003'
          available_quantity = '4.000' ) ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    DATA(ls_result) = lo_cut->allocate_by_storage_location(
      it_demands                   = VALUE #(
        ( request_id                  = 'PREFERRED'
          material                    = 'MAT-1'
          plant                       = '1000'
          storage_location            = '0001'
          fallback_to_other_locations = abap_true
          requested_quantity          = '5.000' ) )
      it_storage_location_priority = VALUE #(
        ( '0003' )
        ( '0002' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '9.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-storage_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-storage_allocations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-storage_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = ls_result-storage_allocations[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-storage_allocations[ 2 ]-allocated_quantity ).
  ENDMETHOD.

  METHOD prioritizes_location_rows.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '10.000' )
        ( storage_location   = '0002'
          available_quantity = '15.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    lo_availability_api->set_result(
      is_result = VALUE #(
        available_at_plant_quantity = '25.000'
        confirmed_quantity          = '18.000'
        confirmation_lines          = VALUE #(
          ( confirmed_date = sy-datum confirmed_quantity = '18.000' ) )
        is_fully_available          = abap_false
        is_check_relevant           = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).
    DATA(lt_location_priority) = VALUE zcl_stock_service=>ty_storage_locations(
      ( '0002' )
      ( '0001' ) ).

    DATA(ls_result) = lo_cut->allocate_location_priority(
      it_demands                   = VALUE #(
        ( request_id         = 'REQ-REPEAT'
          material           = 'MAT-1'
          plant              = '1000'
          priority           = 0
          requested_quantity = '15.000' )
        ( request_id         = 'REQ-REPEAT'
          material           = 'MAT-1'
          plant              = '1000'
          priority           = 10
          requested_quantity = '15.000' ) )
      it_storage_location_priority = lt_location_priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-REPEAT'
      act = ls_result-allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_result-allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_result-allocations[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '15.000' )
      act = ls_result-allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-storage_allocations[ 1 ]-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_result-storage_allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-storage_allocations[ 2 ]-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_result-storage_allocations[ 2 ]-priority ).

    DATA(ls_uom_result) = lo_cut->allocate_location_uom_priority(
      it_demands                   = VALUE #(
        ( request_id         = 'REQ-UOM-REPEAT'
          material           = 'MAT-1'
          plant              = '1000'
          priority           = 0
          requested_quantity = '7.500'
          requested_unit     = 'BOX' )
        ( request_id         = 'REQ-UOM-REPEAT'
          material           = 'MAT-1'
          plant              = '1000'
          priority           = 10
          requested_quantity = '7.500'
          requested_unit     = 'BOX' ) )
      it_storage_location_priority = lt_location_priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_uom_result-allocations[ 1 ]-allocation-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_uom_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_uom_result-allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_uom_result-allocations[ 2 ]-allocation-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '15.000' )
      act = ls_uom_result-allocations[ 2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-UOM-REPEAT'
      act = ls_uom_result-storage_allocations[ 1 ]-storage_split-storage_allocation-request_id ).

    DATA lv_atp_check_date TYPE d.
    lv_atp_check_date = sy-datum + 5.
    DATA(ls_atp_result) = lo_cut->allocate_location_uom_atp_prio(
      it_demands                   = VALUE #(
        ( request_id         = 'REQ-LOW-ATP'
          material           = 'MAT-1'
          plant              = '1000'
          priority           = 0
          requested_quantity = '7.500'
          requested_unit     = 'BOX' )
        ( request_id         = 'REQ-HIGH-ATP'
          material           = 'MAT-1'
          plant              = '1000'
          priority           = 10
          requested_quantity = '7.500'
          requested_unit     = 'BOX' ) )
      iv_check_rule                = 'A'
      iv_atp_check_date            = lv_atp_check_date
      it_storage_location_priority = lt_location_priority ).
    DATA(lt_atp_requests) = lo_availability_api->get_requests( ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_atp_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '25.000' )
      act = ls_atp_result-atp_checks[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_atp_check_date
      act = ls_atp_result-atp_checks[ 1 ]-check_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_atp_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '25.000' )
      act = lt_atp_requests[ 1 ]-requested_quantity ).
  ENDMETHOD.

  METHOD allocates_allowed_locations.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          available_quantity = '100.000' )
        ( storage_location   = '0003'
          available_quantity = '4.000' )
        ( storage_location   = '0004'
          available_quantity = '5.000' ) ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    DATA(ls_result) = lo_cut->allocate_by_storage_location(
      it_demands                   = VALUE #(
        ( request_id                  = 'ALLOW-LOC'
          material                    = 'MAT-1'
          plant                       = '1000'
          storage_location            = '0001'
          fallback_to_other_locations = abap_true
          requested_quantity          = '7.000' ) )
      it_storage_location_priority = VALUE #(
        ( '0004' )
        ( '0003' ) )
      it_allowed_storage_locations = VALUE #(
        ( '0001' )
        ( '0003' )
        ( '0004' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '11.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-storage_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-storage_allocations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0004'
      act = ls_result-storage_allocations[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-storage_allocations[ 2 ]-allocated_quantity ).
  ENDMETHOD.

  METHOD rejects_bad_allowed_locations.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->allocate_by_storage_location(
          it_demands                   = VALUE #(
            ( material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000' ) )
          it_allowed_storage_locations = VALUE #(
            ( '0001' )
            ( '0001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->allocate_by_storage_location(
          it_demands                   = VALUE #(
            ( material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000' ) )
          it_allowed_storage_locations = VALUE #(
            ( space ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_unit_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    CLEAR lv_rejected.
    TRY.
        lo_unit_cut->allocate_by_location_in_units(
          it_demands                   = VALUE #(
            ( material                    = 'MAT-1'
              plant                       = '1000'
              storage_location            = '0001'
              fallback_to_other_locations = abap_true
              requested_quantity          = '1.000'
              requested_unit              = 'BOX' ) )
          it_allowed_storage_locations = VALUE #(
            ( '0002' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_batch_fefo_allowlist.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          expiration_date    = '20261001'
          available_quantity = '50.000' )
        ( storage_location   = '0002'
          batch              = 'B-1'
          expiration_date    = '20261002'
          available_quantity = '3.000' )
        ( storage_location   = '0003'
          batch              = 'B-1'
          expiration_date    = '20261003'
          available_quantity = '6.000' )
        ( storage_location   = '0001'
          batch              = 'B-2'
          expiration_date    = '20261001'
          available_quantity = '90.000' ) ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    DATA(ls_batch_result) = lo_cut->allocate_by_batch(
      it_demands                   = VALUE #(
        ( material           = 'MAT-1'
          plant              = '1000'
          batch              = 'B-1'
          requested_quantity = '7.000' ) )
      it_storage_location_priority = VALUE #(
        ( '0002' )
        ( '0003' ) )
      it_allowed_storage_locations = VALUE #(
        ( '0002' )
        ( '0003' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '9.000' )
      act = ls_batch_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_batch_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_batch_result-batch_allocations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = ls_batch_result-batch_allocations[ 2 ]-storage_location ).

    DATA(ls_fefo_result) = lo_cut->allocate_by_expiry(
      it_demands                   = VALUE #(
        ( material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '8.000' ) )
      it_allowed_storage_locations = VALUE #(
        ( '0002' )
        ( '0003' ) )
      iv_as_of_date                = '20260923' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '9.000' )
      act = ls_fefo_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_fefo_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_fefo_result-batch_allocations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = ls_fefo_result-batch_allocations[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_fefo_result-allocations[ 1 ]-allocated_quantity ).
  ENDMETHOD.

  METHOD rejects_bad_loc_priority.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->allocate_by_storage_location(
          it_demands                   = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000' ) )
          it_storage_location_priority = VALUE #(
            ( '0001' )
            ( '0001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->allocate_by_storage_location(
          it_demands                   = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000' ) )
          it_storage_location_priority = VALUE #(
            ( space ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->allocate_across_plants(
          it_demands                   = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              requested_quantity = '1.000' ) )
          it_sources                   = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000' ) )
          it_storage_location_priority = VALUE #(
            ( '0001' )
            ( '0001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_unit_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    CLEAR lv_rejected.
    TRY.
        lo_unit_cut->allocate_plants_in_units(
          it_demands                   = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources                   = VALUE #(
            ( request_id = 'REQ-1' source_plant = '2000' ) )
          it_storage_location_priority = VALUE #(
            ( '0001' )
            ( '0001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_loc_uom_priority.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '10.000' )
        ( storage_location   = '0002'
          available_quantity = '14.000' )
        ( storage_location   = '0003'
          available_quantity = '20.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_result) = lo_cut->allocate_by_location_in_units(
      it_demands                   = VALUE #(
        ( request_id                  = 'BOX-PRIORITY'
          material                    = 'MAT-1'
          plant                       = '1000'
          storage_location            = '0001'
          fallback_to_other_locations = abap_true
          requested_quantity          = '1.000'
          requested_unit              = 'BOX' ) )
      it_storage_location_priority = VALUE #(
        ( '0003' )
        ( '0002' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-storage_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-storage_allocations[ 1 ]-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_result-storage_allocations[ 1 ]-storage_allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = ls_result-storage_allocations[ 2 ]-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-storage_allocations[ 2 ]-storage_allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 1 ]-allocated_source_quantity ).
  ENDMETHOD.

  METHOD allocates_location_units.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '10.000' )
        ( storage_location   = '0002'
          available_quantity = '14.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_result) = lo_cut->allocate_by_location_in_units(
      it_demands = VALUE #(
        ( request_id                  = 'BOX-1'
          material                    = 'MAT-1'
          plant                       = '1000'
          storage_location            = '0001'
          fallback_to_other_locations = abap_true
          requested_quantity          = '1.000'
          requested_unit              = 'BOX' )
        ( request_id         = 'EA-2'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '12.000'
          requested_unit     = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX-1'
      act = ls_result-allocations[ 1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA-2'
      act = ls_result-allocations[ 2 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-allocations[ 2 ]-allocated_source_quantity ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-storage_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX-1'
      act = ls_result-storage_allocations[ 1 ]-storage_allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-storage_allocations[ 1 ]-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_result-storage_allocations[ 1 ]-storage_allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.833' )
      act = ls_result-storage_allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-storage_allocations[ 2 ]-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.167' )
      act = ls_result-storage_allocations[ 2 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA-2'
      act = ls_result-storage_allocations[ 3 ]-storage_allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-storage_allocations[ 3 ]-source_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-storage_allocations[ 3 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_only_requested_batch.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          available_quantity = '5.000' )
        ( storage_location   = '0001'
          batch              = 'B-2'
          available_quantity = '10.000' ) ) ).

    DATA(ls_result) = lo_cut->allocate_by_batch(
      it_demands = VALUE #(
        ( request_id         = 'SO-1/10'
          material           = 'MAT-1'
          plant              = '1000'
          batch              = 'B-1'
          requested_quantity = '6.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-batch_allocations[ 1 ]-batch ).
  ENDMETHOD.

  METHOD prioritizes_batch_demands.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          available_quantity = '25.000' )
        ( storage_location   = '0001'
          batch              = 'B-2'
          available_quantity = '99.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 10
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_base_result) = lo_cut->allocate_by_batch_priority(
      it_demands = VALUE #(
        ( request_id         = 'SHARED'
          material           = 'MAT-1'
          plant              = '1000'
          batch              = 'B-1'
          priority           = 1
          requested_quantity = '15.000' )
        ( request_id         = 'SHARED'
          material           = 'MAT-1'
          plant              = '1000'
          batch              = 'B-1'
          priority           = 9
          requested_quantity = '20.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_base_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_base_result-allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_base_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 9
      act = ls_base_result-allocations[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '20.000' )
      act = ls_base_result-allocations[ 2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SHARED'
      act = ls_base_result-allocations[ 1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_base_result-batch_allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_base_result-batch_allocations[ 1 ]-batch_allocation-allocated_quantity ).

    DATA(ls_uom_result) = lo_cut->allocate_by_batch_uom_priority(
      it_demands = VALUE #(
        ( request_id         = 'SHARED'
          material           = 'MAT-1'
          plant              = '1000'
          batch              = 'B-1'
          priority           = 1
          requested_quantity = '2.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'SHARED'
          material           = 'MAT-1'
          plant              = '1000'
          batch              = 'B-1'
          priority           = 9
          requested_quantity = '2.000'
          requested_unit     = 'BOX' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_uom_result-allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_uom_result-allocations[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = ls_uom_result-allocations[ 1 ]-allocation-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 9
      act = ls_uom_result-allocations[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '20.000' )
      act = ls_uom_result-allocations[ 2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_uom_result-allocations[ 2 ]-allocation-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_uom_result-batch_allocations[ 1 ]-priority ).

    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    lo_availability_api->set_result(
      is_result = VALUE #(
        available_at_plant_quantity = '25.000'
        confirmed_quantity          = '20.000'
        confirmation_lines          = VALUE #(
          ( confirmed_date     = '20261015'
            confirmed_quantity = '20.000' ) )
        is_fully_available          = abap_false
        is_check_relevant           = abap_true ) ).
    DATA(lo_atp_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).
    DATA(ls_atp_result) = lo_atp_cut->allocate_by_batch_uom_atp_prio(
      it_demands    = VALUE #(
        ( request_id         = 'SHARED'
          material           = 'MAT-1'
          plant              = '1000'
          batch              = 'B-1'
          priority           = 1
          requested_quantity = '2.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'SHARED'
          material           = 'MAT-1'
          plant              = '1000'
          batch              = 'B-1'
          priority           = 9
          requested_quantity = '2.000'
          requested_unit     = 'BOX' ) )
      iv_check_rule = 'A'
      iv_as_of_date = '20261015' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_atp_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '25.000' )
      act = ls_atp_result-atp_checks[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '20.000' )
      act = ls_atp_result-atp_checks[ 1 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_atp_result-atp_checks[ 1 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '25.000' )
      act = lo_availability_api->get_request( )-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_batch_receipts.
    DATA lv_early_date TYPE d.
    DATA lv_due_date TYPE d.
    DATA lv_future_date TYPE d.
    DATA lv_expiration_date TYPE d.
    lv_early_date = sy-datum + 3.
    lv_due_date = sy-datum + 5.
    lv_future_date = sy-datum + 6.
    lv_expiration_date = sy-datum + 50.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          expiration_date    = lv_expiration_date
          available_quantity = '1.000' ) ) ).
    lo_repository->set_safety_stock( iv_quantity = '2.000' ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    DATA(ls_result) = lo_cut->allocate_by_batch(
      it_demands                  = VALUE #(
        ( request_id         = 'LATER'
          material           = 'MAT-1'
          plant              = '1000'
          batch              = 'B-1'
          requested_quantity = '2.000'
          as_of_date         = lv_due_date )
        ( request_id         = 'EARLIER'
          material           = 'MAT-1'
          plant              = '1000'
          batch              = 'B-1'
          requested_quantity = '1.000'
          as_of_date         = lv_early_date ) )
      it_projected_batch_receipts = VALUE #(
        ( material         = 'MAT-1'
          plant            = '1000'
          storage_location = '0002'
          batch            = 'B-1'
          expiration_date  = lv_expiration_date
          receipt_date     = lv_due_date
          base_quantity    = '3.000' )
        ( material         = 'MAT-1'
          plant            = '1000'
          storage_location = '0002'
          batch            = 'B-1'
          expiration_date  = lv_expiration_date
          receipt_date     = lv_future_date
          base_quantity    = '9.000' ) )
      iv_protect_safety_stock     = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-allocations[ 2 ]-available_quantity ).
  ENDMETHOD.

  METHOD alloc_batch_rcpt_uom_atp.
    DATA lv_due_date TYPE d.
    DATA lv_future_date TYPE d.
    DATA lv_expiration_date TYPE d.
    lv_due_date = sy-datum + 5.
    lv_future_date = sy-datum + 6.
    lv_expiration_date = sy-datum + 50.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).
    DATA(lt_demands) = VALUE zcl_stock_service=>ty_unit_batch_demands(
      ( request_id         = 'BOX-1'
        material           = 'MAT-1'
        plant              = '1000'
        batch              = 'B-1'
        requested_quantity = '1.000'
        requested_unit     = 'BOX'
        as_of_date         = lv_due_date ) ).
    DATA(lt_receipts) = VALUE zcl_stock_service=>ty_dated_batch_receipts(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        batch            = 'B-1'
        expiration_date  = lv_expiration_date
        receipt_date     = lv_due_date
        base_quantity    = '4.000' )
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        batch            = 'B-1'
        expiration_date  = lv_expiration_date
        receipt_date     = lv_future_date
        base_quantity    = '9.000' ) ).

    DATA(ls_unit_result) = lo_cut->allocate_by_batch_in_units(
      it_demands                  = lt_demands
      it_projected_batch_receipts = lt_receipts ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_unit_result-allocations[ 1 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_unit_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_unit_result-batch_allocations[ 1 ]-allocated_source_quantity ).

    DATA(ls_atp_result) = lo_cut->allocate_by_batch_atp(
      it_demands                  = lt_demands
      it_projected_batch_receipts = lt_receipts
      iv_check_rule               = 'A'
      iv_as_of_date               = sy-datum ).
    DATA(lt_atp_requests) = lo_availability_api->get_requests( ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_atp_requests[ 1 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_due_date
      act = lt_atp_requests[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_atp_result-atp_checks ) ).
  ENDMETHOD.

  METHOD reject_batch_rcpt_pre_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_by_batch_in_units(
          it_demands                  = VALUE #(
            ( material           = 'MAT-1'
              plant              = '1000'
              batch              = 'B-1'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_projected_batch_receipts = VALUE #(
            ( material         = 'MAT-1'
              plant            = '1000'
              storage_location = '0001'
              batch            = 'B-1'
              expiration_date  = '20261215'
              receipt_date     = '20261301'
              base_quantity    = '1.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_fallback_flags.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_location_rejected TYPE abap_bool.
    DATA lv_location_unit_rejected TYPE abap_bool.
    DATA lv_batch_rejected TYPE abap_bool.
    DATA lv_batch_unit_rejected TYPE abap_bool.
    DATA lv_fefo_rejected TYPE abap_bool.
    DATA lv_fefo_unit_rejected TYPE abap_bool.

    TRY.
        lo_cut->allocate_by_storage_location(
          it_demands = VALUE #(
            ( request_id                  = 'LOC-1'
              material                    = 'MAT-1'
              plant                       = '1000'
              fallback_to_other_locations = 'Y'
              requested_quantity          = '1.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_location_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_by_location_in_units(
          it_demands = VALUE #(
            ( request_id                  = 'LOC-UOM-1'
              material                    = 'MAT-1'
              plant                       = '1000'
              fallback_to_other_locations = 'Y'
              requested_quantity          = '1.000'
              requested_unit              = 'BOX' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_location_unit_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_by_batch(
          it_demands = VALUE #(
            ( request_id                  = 'BATCH-1'
              material                    = 'MAT-1'
              plant                       = '1000'
              batch                       = 'B-1'
              fallback_to_other_locations = 'Y'
              requested_quantity          = '1.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_batch_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_by_batch_in_units(
          it_demands = VALUE #(
            ( request_id                  = 'BATCH-UOM-1'
              material                    = 'MAT-1'
              plant                       = '1000'
              batch                       = 'B-1'
              fallback_to_other_locations = 'Y'
              requested_quantity          = '1.000'
              requested_unit              = 'BOX' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_batch_unit_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_by_expiry(
          it_demands    = VALUE #(
            ( request_id                  = 'FEFO-1'
              material                    = 'MAT-1'
              plant                       = '1000'
              fallback_to_other_locations = 'Y'
              requested_quantity          = '1.000' ) )
          iv_as_of_date = '20261015' ).
      CATCH zcx_invalid_stock_request.
        lv_fefo_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_by_expiry_in_units(
          it_demands    = VALUE #(
            ( request_id                  = 'FEFO-UOM-1'
              material                    = 'MAT-1'
              plant                       = '1000'
              fallback_to_other_locations = 'Y'
              requested_quantity          = '1.000'
              requested_unit              = 'BOX' ) )
          iv_as_of_date = '20261015' ).
      CATCH zcx_invalid_stock_request.
        lv_fefo_unit_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_location_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_location_unit_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_batch_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_batch_unit_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_fefo_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_fefo_unit_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_protection_flags.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_location_rejected TYPE abap_bool.
    DATA lv_location_unit_rejected TYPE abap_bool.
    DATA lv_batch_rejected TYPE abap_bool.
    DATA lv_batch_unit_rejected TYPE abap_bool.
    DATA lv_fefo_rejected TYPE abap_bool.
    DATA lv_fefo_unit_rejected TYPE abap_bool.

    TRY.
        lo_cut->allocate_by_storage_location(
          it_demands              = VALUE #(
            ( request_id         = 'LOC-1'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000' ) )
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_location_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_by_location_in_units(
          it_demands              = VALUE #(
            ( request_id         = 'LOC-UOM-1'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_location_unit_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_by_batch(
          it_demands              = VALUE #(
            ( request_id         = 'BATCH-1'
              material           = 'MAT-1'
              plant              = '1000'
              batch              = 'B-1'
              requested_quantity = '1.000' ) )
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_batch_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_by_batch_in_units(
          it_demands              = VALUE #(
            ( request_id         = 'BATCH-UOM-1'
              material           = 'MAT-1'
              plant              = '1000'
              batch              = 'B-1'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_batch_unit_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_by_expiry(
          it_demands              = VALUE #(
            ( request_id         = 'FEFO-1'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000' ) )
          iv_as_of_date           = '20261015'
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_fefo_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_by_expiry_in_units(
          it_demands              = VALUE #(
            ( request_id         = 'FEFO-UOM-1'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          iv_as_of_date           = '20261015'
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_fefo_unit_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_location_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_location_unit_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_batch_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_batch_unit_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_fefo_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_fefo_unit_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_protection_inputs.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_request_rejected TYPE abap_bool.
    DATA lv_request_date_rejected TYPE abap_bool.
    DATA lv_demands_date_rejected TYPE abap_bool.
    DATA lv_date_units_rejected TYPE abap_bool.
    DATA lv_date_atp_rejected TYPE abap_bool.
    DATA lv_request_date_atp_rejected TYPE abap_bool.
    DATA lv_request_unit_rejected TYPE abap_bool.
    DATA lv_demands_units_rejected TYPE abap_bool.
    DATA lv_demands_rejected TYPE abap_bool.

    TRY.
        lo_cut->allocate_request(
          iv_material             = 'MAT-1'
          iv_plant                = '1000'
          iv_requested_quantity   = '1.000'
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_request_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_request_by_date(
          iv_material             = 'MAT-1'
          iv_plant                = '1000'
          iv_required_date        = '20261015'
          iv_requested_quantity   = '1.000'
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_request_date_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_demands_by_date(
          it_demands              = VALUE #( )
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_demands_date_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_date_demands_in_units(
          it_demands              = VALUE #( )
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_date_units_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_date_demands_atp(
          it_demands              = VALUE #( )
          iv_check_rule           = 'A'
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_date_atp_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_request_date_atp(
          iv_material             = 'MAT-1'
          iv_plant                = '1000'
          iv_unit                 = 'EA'
          iv_check_rule           = 'A'
          iv_required_date        = '20261015'
          iv_requested_quantity   = '1.000'
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_request_date_atp_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_request_in_unit(
          iv_material             = 'MAT-1'
          iv_plant                = '1000'
          iv_requested_quantity   = '1.000'
          iv_requested_unit       = 'BOX'
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_request_unit_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_demands_in_units(
          it_demands              = VALUE #( )
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_demands_units_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_demands(
          it_demands              = VALUE #( )
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_demands_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_request_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_request_date_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_demands_date_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_date_units_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_date_atp_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_request_date_atp_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_request_unit_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_demands_units_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_demands_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_plant_protection.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_plants_rejected TYPE abap_bool.
    DATA lv_date_rejected TYPE abap_bool.
    DATA lv_date_units_rejected TYPE abap_bool.
    DATA lv_date_atp_rejected TYPE abap_bool.
    DATA lv_fefo_rejected TYPE abap_bool.
    DATA lv_fefo_date_atp_rejected TYPE abap_bool.
    DATA lv_batch_rejected TYPE abap_bool.
    DATA lv_date_batch_atp_rejected TYPE abap_bool.
    DATA lv_batch_units_rejected TYPE abap_bool.
    DATA lv_units_rejected TYPE abap_bool.
    DATA lv_atp_rejected TYPE abap_bool.
    DATA lv_batch_atp_rejected TYPE abap_bool.
    DATA lv_fefo_atp_rejected TYPE abap_bool.
    DATA lv_fefo_units_rejected TYPE abap_bool.

    TRY.
        lo_cut->allocate_across_plants(
          it_demands              = VALUE #( )
          it_sources              = VALUE #( )
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_plants_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_plants_by_date(
          it_demands              = VALUE #( )
          it_sources              = VALUE #( )
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_date_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_plants_date_units(
          it_demands              = VALUE #(
            ( request_id         = 'DATE-UOM-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              required_date      = '20261015'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources              = VALUE #( )
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_date_units_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_plants_date_atp(
          it_demands              = VALUE #( )
          it_sources              = VALUE #( )
          iv_check_rule           = 'A'
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_date_atp_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_plants_by_expiry(
          it_demands              = VALUE #( )
          it_sources              = VALUE #( )
          iv_as_of_date           = '20261015'
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_fefo_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_plants_fefo_date_atp(
          it_demands              = VALUE #( )
          it_sources              = VALUE #( )
          iv_check_rule           = 'A'
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_fefo_date_atp_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_plants_by_batch(
          it_demands              = VALUE #( )
          it_sources              = VALUE #( )
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_batch_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_plants_date_batch_atp(
          it_demands              = VALUE #( )
          it_sources              = VALUE #( )
          iv_check_rule           = 'A'
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_date_batch_atp_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_plants_batch_in_units(
          it_demands              = VALUE #(
            ( request_id         = 'BATCH-UOM-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              batch              = 'B-1'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources              = VALUE #( )
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_batch_units_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_plants_in_units(
          it_demands              = VALUE #(
            ( request_id         = 'PLANT-UOM-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources              = VALUE #( )
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_units_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_plants_atp(
          it_demands              = VALUE #( )
          it_sources              = VALUE #( )
          iv_check_rule           = 'A'
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_atp_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_plants_batch_atp(
          it_demands              = VALUE #( )
          it_sources              = VALUE #( )
          iv_check_rule           = 'A'
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_batch_atp_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_plants_fefo_atp(
          it_demands              = VALUE #( )
          it_sources              = VALUE #( )
          iv_check_rule           = 'A'
          iv_as_of_date           = '20261015'
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_fefo_atp_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_plants_fefo_in_units(
          it_demands              = VALUE #(
            ( request_id         = 'PLANT-FEFO-UOM-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources              = VALUE #( )
          iv_as_of_date           = '20261015'
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_fefo_units_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_plants_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_date_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_date_units_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_date_atp_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_fefo_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_fefo_date_atp_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_batch_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_date_batch_atp_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_batch_units_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_units_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_atp_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_batch_atp_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_fefo_atp_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_fefo_units_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_date_receipt_flags.
    TYPES:
      BEGIN OF ty_receipt_flags,
        include_po_receipts         TYPE abap_bool,
        include_po_confirmations    TYPE abap_bool,
        include_sto_in_transit      TYPE abap_bool,
        include_unissued_sto        TYPE abap_bool,
        subtract_unissued_sto       TYPE abap_bool,
        include_prod_receipts       TYPE abap_bool,
        include_pr_receipts         TYPE abap_bool,
        include_sto_pr_receipts     TYPE abap_bool,
        include_planned_receipts    TYPE abap_bool,
        include_fixed_planned       TYPE abap_bool,
        include_sched_agmt_receipts TYPE abap_bool,
      END OF ty_receipt_flags.
    TYPES ty_flag_name TYPE c LENGTH 40.
    TYPES ty_flag_names TYPE STANDARD TABLE OF ty_flag_name
      WITH EMPTY KEY.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lt_flag_names TYPE ty_flag_names.
    DATA ls_flags TYPE ty_receipt_flags.
    DATA lv_single_rejections TYPE i.
    DATA lv_entrypoint_rejections TYPE i.
    FIELD-SYMBOLS <lv_flag> TYPE abap_bool.

    lt_flag_names = VALUE #(
      ( 'INCLUDE_PO_RECEIPTS' )
      ( 'INCLUDE_PO_CONFIRMATIONS' )
      ( 'INCLUDE_STO_IN_TRANSIT' )
      ( 'INCLUDE_UNISSUED_STO' )
      ( 'SUBTRACT_UNISSUED_STO' )
      ( 'INCLUDE_PROD_RECEIPTS' )
      ( 'INCLUDE_PR_RECEIPTS' )
      ( 'INCLUDE_STO_PR_RECEIPTS' )
      ( 'INCLUDE_PLANNED_RECEIPTS' )
      ( 'INCLUDE_FIXED_PLANNED' )
      ( 'INCLUDE_SCHED_AGMT_RECEIPTS' ) ).

    LOOP AT lt_flag_names INTO DATA(lv_flag_name).
      ls_flags = VALUE #(
        include_po_receipts         = abap_false
        include_po_confirmations    = abap_false
        include_sto_in_transit      = abap_false
        include_unissued_sto        = abap_false
        subtract_unissued_sto       = abap_false
        include_prod_receipts       = abap_false
        include_pr_receipts         = abap_false
        include_sto_pr_receipts     = abap_false
        include_planned_receipts    = abap_false
        include_fixed_planned       = abap_false
        include_sched_agmt_receipts = abap_false ).
      ASSIGN COMPONENT lv_flag_name OF STRUCTURE ls_flags TO <lv_flag>.
      cl_abap_unit_assert=>assert_equals(
        exp = 0
        act = sy-subrc ).
      <lv_flag> = 'Y'.

      TRY.
          lo_cut->allocate_request_by_date(
            iv_material                    = 'MAT-1'
            iv_plant                       = '1000'
            iv_required_date               = '20261015'
            iv_requested_quantity          = '1.000'
            iv_include_po_receipts         =
              ls_flags-include_po_receipts
            iv_include_po_confirmations    =
              ls_flags-include_po_confirmations
            iv_include_sto_in_transit      =
              ls_flags-include_sto_in_transit
            iv_include_unissued_sto        =
              ls_flags-include_unissued_sto
            iv_subtract_unissued_sto       =
              ls_flags-subtract_unissued_sto
            iv_include_prod_receipts       =
              ls_flags-include_prod_receipts
            iv_include_pr_receipts         =
              ls_flags-include_pr_receipts
            iv_include_sto_pr_receipts     =
              ls_flags-include_sto_pr_receipts
            iv_include_planned_receipts    =
              ls_flags-include_planned_receipts
            iv_include_fixed_planned       =
              ls_flags-include_fixed_planned
            iv_include_sched_agmt_receipts =
              ls_flags-include_sched_agmt_receipts ).
        CATCH zcx_invalid_stock_request.
          ADD 1 TO lv_single_rejections.
      ENDTRY.
    ENDLOOP.

    ls_flags-include_po_receipts = abap_true.
    ls_flags-include_po_confirmations = abap_true.
    TRY.
        lo_cut->allocate_request_by_date(
          iv_material                 = 'MAT-1'
          iv_plant                    = '1000'
          iv_required_date            = '20261015'
          iv_requested_quantity       = '1.000'
          iv_include_po_receipts      = ls_flags-include_po_receipts
          iv_include_po_confirmations =
            ls_flags-include_po_confirmations ).
      CATCH zcx_invalid_stock_request.
        ADD 1 TO lv_single_rejections.
    ENDTRY.

    TRY.
        lo_cut->allocate_demands_by_date(
          it_demands              = VALUE #( )
          iv_include_unissued_sto = 'Y' ).
      CATCH zcx_invalid_stock_request.
        ADD 1 TO lv_entrypoint_rejections.
    ENDTRY.
    TRY.
        lo_cut->allocate_date_demands_in_units(
          it_demands               = VALUE #(
            ( request_id         = 'DATE-UOM-1'
              material           = 'MAT-1'
              plant              = '1000'
              required_date      = '20261015'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          iv_subtract_unissued_sto = 'Y' ).
      CATCH zcx_invalid_stock_request.
        ADD 1 TO lv_entrypoint_rejections.
    ENDTRY.
    TRY.
        lo_cut->allocate_date_demands_atp(
          it_demands               = VALUE #( )
          iv_check_rule            = 'A'
          iv_include_prod_receipts = 'Y' ).
      CATCH zcx_invalid_stock_request.
        ADD 1 TO lv_entrypoint_rejections.
    ENDTRY.
    TRY.
        lo_cut->allocate_request_date_atp(
          iv_material            = 'MAT-1'
          iv_plant               = '1000'
          iv_unit                = 'EA'
          iv_check_rule          = 'A'
          iv_required_date       = '20261015'
          iv_requested_quantity  = '1.000'
          iv_include_pr_receipts = 'Y' ).
      CATCH zcx_invalid_stock_request.
        ADD 1 TO lv_entrypoint_rejections.
    ENDTRY.
    TRY.
        lo_cut->allocate_plants_by_date(
          it_demands                 = VALUE #( )
          it_sources                 = VALUE #( )
          iv_include_sto_pr_receipts = 'Y' ).
      CATCH zcx_invalid_stock_request.
        ADD 1 TO lv_entrypoint_rejections.
    ENDTRY.
    TRY.
        lo_cut->allocate_plants_date_units(
          it_demands                  = VALUE #(
            ( request_id         = 'PLANT-DATE-UOM-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              required_date      = '20261015'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_sources                  = VALUE #( )
          iv_include_planned_receipts = 'Y' ).
      CATCH zcx_invalid_stock_request.
        ADD 1 TO lv_entrypoint_rejections.
    ENDTRY.
    TRY.
        lo_cut->allocate_plants_date_atp(
          it_demands               = VALUE #( )
          it_sources               = VALUE #( )
          iv_check_rule            = 'A'
          iv_include_fixed_planned = 'Y' ).
      CATCH zcx_invalid_stock_request.
        ADD 1 TO lv_entrypoint_rejections.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = 12
      act = lv_single_rejections ).
    cl_abap_unit_assert=>assert_equals(
      exp = 7
      act = lv_entrypoint_rejections ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_full_qty_flags.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_unit_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_request_rejected TYPE abap_bool.
    DATA lv_date_batch_atp_rejected TYPE abap_bool.
    DATA lv_fefo_rejections TYPE i.

    TRY.
        lo_cut->allocate_request(
          iv_material              = 'MAT-1'
          iv_plant                 = '1000'
          iv_requested_quantity    = '1.000'
          iv_require_full_quantity = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_request_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_plants_date_batch_atp(
          it_demands               = VALUE #( )
          it_sources               = VALUE #( )
          iv_check_rule            = 'A'
          iv_require_full_quantity = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_date_batch_atp_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_by_expiry(
          it_demands    = VALUE #(
            ( material              = 'MAT-1'
              plant                 = '1000'
              requested_quantity    = '1.000'
              require_full_quantity = 'Y' ) )
          iv_as_of_date = '20261001' ).
      CATCH zcx_invalid_stock_request.
        ADD 1 TO lv_fefo_rejections.
    ENDTRY.
    TRY.
        lo_unit_cut->allocate_by_expiry_in_units(
          it_demands    = VALUE #(
            ( material              = 'MAT-1'
              plant                 = '1000'
              requested_quantity    = '1.000'
              requested_unit        = 'BOX'
              require_full_quantity = 'Y' ) )
          iv_as_of_date = '20261001' ).
      CATCH zcx_invalid_stock_request.
        ADD 1 TO lv_fefo_rejections.
    ENDTRY.
    TRY.
        lo_cut->allocate_quality_by_expiry(
          it_demands    = VALUE #(
            ( material              = 'MAT-1'
              plant                 = '1000'
              requested_quantity    = '1.000'
              require_full_quantity = 'Y' ) )
          iv_as_of_date = '20261001' ).
      CATCH zcx_invalid_stock_request.
        ADD 1 TO lv_fefo_rejections.
    ENDTRY.
    TRY.
        lo_unit_cut->allocate_quality_by_expiry_uom(
          it_demands    = VALUE #(
            ( material              = 'MAT-1'
              plant                 = '1000'
              requested_quantity    = '1.000'
              requested_unit        = 'BOX'
              require_full_quantity = 'Y' ) )
          iv_as_of_date = '20261001' ).
      CATCH zcx_invalid_stock_request.
        ADD 1 TO lv_fefo_rejections.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_request_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_date_batch_atp_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lv_fefo_rejections ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_batch_units.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          available_quantity = '10.000' )
        ( storage_location   = '0002'
          batch              = 'B-1'
          available_quantity = '14.000' )
        ( storage_location   = '0002'
          batch              = 'B-2'
          available_quantity = '99.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_result) = lo_cut->allocate_by_batch_in_units(
      it_demands = VALUE #(
        ( request_id                  = 'BOX-1'
          material                    = 'MAT-1'
          plant                       = '1000'
          batch                       = 'B-1'
          storage_location            = '0001'
          fallback_to_other_locations = abap_true
          requested_quantity          = '1.000'
          requested_unit              = 'BOX' )
        ( request_id         = 'EA-2'
          material           = 'MAT-1'
          plant              = '1000'
          batch              = 'B-1'
          requested_quantity = '12.000'
          requested_unit     = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX-1'
      act = ls_result-allocations[ 1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA-2'
      act = ls_result-allocations[ 2 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-allocations[ 2 ]-allocated_source_quantity ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX-1'
      act = ls_result-batch_allocations[ 1 ]-batch_allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-batch_allocations[ 1 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_result-batch_allocations[ 1 ]-batch_allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.833' )
      act = ls_result-batch_allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-batch_allocations[ 2 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.167' )
      act = ls_result-batch_allocations[ 2 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA-2'
      act = ls_result-batch_allocations[ 3 ]-batch_allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-batch_allocations[ 3 ]-source_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-batch_allocations[ 3 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).

  ENDMETHOD.

  METHOD splits_requested_batch.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          batch              = 'B-1'
          available_quantity = '3.000' ) ) ).

    DATA(ls_result) = lo_cut->allocate_by_batch(
      it_demands = VALUE #(
        ( request_id         = 'SO-1/10'
          material           = 'MAT-1'
          plant              = '1000'
          batch              = 'B-1'
          requested_quantity = '4.000' )
        ( request_id         = 'SO-2/10'
          material           = 'MAT-1'
          plant              = '1000'
          batch              = 'B-1'
          requested_quantity = '3.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-batch_allocations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-batch_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SO-2/10'
      act = ls_result-batch_allocations[ 3 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 2 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD prefers_batch_location_first.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          available_quantity = '1.500' )
        ( storage_location   = '0002'
          batch              = 'B-1'
          available_quantity = '2.500' )
        ( storage_location   = '0002'
          batch              = 'B-2'
          available_quantity = '9.000' ) ) ).

    DATA(ls_result) = lo_cut->allocate_by_batch(
      it_demands = VALUE #(
        ( material                    = 'MAT-1'
          plant                       = '1000'
          batch                       = 'B-1'
          storage_location            = '0002'
          fallback_to_other_locations = abap_true
          requested_quantity          = '3.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-batch_allocations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '2.500' )
      act = ls_result-batch_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-batch_allocations[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '0.500' )
      act = ls_result-batch_allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-batch_allocations[ 2 ]-batch ).
  ENDMETHOD.

  METHOD allocates_batch_location_order.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          batch              = 'B-1'
          available_quantity = '3.000' )
        ( storage_location   = '0003'
          batch              = 'B-1'
          available_quantity = '4.000' )
        ( storage_location   = '0001'
          batch              = 'B-2'
          available_quantity = '99.000' ) ) ).

    DATA(ls_result) = lo_cut->allocate_by_batch(
      it_demands                   = VALUE #(
        ( request_id                  = 'BATCH-PRIORITY'
          material                    = 'MAT-1'
          plant                       = '1000'
          batch                       = 'B-1'
          storage_location            = '0002'
          fallback_to_other_locations = abap_true
          requested_quantity          = '5.000' ) )
      it_storage_location_priority = VALUE #(
        ( '0003' )
        ( '0001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '9.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-batch_allocations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '3.000' )
      act = ls_result-batch_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = ls_result-batch_allocations[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '2.000' )
      act = ls_result-batch_allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-batch_allocations[ 2 ]-batch ).
  ENDMETHOD.

  METHOD rejects_missing_batch.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_by_batch(
          it_demands = VALUE #(
            ( material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_by_expiry_date.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-EXPIRED'
          expiration_date    = '20260920'
          available_quantity = '3.000' )
        ( storage_location   = '0001'
          batch              = 'B-LATER'
          expiration_date    = '20261010'
          available_quantity = '4.000' )
        ( storage_location   = '0002'
          batch              = 'B-SOON'
          expiration_date    = '20260930'
          available_quantity = '5.000' )
        ( storage_location   = '0002'
          batch              = 'B-NODATE'
          available_quantity = '2.000' ) ) ).

    DATA(ls_result) = lo_cut->allocate_by_expiry(
      it_demands    = VALUE #(
        ( request_id         = 'SO-1/10'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '6.000' )
        ( request_id         = 'SO-2/10'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '4.000' ) )
      iv_as_of_date = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '11.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-allocations[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-SOON'
      act = ls_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '5.000' )
      act = ls_result-batch_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20260930'
      act = ls_result-batch_allocations[ 1 ]-expiration_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_result-batch_allocations[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-NODATE'
      act = ls_result-batch_allocations[ 4 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_single_fefo_receipts.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    DATA(ls_result) = lo_cut->allocate_by_expiry(
      it_demands                  = VALUE #(
        ( request_id         = 'LATER'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          fefo_as_of_date    = '20261020' )
        ( request_id         = 'EARLIER'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          fefo_as_of_date    = '20261010' ) )
      it_projected_batch_receipts = VALUE #(
        ( material         = 'MAT-1'
          plant            = '1000'
          storage_location = '0001'
          batch            = 'B-DUE'
          expiration_date  = '20261215'
          receipt_date     = '20261020'
          base_quantity    = '5.000' )
        ( material         = 'MAT-1'
          plant            = '1000'
          storage_location = '0001'
          batch            = 'B-FUTURE'
          expiration_date  = '20261231'
          receipt_date     = '20261021'
          base_quantity    = '9.000' ) )
      iv_as_of_date               = '20261001' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-DUE'
      act = ls_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-allocations[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 2 ]-shortfall_quantity ).
  ENDMETHOD.

  METHOD allocates_fefo_row_full_qty.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          expiration_date    = '20261231'
          available_quantity = '5.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_base_result) = lo_cut->allocate_by_expiry(
      it_demands    = VALUE #(
        ( request_id            = 'FULL'
          material              = 'MAT-1'
          plant                 = '1000'
          requested_quantity    = '6.000'
          require_full_quantity = abap_true )
        ( request_id         = 'PARTIAL'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '3.000' ) )
      iv_as_of_date = '20261001' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_base_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_base_result-allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_base_result-allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_base_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PARTIAL'
      act = ls_base_result-batch_allocations[ 1 ]-request_id ).

    DATA(ls_unit_result) = lo_cut->allocate_by_expiry_in_units(
      it_demands    = VALUE #(
        ( request_id            = 'FULL-BOX'
          material              = 'MAT-1'
          plant                 = '1000'
          requested_quantity    = '3.000'
          requested_unit        = 'BOX'
          require_full_quantity = abap_true )
        ( request_id         = 'PARTIAL-BOX'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) )
      iv_as_of_date = '20261001' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_unit_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_unit_result-allocations[ 1 ]-shortfall_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_unit_result-allocations[ 2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PARTIAL-BOX'
      act = ls_unit_result-batch_allocations[ 1 ]-batch_allocation-request_id ).
  ENDMETHOD.

  METHOD protects_due_fefo_buffer.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-CURRENT'
          expiration_date    = '20261231'
          available_quantity = '1.000' ) ) ).
    lo_repository->set_safety_stock( iv_quantity = '2.000' ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    DATA(ls_result) = lo_cut->allocate_by_expiry(
      it_demands                  = VALUE #(
        ( request_id         = 'DUE'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '2.000'
          fefo_as_of_date    = '20261020' ) )
      it_projected_batch_receipts = VALUE #(
        ( material         = 'MAT-1'
          plant            = '1000'
          storage_location = '0002'
          batch            = 'B-RECEIPT'
          expiration_date  = '20261215'
          receipt_date     = '20261020'
          base_quantity    = '3.000' ) )
      iv_as_of_date               = '20261001'
      iv_protect_safety_stock     = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-RECEIPT'
      act = ls_result-batch_allocations[ 1 ]-batch ).
  ENDMETHOD.

  METHOD alloc_single_fefo_rcpt_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).
    DATA(lt_demands) = VALUE zcl_stock_service=>ty_unit_fefo_demands(
      ( request_id         = 'BOX-1'
        material           = 'MAT-1'
        plant              = '1000'
        requested_quantity = '1.000'
        requested_unit     = 'BOX'
        fefo_as_of_date    = '20261020' ) ).
    DATA(lt_receipts) = VALUE zcl_stock_service=>ty_dated_batch_receipts(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        batch            = 'B-DUE'
        expiration_date  = '20261215'
        receipt_date     = '20261020'
        base_quantity    = '4.000' )
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        batch            = 'B-FUTURE'
        expiration_date  = '20261231'
        receipt_date     = '20261021'
        base_quantity    = '9.000' ) ).

    DATA(ls_unit_result) = lo_cut->allocate_by_expiry_in_units(
      it_demands                  = lt_demands
      it_projected_batch_receipts = lt_receipts
      iv_as_of_date               = '20261001' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_unit_result-allocations[ 1 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_unit_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = ls_unit_result-batch_allocations[ 1 ]-source_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_unit_result-batch_allocations[ 1 ]-allocated_source_quantity ).

    DATA(ls_atp_result) = lo_cut->allocate_by_expiry_atp(
      it_demands                  = lt_demands
      it_projected_batch_receipts = lt_receipts
      iv_check_rule               = 'A'
      iv_as_of_date               = '20261001' ).
    DATA(lt_atp_requests) = lo_availability_api->get_requests( ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_atp_result-local_estimate-allocations[
        1 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_atp_requests[ 1 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261020'
      act = lt_atp_requests[ 1 ]-required_date ).
  ENDMETHOD.

  METHOD reject_single_fefo_pre_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_by_expiry_in_units(
          it_demands                  = VALUE #(
            ( material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_projected_batch_receipts = VALUE #(
            ( material         = 'MAT-1'
              plant            = '1000'
              storage_location = '0001'
              batch            = 'B-BAD'
              expiration_date  = '20261215'
              receipt_date     = '20261301'
              base_quantity    = '1.000' ) )
          iv_as_of_date               = '20261001' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_fefo_exact_batch.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-SOON'
          expiration_date    = '20261001'
          available_quantity = '5.000' )
        ( storage_location   = '0002'
          batch              = 'B-LATER'
          expiration_date    = '20261010'
          available_quantity = '7.000' ) ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    DATA(ls_result) = lo_cut->allocate_by_expiry(
      it_demands    = VALUE #(
        ( request_id         = 'SO-BATCH'
          material           = 'MAT-1'
          plant              = '1000'
          batch              = 'B-LATER'
          requested_quantity = '4.000' ) )
      iv_as_of_date = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-batch_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-batch_allocations ) ).
  ENDMETHOD.

  METHOD allocates_quality_by_expiry.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stock_status(
      it_status = VALUE #(
        ( storage_location            = '0001'
          batch                       = 'B-LATER'
          expiration_date             = '20261010'
          unrestricted_quantity       = '50.000'
          available_quantity          = '40.000'
          quality_inspection_quantity = '4.000' )
        ( storage_location            = '0002'
          batch                       = 'B-SOON'
          expiration_date             = '20260930'
          quality_inspection_quantity = '3.000' )
        ( storage_location            = '0001'
          batch                       = 'B-EXPIRED'
          expiration_date             = '20260920'
          quality_inspection_quantity = '100.000' )
        ( storage_location            = '0002'
          batch                       = 'B-UNDATED'
          quality_inspection_quantity = '2.000' ) ) ).

    DATA(ls_result) = lo_cut->allocate_quality_by_expiry(
      it_demands    = VALUE #(
        ( request_id                  = 'QI-1'
          material                    = 'MAT-1'
          plant                       = '1000'
          fallback_to_other_locations = abap_false
          requested_quantity          = '5.000' )
        ( request_id                  = 'QI-2'
          material                    = 'MAT-1'
          plant                       = '1000'
          fallback_to_other_locations = abap_false
          requested_quantity          = '5.000' ) )
      iv_as_of_date = '20260923'
      iv_min_days   = 5 ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 2 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-SOON'
      act = ls_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-batch_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_result-batch_allocations[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_result-batch_allocations[ 3 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD alloc_quality_fefo_row_full.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stock_status(
      it_status = VALUE #(
        ( storage_location            = '0001'
          batch                       = 'B-QI'
          expiration_date             = '20261231'
          quality_inspection_quantity = '5.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_base_result) = lo_cut->allocate_quality_by_expiry(
      it_demands    = VALUE #(
        ( request_id            = 'QI-FULL'
          material              = 'MAT-1'
          plant                 = '1000'
          requested_quantity    = '6.000'
          require_full_quantity = abap_true )
        ( request_id         = 'QI-PARTIAL'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '3.000' ) )
      iv_as_of_date = '20261001' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_base_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_base_result-allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'QI-PARTIAL'
      act = ls_base_result-batch_allocations[ 1 ]-request_id ).

    DATA(ls_unit_result) = lo_cut->allocate_quality_by_expiry_uom(
      it_demands    = VALUE #(
        ( request_id            = 'QI-FULL-BOX'
          material              = 'MAT-1'
          plant                 = '1000'
          requested_quantity    = '3.000'
          requested_unit        = 'BOX'
          require_full_quantity = abap_true )
        ( request_id         = 'QI-PARTIAL-BOX'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) )
      iv_as_of_date = '20261001' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_unit_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_unit_result-allocations[ 2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'QI-PARTIAL-BOX'
      act = ls_unit_result-batch_allocations[ 1 ]-batch_allocation-request_id ).
  ENDMETHOD.

  METHOD allocates_quality_fefo_rcpts.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).
    DATA(lt_receipts) = VALUE zcl_stock_service=>ty_dated_batch_receipts(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        batch            = 'B-QI-DUE'
        expiration_date  = '20261215'
        receipt_date     = '20261020'
        base_quantity    = '3.000' )
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        batch            = 'B-QI-FUTURE'
        expiration_date  = '20261231'
        receipt_date     = '20261021'
        base_quantity    = '7.000' ) ).

    DATA(ls_base_result) = lo_cut->allocate_quality_by_expiry(
      it_demands                  = VALUE #(
        ( request_id         = 'LATER'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          fefo_as_of_date    = '20261020' )
        ( request_id         = 'EARLIER'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          fefo_as_of_date    = '20261010' ) )
      it_projected_batch_receipts = lt_receipts
      iv_as_of_date               = '20261001' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_base_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_base_result-allocations[ 2 ]-available_quantity ).

    DATA(lt_unit_demands) = VALUE zcl_stock_service=>ty_unit_fefo_demands(
      ( request_id         = 'BOX-1'
        material           = 'MAT-1'
        plant              = '1000'
        requested_quantity = '1.000'
        requested_unit     = 'BOX'
        fefo_as_of_date    = '20261020' ) ).
    DATA(ls_unit_result) = lo_cut->allocate_quality_by_expiry_uom(
      it_demands                  = lt_unit_demands
      it_projected_batch_receipts = lt_receipts
      iv_as_of_date               = '20261001' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_unit_result-allocations[ 1 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_unit_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_unit_result-batch_allocations[ 1 ]-allocated_source_quantity ).

    DATA(ls_atp_result) = lo_cut->allocate_quality_by_expiry_atp(
      it_demands                  = lt_unit_demands
      it_projected_batch_receipts = lt_receipts
      iv_check_rule               = 'A'
      iv_as_of_date               = '20261001' ).
    DATA(lt_atp_requests) = lo_availability_api->get_requests( ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_atp_requests[ 1 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261020'
      act = lt_atp_requests[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_atp_result-atp_checks ) ).
  ENDMETHOD.

  METHOD rejects_quality_rcpt_pre_uom.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_quality_by_expiry_uom(
          it_demands                  = VALUE #(
            ( material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          it_projected_batch_receipts = VALUE #(
            ( material         = 'MAT-1'
              plant            = '1000'
              storage_location = '0001'
              batch            = 'B-QI-BAD'
              expiration_date  = '20261215'
              receipt_date     = '20261301'
              base_quantity    = '1.000' ) )
          iv_as_of_date               = '20261001' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_quality_batch.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stock_status(
      it_status = VALUE #(
        ( storage_location            = '0001'
          batch                       = 'B-QI-SOON'
          expiration_date             = '20261001'
          quality_inspection_quantity = '3.000' )
        ( storage_location            = '0002'
          batch                       = 'B-QI-SEL'
          expiration_date             = '20261010'
          quality_inspection_quantity = '7.000' ) ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    DATA(ls_result) = lo_cut->allocate_quality_by_expiry(
      it_demands    = VALUE #(
        ( request_id         = 'QI-BATCH'
          material           = 'MAT-1'
          plant              = '1000'
          batch              = 'B-QI-SEL'
          requested_quantity = '5.000' ) )
      iv_as_of_date = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-QI-SEL'
      act = ls_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-batch_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-batch_allocations ) ).
  ENDMETHOD.

  METHOD allocates_quality_loc_order.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stock_status(
      it_status = VALUE #(
        ( storage_location            = '0001'
          batch                       = 'B-QI'
          expiration_date             = '20261020'
          quality_inspection_quantity = '5.000' )
        ( storage_location            = '0002'
          batch                       = 'B-QI'
          expiration_date             = '20261020'
          quality_inspection_quantity = '5.000' ) ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    DATA(ls_result) = lo_cut->allocate_quality_by_expiry(
      it_demands                   = VALUE #(
        ( request_id                  = 'QI-LOC'
          material                    = 'MAT-1'
          plant                       = '1000'
          requested_quantity          = '7.000'
          fallback_to_other_locations = abap_false ) )
      it_storage_location_priority = VALUE #( ( '0002' ) ( '0001' ) )
      iv_as_of_date                = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-batch_allocations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-batch_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-batch_allocations[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-batch_allocations[ 2 ]-allocated_quantity ).
  ENDMETHOD.

  METHOD filters_quality_locations.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stock_status(
      it_status = VALUE #(
        ( storage_location            = '0001'
          batch                       = 'B-EXCLUDED'
          expiration_date             = '20261020'
          quality_inspection_quantity = '5.000' )
        ( storage_location            = '0002'
          batch                       = 'B-ALLOWED'
          expiration_date             = '20261031'
          quality_inspection_quantity = '8.000' ) ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    DATA(ls_result) = lo_cut->allocate_quality_by_expiry(
      it_demands                   = VALUE #(
        ( request_id                  = 'QI-ALLOW'
          material                    = 'MAT-1'
          plant                       = '1000'
          requested_quantity          = '5.000'
          fallback_to_other_locations = abap_false ) )
      it_allowed_storage_locations = VALUE #( ( '0002' ) )
      iv_as_of_date                = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-ALLOWED'
      act = ls_result-batch_allocations[ 1 ]-batch ).
  ENDMETHOD.

  METHOD rejects_quality_loc_filter.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA(lv_rejected) = abap_false.

    TRY.
        lo_cut->allocate_quality_by_expiry(
          it_demands                   = VALUE #(
            ( request_id                  = 'QI-LOC'
              material                    = 'MAT-1'
              plant                       = '1000'
              storage_location            = '0001'
              requested_quantity          = '1.000'
              fallback_to_other_locations = abap_false ) )
          it_allowed_storage_locations = VALUE #( ( '0002' ) )
          iv_as_of_date                = '20260923' ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD requires_full_quality_quantity.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stock_status(
      it_status = VALUE #(
        ( storage_location            = '0001'
          batch                       = 'B-QI'
          expiration_date             = '20261010'
          quality_inspection_quantity = '4.000' ) ) ).

    DATA(ls_result) = lo_cut->allocate_quality_by_expiry(
      it_demands               = VALUE #(
        ( request_id                  = 'QI-FULL'
          material                    = 'MAT-1'
          plant                       = '1000'
          fallback_to_other_locations = abap_false
          requested_quantity          = '5.000' ) )
      iv_as_of_date            = '20260923'
      iv_require_full_quantity = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = ls_result-allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-allocations[ 1 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_result-batch_allocations ) ).
  ENDMETHOD.

  METHOD allocates_quality_fefo_units.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stock_status(
      it_status = VALUE #(
        ( storage_location            = '0001'
          batch                       = 'B-SOON'
          expiration_date             = '20261001'
          quality_inspection_quantity = '12.000' )
        ( storage_location            = '0002'
          batch                       = 'B-LATER'
          expiration_date             = '20261015'
          quality_inspection_quantity = '12.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_result) = lo_cut->allocate_quality_by_expiry_uom(
      it_demands    = VALUE #(
        ( request_id                  = 'QI-BOX-1'
          material                    = 'MAT-1'
          plant                       = '1000'
          fallback_to_other_locations = abap_false
          requested_quantity          = '1.500'
          requested_unit              = 'BOX' )
        ( request_id                  = 'QI-BOX-2'
          material                    = 'MAT-1'
          plant                       = '1000'
          batch                       = 'B-LATER'
          fallback_to_other_locations = abap_false
          requested_quantity          = '0.500'
          requested_unit              = 'BOX' ) )
      iv_as_of_date = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '18.000' )
      act = ls_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.500' )
      act = ls_result-allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-allocations[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = ls_result-allocations[ 2 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-SOON'
      act = ls_result-batch_allocations[ 1 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-batch_allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_result-batch_allocations[ 3 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD alloc_quality_fefo_priority.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stock_status(
      it_status = VALUE #(
        ( storage_location            = '0001'
          batch                       = 'B-SOON'
          expiration_date             = '20261001'
          quality_inspection_quantity = '10.000' )
        ( storage_location            = '0002'
          batch                       = 'B-LATER'
          expiration_date             = '20261015'
          quality_inspection_quantity = '30.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_base_result) = lo_cut->allocate_quality_fefo_priority(
      it_demands    = VALUE #(
        ( request_id                  = 'QI-LOW'
          material                    = 'MAT-1'
          plant                       = '1000'
          fallback_to_other_locations = abap_false
          priority                    = 0
          requested_quantity          = '30.000' )
        ( request_id                  = 'QI-HIGH'
          material                    = 'MAT-1'
          plant                       = '1000'
          fallback_to_other_locations = abap_false
          priority                    = 10
          requested_quantity          = '30.000' ) )
      iv_as_of_date = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'QI-LOW'
      act = ls_base_result-allocations[ 1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_base_result-allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_base_result-allocations[
        1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'QI-HIGH'
      act = ls_base_result-allocations[ 2 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_base_result-allocations[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '30.000' )
      act = ls_base_result-allocations[
        2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_base_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'QI-LOW'
      act = ls_base_result-batch_allocations[
        1 ]-batch_allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_base_result-batch_allocations[
        1 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'QI-HIGH'
      act = ls_base_result-batch_allocations[
        3 ]-batch_allocation-request_id ).

    DATA(ls_uom_result) = lo_cut->allocate_quality_uom_priority(
      it_demands    = VALUE #(
        ( request_id                  = 'QI-UOM-LOW'
          material                    = 'MAT-1'
          plant                       = '1000'
          fallback_to_other_locations = abap_false
          priority                    = 0
          requested_quantity          = '15.000'
          requested_unit              = 'BOX' )
        ( request_id                  = 'QI-UOM-HIGH'
          material                    = 'MAT-1'
          plant                       = '1000'
          fallback_to_other_locations = abap_false
          priority                    = 10
          requested_quantity          = '15.000'
          requested_unit              = 'BOX' ) )
      iv_as_of_date = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'QI-UOM-LOW'
      act = ls_uom_result-allocations[
        1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_uom_result-allocations[
        1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_uom_result-allocations[
        1 ]-allocation-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'QI-UOM-HIGH'
      act = ls_uom_result-allocations[
        2 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_uom_result-allocations[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '30.000' )
      act = ls_uom_result-allocations[
        2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '15.000' )
      act = ls_uom_result-allocations[
        2 ]-allocation-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'QI-UOM-LOW'
      act = ls_uom_result-batch_allocations[
        1 ]-batch_allocation-batch_allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'QI-UOM-HIGH'
      act = ls_uom_result-batch_allocations[
        3 ]-batch_allocation-batch_allocation-request_id ).

    DATA lv_duplicate_rejected TYPE abap_bool.
    TRY.
        lo_cut->allocate_quality_fefo_priority(
          it_demands    = VALUE #(
            ( request_id         = 'QI-DUPLICATE'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000' )
            ( request_id         = 'QI-DUPLICATE'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000' ) )
          iv_as_of_date = '20260923' ).
      CATCH zcx_invalid_stock_request.
        lv_duplicate_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_duplicate_rejected ).

    DATA lv_uom_duplicate_rejected TYPE abap_bool.
    TRY.
        lo_cut->allocate_quality_uom_priority(
          it_demands    = VALUE #(
            ( request_id         = 'QI-UOM-DUPLICATE'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' )
            ( request_id         = 'QI-UOM-DUPLICATE'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          iv_as_of_date = '20260923' ).
      CATCH zcx_invalid_stock_request.
        lv_uom_duplicate_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_uom_duplicate_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD compares_quality_fefo_atp.
    DATA lv_as_of_date TYPE d.
    lv_as_of_date = '20260923'.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stock_status(
      it_status = VALUE #(
        ( storage_location            = '0001'
          batch                       = 'B-QI-SOON'
          expiration_date             = '20261001'
          quality_inspection_quantity = '4.000' )
        ( storage_location            = '0002'
          batch                       = 'B-QI-LATER'
          expiration_date             = '20261015'
          quality_inspection_quantity = '10.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    lo_availability_api->set_result(
      is_result = VALUE #(
        available_at_plant_quantity = '20.000'
        confirmed_quantity          = '6.000'
        confirmation_lines          = VALUE #(
          ( confirmed_date     = lv_as_of_date
            confirmed_quantity = '6.000' ) )
        is_fully_available          = abap_false
        is_check_relevant           = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).
    DATA(lt_demands) = VALUE zcl_stock_service=>ty_unit_fefo_demands(
      ( request_id         = 'QI-ATP'
        material           = 'MAT-1'
        plant              = '1000'
        requested_quantity = '4.000'
        requested_unit     = 'BOX' ) ).
    DATA lv_bad_rule_rejected TYPE abap_bool.

    TRY.
        lo_cut->allocate_quality_by_expiry_atp(
          it_demands    = lt_demands
          iv_check_rule = space
          iv_as_of_date = lv_as_of_date ).
      CATCH zcx_invalid_stock_request.
        lv_bad_rule_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_rule_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_availability_api->get_check_count( ) ).

    DATA(ls_result) = lo_cut->allocate_quality_by_expiry_atp(
      it_demands    = lt_demands
      iv_check_rule = 'A'
      iv_as_of_date = lv_as_of_date ).
    DATA(lt_atp_requests) = lo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_result-local_estimate-allocations[ 1 ]-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-local_estimate-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-QI-SOON'
      act = ls_result-local_estimate-batch_allocations[
        1 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-QI-LATER'
      act = ls_result-local_estimate-batch_allocations[
        2 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-atp_checks[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_as_of_date
      act = ls_result-atp_checks[ 1 ]-check_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_result-atp_checks[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-atp_checks[ 1 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 1 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_atp_requests[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = lt_atp_requests[ 1 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_availability_api->get_check_count( ) ).
  ENDMETHOD.

  METHOD allocates_fefo_units.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-SOON'
          expiration_date    = '20261001'
          available_quantity = '10.000' )
        ( storage_location   = '0002'
          batch              = 'B-LATER'
          expiration_date    = '20261101'
          available_quantity = '14.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_result) = lo_cut->allocate_by_expiry_in_units(
      it_demands    = VALUE #(
        ( request_id         = 'BOX-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'EA-2'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '12.000'
          requested_unit     = 'EA' ) )
      iv_as_of_date = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX-1'
      act = ls_result-allocations[ 1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = ls_result-allocations[ 1 ]-source_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA-2'
      act = ls_result-allocations[ 2 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-allocations[ 2 ]-allocated_source_quantity ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX-1'
      act = ls_result-batch_allocations[ 1 ]-batch_allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-SOON'
      act = ls_result-batch_allocations[ 1 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_result-batch_allocations[ 1 ]-batch_allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.833' )
      act = ls_result-batch_allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX-1'
      act = ls_result-batch_allocations[ 2 ]-batch_allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.167' )
      act = ls_result-batch_allocations[ 2 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA-2'
      act = ls_result-batch_allocations[ 3 ]-batch_allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-batch_allocations[ 3 ]-source_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-batch_allocations[ 3 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).

    DATA(ls_shelf_result) = lo_cut->allocate_by_expiry_in_units(
      it_demands    = VALUE #(
        ( request_id              = 'BOX-SHELF'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '1.000'
          requested_unit          = 'BOX'
          minimum_shelf_life_days = 30 ) )
      iv_as_of_date = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_shelf_result-batch_allocations[
        1 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 30
      act = ls_shelf_result-batch_allocations[
        1 ]-batch_allocation-minimum_shelf_life_days ).

    DATA(ls_required_date_result) = lo_cut->allocate_by_expiry_in_units(
      it_demands    = VALUE #(
        ( request_id         = 'BOX-DATE'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          requested_unit     = 'BOX'
          fefo_as_of_date    = '20261005' ) )
      iv_as_of_date = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_required_date_result-batch_allocations[
        1 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261005'
      act = ls_required_date_result-batch_allocations[
        1 ]-batch_allocation-as_of_date ).
  ENDMETHOD.

  METHOD allocates_fefo_by_priority.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-SOON'
          expiration_date    = '20261001'
          available_quantity = '10.000' )
        ( storage_location   = '0002'
          batch              = 'B-LATER'
          expiration_date    = '20261101'
          available_quantity = '5.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_base_result) = lo_cut->allocate_by_expiry_priority(
      it_demands    = VALUE #(
        ( request_id         = 'LOW'
          material           = 'MAT-1'
          plant              = '1000'
          priority           = 0
          requested_quantity = '12.000' )
        ( request_id         = 'HIGH-1'
          material           = 'MAT-1'
          plant              = '1000'
          priority           = 10
          requested_quantity = '12.000' )
        ( request_id         = 'HIGH-2'
          material           = 'MAT-1'
          plant              = '1000'
          priority           = 10
          requested_quantity = '12.000' ) )
      iv_as_of_date = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_base_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LOW'
      act = ls_base_result-allocations[ 1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_base_result-allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = ls_base_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'HIGH-1'
      act = ls_base_result-allocations[ 2 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_base_result-allocations[ 2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'HIGH-2'
      act = ls_base_result-allocations[ 3 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_base_result-allocations[ 3 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_base_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'HIGH-1'
      act = ls_base_result-batch_allocations[
        1 ]-batch_allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-SOON'
      act = ls_base_result-batch_allocations[
        1 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'HIGH-2'
      act = ls_base_result-batch_allocations[
        3 ]-batch_allocation-request_id ).

    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-SOON'
          expiration_date    = '20261001'
          available_quantity = '10.000' )
        ( storage_location   = '0002'
          batch              = 'B-LATER'
          expiration_date    = '20261101'
          available_quantity = '15.000' ) ) ).
    DATA(ls_split_order_result) = lo_cut->allocate_by_expiry_priority(
      it_demands    = VALUE #(
        ( request_id         = 'LOW'
          material           = 'MAT-1'
          plant              = '1000'
          priority           = 0
          requested_quantity = '12.000' )
        ( request_id         = 'HIGH-1'
          material           = 'MAT-1'
          plant              = '1000'
          priority           = 10
          requested_quantity = '12.000' )
        ( request_id         = 'HIGH-2'
          material           = 'MAT-1'
          plant              = '1000'
          priority           = 10
          requested_quantity = '12.000' ) )
      iv_as_of_date = '20260923' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LOW'
      act = ls_split_order_result-batch_allocations[
        1 ]-batch_allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'HIGH-2'
      act = ls_split_order_result-batch_allocations[
        4 ]-batch_allocation-request_id ).

    DATA(ls_uom_result) = lo_cut->allocate_fefo_uom_priority(
      it_demands    = VALUE #(
        ( request_id         = 'UOM-LOW'
          material           = 'MAT-1'
          plant              = '1000'
          priority           = 0
          requested_quantity = '6.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'UOM-HIGH-1'
          material           = 'MAT-1'
          plant              = '1000'
          priority           = 10
          requested_quantity = '6.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'UOM-HIGH-2'
          material           = 'MAT-1'
          plant              = '1000'
          priority           = 10
          requested_quantity = '6.000'
          requested_unit     = 'BOX' ) )
      iv_as_of_date = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'UOM-LOW'
      act = ls_uom_result-allocations[
        1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_uom_result-allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_uom_result-allocations[
        1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = ls_uom_result-allocations[
        1 ]-allocation-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'UOM-HIGH-1'
      act = ls_uom_result-allocations[
        2 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_uom_result-allocations[ 2 ]-allocation-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_uom_result-allocations[
        2 ]-allocation-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'UOM-HIGH-2'
      act = ls_uom_result-allocations[
        3 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_uom_result-allocations[
        3 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_uom_result-allocations[
        3 ]-allocation-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( ls_uom_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'UOM-LOW'
      act = ls_uom_result-batch_allocations[
        1 ]-batch_allocation-batch_allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = ls_uom_result-batch_allocations[
        1 ]-batch_allocation-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'UOM-HIGH-2'
      act = ls_uom_result-batch_allocations[
        4 ]-batch_allocation-batch_allocation-request_id ).

    DATA lv_duplicate_rejected TYPE abap_bool.
    TRY.
        lo_cut->allocate_by_expiry_priority(
          it_demands    = VALUE #(
            ( request_id         = 'DUPLICATE'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000' )
            ( request_id         = 'DUPLICATE'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000' ) )
          iv_as_of_date = '20260923' ).
      CATCH zcx_invalid_stock_request.
        lv_duplicate_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_duplicate_rejected ).

    DATA lv_uom_duplicate_rejected TYPE abap_bool.
    TRY.
        lo_cut->allocate_fefo_uom_priority(
          it_demands    = VALUE #(
            ( request_id         = 'DUPLICATE-UOM'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' )
            ( request_id         = 'DUPLICATE-UOM'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) )
          iv_as_of_date = '20260923' ).
      CATCH zcx_invalid_stock_request.
        lv_uom_duplicate_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_uom_duplicate_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_fefo_uom_batch.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-SOON'
          expiration_date    = '20261001'
          available_quantity = '10.000' )
        ( storage_location   = '0002'
          batch              = 'B-SELECTED'
          expiration_date    = '20261010'
          available_quantity = '14.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_result) = lo_cut->allocate_by_expiry_in_units(
      it_demands    = VALUE #(
        ( request_id         = 'FEFO-UNIT-BATCH'
          material           = 'MAT-1'
          plant              = '1000'
          batch              = 'B-SELECTED'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' ) )
      iv_as_of_date = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '14.000' )
      act = ls_result-allocations[ 1 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-SELECTED'
      act = ls_result-batch_allocations[ 1 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-batch_allocations[ 1 ]-batch_allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-batch_allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-batch_allocations ) ).
  ENDMETHOD.

  METHOD filters_fefo_min_days.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-EXPIRED'
          expiration_date    = '20260922'
          available_quantity = '1.000' )
        ( storage_location   = '0001'
          batch              = 'B-SAME-DAY'
          expiration_date    = '20260923'
          available_quantity = '1.000' )
        ( storage_location   = '0001'
          batch              = 'B-6-DAYS'
          expiration_date    = '20260929'
          available_quantity = '1.000' )
        ( storage_location   = '0001'
          batch              = 'B-7-DAYS'
          expiration_date    = '20260930'
          available_quantity = '1.000' )
        ( storage_location   = '0001'
          batch              = 'B-12-DAYS'
          expiration_date    = '20261005'
          available_quantity = '1.000' )
        ( storage_location   = '0001'
          batch              = 'B-NO-DATE'
          available_quantity = '1.000' ) ) ).

    DATA(ls_result) = lo_cut->allocate_by_expiry(
      it_demands    = VALUE #(
        ( material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '10.000' ) )
      iv_as_of_date = '20260923'
      iv_min_days   = 7 ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-7-DAYS'
      act = ls_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-12-DAYS'
      act = ls_result-batch_allocations[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_result-allocations[ 1 ]-shortfall_quantity ).

    DATA(ls_demand_result) = lo_cut->allocate_by_expiry(
      it_demands    = VALUE #(
        ( request_id         = 'REQ-SHARED-FLOOR'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000' )
        ( request_id              = 'REQ-LONG-BUFFER'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '1.000'
          minimum_shelf_life_days = 12 ) )
      iv_as_of_date = '20260923'
      iv_min_days   = 3 ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'B-6-DAYS'
      act = ls_demand_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = ls_demand_result-batch_allocations[
        1 ]-minimum_shelf_life_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-12-DAYS'
      act = ls_demand_result-batch_allocations[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 12
      act = ls_demand_result-batch_allocations[
        2 ]-minimum_shelf_life_days ).
  ENDMETHOD.

  METHOD rejects_negative_fefo_days.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_by_expiry(
          it_demands  = VALUE #(
            ( material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000' ) )
          iv_min_days = -1 ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD restricts_fefo_to_location.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          expiration_date    = '20261001'
          available_quantity = '4.000' )
        ( storage_location   = '0002'
          batch              = 'B-2'
          expiration_date    = '20260925'
          available_quantity = '5.000' ) ) ).

    DATA(ls_result) = lo_cut->allocate_by_expiry(
      it_demands    = VALUE #(
        ( material           = 'MAT-1'
          plant              = '1000'
          storage_location   = '0001'
          requested_quantity = '3.000' ) )
      iv_as_of_date = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-batch_allocations[ 1 ]-storage_location ).
  ENDMETHOD.

  METHOD prefers_fefo_location_first.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-PREF'
          expiration_date    = '20261001'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          batch              = 'B-EARLIEST'
          expiration_date    = '20260925'
          available_quantity = '3.000' ) ) ).

    DATA(ls_result) = lo_cut->allocate_by_expiry(
      it_demands    = VALUE #(
        ( material                    = 'MAT-1'
          plant                       = '1000'
          storage_location            = '0001'
          fallback_to_other_locations = abap_true
          requested_quantity          = '4.000' ) )
      iv_as_of_date = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-PREF'
      act = ls_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-batch_allocations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EARLIEST'
      act = ls_result-batch_allocations[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-batch_allocations[ 2 ]-storage_location ).
  ENDMETHOD.

  METHOD allocates_fefo_loc_order.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-EARLY'
          expiration_date    = '20260925'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          batch              = 'B-EARLY'
          expiration_date    = '20260925'
          available_quantity = '3.000' )
        ( storage_location   = '0003'
          batch              = 'B-LATER'
          expiration_date    = '20261001'
          available_quantity = '5.000' ) ) ).

    DATA(ls_result) = lo_cut->allocate_by_expiry(
      it_demands                   = VALUE #(
        ( request_id         = 'FEFO-LOC-ORDER'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '6.000' ) )
      it_storage_location_priority = VALUE #(
        ( '0002' )
        ( '0003' )
        ( '0001' ) )
      iv_as_of_date                = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-batch_allocations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EARLY'
      act = ls_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '3.000' )
      act = ls_result-batch_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-batch_allocations[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EARLY'
      act = ls_result-batch_allocations[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_result-batch_allocations[ 3 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = ls_result-batch_allocations[ 3 ]-storage_location ).
  ENDMETHOD.

  METHOD protects_safety_stock_in_alloc.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_stock( iv_quantity = '10.000' ).
    lo_repository->set_safety_stock( iv_quantity = '3.000' ).

    DATA(ls_result) = lo_cut->allocate_request(
      iv_material             = 'MAT-1'
      iv_plant                = '1000'
      iv_requested_quantity   = '10.000'
      iv_protect_safety_stock = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = ls_result-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = ls_result-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-shortfall_quantity ).
  ENDMETHOD.

  METHOD protects_location_safety_stock.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          available_quantity = '5.000' ) ) ).
    lo_repository->set_safety_stock( iv_quantity = '3.000' ).

    DATA(ls_result) = lo_cut->allocate_by_storage_location(
      it_demands              = VALUE #(
        ( material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '4.000' ) )
      iv_protect_safety_stock = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-storage_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-storage_allocations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-storage_allocations[ 1 ]-allocated_quantity ).
  ENDMETHOD.

  METHOD protects_batch_safety_stock.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          available_quantity = '5.000' )
        ( storage_location   = '0001'
          batch              = 'B-2'
          available_quantity = '5.000' ) ) ).
    lo_repository->set_safety_stock( iv_quantity = '3.000' ).

    DATA(ls_result) = lo_cut->allocate_by_batch(
      it_demands              = VALUE #(
        ( material           = 'MAT-1'
          plant              = '1000'
          batch              = 'B-1'
          requested_quantity = '5.000' ) )
      iv_protect_safety_stock = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-batch_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocations[ 1 ]-shortfall_quantity ).
  ENDMETHOD.

  METHOD protects_fefo_safety_stock.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-SOON'
          expiration_date    = '20260930'
          available_quantity = '5.000' )
        ( storage_location   = '0001'
          batch              = 'B-LATER'
          expiration_date    = '20261010'
          available_quantity = '5.000' ) ) ).
    lo_repository->set_safety_stock( iv_quantity = '3.000' ).

    DATA(ls_result) = lo_cut->allocate_by_expiry(
      it_demands              = VALUE #(
        ( material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '10.000' ) )
      iv_as_of_date           = '20260923'
      iv_protect_safety_stock = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-SOON'
      act = ls_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-batch_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_result-batch_allocations[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-batch_allocations[ 2 ]-allocated_quantity ).
  ENDMETHOD.

  METHOD rejects_invalid_fefo_input.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_by_expiry(
          it_demands    = VALUE #(
            ( material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '-1.000' ) )
          iv_as_of_date = '20260923' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_in_alternative_unit.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_repository->set_stock( iv_quantity = '10.000' ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(ls_result) = lo_cut->allocate_request_in_unit(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_requested_quantity = '1.000'
      iv_requested_unit     = 'BOX' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = ls_result-source_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_result-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_demands_in_units.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_stock( iv_quantity = '30.000' ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).

    DATA(lt_results) = lo_cut->allocate_demands_in_units(
      it_demands = VALUE #(
        ( request_id         = 'REQ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'REQ-2'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '10.000'
          requested_unit     = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_results[ 1 ]-source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lt_results[ 1 ]-source_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '24.000' )
      act = lt_results[ 1 ]-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '30.000' )
      act = lt_results[ 1 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '24.000' )
      act = lt_results[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_results[ 2 ]-source_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = lt_results[ 2 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = lt_results[ 2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_results[ 2 ]-allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).

    lo_repository->set_stock( iv_quantity = '15.000' ).
    DATA(lt_priority_results) = lo_cut->allocate_demands_uom_priority(
      it_demands = VALUE zcl_stock_service=>ty_priority_unit_demands(
        ( request_id         = 'LOW-BOX'
          material           = 'MAT-1'
          plant              = '1000'
          priority           = 1
          requested_quantity = '1.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'HIGH-BOX'
          material           = 'MAT-1'
          plant              = '1000'
          priority           = 10
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LOW-BOX'
      act = lt_priority_results[ 1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lt_priority_results[ 1 ]-allocation-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_priority_results[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'HIGH-BOX'
      act = lt_priority_results[ 2 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = lt_priority_results[ 2 ]-allocation-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = lt_priority_results[ 2 ]-allocation-allocated_quantity ).
  ENDMETHOD.

  METHOD compares_uom_demand_atp.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_stock( iv_quantity = '6.000' ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    lo_availability_api->set_result(
      is_result = VALUE #(
        available_at_plant_quantity = '6.000'
        confirmed_quantity          = '4.000'
        confirmation_lines          = VALUE #(
          ( confirmed_date     = '20261015'
            confirmed_quantity = '4.000' ) )
        is_fully_available          = abap_false
        is_check_relevant           = abap_true ) ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).

    DATA(ls_result) = lo_cut->allocate_demands_uom_atp(
      it_demands        = VALUE #(
        ( request_id         = 'BOX-REQ'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'EA-REQ'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '2.000'
          requested_unit     = 'EA' ) )
      iv_check_rule     = 'A'
      iv_atp_check_date = '20261015' ).
    DATA(lt_atp_requests) = lo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-local_estimate ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX-REQ'
      act = ls_result-local_estimate[ 1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-local_estimate[ 1 ]-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-local_estimate[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA-REQ'
      act = ls_result-local_estimate[ 2 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-local_estimate[ 2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-atp_checks[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261015'
      act = ls_result-atp_checks[ 1 ]-check_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-atp_checks[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-atp_checks[ 1 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 1 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_atp_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_atp_requests[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = lt_atp_requests[ 1 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD defaults_uom_demand_atp_date.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_stock( iv_quantity = '2.000' ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    lo_availability_api->set_result( is_result = VALUE #(
      is_fully_available = abap_true
      is_check_relevant  = abap_true ) ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).

    DATA(ls_result) = lo_cut->allocate_demands_uom_atp(
      it_demands    = VALUE #(
        ( request_id         = 'DEFAULT-DATE'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          requested_unit     = 'EA' ) )
      iv_check_rule = 'A' ).
    DATA(lt_atp_requests) = lo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = sy-datum
      act = ls_result-atp_checks[ 1 ]-check_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = sy-datum
      act = lt_atp_requests[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-atp_checks[ 1 ]-confirmed_base_quantity ).
  ENDMETHOD.

  METHOD rejects_uom_demand_atp_opts.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_material_availability_api = lo_availability_api ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_demands_uom_atp(
          it_demands    = VALUE #(
            ( request_id         = 'BAD-RULE'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              requested_unit     = 'EA' ) )
          iv_check_rule = space ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lo_availability_api->get_requests( ) ) ).

    CLEAR lv_exception_raised.
    TRY.
        lo_cut->allocate_demands_uom_atp(
          it_demands        = VALUE #(
            ( request_id         = 'BAD-DATE'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              requested_unit     = 'EA' ) )
          iv_check_rule     = 'A'
          iv_atp_check_date = '20260230' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lo_availability_api->get_requests( ) ) ).
  ENDMETHOD.

  METHOD prioritizes_uom_demand_atp.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_stock( iv_quantity = '6.000' ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    lo_availability_api->set_result(
      is_result = VALUE #(
        available_at_plant_quantity = '6.000'
        confirmed_quantity          = '4.000'
        confirmation_lines          = VALUE #(
          ( confirmed_date     = '20261015'
            confirmed_quantity = '4.000' ) )
        is_fully_available          = abap_false
        is_check_relevant           = abap_true ) ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).

    DATA(ls_result) = lo_cut->allocate_demands_uom_atp_prio(
      it_demands        = VALUE #(
        ( request_id         = 'LOW'
          material           = 'MAT-1'
          plant              = '1000'
          priority           = 1
          requested_quantity = '2.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'HIGH'
          material           = 'MAT-1'
          plant              = '1000'
          priority           = 9
          requested_quantity = '2.000'
          requested_unit     = 'BOX' ) )
      iv_check_rule     = 'A'
      iv_atp_check_date = '20261015' ).
    DATA(lt_atp_requests) = lo_availability_api->get_requests( ).
    DATA(ls_low_allocation) = ls_result-local_estimate[ 1 ].
    DATA(ls_high_allocation) = ls_result-local_estimate[ 2 ].

    cl_abap_unit_assert=>assert_equals(
      exp = 'LOW'
      act = ls_result-local_estimate[ 1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-local_estimate[ 1 ]-allocation-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_low_allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'HIGH'
      act = ls_result-local_estimate[ 2 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 9
      act = ls_result-local_estimate[ 2 ]-allocation-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_high_allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-atp_checks[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261015'
      act = ls_result-atp_checks[ 1 ]-check_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-atp_checks[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-atp_checks[ 1 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 1 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_atp_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = lt_atp_requests[ 1 ]-requested_quantity ).
  ENDMETHOD.

  METHOD rejects_uom_rounding_to_zero.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'TNY'
      iv_numerator        = 1
      iv_denominator      = 1000 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_demands_in_units(
          it_demands = VALUE #(
            ( request_id         = 'TINY'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '0.001'
              requested_unit     = 'TNY' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    CLEAR lv_exception_raised.
    TRY.
        lo_cut->allocate_request_in_unit(
          iv_material           = 'MAT-1'
          iv_plant              = '1000'
          iv_requested_quantity = '0.001'
          iv_requested_unit     = 'TNY' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    CLEAR lv_exception_raised.
    TRY.
        lo_cut->allocate_location_by_date_uom(
          it_demands = VALUE #(
            ( request_id         = 'TINY-DATE'
              material           = 'MAT-1'
              plant              = '1000'
              required_date      = '20261020'
              requested_quantity = '0.001'
              requested_unit     = 'TNY' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_unknown_alloc_unit.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'PAL'
      iv_numerator        = 100
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_request_in_unit(
          iv_material           = 'MAT-1'
          iv_plant              = '1000'
          iv_requested_quantity = '1.000'
          iv_requested_unit     = 'BOX' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_unknown_bulk_unit.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_demands_in_units(
          it_demands = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' )
            ( request_id         = 'REQ-2'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              requested_unit     = 'CASE' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_unknown_fefo_unit.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_by_expiry_in_units(
          it_demands    = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' )
            ( request_id         = 'REQ-2'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              requested_unit     = 'CSH' ) )
          iv_as_of_date = '20260923' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_unknown_batch_unit.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_by_batch_in_units(
          it_demands = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              plant              = '1000'
              batch              = 'B-1'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' )
            ( request_id         = 'REQ-2'
              material           = 'MAT-1'
              plant              = '1000'
              batch              = 'B-1'
              requested_quantity = '1.000'
              requested_unit     = 'CSH' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_unknown_location_unit.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_by_location_in_units(
          it_demands = VALUE #(
            ( request_id         = 'REQ-1'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' )
            ( request_id         = 'REQ-2'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              requested_unit     = 'CSH' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_unknown_status_unit.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'PAL'
      iv_numerator        = 100
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->get_stock_status_in_unit(
          iv_material = 'MAT-1'
          iv_plant    = '1000'
          iv_unit     = 'BOX' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_unknown_location_units.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA lv_location_exception TYPE abap_bool.
    DATA lv_batch_exception TYPE abap_bool.
    DATA lv_fefo_exception TYPE abap_bool.

    TRY.
        lo_cut->get_stock_by_location_in_unit(
          iv_material = 'MAT-1'
          iv_plant    = '1000'
          iv_unit     = 'CSH' ).
      CATCH zcx_invalid_stock_request.
        lv_location_exception = abap_true.
    ENDTRY.
    TRY.
        lo_cut->get_stock_by_batch_in_unit(
          iv_material = 'MAT-1'
          iv_plant    = '1000'
          iv_unit     = 'CSH' ).
      CATCH zcx_invalid_stock_request.
        lv_batch_exception = abap_true.
    ENDTRY.
    TRY.
        lo_cut->get_fefo_batch_status_in_unit(
          iv_material = 'MAT-1'
          iv_plant    = '1000'
          iv_unit     = 'CSH' ).
      CATCH zcx_invalid_stock_request.
        lv_fefo_exception = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_location_exception ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_batch_exception ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_fefo_exception ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD compares_fefo_atp.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-EARLY'
          expiration_date    = '20261022'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          batch              = 'B-LATE'
          expiration_date    = '20261130'
          available_quantity = '4.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    lo_availability_api->set_result_for_call(
      iv_call_number = 1
      is_result      = VALUE #(
        available_at_plant_quantity = '2.000'
        is_fully_available          = abap_true
        is_check_relevant           = abap_true ) ).
    lo_availability_api->set_result_for_call(
      iv_call_number = 2
      is_result      = VALUE #(
        available_at_plant_quantity = '4.000'
        confirmed_quantity          = '3.000'
        confirmation_lines          = VALUE #(
          ( confirmed_date     = '20261025'
            confirmed_quantity = '3.000' ) )
        is_fully_available          = abap_false
        is_check_relevant           = abap_true ) ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).
    DATA lv_bad_rule_rejected TYPE abap_bool.
    DATA(lt_demands) = VALUE zcl_stock_service=>ty_unit_fefo_demands(
      ( request_id         = 'FEFO-EARLY'
        material           = 'MAT-1'
        plant              = '1000'
        requested_quantity = '1.000'
        requested_unit     = 'BOX'
        fefo_as_of_date    = '20261020' )
      ( request_id         = 'FEFO-LATE'
        material           = 'MAT-1'
        plant              = '1000'
        requested_quantity = '1.000'
        requested_unit     = 'BOX'
        fefo_as_of_date    = '20261025' ) ).

    TRY.
        lo_cut->allocate_by_expiry_atp(
          it_demands    = lt_demands
          iv_check_rule = space ).
      CATCH zcx_invalid_stock_request.
        lv_bad_rule_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_rule_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_availability_api->get_check_count( ) ).

    DATA(ls_result) = lo_cut->allocate_by_expiry_atp(
      it_demands    = lt_demands
      iv_check_rule = 'A'
      iv_as_of_date = '20261018'
      iv_min_days   = 0 ).
    DATA(lt_atp_requests) = lo_availability_api->get_requests( ).
    DATA(ls_early_batch_split) =
      ls_result-local_estimate-batch_allocations[ 1 ].
    DATA(ls_late_batch_split) =
      ls_result-local_estimate-batch_allocations[ 2 ].

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-local_estimate-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EARLY'
      act = ls_early_batch_split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261020'
      act = ls_early_batch_split-batch_allocation-as_of_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATE'
      act = ls_late_batch_split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261020'
      act = ls_result-atp_checks[ 1 ]-check_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 1 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261025'
      act = ls_result-atp_checks[ 2 ]-check_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 2 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-atp_checks[ 2 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-atp_checks[ 2 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-atp_checks[ 2 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_atp_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_atp_requests[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261025'
      act = lt_atp_requests[ 2 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_atp_requests[ 2 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_availability_api->get_check_count( ) ).

    DATA(ls_expired_result) = lo_cut->allocate_by_expiry_atp(
      it_demands    = VALUE #(
        ( request_id         = 'FEFO-EXPIRED'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          requested_unit     = 'BOX'
          fefo_as_of_date    = '20261231' ) )
      iv_check_rule = 'A'
      iv_as_of_date = '20261018' ).
    DATA(ls_expired_allocation) =
      ls_expired_result-local_estimate-allocations[ 1 ].
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_expired_allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_expired_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_availability_api->get_check_count( ) ).
  ENDMETHOD.

  METHOD compares_fefo_priority_atp.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-SOON'
          expiration_date    = '20261030'
          available_quantity = '6.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    lo_availability_api->set_result(
      is_result = VALUE #(
        available_at_plant_quantity = '6.000'
        confirmed_quantity          = '4.000'
        confirmation_lines          = VALUE #(
          ( confirmed_date     = '20261015'
            confirmed_quantity = '4.000' ) )
        is_fully_available          = abap_false
        is_check_relevant           = abap_true ) ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).

    DATA(ls_result) = lo_cut->allocate_fefo_uom_atp_prio(
      it_demands    = VALUE #(
        ( request_id         = 'LOW'
          material           = 'MAT-1'
          plant              = '1000'
          priority           = 1
          requested_quantity = '2.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'HIGH'
          material           = 'MAT-1'
          plant              = '1000'
          priority           = 9
          requested_quantity = '2.000'
          requested_unit     = 'BOX' ) )
      iv_check_rule = 'A'
      iv_as_of_date = '20261015' ).
    DATA(ls_low_allocation) =
      ls_result-local_estimate-allocations[ 1 ].
    DATA(ls_high_allocation) =
      ls_result-local_estimate-allocations[ 2 ].
    DATA(ls_low_split) =
      ls_result-local_estimate-batch_allocations[ 1 ].

    cl_abap_unit_assert=>assert_equals(
      exp = 'LOW'
      act = ls_low_allocation-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_low_allocation-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 9
      act = ls_high_allocation-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_high_allocation-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-SOON'
      act = ls_low_split-batch_allocation-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_low_split-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-atp_checks[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-atp_checks[ 1 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 1 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_availability_api->get_check_count( ) ).
  ENDMETHOD.

  METHOD compares_batch_atp.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-SELECTED'
          expiration_date    = '20261030'
          available_quantity = '3.000' )
        ( storage_location   = '0002'
          batch              = 'B-LATE'
          expiration_date    = '20261130'
          available_quantity = '2.000' )
        ( storage_location   = '0003'
          batch              = 'B-OTHER'
          expiration_date    = '20261231'
          available_quantity = '100.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    lo_availability_api->set_result_for_call(
      iv_call_number = 1
      is_result      = VALUE #(
        available_at_plant_quantity = '5.000'
        confirmed_quantity          = '2.000'
        confirmation_lines          = VALUE #(
          ( confirmed_date     = '20261025'
            confirmed_quantity = '2.000' ) )
        is_fully_available          = abap_false
        is_check_relevant           = abap_true ) ).
    lo_availability_api->set_result_for_call(
      iv_call_number = 2
      is_result      = VALUE #(
        available_at_plant_quantity = '5.000'
        confirmed_quantity          = '4.000'
        confirmation_lines          = VALUE #(
          ( confirmed_date     = '20261030'
            confirmed_quantity = '4.000' ) )
        is_fully_available          = abap_false
        is_check_relevant           = abap_true ) ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).
    DATA lv_bad_rule_rejected TYPE abap_bool.
    DATA(lt_demands) = VALUE zcl_stock_service=>ty_unit_batch_demands(
      ( request_id         = 'BATCH-ATP-EARLY'
        material           = 'MAT-1'
        plant              = '1000'
        batch              = 'B-SELECTED'
        requested_quantity = '2.000'
        requested_unit     = 'BOX' )
      ( request_id         = 'BATCH-ATP-LATE'
        material           = 'MAT-1'
        plant              = '1000'
        batch              = 'B-LATE'
        requested_quantity = '1.000'
        requested_unit     = 'BOX'
        as_of_date         = '20261030' ) ).

    TRY.
        lo_cut->allocate_by_batch_atp(
          it_demands    = lt_demands
          iv_check_rule = space ).
      CATCH zcx_invalid_stock_request.
        lv_bad_rule_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_rule_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_availability_api->get_check_count( ) ).

    DATA(ls_result) = lo_cut->allocate_by_batch_atp(
      it_demands    = lt_demands
      iv_check_rule = 'A'
      iv_as_of_date = '20261025' ).
    DATA(lt_atp_requests) = lo_availability_api->get_requests( ).
    DATA(ls_early_allocation) =
      ls_result-local_estimate-allocations[ 1 ].
    DATA(ls_early_batch_split) =
      ls_result-local_estimate-batch_allocations[ 1 ].

    cl_abap_unit_assert=>assert_equals(
      exp = 'B-SELECTED'
      act = ls_early_batch_split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261025'
      act = ls_early_batch_split-batch_allocation-as_of_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_early_allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_early_allocation-allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-local_estimate-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261025'
      act = ls_result-atp_checks[ 1 ]-check_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-atp_checks[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-atp_checks[ 1 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 1 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261030'
      act = ls_result-atp_checks[ 2 ]-check_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-atp_checks[ 2 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-atp_checks[ 2 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-atp_checks[ 2 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_atp_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_atp_requests[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261030'
      act = lt_atp_requests[ 2 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lt_atp_requests[ 2 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_availability_api->get_check_count( ) ).
  ENDMETHOD.

  METHOD allocates_location_by_date.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '2.000' ) ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA(lt_demands) = VALUE zcl_stock_service=>ty_dated_location_demands(
        ( request_id         = 'LOCATION-LATE'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = '20261220'
          priority           = 100
          requested_quantity = '1.000' )
        ( request_id         = 'LOCATION-EARLY-LOW'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = '20261210'
          priority           = 0
          requested_quantity = '1.000' )
        ( request_id         = 'LOCATION-EARLY-TIE'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = '20261210'
          priority           = 0
          requested_quantity = '1.000' )
        ( request_id         = 'LOCATION-EARLY-HIGH'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = '20261210'
          priority           = 5
          requested_quantity = '1.000' ) ).
    DATA lv_bad_date_rejected TYPE abap_bool.
    DATA lv_duplicate_ids_rejected TYPE abap_bool.

    TRY.
        lo_cut->allocate_location_by_date(
          it_demands = VALUE #(
            ( request_id         = 'LOCATION-BAD-DATE'
              material           = 'MAT-1'
              plant              = '1000'
              required_date      = '20260230'
              requested_quantity = '1.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_bad_date_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_location_by_date(
          it_demands = VALUE #(
            ( request_id         = 'LOCATION-DUPLICATE'
              material           = 'MAT-1'
              plant              = '1000'
              required_date      = '20261210'
              requested_quantity = '1.000' )
            ( request_id         = 'LOCATION-DUPLICATE'
              material           = 'MAT-1'
              plant              = '1000'
              required_date      = '20261211'
              requested_quantity = '1.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_duplicate_ids_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_date_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_duplicate_ids_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    DATA(ls_result) = lo_cut->allocate_location_by_date(
      it_demands               = lt_demands
      iv_require_full_quantity = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LOCATION-LATE'
      act = ls_result-allocations[
        1 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-allocations[
        1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 100
      act = ls_result-allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[
        2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-allocations[
        3 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocations[
        4 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = ls_result-allocations[ 4 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-storage_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LOCATION-EARLY-LOW'
      act = ls_result-storage_allocations[
        1 ]-storage_allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LOCATION-EARLY-HIGH'
      act = ls_result-storage_allocations[
        2 ]-storage_allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_dated_loc_receipts.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '2.000' ) ) ).
    lo_repository->set_safety_stock( iv_quantity = '3.000' ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA(lt_demands) = VALUE zcl_stock_service=>ty_dated_location_demands(
      ( request_id         = 'LOCATION-RECEIPT-LATE'
        material           = 'MAT-1'
        plant              = '1000'
        required_date      = '20261210'
        requested_quantity = '2.000' )
      ( request_id         = 'LOCATION-RECEIPT-EARLY'
        material           = 'MAT-1'
        plant              = '1000'
        required_date      = '20261205'
        requested_quantity = '2.000' ) ).
    DATA(lt_receipts) = VALUE zcl_stock_service=>ty_dated_location_receipts(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0002'
        receipt_date     = '20261210'
        base_quantity    = '3.000' ) ).
    DATA lv_bad_receipt_rejected TYPE abap_bool.

    TRY.
        lo_cut->allocate_location_by_date(
          it_demands            = lt_demands
          it_projected_receipts = VALUE #(
            ( material         = 'MAT-1'
              plant            = '1000'
              storage_location = '0002'
              receipt_date     = '20260230'
              base_quantity    = '3.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_bad_receipt_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_receipt_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).

    DATA(ls_result) = lo_cut->allocate_location_by_date(
      it_demands               = lt_demands
      it_projected_receipts    = lt_receipts
      iv_protect_safety_stock  = abap_true
      iv_require_full_quantity = abap_true ).
    DATA(ls_late_allocation) = ls_result-allocations[ 1 ].
    DATA(ls_early_allocation) = ls_result-allocations[ 2 ].

    cl_abap_unit_assert=>assert_equals(
      exp = 'LOCATION-RECEIPT-LATE'
      act = ls_late_allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_late_allocation-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_late_allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LOCATION-RECEIPT-EARLY'
      act = ls_early_allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = ls_early_allocation-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = ls_early_allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_early_allocation-allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-storage_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-storage_allocations[
        1 ]-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LOCATION-RECEIPT-LATE'
      act = ls_result-storage_allocations[
        1 ]-storage_allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD alloc_dated_loc_rcpt_uom.
    DATA lv_early_date TYPE d.
    DATA lv_late_date TYPE d.
    lv_early_date = '20261205'.
    lv_late_date = '20261210'.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '2.000' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    lo_availability_api->set_result(
      is_result = VALUE #(
        available_at_plant_quantity = '10.000'
        confirmed_quantity          = '5.000'
        confirmation_lines          = VALUE #(
          ( confirmed_date     = lv_early_date
            confirmed_quantity = '2.000' )
          ( confirmed_date     = lv_late_date
            confirmed_quantity = '3.000' ) )
        is_fully_available          = abap_true
        is_check_relevant           = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).
    DATA(lt_demands) = VALUE zcl_stock_service=>ty_dated_unit_location_demands(
      ( request_id                  = 'UOM-LOCATION-LATE'
        material                    = 'MAT-1'
        plant                       = '1000'
        required_date               = lv_late_date
        storage_location            = '0002'
        fallback_to_other_locations = abap_false
        requested_quantity          = '1.500'
        requested_unit              = 'BOX' )
      ( request_id                  = 'UOM-LOCATION-EARLY'
        material                    = 'MAT-1'
        plant                       = '1000'
        required_date               = lv_early_date
        storage_location            = '0001'
        fallback_to_other_locations = abap_false
        requested_quantity          = '1.000'
        requested_unit              = 'BOX' ) ).
    DATA(lt_receipts) = VALUE zcl_stock_service=>ty_dated_location_receipts(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0002'
        receipt_date     = lv_late_date
        base_quantity    = '4.000' ) ).
    DATA lv_bad_receipt_rejected TYPE abap_bool.

    TRY.
        lo_cut->allocate_location_by_date_uom(
          it_demands            = lt_demands
          it_projected_receipts = VALUE #(
            ( material         = 'MAT-1'
              plant            = '1000'
              storage_location = '0002'
              receipt_date     = '20260230'
              base_quantity    = '4.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_bad_receipt_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_receipt_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).

    DATA(ls_result) = lo_cut->allocate_location_by_date_uom(
      it_demands               = lt_demands
      it_projected_receipts    = lt_receipts
      iv_require_full_quantity = abap_true ).
    DATA(ls_late_allocation) = ls_result-allocations[ 1 ].
    DATA(ls_early_allocation) = ls_result-allocations[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      exp = 'UOM-LOCATION-LATE'
      act = ls_late_allocation-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_late_allocation-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.500' )
      act = ls_late_allocation-allocation-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-storage_allocations[
        1 ]-storage_split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.500' )
      act = ls_result-storage_allocations[
        1 ]-storage_split-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_early_allocation-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_early_allocation-allocation-allocated_source_quantity ).

    lo_repository->set_safety_stock( iv_quantity = '3.000' ).
    DATA(ls_protected_result) = lo_cut->allocate_location_by_date_uom(
      it_demands               = lt_demands
      it_projected_receipts    = lt_receipts
      iv_protect_safety_stock  = abap_true
      iv_require_full_quantity = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_protected_result-allocations[
        1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = ls_protected_result-allocations[
        2 ]-allocation-allocation-allocated_quantity ).

    DATA(ls_atp_result) = lo_cut->allocate_location_date_uom_atp(
      it_demands               = lt_demands
      it_projected_receipts    = lt_receipts
      iv_check_rule            = 'A'
      iv_require_full_quantity = abap_true ).
    DATA(lt_atp_requests) = lo_availability_api->get_requests( ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_atp_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_atp_result-atp_checks[ 1 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_atp_result-atp_checks[ 2 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_atp_requests[ 2 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lt_atp_requests[ 2 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_availability_api->get_check_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 6
      act = lo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD allocates_dated_location_units.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_stock( iv_quantity = '10.000' ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository
      io_uom_converter    = lo_converter ).
    DATA(lt_demands) = VALUE zcl_stock_service=>ty_dated_unit_location_demands(
        ( request_id         = 'LOCATION-LATE'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = '20261020'
          priority           = 100
          requested_quantity = '2.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'LOCATION-EARLY-LOW'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = '20261010'
          priority           = 0
          requested_quantity = '3.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'LOCATION-EARLY-TIE'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = '20261010'
          priority           = 0
          requested_quantity = '2.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'LOCATION-EARLY-HIGH'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = '20261010'
          priority           = 5
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) ).
    DATA lv_bad_date_rejected TYPE abap_bool.
    DATA lv_duplicate_ids_rejected TYPE abap_bool.

    TRY.
        lo_cut->allocate_location_by_date_uom(
          it_demands = VALUE #(
            ( request_id         = 'LOCATION-BAD-DATE'
              material           = 'MAT-1'
              plant              = '1000'
              required_date      = '20260230'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_bad_date_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_location_by_date_uom(
          it_demands = VALUE #(
            ( request_id         = 'LOCATION-DUPLICATE'
              material           = 'MAT-1'
              plant              = '1000'
              required_date      = '20261010'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' )
            ( request_id         = 'LOCATION-DUPLICATE'
              material           = 'MAT-1'
              plant              = '1000'
              required_date      = '20261011'
              requested_quantity = '1.000'
              requested_unit     = 'BOX' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_duplicate_ids_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_date_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_duplicate_ids_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).

    DATA(ls_result) = lo_cut->allocate_location_by_date_uom(
      it_demands = lt_demands ).
    DATA(ls_late_allocation) = ls_result-allocations[ 1 ].
    DATA(ls_early_low_allocation) = ls_result-allocations[ 2 ].
    DATA(ls_early_tie_allocation) = ls_result-allocations[ 3 ].
    DATA(ls_early_high_allocation) = ls_result-allocations[ 4 ].
    DATA(ls_first_storage_split) = ls_result-storage_allocations[ 1 ].
    DATA(ls_second_storage_split) = ls_result-storage_allocations[ 2 ].
    DATA(ls_third_storage_split) = ls_result-storage_allocations[ 3 ].

    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LOCATION-LATE'
      act = ls_late_allocation-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_late_allocation-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261020'
      act = ls_late_allocation-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 100
      act = ls_late_allocation-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LOCATION-EARLY-LOW'
      act = ls_early_low_allocation-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act =
        ls_early_low_allocation-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LOCATION-EARLY-TIE'
      act = ls_early_tie_allocation-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act =
        ls_early_tie_allocation-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LOCATION-EARLY-HIGH'
      act = ls_early_high_allocation-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = ls_early_high_allocation-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act =
        ls_early_high_allocation-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-storage_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LOCATION-EARLY-LOW'
      act =
        ls_first_storage_split-storage_split-storage_allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LOCATION-EARLY-TIE'
      act =
        ls_second_storage_split-storage_split-storage_allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LOCATION-EARLY-HIGH'
      act =
        ls_third_storage_split-storage_split-storage_allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD compares_dated_location_atp.
    DATA lv_early_date TYPE d.
    DATA lv_late_date TYPE d.
    lv_early_date = sy-datum + 1.
    lv_late_date = sy-datum + 2.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_stock( iv_quantity = '10.000' ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    lo_availability_api->set_result(
      is_result = VALUE #(
        available_at_plant_quantity = '10.000'
        confirmed_quantity          = '5.000'
        confirmation_lines          = VALUE #(
          ( confirmed_date     = lv_early_date
            confirmed_quantity = '2.000' )
          ( confirmed_date     = lv_late_date
            confirmed_quantity = '3.000' ) )
        is_fully_available          = abap_false
        is_check_relevant           = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).
    DATA(lt_demands) = VALUE zcl_stock_service=>ty_dated_unit_location_demands(
        ( request_id         = 'DATED-LOCATION-LATE'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = lv_late_date
          priority           = 100
          requested_quantity = '2.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'DATED-LOCATION-EARLY'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = lv_early_date
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) ).
    DATA lv_bad_rule_rejected TYPE abap_bool.

    TRY.
        lo_cut->allocate_location_date_uom_atp(
          it_demands    = lt_demands
          iv_check_rule = space ).
      CATCH zcx_invalid_stock_request.
        lv_bad_rule_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_rule_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_availability_api->get_check_count( ) ).

    DATA(ls_result) = lo_cut->allocate_location_date_uom_atp(
      it_demands    = lt_demands
      iv_check_rule = 'A' ).
    DATA(lt_atp_requests) = lo_availability_api->get_requests( ).
    DATA(ls_late_allocation) = ls_result-local_estimate-allocations[ 1 ].
    DATA(ls_early_allocation) = ls_result-local_estimate-allocations[ 2 ].

    cl_abap_unit_assert=>assert_equals(
      exp = 'DATED-LOCATION-LATE'
      act = ls_late_allocation-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_late_allocation-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_early_allocation-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_early_date
      act = ls_result-atp_checks[ 1 ]-check_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 1 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 1 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_late_date
      act = ls_result-atp_checks[ 2 ]-check_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-atp_checks[ 2 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-atp_checks[ 2 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-atp_checks[ 2 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-atp_checks[ 2 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_early_date
      act = lt_atp_requests[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_atp_requests[ 1 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_late_date
      act = lt_atp_requests[ 2 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = lt_atp_requests[ 2 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_availability_api->get_check_count( ) ).

    DATA(ls_short_result) = lo_cut->allocate_location_date_uom_atp(
      it_demands               = VALUE #(
        ( request_id         = 'DATED-LOCATION-SHORT'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = lv_late_date
          requested_quantity = '6.000'
          requested_unit     = 'BOX' ) )
      iv_check_rule            = 'A'
      iv_require_full_quantity = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_short_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_availability_api->get_check_count( ) ).
  ENDMETHOD.

  METHOD compares_dated_loc_base_atp.
    DATA lv_early_date TYPE d.
    DATA lv_late_date TYPE d.
    lv_early_date = sy-datum + 1.
    lv_late_date = sy-datum + 2.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '6.000' ) ) ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    lo_availability_api->set_result(
      is_result = VALUE #(
        available_at_plant_quantity = '6.000'
        confirmed_quantity          = '4.000'
        confirmation_lines          = VALUE #(
          ( confirmed_date     = lv_early_date
            confirmed_quantity = '2.000' )
          ( confirmed_date     = lv_late_date
            confirmed_quantity = '2.000' ) )
        is_fully_available          = abap_false
        is_check_relevant           = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_material_availability_api = lo_availability_api ).
    DATA(lt_demands) = VALUE zcl_stock_service=>ty_dated_location_demands(
      ( request_id         = 'BASE-LOCATION-EARLY-A'
        material           = 'MAT-1'
        plant              = '1000'
        required_date      = lv_early_date
        requested_quantity = '1.000'
        base_unit          = 'EA' )
      ( request_id         = 'BASE-LOCATION-EARLY-B'
        material           = 'MAT-1'
        plant              = '1000'
        required_date      = lv_early_date
        requested_quantity = '2.000'
        base_unit          = 'EA' )
      ( request_id         = 'BASE-LOCATION-LATE'
        material           = 'MAT-1'
        plant              = '1000'
        required_date      = lv_late_date
        requested_quantity = '3.000'
        base_unit          = 'EA' ) ).
    DATA lv_bad_rule_rejected TYPE abap_bool.
    DATA lv_missing_unit_rejected TYPE abap_bool.

    TRY.
        lo_cut->allocate_location_date_atp(
          it_demands    = lt_demands
          iv_check_rule = space ).
      CATCH zcx_invalid_stock_request.
        lv_bad_rule_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_location_date_atp(
          it_demands    = VALUE #(
            ( request_id         = 'BASE-LOCATION-NO-UNIT'
              material           = 'MAT-1'
              plant              = '1000'
              required_date      = lv_early_date
              requested_quantity = '1.000' ) )
          iv_check_rule = 'A' ).
      CATCH zcx_invalid_stock_request.
        lv_missing_unit_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_rule_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_missing_unit_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_availability_api->get_check_count( ) ).

    DATA(ls_result) = lo_cut->allocate_location_date_atp(
      it_demands    = lt_demands
      iv_check_rule = 'A' ).
    DATA(lt_atp_requests) = lo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-local_estimate-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_early_date
      act = ls_result-atp_checks[ 1 ]-check_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-atp_checks[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-atp_checks[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-atp_checks[ 1 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_late_date
      act = ls_result-atp_checks[ 2 ]-check_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-atp_checks[ 2 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-atp_checks[ 2 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-atp_checks[ 2 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 2 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_early_date
      act = lt_atp_requests[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_atp_requests[ 1 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_atp_requests[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_late_date
      act = lt_atp_requests[ 2 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = lt_atp_requests[ 2 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_availability_api->get_check_count( ) ).

    DATA(ls_receipt_result) = lo_cut->allocate_location_date_atp(
      it_demands            = VALUE #(
        ( request_id                  = 'BASE-LOCATION-RECEIPT'
          material                    = 'MAT-1'
          plant                       = '1000'
          required_date               = lv_late_date
          storage_location            = '0002'
          fallback_to_other_locations = abap_false
          requested_quantity          = '2.000'
          base_unit                   = 'EA' ) )
      it_projected_receipts = VALUE #(
        ( material         = 'MAT-1'
          plant            = '1000'
          storage_location = '0002'
          receipt_date     = lv_late_date
          base_quantity    = '2.000' ) )
      iv_check_rule         = 'A' ).
    DATA(lt_receipt_atp_requests) = lo_availability_api->get_requests( ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_receipt_result-local_estimate-allocations[
        1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_receipt_result-local_estimate-storage_allocations[
        1 ]-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_receipt_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_receipt_atp_requests[ 3 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lo_availability_api->get_check_count( ) ).
  ENDMETHOD.

  METHOD compares_location_atp.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    lo_repository->set_stock( iv_quantity = '10.000' ).
    DATA(lo_uom_repository) = NEW lcl_stock_uom_repo_double( ).
    lo_uom_repository->set_conversion(
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lo_availability_api) = NEW lcl_availability_api_double( ).
    lo_availability_api->set_result(
      is_result = VALUE #(
        available_at_plant_quantity = '10.000'
        confirmed_quantity          = '3.000'
        confirmation_lines          = VALUE #(
          ( confirmed_date     = sy-datum
            confirmed_quantity = '3.000' ) )
        is_fully_available          = abap_false
        is_check_relevant           = abap_true ) ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository          = lo_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).
    DATA(lt_demands) = VALUE zcl_stock_service=>ty_unit_location_demands(
      ( request_id         = 'LOCATION-ATP-1'
        material           = 'MAT-1'
        plant              = '1000'
        requested_quantity = '1.000'
        requested_unit     = 'BOX' )
      ( request_id         = 'LOCATION-ATP-2'
        material           = 'MAT-1'
        plant              = '1000'
        requested_quantity = '1.000'
        requested_unit     = 'BOX' ) ).
    DATA lv_bad_rule_rejected TYPE abap_bool.
    DATA lv_bad_date_rejected TYPE abap_bool.

    TRY.
        lo_cut->allocate_by_location_atp(
          it_demands    = lt_demands
          iv_check_rule = space ).
      CATCH zcx_invalid_stock_request.
        lv_bad_rule_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->allocate_by_location_atp(
          it_demands        = lt_demands
          iv_check_rule     = 'A'
          iv_atp_check_date = '20260230' ).
      CATCH zcx_invalid_stock_request.
        lv_bad_date_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_rule_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_date_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_uom_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_availability_api->get_check_count( ) ).

    DATA lv_check_date TYPE d.
    lv_check_date = sy-datum + 5.
    DATA(ls_result) = lo_cut->allocate_by_location_atp(
      it_demands        = lt_demands
      iv_check_rule     = 'A'
      iv_atp_check_date = lv_check_date ).
    DATA(ls_request) = lo_availability_api->get_request( ).
    DATA(ls_location_allocation) =
      ls_result-local_estimate-allocations[ 1 ].
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-local_estimate-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_location_allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_check_date
      act = ls_result-atp_checks[ 1 ]-check_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-atp_checks[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-atp_checks[ 1 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-atp_checks[ 1 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_request-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_request-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_check_date
      act = ls_request-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_availability_api->get_check_count( ) ).

    DATA(ls_today_result) = lo_cut->allocate_by_location_atp(
      it_demands    = lt_demands
      iv_check_rule = 'A' ).
    DATA(ls_today_request) = lo_availability_api->get_request( ).
    cl_abap_unit_assert=>assert_equals(
      exp = sy-datum
      act = ls_today_result-atp_checks[ 1 ]-check_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = sy-datum
      act = ls_today_request-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_availability_api->get_check_count( ) ).

    DATA(ls_short_result) = lo_cut->allocate_by_location_atp(
      it_demands               = VALUE #(
        ( request_id         = 'LOCATION-ATP-SHORT'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '6.000'
          requested_unit     = 'BOX' ) )
      iv_check_rule            = 'A'
      iv_require_full_quantity = abap_true ).
    DATA(ls_short_allocation) =
      ls_short_result-local_estimate-allocations[ 1 ].
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_short_allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_short_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_availability_api->get_check_count( ) ).
  ENDMETHOD.
ENDCLASS.
