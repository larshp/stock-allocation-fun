CLASS lcl_so_fefo_issue_repository DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_so_stock_repository.
    DATA stock_rows TYPE zif_so_stock_repository=>ty_stock_rows.
    DATA read_count TYPE i.
ENDCLASS.

CLASS lcl_so_fefo_issue_repository IMPLEMENTATION.
  METHOD zif_so_stock_repository~read_base_units_bulk.
    ADD 1 TO read_count.
    LOOP AT it_requests INTO DATA(ls_request).
      READ TABLE rt_units TRANSPORTING NO FIELDS
        WITH KEY material = ls_request-material.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.
      APPEND VALUE #(
        material  = ls_request-material
        base_unit = 'EA' ) TO rt_units.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_so_stock_repository~read_order_items_bulk.
    ADD 1 TO read_count.
    LOOP AT it_item_requests INTO DATA(ls_request).
      READ TABLE rt_items TRANSPORTING NO FIELDS
        WITH KEY sales_document = ls_request-sales_document
                 item_number    = ls_request-item_number.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.
      APPEND VALUE #(
        sales_document = ls_request-sales_document
        item_number    = ls_request-item_number
        material       = 'MAT-1'
        plant          = '1000' ) TO rt_items.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_so_stock_repository~read_stock_bulk.
    ADD 1 TO read_count.
    rt_rows = stock_rows.
  ENDMETHOD.

  METHOD zif_so_stock_repository~read_reservations_bulk.
    ADD 1 TO read_count.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_so_fefo_issue_uom_repo DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_material_uom_repository.
ENDCLASS.

CLASS lcl_so_fefo_issue_uom_repo IMPLEMENTATION.
  METHOD zif_material_uom_repository~get_base_unit.
    IF iv_material = 'MAT-1'.
      rv_base_unit = 'EA'.
    ENDIF.
  ENDMETHOD.

  METHOD zif_material_uom_repository~get_alt_unit_ratio.
    IF iv_material = 'MAT-1' AND iv_alternative_unit = 'BOX'.
      rs_ratio-numerator = 2.
      rs_ratio-denominator = 1.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_so_fefo_issue_api DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_goods_movement_api.
    DATA last_items TYPE zif_goods_movement_api=>ty_items.
    DATA create_count TYPE i.
ENDCLASS.

CLASS lcl_so_fefo_issue_api IMPLEMENTATION.
  METHOD zif_goods_movement_api~create_movement.
    ADD 1 TO create_count.
    last_items = it_items.
    rs_result = VALUE #(
      material_document = '4900000001'
      fiscal_year       = '2026'
      is_successful     = abap_true ).
  ENDMETHOD.

  METHOD zif_goods_movement_api~cancel_movement.
    rs_result-is_successful = abap_true.
  ENDMETHOD.

  METHOD zif_goods_movement_api~commit.
    rs_result-is_successful = abap_true.
  ENDMETHOD.

  METHOD zif_goods_movement_api~rollback.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_so_fefo_issue_service DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO lcl_so_fefo_issue_repository.
    DATA mo_uom_repository TYPE REF TO lcl_so_fefo_issue_uom_repo.
    DATA mo_stock_service TYPE REF TO zcl_so_stock_service.
    DATA mo_api TYPE REF TO lcl_so_fefo_issue_api.
    DATA mo_goods_movement TYPE REF TO zcl_goods_movement_service.
    DATA mo_cut TYPE REF TO zcl_so_fefo_issue_service.
    DATA mt_requests TYPE zcl_so_stock_service=>ty_fefo_issue_requests.
    DATA ms_allocation TYPE zcl_so_stock_service=>ty_fefo_issue_result.
    METHODS setup.
    METHODS posts_fresh_fefo_preview FOR TESTING.
    METHODS posts_fresh_fefo_uom FOR TESTING.
    METHODS posts_priority_fefo_preview FOR TESTING.
    METHODS posts_priority_fefo_uom FOR TESTING.
    METHODS issues_only_known_expiry_batch FOR TESTING.
    METHODS posts_fefo_location_fallback FOR TESTING.
    METHODS posts_selected_fefo_cutoff FOR TESTING.
    METHODS rejects_bad_fefo_selection FOR TESTING.
    METHODS rejects_stale_fefo_preview FOR TESTING.
    METHODS accepts_empty_fefo_issue FOR TESTING.
ENDCLASS.

CLASS ltcl_so_fefo_issue_service IMPLEMENTATION.
  METHOD setup.
    mo_repository = NEW lcl_so_fefo_issue_repository( ).
    mo_repository->stock_rows = VALUE #(
      ( sales_document   = '0000001234'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        batch            = 'B-1'
        expiration_date  = '20261231'
        base_unit        = 'EA'
        quantity         = '3.000' ) ).
    mo_uom_repository = NEW lcl_so_fefo_issue_uom_repo( ).
    mo_stock_service = NEW zcl_so_stock_service(
      io_repository     = mo_repository
      io_uom_repository = mo_uom_repository ).
    mo_api = NEW lcl_so_fefo_issue_api( ).
    mo_goods_movement = NEW zcl_goods_movement_service(
      io_api = mo_api ).
    mo_cut = NEW zcl_so_fefo_issue_service(
      io_stock_service          = mo_stock_service
      io_goods_movement_service = mo_goods_movement ).
    mt_requests = VALUE #(
      ( request_id         = 'SO-FEFO-1'
        sales_document     = '0000001234'
        item_number        = '000010'
        requested_quantity = '2.000' ) ).
    ms_allocation = mo_stock_service->preview_issue_demands_by_fefo(
      it_requests   = mt_requests
      iv_as_of_date = '20261013' ).
  ENDMETHOD.

  METHOD posts_fresh_fefo_preview.
    DATA(ls_result) = mo_cut->issue_fefo(
      is_allocation     = ms_allocation
      it_requests       = mt_requests
      is_header         = VALUE #(
        posting_date  = '20261013'
        document_date = '20261013' )
      it_material_units = VALUE #(
        ( material      = 'MAT-1'
          base_unit     = 'EA'
          base_unit_iso = 'EA' ) )
      iv_as_of_date     = '20261013' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->create_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = '231'
      act = mo_api->last_items[ 1 ]-movement_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = mo_api->last_items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001234'
      act = mo_api->last_items[ 1 ]-sales_order ).
  ENDMETHOD.

  METHOD posts_fresh_fefo_uom.
    DATA(lt_requests) = VALUE zcl_so_stock_service=>ty_fefo_issue_unit_requests(
        ( request_id         = 'SO-FEFO-BOX'
          sales_document     = '0000001234'
          item_number        = '000010'
          requested_quantity = '1.000'
          requested_unit     = 'BOX' ) ).
    DATA(ls_allocation) = mo_stock_service->preview_issue_fefo_uom(
      it_requests   = lt_requests
      iv_as_of_date = '20261013' ).

    DATA(ls_result) = mo_cut->issue_fefo_uom(
      is_allocation     = ls_allocation
      it_requests       = lt_requests
      is_header         = VALUE #(
        posting_date  = '20261013'
        document_date = '20261013' )
      it_material_units = VALUE #(
        ( material      = 'MAT-1'
          base_unit     = 'EA'
          base_unit_iso = 'EA' ) )
      iv_as_of_date     = '20261013' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->create_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '2.000' )
      act = mo_api->last_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = mo_api->last_items[ 1 ]-entry_unit ).
  ENDMETHOD.

  METHOD posts_priority_fefo_preview.
    mo_repository->stock_rows = VALUE #(
      ( sales_document   = '0000001234'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        batch            = 'B-EARLY'
        expiration_date  = '20261020'
        base_unit        = 'EA'
        quantity         = '3.000' )
      ( sales_document   = '0000001234'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0002'
        batch            = 'B-LATE'
        expiration_date  = '20261031'
        base_unit        = 'EA'
        quantity         = '5.000' ) ).
    mt_requests = VALUE #(
      ( request_id         = 'SO-FEFO-LOW'
        sales_document     = '0000001234'
        item_number        = '000010'
        requested_quantity = '4.000'
        priority           = 1 )
      ( request_id         = 'SO-FEFO-HIGH'
        sales_document     = '0000001234'
        item_number        = '000010'
        requested_quantity = '4.000'
        priority           = 10 ) ).
    ms_allocation = mo_stock_service->preview_issue_demands_by_fefo(
      it_requests               = mt_requests
      iv_as_of_date             = '20261013'
      iv_prioritize_by_priority = abap_true ).

    DATA(ls_result) = mo_cut->issue_fefo(
      is_allocation             = ms_allocation
      it_requests               = mt_requests
      is_header                 = VALUE #(
        posting_date  = '20261013'
        document_date = '20261013' )
      it_material_units         = VALUE #(
        ( material      = 'MAT-1'
          base_unit     = 'EA'
          base_unit_iso = 'EA' ) )
      iv_as_of_date             = '20261013'
      iv_prioritize_by_priority = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( mo_api->last_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATE'
      act = mo_api->last_items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '4.000' )
      act = mo_api->last_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EARLY'
      act = mo_api->last_items[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '3.000' )
      act = mo_api->last_items[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATE'
      act = mo_api->last_items[ 3 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '1.000' )
      act = mo_api->last_items[ 3 ]-quantity ).
  ENDMETHOD.

  METHOD posts_priority_fefo_uom.
    mo_repository->stock_rows = VALUE #(
      ( sales_document   = '0000001234'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        batch            = 'B-EARLY'
        expiration_date  = '20261020'
        base_unit        = 'EA'
        quantity         = '3.000' )
      ( sales_document   = '0000001234'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0002'
        batch            = 'B-LATE'
        expiration_date  = '20261031'
        base_unit        = 'EA'
        quantity         = '5.000' ) ).
    DATA(lt_unit_requests) =
      VALUE zcl_so_stock_service=>ty_fefo_issue_unit_requests(
        ( request_id         = 'SO-FEFO-UOM-LOW'
          sales_document     = '0000001234'
          item_number        = '000010'
          requested_quantity = '2.000'
          requested_unit     = 'BOX'
          priority           = 1 )
        ( request_id         = 'SO-FEFO-UOM-HIGH'
          sales_document     = '0000001234'
          item_number        = '000010'
          requested_quantity = '2.000'
          requested_unit     = 'BOX'
          priority           = 10 ) ).
    DATA(ls_preview) = mo_stock_service->preview_issue_fefo_uom(
      it_requests               = lt_unit_requests
      iv_as_of_date             = '20261013'
      iv_prioritize_by_priority = abap_true ).

    DATA(ls_result) = mo_cut->issue_fefo_uom(
      is_allocation             = ls_preview
      it_requests               = lt_unit_requests
      is_header                 = VALUE #(
        posting_date  = '20261013'
        document_date = '20261013' )
      it_material_units         = VALUE #(
        ( material      = 'MAT-1'
          base_unit     = 'EA'
          base_unit_iso = 'EA' ) )
      iv_as_of_date             = '20261013'
      iv_prioritize_by_priority = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( mo_api->last_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATE'
      act = mo_api->last_items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '4.000' )
      act = mo_api->last_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EARLY'
      act = mo_api->last_items[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '3.000' )
      act = mo_api->last_items[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATE'
      act = mo_api->last_items[ 3 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '1.000' )
      act = mo_api->last_items[ 3 ]-quantity ).
  ENDMETHOD.

  METHOD issues_only_known_expiry_batch.
    mo_repository->stock_rows = VALUE #(
      ( sales_document   = '0000001234'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        batch            = 'B-DATED'
        expiration_date  = '20261231'
        base_unit        = 'EA'
        quantity         = '2.000' )
      ( sales_document   = '0000001234'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0002'
        batch            = 'B-UNDATED'
        base_unit        = 'EA'
        quantity         = '5.000' ) ).
    mt_requests = VALUE #(
      ( request_id           = 'SO-FEFO-KNOWN'
        sales_document       = '0000001234'
        item_number          = '000010'
        requested_quantity   = '3.000'
        require_known_expiry = abap_true ) ).
    ms_allocation            = mo_stock_service->preview_issue_demands_by_fefo(
      it_requests   = mt_requests
      iv_as_of_date = '20261013' ).

    DATA(ls_result) = mo_cut->issue_fefo(
      is_allocation              = ms_allocation
      it_requests                = mt_requests
      is_header                  = VALUE #(
        posting_date  = '20261013'
        document_date = '20261013' )
      it_material_units          = VALUE #(
        ( material      = 'MAT-1'
          base_unit     = 'EA'
          base_unit_iso = 'EA' ) )
      iv_as_of_date              = '20261013'
      iv_require_full_allocation = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->create_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-DATED'
      act = mo_api->last_items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV bapi2017_gm_item_create-entry_qnt( '2.000' )
      act = mo_api->last_items[ 1 ]-quantity ).
  ENDMETHOD.

  METHOD posts_fefo_location_fallback.
    mo_repository->stock_rows = VALUE #(
      ( sales_document   = '0000001234'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        batch            = 'B-1'
        expiration_date  = '20261231'
        base_unit        = 'EA'
        quantity         = '2.000' )
      ( sales_document   = '0000001234'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0002'
        batch            = 'B-1'
        expiration_date  = '20261231'
        base_unit        = 'EA'
        quantity         = '3.000' )
      ( sales_document   = '0000001234'
        item_number      = '000010'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0003'
        batch            = 'B-1'
        expiration_date  = '20261231'
        base_unit        = 'EA'
        quantity         = '5.000' ) ).
    mt_requests = VALUE #(
      ( request_id              = 'SO-FEFO-PREFERRED'
        sales_document          = '0000001234'
        item_number             = '000010'
        requested_quantity      = '4.000'
        storage_location        = '0002'
        allow_location_fallback = abap_true ) ).
    ms_allocation = mo_stock_service->preview_issue_demands_by_fefo(
      it_requests           = mt_requests
      iv_as_of_date         = '20261013'
      it_location_allowlist = VALUE #( ( '0001' ) ( '0002' ) )
      it_request_locations  = VALUE #(
        ( request_id = 'SO-FEFO-PREFERRED' storage_location = '0001' )
        ( request_id = 'SO-FEFO-PREFERRED' storage_location = '0002' ) ) ).

    DATA(ls_result) = mo_cut->issue_fefo(
      is_allocation         = ms_allocation
      it_requests           = mt_requests
      is_header             = VALUE #(
        posting_date  = '20261013'
        document_date = '20261013' )
      it_material_units     = VALUE #(
        ( material      = 'MAT-1'
          base_unit     = 'EA'
          base_unit_iso = 'EA' ) )
      iv_as_of_date         = '20261013'
      it_location_allowlist = VALUE #( ( '0001' ) ( '0002' ) )
      it_request_locations  = VALUE #(
        ( request_id = 'SO-FEFO-PREFERRED' storage_location = '0001' )
        ( request_id = 'SO-FEFO-PREFERRED' storage_location = '0002' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( mo_api->last_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = mo_api->last_items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = mo_api->last_items[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV bapi2017_gm_item_create-entry_qnt( '3.000' )
      act = mo_api->last_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV bapi2017_gm_item_create-entry_qnt( '1.000' )
      act = mo_api->last_items[ 2 ]-quantity ).
  ENDMETHOD.

  METHOD posts_selected_fefo_cutoff.
    DATA(lt_requests) = VALUE zcl_so_stock_service=>ty_fefo_issue_requests(
      ( request_id               = 'SO-FEFO-1'
        sales_document           = '0000001234'
        item_number              = '000010'
        requested_quantity       = '2.000'
        reservation_through_date = '20261010' )
      ( request_id               = 'SO-FEFO-2'
        sales_document           = '0000001234'
        item_number              = '000010'
        requested_quantity       = '2.000'
        reservation_through_date = '20261020' ) ).
    DATA(ls_allocation) = mo_stock_service->preview_issue_demands_by_fefo(
      it_requests   = lt_requests
      iv_as_of_date = '20261013' ).
    DATA(ls_result) = mo_cut->issue_fefo(
      is_allocation     = ls_allocation
      it_requests       = lt_requests
      it_request_ids    = VALUE #(
        ( 'SO-FEFO-2' ) )
      is_header         = VALUE #(
        posting_date  = '20261013'
        document_date = '20261013' )
      it_material_units = VALUE #(
        ( material      = 'MAT-1'
          base_unit     = 'EA'
          base_unit_iso = 'EA' ) )
      iv_as_of_date     = '20261013' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->create_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2.000'
      act = mo_api->last_items[ 1 ]-quantity ).
  ENDMETHOD.

  METHOD rejects_bad_fefo_selection.
    DATA(lv_read_count) = mo_repository->read_count.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->issue_fefo(
          is_allocation     = ms_allocation
          it_requests       = mt_requests
          it_request_ids    = VALUE #(
            ( 'UNKNOWN' ) )
          is_header         = VALUE #(
            posting_date  = '20261013'
            document_date = '20261013' )
          it_material_units = VALUE #(
            ( material      = 'MAT-1'
              base_unit     = 'EA'
              base_unit_iso = 'EA' ) )
          iv_as_of_date     = '20261013' ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_read_count
      act = mo_repository->read_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->create_count ).
  ENDMETHOD.

  METHOD rejects_stale_fefo_preview.
    mo_repository->stock_rows[ 1 ]-quantity = '2.000'.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->issue_fefo(
          is_allocation     = ms_allocation
          it_requests       = mt_requests
          is_header         = VALUE #(
            posting_date  = '20261013'
            document_date = '20261013' )
          it_material_units = VALUE #(
            ( material      = 'MAT-1'
              base_unit     = 'EA'
              base_unit_iso = 'EA' ) )
          iv_as_of_date     = '20261013' ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->create_count ).
  ENDMETHOD.

  METHOD accepts_empty_fefo_issue.
    DATA(ls_result) = mo_cut->issue_fefo(
      is_allocation     = VALUE #( )
      it_requests       = VALUE #( )
      is_header         = VALUE #( )
      it_material_units = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->create_count ).
  ENDMETHOD.
ENDCLASS.
