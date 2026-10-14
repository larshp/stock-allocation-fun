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

CLASS ltcl_project_stock_service DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO lcl_project_stock_repo_double.
    DATA mo_uom_repository TYPE REF TO lcl_project_uom_repo_double.
    DATA mo_cut TYPE REF TO zcl_project_stock_service.
    METHODS setup.
    METHODS reads_project_available_stock FOR TESTING.
    METHODS reads_available_stock_in_unit FOR TESTING.
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
    METHODS reads_wbs_coverage_uom FOR TESTING.
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
    METHODS allocates_fefo_per_demand_date FOR TESTING.
    METHODS allocates_dated_fefo_priority FOR TESTING.
    METHODS rejects_bad_dated_fefo FOR TESTING.
    METHODS rejects_batch_expiry_conflict FOR TESTING.
    METHODS rejects_invalid_batch_expiry FOR TESTING.
    METHODS rejects_negative_demand_shelf FOR TESTING.
    METHODS filters_reservations_by_date FOR TESTING.
    METHODS forwards_cutoff_to_transfer FOR TESTING.
    METHODS previews_project_wbs_transfer FOR TESTING.
    METHODS allocates_dated_transfer_fefo FOR TESTING.
    METHODS rejects_bad_transfer_fefo_date FOR TESTING.
    METHODS previews_wbs_location_xfer FOR TESTING.
    METHODS previews_dated_loc_xfer FOR TESTING.
    METHODS allocates_unbatched_stock FOR TESTING.
    METHODS allocates_dated_location_prio FOR TESTING.
    METHODS rejects_bad_dated_location FOR TESTING.
    METHODS shares_stock_between_demands FOR TESTING.
ENDCLASS.

CLASS ltcl_project_stock_service IMPLEMENTATION.
  METHOD setup.
    mo_repository = NEW lcl_project_stock_repo_double( ).
    mo_uom_repository = NEW lcl_project_uom_repo_double( ).
    mo_uom_repository->set_material_data( iv_base_unit = 'EA' ).
    mo_uom_repository->set_alt_unit_ratio(
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    mo_cut = NEW zcl_project_stock_service(
      io_repository     = mo_repository
      io_uom_repository = mo_uom_repository ).
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
      exp = CONV mard-labst( '37.000' )
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
        unrestricted_quantity = '1.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_fefo_by_date(
      it_demands = VALUE #(
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
        ( request_id         = 'REQ-EARLY-HIGH'
          required_date      = lv_early_date
          priority           = 5
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' ) ) ).

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
      exp = 'B-3'
      act = ls_result-batch_allocations[
        1 ]-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-2'
      act = ls_result-batch_allocations[
        2 ]-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-batch_allocations[
        3 ]-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_early_date
      act = ls_result-batch_allocations[
        3 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = ls_result-batch_allocations[ 3 ]-priority ).
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

    CLEAR lv_raised.
    TRY.
        mo_cut->preview_fefo_by_date(
          it_demands = VALUE #(
            ( request_id         = 'REQ-DUPLICATE'
              required_date      = '20261020'
              wbs_element        = 'PRJ-100-001'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              unit               = 'EA' )
            ( request_id         = 'REQ-DUPLICATE'
              required_date      = '20261021'
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
        unrestricted_quantity = '1.000' ) ) ).

    DATA(ls_result) = mo_cut->preview_transfer_fefo_by_date(
      it_demands    = VALUE #(
        ( request_id              = 'XFER-LATE'
          required_date           = '20261205'
          priority                = 99
          source_wbs_element      = 'PRJ-100-001'
          destination_wbs_element = 'PRJ-TARGET-001'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '1.000'
          unit                    = 'EA' )
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
          requested_quantity      = '1.000'
          unit                    = 'EA' ) )
      iv_as_of_date = '20261001' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'XFER-LATE'
      act = ls_result-allocations[
        1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-3'
      act = ls_result-batch_allocations[
        1 ]-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-2'
      act = ls_result-batch_allocations[
        2 ]-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-batch_allocations[
        3 ]-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-TARGET-001'
      act = ls_result-transfer_assignments[
        1 ]-destination_wbs_element ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261201'
      act = ls_result-batch_allocations[
        3 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = ls_result-batch_allocations[
        3 ]-priority ).
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
        ( request_id         = 'LOC-LATE'
          required_date      = lv_late_date
          priority           = 99
          wbs_element        = 'PRJ-100-001'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' )
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

    CLEAR lv_raised.
    TRY.
        mo_cut->preview_by_location_date(
          it_demands = VALUE #(
            ( request_id         = 'LOC-DUPLICATE'
              required_date      = '20261020'
              wbs_element        = 'PRJ-100-001'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              unit               = 'EA' )
            ( request_id         = 'LOC-DUPLICATE'
              required_date      = '20261021'
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
ENDCLASS.
