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
    METHODS rejects_invalid_plant_sources FOR TESTING.
    METHODS allocates_plants_in_units FOR TESTING.
    METHODS rejects_unknown_plant_uom FOR TESTING.
    METHODS allocates_plants_by_expiry FOR TESTING.
    METHODS allocates_plants_fefo_by_date FOR TESTING.
    METHODS prioritizes_dated_fefo_locs FOR TESTING.
    METHODS rejects_bad_dated_fefo_prio FOR TESTING.
    METHODS protects_dated_fefo_buffer FOR TESTING.
    METHODS rejects_missing_fefo_date FOR TESTING.
    METHODS allocates_fefo_from_locations FOR TESTING.
    METHODS rejects_invalid_fefo_locations FOR TESTING.
    METHODS allocates_source_scoped_fefo FOR TESTING.
    METHODS rejects_bad_scoped_locations FOR TESTING.
    METHODS allocates_plants_fefo_date_uom FOR TESTING.
    METHODS rejects_missing_fefo_uom_date FOR TESTING.
    METHODS compares_dated_fefo_atp FOR TESTING.
    METHODS rejects_dated_fefo_atp_rule FOR TESTING.
    METHODS allocates_plants_fefo_units FOR TESTING.
    METHODS rejects_invalid_plant_fefo FOR TESTING.
    METHODS rejects_unknown_plant_fefo_uom FOR TESTING.
    METHODS rejects_invalid_fefo_plant_uom FOR TESTING.
    METHODS allocates_plants_by_batch FOR TESTING.
    METHODS allocates_dated_plant_batches FOR TESTING.
    METHODS rejects_batch_date FOR TESTING.
    METHODS allocates_dated_batch_uom FOR TESTING.
    METHODS rejects_batch_uom_date FOR TESTING.
    METHODS allocates_plants_batch_units FOR TESTING.
    METHODS protects_plant_batch_buffer FOR TESTING.
    METHODS rejects_unknown_batch_uom FOR TESTING.
    METHODS rejects_missing_plant_batch FOR TESTING.
    METHODS splits_allocations_by_location FOR TESTING.
    METHODS allocates_loc_priority FOR TESTING.
    METHODS allocates_allowed_locations FOR TESTING.
    METHODS rejects_bad_allowed_locations FOR TESTING.
    METHODS allocates_batch_fefo_allowlist FOR TESTING.
    METHODS rejects_bad_loc_priority FOR TESTING.
    METHODS allocates_location_units FOR TESTING.
    METHODS allocates_loc_uom_priority FOR TESTING.
    METHODS allocates_only_requested_batch FOR TESTING.
    METHODS allocates_batch_units FOR TESTING.
    METHODS splits_requested_batch FOR TESTING.
    METHODS prefers_batch_location_first FOR TESTING.
    METHODS allocates_batch_location_order FOR TESTING.
    METHODS rejects_missing_batch FOR TESTING.
    METHODS allocates_by_expiry_date FOR TESTING.
    METHODS allocates_fefo_units FOR TESTING.
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
      it_demands    = VALUE #(
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
      it_sources    = VALUE #(
        ( request_id = 'BATCH-BOX' source_plant = '2000' )
        ( request_id = 'BATCH-EA' source_plant = '2000' ) )
      iv_check_rule = 'A' ).
    DATA(lt_requests) = lo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-local_estimate-location_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-local_estimate-location_allocations[ 1 ]-allocation-batch ).
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
      it_demands    = VALUE #(
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
        ( request_id         = 'EARLY-HIGH'
          material           = 'MAT-1'
          target_plant       = '9000'
          required_date      = '20261201'
          priority           = 10
          batch              = 'B-1'
          requested_quantity = '2.000'
          requested_unit     = 'EA' ) )
      it_sources    = VALUE #(
        ( request_id = 'LATE-BOX' source_plant = '2000' )
        ( request_id = 'EARLY-LOW' source_plant = '2000' )
        ( request_id = 'EARLY-HIGH' source_plant = '2000' ) )
      iv_check_rule = 'A' ).
    DATA(lt_requests) = lo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-local_estimate-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY-HIGH'
      act = ls_result-local_estimate-allocations[ 3 ]-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-local_estimate-allocations[ 3 ]-allocation-batch ).
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
      exp = 'B-LATER'
      act = ls_result-batch_allocations[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '1.000' )
      act = ls_result-batch_allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
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
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
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
          requested_unit     = 'BOX' ) )
      it_sources                   = VALUE #(
        ( request_id = 'REQ-LATE' source_plant = '2000' )
        ( request_id = 'REQ-EARLY' source_plant = '2000' ) )
      iv_min_days                  = 5
      it_allowed_storage_locations = VALUE #(
        ( '0001' )
        ( '0002' )
        ( '0003' ) )
      it_source_locations          = VALUE #(
        ( request_id = 'REQ-LATE' source_plant = '2000'
          storage_location = '0002' )
        ( request_id = 'REQ-EARLY' source_plant = '2000'
          storage_location = '0001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
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
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
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
          requested_unit     = 'BOX' ) )
      it_sources                   = VALUE #(
        ( request_id = 'REQ-LATE' source_plant = '2000' )
        ( request_id = 'REQ-EARLY' source_plant = '2000' ) )
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
          storage_location = '0001' ) ) ).
    DATA(lt_requests) = lo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-LATE'
      act = ls_result-local_estimate-allocations[ 1 ]-allocation-request_id ).
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
    cl_abap_unit_assert=>assert_equals(
      exp = 2
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

    DATA(ls_fefo_result) = lo_cut->allocate_plants_by_expiry(
      it_demands               = VALUE #(
        ( request_id         = 'REQ-FEFO'
          material           = 'MAT-1'
          target_plant       = '9000'
          requested_quantity = '4.000' ) )
      it_sources               = VALUE #(
        ( request_id = 'REQ-FEFO' source_plant = '2000' ) )
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

    DATA(ls_fefo_result) = lo_cut->allocate_plants_fefo_in_units(
      it_demands               = VALUE #(
        ( request_id         = 'REQ-FEFO-UOM'
          material           = 'MAT-2'
          target_plant       = '9000'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' ) )
      it_sources               = VALUE #(
        ( request_id = 'REQ-FEFO-UOM' source_plant = '2000' ) )
      iv_as_of_date            = '20261001'
      iv_require_full_quantity = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_fefo_result-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_fefo_result-batch_allocations ) ).
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
ENDCLASS.
