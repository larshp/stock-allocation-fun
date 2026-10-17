CLASS lcl_so_stock_repository DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_so_stock_repository.
    DATA base_units TYPE zif_so_stock_repository=>ty_material_units.
    DATA order_items TYPE zif_so_stock_repository=>ty_order_items.
    DATA stocks TYPE zif_so_stock_repository=>ty_stock_rows.
    DATA reservations TYPE zif_so_stock_repository=>ty_reservation_rows.
    DATA read_count TYPE i.
ENDCLASS.

CLASS lcl_so_stock_uom_repo DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_material_uom_repository.
ENDCLASS.

CLASS ltcl_so_stock_service DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO lcl_so_stock_repository.
    DATA mo_service TYPE REF TO zcl_so_stock_service.
    METHODS setup.
    METHODS set_fefo_stock.
    METHODS nets_open_reservations FOR TESTING.
    METHODS rejects_stock_total_overflow FOR TESTING.
    METHODS nets_reservations_through_date FOR TESTING.
    METHODS rejects_bad_cutoff FOR TESTING.
    METHODS reads_stock_in_unit FOR TESTING.
    METHODS reads_stock_bulk_in_units FOR TESTING.
    METHODS reads_stock_units_at_cutoffs FOR TESTING.
    METHODS rejects_unknown_stock_unit FOR TESTING.
    METHODS previews_issue_demands FOR TESTING.
    METHODS previews_issue_demands_uom FOR TESTING.
    METHODS prioritizes_issue_dates FOR TESTING.
    METHODS prioritizes_issue_priority FOR TESTING.
    METHODS full_qty_aggregate_previews FOR TESTING.
    METHODS previews_duplicate_issue_uom FOR TESTING.
    METHODS rejects_unknown_issue_unit FOR TESTING.
    METHODS rejects_unit_rounds_to_zero FOR TESTING.
    METHODS allocates_duplicate_demands FOR TESTING.
    METHODS allocates_mixed_cutoffs FOR TESTING.
    METHODS empty_issue_preview_no_reads FOR TESTING.
    METHODS keeps_items_separate FOR TESTING.
    METHODS rejects_duplicate_ids FOR TESTING.
    METHODS returns_empty_bulk FOR TESTING.
    METHODS rejects_unrequested_rows FOR TESTING.
    METHODS rejects_duplicate_base_units FOR TESTING.
    METHODS rejects_overdrawn_reservation FOR TESTING.
    METHODS resolves_sales_order_item FOR TESTING.
    METHODS rejects_missing_sales_item FOR TESTING.
    METHODS previews_issue_by_fefo FOR TESTING.
    METHODS previews_issue_by_fefo_uom FOR TESTING.
    METHODS prioritizes_fefo_issue_dates FOR TESTING.
    METHODS prioritizes_fefo_priority FOR TESTING.
    METHODS full_quantity_fefo_requests FOR TESTING.
    METHODS full_qty_fefo_row_policy FOR TESTING.
    METHODS previews_fefo_selected_batch FOR TESTING.
    METHODS filters_fefo_issue_location FOR TESTING.
    METHODS fefo_location_fallback_order FOR TESTING.
    METHODS filters_fefo_allowed_locations FOR TESTING.
    METHODS filters_fefo_req_locations FOR TESTING.
    METHODS previews_fefo_batch_uom FOR TESTING.
    METHODS previews_fefo_min_shelf_life FOR TESTING.
    METHODS previews_fefo_demand_minimum FOR TESTING.
    METHODS fefo_demand_minimum_uom FOR TESTING.
    METHODS filters_fefo_known_expiry FOR TESTING.
    METHODS filters_fefo_known_expiry_uom FOR TESTING.
    METHODS rejects_bad_fefo_expiry FOR TESTING.
    METHODS rejects_bad_fefo_issue_options FOR TESTING.
    METHODS aggregates_dup_fefo_stock FOR TESTING.
ENDCLASS.

CLASS lcl_so_stock_repository IMPLEMENTATION.
  METHOD zif_so_stock_repository~read_base_units_bulk.
    ADD 1 TO read_count.
    rt_units = base_units.
  ENDMETHOD.

  METHOD zif_so_stock_repository~read_order_items_bulk.
    ADD 1 TO read_count.
    rt_items = order_items.
  ENDMETHOD.

  METHOD zif_so_stock_repository~read_stock_bulk.
    ADD 1 TO read_count.
    rt_rows = stocks.
  ENDMETHOD.

  METHOD zif_so_stock_repository~read_reservations_bulk.
    ADD 1 TO read_count.
    rt_rows = reservations.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_so_stock_uom_repo IMPLEMENTATION.
  METHOD zif_material_uom_repository~get_base_unit.
    IF iv_material = 'MAT-1'.
      rv_base_unit = 'EA'.
    ENDIF.
  ENDMETHOD.

  METHOD zif_material_uom_repository~get_alt_unit_ratio.
    IF iv_material = 'MAT-1'.
      CASE iv_alternative_unit.
        WHEN 'BOX'.
          rs_ratio-numerator = 2.
          rs_ratio-denominator = 1.
        WHEN 'ML'.
          rs_ratio-numerator = 1.
          rs_ratio-denominator = 1000.
      ENDCASE.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_so_stock_service IMPLEMENTATION.
  METHOD setup.
    mo_repository = NEW lcl_so_stock_repository( ).
    mo_service = NEW zcl_so_stock_service(
      io_repository = mo_repository ).
  ENDMETHOD.

  METHOD set_fefo_stock.
    mo_repository->order_items = VALUE #(
      ( sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000' ) ).
    mo_repository->base_units = VALUE #(
      ( material = 'MAT-1' base_unit = 'EA' ) ).
    mo_repository->stocks = VALUE #(
      ( sales_document   = '0000001000'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        batch            = 'B-1'
        expiration_date  = '20261020'
        base_unit        = 'EA'
        quantity         = '4.000' )
      ( sales_document   = '0000001000'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0002'
        batch            = 'B-2'
        expiration_date  = '20261101'
        base_unit        = 'EA'
        quantity         = '5.000' )
      ( sales_document   = '0000001000'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0003'
        batch            = 'B-OLD'
        expiration_date  = '20261010'
        base_unit        = 'EA'
        quantity         = '3.000' )
      ( sales_document   = '0000001000'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0004'
        base_unit        = 'EA'
        quantity         = '2.000' ) ).
    mo_repository->reservations = VALUE #(
      ( sales_document     = '0000001000'
        item_number        = '000010'
        material           = 'MAT-1'
        plant              = '1000'
        storage_location   = '0001'
        batch              = 'B-1'
        reservation_number = '0000001240'
        reservation_item   = '0001'
        required_date      = '20261015'
        required_quantity  = '1.000'
        base_unit          = 'EA' )
      ( sales_document     = '0000001000'
        item_number        = '000010'
        material           = 'MAT-1'
        plant              = '1000'
        reservation_number = '0000001241'
        reservation_item   = '0001'
        required_date      = '20261016'
        required_quantity  = '2.000'
        base_unit          = 'EA' )
      ( sales_document     = '0000001000'
        item_number        = '000010'
        material           = 'MAT-1'
        plant              = '1000'
        storage_location   = '0002'
        batch              = 'B-2'
        reservation_number = '0000001242'
        reservation_item   = '0001'
        required_date      = '20261102'
        required_quantity  = '1.000'
        base_unit          = 'EA' ) ).
    mo_service = NEW zcl_so_stock_service(
      io_repository     = mo_repository
      io_uom_repository = NEW lcl_so_stock_uom_repo( ) ).
  ENDMETHOD.

  METHOD reads_stock_in_unit.
    mo_repository->order_items = VALUE #(
      ( sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000' ) ).
    mo_repository->base_units = VALUE #(
      ( material = 'MAT-1' base_unit = 'EA' ) ).
    mo_repository->stocks = VALUE #(
      ( sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000'
        base_unit      = 'EA'
        quantity       = '8.000' ) ).
    mo_repository->reservations = VALUE #(
      ( sales_document     = '0000001000'
        item_number        = '000010'
        material           = 'MAT-1'
        plant              = '1000'
        reservation_number = '0000001240'
        reservation_item   = '0001'
        required_quantity  = '4.000'
        withdrawn_quantity = '1.000'
        base_unit          = 'EA' ) ).
    mo_service = NEW zcl_so_stock_service(
      io_repository     = mo_repository
      io_uom_repository = NEW lcl_so_stock_uom_repo( ) ).

    DATA(ls_result) = mo_service->read_stock_in_unit(
      iv_sales_document = '0000001000'
      iv_item_number    = '000010'
      iv_requested_unit = 'BOX' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = ls_result-requested_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '8.000' )
      act = ls_result-unrestricted_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '4.000' )
      act = ls_result-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '3.000' )
      act = ls_result-reserved_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '1.500' )
      act = ls_result-reserved_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '5.000' )
      act = ls_result-available_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '2.500' )
      act = ls_result-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '5.000' )
      act = ls_result-stock_snapshot-available_quantity ).
  ENDMETHOD.

  METHOD reads_stock_bulk_in_units.
    mo_repository->order_items = VALUE #(
      ( sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000' ) ).
    mo_repository->base_units = VALUE #(
      ( material = 'MAT-1' base_unit = 'EA' ) ).
    mo_repository->stocks = VALUE #(
      ( sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000'
        base_unit      = 'EA'
        quantity       = '8.000' ) ).
    mo_service = NEW zcl_so_stock_service(
      io_repository     = mo_repository
      io_uom_repository = NEW lcl_so_stock_uom_repo( ) ).

    DATA(lt_results) = mo_service->read_stock_bulk_in_unit(
      VALUE #(
        ( request_id     = 'BOX-STOCK'
          sales_document = '0000001000'
          item_number    = '000010'
          requested_unit = 'BOX' )
        ( request_id     = 'EA-STOCK'
          sales_document = '0000001000'
          item_number    = '000010'
          requested_unit = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '4.000' )
      act = lt_results[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '8.000' )
      act = lt_results[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '8.000' )
      act = lt_results[ 2 ]-available_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA-STOCK'
      act = lt_results[ 2 ]-stock_snapshot-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = mo_repository->read_count ).
  ENDMETHOD.

  METHOD reads_stock_units_at_cutoffs.
    mo_repository->order_items = VALUE #(
      ( sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000' ) ).
    mo_repository->base_units = VALUE #(
      ( material = 'MAT-1' base_unit = 'EA' ) ).
    mo_repository->stocks = VALUE #(
      ( sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000'
        base_unit      = 'EA'
        quantity       = '10.000' ) ).
    mo_repository->reservations = VALUE #(
      ( sales_document     = '0000001000'
        item_number        = '000010'
        material           = 'MAT-1'
        plant              = '1000'
        reservation_number = '0000001240'
        reservation_item   = '0001'
        required_date      = '20260401'
        required_quantity  = '3.000'
        base_unit          = 'EA' )
      ( sales_document     = '0000001000'
        item_number        = '000010'
        material           = 'MAT-1'
        plant              = '1000'
        reservation_number = '0000001241'
        reservation_item   = '0001'
        required_date      = '20260402'
        required_quantity  = '2.000'
        base_unit          = 'EA' ) ).
    mo_service = NEW zcl_so_stock_service(
      io_repository     = mo_repository
      io_uom_repository = NEW lcl_so_stock_uom_repo( ) ).

    DATA(lt_results) = mo_service->read_stock_bulk_in_unit(
      VALUE #(
        ( request_id               = 'CUTOFF-APR-01'
          sales_document           = '0000001000'
          item_number              = '000010'
          requested_unit           = 'BOX'
          reservation_through_date = '20260401' )
        ( request_id               = 'CUTOFF-APR-02'
          sales_document           = '0000001000'
          item_number              = '000010'
          requested_unit           = 'BOX'
          reservation_through_date = '20260402' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '7.000' )
      act = lt_results[ 1 ]-available_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '5.000' )
      act = lt_results[ 2 ]-available_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20260401'
      act = lt_results[ 1 ]-stock_snapshot-reservation_through_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20260402'
      act = lt_results[ 2 ]-stock_snapshot-reservation_through_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = mo_repository->read_count ).
  ENDMETHOD.

  METHOD rejects_unknown_stock_unit.
    mo_repository->order_items = VALUE #(
      ( sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000' ) ).
    mo_repository->base_units = VALUE #(
      ( material = 'MAT-1' base_unit = 'EA' ) ).
    mo_service = NEW zcl_so_stock_service(
      io_repository     = mo_repository
      io_uom_repository = NEW lcl_so_stock_uom_repo( ) ).

    TRY.
        mo_service->read_stock_in_unit(
          iv_sales_document = '0000001000'
          iv_item_number    = '000010'
          iv_requested_unit = 'CS' ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_invalid_stock_request.
    ENDTRY.
  ENDMETHOD.

  METHOD previews_issue_demands.
    mo_repository->order_items = VALUE #(
      ( sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000' )
      ( sales_document = '0000001000'
        item_number    = '000020'
        material       = 'MAT-1'
        plant          = '1000' ) ).
    mo_repository->base_units = VALUE #(
      ( material = 'MAT-1' base_unit = 'EA' ) ).
    mo_repository->stocks = VALUE #(
      ( sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000'
        base_unit      = 'EA'
        quantity       = '8.000' )
      ( sales_document = '0000001000'
        item_number    = '000020'
        material       = 'MAT-1'
        plant          = '1000'
        base_unit      = 'EA'
        quantity       = '3.000' ) ).
    mo_repository->reservations = VALUE #(
      ( sales_document     = '0000001000'
        item_number        = '000010'
        material           = 'MAT-1'
        plant              = '1000'
        reservation_number = '0000001240'
        reservation_item   = '0001'
        required_quantity  = '3.000'
        withdrawn_quantity = '1.000'
        base_unit          = 'EA' ) ).

    DATA(lt_results) = mo_service->preview_issue_demands(
      VALUE #(
        ( request_id         = 'ORDER-ITEM-10'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '5.000' )
        ( request_id         = 'ORDER-ITEM-20'
          sales_document     = '0000001000'
          item_number        = '000020'
          requested_quantity = '5.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '6.000' )
      act = lt_results[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '5.000' )
      act = lt_results[ 1 ]-covered_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_results[ 1 ]-is_sufficient ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '3.000' )
      act = lt_results[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '2.000' )
      act = lt_results[ 2 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lt_results[ 2 ]-is_sufficient ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = mo_repository->read_count ).
  ENDMETHOD.

  METHOD previews_issue_demands_uom.
    mo_repository->order_items = VALUE #(
      ( sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000' )
      ( sales_document = '0000001000'
        item_number    = '000020'
        material       = 'MAT-1'
        plant          = '1000' ) ).
    mo_repository->base_units = VALUE #(
      ( material = 'MAT-1' base_unit = 'EA' ) ).
    mo_repository->stocks = VALUE #(
      ( sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000'
        base_unit      = 'EA'
        quantity       = '8.000' )
      ( sales_document = '0000001000'
        item_number    = '000020'
        material       = 'MAT-1'
        plant          = '1000'
        base_unit      = 'EA'
        quantity       = '5.000' ) ).
    mo_repository->reservations = VALUE #(
      ( sales_document     = '0000001000'
        item_number        = '000010'
        material           = 'MAT-1'
        plant              = '1000'
        reservation_number = '0000001240'
        reservation_item   = '0001'
        required_quantity  = '3.000'
        withdrawn_quantity = '1.000'
        base_unit          = 'EA' ) ).
    mo_service = NEW zcl_so_stock_service(
      io_repository     = mo_repository
      io_uom_repository = NEW lcl_so_stock_uom_repo( ) ).

    DATA(lt_results) = mo_service->preview_issue_demands_in_unit(
      VALUE #(
        ( request_id         = 'ORDER-ITEM-10'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '3.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'ORDER-ITEM-20'
          sales_document     = '0000001000'
          item_number        = '000020'
          requested_quantity = '3.000'
          requested_unit     = 'BOX' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '6.000' )
      act = lt_results[ 1 ]-requested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '6.000' )
      act = lt_results[ 1 ]-covered_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_results[ 1 ]-is_sufficient ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lt_results[ 1 ]-requested_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '2.500' )
      act = lt_results[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '2.500' )
      act = lt_results[ 2 ]-covered_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '0.500' )
      act = lt_results[ 2 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '1.000' )
      act = lt_results[ 2 ]-shortfall_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lt_results[ 2 ]-is_sufficient ).
  ENDMETHOD.

  METHOD prioritizes_issue_dates.
    DATA lv_base_date_rejected TYPE abap_bool.
    DATA lv_unit_date_rejected TYPE abap_bool.

    TRY.
        mo_service->preview_issue_demands(
          it_requests           = VALUE #(
            ( request_id         = 'BAD-ISSUE-DATE'
              sales_document     = '0000001000'
              item_number        = '000010'
              requested_quantity = '1.000'
              required_date      = '20261032' ) )
          iv_prioritize_by_date = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_base_date_rejected = abap_true.
    ENDTRY.
    TRY.
        mo_service->preview_issue_demands_in_unit(
          it_requests           = VALUE #(
            ( request_id         = 'BAD-ISSUE-UOM-DATE'
              sales_document     = '0000001000'
              item_number        = '000010'
              requested_quantity = '1.000'
              requested_unit     = 'BOX'
              required_date      = '20261032' ) )
          iv_prioritize_by_date = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_unit_date_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_base_date_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_unit_date_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->read_count ).

    mo_repository->order_items = VALUE #(
      ( sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000' ) ).
    mo_repository->base_units = VALUE #(
      ( material = 'MAT-1' base_unit = 'EA' ) ).
    mo_repository->stocks = VALUE #(
      ( sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000'
        base_unit      = 'EA'
        quantity       = '5.000' ) ).
    mo_service = NEW zcl_so_stock_service(
      io_repository     = mo_repository
      io_uom_repository = NEW lcl_so_stock_uom_repo( ) ).

    DATA(lt_base_results) = mo_service->preview_issue_demands(
      it_requests           = VALUE #(
        ( request_id         = 'ISSUE-LATE'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '3.000'
          required_date      = '20261012'
          priority           = 99 )
        ( request_id         = 'ISSUE-EARLY-LOW'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '1.000'
          required_date      = '20261005'
          priority           = 1 )
        ( request_id         = 'ISSUE-EARLY-HIGH'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '3.000'
          required_date      = '20261005'
          priority           = 10 ) )
      iv_prioritize_by_date = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'ISSUE-LATE'
      act = lt_base_results[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261012'
      act = lt_base_results[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '1.000' )
      act = lt_base_results[ 1 ]-covered_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'ISSUE-EARLY-LOW'
      act = lt_base_results[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '1.000' )
      act = lt_base_results[ 2 ]-covered_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'ISSUE-EARLY-HIGH'
      act = lt_base_results[ 3 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = lt_base_results[ 3 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '3.000' )
      act = lt_base_results[ 3 ]-covered_quantity ).

    DATA(lt_unit_results) = mo_service->preview_issue_demands_in_unit(
      it_requests           = VALUE #(
        ( request_id         = 'ISSUE-UOM-LATE'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '1.500'
          requested_unit     = 'BOX'
          required_date      = '20261012'
          priority           = 99 )
        ( request_id         = 'ISSUE-UOM-EARLY-LOW'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '0.500'
          requested_unit     = 'BOX'
          required_date      = '20261005'
          priority           = 1 )
        ( request_id         = 'ISSUE-UOM-EARLY-HIGH'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '1.500'
          requested_unit     = 'BOX'
          required_date      = '20261005'
          priority           = 10 ) )
      iv_prioritize_by_date = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'ISSUE-UOM-LATE'
      act = lt_unit_results[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '1.000' )
      act = lt_unit_results[ 1 ]-covered_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '0.500' )
      act = lt_unit_results[ 1 ]-covered_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'ISSUE-UOM-EARLY-LOW'
      act = lt_unit_results[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '0.500' )
      act = lt_unit_results[ 2 ]-covered_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'ISSUE-UOM-EARLY-HIGH'
      act = lt_unit_results[ 3 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = lt_unit_results[ 3 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '1.500' )
      act = lt_unit_results[ 3 ]-covered_quantity ).
  ENDMETHOD.

  METHOD prioritizes_issue_priority.
    DATA lv_bad_flag_rejected TYPE abap_bool.
    TRY.
        mo_service->preview_issue_demands(
          it_requests               = VALUE #(
            ( request_id         = 'BAD-ISSUE-PRIORITY-FLAG'
              sales_document     = '0000001000'
              item_number        = '000010'
              requested_quantity = '1.000' ) )
          iv_prioritize_by_priority = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_bad_flag_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_flag_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->read_count ).

    mo_repository->order_items = VALUE #(
      ( sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000' ) ).
    mo_repository->base_units = VALUE #(
      ( material = 'MAT-1' base_unit = 'EA' ) ).
    mo_repository->stocks = VALUE #(
      ( sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000'
        base_unit      = 'EA'
        quantity       = '5.000' ) ).
    mo_service = NEW zcl_so_stock_service(
      io_repository     = mo_repository
      io_uom_repository = NEW lcl_so_stock_uom_repo( ) ).

    DATA(lt_base_results) = mo_service->preview_issue_demands(
      it_requests               = VALUE #(
        ( request_id         = 'ISSUE-LOW'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '3.000'
          priority           = 1 )
        ( request_id         = 'ISSUE-HIGH'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '3.000'
          priority           = 10 ) )
      iv_prioritize_by_priority = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'ISSUE-LOW'
      act = lt_base_results[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lt_base_results[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '2.000' )
      act = lt_base_results[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '2.000' )
      act = lt_base_results[ 1 ]-covered_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'ISSUE-HIGH'
      act = lt_base_results[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = lt_base_results[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '5.000' )
      act = lt_base_results[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '3.000' )
      act = lt_base_results[ 2 ]-covered_quantity ).

    DATA(lt_unit_results) = mo_service->preview_issue_demands_in_unit(
      it_requests               = VALUE #(
        ( request_id         = 'ISSUE-UNIT-LOW'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '2.000'
          requested_unit     = 'BOX'
          priority           = 1 )
        ( request_id         = 'ISSUE-UNIT-HIGH'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '2.000'
          requested_unit     = 'BOX'
          priority           = 10 ) )
      iv_prioritize_by_priority = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'ISSUE-UNIT-LOW'
      act = lt_unit_results[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '1.000' )
      act = lt_unit_results[ 1 ]-available_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '0.500' )
      act = lt_unit_results[ 1 ]-covered_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '1.000' )
      act = lt_unit_results[ 1 ]-covered_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'ISSUE-UNIT-HIGH'
      act = lt_unit_results[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = lt_unit_results[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '2.500' )
      act = lt_unit_results[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '2.000' )
      act = lt_unit_results[ 2 ]-covered_quantity ).
  ENDMETHOD.

  METHOD full_qty_aggregate_previews.
    mo_repository->order_items = VALUE #(
      ( sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000' ) ).
    mo_repository->base_units = VALUE #(
      ( material = 'MAT-1' base_unit = 'EA' ) ).
    mo_repository->stocks = VALUE #(
      ( sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000'
        base_unit      = 'EA'
        quantity       = '5.000' ) ).

    DATA(lt_base_results) = mo_service->preview_issue_demands(
      it_requests              = VALUE #(
        ( request_id = 'AGG-BASE-1' sales_document = '0000001000'
          item_number = '000010' requested_quantity = '3.000' )
        ( request_id = 'AGG-BASE-2' sales_document = '0000001000'
          item_number = '000010' requested_quantity = '3.000' )
        ( request_id = 'AGG-BASE-3' sales_document = '0000001000'
          item_number = '000010' requested_quantity = '2.000' ) )
      iv_require_full_quantity = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '3.000' )
      act = lt_base_results[ 1 ]-covered_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '0.000' )
      act = lt_base_results[ 2 ]-covered_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '3.000' )
      act = lt_base_results[ 2 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '2.000' )
      act = lt_base_results[ 3 ]-covered_quantity ).

    mo_service = NEW zcl_so_stock_service(
      io_repository     = mo_repository
      io_uom_repository = NEW lcl_so_stock_uom_repo( ) ).
    DATA(lt_unit_results) = mo_service->preview_issue_demands_in_unit(
      it_requests              = VALUE #(
        ( request_id = 'AGG-UOM-1' sales_document = '0000001000'
          item_number = '000010' requested_quantity = '1.000'
          requested_unit = 'BOX' )
        ( request_id = 'AGG-UOM-2' sales_document = '0000001000'
          item_number = '000010' requested_quantity = '2.000'
          requested_unit = 'BOX' )
        ( request_id = 'AGG-UOM-3' sales_document = '0000001000'
          item_number = '000010' requested_quantity = '1.500'
          requested_unit = 'BOX' ) )
      iv_require_full_quantity = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '2.000' )
      act = lt_unit_results[ 1 ]-covered_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '0.000' )
      act = lt_unit_results[ 2 ]-covered_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '4.000' )
      act = lt_unit_results[ 2 ]-shortfall_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '3.000' )
      act = lt_unit_results[ 3 ]-covered_base_quantity ).
  ENDMETHOD.

  METHOD rejects_unknown_issue_unit.
    mo_repository->order_items = VALUE #(
      ( sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000' ) ).
    mo_repository->base_units = VALUE #(
      ( material = 'MAT-1' base_unit = 'EA' ) ).
    mo_service = NEW zcl_so_stock_service(
      io_repository     = mo_repository
      io_uom_repository = NEW lcl_so_stock_uom_repo( ) ).

    TRY.
        mo_service->preview_issue_demands_in_unit(
          VALUE #( (
            request_id         = 'ORDER-ITEM-10'
            sales_document     = '0000001000'
            item_number        = '000010'
            requested_quantity = '1.000'
            requested_unit     = 'CASE' ) ) ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_invalid_stock_request.
    ENDTRY.
  ENDMETHOD.

  METHOD rejects_unit_rounds_to_zero.
    mo_repository->order_items = VALUE #(
      ( sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000' ) ).
    mo_repository->base_units = VALUE #(
      ( material = 'MAT-1' base_unit = 'EA' ) ).
    mo_service = NEW zcl_so_stock_service(
      io_repository     = mo_repository
      io_uom_repository = NEW lcl_so_stock_uom_repo( ) ).

    TRY.
        mo_service->preview_issue_demands_in_unit(
          VALUE #( (
            request_id         = 'ORDER-ITEM-10'
            sales_document     = '0000001000'
            item_number        = '000010'
            requested_quantity = '0.001'
            requested_unit     = 'ML' ) ) ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_invalid_stock_request.
    ENDTRY.
  ENDMETHOD.

  METHOD previews_duplicate_issue_uom.
    mo_repository->order_items = VALUE #(
      ( sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000' ) ).
    mo_repository->base_units = VALUE #(
      ( material = 'MAT-1' base_unit = 'EA' ) ).
    mo_repository->stocks = VALUE #(
      ( sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000'
        base_unit      = 'EA'
        quantity       = '8.000' ) ).
    mo_service = NEW zcl_so_stock_service(
      io_repository     = mo_repository
      io_uom_repository = NEW lcl_so_stock_uom_repo( ) ).

    DATA(lt_results) = mo_service->preview_issue_demands_in_unit(
      VALUE #(
        ( request_id         = 'ORDER-ITEM-10-BOX'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '3.000'
          requested_unit     = 'BOX' )
        ( request_id         = 'ORDER-ITEM-10-EA'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '3.000'
          requested_unit     = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '4.000' )
      act = lt_results[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '6.000' )
      act = lt_results[ 1 ]-covered_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '2.000' )
      act = lt_results[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '2.000' )
      act = lt_results[ 2 ]-covered_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '1.000' )
      act = lt_results[ 2 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lt_results[ 2 ]-is_sufficient ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = mo_repository->read_count ).
  ENDMETHOD.

  METHOD allocates_duplicate_demands.
    mo_repository->order_items = VALUE #(
      ( sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000' ) ).
    mo_repository->base_units = VALUE #(
      ( material = 'MAT-1' base_unit = 'EA' ) ).
    mo_repository->stocks = VALUE #(
      ( sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000'
        base_unit      = 'EA'
        quantity       = '6.000' ) ).

    DATA(lt_results) = mo_service->preview_issue_demands(
      VALUE #(
        ( request_id         = 'ORDER-ITEM-10-A'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '4.000' )
        ( request_id         = 'ORDER-ITEM-10-B'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '4.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '6.000' )
      act = lt_results[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '4.000' )
      act = lt_results[ 1 ]-covered_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_results[ 1 ]-is_sufficient ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '2.000' )
      act = lt_results[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '2.000' )
      act = lt_results[ 2 ]-covered_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '2.000' )
      act = lt_results[ 2 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '6.000' )
      act = lt_results[ 2 ]-stock_snapshot-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = mo_repository->read_count ).
  ENDMETHOD.

  METHOD allocates_mixed_cutoffs.
    mo_repository->order_items = VALUE #(
      ( sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000' ) ).
    mo_repository->base_units = VALUE #(
      ( material = 'MAT-1' base_unit = 'EA' ) ).
    mo_repository->stocks = VALUE #(
      ( sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000'
        base_unit      = 'EA'
        quantity       = '10.000' ) ).
    mo_repository->reservations = VALUE #(
      ( sales_document     = '0000001000'
        item_number        = '000010'
        material           = 'MAT-1'
        plant              = '1000'
        reservation_number = '0000001240'
        reservation_item   = '0001'
        required_date      = '20260401'
        required_quantity  = '3.000'
        base_unit          = 'EA' )
      ( sales_document     = '0000001000'
        item_number        = '000010'
        material           = 'MAT-1'
        plant              = '1000'
        reservation_number = '0000001241'
        reservation_item   = '0001'
        required_date      = '20260402'
        required_quantity  = '2.000'
        base_unit          = 'EA' ) ).

    DATA(lt_base_results) = mo_service->preview_issue_demands(
      VALUE #(
        ( request_id               = 'BASE-APR-01-A'
          sales_document           = '0000001000'
          item_number              = '000010'
          requested_quantity       = '6.000'
          reservation_through_date = '20260401' )
        ( request_id               = 'BASE-APR-02'
          sales_document           = '0000001000'
          item_number              = '000010'
          requested_quantity       = '4.000'
          reservation_through_date = '20260402' )
        ( request_id               = 'BASE-APR-01-B'
          sales_document           = '0000001000'
          item_number              = '000010'
          requested_quantity       = '2.000'
          reservation_through_date = '20260401' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '7.000' )
      act = lt_base_results[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '5.000' )
      act = lt_base_results[ 2 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '1.000' )
      act = lt_base_results[ 3 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '1.000' )
      act = lt_base_results[ 3 ]-shortfall_quantity ).

    mo_service = NEW zcl_so_stock_service(
      io_repository     = mo_repository
      io_uom_repository = NEW lcl_so_stock_uom_repo( ) ).
    DATA(lt_unit_results) = mo_service->preview_issue_demands_in_unit(
      VALUE #(
        ( request_id               = 'UNIT-APR-01-A'
          sales_document           = '0000001000'
          item_number              = '000010'
          requested_quantity       = '2.000'
          requested_unit           = 'BOX'
          reservation_through_date = '20260401' )
        ( request_id               = 'UNIT-APR-02'
          sales_document           = '0000001000'
          item_number              = '000010'
          requested_quantity       = '2.000'
          requested_unit           = 'BOX'
          reservation_through_date = '20260402' )
        ( request_id               = 'UNIT-APR-01-B'
          sales_document           = '0000001000'
          item_number              = '000010'
          requested_quantity       = '2.000'
          requested_unit           = 'BOX'
          reservation_through_date = '20260401' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '7.000' )
      act = lt_unit_results[ 1 ]-available_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '5.000' )
      act = lt_unit_results[ 2 ]-available_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '3.000' )
      act = lt_unit_results[ 3 ]-available_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '1.500' )
      act = lt_unit_results[ 3 ]-covered_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '0.500' )
      act = lt_unit_results[ 3 ]-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 8
      act = mo_repository->read_count ).
  ENDMETHOD.

  METHOD empty_issue_preview_no_reads.
    DATA(lt_results) = mo_service->preview_issue_demands( VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->read_count ).

  ENDMETHOD.

  METHOD nets_open_reservations.
    mo_repository->base_units = VALUE #(
      ( material = 'MAT-1' base_unit = 'EA' ) ).
    mo_repository->stocks = VALUE #(
      ( sales_document   = '0000001000'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        batch            = 'B-1'
        base_unit        = 'EA'
        quantity         = '10.000' )
      ( sales_document   = '0000001000'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0002'
        batch            = 'B-2'
        base_unit        = 'EA'
        quantity         = '5.000' ) ).
    mo_repository->reservations = VALUE #(
      ( sales_document     = '0000001000'
        item_number        = '000010'
        material           = 'MAT-1'
        plant              = '1000'
        reservation_number = '0000001234'
        reservation_item   = '0001'
        required_quantity  = '4.000'
        withdrawn_quantity = '1.000'
        base_unit          = 'EA' ) ).
    APPEND VALUE #(
      sales_document     = '0000001000'
      item_number        = '000010'
      material           = 'MAT-1'
      plant              = '1000'
      reservation_number = '0000001235'
      reservation_item   = '0001'
      required_quantity  = '2.000'
      withdrawn_quantity = '2.000'
      base_unit          = 'EA' ) TO mo_repository->reservations.

    DATA(lt_results) = mo_service->read_stock_bulk(
      VALUE #( (
        request_id     = 'SO-ITEM-1'
        sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '15.000' )
      act = lt_results[ 1 ]-unrestricted_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '3.000' )
      act = lt_results[ 1 ]-reserved_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '12.000' )
      act = lt_results[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_results[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results[ 1 ]-stock_balances ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_results[ 1 ]-open_reservations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '3.000' )
      act = lt_results[ 1 ]-open_reservations[ 1 ]-open_quantity ).
  ENDMETHOD.

  METHOD rejects_stock_total_overflow.
    DATA lv_stock_overflow_rejected TYPE abap_bool.
    DATA lv_res_overflow_rejected TYPE abap_bool.
    DATA(lt_requests) = VALUE zcl_so_stock_service=>ty_requests( (
      request_id     = 'SO-RANGE'
      sales_document = '0000001000'
      item_number    = '000010'
      material       = 'MAT-1'
      plant          = '1000' ) ).
    mo_repository->base_units = VALUE #(
      ( material = 'MAT-1' base_unit = 'EA' ) ).
    mo_repository->stocks = VALUE #(
      ( sales_document   = '0000001000'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        base_unit        = 'EA'
        quantity         = '9999999999.999' )
      ( sales_document   = '0000001000'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0002'
        base_unit        = 'EA'
        quantity         = '9999999999.999' ) ).
    TRY.
        mo_service->read_stock_bulk( lt_requests ).
      CATCH zcx_invalid_stock_request.
        lv_stock_overflow_rejected = abap_true.
    ENDTRY.

    mo_repository->stocks = VALUE #(
      ( sales_document   = '0000001000'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        base_unit        = 'EA'
        quantity         = '10.000' ) ).
    mo_repository->reservations = VALUE #(
      ( sales_document     = '0000001000'
        item_number        = '000010'
        material           = 'MAT-1'
        plant              = '1000'
        reservation_number = '0000001301'
        reservation_item   = '0001'
        required_quantity  = '9999999999.999'
        withdrawn_quantity = '0.000'
        base_unit          = 'EA' )
      ( sales_document     = '0000001000'
        item_number        = '000010'
        material           = 'MAT-1'
        plant              = '1000'
        reservation_number = '0000001302'
        reservation_item   = '0001'
        required_quantity  = '9999999999.999'
        withdrawn_quantity = '0.000'
        base_unit          = 'EA' ) ).
    TRY.
        mo_service->read_stock_bulk( lt_requests ).
      CATCH zcx_invalid_stock_request.
        lv_res_overflow_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_stock_overflow_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_res_overflow_rejected ).
  ENDMETHOD.

  METHOD nets_reservations_through_date.
    mo_repository->base_units = VALUE #(
      ( material = 'MAT-1' base_unit = 'EA' ) ).
    mo_repository->stocks = VALUE #(
      ( sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000'
        base_unit      = 'EA'
        quantity       = '10.000' ) ).
    mo_repository->reservations = VALUE #(
      ( sales_document     = '0000001000'
        item_number        = '000010'
        material           = 'MAT-1'
        plant              = '1000'
        reservation_number = '0000001240'
        reservation_item   = '0001'
        required_date      = '20261015'
        required_quantity  = '4.000'
        withdrawn_quantity = '1.000'
        base_unit          = 'EA' )
      ( sales_document     = '0000001000'
        item_number        = '000010'
        material           = 'MAT-1'
        plant              = '1000'
        reservation_number = '0000001241'
        reservation_item   = '0001'
        required_date      = '20261025'
        required_quantity  = '5.000'
        withdrawn_quantity = '1.000'
        base_unit          = 'EA' )
      ( sales_document     = '0000001000'
        item_number        = '000010'
        material           = 'MAT-1'
        plant              = '1000'
        reservation_number = '0000001242'
        reservation_item   = '0001'
        required_quantity  = '2.000'
        withdrawn_quantity = '1.000'
        base_unit          = 'EA' ) ).

    DATA(lt_results) = mo_service->read_stock_bulk(
      VALUE #( (
        request_id               = 'SO-ITEM-1'
        sales_document           = '0000001000'
        item_number              = '000010'
        material                 = 'MAT-1'
        plant                    = '1000'
        reservation_through_date = '20261020' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '4.000' )
      act = lt_results[ 1 ]-reserved_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '6.000' )
      act = lt_results[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261020'
      act = lt_results[ 1 ]-reservation_through_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_results[ 1 ]-open_reservations ) ).
  ENDMETHOD.

  METHOD rejects_bad_cutoff.
    TRY.
        mo_service->read_stock_bulk(
          VALUE #( (
            request_id               = 'SO-ITEM-1'
            sales_document           = '0000001000'
            item_number              = '000010'
            material                 = 'MAT-1'
            plant                    = '1000'
            reservation_through_date = '20261340' ) ) ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_invalid_stock_request.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->read_count ).

  ENDMETHOD.

  METHOD keeps_items_separate.
    mo_repository->base_units = VALUE #(
      ( material = 'MAT-1' base_unit = 'EA' ) ).
    mo_repository->stocks = VALUE #(
      ( sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000'
        base_unit      = 'EA'
        quantity       = '8.000' )
      ( sales_document = '0000001001'
        item_number    = '000020'
        material       = 'MAT-1'
        plant          = '1000'
        base_unit      = 'EA'
        quantity       = '3.000' ) ).

    DATA(lt_results) = mo_service->read_stock_bulk(
      VALUE #( (
        request_id     = 'SECOND'
        sales_document = '0000001001'
        item_number    = '000020'
        material       = 'MAT-1'
        plant          = '1000' )
      ( request_id     = 'FIRST'
        sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'SECOND'
      act = lt_results[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '3.000' )
      act = lt_results[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '8.000' )
      act = lt_results[ 2 ]-available_quantity ).
  ENDMETHOD.

  METHOD rejects_duplicate_ids.
    TRY.
        mo_service->read_stock_bulk(
          VALUE #( (
            request_id     = 'DUPLICATE'
            sales_document = '0000001000'
            item_number    = '000010'
            material       = 'MAT-1'
            plant          = '1000' )
          ( request_id     = 'DUPLICATE'
            sales_document = '0000001001'
            item_number    = '000020'
            material       = 'MAT-1'
            plant          = '1000' ) ) ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_invalid_stock_request.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->read_count ).
  ENDMETHOD.

  METHOD returns_empty_bulk.
    DATA(lt_results) = mo_service->read_stock_bulk( VALUE #( ) ).
    DATA(lt_item_results) =
      mo_service->read_sales_order_items_bulk( VALUE #( ) ).

    cl_abap_unit_assert=>assert_initial( lt_results ).
    cl_abap_unit_assert=>assert_initial( lt_item_results ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->read_count ).
  ENDMETHOD.

  METHOD rejects_unrequested_rows.
    mo_repository->base_units = VALUE #(
      ( material = 'MAT-1' base_unit = 'EA' ) ).
    mo_repository->stocks = VALUE #(
      ( sales_document = '0000009999'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000'
        base_unit      = 'EA'
        quantity       = '8.000' ) ).

    TRY.
        mo_service->read_stock_bulk(
          VALUE #( (
            request_id     = 'SO-ITEM-1'
            sales_document = '0000001000'
            item_number    = '000010'
            material       = 'MAT-1'
            plant          = '1000' ) ) ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_invalid_stock_request.
    ENDTRY.
  ENDMETHOD.

  METHOD rejects_duplicate_base_units.
    mo_repository->base_units = VALUE #(
      ( material = 'MAT-1' base_unit = 'EA' )
      ( material = 'MAT-1' base_unit = 'EA' ) ).

    TRY.
        mo_service->read_stock_bulk(
          VALUE #( (
            request_id     = 'SO-ITEM-1'
            sales_document = '0000001000'
            item_number    = '000010'
            material       = 'MAT-1'
            plant          = '1000' ) ) ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_invalid_stock_request.
    ENDTRY.
  ENDMETHOD.

  METHOD rejects_overdrawn_reservation.
    mo_repository->base_units = VALUE #(
      ( material = 'MAT-1' base_unit = 'EA' ) ).
    mo_repository->reservations = VALUE #(
      ( sales_document     = '0000001000'
        item_number        = '000010'
        material           = 'MAT-1'
        plant              = '1000'
        reservation_number = '0000001234'
        reservation_item   = '0001'
        required_quantity  = '2.000'
        withdrawn_quantity = '3.000'
        base_unit          = 'EA' ) ).

    TRY.
        mo_service->read_stock_bulk(
          VALUE #( (
            request_id     = 'SO-ITEM-1'
            sales_document = '0000001000'
            item_number    = '000010'
            material       = 'MAT-1'
            plant          = '1000' ) ) ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_invalid_stock_request.
    ENDTRY.
  ENDMETHOD.

  METHOD resolves_sales_order_item.
    mo_repository->order_items = VALUE #(
      ( sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000' ) ).
    mo_repository->base_units = VALUE #(
      ( material = 'MAT-1' base_unit = 'EA' ) ).
    mo_repository->stocks = VALUE #(
      ( sales_document = '0000001000'
        item_number    = '000010'
        material       = 'MAT-1'
        plant          = '1000'
        base_unit      = 'EA'
        quantity       = '7.000' ) ).

    DATA(ls_result) = mo_service->read_sales_order_item(
      iv_sales_document           = '0000001000'
      iv_item_number              = '000010'
      iv_reservation_through_date = '20261020' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'MAT-1'
      act = ls_result-material ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = ls_result-plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '7.000' )
      act = ls_result-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261020'
      act = ls_result-reservation_through_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = mo_repository->read_count ).
  ENDMETHOD.

  METHOD rejects_missing_sales_item.
    TRY.
        mo_service->read_sales_order_items_bulk(
          VALUE #( (
            request_id     = 'SO-ITEM-1'
            sales_document = '0000001000'
            item_number    = '000010' ) ) ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_invalid_stock_request.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_repository->read_count ).
  ENDMETHOD.

  METHOD previews_issue_by_fefo.
    set_fefo_stock( ).

    DATA(ls_result) = mo_service->preview_issue_demands_by_fefo(
      it_requests   = VALUE #(
        ( request_id               = 'FEFO-A'
          sales_document           = '0000001000'
          item_number              = '000010'
          requested_quantity       = '3.000'
          reservation_through_date = '20261031' )
        ( request_id               = 'FEFO-B'
          sales_document           = '0000001000'
          item_number              = '000010'
          requested_quantity       = '6.000'
          reservation_through_date = '20261031' ) )
      iv_as_of_date = '20261014' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '8.000' )
      act = ls_result-allocations[ 1 ]-available_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '5.000' )
      act = ls_result-allocations[ 2 ]-available_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '5.000' )
      act = ls_result-allocations[ 2 ]-covered_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '1.000' )
      act = ls_result-allocations[ 2 ]-shortfall_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '1.000' )
      act = ls_result-batch_allocations[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-2'
      act = ls_result-batch_allocations[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-2'
      act = ls_result-batch_allocations[ 3 ]-batch ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-batch_allocations[ 4 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-allocations[ 2 ]-is_sufficient ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '11.000' )
      act = ls_result-allocations[ 1 ]-stock_snapshot-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-allocations[ 1 ]-include_undated_batches ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-batch_allocations[ 4 ]-include_undated_batches ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = mo_repository->read_count ).
  ENDMETHOD.

  METHOD previews_issue_by_fefo_uom.
    set_fefo_stock( ).

    DATA(ls_result) = mo_service->preview_issue_fefo_uom(
      it_requests   = VALUE #(
        ( request_id               = 'FEFO-UOM'
          sales_document           = '0000001000'
          item_number              = '000010'
          requested_quantity       = '3.000'
          requested_unit           = 'BOX'
          reservation_through_date = '20261031' ) )
      iv_as_of_date = '20261014' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '8.000' )
      act = ls_result-allocations[ 1 ]-available_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '4.000' )
      act = ls_result-allocations[ 1 ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '6.000' )
      act = ls_result-allocations[ 1 ]-requested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '0.500' )
      act = ls_result-batch_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '2.500' )
      act = ls_result-batch_allocations[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = ls_result-batch_allocations[ 1 ]-requested_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = mo_repository->read_count ).
  ENDMETHOD.

  METHOD prioritizes_fefo_issue_dates.
    DATA lv_base_date_rejected TYPE abap_bool.
    DATA lv_unit_date_rejected TYPE abap_bool.

    TRY.
        mo_service->preview_issue_demands_by_fefo(
          it_requests           = VALUE #(
            ( request_id         = 'BAD-FEFO-ISSUE-DATE'
              sales_document     = '0000001000'
              item_number        = '000010'
              requested_quantity = '1.000'
              required_date      = '20261032' ) )
          iv_as_of_date         = '20261001'
          iv_prioritize_by_date = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_base_date_rejected = abap_true.
    ENDTRY.
    TRY.
        mo_service->preview_issue_fefo_uom(
          it_requests           = VALUE #(
            ( request_id         = 'BAD-FEFO-UOM-DATE'
              sales_document     = '0000001000'
              item_number        = '000010'
              requested_quantity = '1.000'
              requested_unit     = 'BOX'
              required_date      = '20261032' ) )
          iv_as_of_date         = '20261001'
          iv_prioritize_by_date = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_unit_date_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_base_date_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_unit_date_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->read_count ).

    set_fefo_stock( ).
    mo_repository->reservations = VALUE #( ).
    mo_repository->stocks = VALUE #(
      ( sales_document   = '0000001000'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        batch            = 'B-EARLY'
        expiration_date  = '20261010'
        base_unit        = 'EA'
        quantity         = '2.000' )
      ( sales_document   = '0000001000'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        batch            = 'B-LATE'
        expiration_date  = '20261020'
        base_unit        = 'EA'
        quantity         = '3.000' ) ).

    DATA(ls_base_result) = mo_service->preview_issue_demands_by_fefo(
      it_requests           = VALUE #(
        ( request_id         = 'SO-FEFO-LATE'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '3.000'
          required_date      = '20261012'
          priority           = 99 )
        ( request_id         = 'SO-FEFO-EARLY-LOW'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '1.000'
          required_date      = '20261005'
          priority           = 1 )
        ( request_id         = 'SO-FEFO-EARLY-HIGH'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '3.000'
          required_date      = '20261005'
          priority           = 10 ) )
      iv_as_of_date         = '20261001'
      iv_prioritize_by_date = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'SO-FEFO-LATE'
      act = ls_base_result-allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261012'
      act = ls_base_result-allocations[ 1 ]-as_of_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '1.000' )
      act = ls_base_result-allocations[ 1 ]-covered_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SO-FEFO-EARLY-LOW'
      act = ls_base_result-allocations[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SO-FEFO-EARLY-HIGH'
      act = ls_base_result-allocations[ 3 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_base_result-allocations[ 3 ]-priority ).
    DATA(ls_high_split) = ls_base_result-batch_allocations[ 3 ].
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EARLY'
      act = ls_high_split-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '2.000' )
      act = ls_high_split-allocated_base_quantity ).

    DATA(ls_unit_result) = mo_service->preview_issue_fefo_uom(
      it_requests           = VALUE #(
        ( request_id         = 'SO-FEFO-UOM-LATE'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '1.500'
          requested_unit     = 'BOX'
          required_date      = '20261012'
          priority           = 99 )
        ( request_id         = 'SO-FEFO-UOM-EARLY-LOW'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '0.500'
          requested_unit     = 'BOX'
          required_date      = '20261005'
          priority           = 1 )
        ( request_id         = 'SO-FEFO-UOM-EARLY-HIGH'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '1.500'
          requested_unit     = 'BOX'
          required_date      = '20261005'
          priority           = 10 ) )
      iv_as_of_date         = '20261001'
      iv_prioritize_by_date = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'SO-FEFO-UOM-LATE'
      act = ls_unit_result-allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '1.000' )
      act = ls_unit_result-allocations[ 1 ]-covered_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SO-FEFO-UOM-EARLY-LOW'
      act = ls_unit_result-allocations[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SO-FEFO-UOM-EARLY-HIGH'
      act = ls_unit_result-allocations[ 3 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '3.000' )
      act = ls_unit_result-allocations[ 3 ]-covered_base_quantity ).
  ENDMETHOD.

  METHOD prioritizes_fefo_priority.
    set_fefo_stock( ).
    mo_repository->reservations = VALUE #( ).
    mo_repository->stocks = VALUE #(
      ( sales_document   = '0000001000'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        batch            = 'B-EARLY'
        expiration_date  = '20261010'
        base_unit        = 'EA'
        quantity         = '3.000' )
      ( sales_document   = '0000001000'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0002'
        batch            = 'B-LATE'
        expiration_date  = '20261020'
        base_unit        = 'EA'
        quantity         = '5.000' ) ).
    DATA(lt_requests) = VALUE zcl_so_stock_service=>ty_fefo_issue_requests(
      ( request_id         = 'SO-FEFO-LOW'
        sales_document     = '0000001000'
        item_number        = '000010'
        requested_quantity = '4.000'
        priority           = 1 )
      ( request_id         = 'SO-FEFO-HIGH'
        sales_document     = '0000001000'
        item_number        = '000010'
        requested_quantity = '4.000'
        priority           = 10 ) ).

    DATA(ls_base_result) = mo_service->preview_issue_demands_by_fefo(
      it_requests               = lt_requests
      iv_as_of_date             = '20261001'
      iv_prioritize_by_priority = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'SO-FEFO-LOW'
      act = ls_base_result-allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_base_result-allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATE'
      act = ls_base_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '4.000' )
      act = ls_base_result-batch_allocations[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SO-FEFO-HIGH'
      act = ls_base_result-allocations[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_base_result-allocations[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EARLY'
      act = ls_base_result-batch_allocations[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '3.000' )
      act = ls_base_result-batch_allocations[ 2 ]-allocated_base_quantity ).

    DATA(ls_unit_result) = mo_service->preview_issue_fefo_uom(
      it_requests               = VALUE zcl_so_stock_service=>ty_fefo_issue_unit_requests(
          ( request_id         = 'SO-FEFO-UNIT-LOW'
            sales_document     = '0000001000'
            item_number        = '000010'
            requested_quantity = '2.000'
            requested_unit     = 'BOX'
            priority           = 1 )
          ( request_id         = 'SO-FEFO-UNIT-HIGH'
            sales_document     = '0000001000'
            item_number        = '000010'
            requested_quantity = '2.000'
            requested_unit     = 'BOX'
            priority           = 10 ) )
      iv_as_of_date             = '20261001'
      iv_prioritize_by_priority = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'SO-FEFO-UNIT-LOW'
      act = ls_unit_result-allocations[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATE'
      act = ls_unit_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '4.000' )
      act = ls_unit_result-batch_allocations[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SO-FEFO-UNIT-HIGH'
      act = ls_unit_result-allocations[ 2 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_unit_result-allocations[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EARLY'
      act = ls_unit_result-batch_allocations[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '3.000' )
      act = ls_unit_result-batch_allocations[ 2 ]-allocated_base_quantity ).
  ENDMETHOD.

  METHOD full_quantity_fefo_requests.
    set_fefo_stock( ).

    DATA(ls_base_result) = mo_service->preview_issue_demands_by_fefo(
      it_requests              = VALUE #(
        ( request_id = 'FULL-BASE-1' sales_document = '0000001000'
          item_number = '000010' requested_quantity = '3.000'
          reservation_through_date = '20261031' )
        ( request_id = 'FULL-BASE-2' sales_document = '0000001000'
          item_number = '000010' requested_quantity = '6.000'
          reservation_through_date = '20261031' )
        ( request_id = 'FULL-BASE-3' sales_document = '0000001000'
          item_number = '000010' requested_quantity = '2.000'
          reservation_through_date = '20261031' ) )
      iv_as_of_date            = '20261014'
      iv_require_full_quantity = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '3.000' )
      act = ls_base_result-allocations[ 1 ]-covered_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '0.000' )
      act = ls_base_result-allocations[ 2 ]-covered_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '6.000' )
      act = ls_base_result-allocations[ 2 ]-shortfall_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '2.000' )
      act = ls_base_result-allocations[ 3 ]-covered_base_quantity ).

    set_fefo_stock( ).
    DATA(ls_unit_result) = mo_service->preview_issue_fefo_uom(
      it_requests              = VALUE #(
        ( request_id = 'FULL-UOM-1' sales_document = '0000001000'
          item_number = '000010' requested_quantity = '3.000'
          requested_unit = 'BOX' reservation_through_date = '20261031' )
        ( request_id = 'FULL-UOM-2' sales_document = '0000001000'
          item_number = '000010' requested_quantity = '2.000'
          requested_unit = 'BOX' reservation_through_date = '20261031' )
        ( request_id = 'FULL-UOM-3' sales_document = '0000001000'
          item_number = '000010' requested_quantity = '1.000'
          requested_unit = 'BOX' reservation_through_date = '20261031' ) )
      iv_as_of_date            = '20261014'
      iv_require_full_quantity = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '6.000' )
      act = ls_unit_result-allocations[ 1 ]-covered_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '0.000' )
      act = ls_unit_result-allocations[ 2 ]-covered_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '4.000' )
      act = ls_unit_result-allocations[ 2 ]-shortfall_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '2.000' )
      act = ls_unit_result-allocations[ 3 ]-covered_base_quantity ).
  ENDMETHOD.

  METHOD full_qty_fefo_row_policy.
    set_fefo_stock( ).

    DATA(ls_base_result) = mo_service->preview_issue_demands_by_fefo(
      it_requests   = VALUE #(
        ( request_id = 'ROW-FULL-BASE-1' sales_document = '0000001000'
          item_number = '000010' requested_quantity = '3.000'
          reservation_through_date = '20261031' )
        ( request_id = 'ROW-FULL-BASE-2' sales_document = '0000001000'
          item_number = '000010' requested_quantity = '6.000'
          reservation_through_date = '20261031'
          require_full_quantity = abap_true )
        ( request_id = 'ROW-FULL-BASE-3' sales_document = '0000001000'
          item_number = '000010' requested_quantity = '2.000'
          reservation_through_date = '20261031' ) )
      iv_as_of_date = '20261014' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '3.000' )
      act = ls_base_result-allocations[ 1 ]-covered_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '0.000' )
      act = ls_base_result-allocations[ 2 ]-covered_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '6.000' )
      act = ls_base_result-allocations[ 2 ]-shortfall_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '2.000' )
      act = ls_base_result-allocations[ 3 ]-covered_base_quantity ).

    set_fefo_stock( ).
    DATA(ls_uom_result) = mo_service->preview_issue_fefo_uom(
      it_requests   = VALUE #(
        ( request_id = 'ROW-FULL-UOM-1' sales_document = '0000001000'
          item_number = '000010' requested_quantity = '3.000'
          requested_unit = 'BOX' reservation_through_date = '20261031' )
        ( request_id = 'ROW-FULL-UOM-2' sales_document = '0000001000'
          item_number = '000010' requested_quantity = '3.000'
          requested_unit = 'BOX' reservation_through_date = '20261031'
          require_full_quantity = abap_true )
        ( request_id = 'ROW-FULL-UOM-3' sales_document = '0000001000'
          item_number = '000010' requested_quantity = '1.000'
          requested_unit = 'BOX' reservation_through_date = '20261031' ) )
      iv_as_of_date = '20261014' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '6.000' )
      act = ls_uom_result-allocations[ 1 ]-covered_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '0.000' )
      act = ls_uom_result-allocations[ 2 ]-covered_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '6.000' )
      act = ls_uom_result-allocations[ 2 ]-shortfall_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '2.000' )
      act = ls_uom_result-allocations[ 3 ]-covered_base_quantity ).
  ENDMETHOD.

  METHOD previews_fefo_selected_batch.
    set_fefo_stock( ).

    DATA(ls_result) = mo_service->preview_issue_demands_by_fefo(
      it_requests   = VALUE #(
        ( request_id               = 'BATCH-A'
          sales_document           = '0000001000'
          item_number              = '000010'
          batch                    = 'B-2'
          requested_quantity       = '3.000'
          reservation_through_date = '20261031' )
        ( request_id               = 'BATCH-B'
          sales_document           = '0000001000'
          item_number              = '000010'
          batch                    = 'B-2'
          requested_quantity       = '3.000'
          reservation_through_date = '20261031' ) )
      iv_as_of_date = '20261014' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '5.000' )
      act = ls_result-allocations[ 1 ]-available_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '2.000' )
      act = ls_result-allocations[ 2 ]-available_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '2.000' )
      act = ls_result-allocations[ 2 ]-covered_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '1.000' )
      act = ls_result-allocations[ 2 ]-shortfall_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-2'
      act = ls_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-2'
      act = ls_result-batch_allocations[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '2.000' )
      act = ls_result-batch_allocations[ 2 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '11.000' )
      act = ls_result-allocations[ 1 ]-stock_snapshot-available_quantity ).

    DATA(ls_expired_result) = mo_service->preview_issue_demands_by_fefo(
      it_requests   = VALUE #(
        ( request_id         = 'EXPIRED-BATCH'
          sales_document     = '0000001000'
          item_number        = '000010'
          batch              = 'B-OLD'
          requested_quantity = '1.000' ) )
      iv_as_of_date = '20261014' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( ls_expired_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_expired_result-allocations[ 1 ]-is_sufficient ).
  ENDMETHOD.

  METHOD filters_fefo_issue_location.
    set_fefo_stock( ).
    mo_repository->reservations = VALUE #( ).

    DATA(ls_base_result) = mo_service->preview_issue_demands_by_fefo(
      it_requests   = VALUE #(
        ( request_id         = 'LOCATION-BASE'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '6.000'
          storage_location   = '0002' ) )
      iv_as_of_date = '20261014' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '5.000' )
      act = ls_base_result-allocations[ 1 ]-available_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_base_result-allocations[ 1 ]-selected_storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_base_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_base_result-batch_allocations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act =
        ls_base_result-batch_allocations[ 1 ]-selected_storage_location ).

    DATA(ls_unit_result) = mo_service->preview_issue_fefo_uom(
      it_requests   = VALUE #(
        ( request_id         = 'LOCATION-UOM'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '2.000'
          requested_unit     = 'BOX'
          storage_location   = '0001' ) )
      iv_as_of_date = '20261014' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '4.000' )
      act = ls_unit_result-allocations[ 1 ]-available_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '4.000' )
      act = ls_unit_result-allocations[ 1 ]-covered_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_unit_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_unit_result-batch_allocations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '4.000' )
      act =
        ls_unit_result-batch_allocations[ 1 ]-allocated_base_quantity ).
  ENDMETHOD.

  METHOD fefo_location_fallback_order.
    set_fefo_stock( ).
    mo_repository->reservations = VALUE #( ).
    mo_repository->stocks = VALUE #(
      ( sales_document   = '0000001000'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        batch            = 'B-1'
        expiration_date  = '20261020'
        base_unit        = 'EA'
        quantity         = '2.000' )
      ( sales_document   = '0000001000'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0002'
        batch            = 'B-1'
        expiration_date  = '20261020'
        base_unit        = 'EA'
        quantity         = '3.000' )
      ( sales_document   = '0000001000'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0002'
        batch            = 'B-2'
        expiration_date  = '20261101'
        base_unit        = 'EA'
        quantity         = '10.000' ) ).

    DATA(ls_base_result) = mo_service->preview_issue_demands_by_fefo(
      it_requests   = VALUE #(
        ( request_id              = 'FALLBACK-BASE'
          sales_document          = '0000001000'
          item_number             = '000010'
          requested_quantity      = '4.000'
          storage_location        = '0002'
          allow_location_fallback = abap_true ) )
      iv_as_of_date = '20261014' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_base_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_base_result-batch_allocations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '3.000' )
      act = ls_base_result-batch_allocations[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_base_result-batch_allocations[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_base_result-allocations[ 1 ]-allow_location_fallback ).

    DATA(ls_unit_result) = mo_service->preview_issue_fefo_uom(
      it_requests   = VALUE #(
        ( request_id              = 'FALLBACK-UOM'
          sales_document          = '0000001000'
          item_number             = '000010'
          requested_quantity      = '2.000'
          requested_unit          = 'BOX'
          storage_location        = '0002'
          allow_location_fallback = abap_true ) )
      iv_as_of_date = '20261014' ).

    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_unit_result-batch_allocations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '3.000' )
      act = ls_unit_result-batch_allocations[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '1.500' )
      act = ls_unit_result-batch_allocations[ 1 ]-allocated_quantity ).

    mo_repository->stocks = VALUE #(
      ( sales_document   = '0000001000'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        batch            = 'B-EARLY'
        expiration_date  = '20261020'
        base_unit        = 'EA'
        quantity         = '2.000' )
      ( sales_document   = '0000001000'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0002'
        batch            = 'B-LATE'
        expiration_date  = '20261101'
        base_unit        = 'EA'
        quantity         = '3.000' ) ).

    DATA(ls_fefo_result) = mo_service->preview_issue_demands_by_fefo(
      it_requests   = VALUE #(
        ( request_id              = 'FALLBACK-FEFO'
          sales_document          = '0000001000'
          item_number             = '000010'
          requested_quantity      = '1.000'
          storage_location        = '0002'
          allow_location_fallback = abap_true ) )
      iv_as_of_date = '20261014' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EARLY'
      act = ls_fefo_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_fefo_result-batch_allocations[ 1 ]-storage_location ).
  ENDMETHOD.

  METHOD filters_fefo_allowed_locations.
    set_fefo_stock( ).
    mo_repository->reservations = VALUE #( ).

    DATA(ls_base_result) = mo_service->preview_issue_demands_by_fefo(
      it_requests           = VALUE #(
        ( request_id         = 'ALLOWED-BASE'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '6.000' ) )
      iv_as_of_date         = '20261014'
      it_location_allowlist = VALUE #( ( '0002' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '5.000' )
      act = ls_base_result-allocations[ 1 ]-available_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_base_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_base_result-batch_allocations[ 1 ]-storage_location ).

    DATA(ls_unit_result) = mo_service->preview_issue_fefo_uom(
      it_requests           = VALUE #(
        ( request_id         = 'ALLOWED-UOM'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '3.000'
          requested_unit     = 'BOX' ) )
      iv_as_of_date         = '20261014'
      it_location_allowlist = VALUE #( ( '0002' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '5.000' )
      act = ls_unit_result-allocations[ 1 ]-available_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_unit_result-batch_allocations[ 1 ]-storage_location ).

    TRY.
        mo_service->preview_issue_demands_by_fefo(
          it_requests           = VALUE #(
            ( request_id              = 'OUTSIDE-ALLOWLIST'
              sales_document          = '0000001000'
              item_number             = '000010'
              requested_quantity      = '1.000'
              storage_location        = '0001'
              allow_location_fallback = abap_true ) )
          iv_as_of_date         = '20261014'
          it_location_allowlist = VALUE #( ( '0002' ) ) ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_invalid_stock_request.
    ENDTRY.

    TRY.
        mo_service->preview_issue_demands_by_fefo(
          it_requests           = VALUE #(
            ( request_id         = 'BAD-ALLOWLIST'
              sales_document     = '0000001000'
              item_number        = '000010'
              requested_quantity = '1.000' ) )
          iv_as_of_date         = '20261014'
          it_location_allowlist = VALUE #(
            ( '0002' )
            ( '0002' ) ) ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_invalid_stock_request.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = 8
      act = mo_repository->read_count ).
  ENDMETHOD.

  METHOD filters_fefo_req_locations.
    set_fefo_stock( ).
    mo_repository->reservations = VALUE #( ).

    DATA(ls_base_result) = mo_service->preview_issue_demands_by_fefo(
      it_requests          = VALUE #(
        ( request_id         = 'REQ-LOC-1'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '3.000' )
        ( request_id         = 'REQ-LOC-2'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '4.000' ) )
      iv_as_of_date        = '20261014'
      it_request_locations = VALUE #(
        ( request_id = 'REQ-LOC-1' storage_location = '0001' )
        ( request_id = 'REQ-LOC-2' storage_location = '0002' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '4.000' )
      act = ls_base_result-allocations[ 1 ]-available_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '5.000' )
      act = ls_base_result-allocations[ 2 ]-available_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_base_result-batch_allocations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_base_result-batch_allocations[ 2 ]-storage_location ).

    DATA(ls_unit_result) = mo_service->preview_issue_fefo_uom(
      it_requests           = VALUE #(
        ( request_id         = 'REQ-LOC-UOM'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '2.000'
          requested_unit     = 'BOX' ) )
      iv_as_of_date         = '20261014'
      it_location_allowlist = VALUE #( ( '0002' ) ( '0003' ) )
      it_request_locations  = VALUE #(
        ( request_id = 'REQ-LOC-UOM' storage_location = '0002' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '5.000' )
      act = ls_unit_result-allocations[ 1 ]-available_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_unit_result-batch_allocations[ 1 ]-storage_location ).

    DATA(lv_read_count) = mo_repository->read_count.
    TRY.
        mo_service->preview_issue_demands_by_fefo(
          it_requests          = VALUE #(
            ( request_id         = 'KNOWN-REQ'
              sales_document     = '0000001000'
              item_number        = '000010'
              requested_quantity = '1.000' ) )
          iv_as_of_date        = '20261014'
          it_request_locations = VALUE #(
            ( request_id       = 'UNKNOWN-REQ'
              storage_location = '0001' ) ) ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_invalid_stock_request.
    ENDTRY.

    TRY.
        mo_service->preview_issue_demands_by_fefo(
          it_requests          = VALUE #(
            ( request_id         = 'DUP-REQ'
              sales_document     = '0000001000'
              item_number        = '000010'
              requested_quantity = '1.000' ) )
          iv_as_of_date        = '20261014'
          it_request_locations = VALUE #(
            ( request_id       = 'DUP-REQ'
              storage_location = '0001' )
            ( request_id       = 'DUP-REQ'
              storage_location = '0001' ) ) ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_invalid_stock_request.
    ENDTRY.

    TRY.
        mo_service->preview_issue_demands_by_fefo(
          it_requests          = VALUE #(
            ( request_id         = 'OUTSIDE-REQ-SCOPE'
              sales_document     = '0000001000'
              item_number        = '000010'
              requested_quantity = '1.000'
              storage_location   = '0001' ) )
          iv_as_of_date        = '20261014'
          it_request_locations = VALUE #(
            ( request_id       = 'OUTSIDE-REQ-SCOPE'
              storage_location = '0002' ) ) ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_invalid_stock_request.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = lv_read_count
      act = mo_repository->read_count ).
  ENDMETHOD.

  METHOD previews_fefo_batch_uom.
    set_fefo_stock( ).

    DATA(ls_result) = mo_service->preview_issue_fefo_uom(
      it_requests   = VALUE #(
        ( request_id               = 'BATCH-BOX'
          sales_document           = '0000001000'
          item_number              = '000010'
          batch                    = 'B-2'
          requested_quantity       = '3.000'
          requested_unit           = 'BOX'
          reservation_through_date = '20261031' ) )
      iv_as_of_date = '20261014' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '5.000' )
      act = ls_result-allocations[ 1 ]-available_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '6.000' )
      act = ls_result-allocations[ 1 ]-requested_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '5.000' )
      act = ls_result-allocations[ 1 ]-covered_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '1.000' )
      act = ls_result-allocations[ 1 ]-shortfall_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-2'
      act = ls_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '2.500' )
      act = ls_result-batch_allocations[ 1 ]-allocated_quantity ).
  ENDMETHOD.

  METHOD previews_fefo_min_shelf_life.
    set_fefo_stock( ).

    DATA(ls_result) = mo_service->preview_issue_demands_by_fefo(
      it_requests   = VALUE #(
        ( request_id               = 'FEFO-MIN-LIFE'
          sales_document           = '0000001000'
          item_number              = '000010'
          requested_quantity       = '4.000'
          reservation_through_date = '20261031' ) )
      iv_as_of_date = '20261014'
      iv_min_days   = 10 ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '3.000' )
      act = ls_result-allocations[ 1 ]-available_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '3.000' )
      act = ls_result-allocations[ 1 ]-covered_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '1.000' )
      act = ls_result-allocations[ 1 ]-shortfall_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-2'
      act = ls_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_result-allocations[ 1 ]-minimum_shelf_life_days ).
  ENDMETHOD.

  METHOD previews_fefo_demand_minimum.
    set_fefo_stock( ).
    mo_repository->reservations = VALUE #( ).
    mo_repository->stocks = VALUE #(
      ( sales_document   = '0000001000'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        batch            = 'B-1'
        expiration_date  = '20261020'
        base_unit        = 'EA'
        quantity         = '4.000' )
      ( sales_document   = '0000001000'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0002'
        batch            = 'B-2'
        expiration_date  = '20261101'
        base_unit        = 'EA'
        quantity         = '5.000' ) ).

    DATA(ls_result) = mo_service->preview_issue_demands_by_fefo(
      it_requests   = VALUE #(
        ( request_id              = 'FEFO-STRICT'
          sales_document          = '0000001000'
          item_number             = '000010'
          requested_quantity      = '1.000'
          minimum_shelf_life_days = 7 )
        ( request_id         = 'FEFO-RELAXED'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '1.000' ) )
      iv_as_of_date = '20261014'
      iv_min_days   = 2 ).

    cl_abap_unit_assert=>assert_equals(
      exp = 7
      act = ls_result-allocations[ 1 ]-minimum_shelf_life_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-2'
      act = ls_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-allocations[ 2 ]-minimum_shelf_life_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-batch_allocations[ 2 ]-batch ).
  ENDMETHOD.

  METHOD fefo_demand_minimum_uom.
    set_fefo_stock( ).
    mo_repository->reservations = VALUE #( ).
    mo_repository->stocks = VALUE #(
      ( sales_document   = '0000001000'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        batch            = 'B-1'
        expiration_date  = '20261020'
        base_unit        = 'EA'
        quantity         = '4.000' )
      ( sales_document   = '0000001000'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0002'
        batch            = 'B-2'
        expiration_date  = '20261101'
        base_unit        = 'EA'
        quantity         = '5.000' ) ).

    DATA(ls_result) = mo_service->preview_issue_fefo_uom(
      it_requests   = VALUE #(
        ( request_id              = 'FEFO-BOX-STRICT'
          sales_document          = '0000001000'
          item_number             = '000010'
          requested_quantity      = '1.000'
          requested_unit          = 'BOX'
          minimum_shelf_life_days = 7 ) )
      iv_as_of_date = '20261014'
      iv_min_days   = 2 ).

    cl_abap_unit_assert=>assert_equals(
      exp = 7
      act = ls_result-allocations[ 1 ]-minimum_shelf_life_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-2'
      act = ls_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '2.000' )
      act = ls_result-batch_allocations[ 1 ]-allocated_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '1.000' )
      act = ls_result-batch_allocations[ 1 ]-allocated_quantity ).
  ENDMETHOD.

  METHOD filters_fefo_known_expiry.
    set_fefo_stock( ).
    mo_repository->reservations = VALUE #( ).
    mo_repository->stocks = VALUE #(
      ( sales_document   = '0000001000'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        batch            = 'B-DATED'
        expiration_date  = '20261101'
        base_unit        = 'EA'
        quantity         = '2.000' )
      ( sales_document   = '0000001000'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0002'
        batch            = 'B-UNDATED'
        base_unit        = 'EA'
        quantity         = '3.000' ) ).

    DATA(ls_result) = mo_service->preview_issue_demands_by_fefo(
      it_requests   = VALUE #(
        ( request_id           = 'FEFO-KNOWN'
          sales_document       = '0000001000'
          item_number          = '000010'
          requested_quantity   = '3.000'
          require_known_expiry = abap_true )
        ( request_id         = 'FEFO-ANY-EXPIRY'
          sales_document     = '0000001000'
          item_number        = '000010'
          requested_quantity = '3.000' ) )
      iv_as_of_date = '20261014' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-allocations[ 1 ]-include_undated_batches ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '2.000' )
      act = ls_result-allocations[ 1 ]-available_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-DATED'
      act = ls_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-allocations[ 2 ]-include_undated_batches ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-UNDATED'
      act = ls_result-batch_allocations[ 2 ]-batch ).
  ENDMETHOD.

  METHOD rejects_bad_fefo_expiry.
    set_fefo_stock( ).
    mo_repository->reservations = VALUE #( ).
    LOOP AT mo_repository->stocks ASSIGNING FIELD-SYMBOL(<ls_stock>).
      IF <ls_stock>-batch = 'B-1'.
        <ls_stock>-expiration_date = '20261340'.
      ENDIF.
    ENDLOOP.

    DATA(lv_rejected) = abap_false.
    TRY.
        mo_service->preview_issue_demands_by_fefo(
          it_requests   = VALUE #(
            ( request_id         = 'BAD-EXPIRY-DATA'
              sales_document     = '0000001000'
              item_number        = '000010'
              requested_quantity = '1.000' ) )
          iv_as_of_date = '20261014' ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
  ENDMETHOD.

  METHOD filters_fefo_known_expiry_uom.
    set_fefo_stock( ).
    mo_repository->reservations = VALUE #( ).
    mo_repository->stocks = VALUE #(
      ( sales_document   = '0000001000'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        batch            = 'B-DATED'
        expiration_date  = '20261101'
        base_unit        = 'EA'
        quantity         = '2.000' )
      ( sales_document   = '0000001000'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0002'
        batch            = 'B-UNDATED'
        base_unit        = 'EA'
        quantity         = '3.000' ) ).

    DATA(ls_result) = mo_service->preview_issue_fefo_uom(
      it_requests   = VALUE #(
        ( request_id           = 'FEFO-KNOWN-BOX'
          sales_document       = '0000001000'
          item_number          = '000010'
          requested_quantity   = '1.000'
          requested_unit       = 'BOX'
          require_known_expiry = abap_true ) )
      iv_as_of_date = '20261014' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-allocations[ 1 ]-include_undated_batches ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '2.000' )
      act = ls_result-allocations[ 1 ]-available_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-DATED'
      act = ls_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '1.000' )
      act = ls_result-batch_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-batch_allocations[ 1 ]-include_undated_batches ).
  ENDMETHOD.

  METHOD rejects_bad_fefo_issue_options.
    set_fefo_stock( ).

    TRY.
        mo_service->preview_issue_demands_by_fefo(
          it_requests   = VALUE #(
            ( request_id         = 'BAD-FEFO'
              sales_document     = '0000001000'
              item_number        = '000010'
              requested_quantity = '1.000' ) )
          iv_as_of_date = '20261340' ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_invalid_stock_request.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->read_count ).

    TRY.
        mo_service->preview_issue_demands_by_fefo(
          it_requests   = VALUE #(
            ( request_id            = 'BAD-ROW-FULL'
              sales_document        = '0000001000'
              item_number           = '000010'
              requested_quantity    = '1.000'
              require_full_quantity = 'Y' ) )
          iv_as_of_date = '20261014' ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_invalid_stock_request.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->read_count ).

    TRY.
        mo_service->preview_issue_demands_by_fefo(
          it_requests              = VALUE #(
            ( request_id         = 'BAD-FULL-QUANTITY'
              sales_document     = '0000001000'
              item_number        = '000010'
              requested_quantity = '1.000' ) )
          iv_as_of_date            = '20261014'
          iv_require_full_quantity = 'Y' ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_invalid_stock_request.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->read_count ).

    TRY.
        mo_service->preview_issue_demands_by_fefo(
          it_requests   = VALUE #(
            ( request_id              = 'BAD-MINIMUM'
              sales_document          = '0000001000'
              item_number             = '000010'
              requested_quantity      = '1.000'
              minimum_shelf_life_days = -1 ) )
          iv_as_of_date = '20261014' ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_invalid_stock_request.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->read_count ).

    TRY.
        mo_service->preview_issue_demands_by_fefo(
          it_requests   = VALUE #(
            ( request_id           = 'BAD-EXPIRY-POLICY'
              sales_document       = '0000001000'
              item_number          = '000010'
              requested_quantity   = '1.000'
              require_known_expiry = 'Y' ) )
          iv_as_of_date = '20261014' ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_invalid_stock_request.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->read_count ).

    TRY.
        mo_service->preview_issue_demands_by_fefo(
          it_requests   = VALUE #(
            ( request_id              = 'BAD-LOCATION-FALLBACK-FLAG'
              sales_document          = '0000001000'
              item_number             = '000010'
              requested_quantity      = '1.000'
              storage_location        = '0001'
              allow_location_fallback = 'Y' ) )
          iv_as_of_date = '20261014' ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_invalid_stock_request.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->read_count ).

    TRY.
        mo_service->preview_issue_demands_by_fefo(
          it_requests   = VALUE #(
            ( request_id              = 'FALLBACK-WITHOUT-PREFERENCE'
              sales_document          = '0000001000'
              item_number             = '000010'
              requested_quantity      = '1.000'
              allow_location_fallback = abap_true ) )
          iv_as_of_date = '20261014' ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_invalid_stock_request.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->read_count ).
  ENDMETHOD.

  METHOD aggregates_dup_fefo_stock.
    set_fefo_stock( ).
    mo_repository->reservations = VALUE #( ).
    mo_repository->stocks = VALUE #(
      ( sales_document   = '0000001000'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        batch            = 'B-1'
        expiration_date  = '20261020'
        base_unit        = 'EA'
        quantity         = '4.000' )
      ( sales_document   = '0000001000'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        batch            = 'B-1'
        expiration_date  = '20261020'
        base_unit        = 'EA'
        quantity         = '4.000' ) ).

    TRY.
        DATA(ls_result) = mo_service->preview_issue_demands_by_fefo(
          it_requests   = VALUE #(
            ( request_id         = 'DUP-BALANCE'
              sales_document     = '0000001000'
              item_number        = '000010'
              requested_quantity = '8.000' ) )
          iv_as_of_date = '20261014' ).
      CATCH zcx_invalid_stock_request.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '8.000' )
      act = ls_result-allocations[ 1 ]-available_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '8.000' )
      act = ls_result-batch_allocations[ 1 ]-allocated_base_quantity ).
  ENDMETHOD.
ENDCLASS.
