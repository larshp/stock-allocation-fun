CLASS lcl_cost_center_stock_repo DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_repository.
    METHODS set_location_stocks
      IMPORTING
        it_stock TYPE zif_stock_repository=>ty_location_stocks.
    METHODS set_batch_stocks
      IMPORTING
        it_stock TYPE zif_stock_repository=>ty_batch_stocks.
    METHODS set_unrestricted_stock
      IMPORTING
        iv_quantity TYPE mard-labst.
    METHODS set_date_available_stock
      IMPORTING
        iv_quantity TYPE mard-labst.
    METHODS get_read_count
      RETURNING
        VALUE(rv_count) TYPE i.
  PRIVATE SECTION.
    DATA mt_location_stock TYPE zif_stock_repository=>ty_location_stocks.
    DATA mt_batch_stock TYPE zif_stock_repository=>ty_batch_stocks.
    DATA mv_unrestricted_stock TYPE mard-labst.
    DATA mv_date_available_stock TYPE mard-labst.
    DATA mv_read_count TYPE i.
ENDCLASS.

CLASS lcl_cost_center_stock_repo IMPLEMENTATION.
  METHOD set_location_stocks.
    mt_location_stock = it_stock.
  ENDMETHOD.

  METHOD set_batch_stocks.
    mt_batch_stock = it_stock.
  ENDMETHOD.

  METHOD set_unrestricted_stock.
    mv_unrestricted_stock = iv_quantity.
  ENDMETHOD.

  METHOD set_date_available_stock.
    mv_date_available_stock = iv_quantity.
  ENDMETHOD.

  METHOD get_read_count.
    rv_count = mv_read_count.
  ENDMETHOD.

  METHOD zif_stock_repository~get_unrestricted_stock.
    ADD 1 TO mv_read_count.
    rv_quantity = mv_unrestricted_stock.
  ENDMETHOD.

  METHOD zif_stock_repository~get_available_stock_by_date.
    ADD 1 TO mv_read_count.
    rv_quantity = mv_date_available_stock.
  ENDMETHOD.

  METHOD zif_stock_repository~get_projected_receipts.
  ENDMETHOD.

  METHOD zif_stock_repository~get_po_confirmed_receipts.
  ENDMETHOD.

  METHOD zif_stock_repository~get_safety_stock.
    ADD 1 TO mv_read_count.
  ENDMETHOD.

  METHOD zif_stock_repository~get_sales_order_reservations.
    ADD 1 TO mv_read_count.
  ENDMETHOD.

  METHOD zif_stock_repository~get_order_reservations_bulk.
    ADD 1 TO mv_read_count.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status.
    ADD 1 TO mv_read_count.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status_bulk.
    ADD 1 TO mv_read_count.
    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        request_id = ls_request-request_id
        material   = ls_request-material
        plant      = ls_request-plant )
        TO rt_status.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status_by_location.
    ADD 1 TO mv_read_count.
  ENDMETHOD.

  METHOD zif_stock_repository~get_location_stock_status_bulk.
    ADD 1 TO mv_read_count.
    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        request_id = ls_request-request_id
        material   = ls_request-material
        plant      = ls_request-plant )
        TO rt_status.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status_by_batch.
    ADD 1 TO mv_read_count.
  ENDMETHOD.

  METHOD zif_stock_repository~get_batch_stock_status_bulk.
    ADD 1 TO mv_read_count.
    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        request_id = ls_request-request_id
        material   = ls_request-material
        plant      = ls_request-plant )
        TO rt_status.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_by_location.
    ADD 1 TO mv_read_count.
    rt_stock = mt_location_stock.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_by_batch.
    ADD 1 TO mv_read_count.
    rt_stock = mt_batch_stock.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_cost_center_uom_repo DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_material_uom_repository.
    METHODS set_base_unit
      IMPORTING
        iv_base_unit TYPE mara-meins.
    METHODS set_alt_unit_ratio
      IMPORTING
        iv_alternative_unit TYPE marm-meinh
        iv_numerator        TYPE marm-umrez
        iv_denominator      TYPE marm-umren.
  PRIVATE SECTION.
    DATA mv_base_unit TYPE mara-meins.
    DATA mv_alternative_unit TYPE marm-meinh.
    DATA ms_ratio TYPE zif_material_uom_repository=>ty_alt_unit_ratio.
ENDCLASS.

CLASS lcl_cost_center_uom_repo IMPLEMENTATION.
  METHOD set_base_unit.
    mv_base_unit = iv_base_unit.
  ENDMETHOD.

  METHOD set_alt_unit_ratio.
    mv_alternative_unit = iv_alternative_unit.
    ms_ratio-numerator = iv_numerator.
    ms_ratio-denominator = iv_denominator.
  ENDMETHOD.

  METHOD zif_material_uom_repository~get_base_unit.
    rv_base_unit = mv_base_unit.
  ENDMETHOD.

  METHOD zif_material_uom_repository~get_alt_unit_ratio.
    IF iv_alternative_unit = mv_alternative_unit.
      rs_ratio = ms_ratio.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_cost_center_res_api DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_cc_reservation_api.
    TYPES ty_create_results TYPE STANDARD TABLE OF
      zif_cc_reservation_api=>ty_result WITH EMPTY KEY.
    METHODS set_create_result
      IMPORTING
        is_result TYPE zif_cc_reservation_api=>ty_result.
    METHODS set_create_results
      IMPORTING
        it_results TYPE ty_create_results.
    METHODS set_commit_result
      IMPORTING
        is_result TYPE zif_cc_reservation_api=>ty_commit_result.
    METHODS get_request
      RETURNING
        VALUE(rs_request) TYPE zif_cc_reservation_api=>ty_request.
    METHODS get_create_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_commit_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_rollback_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS was_test_run
      RETURNING
        VALUE(rv_test_run) TYPE abap_bool.
  PRIVATE SECTION.
    DATA ms_create_result TYPE zif_cc_reservation_api=>ty_result.
    DATA mt_create_results TYPE ty_create_results.
    DATA ms_commit_result TYPE zif_cc_reservation_api=>ty_commit_result.
    DATA ms_request TYPE zif_cc_reservation_api=>ty_request.
    DATA mv_create_count TYPE i.
    DATA mv_commit_count TYPE i.
    DATA mv_rollback_count TYPE i.
    DATA mv_test_run TYPE abap_bool.
ENDCLASS.

CLASS lcl_cost_center_res_api IMPLEMENTATION.
  METHOD set_create_result.
    ms_create_result = is_result.
    CLEAR mt_create_results.
  ENDMETHOD.

  METHOD set_create_results.
    mt_create_results = it_results.
  ENDMETHOD.

  METHOD set_commit_result.
    ms_commit_result = is_result.
  ENDMETHOD.

  METHOD get_request.
    rs_request = ms_request.
  ENDMETHOD.

  METHOD get_create_count.
    rv_count = mv_create_count.
  ENDMETHOD.

  METHOD get_commit_count.
    rv_count = mv_commit_count.
  ENDMETHOD.

  METHOD get_rollback_count.
    rv_count = mv_rollback_count.
  ENDMETHOD.

  METHOD was_test_run.
    rv_test_run = mv_test_run.
  ENDMETHOD.

  METHOD zif_cc_reservation_api~create_reservation.
    ADD 1 TO mv_create_count.
    ms_request = is_request.
    mv_test_run = iv_test_run.
    IF mt_create_results IS INITIAL.
      rs_result = ms_create_result.
    ELSE.
      READ TABLE mt_create_results INTO rs_result INDEX mv_create_count.
      IF sy-subrc <> 0.
        rs_result = ms_create_result.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD zif_cc_reservation_api~commit.
    ADD 1 TO mv_commit_count.
    rs_result = ms_commit_result.
  ENDMETHOD.

  METHOD zif_cc_reservation_api~rollback.
    ADD 1 TO mv_rollback_count.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_cc_atp_api_double DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_material_availability_api.
    METHODS set_result
      IMPORTING
        is_result TYPE zif_material_availability_api=>ty_result.
    METHODS get_request
      RETURNING
        VALUE(rs_request) TYPE zif_material_availability_api=>ty_request.
    METHODS get_check_count
      RETURNING
        VALUE(rv_count) TYPE i.
  PRIVATE SECTION.
    DATA ms_result TYPE zif_material_availability_api=>ty_result.
    DATA ms_request TYPE zif_material_availability_api=>ty_request.
    DATA mv_check_count TYPE i.
ENDCLASS.

CLASS lcl_cc_atp_api_double IMPLEMENTATION.
  METHOD set_result.
    ms_result = is_result.
  ENDMETHOD.

  METHOD get_request.
    rs_request = ms_request.
  ENDMETHOD.

  METHOD get_check_count.
    rv_count = mv_check_count.
  ENDMETHOD.

  METHOD zif_material_availability_api~check_availability.
    ADD 1 TO mv_check_count.
    ms_request = is_request.
    rs_result = ms_result.
    rs_result-material = is_request-material.
    rs_result-plant = is_request-plant.
    rs_result-unit = is_request-unit.
    rs_result-check_rule = is_request-check_rule.
    rs_result-required_date = is_request-required_date.
    rs_result-requested_quantity = is_request-requested_quantity.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_cost_center_reservation DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_stock_repo TYPE REF TO lcl_cost_center_stock_repo.
    DATA mo_uom_repo TYPE REF TO lcl_cost_center_uom_repo.
    DATA mo_res_api TYPE REF TO lcl_cost_center_res_api.
    DATA mo_atp_api TYPE REF TO lcl_cc_atp_api_double.
    DATA mo_cut TYPE REF TO zcl_cc_reservation_service.
    METHODS setup.
    METHODS previews_cost_center_demands FOR TESTING.
    METHODS rejects_bad_cc_demands FOR TESTING.
    METHODS empty_cc_demands_skip_read FOR TESTING.
    METHODS previews_dated_cc_demands FOR TESTING.
    METHODS rejects_bad_dated_cc_demands FOR TESTING.
    METHODS empty_dated_cc_demands_skip FOR TESTING.
    METHODS previews_dated_cc_atp FOR TESTING.
    METHODS rejects_dated_cc_atp_rule FOR TESTING.
    METHODS previews_cc_locations FOR TESTING.
    METHODS rejects_bad_cc_locs FOR TESTING.
    METHODS empty_cc_locs_skip_read FOR TESTING.
    METHODS previews_cc_batches FOR TESTING.
    METHODS rejects_bad_cc_batches FOR TESTING.
    METHODS empty_cc_batches_skip FOR TESTING.
    METHODS previews_cc_fefo_demands FOR TESTING.
    METHODS rejects_bad_cc_fefo FOR TESTING.
    METHODS empty_cc_fefo_skip FOR TESTING.
    METHODS reserves_cost_centers_atomic FOR TESTING.
    METHODS reserves_atomic_cc_batches FOR TESTING.
    METHODS reserves_atomic_cc_fefo FOR TESTING.
    METHODS rejects_short_atomic_batch FOR TESTING.
    METHODS rejects_short_atomic_cc FOR TESTING.
    METHODS rolls_back_atomic_cc_create FOR TESTING.
    METHODS rejects_dupe_atomic_numbers FOR TESTING.
    METHODS rolls_back_atomic_cc_commit FOR TESTING.
    METHODS simulates_atomic_cc FOR TESTING.
    METHODS prechecks_atomic_cc_atp FOR TESTING.
    METHODS rejects_short_atomic_cc_atp FOR TESTING.
    METHODS rejects_atomic_cc_atp_opts FOR TESTING.
    METHODS rejects_bad_atomic_cc FOR TESTING.
    METHODS empty_atomic_cc_demands FOR TESTING.
    METHODS commits_partial_res FOR TESTING.
    METHODS converts_alt_unit_res FOR TESTING.
    METHODS allocates_across_locations FOR TESTING.
    METHODS prefers_location_first FOR TESTING.
    METHODS splits_batch_by_location FOR TESTING.
    METHODS falls_back_for_batch FOR TESTING.
    METHODS reserves_fefo_batches FOR TESTING.
    METHODS falls_back_for_fefo FOR TESTING.
    METHODS previews_fefo_without_bapi FOR TESTING.
    METHODS previews_cost_center_atp FOR TESTING.
    METHODS rejects_short_atp_reservation FOR TESTING.
    METHODS rejects_late_atp_reservation FOR TESTING.
    METHODS reserves_atp_confirmed FOR TESTING.
    METHODS rejects_atp_gate_without_check FOR TESTING.
    METHODS rejects_atp_without_rule FOR TESTING.
    METHODS previews_short_full_req FOR TESTING.
    METHODS selects_exact_batch FOR TESTING.
    METHODS requires_full_stock FOR TESTING.
    METHODS simulates_without_commit FOR TESTING.
    METHODS rolls_back_create_error FOR TESTING.
    METHODS rolls_back_commit_error FOR TESTING.
    METHODS skips_empty_stock FOR TESTING.
    METHODS rejects_blank_location FOR TESTING.
    METHODS rejects_fallback_no_loc FOR TESTING.
    METHODS rejects_unknown_unit FOR TESTING.
    METHODS rejects_zero_base_qty FOR TESTING.
    METHODS rejects_fefo_with_batch FOR TESTING.
    METHODS rejects_min_days_without_fefo FOR TESTING.
    METHODS rejects_negative_fefo_days FOR TESTING.
ENDCLASS.

CLASS ltcl_cost_center_reservation IMPLEMENTATION.
  METHOD setup.
    mo_stock_repo = NEW lcl_cost_center_stock_repo( ).
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '6.000' ) ) ).
    mo_uom_repo = NEW lcl_cost_center_uom_repo( ).
    mo_uom_repo->set_base_unit( iv_base_unit = 'EA' ).
    mo_res_api = NEW lcl_cost_center_res_api( ).
    mo_atp_api = NEW lcl_cc_atp_api_double( ).
    mo_res_api->set_create_result(
      is_result = VALUE #(
        reservation_number = '9000000001'
        is_successful      = abap_true ) ).
    mo_res_api->set_create_results(
      it_results = VALUE #(
        ( reservation_number = '9000000001' is_successful = abap_true )
        ( reservation_number = '9000000002' is_successful = abap_true )
        ( reservation_number = '9000000003' is_successful = abap_true )
        ( reservation_number = '9000000004' is_successful = abap_true )
        ( reservation_number = '9000000005' is_successful = abap_true ) ) ).
    mo_res_api->set_commit_result(
      is_result = VALUE #( is_successful = abap_true ) ).
    mo_cut = NEW zcl_cc_reservation_service(
      io_stock_repository          = mo_stock_repo
      io_reservation_api           = mo_res_api
      io_uom_repository            = mo_uom_repo
      io_material_availability_api = mo_atp_api ).
  ENDMETHOD.

  METHOD previews_cost_center_demands.
    mo_stock_repo->set_unrestricted_stock( iv_quantity = '14.000' ).
    mo_uom_repo->set_alt_unit_ratio(
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lt_previews) = mo_cut->preview_cost_center_demands(
      it_demands = VALUE #(
        ( request_id         = 'CC-1'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          requested_quantity = '4.000'
          unit               = 'EA' )
        ( request_id         = 'CC-2'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          requested_quantity = '1.000'
          unit               = 'BOX' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_previews ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-1'
      act = lt_previews[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_previews[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = lt_previews[ 2 ]-allocation-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lt_previews[ 2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_previews[ 2 ]-allocation-allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_stock_repo->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_cc_demands.
    DATA lv_duplicate_raised TYPE abap_bool.
    DATA lv_blank_raised TYPE abap_bool.
    DATA lv_flag_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_cost_center_demands(
          it_demands = VALUE #(
            ( request_id         = 'CC-1'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              requested_quantity = '1.000'
              unit               = 'EA' )
            ( request_id         = 'CC-1'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-200'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_duplicate_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_demands(
          it_demands = VALUE #(
            ( request_id         = 'CC-3'
              plant              = '1000'
              cost_center        = 'COST-100'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_blank_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_demands(
          it_demands              = VALUE #(
            ( request_id         = 'CC-4'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_flag_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_duplicate_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_blank_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_flag_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD empty_cc_demands_skip_read.
    DATA(lt_previews) = mo_cut->preview_cost_center_demands(
      it_demands = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_previews ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD previews_dated_cc_demands.
    mo_stock_repo->set_date_available_stock( iv_quantity = '14.000' ).
    mo_uom_repo->set_alt_unit_ratio(
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lt_previews) = mo_cut->preview_cost_center_by_date(
      it_demands = VALUE #(
        ( request_id         = 'LATE'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = '20261020'
          priority           = 99
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'EARLY-LOW'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          required_date      = '20261001'
          priority           = 0
          requested_quantity = '1.000'
          unit               = 'BOX' )
        ( request_id         = 'EARLY-HIGH'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-300'
          required_date      = '20261001'
          priority           = 10
          requested_quantity = '4.000'
          unit               = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_previews ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LATE'
      act = lt_previews[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_previews[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lt_previews[ 2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_previews[ 3 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = lt_previews[ 2 ]-allocation-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_previews[ 2 ]-allocation-allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD previews_dated_cc_atp.
    mo_stock_repo->set_date_available_stock( iv_quantity = '20.000' ).
    mo_uom_repo->set_alt_unit_ratio(
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    mo_atp_api->set_result(
      is_result = VALUE #(
        is_fully_available = abap_true
        is_check_relevant  = abap_true ) ).

    DATA(lt_previews) = mo_cut->preview_cost_center_by_date(
      it_demands        = VALUE #(
        ( request_id         = 'ATP-LATER'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = '20261020'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'ATP-BOX'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          required_date      = '20261001'
          priority           = 10
          requested_quantity = '1.000'
          unit               = 'BOX' )
        ( request_id         = 'ATP-EARLY'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-300'
          required_date      = '20261001'
          priority           = 0
          requested_quantity = '1.000'
          unit               = 'EA' ) )
      iv_check_atp      = abap_true
      iv_atp_check_rule = 'A' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_previews ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'ATP-LATER'
      act = lt_previews[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_previews[ 1 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_previews[ 1 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_previews[ 2 ]-atp_result-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_previews[ 2 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_previews[ 3 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_previews[ 2 ]-allocation-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_atp_api->get_check_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_dated_cc_atp_rule.
    DATA lv_flag_raised TYPE abap_bool.
    DATA lv_rule_raised TYPE abap_bool.
    DATA lt_demands TYPE zcl_cc_reservation_service=>ty_dated_preview_demands.
    lt_demands = VALUE #(
        ( request_id         = 'ATP-VALIDATION'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = '20261001'
          requested_quantity = '1.000'
          unit               = 'EA' ) ).

    TRY.
        mo_cut->preview_cost_center_by_date(
          it_demands   = lt_demands
          iv_check_atp = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_flag_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_by_date(
          it_demands   = lt_demands
          iv_check_atp = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_rule_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_flag_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rule_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_atp_api->get_check_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_dated_cc_demands.
    DATA lv_duplicate_raised TYPE abap_bool.
    DATA lv_date_raised TYPE abap_bool.
    DATA lv_flag_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_cost_center_by_date(
          it_demands = VALUE #(
            ( request_id         = 'DUP'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              required_date      = '20261001'
              requested_quantity = '1.000'
              unit               = 'EA' )
            ( request_id         = 'DUP'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-200'
              required_date      = '20261002'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_duplicate_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_by_date(
          it_demands = VALUE #(
            ( request_id         = 'NO-DATE'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_date_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_by_date(
          it_demands             = VALUE #(
            ( request_id         = 'BAD-FLAG'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              required_date      = '20261001'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          iv_include_po_receipts = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_flag_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_duplicate_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_date_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_flag_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD empty_dated_cc_demands_skip.
    DATA(lt_previews) = mo_cut->preview_cost_center_by_date(
      it_demands = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_previews ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD previews_cc_locations.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '3.000' )
        ( storage_location   = '0002'
          available_quantity = '4.000' )
        ( storage_location   = '0003'
          available_quantity = '3.000' ) ) ).
    mo_uom_repo->set_alt_unit_ratio(
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lt_previews) = mo_cut->preview_cost_center_locations(
      it_demands                   = VALUE #(
        ( request_id         = 'CC-LOC-1'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          storage_location   = '0002'
          requested_quantity = '3.000'
          unit               = 'EA' )
        ( request_id                  = 'CC-LOC-2'
          material                    = 'MAT-1'
          plant                       = '1000'
          cost_center                 = 'COST-200'
          storage_location            = '0002'
          fallback_to_other_locations = abap_true
          requested_quantity          = '2.000'
          unit                        = 'BOX' ) )
      it_location_priority         = VALUE #(
        ( '0003' )
        ( '0001' ) )
      it_allowed_storage_locations = VALUE #(
        ( '0002' )
        ( '0003' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_previews ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-LOC-1'
      act = lt_previews[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_previews[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_previews[ 1 ]-storage_allocations[ 1 ]-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_previews[ 2 ]-allocation-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_previews[ 2 ]-allocation-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_previews[ 2 ]-storage_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_previews[ 2 ]-storage_allocations[ 1 ]-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_previews[ 2 ]-storage_allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = lt_previews[ 2 ]-storage_allocations[ 2 ]-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.500' )
      act = lt_previews[ 2 ]-storage_allocations[ 2 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_stock_repo->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_cc_locs.
    DATA lv_duplicate_raised TYPE abap_bool.
    DATA lv_flag_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_cost_center_locations(
          it_demands = VALUE #(
            ( request_id         = 'DUP'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              requested_quantity = '1.000'
              unit               = 'EA' )
            ( request_id         = 'DUP'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-200'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_duplicate_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_locations(
          it_demands = VALUE #(
            ( request_id                  = 'BAD-FLAG'
              material                    = 'MAT-1'
              plant                       = '1000'
              cost_center                 = 'COST-100'
              fallback_to_other_locations = 'Y'
              requested_quantity          = '1.000'
              unit                        = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_flag_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_duplicate_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_flag_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD empty_cc_locs_skip_read.
    DATA(lt_previews) = mo_cut->preview_cost_center_locations(
      it_demands = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_previews ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD previews_cc_batches.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'BATCH-1'
          expiration_date    = '20270101'
          available_quantity = '3.000' )
        ( storage_location   = '0002'
          batch              = 'BATCH-1'
          expiration_date    = '20270101'
          available_quantity = '4.000' )
        ( storage_location   = '0003'
          batch              = 'BATCH-1'
          expiration_date    = '20270101'
          available_quantity = '2.000' )
        ( storage_location   = '0001'
          batch              = 'BATCH-2'
          expiration_date    = '20280101'
          available_quantity = '20.000' ) ) ).
    mo_uom_repo->set_alt_unit_ratio(
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    DATA(lt_previews) = mo_cut->preview_cost_center_batches(
      it_demands           = VALUE #(
        ( request_id         = 'CC-BATCH-1'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          batch              = 'BATCH-1'
          storage_location   = '0002'
          requested_quantity = '3.000'
          unit               = 'EA' )
        ( request_id                  = 'CC-BATCH-2'
          material                    = 'MAT-1'
          plant                       = '1000'
          cost_center                 = 'COST-200'
          batch                       = 'BATCH-1'
          storage_location            = '0002'
          fallback_to_other_locations = abap_true
          requested_quantity          = '2.000'
          unit                        = 'BOX' )
        ( request_id         = 'CC-BATCH-3'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-300'
          batch              = 'BATCH-1'
          requested_quantity = '1.000'
          unit               = 'EA' ) )
      it_location_priority = VALUE #(
        ( '0003' )
        ( '0001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_previews ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-BATCH-1'
      act = lt_previews[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BATCH-1'
      act = lt_previews[ 1 ]-selected_batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20270101'
      act = lt_previews[ 1 ]-batch_allocations[ 1 ]-batch_allocation-expiration_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_previews[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_previews[ 2 ]-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_previews[ 2 ]-batch_allocations[ 1 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_previews[ 2 ]-batch_allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = lt_previews[ 2 ]-batch_allocations[ 2 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_previews[ 2 ]-batch_allocations[ 2 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_previews[ 2 ]-batch_allocations[ 3 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_previews[ 2 ]-batch_allocations[ 3 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BATCH-1'
      act = lt_previews[ 3 ]-selected_batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lt_previews[ 3 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_previews[ 3 ]-allocation-allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_previews[ 3 ]-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_previews[ 3 ]-batch_allocations[ 1 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_stock_repo->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_cc_batches.
    DATA lv_duplicate_raised TYPE abap_bool.
    DATA lv_batch_raised TYPE abap_bool.
    DATA lv_flag_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_cost_center_batches(
          it_demands = VALUE #(
            ( request_id         = 'DUP-BATCH'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              batch              = 'BATCH-1'
              requested_quantity = '1.000'
              unit               = 'EA' )
            ( request_id         = 'DUP-BATCH'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-200'
              batch              = 'BATCH-2'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_duplicate_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_batches(
          it_demands = VALUE #(
            ( request_id         = 'NO-BATCH'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_batch_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_batches(
          it_demands = VALUE #(
            ( request_id                  = 'BAD-FLAG'
              material                    = 'MAT-1'
              plant                       = '1000'
              cost_center                 = 'COST-100'
              batch                       = 'BATCH-1'
              fallback_to_other_locations = 'Y'
              requested_quantity          = '1.000'
              unit                        = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_flag_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_duplicate_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_batch_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_flag_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD empty_cc_batches_skip.
    DATA(lt_previews) = mo_cut->preview_cost_center_batches(
      it_demands = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_previews ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD previews_cc_fefo_demands.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-OLD'
          expiration_date    = '20270101'
          available_quantity = '3.000' )
        ( storage_location   = '0003'
          batch              = 'B-OLD'
          expiration_date    = '20270101'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          batch              = 'B-PREF'
          expiration_date    = '20280101'
          available_quantity = '4.000' )
        ( storage_location   = '0001'
          batch              = 'B-SOON'
          expiration_date    = '20261020'
          available_quantity = '10.000' )
        ( storage_location   = '0003'
          batch              = 'B-LAST'
          expiration_date    = '20290101'
          available_quantity = '2.000' ) ) ).
    mo_uom_repo->set_alt_unit_ratio(
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).

    DATA(lt_previews) = mo_cut->preview_cost_center_fefo(
      it_demands           = VALUE #(
        ( request_id                  = 'FEFO-PREF'
          material                    = 'MAT-1'
          plant                       = '1000'
          cost_center                 = 'COST-100'
          storage_location            = '0002'
          fallback_to_other_locations = abap_true
          requested_quantity          = '5.000'
          unit                        = 'EA' )
        ( request_id         = 'FEFO-HARD'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          storage_location   = '0001'
          requested_quantity = '3.000'
          unit               = 'EA' )
        ( request_id         = 'FEFO-BOX'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-300'
          requested_quantity = '1.000'
          unit               = 'BOX' ) )
      it_location_priority = VALUE #(
        ( '0003' )
        ( '0001' )
        ( '0002' ) )
      iv_as_of_date        = '20261011'
      iv_min_days          = 80 ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_previews ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'FEFO-PREF'
      act = lt_previews[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261011'
      act = lt_previews[ 1 ]-as_of_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 80
      act = lt_previews[ 1 ]-minimum_shelf_life_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-PREF'
      act = lt_previews[ 1 ]-batch_allocations[ 1 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_previews[ 1 ]-batch_allocations[ 1 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-OLD'
      act = lt_previews[ 1 ]-batch_allocations[ 2 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = lt_previews[ 1 ]-batch_allocations[ 2 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lt_previews[ 1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_previews[ 2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_previews[ 2 ]-allocation-allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_previews[ 3 ]-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-OLD'
      act = lt_previews[ 3 ]-batch_allocations[ 1 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = lt_previews[ 3 ]-batch_allocations[ 1 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LAST'
      act = lt_previews[ 3 ]-batch_allocations[ 2 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_previews[ 3 ]-batch_allocations[ 1 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = lt_previews[ 3 ]-batch_allocations[ 2 ]-allocated_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_stock_repo->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_cc_fefo.
    DATA lv_duplicate_raised TYPE abap_bool.
    DATA lv_flag_raised TYPE abap_bool.
    DATA lv_days_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_cost_center_fefo(
          it_demands = VALUE #(
            ( request_id         = 'DUP-FEFO'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              requested_quantity = '1.000'
              unit               = 'EA' )
            ( request_id         = 'DUP-FEFO'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-200'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_duplicate_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_fefo(
          it_demands = VALUE #(
            ( request_id                  = 'BAD-FEFO-FLAG'
              material                    = 'MAT-1'
              plant                       = '1000'
              cost_center                 = 'COST-100'
              fallback_to_other_locations = 'Y'
              requested_quantity          = '1.000'
              unit                        = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_flag_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->preview_cost_center_fefo(
          it_demands  = VALUE #( )
          iv_min_days = -1 ).
      CATCH zcx_invalid_stock_request.
        lv_days_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_duplicate_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_flag_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_days_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD empty_cc_fefo_skip.
    DATA(lt_previews) = mo_cut->preview_cost_center_fefo(
      it_demands = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_previews ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD reserves_cost_centers_atomic.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '3.000' )
        ( storage_location   = '0002'
          available_quantity = '2.000' )
        ( storage_location   = '0003'
          available_quantity = '2.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_cost_centers_atomic(
      it_demands           = VALUE #(
        ( request_id                  = 'ATOMIC-1'
          material                    = 'MAT-1'
          plant                       = '1000'
          cost_center                 = 'COST-100'
          required_date               = '20261020'
          storage_location            = '0001'
          fallback_to_other_locations = abap_true
          requested_quantity          = '2.000'
          unit                        = 'EA' )
        ( request_id         = 'ATOMIC-2'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          required_date      = '20261022'
          requested_quantity = '3.000'
          unit               = 'EA' ) )
      it_location_priority = VALUE #(
        ( '0003' )
        ( '0002' )
        ( '0001' ) ) ).
    DATA(ls_request) = mo_res_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'ATOMIC-2'
      act = ls_result-items[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'COST-200'
      act = ls_request-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261022'
      act = ls_request-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = ls_request-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_request-items[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_request-items[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_res_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD reserves_atomic_cc_batches.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          expiration_date    = '20270101'
          available_quantity = '3.000' )
        ( storage_location   = '0002'
          batch              = 'B-1'
          expiration_date    = '20270101'
          available_quantity = '2.000' )
        ( storage_location   = '0001'
          batch              = 'B-OTHER'
          expiration_date    = '20280101'
          available_quantity = '20.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_cost_centers_atomic(
      it_demands = VALUE #(
        ( request_id                  = 'BATCH-ATOMIC-1'
          material                    = 'MAT-1'
          plant                       = '1000'
          cost_center                 = 'COST-100'
          batch                       = 'B-1'
          required_date               = '20261020'
          storage_location            = '0001'
          fallback_to_other_locations = abap_true
          requested_quantity          = '2.000'
          unit                        = 'EA' )
        ( request_id         = 'BATCH-ATOMIC-2'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          batch              = 'B-1'
          required_date      = '20261022'
          requested_quantity = '3.000'
          unit               = 'EA' ) ) ).
    DATA(ls_request) = mo_res_api->get_request( ).
    DATA(ls_selected_batch) =
      ls_result-items[ 2 ]-batch_allocations[ 1 ]-batch_allocation.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-items[ 2 ]-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_selected_batch-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_request-items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_request-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_request-items[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_request-items[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD reserves_atomic_cc_fefo.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-OLD'
          expiration_date    = '20270101'
          available_quantity = '2.000' )
        ( storage_location   = '0002'
          batch              = 'B-LATE'
          expiration_date    = '20280101'
          available_quantity = '5.000' )
        ( storage_location   = '0001'
          batch              = 'B-SOON'
          expiration_date    = '20261020'
          available_quantity = '9.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_cost_centers_atomic(
      it_demands          = VALUE #(
        ( request_id         = 'FEFO-ATOMIC-1'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = '20261020'
          requested_quantity = '2.000'
          unit               = 'EA' )
        ( request_id         = 'FEFO-ATOMIC-2'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          required_date      = '20261022'
          requested_quantity = '3.000'
          unit               = 'EA' ) )
      iv_use_fefo_batches = abap_true
      iv_fefo_as_of_date  = '20261011'
      iv_fefo_min_days    = 80 ).
    DATA(ls_request) = mo_res_api->get_request( ).
    DATA(ls_first_fefo_split) =
      ls_result-items[ 1 ]-batch_allocations[ 1 ]-batch_allocation.
    DATA(ls_second_fefo_split) =
      ls_result-items[ 2 ]-batch_allocations[ 1 ]-batch_allocation.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261011'
      act = ls_result-items[ 1 ]-fefo_as_of_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 80
      act = ls_result-items[ 1 ]-minimum_shelf_life_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-OLD'
      act = ls_first_fefo_split-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATE'
      act = ls_second_fefo_split-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATE'
      act = ls_request-items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_short_atomic_batch.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-1'
          expiration_date    = '20270101'
          available_quantity = '1.000' )
        ( storage_location   = '0001'
          batch              = 'B-OTHER'
          expiration_date    = '20280101'
          available_quantity = '20.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_cost_centers_atomic(
      it_demands = VALUE #(
        ( request_id         = 'BATCH-SHORT'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          batch              = 'B-1'
          required_date      = '20261020'
          requested_quantity = '2.000'
          unit               = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-items[ 1 ]-allocation-shortfall_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_short_atomic_cc.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '3.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_cost_centers_atomic(
      it_demands = VALUE #(
        ( request_id         = 'SHORT-1'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = '20261020'
          requested_quantity = '2.000'
          unit               = 'EA' )
        ( request_id         = 'SHORT-2'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          required_date      = '20261022'
          requested_quantity = '2.000'
          unit               = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-items[ 2 ]-allocation-shortfall_source_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_atomic_cc_create.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '5.000' ) ) ).
    mo_res_api->set_create_result(
      is_result = VALUE #(
        messages = VALUE #(
          ( type = 'E' message = 'Creation failed' ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_cost_centers_atomic(
      it_demands = VALUE #(
        ( request_id         = 'FAIL-1'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = '20261020'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'FAIL-2'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          required_date      = '20261022'
          requested_quantity = '1.000'
          unit               = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rejects_dupe_atomic_numbers.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '5.000' ) ) ).
    mo_res_api->set_create_results(
      it_results = VALUE #(
        ( reservation_number = '9000000001'
          is_successful      = abap_true )
        ( reservation_number = '9000000001'
          is_successful      = abap_true ) ) ).

    DATA(ls_result) = mo_cut->reserve_cost_centers_atomic(
      it_demands = VALUE #(
        ( request_id         = 'DUPLICATE-1'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = '20261020'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'DUPLICATE-2'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          required_date      = '20261022'
          requested_quantity = '1.000'
          unit               = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-items[ 1 ]-reservation_result-reservation_number ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-items[ 2 ]-reservation_result-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Reservation API returned a duplicate reservation number'
      act = ls_result-messages[ type = 'E' ]-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_res_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_atomic_cc_commit.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '5.000' ) ) ).
    mo_res_api->set_commit_result(
      is_result = VALUE #(
        is_successful = abap_false
        message       = VALUE #(
          type    = 'E'
          message = 'Commit failed' ) ) ).

    DATA(ls_result) = mo_cut->reserve_cost_centers_atomic(
      it_demands = VALUE #(
        ( request_id         = 'COMMIT-1'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = '20261020'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'COMMIT-2'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          required_date      = '20261022'
          requested_quantity = '1.000'
          unit               = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-items[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-items[ 1 ]-reservation_result-reservation_number ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-items[ 2 ]-reservation_result-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_res_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD simulates_atomic_cc.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '5.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_cost_centers_atomic(
      it_demands  = VALUE #(
        ( request_id         = 'TEST-ATOMIC'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = '20261020'
          requested_quantity = '1.000'
          unit               = 'EA' ) )
      iv_test_run = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-items[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = mo_res_api->was_test_run( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD prechecks_atomic_cc_atp.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '10.000' ) ) ).
    mo_uom_repo->set_alt_unit_ratio(
      iv_alternative_unit = 'BOX'
      iv_numerator        = 2
      iv_denominator      = 1 ).
    mo_atp_api->set_result(
      is_result = VALUE #(
        is_fully_available = abap_true
        is_check_relevant  = abap_true ) ).

    DATA(ls_result) = mo_cut->reserve_cost_centers_atomic(
      it_demands        = VALUE #(
        ( request_id         = 'ATP-GROUP-1'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = '20261020'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'ATP-GROUP-2'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          required_date      = '20261020'
          requested_quantity = '1.000'
          unit               = 'BOX' )
        ( request_id         = 'ATP-GROUP-3'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-300'
          required_date      = '20261022'
          requested_quantity = '1.000'
          unit               = 'EA' ) )
      iv_check_atp      = abap_true
      iv_atp_check_rule = 'A' ).
    DATA(ls_atp_request) = mo_atp_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-items[ 1 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-items[ 2 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-items[ 2 ]-allocation-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-items[ 3 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_atp_request-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_atp_api->get_check_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = mo_res_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_short_atomic_cc_atp.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '10.000' ) ) ).
    mo_atp_api->set_result(
      is_result = VALUE #(
        confirmed_date     = '20261020'
        confirmed_quantity = '1.000'
        is_fully_available = abap_false
        is_check_relevant  = abap_true ) ).

    DATA(ls_result) = mo_cut->reserve_cost_centers_atomic(
      it_demands                  = VALUE #(
        ( request_id         = 'ATP-SHORT-1'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-100'
          required_date      = '20261020'
          requested_quantity = '2.000'
          unit               = 'EA' )
        ( request_id         = 'ATP-SHORT-2'
          material           = 'MAT-1'
          plant              = '1000'
          cost_center        = 'COST-200'
          required_date      = '20261020'
          requested_quantity = '1.000'
          unit               = 'EA' ) )
      iv_check_atp                = abap_true
      iv_atp_check_rule           = 'A'
      iv_require_atp_confirmation = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-items[ 1 ]-cumulative_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-items[ 2 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-items[ 2 ]-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_atp_api->get_check_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rejects_atomic_cc_atp_opts.
    DATA lv_flag_raised TYPE abap_bool.
    DATA lv_rule_raised TYPE abap_bool.
    DATA lt_demands TYPE zcl_cc_reservation_service=>ty_atomic_reservation_demands.

    lt_demands = VALUE #(
      ( request_id         = 'ATP-OPTIONS'
        material           = 'MAT-1'
        plant              = '1000'
        cost_center        = 'COST-100'
        required_date      = '20261020'
        requested_quantity = '1.000'
        unit               = 'EA' ) ).

    TRY.
        mo_cut->reserve_cost_centers_atomic(
          it_demands   = lt_demands
          iv_check_atp = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_flag_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->reserve_cost_centers_atomic(
          it_demands   = lt_demands
          iv_check_atp = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_rule_raised = abap_true.
    ENDTRY.

    DATA(ls_result) = mo_cut->reserve_cost_centers_atomic(
      it_demands                  = lt_demands
      iv_require_atp_confirmation = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_flag_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rule_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'E'
      act = ls_result-messages[ 1 ]-type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_atp_api->get_check_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_atomic_cc.
    DATA lv_duplicate_raised TYPE abap_bool.
    DATA lv_location_raised TYPE abap_bool.
    DATA lv_flag_raised TYPE abap_bool.
    DATA lv_mixed_batch_raised TYPE abap_bool.
    DATA lv_fefo_batch_raised TYPE abap_bool.
    DATA lv_fefo_flag_raised TYPE abap_bool.
    DATA lv_min_days_raised TYPE abap_bool.
    DATA lt_valid_demands TYPE zcl_cc_reservation_service=>ty_atomic_reservation_demands.

    lt_valid_demands = VALUE #(
      ( request_id         = 'VALID-ATOMIC'
        material           = 'MAT-1'
        plant              = '1000'
        cost_center        = 'COST-100'
        required_date      = '20261020'
        requested_quantity = '1.000'
        unit               = 'EA' ) ).

    TRY.
        mo_cut->reserve_cost_centers_atomic(
          it_demands = VALUE #(
            ( request_id         = 'DUP-ATOMIC'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              required_date      = '20261020'
              requested_quantity = '1.000'
              unit               = 'EA' )
            ( request_id         = 'DUP-ATOMIC'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-200'
              required_date      = '20261022'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_duplicate_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->reserve_cost_centers_atomic(
          it_demands = VALUE #(
            ( request_id                  = 'NO-LOCATION'
              material                    = 'MAT-1'
              plant                       = '1000'
              cost_center                 = 'COST-100'
              required_date               = '20261020'
              fallback_to_other_locations = abap_true
              requested_quantity          = '1.000'
              unit                        = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_location_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->reserve_cost_centers_atomic(
          it_demands = VALUE #(
            ( request_id         = 'MIXED-BATCH-1'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              batch              = 'B-1'
              required_date      = '20261020'
              requested_quantity = '1.000'
              unit               = 'EA' )
            ( request_id         = 'MIXED-BATCH-2'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-200'
              required_date      = '20261022'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_mixed_batch_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->reserve_cost_centers_atomic(
          it_demands          = VALUE #(
            ( request_id         = 'FEFO-AND-BATCH'
              material           = 'MAT-1'
              plant              = '1000'
              cost_center        = 'COST-100'
              batch              = 'B-1'
              required_date      = '20261020'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          iv_use_fefo_batches = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_fefo_batch_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->reserve_cost_centers_atomic(
          it_demands          = lt_valid_demands
          iv_use_fefo_batches = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_fefo_flag_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->reserve_cost_centers_atomic(
          it_demands       = lt_valid_demands
          iv_fefo_min_days = -1 ).
      CATCH zcx_invalid_stock_request.
        lv_min_days_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->reserve_cost_centers_atomic(
          it_demands              = VALUE #( )
          iv_protect_safety_stock = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_flag_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_duplicate_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_location_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_flag_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_mixed_batch_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_fefo_batch_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_fefo_flag_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_min_days_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD empty_atomic_cc_demands.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->reserve_cost_centers_atomic(
          it_demands = VALUE #( ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD commits_partial_res.
    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_storage_location   = '0001'
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '10.000'
      iv_unit               = 'EA'
      iv_required_date      = '20261001' ).
    DATA(ls_request) = mo_res_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '9000000001'
      act = ls_result-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MAT-1'
      act = ls_request-material ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = ls_request-plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_request-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'COST-100'
      act = ls_request-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261001'
      act = ls_request-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD converts_alt_unit_res.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '18.000' ) ) ).
    mo_uom_repo->set_alt_unit_ratio(
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).

    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_storage_location   = '0001'
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '2.000'
      iv_unit               = 'BOX' ).
    DATA(ls_request) = mo_res_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = ls_result-source_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '24.000' )
      act = ls_result-base_requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '18.000' )
      act = ls_result-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_request-items[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '18.000' )
      act = ls_request-items[ 1 ]-quantity ).
  ENDMETHOD.

  METHOD allocates_across_locations.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0002'
          available_quantity = '5.000' )
        ( storage_location   = '0001'
          available_quantity = '3.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '6.000'
      iv_unit               = 'EA' ).
    DATA(ls_request) = mo_res_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-storage_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_request-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_request-items[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_request-items[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD prefers_location_first.
    mo_stock_repo->set_location_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          available_quantity = '5.000' )
        ( storage_location   = '0002'
          available_quantity = '1.000' )
        ( storage_location   = '0003'
          available_quantity = '2.000' ) ) ).

    DATA(ls_preview) = mo_cut->preview_for_cost_center(
      iv_material                  = 'MAT-1'
      iv_plant                     = '1000'
      iv_storage_location          = '0002'
      iv_allow_fallback            = abap_true
      iv_cost_center               = 'COST-100'
      iv_requested_quantity        = '3.000'
      iv_unit                      = 'EA'
      it_location_priority         = VALUE #(
        ( '0003' )
        ( '0001' ) )
      it_allowed_storage_locations = VALUE #(
        ( '0002' )
        ( '0003' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = ls_preview-storage_allocations[ 2 ]-storage_location ).

    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material                  = 'MAT-1'
      iv_plant                     = '1000'
      iv_storage_location          = '0002'
      iv_allow_fallback            = abap_true
      iv_cost_center               = 'COST-100'
      iv_requested_quantity        = '3.000'
      iv_unit                      = 'EA'
      it_location_priority         = VALUE #(
        ( '0003' )
        ( '0001' ) )
      it_allowed_storage_locations = VALUE #(
        ( '0002' )
        ( '0003' ) ) ).
    DATA(ls_request) = mo_res_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_request-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = ls_request-items[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_request-items[ 2 ]-quantity ).
  ENDMETHOD.

  METHOD selects_exact_batch.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'BATCH-1'
          available_quantity = '3.000' )
        ( storage_location   = '0001'
          batch              = 'BATCH-2'
          available_quantity = '8.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_storage_location   = '0001'
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '5.000'
      iv_unit               = 'EA'
      iv_batch              = 'BATCH-1'
      iv_required_date      = '20261001' ).
    DATA(ls_request) = mo_res_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BATCH-1'
      act = ls_request-items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_request-items[ 1 ]-quantity ).
  ENDMETHOD.

  METHOD splits_batch_by_location.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0002'
          batch              = 'BATCH-1'
          available_quantity = '5.000' )
        ( storage_location   = '0001'
          batch              = 'BATCH-1'
          available_quantity = '3.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '6.000'
      iv_unit               = 'EA'
      iv_batch              = 'BATCH-1' ).
    DATA(ls_request) = mo_res_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_request-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BATCH-1'
      act = ls_request-items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_request-items[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BATCH-1'
      act = ls_request-items[ 2 ]-batch ).
  ENDMETHOD.

  METHOD falls_back_for_batch.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'BATCH-1'
          available_quantity = '4.000' )
        ( storage_location   = '0002'
          batch              = 'BATCH-1'
          available_quantity = '1.000' )
        ( storage_location   = '0003'
          batch              = 'BATCH-1'
          available_quantity = '3.000' )
        ( storage_location   = '0002'
          batch              = 'BATCH-2'
          available_quantity = '9.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_storage_location   = '0002'
      iv_allow_fallback     = abap_true
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '3.000'
      iv_unit               = 'EA'
      it_location_priority  = VALUE #(
        ( '0003' )
        ( '0001' ) )
      iv_batch              = 'BATCH-1' ).
    DATA(ls_request) = mo_res_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_result-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_request-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BATCH-1'
      act = ls_request-items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = ls_request-items[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BATCH-1'
      act = ls_request-items[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_request-items[ 2 ]-quantity ).
  ENDMETHOD.

  METHOD reserves_fefo_batches.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-OLD'
          expiration_date    = '20260920'
          available_quantity = '10.000' )
        ( storage_location   = '0001'
          batch              = 'B-SHORT'
          expiration_date    = '20260925'
          available_quantity = '4.000' )
        ( storage_location   = '0002'
          batch              = 'B-BOUND'
          expiration_date    = '20260930'
          available_quantity = '2.000' )
        ( storage_location   = '0001'
          batch              = 'B-LATER'
          expiration_date    = '20261010'
          available_quantity = '5.000' )
        ( storage_location   = '0002'
          batch              = 'B-UNDATED'
          available_quantity = '4.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '4.000'
      iv_unit               = 'EA'
      iv_use_fefo_batches   = abap_true
      iv_fefo_as_of_date    = '20260923'
      iv_fefo_min_days      = 7 ).
    DATA(ls_request) = mo_res_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = ls_result-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-BOUND'
      act = ls_request-items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_request-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_request-items[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_request-items[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_request-items[ 2 ]-quantity ).
  ENDMETHOD.

  METHOD falls_back_for_fefo.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-OLD'
          expiration_date    = '20261010'
          available_quantity = '2.000' )
        ( storage_location   = '0003'
          batch              = 'B-OLD'
          expiration_date    = '20261010'
          available_quantity = '3.000' )
        ( storage_location   = '0001'
          batch              = 'B-LATER'
          expiration_date    = '20261015'
          available_quantity = '20.000' )
        ( storage_location   = '0002'
          batch              = 'B-PREF'
          expiration_date    = '20261101'
          available_quantity = '1.000' ) ) ).

    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_storage_location   = '0002'
      iv_allow_fallback     = abap_true
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '3.000'
      iv_unit               = 'EA'
      iv_use_fefo_batches   = abap_true
      iv_fefo_as_of_date    = '20261001'
      it_location_priority  = VALUE #(
        ( '0003' )
        ( '0001' ) ) ).
    DATA(ls_request) = mo_res_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '26.000' )
      act = ls_result-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-PREF'
      act = ls_request-items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_request-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-OLD'
      act = ls_request-items[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = ls_request-items[ 2 ]-storage_location ).
  ENDMETHOD.

  METHOD previews_fefo_without_bapi.
    mo_stock_repo->set_batch_stocks(
      it_stock = VALUE #(
        ( storage_location   = '0001'
          batch              = 'B-OLD'
          expiration_date    = '20260920'
          available_quantity = '10.000' )
        ( storage_location   = '0002'
          batch              = 'B-BOUND'
          expiration_date    = '20260930'
          available_quantity = '2.000' )
        ( storage_location   = '0001'
          batch              = 'B-LATER'
          expiration_date    = '20261010'
          available_quantity = '5.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '4.000'
      iv_unit               = 'EA'
      iv_use_fefo_batches   = abap_true
      iv_fefo_as_of_date    = '20260923'
      iv_fefo_min_days      = 7 ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = ls_result-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_atp_api->get_check_count( ) ).

  ENDMETHOD.

  METHOD previews_cost_center_atp.
    mo_uom_repo->set_alt_unit_ratio(
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    mo_atp_api->set_result(
      is_result = VALUE #(
        available_at_plant_quantity = '20.000'
        confirmed_date              = '20261001'
        confirmed_quantity          = '12.000'
        is_fully_available          = abap_true
        is_check_relevant           = abap_true ) ).

    DATA(ls_result) = mo_cut->preview_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '1.000'
      iv_unit               = 'BOX'
      iv_required_date      = '20261001'
      iv_require_full_alloc = abap_true
      iv_check_atp          = abap_true
      iv_atp_check_rule     = 'A' ).
    DATA(ls_atp_request) = mo_atp_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-atp_result-is_fully_available ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '20.000' )
      act = ls_result-atp_result-available_at_plant_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-atp_result-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'A'
      act = ls_result-atp_result-check_rule ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261001'
      act = ls_result-atp_result-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-atp_result-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_atp_request-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_atp_request-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_atp_api->get_check_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_short_atp_reservation.
    mo_atp_api->set_result(
      is_result = VALUE #(
        confirmed_date     = '20261001'
        confirmed_quantity = '2.000'
        is_fully_available = abap_false
        is_check_relevant  = abap_true ) ).

    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material                 = 'MAT-1'
      iv_plant                    = '1000'
      iv_storage_location         = '0001'
      iv_cost_center              = 'COST-100'
      iv_requested_quantity       = '4.000'
      iv_unit                     = 'EA'
      iv_required_date            = '20261001'
      iv_test_run                 = abap_true
      iv_require_atp_confirmation = abap_true
      iv_check_atp                = abap_true
      iv_atp_check_rule           = 'A' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-messages ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_atp_api->get_check_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_late_atp_reservation.
    mo_atp_api->set_result(
      is_result = VALUE #(
        confirmed_date     = '20261002'
        confirmed_quantity = '4.000'
        is_fully_available = abap_false
        is_check_relevant  = abap_true ) ).

    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material                 = 'MAT-1'
      iv_plant                    = '1000'
      iv_storage_location         = '0001'
      iv_cost_center              = 'COST-100'
      iv_requested_quantity       = '4.000'
      iv_unit                     = 'EA'
      iv_required_date            = '20261001'
      iv_test_run                 = abap_true
      iv_require_atp_confirmation = abap_true
      iv_check_atp                = abap_true
      iv_atp_check_rule           = 'A' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-unconfirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD reserves_atp_confirmed.
    mo_atp_api->set_result(
      is_result = VALUE #(
        confirmed_date     = '20261001'
        confirmed_quantity = '4.000'
        is_fully_available = abap_true
        is_check_relevant  = abap_true ) ).

    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material                 = 'MAT-1'
      iv_plant                    = '1000'
      iv_storage_location         = '0001'
      iv_cost_center              = 'COST-100'
      iv_requested_quantity       = '4.000'
      iv_unit                     = 'EA'
      iv_required_date            = '20261001'
      iv_test_run                 = abap_true
      iv_require_atp_confirmation = abap_true
      iv_check_atp                = abap_true
      iv_atp_check_rule           = 'A' ).
    DATA(ls_request) = mo_res_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_atp_gate_without_check.
    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material                 = 'MAT-1'
      iv_plant                    = '1000'
      iv_cost_center              = 'COST-100'
      iv_requested_quantity       = '2.000'
      iv_unit                     = 'EA'
      iv_require_atp_confirmation = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-messages ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).

    DATA lv_exception_raised TYPE abap_bool.
    TRY.
        mo_cut->reserve_for_cost_center(
          iv_material                 = 'MAT-1'
          iv_plant                    = '1000'
          iv_cost_center              = 'COST-100'
          iv_requested_quantity       = '2.000'
          iv_unit                     = 'EA'
          iv_require_atp_confirmation = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_atp_api->get_check_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_atp_without_rule.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_for_cost_center(
          iv_material           = 'MAT-1'
          iv_plant              = '1000'
          iv_cost_center        = 'COST-100'
          iv_requested_quantity = '2.000'
          iv_unit               = 'EA'
          iv_check_atp          = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_atp_api->get_check_count( ) ).

    CLEAR lv_exception_raised.
    TRY.
        mo_cut->reserve_for_cost_center(
          iv_material           = 'MAT-1'
          iv_plant              = '1000'
          iv_cost_center        = 'COST-100'
          iv_requested_quantity = '2.000'
          iv_unit               = 'EA'
          iv_check_atp          = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_atp_api->get_check_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD previews_short_full_req.
    DATA(ls_result) = mo_cut->preview_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_storage_location   = '0001'
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '10.000'
      iv_unit               = 'EA'
      iv_require_full_alloc = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD requires_full_stock.
    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_storage_location   = '0001'
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '10.000'
      iv_unit               = 'EA'
      iv_require_full_alloc = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD simulates_without_commit.
    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_storage_location   = '0001'
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '4.000'
      iv_unit               = 'EA'
      iv_test_run           = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = mo_res_api->was_test_run( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_create_error.
    mo_res_api->set_create_result(
      is_result = VALUE #(
        messages = VALUE #(
          ( type = 'E' message = 'Reservation rejected' ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_storage_location   = '0001'
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '4.000'
      iv_unit               = 'EA' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-reservation_number ).
  ENDMETHOD.

  METHOD rolls_back_commit_error.
    mo_res_api->set_commit_result(
      is_result = VALUE #(
        is_successful = abap_false
        message       = VALUE #(
          type    = 'E'
          message = 'Commit rejected' ) ) ).

    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_storage_location   = '0001'
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '4.000'
      iv_unit               = 'EA' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_res_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-reservation_number ).
  ENDMETHOD.

  METHOD skips_empty_stock.
    mo_stock_repo->set_location_stocks( it_stock = VALUE #( ) ).

    DATA(ls_result) = mo_cut->reserve_for_cost_center(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_storage_location   = '0001'
      iv_cost_center        = 'COST-100'
      iv_requested_quantity = '4.000'
      iv_unit               = 'EA' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_res_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_unknown_unit.
    DATA lv_rejected TYPE abap_bool.
    TRY.
        mo_cut->reserve_for_cost_center(
          iv_material           = 'MAT-1'
          iv_plant              = '1000'
          iv_storage_location   = '0001'
          iv_cost_center        = 'COST-100'
          iv_requested_quantity = '4.000'
          iv_unit               = 'KG' ).
      CATCH zcx_invalid_reservation.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_blank_location.
    DATA lv_rejected TYPE abap_bool.
    TRY.
        mo_cut->reserve_for_cost_center(
          iv_material           = 'MAT-1'
          iv_plant              = '1000'
          iv_storage_location   = space
          iv_cost_center        = 'COST-100'
          iv_requested_quantity = '4.000'
          iv_unit               = 'EA' ).
      CATCH zcx_invalid_reservation.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_fallback_no_loc.
    DATA lv_rejected TYPE abap_bool.
    TRY.
        mo_cut->preview_for_cost_center(
          iv_material           = 'MAT-1'
          iv_plant              = '1000'
          iv_allow_fallback     = abap_true
          iv_cost_center        = 'COST-100'
          iv_requested_quantity = '4.000'
          iv_unit               = 'EA' ).
      CATCH zcx_invalid_reservation.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_zero_base_qty.
    mo_uom_repo->set_alt_unit_ratio(
      iv_alternative_unit = 'BOX'
      iv_numerator        = 1
      iv_denominator      = 99999 ).
    DATA lv_rejected TYPE abap_bool.
    TRY.
        mo_cut->reserve_for_cost_center(
          iv_material           = 'MAT-1'
          iv_plant              = '1000'
          iv_storage_location   = '0001'
          iv_cost_center        = 'COST-100'
          iv_requested_quantity = '0.001'
          iv_unit               = 'BOX' ).
      CATCH zcx_invalid_reservation.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_fefo_with_batch.
    DATA lv_rejected TYPE abap_bool.
    TRY.
        mo_cut->reserve_for_cost_center(
          iv_material           = 'MAT-1'
          iv_plant              = '1000'
          iv_storage_location   = '0001'
          iv_cost_center        = 'COST-100'
          iv_requested_quantity = '4.000'
          iv_unit               = 'EA'
          iv_batch              = 'BATCH-1'
          iv_use_fefo_batches   = abap_true ).
      CATCH zcx_invalid_reservation.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_min_days_without_fefo.
    DATA lv_rejected TYPE abap_bool.
    TRY.
        mo_cut->reserve_for_cost_center(
          iv_material           = 'MAT-1'
          iv_plant              = '1000'
          iv_storage_location   = '0001'
          iv_cost_center        = 'COST-100'
          iv_requested_quantity = '4.000'
          iv_unit               = 'EA'
          iv_fefo_min_days      = 1 ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_negative_fefo_days.
    DATA lv_rejected TYPE abap_bool.
    TRY.
        mo_cut->reserve_for_cost_center(
          iv_material           = 'MAT-1'
          iv_plant              = '1000'
          iv_storage_location   = '0001'
          iv_cost_center        = 'COST-100'
          iv_requested_quantity = '4.000'
          iv_unit               = 'EA'
          iv_use_fefo_batches   = abap_true
          iv_fefo_min_days      = -1 ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->get_read_count( ) ).
  ENDMETHOD.
ENDCLASS.
