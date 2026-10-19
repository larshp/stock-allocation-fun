CLASS lcl_project_stock_repo_double DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_project_stock_repository.
    METHODS set_stocks
      IMPORTING
        it_stocks TYPE zif_project_stock_repository=>ty_stocks.
    METHODS set_reservations
      IMPORTING
        it_reservations TYPE zif_project_stock_repository=>ty_reservations.
    DATA mv_reservation_read_calls TYPE i.
    DATA mv_stock_read_calls TYPE i.
    DATA mv_wbs_stock_read_calls TYPE i.
  PRIVATE SECTION.
    DATA mt_stocks TYPE zif_project_stock_repository=>ty_stocks.
    DATA mt_reservations TYPE
      zif_project_stock_repository=>ty_reservations.


ENDCLASS.

CLASS lcl_project_stock_repo_double IMPLEMENTATION.
  METHOD set_stocks.
    mt_stocks = it_stocks.
  ENDMETHOD.

  METHOD set_reservations.
    mt_reservations = it_reservations.
  ENDMETHOD.

  METHOD zif_project_stock_repository~read_project_stocks.
    mv_stock_read_calls = mv_stock_read_calls + 1.
    rt_stocks = mt_stocks.
  ENDMETHOD.

  METHOD zif_project_stock_repository~read_project_stocks_wbs.
    mv_stock_read_calls = mv_stock_read_calls + 1.
    mv_wbs_stock_read_calls = mv_wbs_stock_read_calls + 1.
    rt_stocks = mt_stocks.
  ENDMETHOD.

  METHOD zif_project_stock_repository~read_project_reservations.
    mv_reservation_read_calls = mv_reservation_read_calls + 1.
    rt_reservations = mt_reservations.
  ENDMETHOD.

  METHOD zif_project_stock_repository~read_project_reservations_wbs.
    mv_reservation_read_calls = mv_reservation_read_calls + 1.
    rt_reservations = mt_reservations.
  ENDMETHOD.

  METHOD zif_project_stock_repository~read_project_resv_items_wbs.
    mv_reservation_read_calls = mv_reservation_read_calls + 1.
    rt_reservations = mt_reservations.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_project_uom_repo_double DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_material_uom_repository.
    METHODS set_material_data
      IMPORTING
        iv_base_unit TYPE mara-meins.
    METHODS set_alt_unit_ratio
      IMPORTING
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

CLASS lcl_project_uom_repo_double IMPLEMENTATION.
  METHOD set_material_data.
    mv_base_unit = iv_base_unit.
  ENDMETHOD.

  METHOD set_alt_unit_ratio.
    mv_alternative_unit = iv_alternative_unit.
    ms_ratio-numerator = iv_numerator.
    ms_ratio-denominator = iv_denominator.
  ENDMETHOD.

  METHOD get_read_count.
    rv_count = mv_read_count.
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
ENDCLASS.

CLASS lcl_project_atp_api_double DEFINITION FINAL.
  PUBLIC SECTION.
    TYPES ty_requests TYPE STANDARD TABLE OF
      zif_material_availability_api=>ty_request WITH EMPTY KEY.
    INTERFACES zif_material_availability_api.
    METHODS set_result
      IMPORTING
        is_result TYPE zif_material_availability_api=>ty_result.
    METHODS get_requests
      RETURNING
        VALUE(rt_requests) TYPE ty_requests.
  PRIVATE SECTION.
    DATA mt_requests TYPE ty_requests.
    DATA ms_result TYPE zif_material_availability_api=>ty_result.
ENDCLASS.

CLASS lcl_project_atp_api_double IMPLEMENTATION.
  METHOD set_result.
    ms_result = is_result.
  ENDMETHOD.

  METHOD get_requests.
    rt_requests = mt_requests.
  ENDMETHOD.

  METHOD zif_material_availability_api~check_availability.
    APPEND is_request TO mt_requests.
    rs_result = ms_result.
    rs_result-material = is_request-material.
    rs_result-plant = is_request-plant.
    rs_result-unit = is_request-unit.
    rs_result-check_rule = is_request-check_rule.
    rs_result-required_date = is_request-required_date.
    rs_result-requested_quantity = is_request-requested_quantity.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_project_stock_service DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO lcl_project_stock_repo_double.
    DATA mo_uom_repository TYPE REF TO lcl_project_uom_repo_double.
    DATA mo_availability_api TYPE REF TO lcl_project_atp_api_double.
    DATA mo_cut TYPE REF TO zcl_project_stock_service.
    METHODS setup.
    METHODS reads_project_available_stock FOR TESTING.
    METHODS reads_available_stock_in_unit FOR TESTING.
    METHODS rejects_stock_uom_overflow FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_stock_uom_rounding FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_unknown_stock_unit FOR TESTING.
    METHODS reads_stock_bulk_by_date FOR TESTING.
    METHODS rejects_bad_stock_bulk FOR TESTING.
    METHODS empty_stock_bulk_skips FOR TESTING.
    METHODS reads_open_wbs_reservations FOR TESTING.
    METHODS reads_open_res_bulk_dates FOR TESTING.
    METHODS rejects_bad_open_res_bulk FOR TESTING.
    METHODS empty_open_res_bulk_skips FOR TESTING.
    METHODS reads_final_wbs_reservations FOR TESTING.
    METHODS reads_reservation_items_bulk FOR TESTING.
    METHODS rejects_bad_res_items_bulk FOR TESTING.
    METHODS filters_open_reservations_date FOR TESTING.
    METHODS rejects_invalid_read_cutoffs FOR TESTING.
    METHODS rejects_invalid_fefo_dates FOR TESTING.
    METHODS rejects_invalid_location_date FOR TESTING.
    METHODS rejects_invalid_transfer_dates FOR TESTING.
    METHODS summarizes_wbs_resv_coverage FOR TESTING.
    METHODS rejects_cov_stock_overflow FOR TESTING
      RAISING cx_static_check.
    METHODS reads_wbs_coverage_uom FOR TESTING.
    METHODS rejects_coverage_uom_overflow FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_coverage_uom_rounding FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_unknown_coverage_uom FOR TESTING.
    METHODS reads_coverage_bulk_uom FOR TESTING.
    METHODS rejects_bad_coverage_uom FOR TESTING.
    METHODS reads_coverage_bulk_horizons FOR TESTING.
    METHODS rejects_bad_coverage_bulk FOR TESTING.
    METHODS empty_coverage_bulk_skips FOR TESTING.
    METHODS rejects_dup_wbs_reservations FOR TESTING.
    METHODS rejects_duplicate_wbs_input FOR TESTING.
    METHODS empty_wbs_reserv_skips_repo FOR TESTING.
    METHODS allocates_project_stock_fefo FOR TESTING.
    METHODS restricts_wbs_fefo_scope FOR TESTING.
    METHODS scopes_wbs_location FOR TESTING.
    METHODS previews_scoped_wbs_fefo_atp FOR TESTING.
    METHODS previews_advanced_scoped_atp FOR TESTING.
    METHODS scopes_xfer_fefo FOR TESTING.
    METHODS scopes_xfer_location FOR TESTING.
    METHODS rejects_xfer_scope FOR TESTING.
    METHODS rejects_wbs_location_scopes FOR TESTING.
    METHODS rejects_location_overflow FOR TESTING.
    METHODS rejects_fefo_avail_overflow FOR TESTING.
    METHODS rejects_fefo_atp_overflow FOR TESTING.
    METHODS allocates_projected_fefo FOR TESTING.
    METHODS forwards_fefo_receipt_adapters FOR TESTING.
    METHODS rejects_unmatched_receipts FOR TESTING.
    METHODS rejects_receipt_expiry FOR TESTING.
    METHODS ranks_project_fefo_locs FOR TESTING.
    METHODS prioritizes_project_fefo FOR TESTING.
    METHODS preserves_fefo_row_full_rule FOR TESTING.
    METHODS rank_prio_fefo_loc FOR TESTING.
    METHODS prioritizes_project_fefo_date FOR TESTING.
    METHODS prioritizes_project_location FOR TESTING.
    METHODS allocates_fefo_per_demand_date FOR TESTING.
    METHODS repeats_id_fefo_date FOR TESTING.
    METHODS previews_wbs_fefo_atp FOR TESTING.
    METHODS previews_wbs_loc_atp FOR TESTING.
    METHODS previews_wbs_fefo_prio_atp FOR TESTING.
    METHODS previews_wbs_loc_prio_atp FOR TESTING.
    METHODS previews_xfer_fefo_atp FOR TESTING.
    METHODS previews_xfer_loc_atp FOR TESTING.
    METHODS rejects_bad_project_atp_dates FOR TESTING.
    METHODS previews_dated_wbs_fefo_atp FOR TESTING.
    METHODS previews_dated_wbs_loc_atp FOR TESTING.
    METHODS previews_dated_xfer_fefo_atp FOR TESTING.
    METHODS previews_dated_xfer_loc_atp FOR TESTING.
    METHODS previews_xfer_fefo_prio_atp FOR TESTING.
    METHODS previews_xfer_loc_prio_atp FOR TESTING.
    METHODS rejects_bad_project_atp_rule FOR TESTING.
    METHODS allocates_dated_fefo_priority FOR TESTING.
    METHODS rank_date_fefo_loc FOR TESTING.
    METHODS rejects_bad_dated_fefo FOR TESTING.
    METHODS rejects_batch_expiry_conflict FOR TESTING.
    METHODS rejects_invalid_batch_expiry FOR TESTING.
    METHODS rejects_negative_demand_shelf FOR TESTING.
    METHODS filters_reservations_by_date FOR TESTING.
    METHODS forwards_cutoff_to_transfer FOR TESTING.
    METHODS previews_project_wbs_transfer FOR TESTING.
    METHODS allocates_dated_transfer_fefo FOR TESTING.
    METHODS repeats_id_dated_xfer_fefo FOR TESTING.
    METHODS prioritizes_wbs_transfer_fefo FOR TESTING.
    METHODS preserves_xfer_fefo_row_rule FOR TESTING.
    METHODS preserves_xfer_loc_row_rule FOR TESTING.
    METHODS rejects_bad_transfer_fefo_date FOR TESTING.
    METHODS previews_wbs_location_xfer FOR TESTING.
    METHODS prioritizes_wbs_loc_transfer FOR TESTING.
    METHODS previews_dated_loc_xfer FOR TESTING.
    METHODS repeats_id_dated_loc_xfer FOR TESTING.
    METHODS allocates_unbatched_stock FOR TESTING.
    METHODS allocates_projected_location FOR TESTING.
    METHODS forwards_location_receipts FOR TESTING.
    METHODS rejects_unmatched_loc_receipt FOR TESTING.
    METHODS rejects_loc_receipt_overflow FOR TESTING.
    METHODS allocates_dated_location_prio FOR TESTING.
    METHODS repeats_id_location_date FOR TESTING.
    METHODS ranks_dated_wbs_loc FOR TESTING.
    METHODS rejects_bad_dated_location FOR TESTING.
    METHODS shares_stock_between_demands FOR TESTING.
    METHODS scopes_priority_wbs_fefo FOR TESTING.
    METHODS scopes_dated_wbs_fefo FOR TESTING.
    METHODS scopes_priority_wbs_location FOR TESTING.
    METHODS scopes_dated_wbs_location FOR TESTING.
    METHODS rejects_advanced_wbs_scopes FOR TESTING.
ENDCLASS.

CLASS ltcl_project_stock_service IMPLEMENTATION.
  METHOD setup.
    mo_repository = NEW lcl_project_stock_repo_double( ).
    mo_uom_repository = NEW lcl_project_uom_repo_double( ).
    mo_availability_api = NEW lcl_project_atp_api_double( ).
    mo_uom_repository->set_material_data( iv_base_unit = 'EA' ).
    mo_uom_repository->set_alt_unit_ratio(
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    mo_cut = NEW zcl_project_stock_service(
      io_repository                = mo_repository
      io_uom_repository            = mo_uom_repository
      io_material_availability_api = mo_availability_api ).
  ENDMETHOD.

  METHOD reads_project_available_stock.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        unrestricted_quantity = '5.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-1'
        unrestricted_quantity = '10.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-OTHER'
        storage_location      = '0001'
        unrestricted_quantity = '50.000' ) ) ).
    mo_repository->set_reservations( it_reservations = VALUE #(
      ( material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        batch              = 'B-1'
        required_quantity  = '3.000'
        withdrawn_quantity = '0.000' )
      ( material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        required_quantity  = '2.000'
        withdrawn_quantity = '0.000' )
      ( material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        required_date      = '20261201'
        required_quantity  = '10.000'
        withdrawn_quantity = '0.000' ) ) ).

    DATA(lt_stock) = mo_cut->read_available_stock(
      it_keys                     = VALUE #(
        ( material    = 'MAT-1'
          plant       = '1000'
          wbs_element = 'PRJ-100-001' ) )
      iv_reservation_through_date = '20261101' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_stock ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '3.000' )
      act = lt_stock[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_stock[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '7.000' )
      act = lt_stock[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = lt_stock[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mara-meins( 'EA' )
      act = lt_stock[ 1 ]-base_unit ).
  ENDMETHOD.

  METHOD reads_available_stock_in_unit.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-1'
        unrestricted_quantity = '24.000' ) ) ).

    DATA(lt_single_stock) = mo_cut->read_available_stock_in_unit(
      iv_material    = 'MAT-1'
      iv_plant       = '1000'
      iv_wbs_element = 'PRJ-100-001'
      iv_unit        = 'BOX' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_single_stock ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '2.000' )
      act = lt_single_stock[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mara-meins( 'BOX' )
      act = lt_single_stock[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '24.000' )
      act = lt_single_stock[ 1 ]-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mara-meins( 'EA' )
      act = lt_single_stock[ 1 ]-base_unit ).

    DATA(lt_bulk_stock) = mo_cut->read_available_stock_bulk_uom(
      it_requests = VALUE #(
        ( request_id     = 'BOX-STOCK'
          material       = 'MAT-1'
          plant          = '1000'
          wbs_element    = 'PRJ-100-001'
          requested_unit = 'BOX' )
        ( request_id     = 'BOX-STOCK-2'
          material       = 'MAT-1'
          plant          = '1000'
          wbs_element    = 'PRJ-100-001'
          requested_unit = 'BOX' )
        ( request_id     = 'EA-STOCK'
          material       = 'MAT-1'
          plant          = '1000'
          wbs_element    = 'PRJ-100-001'
          requested_unit = 'EA' ) ) ).
    DATA(ls_box_stock) = lt_bulk_stock[ 1 ]-stocks[ 1 ].
    DATA(ls_box_stock_2) = lt_bulk_stock[ 2 ]-stocks[ 1 ].
    DATA(ls_ea_stock) = lt_bulk_stock[ 3 ]-stocks[ 1 ].
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_bulk_stock ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX-STOCK'
      act = lt_bulk_stock[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '2.000' )
      act = ls_box_stock-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '24.000' )
      act = ls_ea_stock-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '2.000' )
      act = ls_box_stock_2-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '24.000' )
      act = ls_box_stock-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_repository->mv_reservation_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 7
      act = mo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_stock_uom_overflow.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        unrestricted_quantity = '9999999999.999' ) ) ).
    mo_uom_repository->set_alt_unit_ratio(
      iv_alternative_unit = 'BOX'
      iv_numerator        = 1
      iv_denominator      = 99999 ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->read_available_stock_bulk_uom(
          it_requests = VALUE #( (
            request_id     = 'STOCK-RANGE'
            material       = 'MAT-1'
            plant          = '1000'
            wbs_element    = 'PRJ-100-001'
            requested_unit = 'BOX' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_rejected ).
  ENDMETHOD.

  METHOD rejects_stock_uom_rounding.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        unrestricted_quantity = '0.001' ) ) ).
    mo_uom_repository->set_alt_unit_ratio(
      iv_alternative_unit = 'BOX'
      iv_numerator        = 99999
      iv_denominator      = 1 ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->read_available_stock_bulk_uom(
          it_requests = VALUE #( (
            request_id     = 'STOCK-ROUND'
            material       = 'MAT-1'
            plant          = '1000'
            wbs_element    = 'PRJ-100-001'
            requested_unit = 'BOX' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_rejected ).
  ENDMETHOD.

  METHOD rejects_unknown_stock_unit.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        unrestricted_quantity = '24.000' ) ) ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->read_available_stock_bulk_uom(
          it_requests = VALUE #(
            ( request_id     = 'VALID-UNIT'
              material       = 'MAT-1'
              plant          = '1000'
              wbs_element    = 'PRJ-100-001'
              requested_unit = 'BOX' )
            ( request_id     = 'UNKNOWN-UNIT'
              material       = 'MAT-1'
              plant          = '1000'
              wbs_element    = 'PRJ-100-001'
              requested_unit = 'CSH' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_reservation_read_calls ).
  ENDMETHOD.

  METHOD reads_stock_bulk_by_date.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        unrestricted_quantity = '10.000' ) ) ).
    mo_repository->set_reservations( it_reservations = VALUE #(
      ( material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        required_date      = '20261101'
        required_quantity  = '2.000'
        withdrawn_quantity = '0.000' )
      ( material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        required_date      = '20261215'
        required_quantity  = '3.000'
        withdrawn_quantity = '0.000' ) ) ).

    DATA(lt_results) = mo_cut->read_available_stock_bulk(
      it_requests = VALUE #(
        ( request_id               = 'EARLY-1'
          material                 = 'MAT-1'
          plant                    = '1000'
          wbs_element              = 'PRJ-100-001'
          reservation_through_date = '20261115' )
        ( request_id               = 'EARLY-2'
          material                 = 'MAT-1'
          plant                    = '1000'
          wbs_element              = 'PRJ-100-001'
          reservation_through_date = '20261115' )
        ( request_id               = 'LATE'
          material                 = 'MAT-1'
          plant                    = '1000'
          wbs_element              = 'PRJ-100-001'
          reservation_through_date = '20261231' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY-1'
      act = lt_results[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '8.000' )
      act = lt_results[ 1 ]-stocks[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '8.000' )
      act = lt_results[ 2 ]-stocks[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '5.000' )
      act = lt_results[ 3 ]-stocks[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_repository->mv_reservation_read_calls ).
  ENDMETHOD.

  METHOD rejects_bad_stock_bulk.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->read_available_stock_bulk(
          it_requests = VALUE #(
            ( request_id               = 'VALID'
              material                 = 'MAT-1'
              plant                    = '1000'
              wbs_element              = 'PRJ-100-001'
              reservation_through_date = '20261115' )
            ( request_id               = 'INVALID'
              material                 = 'MAT-1'
              plant                    = '1000'
              wbs_element              = 'PRJ-100-001'
              reservation_through_date = '20260230' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_reservation_read_calls ).

  ENDMETHOD.

  METHOD empty_stock_bulk_skips.
    DATA(lt_results) = mo_cut->read_available_stock_bulk(
      it_requests = VALUE #( ) ).

    cl_abap_unit_assert=>assert_initial(
      act = lt_results ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_reservation_read_calls ).
  ENDMETHOD.

  METHOD reads_final_wbs_reservations.
    mo_repository->set_reservations( it_reservations = VALUE #(
      ( reservation_number = '0000001001'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '9.000'
        withdrawn_quantity = '4.000'
        is_final_issue     = abap_true )
      ( reservation_number = '0000001002'
        reservation_item   = '0002'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-OTHER'
        unit               = 'EA'
        required_quantity  = '2.000'
        is_final_issue     = abap_true ) ) ).

    DATA(lt_items) = mo_cut->read_reservation_items(
      it_wbs_elements = VALUE #( ( 'PRJ-100-001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_items[ 1 ]-is_final_issue ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001001'
      act = lt_items[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '5.000' )
      act = lt_items[ 1 ]-open_quantity ).
  ENDMETHOD.

  METHOD reads_open_wbs_reservations.
    mo_repository->set_reservations( it_reservations = VALUE #(
      ( reservation_number = '0000001002'
        reservation_item   = '0002'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        storage_location   = '0002'
        batch              = 'B-2'
        required_date      = '20261020'
        unit               = 'EA'
        required_quantity  = '9.000'
        withdrawn_quantity = '4.000' )
      ( reservation_number = '0000001001'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        storage_location   = '0001'
        required_date      = '20261010'
        unit               = 'EA'
        required_quantity  = '4.000'
        withdrawn_quantity = '1.000' )
      ( reservation_number = '0000001003'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-OTHER'
        unit               = 'EA'
        required_quantity  = '100.000' ) ) ).

    DATA(lt_reservations) = mo_cut->read_open_reservations(
      it_wbs_elements = VALUE #( ( 'PRJ-100-001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_reservations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001001'
      act = lt_reservations[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '3.000' )
      act = lt_reservations[ 1 ]-open_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-2'
      act = lt_reservations[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '5.000' )
      act = lt_reservations[ 2 ]-open_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_repository->mv_reservation_read_calls ).
  ENDMETHOD.

  METHOD reads_open_res_bulk_dates.
    mo_repository->set_reservations( it_reservations = VALUE #(
      ( reservation_number = '0000001001'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        required_date      = '20261101'
        unit               = 'EA'
        required_quantity  = '2.000' )
      ( reservation_number = '0000001002'
        reservation_item   = '0002'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        required_date      = '20261215'
        unit               = 'EA'
        required_quantity  = '3.000' )
      ( reservation_number = '0000001003'
        reservation_item   = '0003'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '4.000' ) ) ).

    DATA(lt_results) = mo_cut->read_open_reservations_bulk(
      it_requests = VALUE #(
        ( request_id            = 'EARLY-1'
          wbs_element           = 'PRJ-100-001'
          required_through_date = '20261115' )
        ( request_id            = 'EARLY-2'
          wbs_element           = 'PRJ-100-001'
          required_through_date = '20261115' )
        ( request_id            = 'LATE'
          wbs_element           = 'PRJ-100-001'
          required_through_date = '20261231' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY-1'
      act = lt_results[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results[ 1 ]-reservations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001003'
      act = lt_results[ 1 ]-reservations[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_results[ 3 ]-reservations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_repository->mv_reservation_read_calls ).
  ENDMETHOD.

  METHOD rejects_bad_open_res_bulk.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->read_open_reservations_bulk(
          it_requests = VALUE #(
            ( request_id            = 'VALID'
              wbs_element           = 'PRJ-100-001'
              required_through_date = '20261115' )
            ( request_id            = 'INVALID'
              wbs_element           = 'PRJ-100-001'
              required_through_date = '20260230' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_reservation_read_calls ).
  ENDMETHOD.

  METHOD empty_open_res_bulk_skips.
    DATA(lt_results) = mo_cut->read_open_reservations_bulk(
      it_requests = VALUE #( ) ).

    cl_abap_unit_assert=>assert_initial(
      act = lt_results ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_reservation_read_calls ).
  ENDMETHOD.

  METHOD reads_reservation_items_bulk.
    mo_repository->set_reservations( it_reservations = VALUE #(
      ( reservation_number = '0000001001'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '9.000'
        withdrawn_quantity = '4.000'
        is_final_issue     = abap_true )
      ( reservation_number = '0000001002'
        reservation_item   = '0002'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '2.000'
        withdrawn_quantity = '2.000' )
      ( reservation_number = '0000002001'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-200-001'
        unit               = 'EA'
        required_quantity  = '3.000'
        is_final_issue     = abap_true ) ) ).

    DATA(lt_results) = mo_cut->read_reservation_items_bulk(
      it_requests = VALUE #(
        ( request_id  = 'ITEMS-200'
          wbs_element = 'PRJ-200-001' )
        ( request_id  = 'ITEMS-100'
          wbs_element = 'PRJ-100-001' )
        ( request_id  = 'ITEMS-100-AGAIN'
          wbs_element = 'PRJ-100-001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'ITEMS-200'
      act = lt_results[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_results[ 1 ]-reservations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_results[ 1 ]-reservations[ 1 ]-is_final_issue ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results[ 2 ]-reservations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '5.000' )
      act = lt_results[ 2 ]-reservations[ 1 ]-open_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '0.000' )
      act = lt_results[ 2 ]-reservations[ 2 ]-open_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_repository->mv_reservation_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
  ENDMETHOD.

  METHOD rejects_bad_res_items_bulk.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->read_reservation_items_bulk(
          it_requests = VALUE #(
            ( request_id  = 'DUPLICATE'
              wbs_element = 'PRJ-100-001' )
            ( request_id  = 'DUPLICATE'
              wbs_element = 'PRJ-200-001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_reservation_read_calls ).
  ENDMETHOD.

  METHOD filters_open_reservations_date.
    mo_repository->set_reservations( it_reservations = VALUE #(
      ( reservation_number = '0000001001'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        required_date      = '20261010'
        unit               = 'EA'
        required_quantity  = '2.000' )
      ( reservation_number = '0000001002'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        required_date      = '20261020'
        unit               = 'EA'
        required_quantity  = '3.000' )
      ( reservation_number = '0000001003'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '4.000' ) ) ).

    DATA(lt_reservations) = mo_cut->read_open_reservations(
      it_wbs_elements          = VALUE #( ( 'PRJ-100-001' ) )
      iv_required_through_date = '20261015' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_reservations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001003'
      act = lt_reservations[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001001'
      act = lt_reservations[ 2 ]-reservation_number ).
  ENDMETHOD.

  METHOD rejects_invalid_read_cutoffs.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->read_available_stock(
          it_keys                     = VALUE #( (
            material    = 'MAT-1'
            plant       = '1000'
            wbs_element = 'PRJ-100-001' ) )
          iv_reservation_through_date = '20261301' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_reservation_read_calls ).

    CLEAR lv_raised.
    TRY.
        mo_cut->read_open_reservations(
          it_wbs_elements          = VALUE #( ( 'PRJ-100-001' ) )
          iv_required_through_date = '20260230' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_reservation_read_calls ).

    CLEAR lv_raised.
    TRY.
        mo_cut->read_reservation_coverage_bulk(
          it_requests = VALUE #(
            ( request_id            = 'REQ-1'
              wbs_element           = 'PRJ-100-001'
              required_through_date = '2026ABCD' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_reservation_read_calls ).
  ENDMETHOD.

  METHOD rejects_invalid_fefo_dates.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_fefo(
          it_demands    = VALUE #(
            ( request_id         = 'REQ-1'
              wbs_element        = 'PRJ-100-001'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          iv_as_of_date = '20260229' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_reservation_read_calls ).

    CLEAR lv_raised.
    TRY.
        mo_cut->preview_fefo(
          it_demands                  = VALUE #(
            ( request_id         = 'REQ-1'
              wbs_element        = 'PRJ-100-001'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          iv_reservation_through_date = '20261131' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_reservation_read_calls ).

    CLEAR lv_raised.
    TRY.
        mo_cut->preview_fefo(
          it_demands    = VALUE #(
            ( request_id         = 'REQ-1'
              wbs_element        = 'PRJ-100-001'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              unit               = 'EA'
              fefo_as_of_date    = '20260229' ) )
          iv_as_of_date = '20261014' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_reservation_read_calls ).
  ENDMETHOD.

  METHOD rejects_invalid_location_date.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_by_location(
          it_demands                  = VALUE #(
            ( request_id         = 'REQ-1'
              wbs_element        = 'PRJ-100-001'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          iv_reservation_through_date = '20260431' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_reservation_read_calls ).

    CLEAR lv_raised.
    TRY.
        mo_cut->preview_by_location(
          it_demands = VALUE #(
            ( request_id              = 'REQ-SHELF-LOCATION'
              wbs_element             = 'PRJ-100-001'
              material                = 'MAT-1'
              plant                   = '1000'
              requested_quantity      = '1.000'
              unit                    = 'EA'
              minimum_shelf_life_days = 1 ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).

    CLEAR lv_raised.
    TRY.
        mo_cut->preview_transfer_by_location(
          it_demands = VALUE #(
            ( request_id              = 'REQ-SHELF-TRANSFER'
              source_wbs_element      = 'PRJ-100-001'
              destination_wbs_element = 'PRJ-200-001'
              material                = 'MAT-1'
              plant                   = '1000'
              requested_quantity      = '1.000'
              unit                    = 'EA'
              minimum_shelf_life_days = 1 ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
  ENDMETHOD.

  METHOD rejects_invalid_transfer_dates.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_transfer_fefo(
          it_demands    = VALUE #(
            ( request_id              = 'REQ-1'
              source_wbs_element      = 'PRJ-100-001'
              destination_wbs_element = 'PRJ-200-001'
              material                = 'MAT-1'
              plant                   = '1000'
              requested_quantity      = '1.000'
              unit                    = 'EA' ) )
          iv_as_of_date = '20260230' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_reservation_read_calls ).

    CLEAR lv_raised.
    TRY.
        mo_cut->preview_transfer_by_location(
          it_demands                  = VALUE #(
            ( request_id              = 'REQ-1'
              source_wbs_element      = 'PRJ-100-001'
              destination_wbs_element = 'PRJ-200-001'
              material                = 'MAT-1'
              plant                   = '1000'
              requested_quantity      = '1.000'
              unit                    = 'EA' ) )
          iv_reservation_through_date = '20261131' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_reservation_read_calls ).
  ENDMETHOD.

  METHOD summarizes_wbs_resv_coverage.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        unrestricted_quantity = '6.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-1'
        unrestricted_quantity = '4.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        unrestricted_quantity = '100.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-200-001'
        storage_location      = '0001'
        unrestricted_quantity = '1.000' ) ) ).
    mo_repository->set_reservations( it_reservations = VALUE #(
      ( reservation_number = '0000002001'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        storage_location   = '0001'
        batch              = 'B-1'
        unit               = 'EA'
        required_quantity  = '3.000' )
      ( reservation_number = '0000002002'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000' )
      ( reservation_number = '0000002003'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        required_date      = '20261020'
        unit               = 'EA'
        required_quantity  = '9.000' )
      ( reservation_number = '0000002004'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-200-001'
        unit               = 'EA'
        required_quantity  = '4.000' ) ) ).

    DATA(lt_coverage) = mo_cut->read_reservation_coverage(
      it_wbs_elements          = VALUE #(
        ( 'PRJ-100-001' )
        ( 'PRJ-200-001' ) )
      iv_required_through_date = '20261015' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_coverage ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '10.000' )
      act = lt_coverage[ 1 ]-project_stock_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '8.000' )
      act = lt_coverage[ 1 ]-reserved_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '2.000' )
      act = lt_coverage[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_coverage[ 1 ]-is_fully_covered ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '1.000' )
      act = lt_coverage[ 2 ]-project_stock_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '4.000' )
      act = lt_coverage[ 2 ]-reserved_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '3.000' )
      act = lt_coverage[ 2 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lt_coverage[ 2 ]-is_fully_covered ).
  ENDMETHOD.

  METHOD rejects_cov_stock_overflow.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        unrestricted_quantity = '9999999999.999' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0002'
        unrestricted_quantity = '9999999999.999' ) ) ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->read_reservation_coverage(
          it_wbs_elements = VALUE #( ( 'PRJ-100-001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_rejected ).
  ENDMETHOD.

  METHOD reads_wbs_coverage_uom.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        unrestricted_quantity = '36.000' ) ) ).
    mo_repository->set_reservations( it_reservations = VALUE #(
      ( reservation_number = '0000003001'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '12.000' ) ) ).

    DATA(ls_coverage) = mo_cut->read_reservation_coverage_uom(
      iv_material    = 'MAT-1'
      iv_plant       = '1000'
      iv_wbs_element = 'PRJ-100-001'
      iv_unit        = 'BOX' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = ls_coverage-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_coverage-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '3.000' )
      act = ls_coverage-project_stock_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '1.000' )
      act = ls_coverage-reserved_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '2.000' )
      act = ls_coverage-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '36.000' )
      act = ls_coverage-base_project_stock_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '12.000' )
      act = ls_coverage-base_reserved_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '24.000' )
      act = ls_coverage-base_available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_coverage-is_fully_covered ).
  ENDMETHOD.

  METHOD rejects_coverage_uom_overflow.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        unrestricted_quantity = '9999999999.999' ) ) ).
    mo_uom_repository->set_alt_unit_ratio(
      iv_alternative_unit = 'BOX'
      iv_numerator        = 1
      iv_denominator      = 99999 ).
    DATA lv_rejected TYPE abap_bool.
    DATA ls_coverage TYPE
      zcl_project_stock_service=>ty_reservation_coverage_in_unit.

    TRY.
        ls_coverage = mo_cut->read_reservation_coverage_uom(
          iv_material    = 'MAT-1'
          iv_plant       = '1000'
          iv_wbs_element = 'PRJ-100-001'
          iv_unit        = 'BOX' ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_rejected ).
  ENDMETHOD.

  METHOD rejects_coverage_uom_rounding.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        unrestricted_quantity = '0.001' ) ) ).
    mo_uom_repository->set_alt_unit_ratio(
      iv_alternative_unit = 'BOX'
      iv_numerator        = 99999
      iv_denominator      = 1 ).
    DATA lv_rejected TYPE abap_bool.
    DATA ls_coverage TYPE
      zcl_project_stock_service=>ty_reservation_coverage_in_unit.

    TRY.
        ls_coverage = mo_cut->read_reservation_coverage_uom(
          iv_material    = 'MAT-1'
          iv_plant       = '1000'
          iv_wbs_element = 'PRJ-100-001'
          iv_unit        = 'BOX' ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_rejected ).
  ENDMETHOD.

  METHOD rejects_unknown_coverage_uom.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->read_reservation_coverage_uom(
          iv_material    = 'MAT-1'
          iv_plant       = '1000'
          iv_wbs_element = 'PRJ-100-001'
          iv_unit        = 'BAD' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_reservation_read_calls ).
  ENDMETHOD.

  METHOD reads_coverage_bulk_uom.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        unrestricted_quantity = '36.000' ) ) ).
    mo_repository->set_reservations( it_reservations = VALUE #(
      ( reservation_number = '0000003001'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '12.000' ) ) ).

    DATA(lt_results) = mo_cut->read_resv_coverage_bulk_uom(
      it_requests = VALUE #(
        ( request_id            = 'COV-BOX'
          material              = 'MAT-1'
          plant                 = '1000'
          wbs_element           = 'PRJ-100-001'
          requested_unit        = 'BOX'
          required_through_date = '20261020' )
        ( request_id            = 'COV-EA'
          material              = 'MAT-1'
          plant                 = '1000'
          wbs_element           = 'PRJ-100-001'
          requested_unit        = 'EA'
          required_through_date = '20261020' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'COV-BOX'
      act = lt_results[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '3.000' )
      act = lt_results[ 1 ]-coverage-project_stock_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '2.000' )
      act = lt_results[ 1 ]-coverage-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '36.000' )
      act = lt_results[ 2 ]-coverage-project_stock_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_wbs_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_repository->mv_reservation_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = mo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_coverage_uom.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->read_resv_coverage_bulk_uom(
          it_requests = VALUE #(
            ( request_id     = 'COV-BAD-UOM'
              material       = 'MAT-1'
              plant          = '1000'
              wbs_element    = 'PRJ-100-001'
              requested_unit = 'BAD' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_reservation_read_calls ).
  ENDMETHOD.

  METHOD reads_coverage_bulk_horizons.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        unrestricted_quantity = '10.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-200-001'
        storage_location      = '0001'
        unrestricted_quantity = '5.000' ) ) ).
    mo_repository->set_reservations( it_reservations = VALUE #(
      ( reservation_number = '0000003001'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        required_date      = '20261020'
        unit               = 'EA'
        required_quantity  = '3.000' ) ) ).

    DATA(lt_results) = mo_cut->read_reservation_coverage_bulk(
      it_requests = VALUE #(
        ( request_id            = 'REQ-A'
          wbs_element           = 'PRJ-100-001'
          required_through_date = '20261015' )
        ( request_id            = 'REQ-A-LATE'
          wbs_element           = 'PRJ-100-001'
          required_through_date = '20261025' )
        ( request_id            = 'REQ-B'
          wbs_element           = 'PRJ-200-001'
          required_through_date = '20261015' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-A'
      act = lt_results[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '0.000' )
      act = lt_results[ 1 ]-coverage[ 1 ]-reserved_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '3.000' )
      act = lt_results[ 2 ]-coverage[ 1 ]-reserved_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '5.000' )
      act = lt_results[ 3 ]-coverage[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_repository->mv_reservation_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_repository->mv_wbs_stock_read_calls ).
  ENDMETHOD.

  METHOD rejects_bad_coverage_bulk.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->read_reservation_coverage_bulk(
          it_requests = VALUE #(
            ( request_id  = 'REQ-DUP'
              wbs_element = 'PRJ-100-001' )
            ( request_id  = 'REQ-DUP'
              wbs_element = 'PRJ-200-001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_reservation_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_wbs_stock_read_calls ).
  ENDMETHOD.

  METHOD empty_coverage_bulk_skips.
    DATA(lt_results) = mo_cut->read_reservation_coverage_bulk(
      it_requests = VALUE #( ) ).

    cl_abap_unit_assert=>assert_initial(
      act = lt_results ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_reservation_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_wbs_stock_read_calls ).
  ENDMETHOD.

  METHOD rejects_dup_wbs_reservations.
    DATA(lv_reservation) = VALUE zif_project_stock_repository=>ty_reservation(
      reservation_number = '0000001001'
      reservation_item   = '0001'
      material           = 'MAT-1'
      plant              = '1000'
      wbs_element        = 'PRJ-100-001'
      unit               = 'EA'
      required_quantity  = '2.000' ).
    mo_repository->set_reservations( it_reservations = VALUE #(
      ( lv_reservation )
      ( lv_reservation ) ) ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->read_open_reservations(
          it_wbs_elements = VALUE #( ( 'PRJ-100-001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
  ENDMETHOD.

  METHOD empty_wbs_reserv_skips_repo.
    DATA(lt_reservations) = mo_cut->read_open_reservations(
      it_wbs_elements = VALUE #( ) ).

    cl_abap_unit_assert=>assert_initial(
      act = lt_reservations ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_reservation_read_calls ).
  ENDMETHOD.

  METHOD rejects_duplicate_wbs_input.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->read_open_reservations(
          it_wbs_elements = VALUE #(
            ( 'PRJ-100-001' )
            ( 'PRJ-100-001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_reservation_read_calls ).
  ENDMETHOD.

  METHOD allocates_project_stock_fefo.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-EARLY'
        expiration_date       = '20261101'
        unrestricted_quantity = '10.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0002'
        batch                 = 'B-LATE'
        expiration_date       = '20270101'
        unrestricted_quantity = '30.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0003'
        batch                 = 'B-UNDATED'
        unrestricted_quantity = '5.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        batch                 = 'B-UNLOCATED'
        expiration_date       = '20261201'
        unrestricted_quantity = '100.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-OTHER'
        storage_location      = '0001'
        batch                 = 'B-OTHER'
        expiration_date       = '20261014'
        unrestricted_quantity = '100.000' ) ) ).
    mo_repository->set_reservations( it_reservations = VALUE #(
      ( material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        storage_location   = '0001'
        batch              = 'B-EARLY'
        required_quantity  = '3.000'
        withdrawn_quantity = '1.000' )
      ( material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        required_quantity  = '1.000'
        withdrawn_quantity = '0.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_fefo(
      it_demands    = VALUE #(
        ( request_id         = 'P-BOX'
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '2.000'
          unit               = 'BOX' ) )
      iv_as_of_date = '20261013' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-wbs_assignments ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-100-001'
      act = ls_result-wbs_assignments[ 1 ]-wbs_element ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '24.000' )
      act = ls_result-allocation-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '42.000' )
      act = ls_result-allocation-allocations[ 1 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocation-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EARLY'
      act = ls_result-allocation-batch_allocations[ 1 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATE'
      act = ls_result-allocation-batch_allocations[ 2 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = ls_result-allocation-batch_allocations[ 1 ]-batch_allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '17.000' )
      act = ls_result-allocation-batch_allocations[ 2 ]-batch_allocation-allocated_quantity ).

    DATA(ls_policy_result) = mo_cut->preview_fefo(
      it_demands                 = VALUE #(
        ( request_id           = 'WBS-STRICT'
          wbs_element          = 'PRJ-100-001'
          material             = 'MAT-1'
          plant                = '1000'
          requested_quantity   = '1.000'
          unit                 = 'EA'
          require_known_expiry = abap_true )
        ( request_id            = 'WBS-ALLOW-UNDATED'
          wbs_element           = 'PRJ-100-001'
          material              = 'MAT-1'
          plant                 = '1000'
          requested_quantity    = '40.000'
          unit                  = 'EA'
          allow_undated_batches = abap_true ) )
      iv_as_of_date              = '20261013'
      iv_include_undated_batches = abap_false ).
    DATA(ls_strict_summary) = ls_policy_result-allocation-allocations[ 1 ]-allocation.
    DATA(ls_allow_summary) = ls_policy_result-allocation-allocations[ 2 ]-allocation.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_strict_summary-require_known_expiry ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_allow_summary-allow_undated_batches ).
    cl_abap_unit_assert=>assert_true(
      act = line_exists( ls_policy_result-allocation-batch_allocations[
        batch_allocation-request_id = 'WBS-ALLOW-UNDATED'
        batch_allocation-batch = 'B-UNDATED' ] ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_policy_result-allocation-batch_allocations[
        batch_allocation-batch = 'B-UNDATED' ]-batch_allocation-allow_undated_batches ).

    DATA(lv_stock_reads_before_conflict) =
      mo_repository->mv_wbs_stock_read_calls.
    DATA(lv_policy_conflict_rejected) = abap_false.
    TRY.
        mo_cut->preview_fefo(
          it_demands    = VALUE #(
            ( request_id            = 'WBS-POLICY-CONFLICT'
              wbs_element           = 'PRJ-100-001'
              material              = 'MAT-1'
              plant                 = '1000'
              requested_quantity    = '1.000'
              unit                  = 'EA'
              require_known_expiry  = abap_true
              allow_undated_batches = abap_true ) )
          iv_as_of_date = '20261013' ).
      CATCH zcx_invalid_stock_request.
        lv_policy_conflict_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_policy_conflict_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_stock_reads_before_conflict
      act = mo_repository->mv_wbs_stock_read_calls ).
  ENDMETHOD.

  METHOD ranks_project_fefo_locs.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-SAME'
        expiration_date       = '20261130'
        unrestricted_quantity = '3.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0002'
        batch                 = 'B-SAME'
        expiration_date       = '20261130'
        unrestricted_quantity = '5.000' ) ) ).
    DATA(lt_location_priorities) =
      VALUE zcl_stock_service=>ty_request_location_priorities(
        ( request_id       = 'WBS-RANK'
          storage_location = '0002'
          priority_rank    = 1 ) ).
    DATA(ls_result) = mo_cut->preview_fefo(
      it_demands                     = VALUE #(
        ( request_id              = 'WBS-RANK'
          wbs_element             = 'PRJ-100-001'
          material                = 'MAT-1'
          plant                   = '1000'
          storage_location        = '0001'
          allow_location_fallback = abap_true
          requested_quantity      = '4.000'
          unit                    = 'EA' ) )
      it_storage_location_priority   = VALUE #( ( '0002' ) ( '0001' ) )
      it_request_location_priorities = lt_location_priorities
      iv_as_of_date                  = '20261014' ).
    DATA(ls_preferred_split) =
      ls_result-allocation-batch_allocations[ 1 ]-batch_allocation.
    DATA(ls_fallback_split) =
      ls_result-allocation-batch_allocations[ 2 ]-batch_allocation.

    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_preferred_split-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_preferred_split-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_fallback_split-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_fallback_split-allocated_quantity ).

    DATA(lv_stock_reads_before_bad_rank) =
      mo_repository->mv_wbs_stock_read_calls.
    DATA(lv_uom_reads_before_bad_rank) =
      mo_uom_repository->get_read_count( ).
    DATA(lv_bad_rank_rejected) = abap_false.
    TRY.
        mo_cut->preview_fefo(
          it_demands                     = VALUE #(
            ( request_id         = 'WBS-RANK'
              wbs_element        = 'PRJ-100-001'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          it_request_location_priorities = VALUE #(
            ( request_id       = 'UNKNOWN'
              storage_location = '0002'
              priority_rank    = 1 ) )
          iv_as_of_date                  = '20261014' ).
      CATCH zcx_invalid_stock_request.
        lv_bad_rank_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_rank_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_stock_reads_before_bad_rank
      act = mo_repository->mv_wbs_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_uom_reads_before_bad_rank
      act = mo_uom_repository->get_read_count( ) ).

    DATA(lv_reads_before_missing_loc) =
      mo_repository->mv_wbs_stock_read_calls.
    DATA(lv_uom_before_missing_loc) =
      mo_uom_repository->get_read_count( ).
    DATA(lv_missing_preference_rejected) = abap_false.
    TRY.
        mo_cut->preview_fefo(
          it_demands    = VALUE #(
            ( request_id              = 'WBS-FALLBACK-MISSING-LOCATION'
              wbs_element             = 'PRJ-100-001'
              material                = 'MAT-1'
              plant                   = '1000'
              allow_location_fallback = abap_true
              requested_quantity      = '1.000'
              unit                    = 'EA' ) )
          iv_as_of_date = '20261014' ).
      CATCH zcx_invalid_stock_request.
        lv_missing_preference_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_missing_preference_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_reads_before_missing_loc
      act = mo_repository->mv_wbs_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_uom_before_missing_loc
      act = mo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD prioritizes_project_fefo.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-SOON'
        expiration_date       = '20261020'
        unrestricted_quantity = '10.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0002'
        batch                 = 'B-LATER'
        expiration_date       = '20261120'
        unrestricted_quantity = '15.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_fefo_priority(
      it_demands    = VALUE #(
        ( request_id         = 'SHARED'
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          priority           = 1
          requested_quantity = '12.000'
          unit               = 'EA' )
        ( request_id           = 'SHARED'
          wbs_element          = 'PRJ-100-001'
          material             = 'MAT-1'
          plant                = '1000'
          priority             = 10
          requested_quantity   = '15.000'
          unit                 = 'EA'
          require_known_expiry = abap_true )
        ( request_id         = 'SHARED'
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          priority           = 10
          requested_quantity = '10.000'
          unit               = 'EA' ) )
      iv_as_of_date = '20261015' ).
    DATA(ls_low_allocation) = ls_result-allocations[ 1 ].
    DATA(ls_first_high_allocation) = ls_result-allocations[ 2 ].
    DATA(ls_second_high_allocation) = ls_result-allocations[ 3 ].
    DATA(ls_low_summary) = ls_low_allocation-allocation-allocation.
    DATA(ls_first_high_summary) = ls_first_high_allocation-allocation-allocation.
    DATA(ls_second_high_summary) = ls_second_high_allocation-allocation-allocation.
    DATA(ls_first_high_split) = ls_result-batch_allocations[ 1 ].
    DATA(ls_first_high_later_split) = ls_result-batch_allocations[ 2 ].
    DATA(ls_second_high_split) = ls_result-batch_allocations[ 3 ].

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SHARED'
      act = ls_low_allocation-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_low_allocation-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_low_summary-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_first_high_allocation-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '15.000' )
      act = ls_first_high_summary-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_first_high_summary-require_known_expiry ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_low_summary-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_second_high_summary-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_result-batch_allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-SOON'
      act = ls_first_high_split-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_first_high_split-split-batch_allocation-require_known_expiry ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_result-batch_allocations[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_first_high_later_split-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_second_high_split-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-wbs_assignments ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-wbs_assignments[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_result-wbs_assignments[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_result-wbs_assignments[ 3 ]-priority ).
  ENDMETHOD.

  METHOD rank_prio_fefo_loc.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-SAME'
        expiration_date       = '20261130'
        unrestricted_quantity = '3.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0002'
        batch                 = 'B-SAME'
        expiration_date       = '20261130'
        unrestricted_quantity = '5.000' ) ) ).
    DATA(lt_location_priorities) =
      VALUE zcl_stock_service=>ty_request_location_priorities(
        ( request_id       = 'WBS-PRIO'
          storage_location = '0002'
          priority_rank    = 1 ) ).

    DATA(ls_result) = mo_cut->preview_fefo_priority(
      it_demands                     = VALUE #(
        ( request_id              = 'WBS-PRIO'
          wbs_element             = 'PRJ-100-001'
          material                = 'MAT-1'
          plant                   = '1000'
          priority                = 10
          storage_location        = '0001'
          allow_location_fallback = abap_true
          requested_quantity      = '4.000'
          unit                    = 'EA' )
        ( request_id         = 'WBS-PRIO'
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          priority           = 5
          requested_quantity = '4.000'
          unit               = 'EA' ) )
      it_request_location_priorities = lt_location_priorities
      iv_as_of_date                  = '20261014' ).
    DATA(ls_first_ranked_split) =
      ls_result-batch_allocations[ 1 ]-split-batch_allocation.
    DATA(ls_second_ranked_split) =
      ls_result-batch_allocations[ 2 ]-split-batch_allocation.
    DATA(ls_third_ranked_split) =
      ls_result-batch_allocations[ 3 ]-split-batch_allocation.

    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_first_ranked_split-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_first_ranked_split-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_second_ranked_split-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_second_ranked_split-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_third_ranked_split-storage_location ).
  ENDMETHOD.

  METHOD prioritizes_project_fefo_date.
    DATA(lv_as_of_date) = CONV d( '20261013' ).
    DATA(lv_early_date) = CONV d( '20261014' ).
    DATA(lv_late_date) = CONV d( '20261015' ).
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'P-SOON'
        expiration_date       = '20261020'
        unrestricted_quantity = '4.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0002'
        batch                 = 'P-LATER'
        expiration_date       = '20261120'
        unrestricted_quantity = '8.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0001'
        batch                 = 'T-SOON'
        expiration_date       = '20261020'
        unrestricted_quantity = '4.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0002'
        batch                 = 'T-LATER'
        expiration_date       = '20261120'
        unrestricted_quantity = '8.000' ) ) ).
    mo_availability_api->set_result( is_result = VALUE #(
      is_check_relevant  = abap_true
      is_fully_available = abap_true ) ).
    DATA(lt_demands) = VALUE zcl_project_stock_service=>ty_priority_fefo_demands(
      ( request_id         = 'LATE-HIGH'
        priority           = 10
        wbs_element        = 'PRJ-100-001'
        material           = 'MAT-1'
        plant              = '1000'
        requested_quantity = '6.000'
        unit               = 'EA'
        fefo_as_of_date    = lv_late_date )
      ( request_id         = 'EARLY-LOW'
        priority           = 1
        wbs_element        = 'PRJ-100-001'
        material           = 'MAT-1'
        plant              = '1000'
        requested_quantity = '6.000'
        unit               = 'EA'
        fefo_as_of_date    = lv_early_date )
      ( request_id         = 'EARLY-HIGH'
        priority           = 5
        wbs_element        = 'PRJ-100-001'
        material           = 'MAT-1'
        plant              = '1000'
        requested_quantity = '6.000'
        unit               = 'EA'
        fefo_as_of_date    = lv_early_date ) ).
    DATA(lt_missing_date) = lt_demands.
    lt_missing_date[ 1 ]-fefo_as_of_date = space.
    DATA lv_missing_date_rejected TYPE abap_bool.

    TRY.
        mo_cut->preview_fefo_priority(
          it_demands            = lt_missing_date
          iv_as_of_date         = lv_as_of_date
          iv_prioritize_by_date = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_missing_date_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_missing_date_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_wbs_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_reservation_read_calls ).

    DATA(ls_wbs_result) = mo_cut->preview_fefo_priority(
      it_demands            = lt_demands
      iv_as_of_date         = lv_as_of_date
      iv_prioritize_by_date = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LATE-HIGH'
      act = ls_wbs_result-allocations[
        1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_wbs_result-allocations[
        1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_wbs_result-allocations[
        2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY-LOW'
      act = ls_wbs_result-allocations[
        2 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY-HIGH'
      act = ls_wbs_result-allocations[
        3 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_wbs_result-allocations[
        3 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_wbs_result-batch_allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = ls_wbs_result-batch_allocations[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'P-SOON'
      act = ls_wbs_result-batch_allocations[
        2 ]-split-batch_allocation-batch ).

    DATA(ls_wbs_atp_result) = mo_cut->preview_fefo_priority_atp(
      it_demands            = lt_demands
      iv_check_rule         = 'A'
      iv_atp_check_date     = lv_early_date
      iv_as_of_date         = lv_as_of_date
      iv_prioritize_by_date = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_wbs_atp_result-local_estimate-allocations[
        1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_wbs_atp_result-local_estimate-allocations[
        2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_wbs_atp_result-local_estimate-allocations[
        3 ]-allocation-allocation-allocated_quantity ).

    DATA(lt_transfer_demands) =
      VALUE zcl_project_stock_service=>ty_priority_transfer_fefo_demands(
        ( request_id              = 'LATE-HIGH'
          priority                = 10
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-LATE'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '6.000'
          unit                    = 'EA'
          fefo_as_of_date         = lv_late_date )
        ( request_id              = 'EARLY-LOW'
          priority                = 1
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-LOW'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '6.000'
          unit                    = 'EA'
          fefo_as_of_date         = lv_early_date )
        ( request_id              = 'EARLY-HIGH'
          priority                = 5
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-HIGH'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '6.000'
          unit                    = 'EA'
          fefo_as_of_date         = lv_early_date ) ).
    DATA(ls_transfer_result) = mo_cut->preview_transfer_fefo_priority(
      it_demands            = lt_transfer_demands
      iv_as_of_date         = lv_as_of_date
      iv_prioritize_by_date = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LATE-HIGH'
      act = ls_transfer_result-allocations[
        1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_transfer_result-allocations[
        1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_transfer_result-allocations[
        2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY-LOW'
      act = ls_transfer_result-allocations[
        2 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EARLY-HIGH'
      act = ls_transfer_result-allocations[
        3 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_transfer_result-allocations[
        3 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_transfer_result-batch_allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = ls_transfer_result-batch_allocations[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'T-SOON'
      act = ls_transfer_result-batch_allocations[
        2 ]-split-batch_allocation-batch ).

    DATA(ls_transfer_atp_result) = mo_cut->preview_transfer_fefo_prio_atp(
      it_demands            = lt_transfer_demands
      iv_check_rule         = 'A'
      iv_atp_check_date     = lv_early_date
      iv_as_of_date         = lv_as_of_date
      iv_prioritize_by_date = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_transfer_atp_result-local_estimate-allocations[
        1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_transfer_atp_result-local_estimate-allocations[
        2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_transfer_atp_result-local_estimate-allocations[
        3 ]-allocation-allocation-allocated_quantity ).
  ENDMETHOD.

  METHOD prioritizes_project_location.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        unrestricted_quantity = '10.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0002'
        unrestricted_quantity = '3.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_by_location_priority(
      it_demands                     = VALUE #(
        ( request_id         = 'SHARED'
          priority           = 1
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '5.000'
          unit               = 'EA' )
        ( request_id              = 'SHARED'
          priority                = 10
          wbs_element             = 'PRJ-100-001'
          material                = 'MAT-1'
          plant                   = '1000'
          storage_location        = '0002'
          allow_location_fallback = abap_true
          requested_quantity      = '10.000'
          unit                    = 'EA' )
        ( request_id         = 'SHARED'
          priority           = 10
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '10.000'
          unit               = 'EA' ) )
      it_storage_location_priority   = VALUE #( ( '0002' ) ( '0001' ) )
      it_request_location_priorities = VALUE #(
        ( request_id       = 'SHARED'
          storage_location = '0001'
          priority_rank    = 1 )
        ( request_id       = 'SHARED'
          storage_location = '0002'
          priority_rank    = 2 ) ) ).
    DATA(ls_low_allocation) = ls_result-allocations[ 1 ].
    DATA(ls_first_high_allocation) = ls_result-allocations[ 2 ].
    DATA(ls_second_high_allocation) = ls_result-allocations[ 3 ].
    DATA(ls_low_summary) = ls_low_allocation-allocation-allocation.
    DATA(ls_first_high_summary) = ls_first_high_allocation-allocation-allocation.
    DATA(ls_second_high_summary) = ls_second_high_allocation-allocation-allocation.
    DATA(ls_first_high_split) = ls_result-storage_allocations[ 1 ].
    DATA(ls_first_high_fallback_split) = ls_result-storage_allocations[ 2 ].
    DATA(ls_second_high_split) = ls_result-storage_allocations[ 3 ].

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_low_allocation-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_low_summary-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_low_summary-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_first_high_summary-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_second_high_summary-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-storage_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_first_high_split-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_first_high_split-split-storage_allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_first_high_fallback_split-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = ls_first_high_fallback_split-split-storage_allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_second_high_split-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-wbs_assignments[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_result-wbs_assignments[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_result-wbs_assignments[ 3 ]-priority ).
  ENDMETHOD.

  METHOD allocates_fefo_per_demand_date.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-EXPIRED'
        expiration_date       = '20261204'
        unrestricted_quantity = '5.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0002'
        batch                 = 'B-ELIGIBLE'
        expiration_date       = '20261210'
        unrestricted_quantity = '5.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0003'
        batch                 = 'B-SHORT'
        expiration_date       = '20261120'
        unrestricted_quantity = '2.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0004'
        batch                 = 'B-LONG'
        expiration_date       = '20261231'
        unrestricted_quantity = '2.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_fefo(
      it_demands    = VALUE #(
        ( request_id         = 'P-DATED'
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '3.000'
          unit               = 'EA'
          fefo_as_of_date    = '20261205' ) )
      iv_as_of_date = '20261014' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-allocation-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-ELIGIBLE'
      act = ls_result-allocation-batch_allocations[
        1 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261205'
      act = ls_result-allocation-batch_allocations[
        1 ]-batch_allocation-as_of_date ).
    DATA(ls_shelf_result) = mo_cut->preview_fefo(
      it_demands    = VALUE #(
        ( request_id         = 'REQ-NO-BUFFER'
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '2.000'
          unit               = 'EA' )
        ( request_id              = 'REQ-LONG-BUFFER'
          wbs_element             = 'PRJ-100-001'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '2.000'
          unit                    = 'EA'
          minimum_shelf_life_days = 70 ) )
      iv_as_of_date = '20261014' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'B-SHORT'
      act = ls_shelf_result-allocation-batch_allocations[
        1 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_shelf_result-allocation-batch_allocations[
        1 ]-batch_allocation-minimum_shelf_life_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LONG'
      act = ls_shelf_result-allocation-batch_allocations[
        2 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 70
      act = ls_shelf_result-allocation-batch_allocations[
        2 ]-batch_allocation-minimum_shelf_life_days ).

    DATA(ls_floor_result) = mo_cut->preview_fefo(
      it_demands                 = VALUE #(
        ( request_id         = 'REQ-SHARED-FLOOR'
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '2.000'
          unit               = 'EA' ) )
      iv_as_of_date              = '20261014'
      iv_minimum_shelf_life_days = 60 ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LONG'
      act = ls_floor_result-allocation-batch_allocations[
        1 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 60
      act = ls_floor_result-allocation-batch_allocations[
        1 ]-batch_allocation-minimum_shelf_life_days ).
  ENDMETHOD.

  METHOD repeats_id_fefo_date.
    DATA lv_early_date TYPE d.
    DATA lv_late_date TYPE d.
    DATA lv_early_expiry TYPE d.
    DATA lv_late_expiry TYPE d.

    lv_early_date = sy-datum + 4.
    lv_late_date = sy-datum + 8.
    lv_early_expiry = sy-datum + 15.
    lv_late_expiry = sy-datum + 16.

    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-EARLY'
        expiration_date       = lv_early_expiry
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-LATE'
        expiration_date       = lv_late_expiry
        unrestricted_quantity = '1.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_fefo_by_date(
      it_demands    = VALUE #(
        ( request_id         = 'SHARED'
          required_date      = lv_late_date
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'SHARED'
          required_date      = lv_early_date
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' ) )
      iv_as_of_date = sy-datum ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'SHARED'
      act = ls_result-allocations[
        1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SHARED'
      act = ls_result-allocations[
        2 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_late_date
      act = ls_result-allocations[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATE'
      act = ls_result-batch_allocations[
        1 ]-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EARLY'
      act = ls_result-batch_allocations[
        2 ]-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_late_date
      act = ls_result-batch_allocations[
        1 ]-required_date ).
  ENDMETHOD.

  METHOD previews_wbs_fefo_atp.
    DATA lv_atp_check_date TYPE d.
    DATA lv_expiration_date TYPE d.

    lv_atp_check_date = sy-datum + 3.
    lv_expiration_date = sy-datum + 15.
    mo_availability_api->set_result( is_result = VALUE #(
      is_check_relevant  = abap_true
      is_fully_available = abap_true ) ).
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-1'
        expiration_date       = lv_expiration_date
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-2'
        expiration_date       = lv_expiration_date
        unrestricted_quantity = '1.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_fefo_atp(
      it_demands        = VALUE #(
        ( request_id         = 'REQ-1'
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'REQ-2'
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' ) )
      iv_check_rule     = 'A'
      iv_atp_check_date = lv_atp_check_date ).
    DATA(lt_requests) = mo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-local_estimate-allocation-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-local_estimate-allocation-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_atp_check_date
      act = ls_result-atp_checks[ 1 ]-check_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_requests[ 1 ]-requested_quantity ).
  ENDMETHOD.

  METHOD previews_wbs_loc_atp.
    mo_availability_api->set_result( is_result = VALUE #(
      is_check_relevant  = abap_true
      is_fully_available = abap_true ) ).
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0002'
        unrestricted_quantity = '1.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_by_location_atp(
      it_demands                   = VALUE #(
        ( request_id         = 'REQ-1'
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'REQ-2'
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' ) )
      iv_check_rule                = 'A'
      it_storage_location_priority = VALUE #(
        ( '0002' )
        ( '0001' ) ) ).
    DATA(lt_requests) = mo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-local_estimate-allocation-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-local_estimate-allocation-storage_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-local_estimate-allocation-storage_allocations[
        1 ]-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = sy-datum
      act = ls_result-atp_checks[ 1 ]-check_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_requests[ 1 ]-requested_quantity ).
  ENDMETHOD.

  METHOD previews_wbs_fefo_prio_atp.
    DATA lv_atp_check_date TYPE d.
    DATA lv_first_expiry TYPE d.
    DATA lv_second_expiry TYPE d.

    lv_atp_check_date = sy-datum + 5.
    lv_first_expiry = sy-datum + 15.
    lv_second_expiry = sy-datum + 16.
    mo_availability_api->set_result( is_result = VALUE #(
      is_check_relevant  = abap_true
      is_fully_available = abap_true ) ).
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-1'
        expiration_date       = lv_first_expiry
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-2'
        expiration_date       = lv_second_expiry
        unrestricted_quantity = '1.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_fefo_priority_atp(
      it_demands        = VALUE #(
        ( request_id         = 'SHARED'
          priority           = 1
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'SHARED'
          priority           = 10
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' ) )
      iv_check_rule     = 'A'
      iv_atp_check_date = lv_atp_check_date ).
    DATA(lt_requests) = mo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-local_estimate-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-local_estimate-allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_result-local_estimate-allocations[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-2'
      act = ls_result-local_estimate-batch_allocations[
        1 ]-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-local_estimate-batch_allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-local_estimate-batch_allocations[
        2 ]-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_result-local_estimate-batch_allocations[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_atp_check_date
      act = ls_result-atp_checks[ 1 ]-check_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_requests[ 1 ]-requested_quantity ).
  ENDMETHOD.

  METHOD previews_wbs_loc_prio_atp.
    mo_availability_api->set_result( is_result = VALUE #(
      is_check_relevant  = abap_true
      is_fully_available = abap_true ) ).
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0002'
        unrestricted_quantity = '1.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_location_priority_atp(
      it_demands                     = VALUE #(
        ( request_id         = 'SHARED'
          priority           = 1
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'SHARED'
          priority           = 10
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' ) )
      iv_check_rule                  = 'A'
      it_storage_location_priority   = VALUE #(
        ( '0002' )
        ( '0001' ) )
      it_request_location_priorities = VALUE #(
        ( request_id       = 'SHARED'
          storage_location = '0001'
          priority_rank    = 1 )
        ( request_id       = 'SHARED'
          storage_location = '0002'
          priority_rank    = 2 ) ) ).
    DATA(lt_requests) = mo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-local_estimate-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-local_estimate-allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_result-local_estimate-allocations[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-local_estimate-storage_allocations[
        1 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-local_estimate-storage_allocations[
        2 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = sy-datum
      act = ls_result-atp_checks[ 1 ]-check_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_requests[ 1 ]-requested_quantity ).
  ENDMETHOD.

  METHOD previews_xfer_fefo_atp.
    DATA lv_atp_check_date TYPE d.
    DATA lv_expiration_date TYPE d.
    DATA lv_second_expiration_date TYPE d.

    lv_atp_check_date = sy-datum + 5.
    lv_expiration_date = sy-datum + 15.
    lv_second_expiration_date = sy-datum + 16.
    mo_availability_api->set_result( is_result = VALUE #(
      is_check_relevant  = abap_true
      is_fully_available = abap_true ) ).
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0001'
        batch                 = 'B-1'
        expiration_date       = lv_expiration_date
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0002'
        batch                 = 'B-1'
        expiration_date       = lv_expiration_date
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0001'
        batch                 = 'B-2'
        expiration_date       = lv_second_expiration_date
        unrestricted_quantity = '1.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_transfer_fefo_atp(
      it_demands                     = VALUE #(
        ( request_id              = 'XFER-1'
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-1'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '1.000'
          unit                    = 'EA' )
        ( request_id              = 'XFER-2'
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-2'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '1.000'
          unit                    = 'EA' ) )
      iv_check_rule                  = 'A'
      iv_atp_check_date              = lv_atp_check_date
      it_storage_location_priority   = VALUE #(
        ( '0001' )
        ( '0002' ) )
      it_request_location_priorities = VALUE #(
        ( request_id       = 'XFER-1'
          storage_location = '0002'
          priority_rank    = 1 )
        ( request_id       = 'XFER-2'
          storage_location = '0001'
          priority_rank    = 1 ) ) ).
    DATA(lt_requests) = mo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-local_estimate-allocation-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-local_estimate-allocation-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-local_estimate-allocation-batch_allocations[
        1 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-local_estimate-allocation-batch_allocations[
        2 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-local_estimate-allocation-batch_allocations[
        1 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-local_estimate-allocation-batch_allocations[
        2 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-TARGET-1'
      act = ls_result-local_estimate-transfer_assignments[
        1 ]-destination_wbs_element ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-TARGET-2'
      act = ls_result-local_estimate-transfer_assignments[
        2 ]-destination_wbs_element ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_atp_check_date
      act = ls_result-atp_checks[ 1 ]-check_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_requests[ 1 ]-requested_quantity ).
  ENDMETHOD.

  METHOD previews_xfer_loc_atp.
    mo_availability_api->set_result( is_result = VALUE #(
      is_check_relevant  = abap_true
      is_fully_available = abap_true ) ).
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0001'
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0002'
        unrestricted_quantity = '1.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_transfer_loc_atp(
      it_demands                     = VALUE #(
        ( request_id              = 'XFER-1'
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-1'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '1.000'
          unit                    = 'EA' )
        ( request_id              = 'XFER-2'
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-2'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '1.000'
          unit                    = 'EA' ) )
      iv_check_rule                  = 'A'
      it_storage_location_priority   = VALUE #(
        ( '0002' )
        ( '0001' ) )
      it_request_location_priorities = VALUE #(
        ( request_id       = 'XFER-1'
          storage_location = '0001'
          priority_rank    = 1 )
        ( request_id       = 'XFER-2'
          storage_location = '0002'
          priority_rank    = 1 ) ) ).
    DATA(lt_requests) = mo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-local_estimate-allocation-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-local_estimate-allocation-storage_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-local_estimate-allocation-storage_allocations[
        1 ]-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-local_estimate-allocation-storage_allocations[
        2 ]-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-TARGET-1'
      act = ls_result-local_estimate-transfer_assignments[
        1 ]-destination_wbs_element ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-TARGET-2'
      act = ls_result-local_estimate-transfer_assignments[
        2 ]-destination_wbs_element ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = sy-datum
      act = ls_result-atp_checks[ 1 ]-check_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_requests[ 1 ]-requested_quantity ).
  ENDMETHOD.

  METHOD previews_xfer_fefo_prio_atp.
    DATA lv_atp_check_date TYPE d.
    DATA lv_first_expiry TYPE d.
    DATA lv_second_expiry TYPE d.

    lv_atp_check_date = sy-datum + 5.
    lv_first_expiry = sy-datum + 15.
    lv_second_expiry = sy-datum + 16.
    mo_availability_api->set_result( is_result = VALUE #(
      is_check_relevant  = abap_true
      is_fully_available = abap_true ) ).
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0001'
        batch                 = 'B-1'
        expiration_date       = lv_first_expiry
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0002'
        batch                 = 'B-1'
        expiration_date       = lv_first_expiry
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0001'
        batch                 = 'B-2'
        expiration_date       = lv_second_expiry
        unrestricted_quantity = '1.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_transfer_fefo_prio_atp(
      it_demands                     = VALUE #(
        ( request_id              = 'SHARED'
          priority                = 1
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-1'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '1.000'
          unit                    = 'EA' )
        ( request_id              = 'SHARED'
          priority                = 10
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-2'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '1.000'
          unit                    = 'EA' ) )
      iv_check_rule                  = 'A'
      iv_atp_check_date              = lv_atp_check_date
      it_storage_location_priority   = VALUE #(
        ( '0001' )
        ( '0002' ) )
      it_request_location_priorities = VALUE #(
        ( request_id       = 'SHARED'
          storage_location = '0002'
          priority_rank    = 1 )
        ( request_id       = 'SHARED'
          storage_location = '0001'
          priority_rank    = 2 ) ) ).
    DATA(lt_requests) = mo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-local_estimate-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-local_estimate-allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_result-local_estimate-allocations[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-local_estimate-batch_allocations[
        1 ]-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-local_estimate-batch_allocations[
        2 ]-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-local_estimate-batch_allocations[
        1 ]-split-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-local_estimate-batch_allocations[
        2 ]-split-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-TARGET-1'
      act = ls_result-local_estimate-transfer_assignments[
        1 ]-destination_wbs_element ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-TARGET-2'
      act = ls_result-local_estimate-transfer_assignments[
        2 ]-destination_wbs_element ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_atp_check_date
      act = ls_result-atp_checks[ 1 ]-check_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_requests[ 1 ]-requested_quantity ).
  ENDMETHOD.

  METHOD previews_xfer_loc_prio_atp.
    mo_availability_api->set_result( is_result = VALUE #(
      is_check_relevant  = abap_true
      is_fully_available = abap_true ) ).
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0001'
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0002'
        unrestricted_quantity = '1.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_transfer_loc_prio_atp(
      it_demands                     = VALUE #(
        ( request_id              = 'SHARED'
          priority                = 1
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-1'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '1.000'
          unit                    = 'EA' )
        ( request_id              = 'SHARED'
          priority                = 10
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-2'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '1.000'
          unit                    = 'EA' ) )
      iv_check_rule                  = 'A'
      it_storage_location_priority   = VALUE #(
        ( '0002' )
        ( '0001' ) )
      it_request_location_priorities = VALUE #(
        ( request_id       = 'SHARED'
          storage_location = '0001'
          priority_rank    = 1 )
        ( request_id       = 'SHARED'
          storage_location = '0002'
          priority_rank    = 2 ) ) ).
    DATA(lt_requests) = mo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-local_estimate-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-local_estimate-allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_result-local_estimate-allocations[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-local_estimate-storage_allocations[
        1 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-local_estimate-storage_allocations[
        2 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-TARGET-1'
      act = ls_result-local_estimate-transfer_assignments[
        1 ]-destination_wbs_element ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-TARGET-2'
      act = ls_result-local_estimate-transfer_assignments[
        2 ]-destination_wbs_element ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = sy-datum
      act = ls_result-atp_checks[ 1 ]-check_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_requests[ 1 ]-requested_quantity ).
  ENDMETHOD.

  METHOD rejects_bad_project_atp_dates.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_fefo_atp(
          it_demands        = VALUE #(
            ( request_id         = 'REQ-ATP-FEFO-DATE'
              wbs_element        = 'PRJ-100-001'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          iv_check_rule     = 'A'
          iv_atp_check_date = '20260230' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( mo_availability_api->get_requests( ) ) ).

    CLEAR lv_raised.
    TRY.
        mo_cut->preview_by_location_atp(
          it_demands        = VALUE #(
            ( request_id         = 'REQ-ATP-LOC-DATE'
              wbs_element        = 'PRJ-100-001'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          iv_check_rule     = 'A'
          iv_atp_check_date = '20260230' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( mo_availability_api->get_requests( ) ) ).

    CLEAR lv_raised.
    TRY.
        mo_cut->preview_transfer_fefo_atp(
          it_demands        = VALUE #(
            ( request_id              = 'XFER-FEFO-DATE'
              source_wbs_element      = 'PRJ-SOURCE-001'
              destination_wbs_element = 'PRJ-TARGET-001'
              material                = 'MAT-1'
              plant                   = '1000'
              requested_quantity      = '1.000'
              unit                    = 'EA' ) )
          iv_check_rule     = 'A'
          iv_atp_check_date = '20260230' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( mo_availability_api->get_requests( ) ) ).

    CLEAR lv_raised.
    TRY.
        mo_cut->preview_transfer_loc_atp(
          it_demands        = VALUE #(
            ( request_id              = 'XFER-LOC-DATE'
              source_wbs_element      = 'PRJ-SOURCE-001'
              destination_wbs_element = 'PRJ-TARGET-001'
              material                = 'MAT-1'
              plant                   = '1000'
              requested_quantity      = '1.000'
              unit                    = 'EA' ) )
          iv_check_rule     = 'A'
          iv_atp_check_date = '20260230' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( mo_availability_api->get_requests( ) ) ).

    CLEAR lv_raised.
    TRY.
        mo_cut->preview_fefo_priority_atp(
          it_demands        = VALUE #(
            ( request_id         = 'REQ-ATP-FEFO-PRIO-DATE'
              priority           = 5
              wbs_element        = 'PRJ-100-001'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          iv_check_rule     = 'A'
          iv_atp_check_date = '20260230' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( mo_availability_api->get_requests( ) ) ).

    CLEAR lv_raised.
    TRY.
        mo_cut->preview_location_priority_atp(
          it_demands        = VALUE #(
            ( request_id         = 'REQ-ATP-LOC-PRIO-DATE'
              priority           = 5
              wbs_element        = 'PRJ-100-001'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          iv_check_rule     = 'A'
          iv_atp_check_date = '20260230' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( mo_availability_api->get_requests( ) ) ).

    CLEAR lv_raised.
    TRY.
        mo_cut->preview_transfer_fefo_prio_atp(
          it_demands        = VALUE #(
            ( request_id              = 'XFER-FEFO-PRIO-DATE'
              priority                = 5
              source_wbs_element      = 'PRJ-SOURCE-001'
              destination_wbs_element = 'PRJ-TARGET-001'
              material                = 'MAT-1'
              plant                   = '1000'
              requested_quantity      = '1.000'
              unit                    = 'EA' ) )
          iv_check_rule     = 'A'
          iv_atp_check_date = '20260230' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( mo_availability_api->get_requests( ) ) ).

    CLEAR lv_raised.
    TRY.
        mo_cut->preview_transfer_loc_prio_atp(
          it_demands        = VALUE #(
            ( request_id              = 'XFER-LOC-PRIO-DATE'
              priority                = 5
              source_wbs_element      = 'PRJ-SOURCE-001'
              destination_wbs_element = 'PRJ-TARGET-001'
              material                = 'MAT-1'
              plant                   = '1000'
              requested_quantity      = '1.000'
              unit                    = 'EA' ) )
          iv_check_rule     = 'A'
          iv_atp_check_date = '20260230' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( mo_availability_api->get_requests( ) ) ).
  ENDMETHOD.

  METHOD previews_dated_wbs_fefo_atp.
    DATA lv_early_date TYPE d.
    DATA lv_late_date TYPE d.
    DATA lv_early_expiry TYPE d.
    DATA lv_late_expiry TYPE d.

    lv_early_date = sy-datum + 4.
    lv_late_date = sy-datum + 8.
    lv_early_expiry = sy-datum + 15.
    lv_late_expiry = sy-datum + 16.
    mo_availability_api->set_result( is_result = VALUE #(
      is_check_relevant  = abap_true
      confirmation_lines = VALUE #(
        ( confirmed_date     = lv_early_date
          confirmed_quantity = '1.500' )
        ( confirmed_date     = lv_late_date
          confirmed_quantity = '1.000' ) ) ) ).
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-EARLY'
        expiration_date       = lv_early_expiry
        unrestricted_quantity = '2.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-LATE'
        expiration_date       = lv_late_expiry
        unrestricted_quantity = '1.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_fefo_by_date_atp(
      it_demands    = VALUE #(
        ( request_id         = 'SHARED'
          required_date      = lv_late_date
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'SHARED'
          required_date      = lv_early_date
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'SHARED'
          required_date      = lv_early_date
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' ) )
      iv_check_rule = 'A'
      iv_as_of_date = sy-datum ).
    DATA(lt_requests) = mo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-local_estimate-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_late_date
      act = ls_result-local_estimate-allocations[
        1 ]-required_date ).
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
      act = lt_requests[ 1 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.500' )
      act = ls_result-atp_checks[ 1 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_late_date
      act = ls_result-atp_checks[ 2 ]-check_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_requests[ 2 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.500' )
      act = ls_result-atp_checks[ 2 ]-confirmed_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.500' )
      act = ls_result-atp_checks[ 2 ]-unconfirmed_base_quantity ).
  ENDMETHOD.

  METHOD previews_dated_wbs_loc_atp.
    DATA lv_required_date TYPE d.

    lv_required_date = sy-datum + 6.
    mo_availability_api->set_result( is_result = VALUE #(
      is_check_relevant  = abap_true
      is_fully_available = abap_true ) ).
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0002'
        unrestricted_quantity = '1.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_by_location_date_atp(
      it_demands                     = VALUE #(
        ( request_id         = 'SHARED'
          required_date      = lv_required_date
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'SHARED'
          required_date      = lv_required_date
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' ) )
      iv_check_rule                  = 'A'
      it_storage_location_priority   = VALUE #(
        ( '0002' )
        ( '0001' ) )
      it_request_location_priorities = VALUE #(
        ( request_id       = 'SHARED'
          storage_location = '0001'
          priority_rank    = 1 )
        ( request_id       = 'SHARED'
          storage_location = '0002'
          priority_rank    = 2 ) ) ).
    DATA(lt_requests) = mo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-local_estimate-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SHARED'
      act = ls_result-local_estimate-allocations[
        1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-local_estimate-storage_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-local_estimate-storage_allocations[
        1 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-local_estimate-storage_allocations[
        2 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_required_date
      act = ls_result-atp_checks[ 1 ]-check_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_requests[ 1 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'A'
      act = lt_requests[ 1 ]-check_rule ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 1 ]-confirmed_base_quantity ).
  ENDMETHOD.

  METHOD previews_dated_xfer_fefo_atp.
    DATA lv_required_date TYPE d.
    DATA lv_first_expiry TYPE d.
    DATA lv_second_expiry TYPE d.

    lv_required_date = sy-datum + 6.
    lv_first_expiry = sy-datum + 15.
    lv_second_expiry = sy-datum + 16.
    mo_availability_api->set_result( is_result = VALUE #(
      is_check_relevant  = abap_true
      is_fully_available = abap_true ) ).
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0001'
        batch                 = 'B-1'
        expiration_date       = lv_first_expiry
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0002'
        batch                 = 'B-1'
        expiration_date       = lv_first_expiry
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0001'
        batch                 = 'B-2'
        expiration_date       = lv_second_expiry
        unrestricted_quantity = '1.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_transfer_fefo_date_atp(
      it_demands                     = VALUE #(
        ( request_id              = 'SHARED'
          required_date           = lv_required_date
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-1'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '1.000'
          unit                    = 'EA' )
        ( request_id              = 'SHARED'
          required_date           = lv_required_date
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-2'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '1.000'
          unit                    = 'EA' ) )
      iv_check_rule                  = 'A'
      it_storage_location_priority   = VALUE #(
        ( '0001' )
        ( '0002' ) )
      it_request_location_priorities = VALUE #(
        ( request_id       = 'SHARED'
          storage_location = '0002'
          priority_rank    = 1 )
        ( request_id       = 'SHARED'
          storage_location = '0001'
          priority_rank    = 2 ) ) ).
    DATA(lt_requests) = mo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-local_estimate-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-local_estimate-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SHARED'
      act = ls_result-local_estimate-allocations[
        1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-local_estimate-batch_allocations[
        1 ]-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-local_estimate-batch_allocations[
        2 ]-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-local_estimate-batch_allocations[
        1 ]-split-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-local_estimate-batch_allocations[
        2 ]-split-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-TARGET-1'
      act = ls_result-local_estimate-transfer_assignments[
        1 ]-destination_wbs_element ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-TARGET-2'
      act = ls_result-local_estimate-transfer_assignments[
        2 ]-destination_wbs_element ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_required_date
      act = ls_result-atp_checks[ 1 ]-check_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_requests[ 1 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'A'
      act = lt_requests[ 1 ]-check_rule ).
  ENDMETHOD.

  METHOD previews_dated_xfer_loc_atp.
    DATA lv_required_date TYPE d.

    lv_required_date = sy-datum + 6.
    mo_availability_api->set_result( is_result = VALUE #(
      is_check_relevant  = abap_true
      is_fully_available = abap_true ) ).
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0001'
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0002'
        unrestricted_quantity = '1.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_transfer_loc_date_atp(
      it_demands                     = VALUE #(
        ( request_id              = 'SHARED'
          required_date           = lv_required_date
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-1'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '1.000'
          unit                    = 'EA' )
        ( request_id              = 'SHARED'
          required_date           = lv_required_date
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-2'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '1.000'
          unit                    = 'EA' ) )
      iv_check_rule                  = 'A'
      it_storage_location_priority   = VALUE #(
        ( '0002' )
        ( '0001' ) )
      it_request_location_priorities = VALUE #(
        ( request_id       = 'SHARED'
          storage_location = '0001'
          priority_rank    = 1 )
        ( request_id       = 'SHARED'
          storage_location = '0002'
          priority_rank    = 2 ) ) ).
    DATA(lt_requests) = mo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-local_estimate-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SHARED'
      act = ls_result-local_estimate-allocations[
        1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-TARGET-1'
      act = ls_result-local_estimate-transfer_assignments[
        1 ]-destination_wbs_element ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-local_estimate-storage_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-local_estimate-storage_allocations[
        1 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-local_estimate-storage_allocations[
        2 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-TARGET-2'
      act = ls_result-local_estimate-transfer_assignments[
        2 ]-destination_wbs_element ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-atp_checks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_required_date
      act = ls_result-atp_checks[ 1 ]-check_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-atp_checks[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_requests[ 1 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'A'
      act = lt_requests[ 1 ]-check_rule ).
  ENDMETHOD.

  METHOD rejects_bad_project_atp_rule.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_fefo_by_date_atp(
          it_demands    = VALUE #(
            ( request_id         = 'REQ-ATP'
              required_date      = sy-datum + 1
              wbs_element        = 'PRJ-100-001'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          iv_check_rule = space ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( mo_availability_api->get_requests( ) ) ).

    CLEAR lv_raised.
    TRY.
        mo_cut->preview_by_location_date_atp(
          it_demands    = VALUE #(
            ( request_id         = 'REQ-ATP-LOCATION'
              required_date      = sy-datum + 1
              wbs_element        = 'PRJ-100-001'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          iv_check_rule = space ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( mo_availability_api->get_requests( ) ) ).

    CLEAR lv_raised.
    TRY.
        mo_cut->preview_transfer_fefo_date_atp(
          it_demands    = VALUE #(
            ( request_id              = 'REQ-ATP-XFER-FEFO'
              required_date           = sy-datum + 1
              source_wbs_element      = 'PRJ-SOURCE-001'
              destination_wbs_element = 'PRJ-TARGET-001'
              material                = 'MAT-1'
              plant                   = '1000'
              requested_quantity      = '1.000'
              unit                    = 'EA' ) )
          iv_check_rule = space ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( mo_availability_api->get_requests( ) ) ).

    CLEAR lv_raised.
    TRY.
        mo_cut->preview_transfer_loc_date_atp(
          it_demands    = VALUE #(
            ( request_id              = 'REQ-ATP-XFER-LOC'
              required_date           = sy-datum + 1
              source_wbs_element      = 'PRJ-SOURCE-001'
              destination_wbs_element = 'PRJ-TARGET-001'
              material                = 'MAT-1'
              plant                   = '1000'
              requested_quantity      = '1.000'
              unit                    = 'EA' ) )
          iv_check_rule = space ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( mo_availability_api->get_requests( ) ) ).

    CLEAR lv_raised.
    TRY.
        mo_cut->preview_fefo_atp(
          it_demands    = VALUE #(
            ( request_id         = 'REQ-ATP-FEFO'
              wbs_element        = 'PRJ-100-001'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          iv_check_rule = space ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( mo_availability_api->get_requests( ) ) ).

    CLEAR lv_raised.
    TRY.
        mo_cut->preview_by_location_atp(
          it_demands    = VALUE #(
            ( request_id         = 'REQ-ATP-LOC'
              wbs_element        = 'PRJ-100-001'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          iv_check_rule = space ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( mo_availability_api->get_requests( ) ) ).

    CLEAR lv_raised.
    TRY.
        mo_cut->preview_transfer_fefo_atp(
          it_demands    = VALUE #(
            ( request_id              = 'XFER-ATP-FEFO'
              source_wbs_element      = 'PRJ-SOURCE-001'
              destination_wbs_element = 'PRJ-TARGET-001'
              material                = 'MAT-1'
              plant                   = '1000'
              requested_quantity      = '1.000'
              unit                    = 'EA' ) )
          iv_check_rule = space ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( mo_availability_api->get_requests( ) ) ).

    CLEAR lv_raised.
    TRY.
        mo_cut->preview_transfer_loc_atp(
          it_demands    = VALUE #(
            ( request_id              = 'XFER-ATP-LOC'
              source_wbs_element      = 'PRJ-SOURCE-001'
              destination_wbs_element = 'PRJ-TARGET-001'
              material                = 'MAT-1'
              plant                   = '1000'
              requested_quantity      = '1.000'
              unit                    = 'EA' ) )
          iv_check_rule = space ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( mo_availability_api->get_requests( ) ) ).

    CLEAR lv_raised.
    TRY.
        mo_cut->preview_fefo_priority_atp(
          it_demands    = VALUE #(
            ( request_id         = 'REQ-ATP-FEFO-PRIO'
              priority           = 5
              wbs_element        = 'PRJ-100-001'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          iv_check_rule = space ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( mo_availability_api->get_requests( ) ) ).

    CLEAR lv_raised.
    TRY.
        mo_cut->preview_location_priority_atp(
          it_demands    = VALUE #(
            ( request_id         = 'REQ-ATP-LOC-PRIO'
              priority           = 5
              wbs_element        = 'PRJ-100-001'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          iv_check_rule = space ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( mo_availability_api->get_requests( ) ) ).

    CLEAR lv_raised.
    TRY.
        mo_cut->preview_transfer_fefo_prio_atp(
          it_demands    = VALUE #(
            ( request_id              = 'XFER-ATP-FEFO-PRIO'
              priority                = 5
              source_wbs_element      = 'PRJ-SOURCE-001'
              destination_wbs_element = 'PRJ-TARGET-001'
              material                = 'MAT-1'
              plant                   = '1000'
              requested_quantity      = '1.000'
              unit                    = 'EA' ) )
          iv_check_rule = space ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( mo_availability_api->get_requests( ) ) ).

    CLEAR lv_raised.
    TRY.
        mo_cut->preview_transfer_loc_prio_atp(
          it_demands    = VALUE #(
            ( request_id              = 'XFER-ATP-LOC-PRIO'
              priority                = 5
              source_wbs_element      = 'PRJ-SOURCE-001'
              destination_wbs_element = 'PRJ-TARGET-001'
              material                = 'MAT-1'
              plant                   = '1000'
              requested_quantity      = '1.000'
              unit                    = 'EA' ) )
          iv_check_rule = space ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( mo_availability_api->get_requests( ) ) ).
  ENDMETHOD.

  METHOD allocates_dated_fefo_priority.
    DATA lv_early_date TYPE d.
    DATA lv_late_date TYPE d.
    DATA lv_first_expiry TYPE d.
    DATA lv_second_expiry TYPE d.
    DATA lv_third_expiry TYPE d.

    lv_early_date = sy-datum + 4.
    lv_late_date = sy-datum + 8.
    lv_first_expiry = sy-datum + 15.
    lv_second_expiry = sy-datum + 16.
    lv_third_expiry = sy-datum + 17.

    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-1'
        expiration_date       = lv_first_expiry
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-2'
        expiration_date       = lv_second_expiry
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-3'
        expiration_date       = lv_third_expiry
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0002'
        batch                 = 'B-UNDATED'
        unrestricted_quantity = '1.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_fefo_by_date(
      it_demands                 = VALUE #(
        ( request_id         = 'REQ-LATE'
          required_date      = lv_late_date
          priority           = 99
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'REQ-EARLY-LOW'
          required_date      = lv_early_date
          priority           = 1
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id            = 'REQ-EARLY-HIGH'
          required_date         = lv_early_date
          priority              = 5
          wbs_element           = 'PRJ-100-001'
          material              = 'MAT-1'
          plant                 = '1000'
          batch                 = 'B-UNDATED'
          requested_quantity    = '1.000'
          unit                  = 'EA'
          allow_undated_batches = abap_true ) )
      iv_include_undated_batches = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-LATE'
      act = ls_result-allocations[
        1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-EARLY-LOW'
      act = ls_result-allocations[
        2 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-EARLY-HIGH'
      act = ls_result-allocations[
        3 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-allocations[
        allocation-allocation-request_id = 'REQ-EARLY-HIGH'
        ]-allocation-allocation-allow_undated_batches ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-UNDATED'
      act = ls_result-batch_allocations[
        split-batch_allocation-request_id = 'REQ-EARLY-HIGH'
        split-batch_allocation-batch = 'B-UNDATED'
        ]-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-batch_allocations[
        split-batch_allocation-request_id = 'REQ-EARLY-HIGH'
        split-batch_allocation-batch = 'B-UNDATED'
        ]-split-batch_allocation-allow_undated_batches ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_early_date
      act = ls_result-batch_allocations[
        split-batch_allocation-request_id = 'REQ-EARLY-HIGH'
        split-batch_allocation-batch = 'B-UNDATED'
        ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = ls_result-batch_allocations[
        split-batch_allocation-request_id = 'REQ-EARLY-HIGH'
        split-batch_allocation-batch = 'B-UNDATED'
        ]-priority ).
  ENDMETHOD.

  METHOD rank_date_fefo_loc.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-SAME'
        expiration_date       = '20261230'
        unrestricted_quantity = '3.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0002'
        batch                 = 'B-SAME'
        expiration_date       = '20261230'
        unrestricted_quantity = '5.000' ) ) ).
    DATA(lt_location_priorities) =
      VALUE zcl_stock_service=>ty_request_location_priorities(
        ( request_id       = 'WBS-DATE'
          storage_location = '0002'
          priority_rank    = 1 ) ).

    DATA(ls_result) = mo_cut->preview_fefo_by_date(
      it_demands                     = VALUE #(
        ( request_id              = 'WBS-DATE'
          required_date           = '20261201'
          priority                = 10
          wbs_element             = 'PRJ-100-001'
          material                = 'MAT-1'
          plant                   = '1000'
          storage_location        = '0001'
          allow_location_fallback = abap_true
          requested_quantity      = '4.000'
          unit                    = 'EA' )
        ( request_id         = 'WBS-DATE'
          required_date      = '20261201'
          priority           = 5
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '4.000'
          unit               = 'EA' ) )
      it_request_location_priorities = lt_location_priorities
      iv_as_of_date                  = '20261014' ).
    DATA(ls_first_split_row) = ls_result-batch_allocations[ 1 ].
    DATA(ls_second_split_row) = ls_result-batch_allocations[ 2 ].
    DATA(ls_third_split_row) = ls_result-batch_allocations[ 3 ].
    DATA(ls_first_split) = ls_first_split_row-split-batch_allocation.
    DATA(ls_second_split) = ls_second_split_row-split-batch_allocation.
    DATA(ls_third_split) = ls_third_split_row-split-batch_allocation.

    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_first_split-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_first_split-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_second_split-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_second_split-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_third_split-storage_location ).
  ENDMETHOD.

  METHOD rejects_bad_dated_fefo.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_fefo_by_date(
          it_demands = VALUE #(
            ( request_id         = 'REQ-BAD-DATE'
              required_date      = '20260230'
              wbs_element        = 'PRJ-100-001'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).

  ENDMETHOD.

  METHOD rejects_batch_expiry_conflict.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-DUPLICATE'
        expiration_date       = '20261210'
        unrestricted_quantity = '2.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-DUPLICATE'
        expiration_date       = '20261211'
        unrestricted_quantity = '2.000' ) ) ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_fefo(
          it_demands    = VALUE #(
            ( request_id         = 'REQ-DUPLICATE-BATCH'
              wbs_element        = 'PRJ-100-001'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          iv_as_of_date = '20261014' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
  ENDMETHOD.

  METHOD rejects_invalid_batch_expiry.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-BAD-DATE'
        expiration_date       = '20260230'
        unrestricted_quantity = '2.000' ) ) ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_fefo(
          it_demands    = VALUE #(
            ( request_id         = 'REQ-INVALID-BATCH-DATE'
              wbs_element        = 'PRJ-100-001'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          iv_as_of_date = '20261014' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
  ENDMETHOD.

  METHOD rejects_negative_demand_shelf.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_fefo(
          it_demands    = VALUE #(
            ( request_id              = 'REQ-NEG-SHELF'
              wbs_element             = 'PRJ-100-001'
              material                = 'MAT-1'
              plant                   = '1000'
              requested_quantity      = '1.000'
              unit                    = 'EA'
              minimum_shelf_life_days = -1 ) )
          iv_as_of_date = '20261014' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
  ENDMETHOD.

  METHOD allocates_dated_transfer_fefo.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-1'
        expiration_date       = '20261210'
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-2'
        expiration_date       = '20261211'
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-3'
        expiration_date       = '20261212'
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-UNDATED'
        unrestricted_quantity = '1.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_transfer_fefo_by_date(
      it_demands                 = VALUE #(
        ( request_id              = 'XFER-LATE'
          required_date           = '20261205'
          priority                = 99
          source_wbs_element      = 'PRJ-100-001'
          destination_wbs_element = 'PRJ-TARGET-001'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '1.000'
          unit                    = 'EA'
          require_known_expiry    = abap_true )
        ( request_id              = 'XFER-EARLY-LOW'
          required_date           = '20261201'
          priority                = 1
          source_wbs_element      = 'PRJ-100-001'
          destination_wbs_element = 'PRJ-TARGET-002'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '1.000'
          unit                    = 'EA' )
        ( request_id              = 'XFER-EARLY-HIGH'
          required_date           = '20261201'
          priority                = 5
          source_wbs_element      = 'PRJ-100-001'
          destination_wbs_element = 'PRJ-TARGET-003'
          material                = 'MAT-1'
          plant                   = '1000'
          batch                   = 'B-UNDATED'
          requested_quantity      = '1.000'
          unit                    = 'EA'
          allow_undated_batches   = abap_true ) )
      iv_as_of_date              = '20261001'
      iv_include_undated_batches = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'XFER-LATE'
      act = ls_result-allocations[
        1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-allocations[
        allocation-allocation-request_id = 'XFER-LATE'
        ]-allocation-allocation-require_known_expiry ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-allocations[
        allocation-allocation-request_id = 'XFER-EARLY-HIGH'
        ]-allocation-allocation-allow_undated_batches ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-UNDATED'
      act = ls_result-batch_allocations[
        split-batch_allocation-request_id = 'XFER-EARLY-HIGH'
        split-batch_allocation-batch = 'B-UNDATED'
        ]-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-batch_allocations[
        split-batch_allocation-request_id = 'XFER-EARLY-HIGH'
        split-batch_allocation-batch = 'B-UNDATED'
        ]-split-batch_allocation-allow_undated_batches ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-TARGET-001'
      act = ls_result-transfer_assignments[
        1 ]-destination_wbs_element ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261201'
      act = ls_result-batch_allocations[
        3 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261201'
      act = ls_result-batch_allocations[
        split-batch_allocation-request_id = 'XFER-EARLY-HIGH'
        ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = ls_result-batch_allocations[
        split-batch_allocation-request_id = 'XFER-EARLY-HIGH'
        ]-priority ).

    DATA(lv_reads_before_conflict) = mo_repository->mv_wbs_stock_read_calls.
    DATA(lv_conflict_rejected) = abap_false.
    TRY.
        mo_cut->preview_transfer_fefo(
          it_demands    = VALUE #(
            ( request_id              = 'XFER-CONFLICT'
              source_wbs_element      = 'PRJ-100-001'
              destination_wbs_element = 'PRJ-TARGET-CONFLICT'
              material                = 'MAT-1'
              plant                   = '1000'
              requested_quantity      = '1.000'
              unit                    = 'EA'
              require_known_expiry    = abap_true
              allow_undated_batches   = abap_true ) )
          iv_as_of_date = '20261001' ).
      CATCH zcx_invalid_stock_request.
        lv_conflict_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_conflict_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_reads_before_conflict
      act = mo_repository->mv_wbs_stock_read_calls ).
  ENDMETHOD.

  METHOD repeats_id_dated_xfer_fefo.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0001'
        batch                 = 'B-EARLY'
        expiration_date       = '20261210'
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0001'
        batch                 = 'B-LATE'
        expiration_date       = '20261211'
        unrestricted_quantity = '1.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_transfer_fefo_by_date(
      it_demands    = VALUE #(
        ( request_id              = 'SHARED'
          required_date           = '20261205'
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-LATE'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '1.000'
          unit                    = 'EA' )
        ( request_id              = 'SHARED'
          required_date           = '20261201'
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-EARLY'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '1.000'
          unit                    = 'EA' ) )
      iv_as_of_date = '20261001' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SHARED'
      act = ls_result-allocations[
        1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SHARED'
      act = ls_result-allocations[
        2 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261205'
      act = ls_result-allocations[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATE'
      act = ls_result-batch_allocations[
        1 ]-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EARLY'
      act = ls_result-batch_allocations[
        2 ]-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-TARGET-LATE'
      act = ls_result-transfer_assignments[
        1 ]-destination_wbs_element ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-TARGET-EARLY'
      act = ls_result-transfer_assignments[
        2 ]-destination_wbs_element ).
  ENDMETHOD.

  METHOD prioritizes_wbs_transfer_fefo.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0001'
        batch                 = 'B-SOON'
        expiration_date       = '20261020'
        unrestricted_quantity = '10.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0001'
        batch                 = 'B-LATER'
        expiration_date       = '20261120'
        unrestricted_quantity = '15.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_transfer_fefo_priority(
      it_demands    = VALUE #(
        ( request_id              = 'SHARED'
          priority                = 1
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-001'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '12.000'
          unit                    = 'EA' )
        ( request_id              = 'SHARED'
          priority                = 10
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-002'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '15.000'
          unit                    = 'EA'
          require_known_expiry    = abap_true )
        ( request_id              = 'SHARED'
          priority                = 10
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-003'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '10.000'
          unit                    = 'EA' ) )
      iv_as_of_date = '20261015' ).
    DATA(ls_low_allocation) = ls_result-allocations[ 1 ].
    DATA(ls_first_high_allocation) = ls_result-allocations[ 2 ].
    DATA(ls_second_high_allocation) = ls_result-allocations[ 3 ].
    DATA(ls_low_summary) = ls_low_allocation-allocation.
    DATA(ls_first_high_summary) = ls_first_high_allocation-allocation.
    DATA(ls_second_high_summary) = ls_second_high_allocation-allocation.
    DATA(ls_first_batch_split) = ls_result-batch_allocations[ 1 ].
    DATA(ls_second_batch_split) = ls_result-batch_allocations[ 2 ].
    DATA(ls_third_batch_split) = ls_result-batch_allocations[ 3 ].

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_low_summary-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_low_summary-allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_first_high_summary-allocation-require_known_expiry ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_first_batch_split-split-batch_allocation-require_known_expiry ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_second_batch_split-split-batch_allocation-require_known_expiry ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '15.000' )
      act = ls_first_high_summary-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_second_high_summary-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-SOON'
      act = ls_first_batch_split-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_second_batch_split-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_third_batch_split-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-TARGET-001'
      act = ls_result-transfer_assignments[
        1 ]-destination_wbs_element ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-TARGET-002'
      act = ls_result-transfer_assignments[
        2 ]-destination_wbs_element ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_result-transfer_assignments[ 3 ]-priority ).
  ENDMETHOD.

  METHOD preserves_xfer_fefo_row_rule.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0001'
        batch                 = 'B-1'
        expiration_date       = '20261231'
        unrestricted_quantity = '2.000' ) ) ).

    DATA(ls_base_result) = mo_cut->preview_transfer_fefo(
      it_demands               = VALUE #(
        ( request_id              = 'STRICT'
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-STRICT'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '3.000'
          require_full_quantity   = abap_true
          unit                    = 'EA' )
        ( request_id              = 'PARTIAL'
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-PARTIAL'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '2.000'
          unit                    = 'EA' ) )
      iv_as_of_date            = '20261015'
      iv_require_full_quantity = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_base_result-allocation-allocations[
        allocation-request_id = 'STRICT'
        ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_base_result-allocation-allocations[
        allocation-request_id = 'STRICT'
        ]-allocation-require_full_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_base_result-allocation-allocations[
        allocation-request_id = 'PARTIAL'
        ]-allocation-allocated_quantity ).

    DATA(ls_priority_result) = mo_cut->preview_transfer_fefo_priority(
      it_demands               = VALUE #(
        ( request_id              = 'STRICT'
          priority                = 20
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-STRICT'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '3.000'
          require_full_quantity   = abap_true
          unit                    = 'EA' )
        ( request_id              = 'PARTIAL'
          priority                = 10
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-PARTIAL'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '2.000'
          unit                    = 'EA' ) )
      iv_as_of_date            = '20261015'
      iv_require_full_quantity = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_priority_result-allocations[
        allocation-allocation-request_id = 'STRICT'
        ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_priority_result-allocations[
        allocation-allocation-request_id = 'STRICT'
        ]-allocation-allocation-require_full_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_priority_result-allocations[
        allocation-allocation-request_id = 'PARTIAL'
        ]-allocation-allocation-allocated_quantity ).

    DATA(ls_dated_result) = mo_cut->preview_transfer_fefo_by_date(
      it_demands               = VALUE #(
        ( request_id              = 'STRICT'
          required_date           = '20261016'
          priority                = 20
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-STRICT'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '3.000'
          require_full_quantity   = abap_true
          unit                    = 'EA' )
        ( request_id              = 'PARTIAL'
          required_date           = '20261016'
          priority                = 10
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-PARTIAL'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '2.000'
          unit                    = 'EA' ) )
      iv_as_of_date            = '20261015'
      iv_require_full_quantity = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_dated_result-allocations[
        allocation-allocation-request_id = 'STRICT'
        ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_dated_result-allocations[
        allocation-allocation-request_id = 'STRICT'
        ]-allocation-allocation-require_full_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_dated_result-allocations[
        allocation-allocation-request_id = 'PARTIAL'
        ]-allocation-allocation-allocated_quantity ).
  ENDMETHOD.

  METHOD preserves_xfer_loc_row_rule.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0001'
        unrestricted_quantity = '2.000' ) ) ).

    DATA(ls_base_result) = mo_cut->preview_transfer_by_location(
      it_demands               = VALUE #(
        ( request_id              = 'STRICT'
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-STRICT'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '3.000'
          require_full_quantity   = abap_true
          unit                    = 'EA' )
        ( request_id              = 'PARTIAL'
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-PARTIAL'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '2.000'
          unit                    = 'EA' ) )
      iv_require_full_quantity = abap_false ).
    DATA(ls_priority_result) = mo_cut->preview_transfer_loc_priority(
      it_demands               = VALUE #(
        ( request_id              = 'STRICT'
          priority                = 20
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-STRICT'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '3.000'
          require_full_quantity   = abap_true
          unit                    = 'EA' )
        ( request_id              = 'PARTIAL'
          priority                = 10
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-PARTIAL'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '2.000'
          unit                    = 'EA' ) )
      iv_require_full_quantity = abap_false ).
    DATA(ls_dated_result) = mo_cut->preview_transfer_location_date(
      it_demands               = VALUE #(
        ( request_id              = 'STRICT'
          required_date           = '20261015'
          priority                = 20
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-STRICT'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '3.000'
          require_full_quantity   = abap_true
          unit                    = 'EA' )
        ( request_id              = 'PARTIAL'
          required_date           = '20261016'
          priority                = 10
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-PARTIAL'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '2.000'
          unit                    = 'EA' ) )
      iv_require_full_quantity = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_base_result-allocation-allocations[
        allocation-request_id = 'STRICT'
        ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_base_result-allocation-allocations[
        allocation-request_id = 'STRICT'
        ]-allocation-require_full_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_base_result-allocation-allocations[
        allocation-request_id = 'PARTIAL'
        ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_priority_result-allocations[
        allocation-allocation-request_id = 'STRICT'
        ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_priority_result-allocations[
        allocation-allocation-request_id = 'STRICT'
        ]-allocation-allocation-require_full_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_priority_result-allocations[
        allocation-allocation-request_id = 'PARTIAL'
        ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_dated_result-allocations[
        allocation-allocation-request_id = 'STRICT'
        ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_dated_result-allocations[
        allocation-allocation-request_id = 'STRICT'
        ]-allocation-allocation-require_full_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_dated_result-allocations[
        allocation-allocation-request_id = 'PARTIAL'
        ]-allocation-allocation-allocated_quantity ).
  ENDMETHOD.

  METHOD rejects_bad_transfer_fefo_date.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_transfer_fefo_by_date(
          it_demands = VALUE #(
            ( request_id              = 'XFER-BAD-DATE'
              required_date           = '20260230'
              source_wbs_element      = 'PRJ-100-001'
              destination_wbs_element = 'PRJ-TARGET-001'
              material                = 'MAT-1'
              plant                   = '1000'
              requested_quantity      = '1.000'
              unit                    = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
  ENDMETHOD.

  METHOD previews_project_wbs_transfer.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0001'
        batch                 = 'B-EARLY'
        expiration_date       = '20261201'
        unrestricted_quantity = '2.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0002'
        batch                 = 'B-LATE'
        expiration_date       = '20270101'
        unrestricted_quantity = '4.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0003'
        batch                 = 'B-SHORT-LIFE'
        expiration_date       = '20261220'
        unrestricted_quantity = '5.000' ) ) ).
    mo_repository->set_reservations( it_reservations = VALUE #(
      ( material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-SOURCE-001'
        storage_location   = '0002'
        batch              = 'B-LATE'
        required_quantity  = '4.000'
        withdrawn_quantity = '1.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_transfer_fefo(
      it_demands    = VALUE #(
        ( request_id              = 'P-TRANSFER'
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-002'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '5.000'
          unit                    = 'EA'
          fefo_as_of_date         = '20261215'
          minimum_shelf_life_days = 10 ) )
      iv_as_of_date = '20261013' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-transfer_assignments ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-SOURCE-001'
      act = ls_result-transfer_assignments[ 1 ]-source_wbs_element ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-TARGET-002'
      act = ls_result-transfer_assignments[ 1 ]-destination_wbs_element ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-allocation-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATE'
      act = ls_result-allocation-batch_allocations[ 1 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocation-allocations[ 1 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocation-batch_allocations[
        1 ]-batch_allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261215'
      act = ls_result-allocation-batch_allocations[
        1 ]-batch_allocation-as_of_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_result-allocation-batch_allocations[
        1 ]-batch_allocation-minimum_shelf_life_days ).
  ENDMETHOD.

  METHOD shares_stock_between_demands.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-ONE'
        expiration_date       = '20270101'
        unrestricted_quantity = '5.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_fefo(
      it_demands    = VALUE #(
        ( request_id         = 'P-FIRST'
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '4.000'
          unit               = 'EA' )
        ( request_id         = 'P-SECOND'
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '4.000'
          unit               = 'EA' ) )
      iv_as_of_date = '20261013' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-allocation-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-allocation-allocations[ 2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocation-allocations[ 2 ]-allocation-shortfall_quantity ).
  ENDMETHOD.

  METHOD allocates_projected_fefo.
    DATA(ls_result) = mo_cut->preview_fefo(
      it_demands                  = VALUE #(
        ( request_id         = 'REQ-EARLY'
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '4.000'
          unit               = 'EA' )
        ( request_id         = 'REQ-LATER'
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '4.000'
          unit               = 'EA'
          fefo_as_of_date    = '20261020' )
        ( request_id         = 'REQ-OTHER-WBS'
          wbs_element        = 'PRJ-OTHER'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '4.000'
          unit               = 'EA'
          fefo_as_of_date    = '20261020' ) )
      it_projected_batch_receipts = VALUE #(
        ( wbs_element      = 'PRJ-100-001'
          material         = 'MAT-1'
          plant            = '1000'
          storage_location = '0001'
          batch            = 'B-RECEIPT'
          expiration_date  = '20261231'
          receipt_date     = '20261018'
          base_quantity    = '4.000' ) )
      iv_as_of_date               = '20261013' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-allocation-allocations[
        1 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-allocation-allocations[
        1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-allocation-allocations[
        2 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-allocation-allocations[
        2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-RECEIPT'
      act = ls_result-allocation-batch_allocations[
        1 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261018'
      act = ls_result-allocation-batch_allocations[
        1 ]-available_from_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-allocation-allocations[
        3 ]-allocation-available_quantity ).
  ENDMETHOD.

  METHOD rejects_unmatched_receipts.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_fefo(
          it_demands                  = VALUE #(
            ( request_id         = 'REQ-ONE'
              wbs_element        = 'PRJ-100-001'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          it_projected_batch_receipts = VALUE #(
            ( wbs_element      = 'PRJ-OTHER'
              material         = 'MAT-1'
              plant            = '1000'
              storage_location = '0001'
              batch            = 'B-RECEIPT'
              expiration_date  = '20261231'
              receipt_date     = '20261018'
              base_quantity    = '1.000' ) )
          iv_as_of_date               = '20261013' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_reservation_read_calls ).
  ENDMETHOD.

  METHOD rejects_receipt_expiry.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_fefo(
          it_demands                  = VALUE #(
            ( request_id         = 'REQ-ONE'
              wbs_element        = 'PRJ-100-001'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              unit               = 'EA' )
            ( request_id         = 'REQ-TWO'
              wbs_element        = 'PRJ-OTHER'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          it_projected_batch_receipts = VALUE #(
            ( wbs_element      = 'PRJ-100-001'
              material         = 'MAT-1'
              plant            = '1000'
              storage_location = '0001'
              batch            = 'B-SAME'
              expiration_date  = '20261231'
              receipt_date     = '20261018'
              base_quantity    = '1.000' )
            ( wbs_element      = 'PRJ-OTHER'
              material         = 'MAT-1'
              plant            = '1000'
              storage_location = '0001'
              batch            = 'B-SAME'
              expiration_date  = '20261230'
              receipt_date     = '20261018'
              base_quantity    = '1.000' ) )
          iv_as_of_date               = '20261013' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
  ENDMETHOD.

  METHOD forwards_fefo_receipt_adapters.
    DATA(lt_receipts) = VALUE zcl_project_stock_service=>ty_projected_batch_receipts(
        ( wbs_element      = 'PRJ-100-001'
          material         = 'MAT-1'
          plant            = '1000'
          storage_location = '0001'
          batch            = 'B-RECEIPT'
          expiration_date  = '20261231'
          receipt_date     = '20261018'
          base_quantity    = '4.000' ) ).
    DATA(lt_priority_demands) = VALUE zcl_project_stock_service=>ty_priority_fefo_demands(
        ( request_id         = 'REQ-PRIORITY'
          priority           = 1
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '4.000'
          unit               = 'EA'
          fefo_as_of_date    = '20261020' ) ).
    DATA(lt_dated_demands) = VALUE zcl_project_stock_service=>ty_dated_fefo_demands(
        ( request_id         = 'REQ-DATED'
          required_date      = '20261020'
          priority           = 1
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '4.000'
          unit               = 'EA' ) ).
    DATA(lt_base_demands) = VALUE zcl_project_stock_service=>ty_demands(
      ( request_id         = 'REQ-ATP'
        wbs_element        = 'PRJ-100-001'
        material           = 'MAT-1'
        plant              = '1000'
        requested_quantity = '4.000'
        unit               = 'EA'
        fefo_as_of_date    = '20261020' ) ).
    DATA(lt_transfer_demands) = VALUE zcl_project_stock_service=>ty_transfer_demands(
        ( request_id              = 'REQ-XFER'
          source_wbs_element      = 'PRJ-100-001'
          destination_wbs_element = 'PRJ-200-001'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '4.000'
          unit                    = 'EA'
          fefo_as_of_date         = '20261020' ) ).
    DATA(lt_priority_transfer_demands) = VALUE zcl_project_stock_service=>ty_priority_transfer_fefo_demands(
        ( request_id              = 'REQ-XFER-PRIORITY'
          priority                = 1
          source_wbs_element      = 'PRJ-100-001'
          destination_wbs_element = 'PRJ-200-001'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '4.000'
          unit                    = 'EA'
          fefo_as_of_date         = '20261020' ) ).
    DATA(lt_dated_transfer_demands) = VALUE zcl_project_stock_service=>ty_dated_transfer_demands(
        ( request_id              = 'REQ-XFER-DATE'
          required_date           = '20261020'
          priority                = 1
          source_wbs_element      = 'PRJ-100-001'
          destination_wbs_element = 'PRJ-200-001'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '4.000'
          unit                    = 'EA' ) ).

    DATA(ls_priority_result) = mo_cut->preview_fefo_priority(
      it_demands                  = lt_priority_demands
      it_projected_batch_receipts = lt_receipts
      iv_as_of_date               = '20261013' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_priority_result-allocations[
        1 ]-allocation-allocation-allocated_quantity ).

    DATA(ls_dated_result) = mo_cut->preview_fefo_by_date(
      it_demands                  = lt_dated_demands
      it_projected_batch_receipts = lt_receipts
      iv_as_of_date               = '20261013' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_dated_result-allocations[
        1 ]-allocation-allocation-allocated_quantity ).

    DATA(ls_atp_result) = mo_cut->preview_fefo_atp(
      it_demands                  = lt_base_demands
      iv_check_rule               = 'A'
      it_projected_batch_receipts = lt_receipts
      iv_as_of_date               = '20261013' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_atp_result-local_estimate-allocation-allocations[
        1 ]-allocation-allocated_quantity ).

    DATA(ls_priority_atp_result) = mo_cut->preview_fefo_priority_atp(
      it_demands                  = lt_priority_demands
      iv_check_rule               = 'A'
      it_projected_batch_receipts = lt_receipts
      iv_as_of_date               = '20261013' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_priority_atp_result-local_estimate-allocations[
        1 ]-allocation-allocation-allocated_quantity ).

    DATA(ls_dated_atp_result) = mo_cut->preview_fefo_by_date_atp(
      it_demands                  = lt_dated_demands
      iv_check_rule               = 'A'
      it_projected_batch_receipts = lt_receipts
      iv_as_of_date               = '20261013' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_dated_atp_result-local_estimate-allocations[
        1 ]-allocation-allocation-allocated_quantity ).

    DATA(ls_transfer_result) = mo_cut->preview_transfer_fefo(
      it_demands                  = lt_transfer_demands
      it_projected_batch_receipts = lt_receipts
      iv_as_of_date               = '20261013' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_transfer_result-allocation-allocations[
        1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261018'
      act = ls_transfer_result-allocation-batch_allocations[
        1 ]-available_from_date ).

    DATA(ls_transfer_atp_result) = mo_cut->preview_transfer_fefo_atp(
      it_demands                  = lt_transfer_demands
      iv_check_rule               = 'A'
      it_projected_batch_receipts = lt_receipts
      iv_as_of_date               = '20261013' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_transfer_atp_result-local_estimate-allocation-allocations[
        1 ]-allocation-allocated_quantity ).

    DATA(ls_priority_transfer_result) =
      mo_cut->preview_transfer_fefo_priority(
        it_demands                  = lt_priority_transfer_demands
        it_projected_batch_receipts = lt_receipts
        iv_as_of_date               = '20261013' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_priority_transfer_result-allocations[
        1 ]-allocation-allocation-allocated_quantity ).

    DATA(ls_prio_xfer_atp) =
      mo_cut->preview_transfer_fefo_prio_atp(
        it_demands                  = lt_priority_transfer_demands
        iv_check_rule               = 'A'
        it_projected_batch_receipts = lt_receipts
        iv_as_of_date               = '20261013' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_prio_xfer_atp-local_estimate-allocations[
        1 ]-allocation-allocation-allocated_quantity ).

    DATA(ls_dated_transfer_result) =
      mo_cut->preview_transfer_fefo_by_date(
        it_demands                  = lt_dated_transfer_demands
        it_projected_batch_receipts = lt_receipts
        iv_as_of_date               = '20261013' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_dated_transfer_result-allocations[
        1 ]-allocation-allocation-allocated_quantity ).

    DATA(ls_dated_transfer_atp_result) =
      mo_cut->preview_transfer_fefo_date_atp(
        it_demands                  = lt_dated_transfer_demands
        iv_check_rule               = 'A'
        it_projected_batch_receipts = lt_receipts
        iv_as_of_date               = '20261013' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_dated_transfer_atp_result-local_estimate-allocations[
        1 ]-allocation-allocation-allocated_quantity ).
  ENDMETHOD.

  METHOD allocates_dated_location_prio.
    DATA lv_early_date TYPE d.
    DATA lv_late_date TYPE d.
    lv_early_date = sy-datum + 4.
    lv_late_date = sy-datum + 8.

    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0002'
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0003'
        unrestricted_quantity = '1.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_by_location_date(
      it_demands = VALUE #(
        ( request_id              = 'LOC-LATE'
          required_date           = lv_late_date
          priority                = 99
          wbs_element             = 'PRJ-100-001'
          material                = 'MAT-1'
          plant                   = '1000'
          storage_location        = '0002'
          allow_location_fallback = abap_true
          requested_quantity      = '1.000'
          unit                    = 'EA' )
        ( request_id         = 'LOC-EARLY-LOW'
          required_date      = lv_early_date
          priority           = 1
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'LOC-EARLY-HIGH'
          required_date      = lv_early_date
          priority           = 5
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'LOC-LATE'
      act = ls_result-allocations[
        1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = ls_result-storage_allocations[
        1 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-storage_allocations[
        2 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-storage_allocations[
        3 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_early_date
      act = ls_result-storage_allocations[
        3 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = ls_result-storage_allocations[ 3 ]-priority ).
  ENDMETHOD.

  METHOD repeats_id_location_date.
    DATA lv_early_date TYPE d.
    DATA lv_late_date TYPE d.

    lv_early_date = sy-datum + 4.
    lv_late_date = sy-datum + 8.

    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0002'
        unrestricted_quantity = '1.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_by_location_date(
      it_demands                   = VALUE #(
        ( request_id         = 'SHARED'
          required_date      = lv_late_date
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'SHARED'
          required_date      = lv_early_date
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' ) )
      it_storage_location_priority = VALUE #(
        ( '0002' )
        ( '0001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'SHARED'
      act = ls_result-allocations[
        1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SHARED'
      act = ls_result-allocations[
        2 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_late_date
      act = ls_result-allocations[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-storage_allocations[
        1 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-storage_allocations[
        2 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_late_date
      act = ls_result-storage_allocations[
        1 ]-required_date ).
  ENDMETHOD.

  METHOD ranks_dated_wbs_loc.
    DATA lv_required_date TYPE d.
    DATA lv_raised TYPE abap_bool.

    lv_required_date = sy-datum + 6.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        unrestricted_quantity = '3.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0002'
        unrestricted_quantity = '5.000' ) ) ).

    TRY.
        mo_cut->preview_by_location_date(
          it_demands                     = VALUE #(
            ( request_id         = 'LOC-RANK-VALID'
              required_date      = lv_required_date
              wbs_element        = 'PRJ-100-001'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          it_request_location_priorities = VALUE #(
            ( request_id       = 'LOC-RANK-UNKNOWN'
              storage_location = '0002'
              priority_rank    = 1 ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).

    DATA(lt_location_priorities) =
      VALUE zcl_stock_service=>ty_request_location_priorities(
        ( request_id       = 'LOC-RANK-DUP'
          storage_location = '0002'
          priority_rank    = 1 ) ).
    DATA(ls_result) = mo_cut->preview_by_location_date(
      it_demands                     = VALUE #(
        ( request_id         = 'LOC-RANK-DUP'
          required_date      = lv_required_date
          priority           = 10
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '4.000'
          unit               = 'EA' )
        ( request_id         = 'LOC-RANK-DUP'
          required_date      = lv_required_date
          priority           = 5
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '4.000'
          unit               = 'EA' ) )
      it_request_location_priorities = lt_location_priorities ).
    DATA(ls_first_split) =
      ls_result-storage_allocations[ 1 ]-split-storage_allocation.
    DATA(ls_second_split) =
      ls_result-storage_allocations[ 2 ]-split-storage_allocation.
    DATA(ls_third_split) =
      ls_result-storage_allocations[ 3 ]-split-storage_allocation.

    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_first_split-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_second_split-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '1.000' )
      act = ls_second_split-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_third_split-storage_location ).
  ENDMETHOD.

  METHOD rejects_bad_dated_location.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_by_location_date(
          it_demands = VALUE #(
            ( request_id         = 'LOC-BAD-DATE'
              required_date      = '20260230'
              wbs_element        = 'PRJ-100-001'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).

  ENDMETHOD.

  METHOD allocates_unbatched_stock.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        unrestricted_quantity = '12.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0002'
        unrestricted_quantity = '18.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0002'
        batch                 = 'B-MANAGED'
        unrestricted_quantity = '50.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        batch                 = 'B-UNLOCATED'
        unrestricted_quantity = '100.000' ) ) ).
    mo_repository->set_reservations( it_reservations = VALUE #(
      ( material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        required_quantity  = '1.000'
        withdrawn_quantity = '0.000' )
      ( material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        storage_location   = '0002'
        batch              = 'B-MANAGED'
        required_quantity  = '10.000'
        withdrawn_quantity = '0.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_by_location(
      it_demands                   = VALUE #(
        ( request_id         = 'P-UNBATCHED'
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '2.000'
          unit               = 'BOX' ) )
      it_storage_location_priority = VALUE #(
        ( '0002' )
        ( '0001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '24.000' )
      act = ls_result-allocation-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '29.000' )
      act = ls_result-allocation-allocations[ 1 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocation-storage_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-allocation-storage_allocations[ 1 ]-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-allocation-storage_allocations[ 2 ]-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '18.000' )
      act = ls_result-allocation-storage_allocations[ 1 ]-storage_allocation-allocated_quantity ).
  ENDMETHOD.

  METHOD allocates_projected_location.
    DATA(ls_result) = mo_cut->preview_by_location(
      it_demands                     = VALUE #(
        ( request_id         = 'LOC-EARLY'
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '4.000'
          unit               = 'EA' )
        ( request_id          = 'LOC-LATER'
          wbs_element         = 'PRJ-100-001'
          material            = 'MAT-1'
          plant               = '1000'
          requested_quantity  = '4.000'
          unit                = 'EA'
          location_as_of_date = '20261020' )
        ( request_id          = 'LOC-OTHER-WBS'
          wbs_element         = 'PRJ-OTHER'
          material            = 'MAT-1'
          plant               = '1000'
          requested_quantity  = '4.000'
          unit                = 'EA'
          location_as_of_date = '20261020' ) )
      it_projected_location_receipts = VALUE #(
        ( wbs_element      = 'PRJ-100-001'
          material         = 'MAT-1'
          plant            = '1000'
          storage_location = '0001'
          receipt_date     = '20261018'
          base_quantity    = '4.000' ) )
      iv_as_of_date                  = '20261013' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-allocation-allocations[
        1 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-allocation-allocations[
        1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-allocation-allocations[
        2 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-allocation-allocations[
        2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-allocation-allocations[
        3 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261018'
      act = ls_result-allocation-storage_allocations[
        1 ]-available_from_date ).
  ENDMETHOD.

  METHOD forwards_location_receipts.
    DATA(lt_receipts) = VALUE zcl_project_stock_service=>ty_projected_location_receipts(
      ( wbs_element      = 'PRJ-100-001'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        receipt_date     = '20261018'
        base_quantity    = '4.000' ) ).
    DATA(lt_priority_demands) = VALUE zcl_project_stock_service=>ty_priority_location_demands(
      ( request_id          = 'LOC-PRIORITY'
        priority            = 1
        wbs_element         = 'PRJ-100-001'
        material            = 'MAT-1'
        plant               = '1000'
        requested_quantity  = '4.000'
        unit                = 'EA'
        location_as_of_date = '20261020' ) ).
    DATA(lt_dated_demands) = VALUE zcl_project_stock_service=>ty_dated_location_demands(
      ( request_id         = 'LOC-DATE'
        required_date      = '20261020'
        priority           = 1
        wbs_element        = 'PRJ-100-001'
        material           = 'MAT-1'
        plant              = '1000'
        requested_quantity = '4.000'
        unit               = 'EA' ) ).
    DATA(lt_base_demands) = VALUE zcl_project_stock_service=>ty_demands(
      ( request_id          = 'LOC-ATP'
        wbs_element         = 'PRJ-100-001'
        material            = 'MAT-1'
        plant               = '1000'
        requested_quantity  = '4.000'
        unit                = 'EA'
        location_as_of_date = '20261020' ) ).
    DATA(lt_transfer_demands) = VALUE zcl_project_stock_service=>ty_transfer_demands(
      ( request_id              = 'LOC-TRANSFER'
        source_wbs_element      = 'PRJ-100-001'
        destination_wbs_element = 'PRJ-100-002'
        material                = 'MAT-1'
        plant                   = '1000'
        requested_quantity      = '4.000'
        unit                    = 'EA'
        location_as_of_date     = '20261020' ) ).
    DATA(lt_priority_transfer_demands) = VALUE zcl_project_stock_service=>ty_priority_location_transfer_demands(
      ( request_id              = 'LOC-TRANSFER-PRIORITY'
        priority                = 1
        source_wbs_element      = 'PRJ-100-001'
        destination_wbs_element = 'PRJ-100-002'
        material                = 'MAT-1'
        plant                   = '1000'
        requested_quantity      = '4.000'
        unit                    = 'EA'
        location_as_of_date     = '20261020' ) ).
    DATA(lt_dated_transfer_demands) = VALUE zcl_project_stock_service=>ty_dated_location_transfer_demands(
      ( request_id              = 'LOC-TRANSFER-DATE'
        required_date           = '20261020'
        priority                = 1
        source_wbs_element      = 'PRJ-100-001'
        destination_wbs_element = 'PRJ-100-002'
        material                = 'MAT-1'
        plant                   = '1000'
        requested_quantity      = '4.000'
        unit                    = 'EA' ) ).

    DATA(ls_priority_result) = mo_cut->preview_by_location_priority(
      it_demands                     = lt_priority_demands
      it_projected_location_receipts = lt_receipts
      iv_as_of_date                  = '20261013' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_priority_result-allocations[
        1 ]-allocation-allocation-allocated_quantity ).

    DATA(ls_dated_result) = mo_cut->preview_by_location_date(
      it_demands                     = lt_dated_demands
      it_projected_location_receipts = lt_receipts
      iv_as_of_date                  = '20261013' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_dated_result-allocations[
        1 ]-allocation-allocation-allocated_quantity ).

    DATA(ls_atp_result) = mo_cut->preview_by_location_atp(
      it_demands                     = lt_base_demands
      iv_check_rule                  = 'A'
      it_projected_location_receipts = lt_receipts
      iv_as_of_date                  = '20261013' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_atp_result-local_estimate-allocation-allocations[
        1 ]-allocation-allocated_quantity ).

    DATA(ls_priority_atp_result) = mo_cut->preview_location_priority_atp(
      it_demands                     = lt_priority_demands
      iv_check_rule                  = 'A'
      it_projected_location_receipts = lt_receipts
      iv_as_of_date                  = '20261013' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_priority_atp_result-local_estimate-allocations[
        1 ]-allocation-allocation-allocated_quantity ).

    DATA(ls_dated_atp_result) = mo_cut->preview_by_location_date_atp(
      it_demands                     = lt_dated_demands
      iv_check_rule                  = 'A'
      it_projected_location_receipts = lt_receipts
      iv_as_of_date                  = '20261013' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_dated_atp_result-local_estimate-allocations[
        1 ]-allocation-allocation-allocated_quantity ).

    DATA(ls_transfer_result) = mo_cut->preview_transfer_by_location(
      it_demands                     = lt_transfer_demands
      it_projected_location_receipts = lt_receipts
      iv_as_of_date                  = '20261013' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_transfer_result-allocation-allocations[
        1 ]-allocation-allocated_quantity ).

    DATA(ls_transfer_priority_result) = mo_cut->preview_transfer_loc_priority(
      it_demands                     = lt_priority_transfer_demands
      it_projected_location_receipts = lt_receipts
      iv_as_of_date                  = '20261013' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_transfer_priority_result-allocations[
        1 ]-allocation-allocation-allocated_quantity ).

    DATA(ls_transfer_date_result) = mo_cut->preview_transfer_location_date(
      it_demands                     = lt_dated_transfer_demands
      it_projected_location_receipts = lt_receipts
      iv_as_of_date                  = '20261013' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_transfer_date_result-allocations[
        1 ]-allocation-allocation-allocated_quantity ).

    DATA(ls_transfer_atp_result) = mo_cut->preview_transfer_loc_atp(
      it_demands                     = lt_transfer_demands
      iv_check_rule                  = 'A'
      it_projected_location_receipts = lt_receipts
      iv_as_of_date                  = '20261013' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_transfer_atp_result-local_estimate-allocation-allocations[
        1 ]-allocation-allocated_quantity ).

    DATA(ls_xfer_prio_atp) = mo_cut->preview_transfer_loc_prio_atp(
      it_demands                     = lt_priority_transfer_demands
      iv_check_rule                  = 'A'
      it_projected_location_receipts = lt_receipts
      iv_as_of_date                  = '20261013' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_xfer_prio_atp-local_estimate-allocations[
        1 ]-allocation-allocation-allocated_quantity ).

    DATA(ls_transfer_date_atp_result) = mo_cut->preview_transfer_loc_date_atp(
      it_demands                     = lt_dated_transfer_demands
      iv_check_rule                  = 'A'
      it_projected_location_receipts = lt_receipts
      iv_as_of_date                  = '20261013' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_transfer_date_atp_result-local_estimate-allocations[
        1 ]-allocation-allocation-allocated_quantity ).
  ENDMETHOD.

  METHOD rejects_unmatched_loc_receipt.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_by_location(
          it_demands                     = VALUE #(
            ( request_id         = 'LOC-ONE'
              wbs_element        = 'PRJ-100-001'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          it_projected_location_receipts = VALUE #(
            ( wbs_element      = 'PRJ-OTHER'
              material         = 'MAT-1'
              plant            = '1000'
              storage_location = '0001'
              receipt_date     = '20261018'
              base_quantity    = '1.000' ) )
          iv_as_of_date                  = '20261013' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_reservation_read_calls ).
  ENDMETHOD.

  METHOD rejects_loc_receipt_overflow.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_by_location(
          it_demands                     = VALUE #(
            ( request_id         = 'LOC-OVERFLOW'
              wbs_element        = 'PRJ-100-001'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              unit               = 'EA' ) )
          it_projected_location_receipts = VALUE #(
            ( wbs_element      = 'PRJ-100-001'
              material         = 'MAT-1'
              plant            = '1000'
              storage_location = '0001'
              receipt_date     = '20261018'
              base_quantity    = '6000000000.000' )
            ( wbs_element      = 'PRJ-100-001'
              material         = 'MAT-1'
              plant            = '1000'
              storage_location = '0001'
              receipt_date     = '20261018'
              base_quantity    = '6000000000.000' ) )
          iv_as_of_date                  = '20261020' ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
  ENDMETHOD.

  METHOD filters_reservations_by_date.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-1'
        expiration_date       = '20270101'
        unrestricted_quantity = '10.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-2'
        expiration_date       = '20280101'
        unrestricted_quantity = '10.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0002'
        unrestricted_quantity = '10.000' ) ) ).
    mo_repository->set_reservations( it_reservations = VALUE #(
      ( material          = 'MAT-1'
        plant             = '1000'
        wbs_element       = 'PRJ-100-001'
        storage_location  = '0001'
        batch             = 'B-1'
        required_date     = '20261130'
        required_quantity = '2.000' )
      ( material          = 'MAT-1'
        plant             = '1000'
        wbs_element       = 'PRJ-100-001'
        storage_location  = '0001'
        batch             = 'B-1'
        required_date     = '20261231'
        required_quantity = '6.000' )
      ( material          = 'MAT-1'
        plant             = '1000'
        wbs_element       = 'PRJ-100-001'
        storage_location  = '0002'
        required_date     = '20261130'
        required_quantity = '1.000' )
      ( material          = 'MAT-1'
        plant             = '1000'
        wbs_element       = 'PRJ-100-001'
        storage_location  = '0002'
        required_date     = '20261231'
        required_quantity = '4.000' ) ) ).

    DATA(ls_fefo) = mo_cut->preview_fefo(
      it_demands                  = VALUE #(
        ( request_id         = 'P-FEFO-DATE'
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '8.000'
          unit               = 'EA' ) )
      iv_reservation_through_date = '20261201' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '17.000' )
      act = ls_fefo-allocation-allocations[ 1 ]-allocation-available_quantity ).

    DATA(ls_fefo_all_dates) = mo_cut->preview_fefo(
      it_demands = VALUE #(
        ( request_id         = 'P-FEFO-ALL'
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '8.000'
          unit               = 'EA' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = ls_fefo_all_dates-allocation-allocations[ 1 ]-allocation-available_quantity ).

    DATA(ls_location) = mo_cut->preview_by_location(
      it_demands                  = VALUE #(
        ( request_id         = 'P-LOCATION-DATE'
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '8.000'
          unit               = 'EA' ) )
      iv_reservation_through_date = '20261201' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '9.000' )
      act = ls_location-allocation-allocations[ 1 ]-allocation-available_quantity ).

    DATA(ls_location_all_dates) = mo_cut->preview_by_location(
      it_demands = VALUE #(
        ( request_id         = 'P-LOCATION-ALL'
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '8.000'
          unit               = 'EA' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_location_all_dates-allocation-allocations[ 1 ]-allocation-available_quantity ).
  ENDMETHOD.

  METHOD forwards_cutoff_to_transfer.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0001'
        batch                 = 'B-1'
        expiration_date       = '20270101'
        unrestricted_quantity = '10.000' ) ) ).
    mo_repository->set_reservations( it_reservations = VALUE #(
      ( material          = 'MAT-1'
        plant             = '1000'
        wbs_element       = 'PRJ-SOURCE-001'
        storage_location  = '0001'
        batch             = 'B-1'
        required_date     = '20261231'
        required_quantity = '6.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_transfer_fefo(
      it_demands                  = VALUE #(
        ( request_id              = 'P-TRANSFER-DATE'
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-001'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '10.000'
          unit                    = 'EA' ) )
      iv_reservation_through_date = '20261201' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_result-allocation-allocations[ 1 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_result-allocation-allocations[ 1 ]-allocation-allocated_quantity ).
  ENDMETHOD.

  METHOD previews_wbs_location_xfer.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0001'
        unrestricted_quantity = '2.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0002'
        unrestricted_quantity = '4.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0002'
        batch                 = 'B-MANAGED'
        unrestricted_quantity = '50.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-OTHER-001'
        storage_location      = '0001'
        unrestricted_quantity = '100.000' ) ) ).
    mo_repository->set_reservations( it_reservations = VALUE #(
      ( material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-SOURCE-001'
        storage_location   = '0002'
        required_quantity  = '2.000'
        withdrawn_quantity = '1.000' )
      ( material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-OTHER-001'
        storage_location   = '0001'
        required_quantity  = '100.000'
        withdrawn_quantity = '0.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_transfer_by_location(
      it_demands                   = VALUE #(
        ( request_id              = 'P-TRANSFER'
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-002'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '5.000'
          unit                    = 'EA' ) )
      it_storage_location_priority = VALUE #(
        ( '0002' )
        ( '0001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-transfer_assignments ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-SOURCE-001'
      act = ls_result-transfer_assignments[ 1 ]-source_wbs_element ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-TARGET-002'
      act = ls_result-transfer_assignments[ 1 ]-destination_wbs_element ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-allocation-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_result-allocation-allocations[ 1 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocation-storage_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-allocation-storage_allocations[ 1 ]-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-allocation-storage_allocations[ 1 ]-storage_allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-allocation-storage_allocations[ 2 ]-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-allocation-storage_allocations[ 2 ]-storage_allocation-allocated_quantity ).
  ENDMETHOD.

  METHOD prioritizes_wbs_loc_transfer.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0001'
        unrestricted_quantity = '10.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0002'
        unrestricted_quantity = '10.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_transfer_loc_priority(
      it_demands                   = VALUE #(
        ( request_id              = 'SHARED'
          priority                = 1
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-001'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '5.000'
          unit                    = 'EA' )
        ( request_id              = 'SHARED'
          priority                = 10
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-002'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '10.000'
          unit                    = 'EA' )
        ( request_id              = 'SHARED'
          priority                = 10
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-003'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '10.000'
          unit                    = 'EA' ) )
      it_storage_location_priority = VALUE #( ( '0002' ) ( '0001' ) ) ).
    DATA(ls_low_allocation) = ls_result-allocations[ 1 ].
    DATA(ls_first_high_allocation) = ls_result-allocations[ 2 ].
    DATA(ls_second_high_allocation) = ls_result-allocations[ 3 ].
    DATA(ls_low_summary) = ls_low_allocation-allocation.
    DATA(ls_first_high_summary) = ls_first_high_allocation-allocation.
    DATA(ls_second_high_summary) = ls_second_high_allocation-allocation.
    DATA(ls_first_location_split) = ls_result-storage_allocations[ 1 ].
    DATA(ls_second_location_split) = ls_result-storage_allocations[ 2 ].

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_low_summary-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_low_summary-allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_first_high_summary-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_second_high_summary-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_first_location_split-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_second_location_split-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-TARGET-001'
      act = ls_result-transfer_assignments[
        1 ]-destination_wbs_element ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_result-transfer_assignments[ 3 ]-priority ).
  ENDMETHOD.

  METHOD previews_dated_loc_xfer.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0001'
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0002'
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0003'
        unrestricted_quantity = '1.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_transfer_location_date(
      it_demands                   = VALUE #(
        ( request_id              = 'LOC-LATE'
          required_date           = '20261205'
          priority                = 99
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-001'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '1.000'
          unit                    = 'EA' )
        ( request_id              = 'LOC-EARLY-LOW'
          required_date           = '20261201'
          priority                = 1
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-002'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '1.000'
          unit                    = 'EA' )
        ( request_id              = 'LOC-EARLY-HIGH'
          required_date           = '20261201'
          priority                = 5
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-003'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '1.000'
          unit                    = 'EA' ) )
      it_storage_location_priority = VALUE #(
        ( '0003' )
        ( '0002' )
        ( '0001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'LOC-LATE'
      act = ls_result-allocations[
        1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-storage_allocations[
        1 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-storage_allocations[
        2 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = ls_result-storage_allocations[
        3 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = ls_result-storage_allocations[
        3 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-TARGET-001'
      act = ls_result-transfer_assignments[
        1 ]-destination_wbs_element ).
  ENDMETHOD.

  METHOD repeats_id_dated_loc_xfer.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0001'
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0002'
        unrestricted_quantity = '1.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_transfer_location_date(
      it_demands                   = VALUE #(
        ( request_id              = 'SHARED'
          required_date           = '20261205'
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-LATE'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '1.000'
          unit                    = 'EA' )
        ( request_id              = 'SHARED'
          required_date           = '20261201'
          source_wbs_element      = 'PRJ-SOURCE-001'
          destination_wbs_element = 'PRJ-TARGET-EARLY'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '1.000'
          unit                    = 'EA' ) )
      it_storage_location_priority = VALUE #(
        ( '0002' )
        ( '0001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SHARED'
      act = ls_result-allocations[
        1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SHARED'
      act = ls_result-allocations[
        2 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261205'
      act = ls_result-allocations[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-storage_allocations[
        1 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-storage_allocations[
        2 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-TARGET-LATE'
      act = ls_result-transfer_assignments[
        1 ]-destination_wbs_element ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-TARGET-EARLY'
      act = ls_result-transfer_assignments[
        2 ]-destination_wbs_element ).
  ENDMETHOD.
  METHOD rejects_location_overflow.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        unrestricted_quantity = '9999999999.999' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0002'
        unrestricted_quantity = '9999999999.999' ) ) ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->preview_by_location(
          it_demands = VALUE #( (
            request_id         = 'LOCATION-OVERFLOW'
            wbs_element        = 'PRJ-100-001'
            material           = 'MAT-1'
            plant              = '1000'
            requested_quantity = '1.000'
            unit               = 'EA' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
  ENDMETHOD.

  METHOD rejects_fefo_avail_overflow.
    DATA lv_early_expiry TYPE d.
    DATA lv_late_expiry TYPE d.
    DATA lv_rejected TYPE abap_bool.
    lv_early_expiry = sy-datum + 30.
    lv_late_expiry = sy-datum + 31.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-EARLY'
        expiration_date       = lv_early_expiry
        unrestricted_quantity = '9999999999.999' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0002'
        batch                 = 'B-LATE'
        expiration_date       = lv_late_expiry
        unrestricted_quantity = '9999999999.999' ) ) ).

    TRY.
        mo_cut->preview_fefo(
          it_demands    = VALUE #( (
            request_id         = 'FEFO-OVERFLOW'
            wbs_element        = 'PRJ-100-001'
            material           = 'MAT-1'
            plant              = '1000'
            requested_quantity = '1.000'
            unit               = 'EA' ) )
          iv_as_of_date = sy-datum ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
  ENDMETHOD.

  METHOD rejects_fefo_atp_overflow.
    DATA lv_atp_check_date TYPE d.
    DATA lv_expiration_date TYPE d.
    DATA lv_rejected TYPE abap_bool.
    lv_atp_check_date = sy-datum + 5.
    lv_expiration_date = sy-datum + 30.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-WBS-1'
        expiration_date       = lv_expiration_date
        unrestricted_quantity = '9999999999.999' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-002'
        storage_location      = '0001'
        batch                 = 'B-WBS-2'
        expiration_date       = lv_expiration_date
        unrestricted_quantity = '9999999999.999' ) ) ).

    TRY.
        mo_cut->preview_fefo_atp(
          it_demands        = VALUE #(
            ( request_id         = 'FEFO-ATP-1'
              wbs_element        = 'PRJ-100-001'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '9999999999.999'
              unit               = 'EA' )
            ( request_id         = 'FEFO-ATP-2'
              wbs_element        = 'PRJ-100-002'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '9999999999.999'
              unit               = 'EA' ) )
          iv_check_rule     = 'A'
          iv_atp_check_date = lv_atp_check_date
          iv_as_of_date     = sy-datum ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_initial(
      act = mo_availability_api->get_requests( ) ).
  ENDMETHOD.

  METHOD restricts_wbs_fefo_scope.
    DATA lv_expiry_date TYPE d.
    lv_expiry_date = sy-datum + 30.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-1'
        expiration_date       = lv_expiry_date
        unrestricted_quantity = '5.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0002'
        batch                 = 'B-2'
        expiration_date       = lv_expiry_date
        unrestricted_quantity = '5.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0003'
        batch                 = 'B-3'
        expiration_date       = lv_expiry_date
        unrestricted_quantity = '5.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_fefo(
      it_demands                   = VALUE #(
        ( request_id         = 'FEFO-SCOPE-A'
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '3.000'
          unit               = 'EA' )
        ( request_id         = 'FEFO-SCOPE-B'
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '3.000'
          unit               = 'EA' ) )
      it_allowed_storage_locations = VALUE #( ( '0002' ) ( '0003' ) )
      it_request_locations         = VALUE #(
        ( request_id = 'FEFO-SCOPE-A' storage_location = '0001' )
        ( request_id = 'FEFO-SCOPE-A' storage_location = '0002' )
        ( request_id = 'FEFO-SCOPE-B' storage_location = '0001' )
        ( request_id = 'FEFO-SCOPE-B' storage_location = '0003' ) )
      iv_as_of_date                = sy-datum ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocation-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-allocation-batch_allocations[
        1 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = ls_result-allocation-batch_allocations[
        2 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( ls_result-request_locations ) ).
  ENDMETHOD.

  METHOD scopes_wbs_location.
    DATA ls_location_scope_result TYPE
      zcl_project_stock_service=>ty_location_result.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        unrestricted_quantity = '5.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0002'
        unrestricted_quantity = '5.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0003'
        unrestricted_quantity = '5.000' ) ) ).

    ls_location_scope_result = mo_cut->preview_by_location(
      it_demands                   = VALUE #(
        ( request_id         = 'LOC-SCOPE-A'
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '3.000'
          unit               = 'EA' )
        ( request_id         = 'LOC-SCOPE-B'
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '3.000'
          unit               = 'EA' ) )
      it_allowed_storage_locations = VALUE #( ( '0002' ) ( '0003' ) )
      it_request_locations         = VALUE #(
        ( request_id = 'LOC-SCOPE-A' storage_location = '0001' )
        ( request_id = 'LOC-SCOPE-A' storage_location = '0002' )
        ( request_id = 'LOC-SCOPE-B' storage_location = '0001' )
        ( request_id = 'LOC-SCOPE-B' storage_location = '0003' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines(
        ls_location_scope_result-allocation-storage_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_location_scope_result-allocation-storage_allocations[
        1 ]-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = ls_location_scope_result-allocation-storage_allocations[
        2 ]-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( ls_location_scope_result-request_locations ) ).
  ENDMETHOD.


  METHOD previews_scoped_wbs_fefo_atp.
    DATA lv_expiry_date TYPE d.
    lv_expiry_date = sy-datum + 30.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-1'
        expiration_date       = lv_expiry_date
        unrestricted_quantity = '9.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0002'
        batch                 = 'B-2'
        expiration_date       = lv_expiry_date
        unrestricted_quantity = '3.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_fefo_atp(
      it_demands           = VALUE #( (
        request_id         = 'FEFO-ATP-SCOPE'
        wbs_element        = 'PRJ-100-001'
        material           = 'MAT-1'
        plant              = '1000'
        requested_quantity = '3.000'
        unit               = 'EA' ) )
      iv_check_rule        = 'A'
      it_request_locations = VALUE #(
        ( request_id       = 'FEFO-ATP-SCOPE'
          storage_location = '0002' ) )
      iv_as_of_date        = sy-datum ).
    DATA(lt_atp_requests) = mo_availability_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-local_estimate-allocation-batch_allocations[
        1 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_atp_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_atp_requests[ 1 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-local_estimate-request_locations ) ).
  ENDMETHOD.

  METHOD rejects_wbs_location_scopes.
    DATA ls_fefo_result TYPE zcl_project_stock_service=>ty_result.
    DATA ls_location_result TYPE
      zcl_project_stock_service=>ty_location_result.
    DATA lv_rejected TYPE abap_bool.
    DATA(lv_stock_reads_before) = mo_repository->mv_stock_read_calls.

    TRY.
        ls_fefo_result = mo_cut->preview_fefo(
          it_demands           = VALUE #( (
            request_id         = 'SCOPE-KNOWN'
            wbs_element        = 'PRJ-100-001'
            material           = 'MAT-1'
            plant              = '1000'
            requested_quantity = '1.000'
            unit               = 'EA' ) )
          it_request_locations = VALUE #( (
            request_id       = 'SCOPE-UNKNOWN'
            storage_location = '0001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_stock_reads_before
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_initial(
      act = mo_uom_repository->get_read_count( ) ).

    CLEAR lv_rejected.
    TRY.
        ls_location_result = mo_cut->preview_by_location(
          it_demands           = VALUE #( (
            request_id         = 'SCOPE-DUPLICATE'
            wbs_element        = 'PRJ-100-001'
            material           = 'MAT-1'
            plant              = '1000'
            requested_quantity = '1.000'
            unit               = 'EA' ) )
          it_request_locations = VALUE #(
            ( request_id       = 'SCOPE-DUPLICATE'
              storage_location = '0001' )
            ( request_id       = 'SCOPE-DUPLICATE'
              storage_location = '0001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_stock_reads_before
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_initial(
      act = mo_uom_repository->get_read_count( ) ).
  ENDMETHOD.


  METHOD scopes_priority_wbs_fefo.
    DATA lv_expiry_date TYPE d.
    lv_expiry_date = sy-datum + 30.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-OTHER'
        expiration_date       = lv_expiry_date
        unrestricted_quantity = '5.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0002'
        batch                 = 'B-SCOPED'
        expiration_date       = lv_expiry_date
        unrestricted_quantity = '5.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_fefo_priority(
      it_demands           = VALUE #( (
        request_id         = 'PRIO-FEFO-SCOPE'
        wbs_element        = 'PRJ-100-001'
        material           = 'MAT-1'
        plant              = '1000'
        priority           = 3
        requested_quantity = '2.000'
        unit               = 'EA' ) )
      it_request_locations = VALUE #( (
        request_id       = 'PRIO-FEFO-SCOPE'
        storage_location = '0002' ) )
      iv_as_of_date        = sy-datum ).

    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-batch_allocations[
        1 ]-split-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-request_locations ) ).
  ENDMETHOD.

  METHOD scopes_dated_wbs_fefo.
    DATA lv_required_date TYPE d.
    DATA lv_expiry_date TYPE d.
    lv_required_date = sy-datum + 5.
    lv_expiry_date = sy-datum + 30.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-OTHER'
        expiration_date       = lv_expiry_date
        unrestricted_quantity = '5.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0002'
        batch                 = 'B-SCOPED'
        expiration_date       = lv_expiry_date
        unrestricted_quantity = '5.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_fefo_by_date(
      it_demands           = VALUE #( (
        request_id         = 'DATE-FEFO-SCOPE'
        required_date      = lv_required_date
        wbs_element        = 'PRJ-100-001'
        material           = 'MAT-1'
        plant              = '1000'
        requested_quantity = '2.000'
        unit               = 'EA' ) )
      it_request_locations = VALUE #( (
        request_id       = 'DATE-FEFO-SCOPE'
        storage_location = '0002' ) )
      iv_as_of_date        = sy-datum ).

    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-batch_allocations[
        1 ]-split-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-request_locations ) ).
  ENDMETHOD.

  METHOD scopes_priority_wbs_location.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        unrestricted_quantity = '5.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0002'
        unrestricted_quantity = '5.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_by_location_priority(
      it_demands           = VALUE #( (
        request_id         = 'PRIO-LOC-SCOPE'
        wbs_element        = 'PRJ-100-001'
        material           = 'MAT-1'
        plant              = '1000'
        priority           = 3
        requested_quantity = '2.000'
        unit               = 'EA' ) )
      it_request_locations = VALUE #( (
        request_id       = 'PRIO-LOC-SCOPE'
        storage_location = '0002' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-storage_allocations[
        1 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-request_locations ) ).
  ENDMETHOD.

  METHOD scopes_dated_wbs_location.
    DATA lv_required_date TYPE d.
    lv_required_date = sy-datum + 5.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        unrestricted_quantity = '5.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0002'
        unrestricted_quantity = '5.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_by_location_date(
      it_demands           = VALUE #( (
        request_id         = 'DATE-LOC-SCOPE'
        required_date      = lv_required_date
        wbs_element        = 'PRJ-100-001'
        material           = 'MAT-1'
        plant              = '1000'
        requested_quantity = '2.000'
        unit               = 'EA' ) )
      it_request_locations = VALUE #( (
        request_id       = 'DATE-LOC-SCOPE'
        storage_location = '0002' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-storage_allocations[
        1 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-request_locations ) ).
  ENDMETHOD.

  METHOD rejects_advanced_wbs_scopes.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_fefo_priority(
          it_demands           = VALUE #( (
            request_id         = 'KNOWN-SCOPE'
            wbs_element        = 'PRJ-100-001'
            material           = 'MAT-1'
            plant              = '1000'
            priority           = 1
            requested_quantity = '1.000'
            unit               = 'EA' ) )
          it_request_locations = VALUE #( (
            request_id       = 'UNKNOWN-SCOPE'
            storage_location = '0002' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_initial(
      act = mo_uom_repository->get_read_count( ) ).

    CLEAR lv_raised.
    TRY.
        mo_cut->preview_by_location_date(
          it_demands           = VALUE #( (
            request_id         = 'DUP-SCOPE'
            required_date      = sy-datum
            wbs_element        = 'PRJ-100-001'
            material           = 'MAT-1'
            plant              = '1000'
            requested_quantity = '1.000'
            unit               = 'EA' ) )
          it_request_locations = VALUE #(
            ( request_id       = 'DUP-SCOPE'
              storage_location = '0001' )
            ( request_id       = 'DUP-SCOPE'
              storage_location = '0001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_initial(
      act = mo_uom_repository->get_read_count( ) ).
  ENDMETHOD.


  METHOD previews_advanced_scoped_atp.
    DATA lv_required_date TYPE d.
    DATA lv_expiry_date TYPE d.
    lv_required_date = sy-datum + 5.
    lv_expiry_date = sy-datum + 30.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-OTHER'
        expiration_date       = lv_expiry_date
        unrestricted_quantity = '5.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0002'
        batch                 = 'B-SCOPED'
        expiration_date       = lv_expiry_date
        unrestricted_quantity = '5.000' ) ) ).

    DATA(ls_priority_fefo) = mo_cut->preview_fefo_priority_atp(
      it_demands           = VALUE #( (
        request_id         = 'ATP-PRIO-FEFO'
        wbs_element        = 'PRJ-100-001'
        material           = 'MAT-1'
        plant              = '1000'
        priority           = 5
        requested_quantity = '2.000'
        unit               = 'EA' ) )
      iv_check_rule        = 'A'
      it_request_locations = VALUE #( (
        request_id       = 'ATP-PRIO-FEFO'
        storage_location = '0002' ) )
      iv_as_of_date        = sy-datum ).
    DATA(ls_dated_fefo) = mo_cut->preview_fefo_by_date_atp(
      it_demands           = VALUE #( (
        request_id         = 'ATP-DATE-FEFO'
        required_date      = lv_required_date
        wbs_element        = 'PRJ-100-001'
        material           = 'MAT-1'
        plant              = '1000'
        requested_quantity = '2.000'
        unit               = 'EA' ) )
      iv_check_rule        = 'A'
      it_request_locations = VALUE #( (
        request_id       = 'ATP-DATE-FEFO'
        storage_location = '0002' ) )
      iv_as_of_date        = sy-datum ).

    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        unrestricted_quantity = '5.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0002'
        unrestricted_quantity = '5.000' ) ) ).
    DATA(ls_priority_location) = mo_cut->preview_location_priority_atp(
      it_demands           = VALUE #( (
        request_id         = 'ATP-PRIO-LOC'
        wbs_element        = 'PRJ-100-001'
        material           = 'MAT-1'
        plant              = '1000'
        priority           = 5
        requested_quantity = '2.000'
        unit               = 'EA' ) )
      iv_check_rule        = 'A'
      it_request_locations = VALUE #( (
        request_id       = 'ATP-PRIO-LOC'
        storage_location = '0002' ) ) ).
    DATA(ls_dated_location) = mo_cut->preview_by_location_date_atp(
      it_demands           = VALUE #( (
        request_id         = 'ATP-DATE-LOC'
        required_date      = lv_required_date
        wbs_element        = 'PRJ-100-001'
        material           = 'MAT-1'
        plant              = '1000'
        requested_quantity = '2.000'
        unit               = 'EA' ) )
      iv_check_rule        = 'A'
      it_request_locations = VALUE #( (
        request_id       = 'ATP-DATE-LOC'
        storage_location = '0002' ) ) ).

    DATA(lt_atp_requests) = mo_availability_api->get_requests( ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_priority_fefo-local_estimate-batch_allocations[
        1 ]-split-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_dated_fefo-local_estimate-batch_allocations[
        1 ]-split-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_priority_location-local_estimate-storage_allocations[
        1 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_dated_location-local_estimate-storage_allocations[
        1 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_priority_fefo-local_estimate-request_locations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_dated_fefo-local_estimate-request_locations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_priority_location-local_estimate-request_locations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_dated_location-local_estimate-request_locations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_atp_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_atp_requests[ 1 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_atp_requests[ 4 ]-requested_quantity ).
  ENDMETHOD.


  METHOD scopes_xfer_fefo.
    DATA lv_required_date TYPE d.
    DATA lv_expiry_date TYPE d.
    lv_required_date = sy-datum + 5.
    lv_expiry_date = sy-datum + 30.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0001'
        batch                 = 'B-OTHER'
        expiration_date       = lv_expiry_date
        unrestricted_quantity = '5.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0002'
        batch                 = 'B-SCOPED'
        expiration_date       = lv_expiry_date
        unrestricted_quantity = '5.000' ) ) ).

    DATA(ls_base) = mo_cut->preview_transfer_fefo(
      it_demands           = VALUE #( (
        request_id              = 'XFER-FEFO-BASE'
        source_wbs_element      = 'PRJ-SOURCE-001'
        destination_wbs_element = 'PRJ-TARGET-001'
        material                = 'MAT-1'
        plant                   = '1000'
        requested_quantity      = '2.000'
        unit                    = 'EA' ) )
      it_request_locations = VALUE #( (
        request_id       = 'XFER-FEFO-BASE'
        storage_location = '0002' ) )
      iv_as_of_date        = sy-datum ).
    DATA(ls_priority) = mo_cut->preview_transfer_fefo_priority(
      it_demands           = VALUE #( (
        request_id              = 'XFER-FEFO-PRIORITY'
        source_wbs_element      = 'PRJ-SOURCE-001'
        destination_wbs_element = 'PRJ-TARGET-001'
        material                = 'MAT-1'
        plant                   = '1000'
        priority                = 5
        requested_quantity      = '2.000'
        unit                    = 'EA' ) )
      it_request_locations = VALUE #( (
        request_id       = 'XFER-FEFO-PRIORITY'
        storage_location = '0002' ) )
      iv_as_of_date        = sy-datum ).
    DATA(ls_dated) = mo_cut->preview_transfer_fefo_by_date(
      it_demands           = VALUE #( (
        request_id              = 'XFER-FEFO-DATE'
        required_date           = lv_required_date
        source_wbs_element      = 'PRJ-SOURCE-001'
        destination_wbs_element = 'PRJ-TARGET-001'
        material                = 'MAT-1'
        plant                   = '1000'
        requested_quantity      = '2.000'
        unit                    = 'EA' ) )
      it_request_locations = VALUE #( (
        request_id       = 'XFER-FEFO-DATE'
        storage_location = '0002' ) )
      iv_as_of_date        = sy-datum ).
    DATA(ls_base_atp) = mo_cut->preview_transfer_fefo_atp(
      it_demands           = VALUE #( (
        request_id              = 'XFER-FEFO-BASE-ATP'
        source_wbs_element      = 'PRJ-SOURCE-001'
        destination_wbs_element = 'PRJ-TARGET-001'
        material                = 'MAT-1'
        plant                   = '1000'
        requested_quantity      = '2.000'
        unit                    = 'EA' ) )
      iv_check_rule        = 'A'
      it_request_locations = VALUE #( (
        request_id       = 'XFER-FEFO-BASE-ATP'
        storage_location = '0002' ) )
      iv_as_of_date        = sy-datum ).
    DATA(ls_priority_atp) = mo_cut->preview_transfer_fefo_prio_atp(
      it_demands           = VALUE #( (
        request_id              = 'XFER-FEFO-PRIO-ATP'
        source_wbs_element      = 'PRJ-SOURCE-001'
        destination_wbs_element = 'PRJ-TARGET-001'
        material                = 'MAT-1'
        plant                   = '1000'
        priority                = 5
        requested_quantity      = '2.000'
        unit                    = 'EA' ) )
      iv_check_rule        = 'A'
      it_request_locations = VALUE #( (
        request_id       = 'XFER-FEFO-PRIO-ATP'
        storage_location = '0002' ) )
      iv_as_of_date        = sy-datum ).
    DATA(ls_dated_atp) = mo_cut->preview_transfer_fefo_date_atp(
      it_demands           = VALUE #( (
        request_id              = 'XFER-FEFO-DATE-ATP'
        required_date           = lv_required_date
        source_wbs_element      = 'PRJ-SOURCE-001'
        destination_wbs_element = 'PRJ-TARGET-001'
        material                = 'MAT-1'
        plant                   = '1000'
        requested_quantity      = '2.000'
        unit                    = 'EA' ) )
      iv_check_rule        = 'A'
      it_request_locations = VALUE #( (
        request_id       = 'XFER-FEFO-DATE-ATP'
        storage_location = '0002' ) )
      iv_as_of_date        = sy-datum ).

    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_base-allocation-batch_allocations[
        1 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_priority-batch_allocations[
        1 ]-split-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_dated-batch_allocations[
        1 ]-split-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-TARGET-001'
      act = ls_base-transfer_assignments[ 1 ]-destination_wbs_element ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_base-request_locations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_priority-request_locations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_dated-request_locations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_base_atp-local_estimate-allocation-batch_allocations[
        1 ]-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_priority_atp-local_estimate-batch_allocations[
        1 ]-split-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_dated_atp-local_estimate-batch_allocations[
        1 ]-split-batch_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( mo_availability_api->get_requests( ) ) ).
  ENDMETHOD.

  METHOD scopes_xfer_location.
    DATA lv_required_date TYPE d.
    lv_required_date = sy-datum + 5.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0001'
        unrestricted_quantity = '5.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-SOURCE-001'
        storage_location      = '0002'
        unrestricted_quantity = '5.000' ) ) ).

    DATA(ls_base) = mo_cut->preview_transfer_by_location(
      it_demands           = VALUE #( (
        request_id              = 'XFER-LOC-BASE'
        source_wbs_element      = 'PRJ-SOURCE-001'
        destination_wbs_element = 'PRJ-TARGET-001'
        material                = 'MAT-1'
        plant                   = '1000'
        requested_quantity      = '2.000'
        unit                    = 'EA' ) )
      it_request_locations = VALUE #( (
        request_id       = 'XFER-LOC-BASE'
        storage_location = '0002' ) ) ).
    DATA(ls_priority) = mo_cut->preview_transfer_loc_priority(
      it_demands           = VALUE #( (
        request_id              = 'XFER-LOC-PRIORITY'
        source_wbs_element      = 'PRJ-SOURCE-001'
        destination_wbs_element = 'PRJ-TARGET-001'
        material                = 'MAT-1'
        plant                   = '1000'
        priority                = 5
        requested_quantity      = '2.000'
        unit                    = 'EA' ) )
      it_request_locations = VALUE #( (
        request_id       = 'XFER-LOC-PRIORITY'
        storage_location = '0002' ) ) ).
    DATA(ls_dated) = mo_cut->preview_transfer_location_date(
      it_demands           = VALUE #( (
        request_id              = 'XFER-LOC-DATE'
        required_date           = lv_required_date
        source_wbs_element      = 'PRJ-SOURCE-001'
        destination_wbs_element = 'PRJ-TARGET-001'
        material                = 'MAT-1'
        plant                   = '1000'
        requested_quantity      = '2.000'
        unit                    = 'EA' ) )
      it_request_locations = VALUE #( (
        request_id       = 'XFER-LOC-DATE'
        storage_location = '0002' ) ) ).
    DATA(ls_base_atp) = mo_cut->preview_transfer_loc_atp(
      it_demands           = VALUE #( (
        request_id              = 'XFER-LOC-BASE-ATP'
        source_wbs_element      = 'PRJ-SOURCE-001'
        destination_wbs_element = 'PRJ-TARGET-001'
        material                = 'MAT-1'
        plant                   = '1000'
        requested_quantity      = '2.000'
        unit                    = 'EA' ) )
      iv_check_rule        = 'A'
      it_request_locations = VALUE #( (
        request_id       = 'XFER-LOC-BASE-ATP'
        storage_location = '0002' ) ) ).
    DATA(ls_priority_atp) = mo_cut->preview_transfer_loc_prio_atp(
      it_demands           = VALUE #( (
        request_id              = 'XFER-LOC-PRIO-ATP'
        source_wbs_element      = 'PRJ-SOURCE-001'
        destination_wbs_element = 'PRJ-TARGET-001'
        material                = 'MAT-1'
        plant                   = '1000'
        priority                = 5
        requested_quantity      = '2.000'
        unit                    = 'EA' ) )
      iv_check_rule        = 'A'
      it_request_locations = VALUE #( (
        request_id       = 'XFER-LOC-PRIO-ATP'
        storage_location = '0002' ) ) ).
    DATA(ls_dated_atp) = mo_cut->preview_transfer_loc_date_atp(
      it_demands           = VALUE #( (
        request_id              = 'XFER-LOC-DATE-ATP'
        required_date           = lv_required_date
        source_wbs_element      = 'PRJ-SOURCE-001'
        destination_wbs_element = 'PRJ-TARGET-001'
        material                = 'MAT-1'
        plant                   = '1000'
        requested_quantity      = '2.000'
        unit                    = 'EA' ) )
      iv_check_rule        = 'A'
      it_request_locations = VALUE #( (
        request_id       = 'XFER-LOC-DATE-ATP'
        storage_location = '0002' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_base-allocation-storage_allocations[
        1 ]-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_priority-storage_allocations[
        1 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_dated-storage_allocations[
        1 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-TARGET-001'
      act = ls_base-transfer_assignments[ 1 ]-destination_wbs_element ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_base-request_locations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_priority-request_locations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_dated-request_locations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_base_atp-local_estimate-allocation-storage_allocations[
        1 ]-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_priority_atp-local_estimate-storage_allocations[
        1 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_dated_atp-local_estimate-storage_allocations[
        1 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( mo_availability_api->get_requests( ) ) ).
  ENDMETHOD.

  METHOD rejects_xfer_scope.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->preview_transfer_fefo_priority(
          it_demands           = VALUE #( (
            request_id              = 'XFER-KNOWN'
            source_wbs_element      = 'PRJ-SOURCE-001'
            destination_wbs_element = 'PRJ-TARGET-001'
            material                = 'MAT-1'
            plant                   = '1000'
            priority                = 1
            requested_quantity      = '1.000'
            unit                    = 'EA' ) )
          it_request_locations = VALUE #( (
            request_id       = 'XFER-UNKNOWN'
            storage_location = '0002' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_initial(
      act = mo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD preserves_fefo_row_full_rule.
    mo_repository->set_stocks( it_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-100-001'
        storage_location      = '0001'
        batch                 = 'B-AVAILABLE'
        expiration_date       = '20261231'
        unrestricted_quantity = '2.000' ) ) ).

    DATA(ls_priority_result) = mo_cut->preview_fefo_priority(
      it_demands               = VALUE #(
        ( request_id         = 'PARTIAL-ROW'
          priority           = 1
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '2.000'
          unit               = 'EA' )
        ( request_id            = 'STRICT-ROW'
          priority              = 10
          wbs_element           = 'PRJ-100-001'
          material              = 'MAT-1'
          plant                 = '1000'
          requested_quantity    = '3.000'
          require_full_quantity = abap_true
          unit                  = 'EA' ) )
      iv_as_of_date            = '20261014'
      iv_require_full_quantity = abap_false ).
    DATA(ls_priority_partial) =
      ls_priority_result-allocations[ 1 ]-allocation-allocation.
    DATA(ls_priority_strict) =
      ls_priority_result-allocations[ 2 ]-allocation-allocation.

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_priority_partial-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_priority_partial-require_full_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_priority_strict-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_priority_strict-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_priority_strict-require_full_quantity ).

    DATA(ls_dated_result) = mo_cut->preview_fefo_by_date(
      it_demands               = VALUE #(
        ( request_id         = 'DATED-PARTIAL'
          required_date      = '20261102'
          priority           = 1
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '2.000'
          unit               = 'EA' )
        ( request_id            = 'DATED-STRICT'
          required_date         = '20261101'
          priority              = 10
          wbs_element           = 'PRJ-100-001'
          material              = 'MAT-1'
          plant                 = '1000'
          requested_quantity    = '3.000'
          require_full_quantity = abap_true
          unit                  = 'EA' ) )
      iv_as_of_date            = '20261014'
      iv_require_full_quantity = abap_false ).
    DATA(ls_dated_partial) =
      ls_dated_result-allocations[ 1 ]-allocation-allocation.
    DATA(ls_dated_strict) =
      ls_dated_result-allocations[ 2 ]-allocation-allocation.

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_dated_partial-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_dated_partial-require_full_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_dated_strict-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_dated_strict-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_dated_strict-require_full_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261102'
      act = ls_dated_result-allocations[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'DATED-STRICT'
      act = ls_dated_result-allocations[ 2 ]-allocation-allocation-request_id ).
  ENDMETHOD.

ENDCLASS.
