CLASS lcl_prod_comp_repo DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_prod_comp_repo.
    METHODS set_components
      IMPORTING
        it_components TYPE zif_prod_comp_repo=>ty_reservation_items.
    METHODS get_read_count
      RETURNING
        VALUE(rv_count) TYPE i.
  PRIVATE SECTION.
    DATA mt_components TYPE zif_prod_comp_repo=>ty_reservation_items.
    DATA mv_read_count TYPE i.
ENDCLASS.

CLASS lcl_prod_comp_repo IMPLEMENTATION.
  METHOD set_components.
    mt_components = it_components.
  ENDMETHOD.

  METHOD get_read_count.
    rv_count = mv_read_count.
  ENDMETHOD.

  METHOD zif_prod_comp_repo~get_components.
    DATA lt_production_orders TYPE zif_prod_comp_repo=>ty_production_orders.

    APPEND iv_production_order TO lt_production_orders.
    rt_items = zif_prod_comp_repo~get_components_bulk(
      it_production_orders = lt_production_orders ).
  ENDMETHOD.

  METHOD zif_prod_comp_repo~get_components_bulk.
    ADD 1 TO mv_read_count.
    LOOP AT mt_components INTO DATA(ls_component).
      READ TABLE it_production_orders WITH KEY
        table_line = ls_component-production_order
        TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        APPEND ls_component TO rt_items.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_prod_repl_policy_repo DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_replenishment_policy_repo.
    METHODS set_policies
      IMPORTING
        it_policies TYPE zif_replenishment_policy_repo=>ty_policies.
    METHODS set_rounding_profiles
      IMPORTING
        it_profiles TYPE
          zif_replenishment_policy_repo=>ty_rounding_profiles.
    METHODS get_read_count
      RETURNING
        VALUE(rv_count) TYPE i.
  PRIVATE SECTION.
    DATA mt_policies TYPE zif_replenishment_policy_repo=>ty_policies.
    DATA mt_rounding_profiles TYPE
      zif_replenishment_policy_repo=>ty_rounding_profiles.
    DATA mv_read_count TYPE i.
ENDCLASS.

CLASS lcl_prod_repl_policy_repo IMPLEMENTATION.
  METHOD set_policies.
    mt_policies = it_policies.
  ENDMETHOD.

  METHOD set_rounding_profiles.
    mt_rounding_profiles = it_profiles.
  ENDMETHOD.

  METHOD get_read_count.
    rv_count = mv_read_count.
  ENDMETHOD.

  METHOD zif_replenishment_policy_repo~get_policies_bulk.
    ADD 1 TO mv_read_count.
    LOOP AT mt_policies INTO DATA(ls_policy).
      READ TABLE it_material_plants TRANSPORTING NO FIELDS
        WITH KEY material = ls_policy-material
                 plant = ls_policy-plant.
      IF sy-subrc = 0.
        APPEND ls_policy TO rt_policies.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_replenishment_policy_repo~get_rounding_profiles_bulk.
    LOOP AT mt_rounding_profiles INTO DATA(ls_profile).
      READ TABLE it_profile_keys TRANSPORTING NO FIELDS
        WITH TABLE KEY plant = ls_profile-plant
                       rounding_profile = ls_profile-rounding_profile.
      IF sy-subrc = 0.
        APPEND ls_profile TO rt_profiles.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_prod_cal_period_repo DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_planning_calendar_repo.
    METHODS set_periods
      IMPORTING
        it_periods TYPE zif_planning_calendar_repo=>ty_periods.
    METHODS get_read_count
      RETURNING
        VALUE(rv_count) TYPE i.
  PRIVATE SECTION.
    DATA mt_periods TYPE zif_planning_calendar_repo=>ty_periods.
    DATA mv_read_count TYPE i.
ENDCLASS.

CLASS lcl_prod_cal_period_repo IMPLEMENTATION.
  METHOD set_periods.
    mt_periods = it_periods.
  ENDMETHOD.

  METHOD get_read_count.
    rv_count = mv_read_count.
  ENDMETHOD.

  METHOD zif_planning_calendar_repo~get_periods_bulk.
    ADD 1 TO mv_read_count.
    LOOP AT mt_periods INTO DATA(ls_period).
      LOOP AT it_requests INTO DATA(ls_request)
          WHERE plant = ls_period-plant
            AND planning_calendar_id = ls_period-planning_calendar_id
            AND from_date <= ls_period-end_date
            AND through_date >= ls_period-start_date.
        APPEND CORRESPONDING #( ls_period ) TO rt_periods.
        EXIT.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lcl_prod_repl_calendar DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_factory_calendar_api.
    TYPES ty_dates TYPE SORTED TABLE OF d WITH UNIQUE KEY table_line.
    METHODS set_working_dates
      IMPORTING
        it_dates TYPE ty_dates.
    METHODS get_call_count
      RETURNING
        VALUE(rv_count) TYPE i.
  PRIVATE SECTION.
    DATA mt_dates TYPE ty_dates.
    DATA mv_call_count TYPE i.
ENDCLASS.

CLASS lcl_prod_repl_calendar IMPLEMENTATION.
  METHOD set_working_dates.
    mt_dates = it_dates.
  ENDMETHOD.

  METHOD get_call_count.
    rv_count = mv_call_count.
  ENDMETHOD.

  METHOD zif_factory_calendar_api~subtract_workdays.
    ADD 1 TO mv_call_count.
    IF iv_date IS INITIAL
        OR iv_factory_calendar_id IS INITIAL
        OR iv_workdays < 0.
      RETURN.
    ENDIF.

    DATA(lv_candidate_date) = iv_date.
    DATA lv_found_date TYPE abap_bool.
    LOOP AT mt_dates INTO DATA(lv_working_date)
        WHERE table_line <= iv_date.
      lv_candidate_date = lv_working_date.
      lv_found_date = abap_true.
    ENDLOOP.
    IF lv_found_date <> abap_true.
      RETURN.
    ENDIF.

    DATA(lv_days_remaining) = iv_workdays.
    WHILE lv_days_remaining > 0.
      lv_candidate_date = lv_candidate_date - 1.
      READ TABLE mt_dates TRANSPORTING NO FIELDS
        WITH TABLE KEY table_line = lv_candidate_date.
      IF sy-subrc = 0.
        SUBTRACT 1 FROM lv_days_remaining.
      ENDIF.
    ENDWHILE.

    rs_result-date = lv_candidate_date.
    rs_result-is_successful = abap_true.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_prod_uom_repository DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_material_uom_repository.
    METHODS set_units
      IMPORTING
        iv_material         TYPE mard-matnr
        iv_base_unit        TYPE mara-meins
        iv_alternative_unit TYPE mara-meins
        iv_numerator        TYPE marm-umrez
        iv_denominator      TYPE marm-umren.
  PRIVATE SECTION.
    DATA mv_material TYPE mard-matnr.
    DATA mv_base_unit TYPE mara-meins.
    DATA mv_alternative_unit TYPE mara-meins.
    DATA mv_numerator TYPE marm-umrez.
    DATA mv_denominator TYPE marm-umren.
ENDCLASS.

CLASS lcl_prod_uom_repository IMPLEMENTATION.
  METHOD set_units.
    mv_material = iv_material.
    mv_base_unit = iv_base_unit.
    mv_alternative_unit = iv_alternative_unit.
    mv_numerator = iv_numerator.
    mv_denominator = iv_denominator.
  ENDMETHOD.

  METHOD zif_material_uom_repository~get_base_unit.
    IF iv_material = mv_material.
      rv_base_unit = mv_base_unit.
    ENDIF.
  ENDMETHOD.

  METHOD zif_material_uom_repository~get_alt_unit_ratio.
    IF iv_material = mv_material
        AND iv_alternative_unit = mv_alternative_unit.
      rs_ratio-numerator = mv_numerator.
      rs_ratio-denominator = mv_denominator.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_prod_availability_api DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_material_availability_api.
    TYPES ty_requests TYPE STANDARD TABLE OF
      zif_material_availability_api=>ty_request WITH EMPTY KEY.
    METHODS get_requests
      RETURNING
        VALUE(rt_requests) TYPE ty_requests.
  PRIVATE SECTION.
    DATA mt_requests TYPE ty_requests.
ENDCLASS.

CLASS lcl_prod_availability_api IMPLEMENTATION.
  METHOD get_requests.
    rt_requests = mt_requests.
  ENDMETHOD.

  METHOD zif_material_availability_api~check_availability.
    APPEND is_request TO mt_requests.
    DATA(lv_confirmed_quantity) = COND mard-labst(
      WHEN is_request-required_date = '20261015' THEN '7.000'
      ELSE '5.000' ).
    DATA lt_confirmation_lines TYPE
      zif_material_availability_api=>ty_confirmation_lines.
    IF is_request-required_date = '20261015'.
      lt_confirmation_lines = VALUE #(
        ( confirmed_date = '20261005' confirmed_quantity = '4.000' )
        ( confirmed_date = '20261010' confirmed_quantity = '1.000' )
        ( confirmed_date = '20261015' confirmed_quantity = '2.000' ) ).
    ELSE.
      lt_confirmation_lines = VALUE #(
        ( confirmed_date = '20261005' confirmed_quantity = '4.000' )
        ( confirmed_date = '20261010' confirmed_quantity = '1.000' ) ).
    ENDIF.
    rs_result = VALUE #(
      material           = is_request-material
      plant              = is_request-plant
      unit               = is_request-unit
      check_rule         = is_request-check_rule
      required_date      = is_request-required_date
      requested_quantity = is_request-requested_quantity
      confirmed_quantity = lv_confirmed_quantity
      confirmation_lines = lt_confirmation_lines
      is_fully_available = abap_false
      is_check_relevant  = abap_true ).
  ENDMETHOD.
ENDCLASS.

CLASS lcl_prod_stock_repository DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_repository.
    METHODS set_projected_receipts
      IMPORTING
        it_receipts TYPE zif_stock_repository=>ty_projected_receipts.
    METHODS set_date_stock
      IMPORTING
        iv_date                     TYPE resb-bdter
        iv_quantity                 TYPE mard-labst
        iv_receipt_quantity         TYPE mard-labst DEFAULT 0
        iv_sto_in_transit_quantity  TYPE mard-labst DEFAULT 0
        iv_unissued_sto_quantity    TYPE mard-labst DEFAULT 0
        iv_outgoing_sto_quantity    TYPE mard-labst DEFAULT 0
        iv_prod_receipt_quantity    TYPE mard-labst DEFAULT 0
        iv_pr_receipt_quantity      TYPE mard-labst DEFAULT 0
        iv_sto_pr_receipt_quantity  TYPE mard-labst DEFAULT 0
        iv_planned_receipt_quantity TYPE mard-labst DEFAULT 0
        iv_fixed_plan_receipt_qty   TYPE mard-labst DEFAULT 0.
    METHODS set_safety_stock
      IMPORTING
        iv_quantity TYPE marc-eisbe.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_date_stock,
        required_date            TYPE resb-bdter,
        quantity                 TYPE mard-labst,
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
    DATA mt_date_stocks TYPE ty_date_stocks.
    DATA mt_projected_receipts TYPE
      zif_stock_repository=>ty_projected_receipts.
    DATA mv_safety_stock TYPE marc-eisbe.
ENDCLASS.

CLASS lcl_prod_stock_repository IMPLEMENTATION.
  METHOD set_projected_receipts.
    mt_projected_receipts = it_receipts.
  ENDMETHOD.

  METHOD set_date_stock.
    DELETE mt_date_stocks WHERE required_date = iv_date.
    APPEND VALUE #(
      required_date            = iv_date
      quantity                 = iv_quantity
      receipt_quantity         = iv_receipt_quantity
      sto_in_transit_quantity  = iv_sto_in_transit_quantity
      unissued_sto_quantity    = iv_unissued_sto_quantity
      outgoing_sto_quantity    = iv_outgoing_sto_quantity
      prod_receipt_quantity    = iv_prod_receipt_quantity
      pr_receipt_quantity      = iv_pr_receipt_quantity
      sto_pr_receipt_quantity  = iv_sto_pr_receipt_quantity
      planned_receipt_quantity = iv_planned_receipt_quantity
      fixed_plan_receipt_qty   = iv_fixed_plan_receipt_qty )
      TO mt_date_stocks.
  ENDMETHOD.

  METHOD set_safety_stock.
    mv_safety_stock = iv_quantity.
  ENDMETHOD.

  METHOD zif_stock_repository~get_unrestricted_stock.
  ENDMETHOD.

  METHOD zif_stock_repository~get_available_stock_by_date.
    READ TABLE mt_date_stocks INTO DATA(ls_date_stock)
      WITH KEY required_date = iv_required_date.
    IF sy-subrc = 0.
      rv_quantity = ls_date_stock-quantity.
      IF iv_include_po_receipts = abap_true.
        rv_quantity = rv_quantity + ls_date_stock-receipt_quantity.
      ENDIF.
      IF iv_include_sto_in_transit = abap_true.
        rv_quantity = rv_quantity
          + ls_date_stock-sto_in_transit_quantity.
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
      IF iv_include_fixed_planned = abap_true.
        rv_quantity = rv_quantity + ls_date_stock-fixed_plan_receipt_qty.
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
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_repository~get_projected_receipts.
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
        WHEN 'PRODUCTION'.
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
          IF iv_include_fixed_planned = abap_true.
            APPEND ls_receipt TO rt_receipts.
          ENDIF.
        WHEN 'SCHED_AGREEMENT'.
          IF iv_include_sched_agmt_receipts = abap_true.
            APPEND ls_receipt TO rt_receipts.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_safety_stock.
    rv_quantity = mv_safety_stock.
  ENDMETHOD.

  METHOD zif_stock_repository~get_sales_order_reservations.
  ENDMETHOD.

  METHOD zif_stock_repository~get_order_reservations_bulk.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status_by_location.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status_by_batch.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_by_location.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_by_batch.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_prod_reservation_reader DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_so_reservation_reader.
    METHODS set_result
      IMPORTING
        is_result TYPE zif_so_reservation_reader=>ty_result.
    METHODS get_read_count
      RETURNING
        VALUE(rv_count) TYPE i.
  PRIVATE SECTION.
    DATA ms_result TYPE zif_so_reservation_reader=>ty_result.
    DATA mv_read_count TYPE i.
ENDCLASS.

CLASS lcl_prod_reservation_reader IMPLEMENTATION.
  METHOD set_result.
    ms_result = is_result.
  ENDMETHOD.

  METHOD get_read_count.
    rv_count = mv_read_count.
  ENDMETHOD.

  METHOD zif_so_reservation_reader~read_reservation.
    ADD 1 TO mv_read_count.
    rs_result-is_successful = ms_result-is_successful.
    rs_result-messages = ms_result-messages.
    LOOP AT ms_result-items INTO DATA(ls_item)
        WHERE reservation_number = iv_reservation_number.
      APPEND ls_item TO rs_result-items.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_prod_goods_movement_api DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_goods_movement_api.
    METHODS get_items
      RETURNING
        VALUE(rt_items) TYPE zif_goods_movement_api=>ty_items.
    METHODS get_gm_code
      RETURNING
        VALUE(rv_gm_code) TYPE zif_goods_movement_api=>ty_gm_code.
    METHODS get_create_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_commit_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_cancel_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_last_cancel_document
      RETURNING
        VALUE(rv_document) TYPE zif_goods_movement_api=>ty_material_document.
    METHODS get_last_cancel_year
      RETURNING
        VALUE(rv_year) TYPE zif_goods_movement_api=>ty_fiscal_year.
    METHODS get_last_cancel_posting_date
      RETURNING
        VALUE(rv_posting_date) TYPE d.
    METHODS get_last_cancel_items
      RETURNING
        VALUE(rt_item_numbers) TYPE zif_goods_movement_api=>ty_material_document_items.
  PRIVATE SECTION.
    DATA mt_items TYPE zif_goods_movement_api=>ty_items.
    DATA mv_gm_code TYPE zif_goods_movement_api=>ty_gm_code.
    DATA mv_create_count TYPE i.
    DATA mv_commit_count TYPE i.
    DATA mv_cancel_count TYPE i.
    DATA mv_cancel_document TYPE zif_goods_movement_api=>ty_material_document.
    DATA mv_cancel_year TYPE zif_goods_movement_api=>ty_fiscal_year.
    DATA mv_cancel_posting_date TYPE d.
    DATA mt_cancel_item_numbers TYPE
      zif_goods_movement_api=>ty_material_document_items.
ENDCLASS.

CLASS lcl_prod_goods_movement_api IMPLEMENTATION.
  METHOD get_items.
    rt_items = mt_items.
  ENDMETHOD.

  METHOD get_gm_code.
    rv_gm_code = mv_gm_code.
  ENDMETHOD.

  METHOD get_create_count.
    rv_count = mv_create_count.
  ENDMETHOD.

  METHOD get_commit_count.
    rv_count = mv_commit_count.
  ENDMETHOD.

  METHOD get_cancel_count.
    rv_count = mv_cancel_count.
  ENDMETHOD.

  METHOD get_last_cancel_document.
    rv_document = mv_cancel_document.
  ENDMETHOD.

  METHOD get_last_cancel_year.
    rv_year = mv_cancel_year.
  ENDMETHOD.

  METHOD get_last_cancel_posting_date.
    rv_posting_date = mv_cancel_posting_date.
  ENDMETHOD.

  METHOD get_last_cancel_items.
    rt_item_numbers = mt_cancel_item_numbers.
  ENDMETHOD.

  METHOD zif_goods_movement_api~create_movement.
    ADD 1 TO mv_create_count.
    mt_items = it_items.
    mv_gm_code = iv_gm_code.
    rs_result = VALUE #(
      material_document = '4900000001'
      fiscal_year       = '2026'
      is_successful     = abap_true ).
  ENDMETHOD.

  METHOD zif_goods_movement_api~cancel_movement.
    ADD 1 TO mv_cancel_count.
    mv_cancel_document = iv_material_document.
    mv_cancel_year = iv_fiscal_year.
    mv_cancel_posting_date = iv_posting_date.
    mt_cancel_item_numbers = it_item_numbers.
    rs_result = VALUE #(
      material_document = '4900000002'
      fiscal_year       = '2026'
      is_successful     = abap_true ).
  ENDMETHOD.

  METHOD zif_goods_movement_api~commit.
    ADD 1 TO mv_commit_count.
    rs_result-is_successful = abap_true.
  ENDMETHOD.

  METHOD zif_goods_movement_api~rollback.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_prod_comp_service DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS reads_open_components FOR TESTING.
    METHODS rejects_blank_order FOR TESTING.
    METHODS issues_selected_components FOR TESTING.
    METHODS returns_selected_component FOR TESTING.
    METHODS returns_components_bulk FOR TESTING.
    METHODS rejects_return_over_withdrawn FOR TESTING.
    METHODS cancels_component_issue FOR TESTING.
    METHODS rejects_unassigned_item FOR TESTING.
    METHODS rejects_component_over_issue FOR TESTING.
    METHODS reads_bulk_components FOR TESTING.
    METHODS issues_bulk_components FOR TESTING.
    METHODS rejects_invalid_bulk_orders FOR TESTING.
    METHODS previews_components_atp FOR TESTING.
    METHODS previews_order_components_atp FOR TESTING.
    METHODS previews_components_stock FOR TESTING.
    METHODS rejects_component_atp_rule FOR TESTING.
    METHODS rejects_component_atp_date FOR TESTING.
    METHODS summarizes_component_readiness FOR TESTING.
    METHODS summarizes_component_shortages FOR TESTING.
    METHODS summarizes_order_atp FOR TESTING.
    METHODS suggests_comp_replenishment FOR TESTING.
    METHODS rounds_replenishment_profile FOR TESTING.
    METHODS rejects_missing_profile_levels FOR TESTING.
    METHODS rejects_rounding_over_max_lot FOR TESTING.
    METHODS groups_monthly_lot_size FOR TESTING.
    METHODS groups_weekly_lot_size FOR TESTING.
    METHODS groups_pk_lot_size FOR TESTING.
    METHODS suggests_max_stock_replen FOR TESTING.
    METHODS categorizes_repl_urgency FOR TESTING.
    METHODS suggests_comp_repl_from_stock FOR TESTING.
    METHODS nets_prior_surplus FOR TESTING.
    METHODS nets_projected_receipts FOR TESTING.
    METHODS rejects_bad_replenishment FOR TESTING.
    METHODS rejects_bad_readiness FOR TESTING.
ENDCLASS.

CLASS ltcl_prod_comp_service IMPLEMENTATION.
  METHOD reads_open_components.
    DATA(lo_repository) = NEW lcl_prod_comp_repo( ).
    lo_repository->set_components(
      it_components = VALUE #(
        ( production_order   = '0000004711'
          reservation_number = '0000001234'
          reservation_item   = '0030'
          material           = 'MAT-2'
          plant              = '1000'
          movement_type      = '261'
          required_quantity  = '5.000'
          withdrawn_quantity = '1.000'
          unit               = 'EA' )
        ( production_order   = '0000004711'
          reservation_number = '0000001234'
          reservation_item   = '0020'
          material           = 'MAT-1'
          plant              = '1000'
          required_quantity  = '4.000'
          withdrawn_quantity = '4.000'
          unit               = 'EA' )
        ( production_order   = '0000004711'
          reservation_number = '0000001234'
          reservation_item   = '0010'
          material           = 'MAT-1'
          plant              = '1000'
          storage_location   = '0001'
          batch              = 'BATCH-1'
          movement_type      = '261'
          required_date      = '20261001'
          required_quantity  = '10.000'
          withdrawn_quantity = '3.000'
          unit               = 'EA' )
        ( production_order   = '0000004711'
          reservation_number = '0000001234'
          reservation_item   = '0040'
          material           = 'MAT-3'
          plant              = '1000'
          required_quantity  = '8.000'
          withdrawn_quantity = '2.000'
          is_deleted         = 'X'
          unit               = 'EA' )
        ( production_order   = '0000004711'
          reservation_number = '0000001234'
          reservation_item   = '0050'
          material           = 'MAT-4'
          plant              = '1000'
          required_quantity  = '8.000'
          withdrawn_quantity = '2.000'
          is_final_issue     = 'X'
          unit               = 'EA' )
        ( production_order   = '0000009999'
          reservation_number = '0000001234'
          reservation_item   = '0060'
          material           = 'MAT-5'
          plant              = '1000'
          required_quantity  = '8.000'
          withdrawn_quantity = '2.000'
          unit               = 'EA' )
        ( production_order   = '0000004711'
          reservation_number = '0000001234'
          reservation_item   = '0070'
          material           = 'MAT-6'
          plant              = '1000'
          required_quantity  = '2.000'
          withdrawn_quantity = '3.000'
          unit               = 'EA' ) ) ).
    DATA(lo_cut) = NEW zcl_prod_comp_service(
      io_repository = lo_repository ).

    DATA(lt_components) = lo_cut->get_open_components(
      iv_production_order = '0000004711' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_components ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0010'
      act = lt_components[ 1 ]-reservation_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MAT-1'
      act = lt_components[ 1 ]-material ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_components[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BATCH-1'
      act = lt_components[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '10.000' )
      act = lt_components[ 1 ]-required_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-enmng( '3.000' )
      act = lt_components[ 1 ]-withdrawn_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '7.000' )
      act = lt_components[ 1 ]-open_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0030'
      act = lt_components[ 2 ]-reservation_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '4.000' )
      act = lt_components[ 2 ]-open_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_blank_order.
    DATA(lo_repository) = NEW lcl_prod_comp_repo( ).
    DATA(lo_cut) = NEW zcl_prod_comp_service(
      io_repository = lo_repository ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->get_open_components( iv_production_order = space ).
      CATCH zcx_invalid_production_order.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD issues_selected_components.
    DATA(lo_repository) = NEW lcl_prod_comp_repo( ).
    lo_repository->set_components(
      it_components = VALUE #(
        ( production_order   = '0000004711'
          reservation_number = '0000001234'
          reservation_item   = '0010'
          material           = 'MAT-1'
          plant              = '1000'
          storage_location   = '0001'
          movement_type      = '261'
          required_quantity  = '10.000'
          withdrawn_quantity = '2.000'
          unit               = 'EA' ) ) ).
    DATA(lo_reader) = NEW lcl_prod_reservation_reader( ).
    lo_reader->set_result(
      is_result = VALUE #(
        is_successful = abap_true
        items         = VALUE #(
          ( reservation_number = '0000001234'
            item_number        = '0010'
            record_type        = '1'
            movement_allowed   = abap_true
            material           = 'MAT-1'
            plant              = '1000'
            storage_location   = '0001'
            required_quantity  = '10.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA'
            withdrawn_quantity = '2.000' ) ) ) ).
    DATA(lo_api) = NEW lcl_prod_goods_movement_api( ).
    DATA(lo_cut) = NEW zcl_prod_comp_service(
      io_repository         = lo_repository
      io_reservation_reader = lo_reader
      io_goods_movement_api = lo_api ).

    DATA(ls_result) = lo_cut->issue_components(
      iv_production_order = '0000004711'
      is_header           = VALUE #(
        posting_date  = '20261001'
        document_date = '20261001' )
      it_requests         = VALUE #(
        ( reservation_number = '0000001234'
          reservation_item   = '0010'
          quantity           = '4.000' ) ) ).
    DATA(lt_items) = lo_api->get_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '03'
      act = lo_api->get_gm_code( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001234'
      act = lt_items[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0010'
      act = lt_items[ 1 ]-reservation_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = space
      act = lt_items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_reader->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD returns_selected_component.
    DATA(lo_repository) = NEW lcl_prod_comp_repo( ).
    lo_repository->set_components(
      it_components = VALUE #(
        ( production_order   = '0000004711'
          reservation_number = '0000001234'
          reservation_item   = '0010'
          movement_type      = '261'
          required_quantity  = '10.000'
          withdrawn_quantity = '2.000'
          is_final_issue     = 'X'
          unit               = 'EA' ) ) ).
    DATA(lo_reader) = NEW lcl_prod_reservation_reader( ).
    lo_reader->set_result(
      is_result = VALUE #(
        is_successful = abap_true
        items         = VALUE #(
          ( reservation_number = '0000001234'
            item_number        = '0010'
            record_type        = '1'
            movement_allowed   = abap_false
            is_final_issue     = abap_true
            required_quantity  = '10.000'
            withdrawn_quantity = '2.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' ) ) ) ).
    DATA(lo_api) = NEW lcl_prod_goods_movement_api( ).
    DATA(lo_cut) = NEW zcl_prod_comp_service(
      io_repository         = lo_repository
      io_reservation_reader = lo_reader
      io_goods_movement_api = lo_api ).

    DATA(ls_result) = lo_cut->return_components(
      iv_production_order = '0000004711'
      is_header           = VALUE #(
        posting_date  = '20261002'
        document_date = '20261002' )
      it_requests         = VALUE #(
        ( reservation_number = '0000001234'
          reservation_item   = '0010'
          quantity           = '1.250'
          storage_location   = '0002' ) ) ).
    DATA(lt_items) = lo_api->get_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '06'
      act = lo_api->get_gm_code( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_items[ 1 ]-is_reversal ).
    cl_abap_unit_assert=>assert_initial(
      lt_items[ 1 ]-movement_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001234'
      act = lt_items[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.250' )
      act = lt_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD returns_components_bulk.
    DATA(lo_repository) = NEW lcl_prod_comp_repo( ).
    lo_repository->set_components(
      it_components = VALUE #(
        ( production_order   = '0000004711'
          reservation_number = '0000001234'
          reservation_item   = '0010'
          movement_type      = '261'
          required_quantity  = '10.000'
          withdrawn_quantity = '2.000'
          unit               = 'EA' )
        ( production_order   = '0000004712'
          reservation_number = '0000005678'
          reservation_item   = '0020'
          movement_type      = '261'
          required_quantity  = '8.000'
          withdrawn_quantity = '3.000'
          unit               = 'EA' ) ) ).
    DATA(lo_reader) = NEW lcl_prod_reservation_reader( ).
    lo_reader->set_result(
      is_result = VALUE #(
        is_successful = abap_true
        items         = VALUE #(
          ( reservation_number = '0000001234'
            item_number        = '0010'
            record_type        = '1'
            withdrawn_quantity = '2.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' )
          ( reservation_number = '0000005678'
            item_number        = '0020'
            record_type        = '1'
            withdrawn_quantity = '3.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' ) ) ) ).
    DATA(lo_api) = NEW lcl_prod_goods_movement_api( ).
    DATA(lo_cut) = NEW zcl_prod_comp_service(
      io_repository         = lo_repository
      io_reservation_reader = lo_reader
      io_goods_movement_api = lo_api ).

    DATA(ls_result) = lo_cut->return_components_bulk(
      is_header   = VALUE #(
        posting_date  = '20261002'
        document_date = '20261002' )
      it_requests = VALUE #(
        ( production_order   = '0000004711'
          reservation_number = '0000001234'
          reservation_item   = '0010'
          quantity           = '1.000' )
        ( production_order   = '0000004712'
          reservation_number = '0000005678'
          reservation_item   = '0020'
          quantity           = '1.500' ) ) ).
    DATA(lt_items) = lo_api->get_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '06'
      act = lo_api->get_gm_code( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001234'
      act = lt_items[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000005678'
      act = lt_items[ 2 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_reader->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_return_over_withdrawn.
    DATA(lo_repository) = NEW lcl_prod_comp_repo( ).
    lo_repository->set_components(
      it_components = VALUE #(
        ( production_order   = '0000004711'
          reservation_number = '0000001234'
          reservation_item   = '0010'
          movement_type      = '261'
          required_quantity  = '10.000'
          withdrawn_quantity = '2.000'
          unit               = 'EA' ) ) ).
    DATA(lo_reader) = NEW lcl_prod_reservation_reader( ).
    DATA(lo_api) = NEW lcl_prod_goods_movement_api( ).
    DATA(lo_cut) = NEW zcl_prod_comp_service(
      io_repository         = lo_repository
      io_reservation_reader = lo_reader
      io_goods_movement_api = lo_api ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->return_components(
          iv_production_order = '0000004711'
          is_header           = VALUE #(
            posting_date  = '20261002'
            document_date = '20261002' )
          it_requests         = VALUE #(
            ( reservation_number = '0000001234'
              reservation_item   = '0010'
              quantity           = '2.001' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_reader->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD cancels_component_issue.
    DATA(lo_api) = NEW lcl_prod_goods_movement_api( ).
    DATA(lo_cut) = NEW zcl_prod_comp_service(
      io_goods_movement_api = lo_api ).
    DATA lt_item_numbers TYPE
      zif_goods_movement_api=>ty_material_document_items.
    APPEND '0001' TO lt_item_numbers.
    APPEND '0002' TO lt_item_numbers.

    DATA(ls_result) = lo_cut->cancel_component_issue(
      iv_material_document = '4900000001'
      iv_fiscal_year       = '2026'
      iv_posting_date      = '20261002'
      it_item_numbers      = lt_item_numbers ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4900000001'
      act = lo_api->get_last_cancel_document( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2026'
      act = lo_api->get_last_cancel_year( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261002'
      act = lo_api->get_last_cancel_posting_date( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lo_api->get_last_cancel_items( ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_cancel_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_unassigned_item.
    DATA(lo_repository) = NEW lcl_prod_comp_repo( ).
    lo_repository->set_components(
      it_components = VALUE #(
        ( production_order   = '0000004711'
          reservation_number = '0000001234'
          reservation_item   = '0010'
          required_quantity  = '10.000'
          withdrawn_quantity = '2.000' ) ) ).
    DATA(lo_reader) = NEW lcl_prod_reservation_reader( ).
    DATA(lo_api) = NEW lcl_prod_goods_movement_api( ).
    DATA(lo_cut) = NEW zcl_prod_comp_service(
      io_repository         = lo_repository
      io_reservation_reader = lo_reader
      io_goods_movement_api = lo_api ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->issue_components(
          iv_production_order = '0000004711'
          is_header           = VALUE #(
            posting_date  = '20261001'
            document_date = '20261001' )
          it_requests         = VALUE #(
            ( reservation_number = '0000001234'
              reservation_item   = '0099'
              quantity           = '1.000' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_reader->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_component_over_issue.
    DATA(lo_repository) = NEW lcl_prod_comp_repo( ).
    lo_repository->set_components(
      it_components = VALUE #(
        ( production_order   = '0000004711'
          reservation_number = '0000001234'
          reservation_item   = '0010'
          required_quantity  = '10.000'
          withdrawn_quantity = '2.000' ) ) ).
    DATA(lo_reader) = NEW lcl_prod_reservation_reader( ).
    DATA(lo_api) = NEW lcl_prod_goods_movement_api( ).
    DATA(lo_cut) = NEW zcl_prod_comp_service(
      io_repository         = lo_repository
      io_reservation_reader = lo_reader
      io_goods_movement_api = lo_api ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->issue_components(
          iv_production_order = '0000004711'
          is_header           = VALUE #(
            posting_date  = '20261001'
            document_date = '20261001' )
          it_requests         = VALUE #(
            ( reservation_number = '0000001234'
              reservation_item   = '0010'
              quantity           = '9.000' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_reader->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD reads_bulk_components.
    DATA(lo_repository) = NEW lcl_prod_comp_repo( ).
    lo_repository->set_components(
      it_components = VALUE #(
        ( production_order   = '0000004711'
          reservation_number = '0000001234'
          reservation_item   = '0010'
          material           = 'MAT-1'
          required_quantity  = '5.000'
          withdrawn_quantity = '1.000'
          unit               = 'EA' )
        ( production_order   = '0000004712'
          reservation_number = '0000005678'
          reservation_item   = '0020'
          material           = 'MAT-2'
          required_quantity  = '8.000'
          withdrawn_quantity = '2.000'
          unit               = 'EA' ) ) ).
    DATA(lo_cut) = NEW zcl_prod_comp_service(
      io_repository = lo_repository ).

    DATA(lt_components) = lo_cut->get_open_components_bulk(
      VALUE #( ( '0000004712' ) ( '0000004711' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_components ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711'
      act = lt_components[ 1 ]-production_order ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004712'
      act = lt_components[ 2 ]-production_order ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '6.000' )
      act = lt_components[ 2 ]-open_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD issues_bulk_components.
    DATA(lo_repository) = NEW lcl_prod_comp_repo( ).
    lo_repository->set_components(
      it_components = VALUE #(
        ( production_order   = '0000004711'
          reservation_number = '0000001234'
          reservation_item   = '0010'
          material           = 'MAT-1'
          plant              = '1000'
          required_quantity  = '10.000'
          withdrawn_quantity = '2.000'
          unit               = 'EA' )
        ( production_order   = '0000004712'
          reservation_number = '0000005678'
          reservation_item   = '0020'
          material           = 'MAT-2'
          plant              = '1000'
          required_quantity  = '8.000'
          withdrawn_quantity = '1.000'
          unit               = 'EA' ) ) ).
    DATA(lo_reader) = NEW lcl_prod_reservation_reader( ).
    lo_reader->set_result(
      is_result = VALUE #(
        is_successful = abap_true
        items         = VALUE #(
          ( reservation_number = '0000001234'
            item_number        = '0010'
            record_type        = '1'
            movement_allowed   = abap_true
            material           = 'MAT-1'
            plant              = '1000'
            required_quantity  = '10.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA'
            withdrawn_quantity = '2.000' )
          ( reservation_number = '0000005678'
            item_number        = '0020'
            record_type        = '1'
            movement_allowed   = abap_true
            material           = 'MAT-2'
            plant              = '1000'
            required_quantity  = '8.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA'
            withdrawn_quantity = '1.000' ) ) ) ).
    DATA(lo_api) = NEW lcl_prod_goods_movement_api( ).
    DATA(lo_cut) = NEW zcl_prod_comp_service(
      io_repository         = lo_repository
      io_reservation_reader = lo_reader
      io_goods_movement_api = lo_api ).

    DATA(ls_result) = lo_cut->issue_components_bulk(
      is_header   = VALUE #(
        posting_date  = '20261001'
        document_date = '20261001' )
      it_requests = VALUE #(
        ( production_order   = '0000004711'
          reservation_number = '0000001234'
          reservation_item   = '0010'
          quantity           = '4.000' )
        ( production_order   = '0000004712'
          reservation_number = '0000005678'
          reservation_item   = '0020'
          quantity           = '3.000' ) ) ).
    DATA(lt_items) = lo_api->get_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001234'
      act = lt_items[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000005678'
      act = lt_items[ 2 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_invalid_bulk_orders.
    DATA(lo_repository) = NEW lcl_prod_comp_repo( ).
    DATA(lo_cut) = NEW zcl_prod_comp_service(
      io_repository = lo_repository ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->get_open_components_bulk( VALUE #( ) ).
      CATCH zcx_invalid_production_order.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->get_open_components_bulk(
          VALUE #( ( '0000004711' ) ( '0000004711' ) ) ).
      CATCH zcx_invalid_production_order.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        lo_cut->issue_components_bulk(
          is_header   = VALUE #(
            posting_date  = '20261001'
            document_date = '20261001' )
          it_requests = VALUE #(
            ( production_order   = space
              reservation_number = '0000001234'
              reservation_item   = '0010'
              quantity           = '1.000' ) ) ).
      CATCH zcx_invalid_production_order.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD previews_components_atp.
    DATA(lo_repository) = NEW lcl_prod_comp_repo( ).
    lo_repository->set_components(
      it_components = VALUE #(
        ( production_order   = '0000004711'
          reservation_number = '0000001234'
          reservation_item   = '0010'
          material           = 'MAT-1'
          plant              = '1000'
          movement_type      = '261'
          required_date      = '20261005'
          required_quantity  = '7.000'
          withdrawn_quantity = '3.000'
          unit               = 'EA' )
        ( production_order   = '0000004711'
          reservation_number = '0000001234'
          reservation_item   = '0020'
          material           = 'MAT-1'
          plant              = '1000'
          movement_type      = '261'
          required_date      = '20261005'
          required_quantity  = '3.000'
          unit               = 'EA' )
        ( production_order   = '0000004711'
          reservation_number = '0000001234'
          reservation_item   = '0030'
          material           = 'MAT-1'
          plant              = '1000'
          movement_type      = '261'
          required_date      = '20261015'
          required_quantity  = '2.000'
          unit               = 'EA' )
        ( production_order   = '0000004712'
          reservation_number = '0000005678'
          reservation_item   = '0010'
          material           = 'MAT-1'
          plant              = '1000'
          movement_type      = '261'
          required_date      = '20261005'
          required_quantity  = '1.000'
          unit               = 'BOX' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_prod_uom_repository( ).
    lo_uom_repository->set_units(
      iv_material         = 'MAT-1'
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_availability_api) = NEW lcl_prod_availability_api( ).
    DATA(lo_stock_repository) = NEW lcl_prod_stock_repository( ).
    lo_stock_repository->set_date_stock(
      iv_date     = '20261005'
      iv_quantity = '10.000' ).
    lo_stock_repository->set_date_stock(
      iv_date                    = '20261015'
      iv_quantity                = '10.000'
      iv_receipt_quantity        = '5.000'
      iv_sto_in_transit_quantity = '2.000'
      iv_unissued_sto_quantity   = '3.000'
      iv_outgoing_sto_quantity   = '1.000'
      iv_prod_receipt_quantity   = '4.000' ).
    lo_stock_repository->set_safety_stock( iv_quantity = '2.000' ).
    DATA(lo_stock_service) = NEW zcl_stock_service(
      io_stock_repository          = lo_stock_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).
    DATA(lo_cut) = NEW zcl_prod_comp_service(
      io_repository    = lo_repository
      io_stock_service = lo_stock_service
      io_uom_converter = lo_converter ).

    DATA(lt_checks) = lo_cut->preview_components_atp_bulk(
      it_production_orders      = VALUE #(
        ( '0000004711' )
        ( '0000004712' ) )
      iv_check_rule             = 'A'
      iv_include_po_receipts    = abap_true
      iv_include_sto_in_transit = abap_true
      iv_include_unissued_sto   = abap_true
      iv_subtract_unissued_sto  = abap_true
      iv_include_prod_receipts  = abap_true
      iv_protect_safety_stock   = abap_true ).
    DATA(lt_requests) = lo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_checks[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_checks[ 1 ]-requested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '19.000' )
      act = lt_checks[ 1 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_checks[ 1 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261010'
      act = lt_checks[ 1 ]-atp_result-confirmation_lines[ 2 ]-confirmed_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_checks[ 1 ]-component_confirmed_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_checks[ 1 ]-component_unconfirmed_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_checks[ 2 ]-component_confirmed_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_checks[ 2 ]-component_unconfirmed_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '15.000' )
      act = lt_checks[ 2 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '21.000' )
      act = lt_checks[ 3 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_checks[ 3 ]-component_confirmed_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_checks[ 4 ]-component_confirmed_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = lt_checks[ 4 ]-component_unconfirmed_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = lt_checks[ 4 ]-requested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '19.000' )
      act = lt_checks[ 1 ]-local_estimate-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = lt_checks[ 1 ]-local_estimate-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = lt_checks[ 1 ]-local_estimate-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '11.000' )
      act = lt_checks[ 1 ]-local_estimate-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '13.000' )
      act = lt_checks[ 3 ]-local_estimate-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_checks[ 3 ]-local_estimate-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_checks[ 1 ]-component_local_estimate-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = lt_checks[ 1 ]-component_local_estimate-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_checks[ 1 ]-component_local_estimate-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_checks[ 2 ]-component_local_estimate-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_checks[ 2 ]-component_local_estimate-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_checks[ 4 ]-component_local_estimate-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '11.000' )
      act = lt_checks[ 4 ]-component_local_estimate-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261005'
      act = lt_requests[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_requests[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '19.000' )
      act = lt_requests[ 1 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261015'
      act = lt_requests[ 2 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '21.000' )
      act = lt_requests[ 2 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_component_atp_rule.
    DATA(lo_repository) = NEW lcl_prod_comp_repo( ).
    DATA(lo_cut) = NEW zcl_prod_comp_service(
      io_repository = lo_repository ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->preview_components_atp_bulk(
          it_production_orders = VALUE #( ( '0000004711' ) )
          iv_check_rule        = space ).
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

  METHOD previews_order_components_atp.
    DATA(lo_repository) = NEW lcl_prod_comp_repo( ).
    lo_repository->set_components(
      it_components = VALUE #(
        ( production_order   = '0000004711'
          reservation_number = '0000001234'
          reservation_item   = '0010'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = '20261005'
          required_quantity  = '2.000'
          unit               = 'EA' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_prod_uom_repository( ).
    lo_uom_repository->set_units(
      iv_material         = 'MAT-1'
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_api) = NEW lcl_prod_availability_api( ).
    DATA(lo_stock_repository) = NEW lcl_prod_stock_repository( ).
    lo_stock_repository->set_date_stock(
      iv_date             = '20261005'
      iv_quantity         = '3.000'
      iv_receipt_quantity = '2.000' ).
    lo_stock_repository->set_safety_stock( iv_quantity = '1.000' ).
    DATA(lo_stock_service) = NEW zcl_stock_service(
      io_stock_repository          = lo_stock_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_api ).
    DATA(lo_cut) = NEW zcl_prod_comp_service(
      io_repository    = lo_repository
      io_stock_service = lo_stock_service
      io_uom_converter = lo_converter ).

    DATA(lt_checks) = lo_cut->preview_components_atp(
      iv_production_order     = '0000004711'
      iv_check_rule           = 'A'
      iv_include_po_receipts  = abap_true
      iv_protect_safety_stock = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_checks[ 1 ]-requested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_checks[ 1 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_checks[ 1 ]-local_estimate-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_checks[ 1 ]-local_estimate-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD previews_components_stock.
    DATA(lo_repository) = NEW lcl_prod_comp_repo( ).
    lo_repository->set_components(
      it_components = VALUE #(
        ( production_order   = '0000004711'
          reservation_number = '0000001234'
          reservation_item   = '0010'
          material           = 'MAT-1'
          plant              = '1000'
          required_date      = '20261005'
          required_quantity  = '3.000'
          unit               = 'EA' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_prod_uom_repository( ).
    lo_uom_repository->set_units(
      iv_material         = 'MAT-1'
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_availability_api) = NEW lcl_prod_availability_api( ).
    DATA(lo_stock_repository) = NEW lcl_prod_stock_repository( ).
    lo_stock_repository->set_date_stock(
      iv_date                     = '20261005'
      iv_quantity                 = '2.000'
      iv_pr_receipt_quantity      = '2.000'
      iv_sto_pr_receipt_quantity  = '2.000'
      iv_planned_receipt_quantity = '2.000'
      iv_fixed_plan_receipt_qty   = '2.000' ).
    lo_stock_repository->set_projected_receipts(
      it_receipts = VALUE #(
        ( material        = 'MAT-1'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261005'
          quantity        = '2.000'
          source_type     = 'SCHED_AGREEMENT'
          source_document = '5500000010' ) ) ).
    DATA(lo_stock_service) = NEW zcl_stock_service(
      io_stock_repository          = lo_stock_repository
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).
    DATA(lo_cut) = NEW zcl_prod_comp_service(
      io_repository    = lo_repository
      io_stock_service = lo_stock_service
      io_uom_converter = lo_converter ).

    DATA(lt_checks) = lo_cut->preview_components_stock(
      iv_production_order = '0000004711' ).
    DATA(lt_bulk_checks) = lo_cut->preview_components_stock_bulk(
      it_production_orders = VALUE #( ( '0000004711' ) ) ).
    DATA(lt_pr_checks) = lo_cut->preview_components_stock(
      iv_production_order    = '0000004711'
      iv_include_pr_receipts = abap_true ).
    DATA(lt_sto_pr_checks) = lo_cut->preview_components_stock(
      iv_production_order        = '0000004711'
      iv_include_sto_pr_receipts = abap_true ).
    DATA(lt_planned_checks) = lo_cut->preview_components_stock(
      iv_production_order         = '0000004711'
      iv_include_planned_receipts = abap_true ).
    DATA(lt_fixed_planned_checks) = lo_cut->preview_components_stock(
      iv_production_order      = '0000004711'
      iv_include_fixed_planned = abap_true ).
    DATA(lt_sched_agreement_checks) = lo_cut->preview_components_stock(
      iv_production_order            = '0000004711'
      iv_include_sched_agmt_receipts = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_checks[ 1 ]-requested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_checks[ 1 ]-component_local_estimate-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_checks[ 1 ]-component_local_estimate-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_bulk_checks[ 1 ]-component_local_estimate-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_pr_checks[ 1 ]-local_estimate-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_pr_checks[ 1 ]-component_local_estimate-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_sto_pr_checks[ 1 ]-local_estimate-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_planned_checks[ 1 ]-local_estimate-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_fixed_planned_checks[ 1 ]-local_estimate-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_sched_agreement_checks[ 1 ]-local_estimate-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lt_checks[ 1 ]-atp_result-is_check_relevant ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_checks[ 1 ]-component_confirmed_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_checks[ 1 ]-component_unconfirmed_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lo_availability_api->get_requests( ) ) ).
  ENDMETHOD.

  METHOD rejects_component_atp_date.
    DATA(lo_repository) = NEW lcl_prod_comp_repo( ).
    lo_repository->set_components(
      it_components = VALUE #(
        ( production_order   = '0000004711'
          reservation_number = '0000001234'
          reservation_item   = '0010'
          material           = 'MAT-1'
          plant              = '1000'
          required_quantity  = '1.000'
          unit               = 'EA' ) ) ).
    DATA(lo_uom_repository) = NEW lcl_prod_uom_repository( ).
    lo_uom_repository->set_units(
      iv_material         = 'MAT-1'
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_availability_api) = NEW lcl_prod_availability_api( ).
    DATA(lo_stock_service) = NEW zcl_stock_service(
      io_stock_repository          = NEW zcl_mard_stock_repository( )
      io_uom_converter             = lo_converter
      io_material_availability_api = lo_availability_api ).
    DATA(lo_cut) = NEW zcl_prod_comp_service(
      io_repository    = lo_repository
      io_stock_service = lo_stock_service
      io_uom_converter = lo_converter ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->preview_components_atp_bulk(
          it_production_orders = VALUE #( ( '0000004711' ) )
          iv_check_rule        = 'A' ).
      CATCH zcx_invalid_production_order.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lo_availability_api->get_requests( ) ) ).
  ENDMETHOD.

  METHOD summarizes_component_readiness.
    DATA(lo_cut) = NEW zcl_prod_comp_service( ).
    DATA(lt_readiness) = lo_cut->summarize_component_readiness(
      it_checks = VALUE #(
        ( component                = VALUE #(
            production_order   = '0000004711'
            reservation_number = '0000001234'
            reservation_item   = '0010'
            required_date      = '20261005' )
          requested_base_quantity  = '4.000'
          component_local_estimate = VALUE #(
            requested_quantity = '4.000'
            available_quantity = '8.000'
            allocated_quantity = '4.000'
            shortfall_quantity = '0.000' ) )
        ( component                = VALUE #(
            production_order   = '0000004711'
            reservation_number = '0000001234'
            reservation_item   = '0020'
            required_date      = '20261015' )
          requested_base_quantity  = '3.000'
          component_local_estimate = VALUE #(
            requested_quantity = '3.000'
            available_quantity = '1.000'
            allocated_quantity = '1.000'
            shortfall_quantity = '2.000' ) )
        ( component                = VALUE #(
            production_order   = '0000004712'
            reservation_number = '0000005678'
            reservation_item   = '0010'
            required_date      = '20261010' )
          requested_base_quantity  = '12.000'
          component_local_estimate = VALUE #(
            requested_quantity = '12.000'
            available_quantity = '12.000'
            allocated_quantity = '12.000'
            shortfall_quantity = '0.000' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_readiness ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711'
      act = lt_readiness[ 1 ]-production_order ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lt_readiness[ 1 ]-open_component_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lt_readiness[ 1 ]-covered_component_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lt_readiness[ 1 ]-short_component_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261005'
      act = lt_readiness[ 1 ]-first_required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261015'
      act = lt_readiness[ 1 ]-last_required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261015'
      act = lt_readiness[ 1 ]-first_local_shortage_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lt_readiness[ 1 ]-is_locally_ready ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004712'
      act = lt_readiness[ 2 ]-production_order ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_readiness[ 2 ]-is_locally_ready ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lt_readiness[ 2 ]-short_component_count ).
  ENDMETHOD.

  METHOD rejects_bad_readiness.
    DATA(lo_cut) = NEW zcl_prod_comp_service( ).
    DATA lv_order_rejected TYPE abap_bool.
    DATA lv_quantity_rejected TYPE abap_bool.

    TRY.
        lo_cut->summarize_component_readiness(
          it_checks = VALUE #( ( requested_base_quantity = '1.000' ) ) ).
      CATCH zcx_invalid_production_order.
        lv_order_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->summarize_component_readiness(
          it_checks = VALUE #(
            ( component                = VALUE #(
                production_order   = '0000004711'
                reservation_number = '0000001234'
                reservation_item   = '0010'
                required_date      = '20261005' )
              requested_base_quantity  = '1.000'
              component_local_estimate = VALUE #(
                requested_quantity = '1.000'
                allocated_quantity = '0.500'
                shortfall_quantity = '0.250' ) ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_quantity_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_order_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_quantity_rejected ).
  ENDMETHOD.

  METHOD summarizes_component_shortages.
    DATA(lo_cut) = NEW zcl_prod_comp_service( ).
    DATA(lt_shortages) = lo_cut->summarize_component_shortages(
      it_checks = VALUE #(
        ( component                = VALUE #(
            production_order   = '0000004711'
            reservation_number = '0000001234'
            reservation_item   = '0010'
            material           = 'MAT-1'
            plant              = '1000'
            required_date      = '20261005' )
          base_unit                = 'EA'
          requested_base_quantity  = '4.000'
          component_local_estimate = VALUE #(
            requested_quantity = '4.000'
            available_quantity = '8.000'
            allocated_quantity = '4.000'
            shortfall_quantity = '0.000' ) )
        ( component                = VALUE #(
            production_order   = '0000004711'
            reservation_number = '0000001234'
            reservation_item   = '0020'
            material           = 'MAT-1'
            plant              = '1000'
            required_date      = '20261005' )
          base_unit                = 'EA'
          requested_base_quantity  = '3.000'
          component_local_estimate = VALUE #(
            requested_quantity = '3.000'
            available_quantity = '4.000'
            allocated_quantity = '3.000'
            shortfall_quantity = '0.000' ) )
        ( component                = VALUE #(
            production_order   = '0000004712'
            reservation_number = '0000005678'
            reservation_item   = '0010'
            material           = 'MAT-1'
            plant              = '1000'
            required_date      = '20261005' )
          base_unit                = 'EA'
          requested_base_quantity  = '12.000'
          component_local_estimate = VALUE #(
            requested_quantity = '12.000'
            available_quantity = '1.000'
            allocated_quantity = '1.000'
            shortfall_quantity = '11.000' ) )
        ( component                = VALUE #(
            production_order   = '0000004712'
            reservation_number = '0000005678'
            reservation_item   = '0020'
            material           = 'MAT-1'
            plant              = '1000'
            required_date      = '20261005' )
          base_unit                = 'EA'
          requested_base_quantity  = '1.000'
          component_local_estimate = VALUE #(
            requested_quantity = '1.000'
            available_quantity = '0.000'
            allocated_quantity = '0.000'
            shortfall_quantity = '1.000' ) )
        ( component                = VALUE #(
            production_order   = '0000004713'
            reservation_number = '0000006789'
            reservation_item   = '0010'
            material           = 'MAT-2'
            plant              = '1000'
            required_date      = '20261010' )
          base_unit                = 'KG'
          requested_base_quantity  = '2.000'
          component_local_estimate = VALUE #(
            requested_quantity = '2.000'
            available_quantity = '0.000'
            allocated_quantity = '0.000'
            shortfall_quantity = '2.000' ) )
        ( component                = VALUE #(
            production_order   = '0000004714'
            reservation_number = '0000007890'
            reservation_item   = '0010'
            material           = 'MAT-1'
            plant              = '1000'
            required_date      = '20261015' )
          base_unit                = 'EA'
          requested_base_quantity  = '1.000'
          component_local_estimate = VALUE #(
            requested_quantity = '1.000'
            available_quantity = '1.000'
            allocated_quantity = '1.000'
            shortfall_quantity = '0.000' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_shortages ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MAT-1'
      act = lt_shortages[ 1 ]-material ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_shortages[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261005'
      act = lt_shortages[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lt_shortages[ 1 ]-component_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lt_shortages[ 1 ]-short_component_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lt_shortages[ 1 ]-affected_order_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines(
        lt_shortages[ 1 ]-affected_production_orders ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004712'
      act = lt_shortages[ 1 ]-affected_production_orders[ 1 ] ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '20.000' )
      act = lt_shortages[ 1 ]-requested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = lt_shortages[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = lt_shortages[ 1 ]-shortfall_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MAT-2'
      act = lt_shortages[ 2 ]-material ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'KG'
      act = lt_shortages[ 2 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_shortages[ 2 ]-shortfall_base_quantity ).
  ENDMETHOD.

  METHOD summarizes_order_atp.
    DATA(lo_cut) = NEW zcl_prod_comp_service( ).
    DATA(lt_summaries) = lo_cut->summarize_order_atp(
      it_checks = VALUE #(
        ( component                      = VALUE #(
            production_order   = '0000004711'
            reservation_number = '0000001234'
            reservation_item   = '0010'
            material           = 'MAT-1'
            plant              = '1000'
            required_date      = '20261005' )
          base_unit                      = 'EA'
          requested_base_quantity        = '4.000'
          cumulative_base_quantity       = '19.000'
          confirmed_base_quantity        = '5.000'
          unconfirmed_base_quantity      = '14.000'
          component_confirmed_quantity   = '4.000'
          component_unconfirmed_quantity = '0.000'
          atp_result                     = VALUE #( is_check_relevant = abap_true ) )
        ( component                      = VALUE #(
            production_order   = '0000004711'
            reservation_number = '0000001234'
            reservation_item   = '0020'
            material           = 'MAT-1'
            plant              = '1000'
            required_date      = '20261005' )
          base_unit                      = 'EA'
          requested_base_quantity        = '3.000'
          cumulative_base_quantity       = '19.000'
          confirmed_base_quantity        = '5.000'
          unconfirmed_base_quantity      = '14.000'
          component_confirmed_quantity   = '1.000'
          component_unconfirmed_quantity = '2.000'
          atp_result                     = VALUE #( is_check_relevant = abap_true ) )
        ( component                      = VALUE #(
            production_order   = '0000004712'
            reservation_number = '0000005678'
            reservation_item   = '0010'
            material           = 'MAT-1'
            plant              = '1000'
            required_date      = '20261005' )
          base_unit                      = 'EA'
          requested_base_quantity        = '12.000'
          cumulative_base_quantity       = '19.000'
          confirmed_base_quantity        = '5.000'
          unconfirmed_base_quantity      = '14.000'
          component_confirmed_quantity   = '0.000'
          component_unconfirmed_quantity = '12.000'
          atp_result                     = VALUE #( is_check_relevant = abap_true ) )
        ( component                      = VALUE #(
            production_order   = '0000004712'
            reservation_number = '0000005678'
            reservation_item   = '0020'
            material           = 'MAT-1'
            plant              = '1000'
            required_date      = '20261015' )
          base_unit                      = 'EA'
          requested_base_quantity        = '2.000'
          cumulative_base_quantity       = '21.000'
          confirmed_base_quantity        = '7.000'
          unconfirmed_base_quantity      = '14.000'
          component_confirmed_quantity   = '2.000'
          component_unconfirmed_quantity = '0.000'
          atp_result                     = VALUE #( is_check_relevant = abap_true ) )
        ( component                      = VALUE #(
            production_order   = '0000004711'
            reservation_number = '0000009999'
            reservation_item   = '0010'
            material           = 'MAT-2'
            plant              = '1000'
            required_date      = '20261010' )
          base_unit                      = 'KG'
          requested_base_quantity        = '2.000'
          cumulative_base_quantity       = '2.000'
          confirmed_base_quantity        = '0.000'
          unconfirmed_base_quantity      = '2.000'
          component_confirmed_quantity   = '0.000'
          component_unconfirmed_quantity = '2.000'
          atp_result                     = VALUE #( is_check_relevant = abap_true ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_summaries ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MAT-1'
      act = lt_summaries[ 1 ]-material ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_summaries[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lt_summaries[ 1 ]-component_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lt_summaries[ 1 ]-fully_confirmed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lt_summaries[ 1 ]-partially_confirmed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = lt_summaries[ 1 ]-requested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lt_summaries[ 1 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_summaries[ 1 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lt_summaries[ 1 ]-is_split_fully_confirmed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MAT-2'
      act = lt_summaries[ 2 ]-material ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'KG'
      act = lt_summaries[ 2 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_summaries[ 2 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MAT-1'
      act = lt_summaries[ 3 ]-material ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lt_summaries[ 3 ]-component_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261005'
      act = lt_summaries[ 3 ]-first_unconfirmed_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261015'
      act = lt_summaries[ 3 ]-last_required_date ).
  ENDMETHOD.

  METHOD suggests_comp_replenishment.
    DATA(lo_policy_repo) = NEW lcl_prod_repl_policy_repo( ).
    DATA(lo_calendar) = NEW lcl_prod_repl_calendar( ).
    lo_calendar->set_working_dates( it_dates = VALUE #(
      ( '20261012' )
      ( '20261013' )
      ( '20261014' )
      ( '20261015' )
      ( '20261016' )
      ( '20261019' )
      ( '20261020' )
      ( '20261021' )
      ( '20261022' )
      ( '20261023' ) ) ).
    lo_policy_repo->set_policies( it_policies = VALUE #(
      ( lot_size_procedure           = 'FX'
        procurement_type             = 'E'
        special_procurement_key      = '40'
        material                     = 'MAT-4'
        plant                        = '1000'
        base_unit                    = 'EA'
        minimum_base_quantity        = '1.000'
        maximum_base_quantity        = '1.000'
        fixed_base_quantity          = '2.000'
        order_multiple_base_quantity = '0.500' )
      ( lot_size_procedure            = 'EX'
        procurement_type              = 'F'
        material                      = 'MAT-5'
        plant                         = '1000'
        base_unit                     = 'EA'
        factory_calendar_id           = '01'
        planned_delivery_days         = 3
        goods_receipt_processing_days = 2
        purchasing_processing_days    = '01'
        minimum_base_quantity         = '1.500'
        maximum_base_quantity         = '3.000'
        fixed_base_quantity           = '5.000'
        order_multiple_base_quantity  = '2.000' )
      ( lot_size_procedure           = 'WB'
        procurement_type             = 'X'
        material                     = 'MAT-6'
        plant                        = '1000'
        base_unit                    = 'EA'
        minimum_base_quantity        = '1.000'
        maximum_base_quantity        = '1.000'
        fixed_base_quantity          = '2.000'
        order_multiple_base_quantity = '1.000' )
      ( lot_size_procedure           = 'EX'
        material                     = 'MAT-7'
        plant                        = '1000'
        base_unit                    = 'EA'
        minimum_base_quantity        = '4.000'
        maximum_base_quantity        = '3.000'
        fixed_base_quantity          = '0.000'
        order_multiple_base_quantity = '0.000' )
      ( lot_size_procedure           = 'EX'
        material                     = 'MAT-8'
        plant                        = '1000'
        base_unit                    = 'EA'
        maximum_base_quantity        = '3.000'
        order_multiple_base_quantity = '4.000' )
      ( lot_size_procedure = 'EX'
        procurement_type   = 'F'
        material           = 'MAT-9'
        plant              = '1000'
        base_unit          = 'EA' )
      ( lot_size_procedure    = 'EX'
        procurement_type      = 'F'
        material              = 'MAT-10'
        plant                 = '1000'
        base_unit             = 'EA'
        factory_calendar_id   = '01'
        planned_delivery_days = 1 ) ) ).
    DATA(lo_cut) = NEW zcl_prod_comp_service(
      io_repl_policy_repo     = lo_policy_repo
      io_factory_calendar_api = lo_calendar ).
    DATA(lt_suggestions) = lo_cut->suggest_comp_replenishment(
      it_shortages  = VALUE #(
        ( material                = 'MAT-1'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261005'
          component_count         = 3
          affected_order_count    = 2
          requested_base_quantity = '10.000'
          allocated_base_quantity = '6.000'
          shortfall_base_quantity = '4.000' )
        ( material                = 'MAT-2'
          plant                   = '1000'
          base_unit               = 'KG'
          required_date           = '20261010'
          component_count         = 2
          affected_order_count    = 1
          requested_base_quantity = '8.250'
          allocated_base_quantity = '5.000'
          shortfall_base_quantity = '3.250' )
        ( material                = 'MAT-3'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261015'
          component_count         = 1
          affected_order_count    = 1
          requested_base_quantity = '3.000'
          allocated_base_quantity = '2.500'
          shortfall_base_quantity = '0.500' )
        ( material                = 'MAT-4'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261020'
          component_count         = 1
          affected_order_count    = 1
          requested_base_quantity = '1.250'
          allocated_base_quantity = '0.000'
          shortfall_base_quantity = '1.250' )
        ( material                = 'MAT-5'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261025'
          component_count         = 1
          affected_order_count    = 1
          requested_base_quantity = '3.000'
          allocated_base_quantity = '0.000'
          shortfall_base_quantity = '3.000' )
        ( material                = 'MAT-6'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261030'
          component_count         = 1
          affected_order_count    = 1
          requested_base_quantity = '0.750'
          allocated_base_quantity = '0.000'
          shortfall_base_quantity = '0.750' )
        ( material                = 'MAT-7'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261104'
          component_count         = 1
          affected_order_count    = 1
          requested_base_quantity = '0.500'
          allocated_base_quantity = '0.000'
          shortfall_base_quantity = '0.500' )
        ( material                = 'MAT-8'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261105'
          component_count         = 1
          affected_order_count    = 1
          requested_base_quantity = '4.000'
          allocated_base_quantity = '0.000'
          shortfall_base_quantity = '4.000' )
        ( material                = 'MAT-9'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261020'
          component_count         = 1
          affected_order_count    = 1
          requested_base_quantity = '1.000'
          allocated_base_quantity = '0.000'
          shortfall_base_quantity = '1.000' )
        ( material                = 'MAT-10'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20260930'
          component_count         = 1
          affected_order_count    = 1
          requested_base_quantity = '1.000'
          allocated_base_quantity = '0.000'
          shortfall_base_quantity = '1.000' )
        ( material                = 'MAT-11'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261025'
          component_count         = 1
          affected_order_count    = 1
          requested_base_quantity = '2.000'
          allocated_base_quantity = '0.000'
          shortfall_base_quantity = '2.000' )
        ( material                = 'MAT-12'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261025'
          component_count         = 1
          affected_order_count    = 1
          requested_base_quantity = '2.000'
          allocated_base_quantity = '0.000'
          shortfall_base_quantity = '2.000' ) )
      it_policies   = VALUE #(
        ( material                     = 'MAT-1'
          plant                        = '1000'
          base_unit                    = 'EA'
          procurement_type             = 'F'
          special_procurement_key      = '30'
          minimum_base_quantity        = '5.000'
          order_multiple_base_quantity = '2.000' )
        ( material                     = 'MAT-2'
          plant                        = '1000'
          base_unit                    = 'KG'
          minimum_base_quantity        = '1.000'
          order_multiple_base_quantity = '0.500' )
        ( material                      = 'MAT-11'
          plant                         = '1000'
          base_unit                     = 'EA'
          lot_size_procedure            = 'EX'
          procurement_type              = 'F'
          factory_calendar_id           = '01'
          planned_delivery_days         = 3
          source_vendor                 = '0000100001'
          source_purchasing_org         = '1000'
          source_info_record            = '0000001234'
          source_category               = '0'
          source_planned_delivery_days  = 7
          goods_receipt_processing_days = 2
          purchasing_processing_days    = '01'
          minimum_base_quantity         = '1.000'
          maximum_base_quantity         = '3.000'
          order_multiple_base_quantity  = '1.000' )
        ( material                      = 'MAT-12'
          plant                         = '1000'
          base_unit                     = 'EA'
          lot_size_procedure            = 'EX'
          procurement_type              = 'F'
          factory_calendar_id           = '01'
          planned_delivery_days         = 3
          source_vendor                 = '0000100002'
          source_purchasing_org         = '1000'
          source_agreement              = '4500000002'
          source_agreement_item         = '00020'
          goods_receipt_processing_days = 2
          purchasing_processing_days    = '01'
          minimum_base_quantity         = '1.000'
          maximum_base_quantity         = '3.000'
          order_multiple_base_quantity  = '1.000' ) )
      iv_as_of_date = '20261015' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 12
      act = lines( lt_suggestions ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_suggestions[ 1 ]-shortfall_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lt_suggestions[ 1 ]-minimum_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CALLER'
      act = lt_suggestions[ 1 ]-policy_origin ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SPECIAL_SOURCE'
      act = lt_suggestions[ 1 ]-lead_time_status ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'F'
      act = lt_suggestions[ 1 ]-procurement_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = '30'
      act = lt_suggestions[ 1 ]-special_procurement_key ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_suggestions[ 1 ]-order_multiple_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = lt_suggestions[ 1 ]-suggested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lt_suggestions[ 1 ]-suggested_receipt_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = lt_suggestions[ 1 ]-final_receipt_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_suggestions[ 1 ]-rounding_surplus_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.500' )
      act = lt_suggestions[ 2 ]-suggested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.250' )
      act = lt_suggestions[ 2 ]-rounding_surplus_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_suggestions[ 3 ]-suggested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_suggestions[ 3 ]-rounding_surplus_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'NONE'
      act = lt_suggestions[ 3 ]-policy_origin ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'NO_POLICY'
      act = lt_suggestions[ 3 ]-lead_time_status ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_policy_repo->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'FX'
      act = lt_suggestions[ 4 ]-lot_size_procedure ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MARC'
      act = lt_suggestions[ 4 ]-policy_origin ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'E'
      act = lt_suggestions[ 4 ]-procurement_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = '40'
      act = lt_suggestions[ 4 ]-special_procurement_key ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'IN_HOUSE'
      act = lt_suggestions[ 4 ]-lead_time_status ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_suggestions[ 4 ]-minimum_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_suggestions[ 4 ]-maximum_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_suggestions[ 4 ]-fixed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_suggestions[ 4 ]-order_multiple_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_suggestions[ 4 ]-suggested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.750' )
      act = lt_suggestions[ 4 ]-rounding_surplus_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EX'
      act = lt_suggestions[ 5 ]-lot_size_procedure ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.500' )
      act = lt_suggestions[ 5 ]-minimum_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_suggestions[ 5 ]-maximum_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_suggestions[ 5 ]-fixed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_suggestions[ 5 ]-order_multiple_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lt_suggestions[ 5 ]-suggested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lt_suggestions[ 5 ]-suggested_receipt_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_suggestions[ 5 ]-final_receipt_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_suggestions[ 5 ]-rounding_surplus_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MATERIAL_ESTIMATE'
      act = lt_suggestions[ 5 ]-lead_time_status ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261021' )
      act = lt_suggestions[ 5 ]-estimated_delivery_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261016' )
      act = lt_suggestions[ 5 ]-latest_purchase_order_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261015' )
      act = lt_suggestions[ 5 ]-latest_pr_release_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'WB'
      act = lt_suggestions[ 6 ]-lot_size_procedure ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MARC'
      act = lt_suggestions[ 6 ]-policy_origin ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'X'
      act = lt_suggestions[ 6 ]-procurement_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'AMBIGUOUS'
      act = lt_suggestions[ 6 ]-lead_time_status ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_suggestions[ 6 ]-suggested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261026' )
      act = lt_suggestions[ 6 ]-lot_size_period_start ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261101' )
      act = lt_suggestions[ 6 ]-lot_size_period_end ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'UNSUPPORTED'
      act = lt_suggestions[ 7 ]-policy_origin ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_suggestions[ 7 ]-suggested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'UNSUPPORTED'
      act = lt_suggestions[ 8 ]-policy_origin ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_suggestions[ 8 ]-suggested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MISSING_CALENDAR'
      act = lt_suggestions[ 9 ]-lead_time_status ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CALENDAR_ERROR'
      act = lt_suggestions[ 10 ]-lead_time_status ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_suggestions[ 11 ]-source_vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = lt_suggestions[ 11 ]-source_purchasing_org ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001234'
      act = lt_suggestions[ 11 ]-source_info_record ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0'
      act = lt_suggestions[ 11 ]-source_category ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV marc-plifz( 7 )
      act = lt_suggestions[ 11 ]-planned_delivery_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV eine-aplfz( 7 )
      act = lt_suggestions[ 11 ]-source_planned_delivery_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_prod_comp_service=>c_repl_days_origin_info_record
      act = lt_suggestions[ 11 ]-lead_time_days_origin ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261014' )
      act = lt_suggestions[ 11 ]-latest_purchase_order_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261013' )
      act = lt_suggestions[ 11 ]-latest_pr_release_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_suggestions[ 11 ]-pr_release_is_overdue ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lt_suggestions[ 11 ]-pr_release_days_overdue ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261015' )
      act = lt_suggestions[ 11 ]-as_of_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lt_suggestions[ 12 ]-source_planned_delivery_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV marc-plifz( 3 )
      act = lt_suggestions[ 12 ]-planned_delivery_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000002'
      act = lt_suggestions[ 12 ]-source_agreement ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00020'
      act = lt_suggestions[ 12 ]-source_agreement_item ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_suggestions[ 12 ]-source_info_record ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_prod_comp_service=>c_repl_days_origin_caller
      act = lt_suggestions[ 12 ]-lead_time_days_origin ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261016' )
      act = lt_suggestions[ 12 ]-latest_purchase_order_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lt_suggestions[ 12 ]-pr_release_is_overdue ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lt_suggestions[ 12 ]-pr_release_days_overdue ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = lo_calendar->get_call_count( ) ).
  ENDMETHOD.

  METHOD rounds_replenishment_profile.
    DATA(lo_policy_repo) = NEW lcl_prod_repl_policy_repo( ).
    lo_policy_repo->set_policies( it_policies = VALUE #(
      ( material              = 'MAT-MASTER'
        plant                 = '1000'
        base_unit             = 'EA'
        lot_size_procedure    = 'EX'
        maximum_base_quantity = '100.000'
        rounding_profile      = 'R001' ) ) ).
    lo_policy_repo->set_rounding_profiles( it_profiles = VALUE #(
      ( plant = '1000' rounding_profile = 'R001'
        level_number = '000001' threshold_quantity = '2.000'
        rounding_quantity = '5.000' )
      ( plant = '1000' rounding_profile = 'R001'
        level_number = '000002' threshold_quantity = '32.000'
        rounding_quantity = '40.000' ) ) ).
    DATA(lo_cut) = NEW zcl_prod_comp_service(
      io_repl_policy_repo = lo_policy_repo ).

    DATA(lt_suggestions) = lo_cut->suggest_comp_replenishment(
      it_shortages  = VALUE #(
        ( material = 'MAT-CALLER' plant = '1000' base_unit = 'EA'
          required_date = '20261015' component_count = 1
          requested_base_quantity = '31.000'
          allocated_base_quantity = '0.000'
          shortfall_base_quantity = '31.000' )
        ( material = 'MAT-MASTER' plant = '1000' base_unit = 'EA'
          required_date = '20261015' component_count = 1
          requested_base_quantity = '74.000'
          allocated_base_quantity = '0.000'
          shortfall_base_quantity = '74.000' )
        ( material = 'MAT-SPLIT' plant = '1000' base_unit = 'EA'
          required_date = '20261015' component_count = 1
          requested_base_quantity = '7.000'
          allocated_base_quantity = '0.000'
          shortfall_base_quantity = '7.000' )
        ( material = 'MAT-FIXED' plant = '1000' base_unit = 'EA'
          required_date = '20261015' component_count = 1
          requested_base_quantity = '7.000'
          allocated_base_quantity = '0.000'
          shortfall_base_quantity = '7.000' ) )
      it_policies   = VALUE #(
        ( material         = 'MAT-CALLER'
          plant            = '1000'
          base_unit        = 'EA'
          rounding_profile = 'R001' )
        ( material              = 'MAT-SPLIT'
          plant                 = '1000'
          base_unit             = 'EA'
          lot_size_procedure    = 'EX'
          maximum_base_quantity = '5.000'
          rounding_profile      = 'R001' )
        ( material            = 'MAT-FIXED'
          plant               = '1000'
          base_unit           = 'EA'
          lot_size_procedure  = 'FX'
          fixed_base_quantity = '3.000'
          rounding_profile    = 'R001' ) )
      iv_as_of_date = '20261001' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_suggestions ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'R001'
      act = lt_suggestions[ 1 ]-rounding_profile ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '35.000' )
      act = lt_suggestions[ 1 ]-suggested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '35.000' )
      act = lt_suggestions[ 1 ]-final_receipt_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_suggestions[ 1 ]-rounding_surplus_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'R001'
      act = lt_suggestions[ 2 ]-rounding_profile ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '80.000' )
      act = lt_suggestions[ 2 ]-suggested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '80.000' )
      act = lt_suggestions[ 2 ]-final_receipt_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = lt_suggestions[ 2 ]-rounding_surplus_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lt_suggestions[ 3 ]-suggested_receipt_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lt_suggestions[ 3 ]-suggested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lt_suggestions[ 3 ]-final_receipt_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_suggestions[ 3 ]-rounding_surplus_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lt_suggestions[ 4 ]-suggested_receipt_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_suggestions[ 4 ]-fixed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '15.000' )
      act = lt_suggestions[ 4 ]-suggested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lt_suggestions[ 4 ]-final_receipt_base_quantity ).
  ENDMETHOD.

  METHOD rejects_missing_profile_levels.
    DATA lv_profile_rejected TYPE abap_bool.
    DATA(lo_policy_repo) = NEW lcl_prod_repl_policy_repo( ).
    DATA(lo_cut) = NEW zcl_prod_comp_service(
      io_repl_policy_repo = lo_policy_repo ).

    TRY.
        DATA(lt_suggestions) = lo_cut->suggest_comp_replenishment(
          it_shortages  = VALUE #(
            ( material = 'MAT-CALLER' plant = '1000' base_unit = 'EA'
              required_date = '20261015' component_count = 1
              requested_base_quantity = '5.000'
              allocated_base_quantity = '0.000'
              shortfall_base_quantity = '5.000' ) )
          it_policies   = VALUE #(
            ( material         = 'MAT-CALLER'
              plant            = '1000'
              base_unit        = 'EA'
              rounding_profile = 'MISS' ) )
          iv_as_of_date = '20261001' ).
      CATCH zcx_invalid_stock_request.
        lv_profile_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_profile_rejected ).
  ENDMETHOD.

  METHOD rejects_rounding_over_max_lot.
    DATA lv_limit_rejected TYPE abap_bool.
    DATA(lo_policy_repo) = NEW lcl_prod_repl_policy_repo( ).
    lo_policy_repo->set_rounding_profiles( it_profiles = VALUE #(
      ( plant = '1000' rounding_profile = 'R001'
        level_number = '000001' threshold_quantity = '2.000'
        rounding_quantity = '5.000' ) ) ).
    DATA(lo_cut) = NEW zcl_prod_comp_service(
      io_repl_policy_repo = lo_policy_repo ).

    TRY.
        DATA(lt_suggestions) = lo_cut->suggest_comp_replenishment(
          it_shortages  = VALUE #(
            ( material = 'MAT-SPLIT' plant = '1000' base_unit = 'EA'
              required_date = '20261015' component_count = 1
              requested_base_quantity = '7.000'
              allocated_base_quantity = '0.000'
              shortfall_base_quantity = '7.000' ) )
          it_policies   = VALUE #(
            ( material              = 'MAT-SPLIT'
              plant                 = '1000'
              base_unit             = 'EA'
              lot_size_procedure    = 'EX'
              maximum_base_quantity = '3.000'
              rounding_profile      = 'R001' ) )
          iv_as_of_date = '20261001' ).
      CATCH zcx_invalid_stock_request.
        lv_limit_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_limit_rejected ).
  ENDMETHOD.

  METHOD groups_monthly_lot_size.
    DATA(lo_cut) = NEW zcl_prod_comp_service( ).
    DATA(lt_suggestions) = lo_cut->suggest_comp_replenishment(
      it_shortages          = VALUE #(
        ( material                   = 'MAT-MB'
          plant                      = '1000'
          base_unit                  = 'EA'
          required_date              = '20280205'
          component_count            = 2
          affected_order_count       = 1
          affected_production_orders = VALUE #(
            ( CONV resb-aufnr( '0000004711' ) ) )
          requested_base_quantity    = '3.000'
          shortfall_base_quantity    = '3.000' )
        ( material                   = 'MAT-MB'
          plant                      = '1000'
          base_unit                  = 'EA'
          required_date              = '20280225'
          component_count            = 3
          affected_order_count       = 2
          affected_production_orders = VALUE #(
            ( CONV resb-aufnr( '0000004711' ) )
            ( CONV resb-aufnr( '0000004712' ) ) )
          requested_base_quantity    = '4.000'
          shortfall_base_quantity    = '4.000' )
        ( material                = 'MAT-MB'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20280303'
          component_count         = 1
          affected_order_count    = 1
          requested_base_quantity = '2.000'
          shortfall_base_quantity = '2.000' ) )
      it_policies           = VALUE #(
        ( lot_size_procedure           = 'MB'
          procurement_type             = 'E'
          material                     = 'MAT-MB'
          plant                        = '1000'
          base_unit                    = 'EA'
          minimum_base_quantity        = '5.000'
          maximum_base_quantity        = '10.000'
          order_multiple_base_quantity = '2.000' ) )
      it_projected_receipts = VALUE #(
        ( material        = 'MAT-MB'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20280220'
          quantity        = '2.000'
          source_type     = 'PO'
          source_document = '4500001234'
          source_item     = '00010' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_suggestions ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20280205' )
      act = lt_suggestions[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20280201' )
      act = lt_suggestions[ 1 ]-lot_size_period_start ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20280229' )
      act = lt_suggestions[ 1 ]-lot_size_period_end ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lt_suggestions[ 1 ]-grouped_shortage_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = lt_suggestions[ 1 ]-component_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lt_suggestions[ 1 ]-affected_order_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines(
        lt_suggestions[ 1 ]-affected_production_orders ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711'
      act = lt_suggestions[ 1 ]-affected_production_orders[ 1 ] ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004712'
      act = lt_suggestions[ 1 ]-affected_production_orders[ 2 ] ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = lt_suggestions[ 1 ]-shortfall_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_suggestions[ 1 ]-projected_receipt_used_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lt_suggestions[ 1 ]-planning_shortfall_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = lt_suggestions[ 1 ]-suggested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20280220' )
      act = lt_suggestions[ 1 ]-projected_receipt_uses[ 1 ]-receipt_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500001234'
      act = lt_suggestions[ 1 ]-projected_receipt_uses[ 1 ]-source_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20280301' )
      act = lt_suggestions[ 2 ]-lot_size_period_start ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20280331' )
      act = lt_suggestions[ 2 ]-lot_size_period_end ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lt_suggestions[ 2 ]-grouped_shortage_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = lt_suggestions[ 2 ]-suggested_base_quantity ).

    DATA(lt_sunday_suggestions) = lo_cut->suggest_comp_replenishment(
      it_shortages          = VALUE #(
        ( material                = 'MAT-WB-SUNDAY'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261003'
          component_count         = 1
          requested_base_quantity = '1.000'
          shortfall_base_quantity = '1.000' )
        ( material                = 'MAT-WB-SUNDAY'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261004'
          component_count         = 1
          requested_base_quantity = '1.000'
          shortfall_base_quantity = '1.000' ) )
      it_policies           = VALUE #(
        ( lot_size_procedure = 'WB'
          procurement_type   = 'E'
          material           = 'MAT-WB-SUNDAY'
          plant              = '1000'
          base_unit          = 'EA' ) )
      iv_week_start_weekday = 7 ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20260927' )
      act = lt_sunday_suggestions[ 1 ]-lot_size_period_start ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261003' )
      act = lt_sunday_suggestions[ 1 ]-lot_size_period_end ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261004' )
      act = lt_sunday_suggestions[ 2 ]-lot_size_period_start ).

    DATA(lt_mixed_suggestions) = lo_cut->suggest_comp_replenishment(
      it_shortages = VALUE #(
        ( material                   = 'MAT-MB-MIXED'
          plant                      = '1000'
          base_unit                  = 'EA'
          required_date              = '20280205'
          component_count            = 1
          affected_order_count       = 1
          affected_production_orders = VALUE #(
            ( CONV resb-aufnr( '0000004711' ) ) )
          requested_base_quantity    = '1.000'
          shortfall_base_quantity    = '1.000' )
        ( material                = 'MAT-MB-MIXED'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20280225'
          component_count         = 1
          affected_order_count    = 2
          requested_base_quantity = '1.000'
          shortfall_base_quantity = '1.000' ) )
      it_policies  = VALUE #(
        ( lot_size_procedure = 'MB'
          procurement_type   = 'E'
          material           = 'MAT-MB-MIXED'
          plant              = '1000'
          base_unit          = 'EA' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_mixed_suggestions ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lt_mixed_suggestions[ 1 ]-affected_order_count ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_mixed_suggestions[ 1 ]-affected_production_orders ).

    DATA lv_bad_order_list_rejected TYPE abap_bool.
    TRY.
        lo_cut->suggest_comp_replenishment(
          it_shortages = VALUE #(
            ( material                   = 'MAT-MB-BAD-ORDER-LIST'
              plant                      = '1000'
              base_unit                  = 'EA'
              required_date              = '20280205'
              component_count            = 1
              affected_order_count       = 2
              affected_production_orders = VALUE #(
                ( CONV resb-aufnr( '0000004711' ) ) )
              requested_base_quantity    = '1.000'
              shortfall_base_quantity    = '1.000' ) )
          it_policies  = VALUE #(
            ( lot_size_procedure = 'MB'
              procurement_type   = 'E'
              material           = 'MAT-MB-BAD-ORDER-LIST'
              plant              = '1000'
              base_unit          = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_bad_order_list_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_order_list_rejected ).
  ENDMETHOD.

  METHOD groups_weekly_lot_size.
    DATA(lo_cut) = NEW zcl_prod_comp_service( ).
    DATA(lt_suggestions) = lo_cut->suggest_comp_replenishment(
      it_shortages          = VALUE #(
        ( material                = 'MAT-WB'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20260104'
          component_count         = 3
          affected_order_count    = 2
          requested_base_quantity = '4.000'
          shortfall_base_quantity = '4.000' )
        ( material                = 'MAT-WB'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20260101'
          component_count         = 2
          affected_order_count    = 1
          requested_base_quantity = '3.000'
          shortfall_base_quantity = '3.000' )
        ( material                = 'MAT-WB'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20260105'
          component_count         = 1
          affected_order_count    = 1
          requested_base_quantity = '2.000'
          shortfall_base_quantity = '2.000' ) )
      it_policies           = VALUE #(
        ( lot_size_procedure           = 'WB'
          procurement_type             = 'E'
          material                     = 'MAT-WB'
          plant                        = '1000'
          base_unit                    = 'EA'
          minimum_base_quantity        = '5.000'
          maximum_base_quantity        = '10.000'
          order_multiple_base_quantity = '2.000' ) )
      it_projected_receipts = VALUE #(
        ( material        = 'MAT-WB'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20260102'
          quantity        = '2.000'
          source_type     = 'PO'
          source_document = '4500001235'
          source_item     = '00010' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_suggestions ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20260101' )
      act = lt_suggestions[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20251229' )
      act = lt_suggestions[ 1 ]-lot_size_period_start ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20260104' )
      act = lt_suggestions[ 1 ]-lot_size_period_end ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lt_suggestions[ 1 ]-grouped_shortage_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = lt_suggestions[ 1 ]-component_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_suggestions[ 1 ]-projected_receipt_used_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lt_suggestions[ 1 ]-planning_shortfall_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = lt_suggestions[ 1 ]-suggested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20260105' )
      act = lt_suggestions[ 2 ]-lot_size_period_start ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20260111' )
      act = lt_suggestions[ 2 ]-lot_size_period_end ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lt_suggestions[ 2 ]-grouped_shortage_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = lt_suggestions[ 2 ]-suggested_base_quantity ).
  ENDMETHOD.

  METHOD groups_pk_lot_size.
    DATA(lo_policy_repo) = NEW lcl_prod_repl_policy_repo( ).
    lo_policy_repo->set_policies( it_policies = VALUE #(
      ( lot_size_procedure           = 'PK'
        planning_calendar_id         = 'PC1'
        material                     = 'MAT-PK'
        plant                        = '1000'
        base_unit                    = 'EA'
        order_multiple_base_quantity = '2.000' ) ) ).
    DATA(lo_calendar_repo) = NEW lcl_prod_cal_period_repo( ).
    lo_calendar_repo->set_periods( it_periods = VALUE #(
      ( plant                = '1000'
        planning_calendar_id = 'PC1'
        start_date           = '20261004'
        end_date             = '20261005' )
      ( plant                = '1000'
        planning_calendar_id = 'PC1'
        start_date           = '20261006'
        end_date             = '20261010' ) ) ).
    DATA(lo_cut) = NEW zcl_prod_comp_service(
      io_repl_policy_repo       = lo_policy_repo
      io_planning_calendar_repo = lo_calendar_repo ).
    DATA(lt_suggestions) = lo_cut->suggest_comp_replenishment(
      it_shortages          = VALUE #(
        ( material                = 'MAT-PK'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261005'
          component_count         = 1
          requested_base_quantity = '3.000'
          shortfall_base_quantity = '3.000' )
        ( material                = 'MAT-PK'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261004'
          component_count         = 2
          requested_base_quantity = '2.000'
          shortfall_base_quantity = '2.000' )
        ( material                = 'MAT-PK'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261006'
          component_count         = 1
          requested_base_quantity = '4.000'
          shortfall_base_quantity = '4.000' )
        ( material                = 'MAT-PK'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261011'
          component_count         = 1
          requested_base_quantity = '1.000'
          shortfall_base_quantity = '1.000' ) )
      it_policies           = VALUE #( )
      it_projected_receipts = VALUE #(
        ( material        = 'MAT-PK'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261004'
          quantity        = '2.000'
          source_type     = 'PO'
          source_document = '4500001236'
          source_item     = '00010' ) )
      iv_as_of_date         = '20261001' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_suggestions ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PC1'
      act = lt_suggestions[ 1 ]-planning_calendar_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MARC'
      act = lt_suggestions[ 1 ]-policy_origin ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261004' )
      act = lt_suggestions[ 1 ]-lot_size_period_start ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261005' )
      act = lt_suggestions[ 1 ]-lot_size_period_end ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lt_suggestions[ 1 ]-grouped_shortage_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_suggestions[ 1 ]-projected_receipt_used_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_suggestions[ 1 ]-planning_shortfall_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_suggestions[ 1 ]-suggested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261006' )
      act = lt_suggestions[ 2 ]-lot_size_period_start ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261010' )
      act = lt_suggestions[ 2 ]-lot_size_period_end ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lt_suggestions[ 2 ]-grouped_shortage_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lt_suggestions[ 3 ]-grouped_shortage_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '00000000' )
      act = lt_suggestions[ 3 ]-lot_size_period_start ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_calendar_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD suggests_max_stock_replen.
    DATA(lo_policy_repo) = NEW lcl_prod_repl_policy_repo( ).
    lo_policy_repo->set_policies( it_policies = VALUE #(
      ( lot_size_procedure     = 'HB'
        procurement_type       = 'F'
        material               = 'MAT-HB-MARC'
        plant                  = '1000'
        base_unit              = 'EA'
        maximum_stock_quantity = '10.000' ) ) ).
    DATA(lo_cut) = NEW zcl_prod_comp_service(
      io_repl_policy_repo = lo_policy_repo ).

    DATA(lt_suggestions) = lo_cut->suggest_comp_replenishment(
      it_shortages = VALUE #(
        ( material                = 'MAT-HB-MARC'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261020'
          component_count         = 1
          requested_base_quantity = '12.000'
          shortfall_base_quantity = '12.000' )
        ( material                = 'MAT-HB-CALLER'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261021'
          component_count         = 1
          requested_base_quantity = '3.000'
          shortfall_base_quantity = '3.000' ) )
      it_policies  = VALUE #(
        ( lot_size_procedure     = 'HB'
          material               = 'MAT-HB-CALLER'
          plant                  = '1000'
          base_unit              = 'EA'
          maximum_stock_quantity = '8.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_suggestions ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MARC'
      act = lt_suggestions[ 1 ]-policy_origin ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lt_suggestions[ 1 ]-maximum_stock_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = lt_suggestions[ 1 ]-suggested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = lt_suggestions[ 1 ]-final_receipt_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CALLER'
      act = lt_suggestions[ 2 ]-policy_origin ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = lt_suggestions[ 2 ]-suggested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lt_suggestions[ 2 ]-rounding_surplus_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_policy_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD categorizes_repl_urgency.
    DATA(lo_calendar) = NEW lcl_prod_repl_calendar( ).
    lo_calendar->set_working_dates( it_dates = VALUE #(
      ( '20261014' )
      ( '20261015' )
      ( '20261020' ) ) ).
    DATA(lo_cut) = NEW zcl_prod_comp_service(
      io_factory_calendar_api = lo_calendar ).

    DATA(lt_suggestions) = lo_cut->suggest_comp_replenishment(
      it_shortages  = VALUE #(
        ( material                = 'MAT-PR-1'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261014'
          component_count         = 1
          requested_base_quantity = '1.000'
          shortfall_base_quantity = '1.000' )
        ( material                = 'MAT-PR-2'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261015'
          component_count         = 1
          requested_base_quantity = '1.000'
          shortfall_base_quantity = '1.000' )
        ( material                = 'MAT-PR-3'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261020'
          component_count         = 1
          requested_base_quantity = '1.000'
          shortfall_base_quantity = '1.000' )
        ( material                = 'MAT-PR-4'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261020'
          component_count         = 1
          requested_base_quantity = '1.000'
          shortfall_base_quantity = '1.000' ) )
      it_policies   = VALUE #(
        ( material            = 'MAT-PR-1'
          plant               = '1000'
          base_unit           = 'EA'
          lot_size_procedure  = 'EX'
          procurement_type    = 'F'
          factory_calendar_id = '01' )
        ( material            = 'MAT-PR-2'
          plant               = '1000'
          base_unit           = 'EA'
          lot_size_procedure  = 'EX'
          procurement_type    = 'F'
          factory_calendar_id = '01' )
        ( material            = 'MAT-PR-3'
          plant               = '1000'
          base_unit           = 'EA'
          lot_size_procedure  = 'EX'
          procurement_type    = 'F'
          factory_calendar_id = '01' )
        ( material           = 'MAT-PR-4'
          plant              = '1000'
          base_unit          = 'EA'
          lot_size_procedure = 'EX'
          procurement_type   = 'E' ) )
      iv_as_of_date = '20261015' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_suggestions ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_prod_comp_service=>c_pr_urgency_overdue
      act = lt_suggestions[ 1 ]-pr_release_urgency ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_prod_comp_service=>c_pr_urgency_due_today
      act = lt_suggestions[ 2 ]-pr_release_urgency ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_prod_comp_service=>c_pr_urgency_upcoming
      act = lt_suggestions[ 3 ]-pr_release_urgency ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_prod_comp_service=>c_pr_urgency_no_estimate
      act = lt_suggestions[ 4 ]-pr_release_urgency ).
  ENDMETHOD.

  METHOD suggests_comp_repl_from_stock.
    DATA(lo_stock_repository) = NEW lcl_prod_stock_repository( ).
    lo_stock_repository->set_projected_receipts(
      it_receipts = VALUE #(
        ( material             = 'MAT-AUTO'
          plant                = '1000'
          base_unit            = 'EA'
          receipt_date         = '20261021'
          quantity             = '0.250'
          source_type          = 'PO'
          source_document      = '4500000020'
          source_item          = '00010'
          source_schedule_line = '0001' )
        ( material             = 'MAT-AUTO'
          plant                = '1000'
          base_unit            = 'EA'
          receipt_date         = '20261022'
          quantity             = '0.250'
          source_type          = 'STO_IN_TRANSIT'
          source_document      = '0080000020'
          source_item          = '00020'
          source_schedule_line = '0002' )
        ( material        = 'MAT-AUTO'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261023'
          quantity        = '2.000'
          source_type     = 'PRODUCTION'
          source_document = '0000004720'
          source_item     = '0010' ) ) ).
    DATA(lo_stock_service) = NEW zcl_stock_service(
      io_stock_repository = lo_stock_repository ).
    DATA(lo_cut) = NEW zcl_prod_comp_service(
      io_stock_service = lo_stock_service ).

    DATA(lt_suggestions) = lo_cut->suggest_comp_repl_from_stock(
      it_shortages              = VALUE #(
        ( material                = 'MAT-AUTO'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261022'
          component_count         = 1
          affected_order_count    = 1
          requested_base_quantity = '0.500'
          allocated_base_quantity = '0.000'
          shortfall_base_quantity = '0.500' )
        ( material                = 'MAT-AUTO'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261021'
          component_count         = 1
          affected_order_count    = 1
          requested_base_quantity = '0.500'
          allocated_base_quantity = '0.000'
          shortfall_base_quantity = '0.500' ) )
      it_policies               = VALUE #(
        ( material                     = 'MAT-AUTO'
          plant                        = '1000'
          base_unit                    = 'EA'
          lot_size_procedure           = 'EX'
          procurement_type             = 'F'
          order_multiple_base_quantity = '1.000' ) )
      iv_include_po_receipts    = abap_true
      iv_include_sto_in_transit = abap_true
      iv_include_prod_receipts  = abap_true
      iv_as_of_date             = '20261020'
      iv_net_prior_surplus      = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_suggestions ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261021' )
      act = lt_suggestions[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.250' )
      act = lt_suggestions[ 1 ]-projected_receipt_used_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000020'
      act = lt_suggestions[ 1 ]-projected_receipt_uses[ 1 ]-source_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261022' )
      act = lt_suggestions[ 2 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.250' )
      act = lt_suggestions[ 2 ]-projected_receipt_used_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.250' )
      act = lt_suggestions[ 2 ]-prior_surplus_used_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_prod_comp_service=>c_repl_status_supply
      act = lt_suggestions[ 2 ]-lead_time_status ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'STO_IN_TRANSIT'
      act = lt_suggestions[ 2 ]-projected_receipt_uses[ 1 ]-source_type ).

    DATA(lo_pr_repository) = NEW lcl_prod_stock_repository( ).
    lo_pr_repository->set_projected_receipts(
      it_receipts = VALUE #(
        ( material        = 'MAT-PR-AUTO'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261021'
          quantity        = '0.500'
          source_type     = 'PR'
          source_document = '0010001234'
          source_item     = '00010' )
        ( material        = 'MAT-PR-AUTO'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261021'
          quantity        = '0.500'
          source_type     = 'STO_PR'
          source_document = '0010001235'
          source_item     = '00020'
          source_plant    = '2000' )
        ( material        = 'MAT-PR-AUTO'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261021'
          quantity        = '0.500'
          source_type     = 'PLANNED_ORDER'
          source_document = '0000001236' )
        ( material        = 'MAT-PR-AUTO'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261021'
          quantity        = '0.500'
          source_type     = 'FIXED_PLAN_ORDER'
          source_document = '0000001237' )
        ( material             = 'MAT-PR-AUTO'
          plant                = '1000'
          base_unit            = 'EA'
          receipt_date         = '20261021'
          quantity             = '0.500'
          source_type          = 'SCHED_AGREEMENT'
          source_document      = '5500000010'
          source_item          = '00030'
          source_schedule_line = '0004' ) ) ).
    DATA(lo_pr_stock_service) = NEW zcl_stock_service(
      io_stock_repository = lo_pr_repository ).
    DATA(lo_pr_suggestion_service) = NEW zcl_prod_comp_service(
      io_stock_service = lo_pr_stock_service ).
    DATA(lt_pr_disabled) = lo_pr_suggestion_service->suggest_comp_repl_from_stock(
      it_shortages  = VALUE #(
        ( material                = 'MAT-PR-AUTO'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261021'
          component_count         = 1
          affected_order_count    = 1
          requested_base_quantity = '0.500'
          allocated_base_quantity = '0.000'
          shortfall_base_quantity = '0.500' ) )
      it_policies   = VALUE #(
        ( material                     = 'MAT-PR-AUTO'
          plant                        = '1000'
          base_unit                    = 'EA'
          lot_size_procedure           = 'EX'
          procurement_type             = 'F'
          order_multiple_base_quantity = '1.000' ) )
      iv_as_of_date = '20261020' ).
    DATA(lt_pr_enabled) = lo_pr_suggestion_service->suggest_comp_repl_from_stock(
      it_shortages           = VALUE #(
        ( material                = 'MAT-PR-AUTO'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261021'
          component_count         = 1
          affected_order_count    = 1
          requested_base_quantity = '0.500'
          allocated_base_quantity = '0.000'
          shortfall_base_quantity = '0.500' ) )
      it_policies            = VALUE #(
        ( material                     = 'MAT-PR-AUTO'
          plant                        = '1000'
          base_unit                    = 'EA'
          lot_size_procedure           = 'EX'
          procurement_type             = 'F'
          order_multiple_base_quantity = '1.000' ) )
      iv_include_pr_receipts = abap_true
      iv_as_of_date          = '20261020' ).
    DATA(lt_sto_pr_enabled) = lo_pr_suggestion_service->suggest_comp_repl_from_stock(
      it_shortages               = VALUE #(
        ( material                = 'MAT-PR-AUTO'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261021'
          component_count         = 1
          affected_order_count    = 1
          requested_base_quantity = '0.500'
          allocated_base_quantity = '0.000'
          shortfall_base_quantity = '0.500' ) )
      it_policies                = VALUE #(
        ( material                     = 'MAT-PR-AUTO'
          plant                        = '1000'
          base_unit                    = 'EA'
          lot_size_procedure           = 'EX'
          procurement_type             = 'F'
          order_multiple_base_quantity = '1.000' ) )
      iv_include_sto_pr_receipts = abap_true
      iv_as_of_date              = '20261020' ).
    DATA(lt_planned_enabled) = lo_pr_suggestion_service->suggest_comp_repl_from_stock(
      it_shortages                = VALUE #(
        ( material                = 'MAT-PR-AUTO'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261021'
          component_count         = 1
          affected_order_count    = 1
          requested_base_quantity = '0.500'
          allocated_base_quantity = '0.000'
          shortfall_base_quantity = '0.500' ) )
      it_policies                 = VALUE #(
        ( material                     = 'MAT-PR-AUTO'
          plant                        = '1000'
          base_unit                    = 'EA'
          lot_size_procedure           = 'EX'
          procurement_type             = 'F'
          order_multiple_base_quantity = '1.000' ) )
      iv_include_planned_receipts = abap_true
      iv_as_of_date               = '20261020' ).
    DATA(lt_fixed_planned_enabled) = lo_pr_suggestion_service->suggest_comp_repl_from_stock(
      it_shortages             = VALUE #(
        ( material                = 'MAT-PR-AUTO'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261021'
          component_count         = 1
          affected_order_count    = 1
          requested_base_quantity = '0.500'
          allocated_base_quantity = '0.000'
          shortfall_base_quantity = '0.500' ) )
      it_policies              = VALUE #(
        ( material                     = 'MAT-PR-AUTO'
          plant                        = '1000'
          base_unit                    = 'EA'
          lot_size_procedure           = 'EX'
          procurement_type             = 'F'
          order_multiple_base_quantity = '1.000' ) )
      iv_include_fixed_planned = abap_true
      iv_as_of_date            = '20261020' ).
    DATA(lt_sched_agreement_disabled) =
      lo_pr_suggestion_service->suggest_comp_repl_from_stock(
        it_shortages  = VALUE #(
          ( material                = 'MAT-PR-AUTO'
            plant                   = '1000'
            base_unit               = 'EA'
            required_date           = '20261021'
            component_count         = 1
            affected_order_count    = 1
            requested_base_quantity = '0.500'
            allocated_base_quantity = '0.000'
            shortfall_base_quantity = '0.500' ) )
        it_policies   = VALUE #(
          ( material                     = 'MAT-PR-AUTO'
            plant                        = '1000'
            base_unit                    = 'EA'
            lot_size_procedure           = 'EX'
            procurement_type             = 'F'
            order_multiple_base_quantity = '1.000' ) )
        iv_as_of_date = '20261020' ).
    DATA(lt_sched_agreement_enabled) =
      lo_pr_suggestion_service->suggest_comp_repl_from_stock(
        it_shortages                   = VALUE #(
          ( material                = 'MAT-PR-AUTO'
            plant                   = '1000'
            base_unit               = 'EA'
            required_date           = '20261021'
            component_count         = 1
            affected_order_count    = 1
            requested_base_quantity = '0.500'
            allocated_base_quantity = '0.000'
            shortfall_base_quantity = '0.500' ) )
        it_policies                    = VALUE #(
          ( material                     = 'MAT-PR-AUTO'
            plant                        = '1000'
            base_unit                    = 'EA'
            lot_size_procedure           = 'EX'
            procurement_type             = 'F'
            order_multiple_base_quantity = '1.000' ) )
        iv_include_sched_agmt_receipts = abap_true
        iv_as_of_date                  = '20261020' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_pr_disabled[ 1 ]-suggested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_pr_enabled[ 1 ]-projected_receipt_used_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_pr_enabled[ 1 ]-suggested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PR'
      act = lt_pr_enabled[ 1 ]-projected_receipt_uses[ 1 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_sto_pr_enabled[ 1 ]-projected_receipt_used_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'STO_PR'
      act = lt_sto_pr_enabled[ 1 ]-projected_receipt_uses[ 1 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = lt_sto_pr_enabled[ 1 ]-projected_receipt_uses[ 1 ]-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_planned_enabled[ 1 ]-projected_receipt_used_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PLANNED_ORDER'
      act = lt_planned_enabled[ 1 ]-projected_receipt_uses[ 1 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001236'
      act = lt_planned_enabled[ 1 ]-projected_receipt_uses[ 1 ]-source_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_fixed_planned_enabled[ 1 ]-projected_receipt_used_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'FIXED_PLAN_ORDER'
      act = lt_fixed_planned_enabled[ 1 ]-projected_receipt_uses[ 1 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001237'
      act = lt_fixed_planned_enabled[ 1 ]-projected_receipt_uses[ 1 ]-source_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_sched_agreement_disabled[ 1 ]-suggested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_sched_agreement_enabled[ 1 ]-projected_receipt_used_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_sched_agreement_enabled[ 1 ]-suggested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SCHED_AGREEMENT'
      act = lt_sched_agreement_enabled[ 1 ]-projected_receipt_uses[ 1 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = '5500000010'
      act = lt_sched_agreement_enabled[ 1 ]-projected_receipt_uses[ 1 ]-source_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00030'
      act = lt_sched_agreement_enabled[ 1 ]-projected_receipt_uses[ 1 ]-source_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0004'
      act = lt_sched_agreement_enabled[ 1 ]-projected_receipt_uses[ 1 ]-source_schedule_line ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0010001234'
      act = lt_pr_enabled[ 1 ]-projected_receipt_uses[ 1 ]-source_document ).
    DATA lv_bad_fixed_option_rejected TYPE abap_bool.
    TRY.
        lo_pr_suggestion_service->suggest_comp_repl_from_stock(
          it_shortages             = VALUE #(
            ( material                = 'MAT-PR-AUTO'
              plant                   = '1000'
              base_unit               = 'EA'
              required_date           = '20261021'
              component_count         = 1
              affected_order_count    = 1
              requested_base_quantity = '0.500'
              allocated_base_quantity = '0.000'
              shortfall_base_quantity = '0.500' ) )
          it_policies              = VALUE #(
            ( material           = 'MAT-PR-AUTO'
              plant              = '1000'
              base_unit          = 'EA'
              lot_size_procedure = 'EX'
              procurement_type   = 'F' ) )
          iv_include_fixed_planned = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_bad_fixed_option_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_fixed_option_rejected ).
  ENDMETHOD.

  METHOD nets_prior_surplus.
    DATA(lo_cut) = NEW zcl_prod_comp_service( ).
    DATA(lt_suggestions) = lo_cut->suggest_comp_replenishment(
      it_shortages         = VALUE #(
        ( material                = 'MAT-NET'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261023'
          component_count         = 1
          affected_order_count    = 1
          requested_base_quantity = '0.500'
          allocated_base_quantity = '0.000'
          shortfall_base_quantity = '0.500' )
        ( material                = 'MAT-NET'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261022'
          component_count         = 1
          affected_order_count    = 1
          requested_base_quantity = '0.500'
          allocated_base_quantity = '0.000'
          shortfall_base_quantity = '0.500' )
        ( material                = 'MAT-NET'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261021'
          component_count         = 1
          affected_order_count    = 1
          requested_base_quantity = '1.250'
          allocated_base_quantity = '0.000'
          shortfall_base_quantity = '1.250' ) )
      it_policies          = VALUE #(
        ( material                     = 'MAT-NET'
          plant                        = '1000'
          base_unit                    = 'EA'
          lot_size_procedure           = 'EX'
          procurement_type             = 'F'
          order_multiple_base_quantity = '1.000' ) )
      iv_as_of_date        = '20261020'
      iv_net_prior_surplus = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_suggestions ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261021' )
      act = lt_suggestions[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.250' )
      act = lt_suggestions[ 1 ]-planning_shortfall_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_suggestions[ 1 ]-suggested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.750' )
      act = lt_suggestions[ 1 ]-rounding_surplus_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261022' )
      act = lt_suggestions[ 2 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_suggestions[ 2 ]-prior_surplus_used_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_suggestions[ 2 ]-planning_shortfall_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_suggestions[ 2 ]-suggested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lt_suggestions[ 2 ]-suggested_receipt_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_prod_comp_service=>c_repl_status_covered
      act = lt_suggestions[ 2 ]-lead_time_status ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.250' )
      act = lt_suggestions[ 2 ]-rounding_surplus_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261023' )
      act = lt_suggestions[ 3 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.250' )
      act = lt_suggestions[ 3 ]-prior_surplus_used_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.250' )
      act = lt_suggestions[ 3 ]-planning_shortfall_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_suggestions[ 3 ]-suggested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.750' )
      act = lt_suggestions[ 3 ]-rounding_surplus_base_quantity ).
  ENDMETHOD.

  METHOD nets_projected_receipts.
    DATA(lo_cut) = NEW zcl_prod_comp_service( ).
    DATA(lt_suggestions) = lo_cut->suggest_comp_replenishment(
      it_shortages          = VALUE #(
        ( material                = 'MAT-RCPT'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261023'
          component_count         = 1
          affected_order_count    = 1
          requested_base_quantity = '0.500'
          allocated_base_quantity = '0.000'
          shortfall_base_quantity = '0.500' )
        ( material                = 'MAT-RCPT'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261022'
          component_count         = 1
          affected_order_count    = 1
          requested_base_quantity = '0.500'
          allocated_base_quantity = '0.000'
          shortfall_base_quantity = '0.500' )
        ( material                = 'MAT-RCPT'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261021'
          component_count         = 1
          affected_order_count    = 1
          requested_base_quantity = '1.250'
          allocated_base_quantity = '0.000'
          shortfall_base_quantity = '1.250' ) )
      it_policies           = VALUE #(
        ( material                     = 'MAT-RCPT'
          plant                        = '1000'
          base_unit                    = 'EA'
          lot_size_procedure           = 'EX'
          procurement_type             = 'F'
          order_multiple_base_quantity = '1.000' ) )
      it_projected_receipts = VALUE #(
        ( material             = 'MAT-RCPT'
          plant                = '1000'
          base_unit            = 'EA'
          receipt_date         = '20261021'
          quantity             = '0.250'
          source_type          = 'PO'
          source_document      = '4500000001'
          source_item          = '00010'
          source_schedule_line = '0001' )
        ( material        = 'MAT-RCPT'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261021'
          quantity        = '0.250'
          source_type     = 'STO'
          source_document = '0080000000'
          source_item     = '00010' )
        ( material        = 'MAT-RCPT'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261022'
          quantity        = '0.250'
          source_type     = 'STO'
          source_document = '0080000001'
          source_item     = '00020' )
        ( material        = 'MAT-RCPT'
          plant           = '1000'
          base_unit       = 'EA'
          receipt_date    = '20261023'
          quantity        = '0.500'
          source_type     = 'PRODUCTION'
          source_document = '0000004711'
          source_item     = '0010' ) )
      iv_as_of_date         = '20261020'
      iv_net_prior_surplus  = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_suggestions ) ).
    DATA(ls_first_receipt_use) =
      lt_suggestions[ 1 ]-projected_receipt_uses[ 1 ].
    cl_abap_unit_assert=>assert_equals(
      exp = 'PO'
      act = ls_first_receipt_use-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000001'
      act = ls_first_receipt_use-source_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_first_receipt_use-source_schedule_line ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.250' )
      act = ls_first_receipt_use-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_suggestions[ 1 ]-projected_receipt_uses ) ).
    DATA(ls_second_same_date_use) =
      lt_suggestions[ 1 ]-projected_receipt_uses[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      exp = '0080000000'
      act = ls_second_same_date_use-source_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261021' )
      act = lt_suggestions[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_suggestions[ 1 ]-projected_receipt_used_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.750' )
      act = lt_suggestions[ 1 ]-planning_shortfall_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_suggestions[ 1 ]-suggested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.250' )
      act = lt_suggestions[ 1 ]-rounding_surplus_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261022' )
      act = lt_suggestions[ 2 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.250' )
      act = lt_suggestions[ 2 ]-projected_receipt_used_qty ).
    DATA(ls_second_receipt_use) =
      lt_suggestions[ 2 ]-projected_receipt_uses[ 1 ].
    cl_abap_unit_assert=>assert_equals(
      exp = 'STO'
      act = ls_second_receipt_use-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0080000001'
      act = ls_second_receipt_use-source_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.250' )
      act = lt_suggestions[ 2 ]-prior_surplus_used_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_suggestions[ 2 ]-planning_shortfall_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_prod_comp_service=>c_repl_status_supply
      act = lt_suggestions[ 2 ]-lead_time_status ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261023' )
      act = lt_suggestions[ 3 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_suggestions[ 3 ]-projected_receipt_used_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_prod_comp_service=>c_repl_status_receipt
      act = lt_suggestions[ 3 ]-lead_time_status ).
  ENDMETHOD.

  METHOD rejects_bad_replenishment.
    DATA(lo_cut) = NEW zcl_prod_comp_service( ).
    DATA lv_bad_policy_rejected TYPE abap_bool.
    DATA lv_bad_week_start_rejected TYPE abap_bool.
    DATA lv_duplicate_policy_rejected TYPE abap_bool.
    DATA lv_bad_shortage_rejected TYPE abap_bool.
    DATA lv_bad_source_rejected TYPE abap_bool.
    DATA lv_partial_agreement_rejected TYPE abap_bool.
    DATA lv_mixed_source_rejected TYPE abap_bool.
    DATA lv_bad_receipt_rejected TYPE abap_bool.
    DATA lv_bad_receipt_source_pair TYPE abap_bool.
    DATA lv_bad_cal_overlap TYPE abap_bool.

    TRY.
        lo_cut->suggest_comp_replenishment(
          it_shortages = VALUE #( )
          it_policies  = VALUE #(
            ( material                     = 'MAT-1'
              plant                        = '1000'
              base_unit                    = 'EA'
              minimum_base_quantity        = '0.000'
              order_multiple_base_quantity = '-1.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_bad_policy_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_cut->suggest_comp_replenishment(
          it_shortages          = VALUE #( )
          it_policies           = VALUE #( )
          iv_week_start_weekday = 8 ).
      CATCH zcx_invalid_stock_request.
        lv_bad_week_start_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_cut->suggest_comp_replenishment(
          it_shortages                 = VALUE #( )
          it_policies                  = VALUE #( )
          it_planning_calendar_periods = VALUE #(
            ( plant                = '1000'
              planning_calendar_id = 'PC1'
              start_date           = '20261001'
              end_date             = '20261005' )
            ( plant                = '1000'
              planning_calendar_id = 'PC1'
              start_date           = '20261005'
              end_date             = '20261010' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_bad_cal_overlap = abap_true.
    ENDTRY.

    TRY.
        lo_cut->suggest_comp_replenishment(
          it_shortages = VALUE #( )
          it_policies  = VALUE #(
            ( material    = 'MAT-1' plant = '1000' base_unit = 'EA' )
            ( material    = 'MAT-1' plant = '1000' base_unit = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_duplicate_policy_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_cut->suggest_comp_replenishment(
          it_shortages = VALUE #( )
          it_policies  = VALUE #(
            ( material           = 'MAT-1'
              plant              = '1000'
              base_unit          = 'EA'
              procurement_type   = 'F'
              source_info_record = '0000001234' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_bad_source_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_cut->suggest_comp_replenishment(
          it_shortages = VALUE #( )
          it_policies  = VALUE #(
            ( material              = 'MAT-1'
              plant                 = '1000'
              base_unit             = 'EA'
              procurement_type      = 'F'
              source_vendor         = '0000100001'
              source_purchasing_org = '1000'
              source_agreement      = '4500000001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_partial_agreement_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_cut->suggest_comp_replenishment(
          it_shortages = VALUE #( )
          it_policies  = VALUE #(
            ( material              = 'MAT-1'
              plant                 = '1000'
              base_unit             = 'EA'
              procurement_type      = 'F'
              source_vendor         = '0000100001'
              source_purchasing_org = '1000'
              source_info_record    = '0000001234'
              source_category       = '0'
              source_agreement      = '4500000001'
              source_agreement_item = '00010' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_mixed_source_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_cut->suggest_comp_replenishment(
          it_shortages          = VALUE #( )
          it_policies           = VALUE #( )
          it_projected_receipts = VALUE #(
            ( material     = 'MAT-1'
              plant        = '1000'
              base_unit    = 'EA'
              receipt_date = '20261005'
              quantity     = '0.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_bad_receipt_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_cut->suggest_comp_replenishment(
          it_shortages          = VALUE #( )
          it_policies           = VALUE #( )
          it_projected_receipts = VALUE #(
            ( material     = 'MAT-1'
              plant        = '1000'
              base_unit    = 'EA'
              receipt_date = '20261005'
              quantity     = '0.500'
              source_type  = 'PO' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_bad_receipt_source_pair = abap_true.
    ENDTRY.

    TRY.
        lo_cut->suggest_comp_replenishment(
          it_shortages = VALUE #(
            ( material                = 'MAT-1'
              plant                   = '1000'
              base_unit               = 'EA'
              required_date           = '20261005'
              component_count         = 1
              affected_order_count    = 1
              requested_base_quantity = '5.000'
              allocated_base_quantity = '2.000'
              shortfall_base_quantity = '2.000' ) )
          it_policies  = VALUE #( ) ).
      CATCH zcx_invalid_stock_request.
        lv_bad_shortage_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_policy_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_week_start_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_cal_overlap ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_duplicate_policy_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_source_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_partial_agreement_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_mixed_source_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_receipt_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_receipt_source_pair ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_shortage_rejected ).
  ENDMETHOD.
ENDCLASS.
