CLASS lcl_quality_stock_repository DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_repository.
    DATA mt_quality_stock TYPE
      zif_stock_repository=>ty_batch_stock_statuses.
    DATA mt_recheck_quality_stock TYPE
      zif_stock_repository=>ty_batch_stock_statuses.
    DATA mt_unrestricted_stock TYPE zif_stock_repository=>ty_batch_stocks.
    DATA mt_recheck_unrestricted_stock TYPE
      zif_stock_repository=>ty_batch_stocks.
    DATA mv_use_recheck_quality_stock TYPE abap_bool.
    DATA mv_use_recheck_unrestricted TYPE abap_bool.
    DATA mv_batch_status_reads TYPE i.
    DATA mv_unrestricted_stock_reads TYPE i.
    METHODS get_batch_status_read_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_unrestricted_read_count
      RETURNING
        VALUE(rv_count) TYPE i.
ENDCLASS.

CLASS lcl_quality_stock_repository IMPLEMENTATION.
  METHOD get_batch_status_read_count.
    rv_count = mv_batch_status_reads.
  ENDMETHOD.

  METHOD get_unrestricted_read_count.
    rv_count = mv_unrestricted_stock_reads.
  ENDMETHOD.

  METHOD zif_stock_repository~get_unrestricted_stock.
  ENDMETHOD.

  METHOD zif_stock_repository~get_available_stock_by_date.
  ENDMETHOD.

  METHOD zif_stock_repository~get_available_stock_date_bulk.
    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        request_id    = ls_request-request_id
        material      = ls_request-material
        plant         = ls_request-plant
        required_date = ls_request-required_date ) TO rt_results.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_projected_receipts.
  ENDMETHOD.

  METHOD zif_stock_repository~get_projected_receipts_bulk.
    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        request_id   = ls_request-request_id
        material     = ls_request-material
        plant        = ls_request-plant
        through_date = ls_request-through_date ) TO rt_results.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_po_confirmed_receipts.
  ENDMETHOD.

  METHOD zif_stock_repository~get_po_confirmed_receipts_bulk.
    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        request_id   = ls_request-request_id
        material     = ls_request-material
        plant        = ls_request-plant
        through_date = ls_request-through_date ) TO rt_results.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_safety_stock.
  ENDMETHOD.

  METHOD zif_stock_repository~get_safety_stock_bulk.
    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        request_id = ls_request-request_id
        material   = ls_request-material
        plant      = ls_request-plant )
        TO rt_status.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_sales_order_reservations.
  ENDMETHOD.

  METHOD zif_stock_repository~get_order_reservations_bulk.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status_bulk.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status_by_location.
  ENDMETHOD.

  METHOD zif_stock_repository~get_location_stock_status_bulk.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_status_by_batch.
    rt_status = mt_quality_stock.
  ENDMETHOD.

  METHOD zif_stock_repository~get_batch_stock_status_bulk.
    DATA lt_batches TYPE zif_stock_repository=>ty_batch_stock_statuses.
    READ TABLE it_requests INTO DATA(ls_first_request) INDEX 1.
    IF sy-subrc = 0 AND ls_first_request-request_id CP 'QF*'.
      ADD 1 TO mv_batch_status_reads.
    ELSEIF sy-subrc = 0.
      ADD 1 TO mv_unrestricted_stock_reads.
    ENDIF.
    LOOP AT it_requests INTO DATA(ls_request).
      CLEAR lt_batches.
      IF ls_request-request_id CP 'QF*'.
        lt_batches = mt_quality_stock.
        IF mv_use_recheck_quality_stock = abap_true
            AND mv_batch_status_reads > 1.
          lt_batches = mt_recheck_quality_stock.
        ENDIF.
      ELSE.
        DATA(lt_unrestricted_stock) = mt_unrestricted_stock.
        IF mv_use_recheck_unrestricted = abap_true
            AND mv_unrestricted_stock_reads > 1.
          lt_unrestricted_stock = mt_recheck_unrestricted_stock.
        ENDIF.
        LOOP AT lt_unrestricted_stock INTO DATA(ls_unrestricted_stock).
          APPEND VALUE #(
            storage_location      = ls_unrestricted_stock-storage_location
            batch                 = ls_unrestricted_stock-batch
            expiration_date       = ls_unrestricted_stock-expiration_date
            unrestricted_quantity = ls_unrestricted_stock-available_quantity
            available_quantity    = ls_unrestricted_stock-available_quantity )
            TO lt_batches.
        ENDLOOP.
      ENDIF.
      APPEND VALUE #(
        request_id = ls_request-request_id
        material   = ls_request-material
        plant      = ls_request-plant
        batches    = lt_batches ) TO rt_status.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_by_location.
  ENDMETHOD.

  METHOD zif_stock_repository~get_stock_by_batch.
    ADD 1 TO mv_unrestricted_stock_reads.
    IF mv_use_recheck_unrestricted = abap_true
        AND mv_unrestricted_stock_reads > 1.
      rt_stock = mt_recheck_unrestricted_stock.
    ELSE.
      rt_stock = mt_unrestricted_stock.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_repository~get_open_stock_reservations.
  ENDMETHOD.

  METHOD zif_stock_repository~get_open_stock_res_bulk.
    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        request_id = ls_request-request_id
        material   = ls_request-material
        plant      = ls_request-plant )
        TO rt_status.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_quality_uom_repository DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_material_uom_repository.
    DATA mv_read_count TYPE i.
    METHODS get_read_count
      RETURNING
        VALUE(rv_count) TYPE i.
ENDCLASS.

CLASS lcl_quality_uom_repository IMPLEMENTATION.
  METHOD get_read_count.
    rv_count = mv_read_count.
  ENDMETHOD.

  METHOD zif_material_uom_repository~get_base_unit.
    ADD 1 TO mv_read_count.
    IF iv_material = 'MAT-1'.
      rv_base_unit = 'EA'.
    ENDIF.
  ENDMETHOD.

  METHOD zif_material_uom_repository~get_alt_unit_ratio.
    ADD 1 TO mv_read_count.
    IF iv_material = 'MAT-1' AND iv_alternative_unit = 'BOX'.
      rs_ratio-numerator = 2.
      rs_ratio-denominator = 1.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_quality_goods_movement_api DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_goods_movement_api.
    DATA mt_last_items TYPE zif_goods_movement_api=>ty_items.
    DATA mv_create_calls TYPE i.
ENDCLASS.

CLASS lcl_quality_goods_movement_api IMPLEMENTATION.
  METHOD zif_goods_movement_api~create_movement.
    ADD 1 TO mv_create_calls.
    mt_last_items = it_items.
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

CLASS ltcl_quality_stock_service DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.
  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO lcl_quality_stock_repository.
    DATA mo_uom_repository TYPE REF TO lcl_quality_uom_repository.
    DATA mo_stock_service TYPE REF TO zcl_stock_service.
    DATA mo_api TYPE REF TO lcl_quality_goods_movement_api.
    DATA mo_goods_movement_service TYPE REF TO zcl_goods_movement_service.
    DATA mo_cut TYPE REF TO zcl_quality_stock_service.
    METHODS setup.
    METHODS get_demands
      RETURNING
        VALUE(rt_demands) TYPE zcl_stock_service=>ty_unit_fefo_demands.
    METHODS get_priority_demands
      RETURNING
        VALUE(rt_demands) TYPE
          zcl_stock_service=>ty_priority_unit_fefo_demands.
    METHODS get_material_units
      RETURNING
        VALUE(rt_units) TYPE
          zcl_goods_movement_service=>ty_material_unit_mappings.
    METHODS gets_fresh_quality_fefo FOR TESTING.
    METHODS releases_priority_quality_fefo FOR TESTING.
    METHODS posts_date_prio_quality_fefo FOR TESTING.
    METHODS rejects_changed_priority_fefo FOR TESTING.
    METHODS rejects_prio_fefo_stock_change FOR TESTING.
    METHODS releases_fefo_allowlist FOR TESTING.
    METHODS sends_fresh_unrestricted_fefo FOR TESTING.
    METHODS sends_priority_fefo_quality FOR TESTING.
    METHODS rejects_send_priority_echo FOR TESTING.
    METHODS rejects_send_prio_stock_change FOR TESTING.
    METHODS rejects_changed_quality_stock FOR TESTING.
    METHODS rechecks_req_loc_ranks FOR TESTING.
    METHODS rejects_q_location_scopes FOR TESTING.
    METHODS noops_empty_quality_demands FOR TESTING.
    METHODS rejects_scopes_without_demands FOR TESTING.
ENDCLASS.

CLASS ltcl_quality_stock_service IMPLEMENTATION.
  METHOD setup.
    mo_repository = NEW lcl_quality_stock_repository( ).
    mo_repository->mt_quality_stock = VALUE #(
      ( storage_location            = '0001'
        batch                       = 'B-SOON'
        expiration_date             = '20261020'
        unrestricted_quantity       = '3.000'
        available_quantity          = '3.000'
        quality_inspection_quantity = '3.000' )
      ( storage_location            = '0002'
        batch                       = 'B-LATER'
        expiration_date             = '20261031'
        unrestricted_quantity       = '5.000'
        available_quantity          = '5.000'
        quality_inspection_quantity = '5.000' ) ).
    mo_repository->mt_unrestricted_stock = VALUE #(
      ( storage_location   = '0001'
        batch              = 'B-SOON'
        expiration_date    = '20261020'
        available_quantity = '3.000' )
      ( storage_location   = '0002'
        batch              = 'B-LATER'
        expiration_date    = '20261031'
        available_quantity = '5.000' ) ).
    mo_uom_repository = NEW lcl_quality_uom_repository( ).
    DATA(lo_uom_converter) = NEW zcl_material_uom_converter(
      io_repository = mo_uom_repository ).
    mo_stock_service = NEW zcl_stock_service(
      io_stock_repository = mo_repository
      io_uom_converter    = lo_uom_converter ).
    mo_api = NEW lcl_quality_goods_movement_api( ).
    mo_goods_movement_service = NEW zcl_goods_movement_service(
      io_api            = mo_api
      io_uom_repository = mo_uom_repository ).
    mo_cut = NEW zcl_quality_stock_service(
      io_stock_service          = mo_stock_service
      io_goods_movement_service = mo_goods_movement_service ).
  ENDMETHOD.

  METHOD get_demands.
    rt_demands = VALUE #(
      ( request_id                  = 'QI-1'
        material                    = 'MAT-1'
        plant                       = '1000'
        fallback_to_other_locations = abap_false
        requested_quantity          = '2.500'
        requested_unit              = 'BOX' ) ).
  ENDMETHOD.

  METHOD get_priority_demands.
    rt_demands = VALUE #(
      ( request_id         = 'QI-LOW'
        material           = 'MAT-1'
        plant              = '1000'
        priority           = 1
        requested_quantity = '2.000'
        requested_unit     = 'BOX' )
      ( request_id         = 'QI-HIGH'
        material           = 'MAT-1'
        plant              = '1000'
        priority           = 10
        requested_quantity = '2.000'
        requested_unit     = 'BOX' ) ).
  ENDMETHOD.

  METHOD get_material_units.
    rt_units = VALUE #(
      ( material      = 'MAT-1'
        base_unit     = 'EA'
        base_unit_iso = 'EA' ) ).
  ENDMETHOD.

  METHOD gets_fresh_quality_fefo.
    DATA(ls_preview) = mo_stock_service->allocate_quality_by_expiry_uom(
      it_demands    = get_demands( )
      iv_as_of_date = '20260923' ).

    DATA(ls_result) = mo_cut->release_quality_fefo(
      is_allocation     = ls_preview
      it_demands        = get_demands( )
      is_header         = VALUE #(
        posting_date  = '20261013'
        document_date = '20261013' )
      it_material_units = get_material_units( )
      iv_as_of_date     = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( mo_api->mt_last_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '321'
      act = mo_api->mt_last_items[ 1 ]-movement_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-SOON'
      act = mo_api->mt_last_items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = mo_api->mt_last_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = mo_api->mt_last_items[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = mo_api->mt_last_items[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_repository->get_batch_status_read_count( ) ).
  ENDMETHOD.

  METHOD releases_priority_quality_fefo.
    DATA(ls_preview) = mo_stock_service->allocate_quality_uom_priority(
      it_demands    = get_priority_demands( )
      iv_as_of_date = '20260923' ).

    DATA(ls_result) = mo_cut->release_quality_fefo_priority(
      is_allocation     = ls_preview
      it_demands        = get_priority_demands( )
      is_header         = VALUE #(
        posting_date  = '20261013'
        document_date = '20261013' )
      it_material_units = get_material_units( )
      iv_as_of_date     = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( mo_api->mt_last_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'QI-LOW'
      act = ls_preview-allocations[ 1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_preview-allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'QI-HIGH'
      act = ls_preview-allocations[ 2 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_preview-allocations[ 2 ]-priority ).
    DATA(ls_low_priority_split) = ls_preview-batch_allocations[ 1 ].
    DATA(ls_low_split) =
      ls_low_priority_split-batch_allocation-batch_allocation.
    DATA(ls_high_priority_split) = ls_preview-batch_allocations[ 2 ].
    DATA(ls_high_first_split) =
      ls_high_priority_split-batch_allocation-batch_allocation.

    cl_abap_unit_assert=>assert_equals(
      exp = 'QI-LOW'
      act = ls_low_split-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = mo_api->mt_last_items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = mo_api->mt_last_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'QI-HIGH'
      act = ls_high_first_split-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-SOON'
      act = mo_api->mt_last_items[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = mo_api->mt_last_items[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = mo_api->mt_last_items[ 3 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = mo_api->mt_last_items[ 3 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_repository->get_batch_status_read_count( ) ).
  ENDMETHOD.

  METHOD posts_date_prio_quality_fefo.
    DATA(lt_demands) =
      VALUE zcl_stock_service=>ty_priority_unit_fefo_demands(
        ( request_id         = 'LATE-HIGH'
          material           = 'MAT-1'
          plant              = '1000'
          priority           = 10
          requested_quantity = '2.000'
          requested_unit     = 'BOX'
          fefo_as_of_date    = '20261011' )
        ( request_id         = 'EARLY-LOW'
          material           = 'MAT-1'
          plant              = '1000'
          priority           = 1
          requested_quantity = '2.000'
          requested_unit     = 'BOX'
          fefo_as_of_date    = '20261010' )
        ( request_id         = 'EARLY-HIGH'
          material           = 'MAT-1'
          plant              = '1000'
          priority           = 5
          requested_quantity = '2.000'
          requested_unit     = 'BOX'
          fefo_as_of_date    = '20261010' ) ).
    DATA(ls_quality_preview) = mo_stock_service->allocate_quality_uom_priority(
      it_demands               = lt_demands
      iv_as_of_date            = '20260923'
      iv_prioritize_by_date    = abap_true
      iv_require_full_quantity = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'LATE-HIGH'
      act = ls_quality_preview-allocations[
        1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_quality_preview-allocations[
        1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_quality_preview-allocations[
        2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_quality_preview-allocations[
        3 ]-allocation-allocation-allocated_quantity ).

    DATA(ls_release_result) = mo_cut->release_quality_fefo_priority(
      is_allocation              = ls_quality_preview
      it_demands                 = lt_demands
      is_header                  = VALUE #(
        posting_date  = '20261013'
        document_date = '20261013' )
      it_material_units          = get_material_units( )
      iv_as_of_date              = '20260923'
      iv_prioritize_by_date      = abap_true
      iv_require_full_allocation = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_release_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( mo_api->mt_last_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '321'
      act = mo_api->mt_last_items[ 1 ]-movement_type ).

    DATA(ls_unrestricted_preview) = mo_stock_service->allocate_fefo_uom_priority(
      it_demands               = lt_demands
      iv_as_of_date            = '20260923'
      iv_prioritize_by_date    = abap_true
      iv_require_full_quantity = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LATE-HIGH'
      act = ls_unrestricted_preview-allocations[
        1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_unrestricted_preview-allocations[
        1 ]-allocation-allocation-allocated_quantity ).
    DATA(ls_send_result) = mo_cut->send_quality_fefo_priority(
      is_allocation              = ls_unrestricted_preview
      it_demands                 = lt_demands
      is_header                  = VALUE #(
        posting_date  = '20261013'
        document_date = '20261013' )
      it_material_units          = get_material_units( )
      iv_as_of_date              = '20260923'
      iv_prioritize_by_date      = abap_true
      iv_require_full_allocation = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_send_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( mo_api->mt_last_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '322'
      act = mo_api->mt_last_items[ 1 ]-movement_type ).
  ENDMETHOD.

  METHOD rejects_changed_priority_fefo.
    DATA(ls_preview) = mo_stock_service->allocate_quality_uom_priority(
      it_demands    = get_priority_demands( )
      iv_as_of_date = '20260923' ).
    READ TABLE ls_preview-allocations ASSIGNING FIELD-SYMBOL(<ls_allocation>)
      INDEX 1.
    <ls_allocation>-priority = 2.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->release_quality_fefo_priority(
          is_allocation     = ls_preview
          it_demands        = get_priority_demands( )
          is_header         = VALUE #(
            posting_date  = '20261013'
            document_date = '20261013' )
          it_material_units = get_material_units( )
          iv_as_of_date     = '20260923' ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_create_calls ).
  ENDMETHOD.

  METHOD rejects_prio_fefo_stock_change.
    DATA(ls_preview) = mo_stock_service->allocate_quality_uom_priority(
      it_demands    = get_priority_demands( )
      iv_as_of_date = '20260923' ).
    mo_repository->mv_use_recheck_quality_stock = abap_true.
    mo_repository->mt_recheck_quality_stock = VALUE #(
      ( storage_location            = '0001'
        batch                       = 'B-SOON'
        expiration_date             = '20261020'
        unrestricted_quantity       = '1.000'
        available_quantity          = '1.000'
        quality_inspection_quantity = '1.000' )
      ( storage_location            = '0002'
        batch                       = 'B-LATER'
        expiration_date             = '20261031'
        unrestricted_quantity       = '7.000'
        available_quantity          = '7.000'
        quality_inspection_quantity = '7.000' ) ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->release_quality_fefo_priority(
          is_allocation     = ls_preview
          it_demands        = get_priority_demands( )
          is_header         = VALUE #(
            posting_date  = '20261013'
            document_date = '20261013' )
          it_material_units = get_material_units( )
          iv_as_of_date     = '20260923' ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_create_calls ).
  ENDMETHOD.

  METHOD releases_fefo_allowlist.
    DATA(lt_allowed_locations) = VALUE zcl_stock_service=>ty_storage_locations(
      ( '0002' ) ).
    DATA(ls_preview) = mo_stock_service->allocate_quality_by_expiry_uom(
      it_demands                   = get_demands( )
      it_allowed_storage_locations = lt_allowed_locations
      iv_as_of_date                = '20260923' ).

    DATA(ls_result) = mo_cut->release_quality_fefo(
      is_allocation                = ls_preview
      it_demands                   = get_demands( )
      is_header                    = VALUE #(
        posting_date  = '20261013'
        document_date = '20261013' )
      it_material_units            = get_material_units( )
      it_allowed_storage_locations = lt_allowed_locations
      iv_as_of_date                = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( mo_api->mt_last_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = mo_api->mt_last_items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = mo_api->mt_last_items[ 1 ]-quantity ).
  ENDMETHOD.

  METHOD sends_fresh_unrestricted_fefo.
    DATA(ls_preview) = mo_stock_service->allocate_by_expiry_in_units(
      it_demands    = get_demands( )
      iv_as_of_date = '20260923' ).

    DATA(ls_result) = mo_cut->send_quality_fefo(
      is_allocation     = ls_preview
      it_demands        = get_demands( )
      is_header         = VALUE #(
        posting_date  = '20261013'
        document_date = '20261013' )
      it_material_units = get_material_units( )
      iv_as_of_date     = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( mo_api->mt_last_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '322'
      act = mo_api->mt_last_items[ 1 ]-movement_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-SOON'
      act = mo_api->mt_last_items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = mo_api->mt_last_items[ 2 ]-batch ).
  ENDMETHOD.

  METHOD sends_priority_fefo_quality.
    DATA(ls_preview) = mo_stock_service->allocate_fefo_uom_priority(
      it_demands    = get_priority_demands( )
      iv_as_of_date = '20260923' ).

    DATA(ls_result) = mo_cut->send_quality_fefo_priority(
      is_allocation     = ls_preview
      it_demands        = get_priority_demands( )
      is_header         = VALUE #(
        posting_date  = '20261013'
        document_date = '20261013' )
      it_material_units = get_material_units( )
      iv_as_of_date     = '20260923' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( mo_api->mt_last_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'QI-LOW'
      act = ls_preview-allocations[ 1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_preview-allocations[ 1 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'QI-HIGH'
      act = ls_preview-allocations[ 2 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = ls_preview-allocations[ 2 ]-priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = '322'
      act = mo_api->mt_last_items[ 1 ]-movement_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = mo_api->mt_last_items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = mo_api->mt_last_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-SOON'
      act = mo_api->mt_last_items[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = mo_api->mt_last_items[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = mo_api->mt_last_items[ 3 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = mo_api->mt_last_items[ 3 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_repository->get_unrestricted_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_send_priority_echo.
    DATA(ls_preview) = mo_stock_service->allocate_fefo_uom_priority(
      it_demands    = get_priority_demands( )
      iv_as_of_date = '20260923' ).
    READ TABLE ls_preview-allocations ASSIGNING FIELD-SYMBOL(<ls_allocation>)
      INDEX 1.
    <ls_allocation>-priority = 2.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->send_quality_fefo_priority(
          is_allocation     = ls_preview
          it_demands        = get_priority_demands( )
          is_header         = VALUE #(
            posting_date  = '20261013'
            document_date = '20261013' )
          it_material_units = get_material_units( )
          iv_as_of_date     = '20260923' ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_create_calls ).
  ENDMETHOD.

  METHOD rejects_send_prio_stock_change.
    DATA(ls_preview) = mo_stock_service->allocate_fefo_uom_priority(
      it_demands    = get_priority_demands( )
      iv_as_of_date = '20260923' ).
    mo_repository->mv_use_recheck_unrestricted = abap_true.
    mo_repository->mt_recheck_unrestricted_stock = VALUE #(
      ( storage_location   = '0001'
        batch              = 'B-SOON'
        expiration_date    = '20261020'
        available_quantity = '1.000' )
      ( storage_location   = '0002'
        batch              = 'B-LATER'
        expiration_date    = '20261031'
        available_quantity = '7.000' ) ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->send_quality_fefo_priority(
          is_allocation     = ls_preview
          it_demands        = get_priority_demands( )
          is_header         = VALUE #(
            posting_date  = '20261013'
            document_date = '20261013' )
          it_material_units = get_material_units( )
          iv_as_of_date     = '20260923' ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_repository->get_unrestricted_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_changed_quality_stock.
    DATA(ls_preview) = mo_stock_service->allocate_quality_by_expiry_uom(
      it_demands    = get_demands( )
      iv_as_of_date = '20260923' ).
    mo_repository->mv_use_recheck_quality_stock = abap_true.
    mo_repository->mt_recheck_quality_stock = VALUE #(
      ( storage_location            = '0001'
        batch                       = 'B-SOON'
        expiration_date             = '20261020'
        unrestricted_quantity       = '2.000'
        available_quantity          = '2.000'
        quality_inspection_quantity = '2.000' )
      ( storage_location            = '0002'
        batch                       = 'B-LATER'
        expiration_date             = '20261031'
        unrestricted_quantity       = '5.000'
        available_quantity          = '5.000'
        quality_inspection_quantity = '5.000' ) ).
    DATA(lv_rejected) = abap_false.

    TRY.
        mo_cut->release_quality_fefo(
          is_allocation     = ls_preview
          it_demands        = get_demands( )
          is_header         = VALUE #(
            posting_date  = '20261013'
            document_date = '20261013' )
          it_material_units = get_material_units( )
          iv_as_of_date     = '20260923' ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_repository->get_batch_status_read_count( ) ).
  ENDMETHOD.

  METHOD rechecks_req_loc_ranks.
    DATA(lt_single_location_priorities) =
      VALUE zcl_stock_service=>ty_request_location_priorities(
        ( request_id       = 'QI-1'
          storage_location = '0002'
          priority_rank    = 1 ) ).
    DATA(lt_single_location_scopes) =
      VALUE zcl_stock_service=>ty_request_locations(
        ( request_id = 'QI-1' storage_location = '0002' ) ).
    DATA(lt_prio_location_scopes) =
      VALUE zcl_stock_service=>ty_request_locations(
        ( request_id = 'QI-LOW' storage_location = '0002' )
        ( request_id = 'QI-HIGH' storage_location = '0001' )
        ( request_id = 'QI-HIGH' storage_location = '0002' ) ).
    DATA(lt_prio_loc_prios) =
      VALUE zcl_stock_service=>ty_request_location_priorities(
        ( request_id       = 'QI-LOW'
          storage_location = '0002'
          priority_rank    = 1 )
        ( request_id       = 'QI-LOW'
          storage_location = '0001'
          priority_rank    = 2 )
        ( request_id       = 'QI-HIGH'
          storage_location = '0001'
          priority_rank    = 1 )
        ( request_id       = 'QI-HIGH'
          storage_location = '0002'
          priority_rank    = 2 ) ).
    mo_repository->mt_quality_stock = VALUE #(
      ( storage_location            = '0001'
        batch                       = 'B-SAME'
        expiration_date             = '20261020'
        unrestricted_quantity       = '3.000'
        available_quantity          = '3.000'
        quality_inspection_quantity = '3.000' )
      ( storage_location            = '0002'
        batch                       = 'B-SAME'
        expiration_date             = '20261020'
        unrestricted_quantity       = '5.000'
        available_quantity          = '5.000'
        quality_inspection_quantity = '5.000' ) ).
    mo_repository->mt_unrestricted_stock = VALUE #(
      ( storage_location   = '0001'
        batch              = 'B-SAME'
        expiration_date    = '20261020'
        available_quantity = '3.000' )
      ( storage_location   = '0002'
        batch              = 'B-SAME'
        expiration_date    = '20261020'
        available_quantity = '5.000' ) ).

    DATA(ls_quality_preview) =
      mo_stock_service->allocate_quality_by_expiry_uom(
        it_demands                     = get_demands( )
        it_request_location_priorities = lt_single_location_priorities
        it_request_locations           = lt_single_location_scopes
        iv_as_of_date                  = '20260923' ).
    DATA(ls_release_result) = mo_cut->release_quality_fefo(
      is_allocation                  = ls_quality_preview
      it_demands                     = get_demands( )
      is_header                      = VALUE #(
        posting_date  = '20261013'
        document_date = '20261013' )
      it_material_units              = get_material_units( )
      it_request_location_priorities = lt_single_location_priorities
      it_request_locations           = lt_single_location_scopes
      iv_as_of_date                  = '20260923' ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_release_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = mo_api->mt_last_items[ 1 ]-storage_location ).

    DATA(ls_quality_priority_preview) =
      mo_stock_service->allocate_quality_uom_priority(
        it_demands                     = get_priority_demands( )
        it_request_location_priorities = lt_prio_loc_prios
        it_request_locations           = lt_prio_location_scopes
        iv_as_of_date                  = '20260923' ).
    DATA(ls_priority_release_result) =
      mo_cut->release_quality_fefo_priority(
        is_allocation                  = ls_quality_priority_preview
        it_demands                     = get_priority_demands( )
        is_header                      = VALUE #(
          posting_date  = '20261013'
          document_date = '20261013' )
        it_material_units              = get_material_units( )
        it_request_location_priorities = lt_prio_loc_prios
        it_request_locations           = lt_prio_location_scopes
        iv_as_of_date                  = '20260923' ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_priority_release_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = mo_api->mt_last_items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = mo_api->mt_last_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = mo_api->mt_last_items[ 2 ]-storage_location ).

    DATA(ls_unrestricted_preview) =
      mo_stock_service->allocate_by_expiry_in_units(
        it_demands                     = get_demands( )
        it_request_location_priorities = lt_single_location_priorities
        it_request_locations           = lt_single_location_scopes
        iv_as_of_date                  = '20260923' ).
    DATA(ls_send_result) = mo_cut->send_quality_fefo(
      is_allocation                  = ls_unrestricted_preview
      it_demands                     = get_demands( )
      is_header                      = VALUE #(
        posting_date  = '20261013'
        document_date = '20261013' )
      it_material_units              = get_material_units( )
      it_request_location_priorities = lt_single_location_priorities
      it_request_locations           = lt_single_location_scopes
      iv_as_of_date                  = '20260923' ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_send_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = mo_api->mt_last_items[ 1 ]-storage_location ).

    DATA(ls_unres_prio_preview) =
      mo_stock_service->allocate_fefo_uom_priority(
        it_demands                     = get_priority_demands( )
        it_request_location_priorities = lt_prio_loc_prios
        it_request_locations           = lt_prio_location_scopes
        iv_as_of_date                  = '20260923' ).
    DATA(ls_priority_send_result) = mo_cut->send_quality_fefo_priority(
      is_allocation                    = ls_unres_prio_preview
      it_demands                       = get_priority_demands( )
      is_header                        = VALUE #(
        posting_date  = '20261013'
        document_date = '20261013' )
      it_material_units                = get_material_units( )
        it_request_location_priorities = lt_prio_loc_prios
        it_request_locations           = lt_prio_location_scopes
      iv_as_of_date                    = '20260923' ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_priority_send_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = mo_api->mt_last_items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = mo_api->mt_last_items[ 2 ]-storage_location ).
  ENDMETHOD.

  METHOD rejects_q_location_scopes.
    DATA(lv_rejected) = abap_false.
    TRY.
        mo_cut->release_quality_fefo(
          is_allocation        = VALUE #( )
          it_demands           = get_demands( )
          is_header            = VALUE #(
            posting_date  = '20261013'
            document_date = '20261013' )
          it_material_units    = get_material_units( )
          it_request_locations = VALUE #(
            ( request_id = 'UNKNOWN' storage_location = '0002' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0 act = mo_repository->get_batch_status_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0 act = mo_uom_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals( exp = 0 act = mo_api->mv_create_calls ).

    CLEAR lv_rejected.
    TRY.
        mo_stock_service->allocate_quality_by_expiry_uom(
          it_demands           = get_demands( )
          it_request_locations = VALUE #(
            ( request_id = 'QI-1' storage_location = '0002' )
            ( request_id = 'QI-1' storage_location = '0002' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0 act = mo_repository->get_batch_status_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0 act = mo_uom_repository->get_read_count( ) ).

    DATA(lt_preferred_demand) = get_demands( ).
    lt_preferred_demand[ 1 ]-storage_location = '0001'.
    CLEAR lv_rejected.
    TRY.
        mo_stock_service->allocate_quality_by_expiry_uom(
          it_demands           = lt_preferred_demand
          it_request_locations = VALUE #(
            ( request_id = 'QI-1' storage_location = '0002' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals( exp = abap_true act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0 act = mo_repository->get_batch_status_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0 act = mo_uom_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD noops_empty_quality_demands.
    DATA(ls_result) = mo_cut->release_quality_fefo(
      is_allocation     = VALUE #( )
      it_demands        = VALUE #( )
      is_header         = VALUE #( )
      it_material_units = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_repository->get_batch_status_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_create_calls ).
    DATA(lv_scope_rejected) = abap_false.
    TRY.
        mo_cut->release_quality_fefo(
          is_allocation        = VALUE #( )
          it_demands           = VALUE #( )
          is_header            = VALUE #( )
          it_material_units    = VALUE #( )
          it_request_locations = VALUE #(
            ( request_id = 'QI-1' storage_location = '0002' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_scope_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true act = lv_scope_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0 act = mo_repository->get_batch_status_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0 act = mo_api->mv_create_calls ).

  ENDMETHOD.

  METHOD rejects_scopes_without_demands.
    DATA(lv_rejected) = abap_false.
    TRY.
        mo_cut->release_quality_fefo(
          is_allocation                = VALUE #( )
          it_demands                   = VALUE #( )
          is_header                    = VALUE #( )
          it_material_units            = VALUE #( )
          it_storage_location_priority = VALUE #( ( '0001' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        mo_cut->release_quality_fefo_priority(
          is_allocation                  = VALUE #( )
          it_demands                     = VALUE #( )
          is_header                      = VALUE #( )
          it_material_units              = VALUE #( )
          it_request_location_priorities = VALUE #(
            ( request_id       = 'QI-1'
              storage_location = '0001'
              priority_rank    = 1 ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        mo_cut->send_quality_fefo(
          is_allocation                = VALUE #( )
          it_demands                   = VALUE #( )
          is_header                    = VALUE #( )
          it_material_units            = VALUE #( )
          it_allowed_storage_locations = VALUE #( ( '0001' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        mo_cut->send_quality_fefo_priority(
          is_allocation        = VALUE #( )
          it_demands           = VALUE #( )
          is_header            = VALUE #( )
          it_material_units    = VALUE #( )
          it_request_locations = VALUE #(
            ( request_id = 'QI-1' storage_location = '0001' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        mo_cut->send_quality_fefo_priority(
          is_allocation     = VALUE #(
            request_locations = VALUE #(
              ( request_id = 'QI-1' storage_location = '0001' ) ) )
          it_demands        = VALUE #( )
          is_header         = VALUE #( )
          it_material_units = VALUE #( ) ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0 act = mo_repository->get_batch_status_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0 act = mo_uom_repository->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0 act = mo_api->mv_create_calls ).
  ENDMETHOD.
ENDCLASS.
