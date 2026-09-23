CLASS lcl_goods_movement_api_double DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_goods_movement_api.
    METHODS set_create_result
      IMPORTING
        is_result TYPE zif_goods_movement_api=>ty_result.
    METHODS set_commit_result
      IMPORTING
        is_result TYPE zif_goods_movement_api=>ty_commit_result.
    METHODS set_cancel_result
      IMPORTING
        is_result TYPE zif_goods_movement_api=>ty_result.
    METHODS get_create_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_commit_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_cancel_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_rollback_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_last_items
      RETURNING
        VALUE(rt_items) TYPE zif_goods_movement_api=>ty_items.
    METHODS get_last_gm_code
      RETURNING
        VALUE(rv_gm_code) TYPE zif_goods_movement_api=>ty_gm_code.
    METHODS was_test_run
      RETURNING
        VALUE(rv_test_run) TYPE abap_bool.
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
    DATA ms_create_result TYPE zif_goods_movement_api=>ty_result.
    DATA ms_commit_result TYPE zif_goods_movement_api=>ty_commit_result.
    DATA mv_create_count TYPE i.
    DATA mv_commit_count TYPE i.
    DATA mv_cancel_count TYPE i.
    DATA mv_rollback_count TYPE i.
    DATA mv_test_run TYPE abap_bool.
    DATA mt_items TYPE zif_goods_movement_api=>ty_items.
    DATA mv_gm_code TYPE zif_goods_movement_api=>ty_gm_code.
    DATA ms_cancel_result TYPE zif_goods_movement_api=>ty_result.
    DATA mv_cancel_document TYPE zif_goods_movement_api=>ty_material_document.
    DATA mv_cancel_year TYPE zif_goods_movement_api=>ty_fiscal_year.
    DATA mv_cancel_posting_date TYPE d.
    DATA mt_cancel_item_numbers TYPE
      zif_goods_movement_api=>ty_material_document_items.
ENDCLASS.

CLASS lcl_goods_movement_api_double IMPLEMENTATION.
  METHOD set_create_result.
    ms_create_result = is_result.
  ENDMETHOD.

  METHOD set_commit_result.
    ms_commit_result = is_result.
  ENDMETHOD.

  METHOD set_cancel_result.
    ms_cancel_result = is_result.
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

  METHOD get_rollback_count.
    rv_count = mv_rollback_count.
  ENDMETHOD.

  METHOD get_last_items.
    rt_items = mt_items.
  ENDMETHOD.

  METHOD get_last_gm_code.
    rv_gm_code = mv_gm_code.
  ENDMETHOD.

  METHOD was_test_run.
    rv_test_run = mv_test_run.
  ENDMETHOD.

  METHOD zif_goods_movement_api~create_movement.
    ADD 1 TO mv_create_count.
    mv_test_run = iv_test_run.
    mt_items = it_items.
    mv_gm_code = iv_gm_code.
    rs_result = ms_create_result.
  ENDMETHOD.

  METHOD zif_goods_movement_api~cancel_movement.
    ADD 1 TO mv_cancel_count.
    mv_cancel_document = iv_material_document.
    mv_cancel_year = iv_fiscal_year.
    mv_cancel_posting_date = iv_posting_date.
    mt_cancel_item_numbers = it_item_numbers.
    rs_result = ms_cancel_result.
  ENDMETHOD.

  METHOD zif_goods_movement_api~commit.
    ADD 1 TO mv_commit_count.
    rs_result = ms_commit_result.
  ENDMETHOD.

  METHOD zif_goods_movement_api~rollback.
    ADD 1 TO mv_rollback_count.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_goods_movement_service DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_api TYPE REF TO lcl_goods_movement_api_double.
    DATA mo_cut TYPE REF TO zcl_goods_movement_service.
    METHODS setup.
    METHODS posts_and_commits FOR TESTING.
    METHODS simulates_without_commit FOR TESTING.
    METHODS rolls_back_create_error FOR TESTING.
    METHODS rolls_back_failed_api_result FOR TESTING.
    METHODS rejects_missing_cost_center FOR TESTING.
    METHODS rejects_missing_unit_iso FOR TESTING.
    METHODS posts_storage_transfer FOR TESTING.
    METHODS transfers_plant_allocation FOR TESTING.
    METHODS rejects_short_plant_transfer FOR TESTING.
    METHODS rejects_bad_transfer_split FOR TESTING.
    METHODS transfers_batch_allocation FOR TESTING.
    METHODS transfers_fefo_allocation FOR TESTING.
    METHODS rejects_short_batch_transfer FOR TESTING.
    METHODS rejects_bad_batch_split FOR TESTING.
    METHODS rejects_missing_transfer_batch FOR TESTING.
    METHODS transfers_unit_allocation FOR TESTING.
    METHODS transfers_unit_batch_alloc FOR TESTING.
    METHODS rejects_unit_mismatch FOR TESTING.
    METHODS transfers_fefo_unit_alloc FOR TESTING.
    METHODS rejects_fefo_units_mismatch FOR TESTING.
    METHODS posts_two_step_transfers FOR TESTING.
    METHODS rejects_incomplete_2step FOR TESTING.
    METHODS rejects_missing_transfer_to FOR TESTING.
    METHODS rejects_missing_target_plant FOR TESTING.
    METHODS posts_sales_order_issue FOR TESTING.
    METHODS rejects_unassigned_sales_issue FOR TESTING.
    METHODS posts_purchase_order_receipt FOR TESTING.
    METHODS posts_purchase_order_return FOR TESTING.
    METHODS rejects_incomplete_po_receipt FOR TESTING.
    METHODS rejects_wrong_po_receipt_code FOR TESTING.
    METHODS rejects_wrong_po_return_code FOR TESTING.
    METHODS rejects_mixed_receipt_items FOR TESTING.
    METHODS posts_prod_order_receipt FOR TESTING.
    METHODS rejects_prod_receipt_fields FOR TESTING.
    METHODS rejects_mixed_prod_receipts FOR TESTING.
    METHODS rolls_back_commit_error FOR TESTING.
    METHODS cancels_and_commits FOR TESTING.
    METHODS rejects_cancel_without_key FOR TESTING.
    METHODS rolls_back_cancel_error FOR TESTING.
    METHODS rejects_cancel_without_result FOR TESTING.
    METHODS rolls_back_cancel_commit_error FOR TESTING.
    METHODS cancels_selected_items FOR TESTING.
    METHODS rejects_duplicate_cancel_items FOR TESTING.
    METHODS rejects_blank_cancel_item FOR TESTING.
ENDCLASS.

CLASS ltcl_goods_movement_service IMPLEMENTATION.
  METHOD setup.
    mo_api = NEW lcl_goods_movement_api_double( ).
    mo_api->set_create_result(
      is_result = VALUE #(
        material_document = '4900000001'
        fiscal_year       = '2026'
        is_successful     = abap_true ) ).
    mo_api->set_commit_result(
      is_result = VALUE #( is_successful = abap_true ) ).
    mo_cut = NEW zcl_goods_movement_service( io_api = mo_api ).
  ENDMETHOD.

  METHOD posts_and_commits.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date       = '20260922'
      document_date      = '20260922'
      reference_document = 'ALLOC-1'
      header_text        = 'Stock allocation' ).
    DATA(lt_items) = VALUE zif_goods_movement_api=>ty_items(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        movement_type    = '201'
        quantity         = '2.000'
        entry_unit       = 'EA'
        entry_unit_iso   = 'EA'
        cost_center      = 'CC-1000' ) ).

    DATA(ls_result) = mo_cut->execute(
      is_header  = ls_header
      iv_gm_code = '03'
      it_items   = lt_items ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4900000001'
      act = ls_result-material_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD simulates_without_commit.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260922'
      document_date = '20260922' ).
    DATA(lt_items) = VALUE zif_goods_movement_api=>ty_items(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        movement_type    = '201'
        quantity         = '2.000'
        entry_unit       = 'EA'
        entry_unit_iso   = 'EA'
        cost_center      = 'CC-1000' ) ).

    DATA(ls_result) = mo_cut->execute(
      is_header   = ls_header
      iv_gm_code  = '03'
      it_items    = lt_items
      iv_test_run = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = mo_api->was_test_run( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_create_error.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260922'
      document_date = '20260922' ).
    DATA(lt_items) = VALUE zif_goods_movement_api=>ty_items(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        movement_type    = '201'
        quantity         = '2.000'
        entry_unit       = 'EA'
        entry_unit_iso   = 'EA'
        cost_center      = 'CC-1000' ) ).
    mo_api->set_create_result(
      is_result = VALUE #(
        messages = VALUE #(
          ( type = 'E' message = 'Invalid goods movement' ) ) ) ).

    DATA(ls_result) = mo_cut->execute(
      is_header  = ls_header
      iv_gm_code = '03'
      it_items   = lt_items ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rejects_missing_cost_center.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260922'
      document_date = '20260922' ).
    DATA(lt_items) = VALUE zif_goods_movement_api=>ty_items(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        movement_type    = '201'
        quantity         = '2.000'
        entry_unit       = 'EA'
        entry_unit_iso   = 'EA' ) ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->execute(
          is_header  = ls_header
          iv_gm_code = '03'
          it_items   = lt_items ).
      CATCH zcx_invalid_goods_movement.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_missing_unit_iso.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260922'
      document_date = '20260922' ).
    DATA(lt_items) = VALUE zif_goods_movement_api=>ty_items(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        movement_type    = '201'
        quantity         = '2.000'
        entry_unit       = 'EA'
        cost_center      = 'CC-1000' ) ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->execute(
          is_header  = ls_header
          iv_gm_code = '03'
          it_items   = lt_items ).
      CATCH zcx_invalid_goods_movement.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD posts_storage_transfer.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260922'
      document_date = '20260922' ).
    DATA(lt_items) = VALUE zif_goods_movement_api=>ty_items(
      ( material                   = 'MAT-1'
        plant                      = '1000'
        storage_location           = '0001'
        movement_type              = '311'
        quantity                   = '2.000'
        entry_unit                 = 'EA'
        entry_unit_iso             = 'EA'
        receiving_storage_location = '0002' ) ).

    DATA(ls_result) = mo_cut->execute(
      is_header  = ls_header
      iv_gm_code = '04'
      it_items   = lt_items ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD transfers_plant_allocation.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260923'
      document_date = '20260923' ).

    DATA(ls_result) = mo_cut->transfer_plant_allocation(
      is_header         = ls_header
      is_allocation     = VALUE #(
        allocations          = VALUE #(
          ( request_id         = 'REQ-1'
            material           = 'MAT-1'
            target_plant       = '2000'
            requested_quantity = '7.000'
            available_quantity = '7.000'
            allocated_quantity = '7.000'
            shortfall_quantity = '0.000' )
          ( request_id         = 'REQ-2'
            material           = 'MAT-2'
            target_plant       = '3000'
            requested_quantity = '3.000'
            available_quantity = '3.000'
            allocated_quantity = '3.000'
            shortfall_quantity = '0.000' ) )
        location_allocations = VALUE #(
          ( request_id         = 'REQ-1'
            material           = 'MAT-1'
            target_plant       = '2000'
            source_plant       = '1000'
            storage_location   = '0001'
            available_quantity = '3.000'
            allocated_quantity = '3.000' )
          ( request_id         = 'REQ-1'
            material           = 'MAT-1'
            target_plant       = '2000'
            source_plant       = '9000'
            storage_location   = '0002'
            available_quantity = '4.000'
            allocated_quantity = '4.000' )
          ( request_id         = 'REQ-2'
            material           = 'MAT-2'
            target_plant       = '3000'
            source_plant       = '1000'
            storage_location   = '0003'
            available_quantity = '3.000'
            allocated_quantity = '3.000' ) ) )
      it_destinations   = VALUE #(
        ( request_id = 'REQ-1' receiving_storage_location = '0009' )
        ( request_id = 'REQ-2' receiving_storage_location = '0010' ) )
      it_material_units = VALUE #(
        ( material = 'MAT-1' base_unit = 'EA' base_unit_iso = 'EA' )
        ( material = 'MAT-2' base_unit = 'KG' base_unit_iso = 'KGM' ) ) ).
    DATA(lt_items) = mo_api->get_last_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '04'
      act = mo_api->get_last_gm_code( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '301'
      act = lt_items[ 1 ]-movement_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = lt_items[ 1 ]-plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = lt_items[ 1 ]-receiving_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0009'
      act = lt_items[ 1 ]-receiving_storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_items[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'KG'
      act = lt_items[ 3 ]-entry_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'KGM'
      act = lt_items[ 3 ]-entry_unit_iso ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_short_plant_transfer.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260923'
      document_date = '20260923' ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->transfer_plant_allocation(
          is_header         = ls_header
          is_allocation     = VALUE #(
            allocations = VALUE #(
              ( request_id         = 'REQ-1'
                material           = 'MAT-1'
                target_plant       = '2000'
                requested_quantity = '5.000'
                available_quantity = '3.000'
                allocated_quantity = '3.000'
                shortfall_quantity = '2.000' ) ) )
          it_destinations   = VALUE #( )
          it_material_units = VALUE #( ) ).
      CATCH zcx_invalid_goods_movement.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_transfer_split.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260923'
      document_date = '20260923' ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->transfer_plant_allocation(
          is_header         = ls_header
          is_allocation     = VALUE #(
            allocations          = VALUE #(
              ( request_id         = 'REQ-1'
                material           = 'MAT-1'
                target_plant       = '2000'
                requested_quantity = '5.000'
                available_quantity = '5.000'
                allocated_quantity = '5.000'
                shortfall_quantity = '0.000' ) )
            location_allocations = VALUE #(
              ( request_id         = 'REQ-1'
                material           = 'MAT-1'
                target_plant       = '2000'
                source_plant       = '1000'
                storage_location   = '0001'
                available_quantity = '5.000'
                allocated_quantity = '4.000' ) ) )
          it_destinations   = VALUE #(
            ( request_id = 'REQ-1' receiving_storage_location = '0009' ) )
          it_material_units = VALUE #(
            ( material = 'MAT-1' base_unit = 'EA' base_unit_iso = 'EA' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD transfers_batch_allocation.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260923'
      document_date = '20260923' ).

    DATA(ls_result) = mo_cut->transfer_plant_batch_alloc(
      is_header         = ls_header
      is_allocation     = VALUE #(
        allocations          = VALUE #(
          ( request_id         = 'REQ-1'
            material           = 'MAT-1'
            target_plant       = '2000'
            batch              = 'B-1'
            requested_quantity = '3.000'
            available_quantity = '3.000'
            allocated_quantity = '3.000'
            shortfall_quantity = '0.000' ) )
        location_allocations = VALUE #(
          ( request_id         = 'REQ-1'
            material           = 'MAT-1'
            target_plant       = '2000'
            source_plant       = '1000'
            storage_location   = '0001'
            batch              = 'B-1'
            expiration_date    = '20261231'
            available_quantity = '3.000'
            allocated_quantity = '3.000' ) ) )
      it_destinations   = VALUE #(
        ( request_id = 'REQ-1' receiving_storage_location = '0009' ) )
      it_material_units = VALUE #(
        ( material = 'MAT-1' base_unit = 'EA' base_unit_iso = 'EA' ) ) ).
    DATA(lt_items) = mo_api->get_last_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = lt_items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '301'
      act = lt_items[ 1 ]-movement_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD transfers_fefo_allocation.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260923'
      document_date = '20260923' ).

    DATA(ls_result) = mo_cut->transfer_plant_fefo_alloc(
      is_header         = ls_header
      is_allocation     = VALUE #(
        allocations       = VALUE #(
          ( request_id         = 'REQ-1'
            material           = 'MAT-1'
            target_plant       = '2000'
            requested_quantity = '5.000'
            available_quantity = '5.000'
            allocated_quantity = '5.000'
            shortfall_quantity = '0.000' ) )
        batch_allocations = VALUE #(
          ( request_id         = 'REQ-1'
            material           = 'MAT-1'
            target_plant       = '2000'
            source_plant       = '1000'
            storage_location   = '0001'
            batch              = 'B-EARLY'
            expiration_date    = '20261001'
            available_quantity = '3.000'
            allocated_quantity = '3.000' )
          ( request_id         = 'REQ-1'
            material           = 'MAT-1'
            target_plant       = '2000'
            source_plant       = '9000'
            storage_location   = '0002'
            batch              = 'B-LATER'
            expiration_date    = '20261010'
            available_quantity = '2.000'
            allocated_quantity = '2.000' ) ) )
      it_destinations   = VALUE #(
        ( request_id = 'REQ-1' receiving_storage_location = '0009' ) )
      it_material_units = VALUE #(
        ( material = 'MAT-1' base_unit = 'EA' base_unit_iso = 'EA' ) ) ).
    DATA(lt_items) = mo_api->get_last_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EARLY'
      act = lt_items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = lt_items[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '9000'
      act = lt_items[ 2 ]-plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_items[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_short_batch_transfer.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260923'
      document_date = '20260923' ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->transfer_plant_batch_alloc(
          is_header         = ls_header
          is_allocation     = VALUE #(
            allocations = VALUE #(
              ( request_id         = 'REQ-1'
                material           = 'MAT-1'
                target_plant       = '2000'
                batch              = 'B-1'
                requested_quantity = '5.000'
                available_quantity = '3.000'
                allocated_quantity = '3.000'
                shortfall_quantity = '2.000' ) ) )
          it_destinations   = VALUE #( )
          it_material_units = VALUE #( ) ).
      CATCH zcx_invalid_goods_movement.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_batch_split.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260923'
      document_date = '20260923' ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->transfer_plant_batch_alloc(
          is_header         = ls_header
          is_allocation     = VALUE #(
            allocations          = VALUE #(
              ( request_id         = 'REQ-1'
                material           = 'MAT-1'
                target_plant       = '2000'
                batch              = 'B-1'
                requested_quantity = '5.000'
                available_quantity = '5.000'
                allocated_quantity = '5.000'
                shortfall_quantity = '0.000' ) )
            location_allocations = VALUE #(
              ( request_id         = 'REQ-1'
                material           = 'MAT-1'
                target_plant       = '2000'
                source_plant       = '1000'
                storage_location   = '0001'
                batch              = 'B-1'
                available_quantity = '5.000'
                allocated_quantity = '4.000' ) ) )
          it_destinations   = VALUE #(
            ( request_id = 'REQ-1' receiving_storage_location = '0009' ) )
          it_material_units = VALUE #(
            ( material = 'MAT-1' base_unit = 'EA' base_unit_iso = 'EA' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_missing_transfer_batch.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260923'
      document_date = '20260923' ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->transfer_plant_fefo_alloc(
          is_header         = ls_header
          is_allocation     = VALUE #(
            allocations       = VALUE #(
              ( request_id         = 'REQ-1'
                material           = 'MAT-1'
                target_plant       = '2000'
                requested_quantity = '1.000'
                available_quantity = '1.000'
                allocated_quantity = '1.000'
                shortfall_quantity = '0.000' ) )
            batch_allocations = VALUE #(
              ( request_id         = 'REQ-1'
                material           = 'MAT-1'
                target_plant       = '2000'
                source_plant       = '1000'
                storage_location   = '0001'
                available_quantity = '1.000'
                allocated_quantity = '1.000' ) ) )
          it_destinations   = VALUE #(
            ( request_id = 'REQ-1' receiving_storage_location = '0009' ) )
          it_material_units = VALUE #(
            ( material = 'MAT-1' base_unit = 'EA' base_unit_iso = 'EA' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD transfers_unit_allocation.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260923'
      document_date = '20260923' ).

    DATA(ls_result) = mo_cut->transfer_plant_units_alloc(
      is_header         = ls_header
      is_allocation     = VALUE #(
        allocations          = VALUE #(
          ( allocation = VALUE #(
              request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              requested_quantity = '24.000'
              available_quantity = '24.000'
              allocated_quantity = '24.000'
              shortfall_quantity = '0.000' )
            base_unit  = 'EA' ) )
        location_allocations = VALUE #(
          ( allocation                = VALUE #(
              request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              source_plant       = '2000'
              storage_location   = '0001'
              available_quantity = '10.000'
              allocated_quantity = '10.000' )
            base_unit                 = 'EA'
            available_source_quantity = '0.833'
            allocated_source_quantity = '0.833' )
          ( allocation                = VALUE #(
              request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              source_plant       = '2000'
              storage_location   = '0002'
              available_quantity = '14.000'
              allocated_quantity = '14.000' )
            base_unit                 = 'EA'
            available_source_quantity = '1.167'
            allocated_source_quantity = '1.167' ) ) )
      it_destinations   = VALUE #(
        ( request_id = 'REQ-1' receiving_storage_location = '0009' ) )
      it_material_units = VALUE #(
        ( material = 'MAT-1' base_unit = 'EA' base_unit_iso = 'EA' ) ) ).
    DATA(lt_items) = mo_api->get_last_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lt_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '14.000' )
      act = lt_items[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_items[ 1 ]-entry_unit ).
  ENDMETHOD.

  METHOD transfers_unit_batch_alloc.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260923'
      document_date = '20260923' ).

    DATA(ls_result) = mo_cut->transfer_plant_batch_units(
      is_header         = ls_header
      is_allocation     = VALUE #(
        allocations          = VALUE #(
          ( allocation                = VALUE #(
              request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              batch              = 'B-1'
              requested_quantity = '12.000'
              available_quantity = '12.000'
              allocated_quantity = '12.000'
              shortfall_quantity = '0.000' )
            base_unit                 = 'EA'
            source_quantity           = '1.000'
            source_unit               = 'BOX'
            base_quantity             = '12.000'
            allocated_source_quantity = '1.000' ) )
        location_allocations = VALUE #(
          ( allocation                = VALUE #(
              request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              source_plant       = '2000'
              storage_location   = '0001'
              batch              = 'B-1'
              available_quantity = '12.000'
              allocated_quantity = '12.000' )
            base_unit                 = 'EA'
            available_source_quantity = '1.000'
            allocated_source_quantity = '1.000' ) ) )
      it_destinations   = VALUE #(
        ( request_id = 'REQ-1' receiving_storage_location = '0009' ) )
      it_material_units = VALUE #(
        ( material = 'MAT-1' base_unit = 'EA' base_unit_iso = 'EA' ) ) ).
    DATA(lt_items) = mo_api->get_last_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = lt_items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = lt_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_items[ 1 ]-entry_unit ).
  ENDMETHOD.

  METHOD rejects_unit_mismatch.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260923'
      document_date = '20260923' ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->transfer_plant_units_alloc(
          is_header         = ls_header
          is_allocation     = VALUE #(
            allocations          = VALUE #(
              ( allocation = VALUE #(
                  request_id         = 'REQ-1'
                  material           = 'MAT-1'
                  target_plant       = '9000'
                  requested_quantity = '12.000'
                  available_quantity = '12.000'
                  allocated_quantity = '12.000'
                  shortfall_quantity = '0.000' )
                base_unit  = 'BOX' ) )
            location_allocations = VALUE #(
              ( allocation = VALUE #(
                  request_id         = 'REQ-1'
                  material           = 'MAT-1'
                  target_plant       = '9000'
                  source_plant       = '2000'
                  storage_location   = '0001'
                  available_quantity = '12.000'
                  allocated_quantity = '12.000' )
                base_unit  = 'EA' ) ) )
          it_destinations   = VALUE #(
            ( request_id = 'REQ-1' receiving_storage_location = '0009' ) )
          it_material_units = VALUE #(
            ( material = 'MAT-1' base_unit = 'EA' base_unit_iso = 'EA' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD transfers_fefo_unit_alloc.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260923'
      document_date = '20260923' ).

    DATA(ls_result) = mo_cut->transfer_plant_fefo_units(
      is_header         = ls_header
      is_allocation     = VALUE #(
        allocations       = VALUE #(
          ( allocation                = VALUE #(
              request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              requested_quantity = '12.000'
              available_quantity = '12.000'
              allocated_quantity = '12.000'
              shortfall_quantity = '0.000' )
            base_unit                 = 'EA'
            source_quantity           = '1.000'
            source_unit               = 'BOX'
            base_quantity             = '12.000'
            allocated_source_quantity = '1.000' ) )
        batch_allocations = VALUE #(
          ( allocation                = VALUE #(
              request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              source_plant       = '2000'
              storage_location   = '0001'
              batch              = 'B-EARLY'
              expiration_date    = '20261001'
              available_quantity = '7.000'
              allocated_quantity = '7.000' )
            source_unit               = 'BOX'
            base_unit                 = 'EA'
            available_source_quantity = '0.583'
            allocated_source_quantity = '0.583' )
          ( allocation                = VALUE #(
              request_id         = 'REQ-1'
              material           = 'MAT-1'
              target_plant       = '9000'
              source_plant       = '1000'
              storage_location   = '0002'
              batch              = 'B-LATER'
              expiration_date    = '20261010'
              available_quantity = '5.000'
              allocated_quantity = '5.000' )
            source_unit               = 'BOX'
            base_unit                 = 'EA'
            available_source_quantity = '0.417'
            allocated_source_quantity = '0.417' ) ) )
      it_destinations   = VALUE #(
        ( request_id = 'REQ-1' receiving_storage_location = '0009' ) )
      it_material_units = VALUE #(
        ( material = 'MAT-1' base_unit = 'EA' base_unit_iso = 'EA' ) ) ).
    DATA(lt_items) = mo_api->get_last_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '04'
      act = mo_api->get_last_gm_code( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EARLY'
      act = lt_items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = lt_items[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '7.000' )
      act = lt_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lt_items[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_items[ 1 ]-entry_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_fefo_units_mismatch.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260923'
      document_date = '20260923' ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->transfer_plant_fefo_units(
          is_header         = ls_header
          is_allocation     = VALUE #(
            allocations       = VALUE #(
              ( allocation = VALUE #(
                  request_id         = 'REQ-1'
                  material           = 'MAT-1'
                  target_plant       = '9000'
                  requested_quantity = '1.000'
                  available_quantity = '1.000'
                  allocated_quantity = '1.000'
                  shortfall_quantity = '0.000' )
                base_unit  = 'BOX' ) )
            batch_allocations = VALUE #(
              ( allocation = VALUE #(
                  request_id         = 'REQ-1'
                  material           = 'MAT-1'
                  target_plant       = '9000'
                  source_plant       = '2000'
                  storage_location   = '0001'
                  batch              = 'B-1'
                  available_quantity = '1.000'
                  allocated_quantity = '1.000' )
                base_unit  = 'EA' ) ) )
          it_destinations   = VALUE #(
            ( request_id = 'REQ-1' receiving_storage_location = '0009' ) )
          it_material_units = VALUE #(
            ( material = 'MAT-1' base_unit = 'EA' base_unit_iso = 'EA' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD posts_two_step_transfers.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260923'
      document_date = '20260923' ).
    DATA(lt_items) = VALUE zif_goods_movement_api=>ty_items(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        movement_type    = '303'
        quantity         = '2.000'
        entry_unit       = 'EA'
        entry_unit_iso   = 'EA'
        receiving_plant  = '2000' ) ).

    DATA(ls_result_303) = mo_cut->execute(
      is_header  = ls_header
      iv_gm_code = '04'
      it_items   = lt_items ).

    lt_items = VALUE #(
      ( material         = 'MAT-1'
        plant            = '2000'
        storage_location = '0002'
        movement_type    = '305'
        quantity         = '2.000'
        entry_unit       = 'EA'
        entry_unit_iso   = 'EA' ) ).
    DATA(ls_result_305) = mo_cut->execute(
      is_header  = ls_header
      iv_gm_code = '04'
      it_items   = lt_items ).

    lt_items = VALUE #(
      ( material                   = 'MAT-1'
        plant                      = '1000'
        storage_location           = '0001'
        movement_type              = '313'
        quantity                   = '2.000'
        entry_unit                 = 'EA'
        entry_unit_iso             = 'EA'
        receiving_storage_location = '0002' ) ).
    DATA(ls_result_313) = mo_cut->execute(
      is_header  = ls_header
      iv_gm_code = '04'
      it_items   = lt_items ).

    lt_items = VALUE #(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0002'
        movement_type    = '315'
        quantity         = '2.000'
        entry_unit       = 'EA'
        entry_unit_iso   = 'EA' ) ).
    DATA(ls_result_315) = mo_cut->execute(
      is_header  = ls_header
      iv_gm_code = '04'
      it_items   = lt_items ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result_303-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result_305-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result_313-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result_315-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_incomplete_2step.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260923'
      document_date = '20260923' ).
    DATA(lt_items) = VALUE zif_goods_movement_api=>ty_items(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        movement_type    = '303'
        quantity         = '2.000'
        entry_unit       = 'EA'
        entry_unit_iso   = 'EA' ) ).
    DATA lv_plant_exception TYPE abap_bool.
    DATA lv_sloc_exception TYPE abap_bool.

    TRY.
        mo_cut->execute(
          is_header  = ls_header
          iv_gm_code = '04'
          it_items   = lt_items ).
      CATCH zcx_invalid_goods_movement.
        lv_plant_exception = abap_true.
    ENDTRY.

    lt_items = VALUE #(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        movement_type    = '313'
        quantity         = '2.000'
        entry_unit       = 'EA'
        entry_unit_iso   = 'EA' ) ).
    TRY.
        mo_cut->execute(
          is_header  = ls_header
          iv_gm_code = '04'
          it_items   = lt_items ).
      CATCH zcx_invalid_goods_movement.
        lv_sloc_exception = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_plant_exception ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_sloc_exception ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_missing_transfer_to.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260922'
      document_date = '20260922' ).
    DATA(lt_items) = VALUE zif_goods_movement_api=>ty_items(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        movement_type    = '311'
        quantity         = '2.000'
        entry_unit       = 'EA'
        entry_unit_iso   = 'EA' ) ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->execute(
          is_header  = ls_header
          iv_gm_code = '04'
          it_items   = lt_items ).
      CATCH zcx_invalid_goods_movement.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_missing_target_plant.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260922'
      document_date = '20260922' ).
    DATA(lt_items) = VALUE zif_goods_movement_api=>ty_items(
      ( material                   = 'MAT-1'
        plant                      = '1000'
        storage_location           = '0001'
        movement_type              = '301'
        quantity                   = '2.000'
        entry_unit                 = 'EA'
        entry_unit_iso             = 'EA'
        receiving_storage_location = '0002' ) ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->execute(
          is_header  = ls_header
          iv_gm_code = '04'
          it_items   = lt_items ).
      CATCH zcx_invalid_goods_movement.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD posts_sales_order_issue.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260922'
      document_date = '20260922' ).
    DATA(lt_items) = VALUE zif_goods_movement_api=>ty_items(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        movement_type    = '231'
        quantity         = '2.000'
        entry_unit       = 'EA'
        entry_unit_iso   = 'EA'
        sales_order      = '0000004711'
        sales_order_item = '000010' ) ).

    DATA(ls_result) = mo_cut->execute(
      is_header  = ls_header
      iv_gm_code = '03'
      it_items   = lt_items ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_unassigned_sales_issue.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260922'
      document_date = '20260922' ).
    DATA(lt_items) = VALUE zif_goods_movement_api=>ty_items(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        movement_type    = '231'
        quantity         = '2.000'
        entry_unit       = 'EA'
        entry_unit_iso   = 'EA'
        sales_order      = '0000004711' ) ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->execute(
          is_header  = ls_header
          iv_gm_code = '03'
          it_items   = lt_items ).
      CATCH zcx_invalid_goods_movement.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD posts_purchase_order_receipt.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260922'
      document_date = '20260922' ).
    DATA(lt_items) = VALUE zif_goods_movement_api=>ty_items(
      ( movement_type       = '101'
        quantity            = '4.000'
        entry_unit          = 'EA'
        entry_unit_iso      = 'EA'
        movement_indicator  = 'B'
        purchase_order      = '4500000123'
        purchase_order_item = '00010' ) ).

    DATA(ls_result) = mo_cut->execute(
      is_header  = ls_header
      iv_gm_code = '01'
      it_items   = lt_items ).
    DATA(lt_posted_items) = mo_api->get_last_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '01'
      act = mo_api->get_last_gm_code( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000123'
      act = lt_posted_items[ 1 ]-purchase_order ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00010'
      act = lt_posted_items[ 1 ]-purchase_order_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B'
      act = lt_posted_items[ 1 ]-movement_indicator ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD posts_purchase_order_return.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260923'
      document_date = '20260923' ).
    DATA(lt_items) = VALUE zif_goods_movement_api=>ty_items(
      ( movement_type       = '122'
        quantity            = '2.000'
        entry_unit          = 'EA'
        entry_unit_iso      = 'EA'
        movement_indicator  = 'B'
        purchase_order      = '4500000123'
        purchase_order_item = '00010' ) ).

    DATA(ls_result) = mo_cut->execute(
      is_header  = ls_header
      iv_gm_code = '01'
      it_items   = lt_items ).
    DATA(lt_posted_items) = mo_api->get_last_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '01'
      act = mo_api->get_last_gm_code( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '122'
      act = lt_posted_items[ 1 ]-movement_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B'
      act = lt_posted_items[ 1 ]-movement_indicator ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000123'
      act = lt_posted_items[ 1 ]-purchase_order ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_incomplete_po_receipt.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260922'
      document_date = '20260922' ).
    DATA(lt_items) = VALUE zif_goods_movement_api=>ty_items(
      ( movement_type      = '101'
        quantity           = '4.000'
        entry_unit         = 'EA'
        entry_unit_iso     = 'EA'
        movement_indicator = 'B'
        purchase_order     = '4500000123' ) ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->execute(
          is_header  = ls_header
          iv_gm_code = '01'
          it_items   = lt_items ).
      CATCH zcx_invalid_goods_movement.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_mixed_receipt_items.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260922'
      document_date = '20260922' ).
    DATA(lt_items) = VALUE zif_goods_movement_api=>ty_items(
      ( movement_type       = '101'
        quantity            = '4.000'
        entry_unit          = 'EA'
        entry_unit_iso      = 'EA'
        movement_indicator  = 'B'
        purchase_order      = '4500000123'
        purchase_order_item = '00010' )
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        movement_type    = '201'
        quantity         = '1.000'
        entry_unit       = 'EA'
        entry_unit_iso   = 'EA'
        cost_center      = 'CC-1000' ) ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->execute(
          is_header  = ls_header
          iv_gm_code = '01'
          it_items   = lt_items ).
      CATCH zcx_invalid_goods_movement.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD posts_prod_order_receipt.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260922'
      document_date = '20260922' ).
    DATA(lt_items) = VALUE zif_goods_movement_api=>ty_items(
      ( movement_type      = '101'
        quantity           = '4.000'
        entry_unit         = 'EA'
        entry_unit_iso     = 'EA'
        order_id           = '000001234567'
        movement_indicator = 'F' ) ).

    DATA(ls_result) = mo_cut->execute(
      is_header  = ls_header
      iv_gm_code = '02'
      it_items   = lt_items ).
    DATA(lt_posted_items) = mo_api->get_last_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '02'
      act = mo_api->get_last_gm_code( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '000001234567'
      act = lt_posted_items[ 1 ]-order_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'F'
      act = lt_posted_items[ 1 ]-movement_indicator ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_prod_receipt_fields.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260922'
      document_date = '20260922' ).
    DATA(lt_items) = VALUE zif_goods_movement_api=>ty_items(
      ( movement_type  = '101'
        quantity       = '4.000'
        entry_unit     = 'EA'
        entry_unit_iso = 'EA'
        order_id       = '000001234567' ) ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->execute(
          is_header  = ls_header
          iv_gm_code = '02'
          it_items   = lt_items ).
      CATCH zcx_invalid_goods_movement.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_mixed_prod_receipts.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260922'
      document_date = '20260922' ).
    DATA(lt_items) = VALUE zif_goods_movement_api=>ty_items(
      ( movement_type      = '101'
        quantity           = '4.000'
        entry_unit         = 'EA'
        entry_unit_iso     = 'EA'
        order_id           = '000001234567'
        movement_indicator = 'F' )
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        movement_type    = '201'
        quantity         = '1.000'
        entry_unit       = 'EA'
        entry_unit_iso   = 'EA'
        cost_center      = 'CC-1000' ) ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->execute(
          is_header  = ls_header
          iv_gm_code = '02'
          it_items   = lt_items ).
      CATCH zcx_invalid_goods_movement.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_wrong_po_receipt_code.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260922'
      document_date = '20260922' ).
    DATA(lt_items) = VALUE zif_goods_movement_api=>ty_items(
      ( movement_type       = '101'
        quantity            = '4.000'
        entry_unit          = 'EA'
        entry_unit_iso      = 'EA'
        movement_indicator  = 'B'
        purchase_order      = '4500000123'
        purchase_order_item = '00010' ) ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->execute(
          is_header  = ls_header
          iv_gm_code = '03'
          it_items   = lt_items ).
      CATCH zcx_invalid_goods_movement.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_wrong_po_return_code.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260923'
      document_date = '20260923' ).
    DATA(lt_items) = VALUE zif_goods_movement_api=>ty_items(
      ( movement_type       = '122'
        quantity            = '2.000'
        entry_unit          = 'EA'
        entry_unit_iso      = 'EA'
        movement_indicator  = 'B'
        purchase_order      = '4500000123'
        purchase_order_item = '00010' ) ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->execute(
          is_header  = ls_header
          iv_gm_code = '03'
          it_items   = lt_items ).
      CATCH zcx_invalid_goods_movement.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_failed_api_result.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260922'
      document_date = '20260922' ).
    DATA(lt_items) = VALUE zif_goods_movement_api=>ty_items(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        movement_type    = '201'
        quantity         = '2.000'
        entry_unit       = 'EA'
        entry_unit_iso   = 'EA'
        cost_center      = 'CC-1000' ) ).
    mo_api->set_create_result(
      is_result = VALUE #( is_successful = abap_false ) ).

    DATA(ls_result) = mo_cut->execute(
      is_header  = ls_header
      iv_gm_code = '03'
      it_items   = lt_items ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_commit_error.
    DATA(ls_header) = VALUE zif_goods_movement_api=>ty_header(
      posting_date  = '20260922'
      document_date = '20260922' ).
    DATA(lt_items) = VALUE zif_goods_movement_api=>ty_items(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        movement_type    = '201'
        quantity         = '2.000'
        entry_unit       = 'EA'
        entry_unit_iso   = 'EA'
        cost_center      = 'CC-1000' ) ).
    mo_api->set_commit_result(
      is_result = VALUE #(
        is_successful = abap_false
        message       = VALUE #(
          type    = 'E'
          message = 'Commit failed' ) ) ).

    DATA(ls_result) = mo_cut->execute(
      is_header  = ls_header
      iv_gm_code = '03'
      it_items   = lt_items ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD cancels_and_commits.
    mo_api->set_cancel_result(
      is_result = VALUE #(
        material_document = '4900000002'
        fiscal_year       = '2026'
        is_successful     = abap_true ) ).

    DATA(ls_result) = mo_cut->cancel(
      iv_material_document = '4900000001'
      iv_fiscal_year       = '2026'
      iv_posting_date      = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4900000002'
      act = ls_result-material_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4900000001'
      act = mo_api->get_last_cancel_document( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2026'
      act = mo_api->get_last_cancel_year( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20260923'
      act = mo_api->get_last_cancel_posting_date( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( mo_api->get_last_cancel_items( ) ) ).
  ENDMETHOD.

  METHOD rejects_cancel_without_key.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->cancel(
          iv_material_document = '4900000001'
          iv_fiscal_year       = '' ).
      CATCH zcx_invalid_goods_movement.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_cancel_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_cancel_error.
    mo_api->set_cancel_result(
      is_result = VALUE #(
        messages      = VALUE #(
          ( type = 'E' message = 'Document cannot be canceled' ) )
        is_successful = abap_false ) ).

    DATA(ls_result) = mo_cut->cancel(
      iv_material_document = '4900000001'
      iv_fiscal_year       = '2026' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rejects_cancel_without_result.
    mo_api->set_cancel_result(
      is_result = VALUE #( is_successful = abap_true ) ).

    DATA(ls_result) = mo_cut->cancel(
      iv_material_document = '4900000001'
      iv_fiscal_year       = '2026' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_cancel_commit_error.
    mo_api->set_cancel_result(
      is_result = VALUE #(
        material_document = '4900000002'
        fiscal_year       = '2026'
        is_successful     = abap_true ) ).
    mo_api->set_commit_result(
      is_result = VALUE #(
        is_successful = abap_false
        message       = VALUE #(
          type    = 'E'
          message = 'Commit failed' ) ) ).

    DATA(ls_result) = mo_cut->cancel(
      iv_material_document = '4900000001'
      iv_fiscal_year       = '2026' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD cancels_selected_items.
    DATA lt_item_numbers TYPE
      zif_goods_movement_api=>ty_material_document_items.
    APPEND '0001' TO lt_item_numbers.
    APPEND '0003' TO lt_item_numbers.
    mo_api->set_cancel_result(
      is_result = VALUE #(
        material_document = '4900000002'
        fiscal_year       = '2026'
        is_successful     = abap_true ) ).

    DATA(ls_result) = mo_cut->cancel(
      iv_material_document = '4900000001'
      iv_fiscal_year       = '2026'
      it_item_numbers      = lt_item_numbers ).
    DATA(lt_cancelled_items) = mo_api->get_last_cancel_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_cancelled_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_cancelled_items[ 1 ] ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = lt_cancelled_items[ 2 ] ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_duplicate_cancel_items.
    DATA lt_item_numbers TYPE
      zif_goods_movement_api=>ty_material_document_items.
    APPEND '0001' TO lt_item_numbers.
    APPEND '0001' TO lt_item_numbers.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->cancel(
          iv_material_document = '4900000001'
          iv_fiscal_year       = '2026'
          it_item_numbers      = lt_item_numbers ).
      CATCH zcx_invalid_goods_movement.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_cancel_count( ) ).
  ENDMETHOD.

  METHOD rejects_blank_cancel_item.
    DATA lt_item_numbers TYPE
      zif_goods_movement_api=>ty_material_document_items.
    APPEND INITIAL LINE TO lt_item_numbers.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->cancel(
          iv_material_document = '4900000001'
          iv_fiscal_year       = '2026'
          it_item_numbers      = lt_item_numbers ).
      CATCH zcx_invalid_goods_movement.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_cancel_count( ) ).
  ENDMETHOD.
ENDCLASS.
