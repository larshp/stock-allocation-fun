CLASS lcl_sto_api_double DEFINITION FINAL.
  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_write_override,
        call_number TYPE i,
        result      TYPE zif_stock_transfer_order_api=>ty_result,
      END OF ty_write_override.
    TYPES ty_write_overrides TYPE STANDARD TABLE OF ty_write_override
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_change_override,
        call_number TYPE i,
        result      TYPE zif_stock_transfer_order_api=>ty_change_result,
      END OF ty_change_override.
    TYPES ty_change_overrides TYPE STANDARD TABLE OF ty_change_override
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_delete_call,
        call_number    TYPE i,
        purchase_order TYPE eord-ebeln,
        item_numbers   TYPE zif_stock_transfer_order_api=>ty_item_numbers,
      END OF ty_delete_call.
    TYPES ty_delete_calls TYPE STANDARD TABLE OF ty_delete_call
      WITH EMPTY KEY.
    TYPES ty_delivery_complete_calls TYPE STANDARD TABLE OF ty_delete_call
      WITH EMPTY KEY.
    INTERFACES zif_stock_transfer_order_api.
    METHODS set_write_result
      IMPORTING
        is_result TYPE zif_stock_transfer_order_api=>ty_result.
    METHODS set_write_result_for_call
      IMPORTING
        iv_call_number TYPE i
        is_result      TYPE zif_stock_transfer_order_api=>ty_result.
    METHODS set_commit_result
      IMPORTING
        is_result TYPE zif_stock_transfer_order_api=>ty_commit_result.
    METHODS set_change_result
      IMPORTING
        is_result TYPE zif_stock_transfer_order_api=>ty_change_result.
    METHODS set_change_result_for_call
      IMPORTING
        iv_call_number TYPE i
        is_result      TYPE zif_stock_transfer_order_api=>ty_change_result.
    METHODS get_create_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_commit_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_rollback_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_delete_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_delete_call
      IMPORTING
        iv_call_number TYPE i
      RETURNING
        VALUE(rs_call) TYPE ty_delete_call.
    METHODS get_delivery_complete_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_delivery_complete_call
      IMPORTING
        iv_call_number TYPE i
      RETURNING
        VALUE(rs_call) TYPE ty_delete_call.
    DATA ms_request TYPE zif_stock_transfer_order_api=>ty_request.
  PRIVATE SECTION.
    DATA ms_write_result TYPE zif_stock_transfer_order_api=>ty_result.
    DATA mt_write_overrides TYPE ty_write_overrides.
    DATA ms_commit_result TYPE
      zif_stock_transfer_order_api=>ty_commit_result.
    DATA ms_change_result TYPE
      zif_stock_transfer_order_api=>ty_change_result.
    DATA mt_change_overrides TYPE ty_change_overrides.
    DATA mt_delete_calls TYPE ty_delete_calls.
    DATA mt_delivery_complete_calls TYPE ty_delivery_complete_calls.
    DATA mv_create_count TYPE i.
    DATA mv_delete_count TYPE i.
    DATA mv_delivery_complete_count TYPE i.
    DATA mv_commit_count TYPE i.
    DATA mv_rollback_count TYPE i.
ENDCLASS.

CLASS lcl_sto_api_double IMPLEMENTATION.
  METHOD set_write_result.
    ms_write_result = is_result.
  ENDMETHOD.

  METHOD set_write_result_for_call.
    APPEND VALUE #(
      call_number = iv_call_number
      result      = is_result ) TO mt_write_overrides.
  ENDMETHOD.

  METHOD set_commit_result.
    ms_commit_result = is_result.
  ENDMETHOD.

  METHOD set_change_result.
    ms_change_result = is_result.
  ENDMETHOD.

  METHOD set_change_result_for_call.
    APPEND VALUE #(
      call_number = iv_call_number
      result      = is_result ) TO mt_change_overrides.
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

  METHOD get_delete_count.
    rv_count = mv_delete_count.
  ENDMETHOD.

  METHOD get_delete_call.
    READ TABLE mt_delete_calls INTO rs_call
      WITH KEY call_number = iv_call_number.
  ENDMETHOD.

  METHOD get_delivery_complete_count.
    rv_count = mv_delivery_complete_count.
  ENDMETHOD.

  METHOD get_delivery_complete_call.
    READ TABLE mt_delivery_complete_calls INTO rs_call
      WITH KEY call_number = iv_call_number.
  ENDMETHOD.

  METHOD zif_stock_transfer_order_api~create_order.
    ADD 1 TO mv_create_count.
    ms_request = is_request.
    READ TABLE mt_write_overrides INTO DATA(ls_override)
      WITH KEY call_number = mv_create_count.
    IF sy-subrc = 0.
      rs_result = ls_override-result.
    ELSE.
      rs_result = ms_write_result.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_transfer_order_api~mark_items_for_deletion.
    ADD 1 TO mv_delete_count.
    APPEND VALUE #(
      call_number    = mv_delete_count
      purchase_order = iv_purchase_order
      item_numbers   = it_item_numbers ) TO mt_delete_calls.
    READ TABLE mt_change_overrides INTO DATA(ls_override)
      WITH KEY call_number = mv_delete_count.
    IF sy-subrc = 0.
      rs_result = ls_override-result.
    ELSE.
      rs_result = ms_change_result.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_transfer_order_api~mark_items_delivery_complete.
    ADD 1 TO mv_delivery_complete_count.
    APPEND VALUE #(
      call_number    = mv_delivery_complete_count
      purchase_order = iv_purchase_order
      item_numbers   = it_item_numbers ) TO mt_delivery_complete_calls.
    READ TABLE mt_change_overrides INTO DATA(ls_override)
      WITH KEY call_number = mv_delivery_complete_count.
    IF sy-subrc = 0.
      rs_result = ls_override-result.
    ELSE.
      rs_result = ms_change_result.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_transfer_order_api~commit.
    ADD 1 TO mv_commit_count.
    rs_result = ms_commit_result.
  ENDMETHOD.

  METHOD zif_stock_transfer_order_api~rollback.
    ADD 1 TO mv_rollback_count.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_sto_order_service DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS get_multi_source_allocation
      RETURNING
        VALUE(rs_allocation) TYPE zcl_stock_service=>ty_unit_date_plant_result.
    METHODS get_atp_source_alloc
      RETURNING
        VALUE(rs_allocation) TYPE zcl_stock_service=>ty_plant_date_atp_result.
    METHODS get_atp_pair_alloc
      RETURNING
        VALUE(rs_allocation) TYPE zcl_stock_service=>ty_plant_date_atp_result.
    METHODS get_atp_fefo_alloc
      RETURNING
        VALUE(rs_allocation) TYPE zcl_stock_service=>ty_plant_fefo_date_atp_result.
    METHODS get_multi_plant_allocation
      RETURNING
        VALUE(rs_allocation) TYPE zcl_stock_service=>ty_unit_date_plant_result.
    METHODS get_multi_batch_allocation
      RETURNING
        VALUE(rs_allocation) TYPE zcl_stock_service=>ty_unit_plant_batch_result.
    METHODS get_fefo_allocation
      RETURNING
        VALUE(rs_allocation) TYPE zcl_stock_service=>ty_unit_date_plant_fefo_result.
    METHODS get_sto_order_for_deletion
      RETURNING
        VALUE(rs_order) TYPE zif_stock_transfer_order_api=>ty_result.
    METHODS get_sto_orders_for_deletion
      RETURNING
        VALUE(rs_orders) TYPE zcl_stock_xfer_order_svc=>ty_plant_pairs_result.
    METHODS creates_order_from_allocation FOR TESTING.
    METHODS creates_batch_order FOR TESTING.
    METHODS creates_all_batch_plant_pairs FOR TESTING.
    METHODS validates_batch_pairs_first FOR TESTING.
    METHODS creates_fefo_pair_orders FOR TESTING.
    METHODS validates_fefo_pairs_first FOR TESTING.
    METHODS rejects_batch_without_identity FOR TESTING.
    METHODS creates_multi_source_orders FOR TESTING.
    METHODS commits_atomic_source_orders FOR TESTING.
    METHODS rolls_back_atomic_sources FOR TESTING.
    METHODS fails_atomic_source_commit FOR TESTING.
    METHODS creates_atp_source_orders FOR TESTING.
    METHODS rejects_short_atp_sources FOR TESTING.
    METHODS creates_atp_plant_pairs FOR TESTING.
    METHODS rejects_short_atp_pairs FOR TESTING.
    METHODS creates_atp_fefo_pairs FOR TESTING.
    METHODS rejects_short_atp_fefo FOR TESTING.
    METHODS creates_all_plant_pairs FOR TESTING.
    METHODS fails_atomic_plant_pairs FOR TESTING.
    METHODS fails_atomic_pair_commit FOR TESTING.
    METHODS validates_pairs_first FOR TESTING.
    METHODS rejects_bad_location_map FOR TESTING.
    METHODS validates_sources_first FOR TESTING.
    METHODS reports_pair_failure FOR TESTING.
    METHODS simulates_order_without_commit FOR TESTING.
    METHODS rejects_short_allocation FOR TESTING.
    METHODS rolls_back_create_error FOR TESTING.
    METHODS rolls_back_commit_error FOR TESTING.
    METHODS deletes_single_sto FOR TESTING.
    METHODS continues_sto_delete_failure FOR TESTING.
    METHODS deletes_sto_pairs_atomically FOR TESTING.
    METHODS rolls_back_atomic_sto_delete FOR TESTING.
    METHODS fails_atomic_delete_commit FOR TESTING.
    METHODS rejects_atomic_ineligible_sto FOR TESTING.
    METHODS prevalidates_sto_deletions FOR TESTING.
    METHODS skips_uncommitted_sto_deletion FOR TESTING.
    METHODS rolls_back_deletion_commit FOR TESTING.
    METHODS completes_single_sto_delivery FOR TESTING.
    METHODS continues_complete_failure FOR TESTING.
    METHODS completes_pairs_atomically FOR TESTING.
    METHODS rolls_back_atomic_complete FOR TESTING.
    METHODS fails_atomic_complete_commit FOR TESTING.
    METHODS rejects_atomic_complete_input FOR TESTING.
    METHODS prevalidates_sto_completion FOR TESTING.
    METHODS skips_uncommitted_completion FOR TESTING.
    METHODS rolls_back_completion_commit FOR TESTING.
ENDCLASS.

CLASS ltcl_sto_order_service IMPLEMENTATION.
  METHOD get_multi_source_allocation.
    rs_allocation = VALUE #(
      allocations       = VALUE #(
        ( allocation = VALUE #(
            request_id = 'REQ-1' material = 'MAT-1'
            target_plant = '2000' required_date = '20261010'
            requested_quantity = '5.000' available_quantity = '5.000'
            allocated_quantity = '5.000' shortfall_quantity = '0.000' )
          source_quantity = '5.000' source_unit = 'EA'
          base_quantity = '5.000' base_unit = 'EA'
          available_source_quantity = '5.000'
          allocated_source_quantity = '5.000' ) )
      plant_allocations = VALUE #(
        ( allocation = VALUE #(
            request_id = 'REQ-1' material = 'MAT-1'
            target_plant = '2000' source_plant = '1000'
            required_date = '20261010' available_quantity = '3.000'
            allocated_quantity = '3.000' )
          source_unit = 'EA' base_unit = 'EA'
          available_source_quantity = '3.000'
          allocated_source_quantity = '3.000' )
        ( allocation = VALUE #(
            request_id = 'REQ-1' material = 'MAT-1'
            target_plant = '2000' source_plant = '1100'
            required_date = '20261010' available_quantity = '2.000'
            allocated_quantity = '2.000' )
          source_unit = 'EA' base_unit = 'EA'
          available_source_quantity = '2.000'
          allocated_source_quantity = '2.000' ) ) ).
  ENDMETHOD.

  METHOD get_atp_source_alloc.
    rs_allocation = VALUE #(
      local_estimate = get_multi_source_allocation( )
      atp_checks     = VALUE #(
        ( request_id               = 'REQ-1'
          material                 = 'MAT-1'
          target_plant             = '2000'
          source_plant             = '1000'
          required_date            = '20261010'
          base_unit                = 'EA'
          allocated_base_quantity  = '3.000'
          cumulative_base_quantity = '3.000'
          confirmed_base_quantity  = '3.000'
          atp_result               = VALUE #(
            material           = 'MAT-1'
            plant              = '1000'
            unit               = 'EA'
            check_rule         = 'A'
            required_date      = '20261010'
            requested_quantity = '3.000'
            confirmed_date     = '20261010'
            confirmed_quantity = '3.000'
            is_fully_available = abap_true
            is_check_relevant  = abap_true ) )
        ( request_id               = 'REQ-1'
          material                 = 'MAT-1'
          target_plant             = '2000'
          source_plant             = '1100'
          required_date            = '20261010'
          base_unit                = 'EA'
          allocated_base_quantity  = '2.000'
          cumulative_base_quantity = '2.000'
          confirmed_base_quantity  = '2.000'
          atp_result               = VALUE #(
            material           = 'MAT-1'
            plant              = '1100'
            unit               = 'EA'
            check_rule         = 'A'
            required_date      = '20261010'
            requested_quantity = '2.000'
            confirmed_date     = '20261010'
            confirmed_quantity = '2.000'
            is_fully_available = abap_true
            is_check_relevant  = abap_true ) ) ) ).
  ENDMETHOD.

  METHOD get_atp_pair_alloc.
    rs_allocation-local_estimate = get_multi_plant_allocation( ).

    LOOP AT rs_allocation-local_estimate-plant_allocations
        INTO DATA(ls_source_allocation).
      DATA(lv_quantity) =
        ls_source_allocation-allocation-allocated_quantity.
      APPEND VALUE #(
        request_id               = ls_source_allocation-allocation-request_id
        material                 = ls_source_allocation-allocation-material
        target_plant             = ls_source_allocation-allocation-target_plant
        source_plant             = ls_source_allocation-allocation-source_plant
        required_date            = ls_source_allocation-allocation-required_date
        base_unit                = ls_source_allocation-base_unit
        allocated_base_quantity  = lv_quantity
        cumulative_base_quantity = lv_quantity
        confirmed_base_quantity  = lv_quantity
        atp_result               = VALUE #(
          material           = ls_source_allocation-allocation-material
          plant              = ls_source_allocation-allocation-source_plant
          unit               = ls_source_allocation-base_unit
          check_rule         = 'A'
          required_date      = ls_source_allocation-allocation-required_date
          requested_quantity = lv_quantity
          confirmed_date     = ls_source_allocation-allocation-required_date
          confirmed_quantity = lv_quantity
          is_fully_available = abap_true
          is_check_relevant  = abap_true ) )
        TO rs_allocation-atp_checks.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_multi_plant_allocation.
    rs_allocation = VALUE #(
      allocations       = VALUE #(
        ( allocation = VALUE #(
            request_id = 'REQ-1' material = 'MAT-1'
            target_plant = '2000' required_date = '20261010'
            requested_quantity = '5.000' available_quantity = '5.000'
            allocated_quantity = '5.000' shortfall_quantity = '0.000' )
          source_quantity = '5.000' source_unit = 'EA'
          base_quantity = '5.000' base_unit = 'EA'
          available_source_quantity = '5.000'
          allocated_source_quantity = '5.000' )
        ( allocation = VALUE #(
            request_id = 'REQ-2' material = 'MAT-2'
            target_plant = '3000' required_date = '20261012'
            requested_quantity = '5.000' available_quantity = '5.000'
            allocated_quantity = '5.000' shortfall_quantity = '0.000' )
          source_quantity = '5.000' source_unit = 'EA'
          base_quantity = '5.000' base_unit = 'EA'
          available_source_quantity = '5.000'
          allocated_source_quantity = '5.000' ) )
      plant_allocations = VALUE #(
        ( allocation = VALUE #(
            request_id = 'REQ-1' material = 'MAT-1'
            target_plant = '2000' source_plant = '1000'
            required_date = '20261010' available_quantity = '3.000'
            allocated_quantity = '3.000' )
          source_unit = 'EA' base_unit = 'EA'
          available_source_quantity = '3.000'
          allocated_source_quantity = '3.000' )
        ( allocation = VALUE #(
            request_id = 'REQ-1' material = 'MAT-1'
            target_plant = '2000' source_plant = '1100'
            required_date = '20261010' available_quantity = '2.000'
            allocated_quantity = '2.000' )
          source_unit = 'EA' base_unit = 'EA'
          available_source_quantity = '2.000'
          allocated_source_quantity = '2.000' )
        ( allocation = VALUE #(
            request_id = 'REQ-2' material = 'MAT-2'
            target_plant = '3000' source_plant = '1200'
            required_date = '20261012' available_quantity = '4.000'
            allocated_quantity = '4.000' )
          source_unit = 'EA' base_unit = 'EA'
          available_source_quantity = '4.000'
          allocated_source_quantity = '4.000' )
        ( allocation = VALUE #(
            request_id = 'REQ-2' material = 'MAT-2'
            target_plant = '3000' source_plant = '1300'
            required_date = '20261012' available_quantity = '1.000'
            allocated_quantity = '1.000' )
          source_unit = 'EA' base_unit = 'EA'
          available_source_quantity = '1.000'
          allocated_source_quantity = '1.000' ) ) ).
  ENDMETHOD.

  METHOD get_atp_fefo_alloc.
    rs_allocation-local_estimate = get_fefo_allocation( ).
    rs_allocation-local_estimate-plant_allocations = VALUE #(
      ( allocation                = VALUE #(
          request_id         = 'FEFO-REQ-1'
          material           = 'MAT-1'
          target_plant       = '2000'
          source_plant       = '1000'
          required_date      = '20261130'
          available_quantity = '5.000'
          allocated_quantity = '5.000' )
        source_unit               = 'BOX'
        base_unit                 = 'EA'
        available_source_quantity = '5.000'
        allocated_source_quantity = '5.000' )
      ( allocation                = VALUE #(
          request_id         = 'FEFO-REQ-2'
          material           = 'MAT-2'
          target_plant       = '3000'
          source_plant       = '1200'
          required_date      = '20261201'
          available_quantity = '4.000'
          allocated_quantity = '4.000' )
        source_unit               = 'EA'
        base_unit                 = 'EA'
        available_source_quantity = '4.000'
        allocated_source_quantity = '4.000' ) ).
    rs_allocation-atp_checks = VALUE #(
      ( request_id               = 'FEFO-REQ-1'
        material                 = 'MAT-1'
        target_plant             = '2000'
        source_plant             = '1000'
        required_date            = '20261130'
        base_unit                = 'EA'
        allocated_base_quantity  = '5.000'
        cumulative_base_quantity = '5.000'
        confirmed_base_quantity  = '5.000'
        atp_result               = VALUE #(
          material           = 'MAT-1'
          plant              = '1000'
          unit               = 'EA'
          check_rule         = 'A'
          required_date      = '20261130'
          requested_quantity = '5.000'
          confirmed_date     = '20261130'
          confirmed_quantity = '5.000'
          is_fully_available = abap_true
          is_check_relevant  = abap_true ) )
      ( request_id               = 'FEFO-REQ-2'
        material                 = 'MAT-2'
        target_plant             = '3000'
        source_plant             = '1200'
        required_date            = '20261201'
        base_unit                = 'EA'
        allocated_base_quantity  = '4.000'
        cumulative_base_quantity = '4.000'
        confirmed_base_quantity  = '4.000'
        atp_result               = VALUE #(
          material           = 'MAT-2'
          plant              = '1200'
          unit               = 'EA'
          check_rule         = 'A'
          required_date      = '20261201'
          requested_quantity = '4.000'
          confirmed_date     = '20261201'
          confirmed_quantity = '4.000'
          is_fully_available = abap_true
          is_check_relevant  = abap_true ) ) ).
  ENDMETHOD.

  METHOD get_multi_batch_allocation.
    rs_allocation = VALUE #(
      allocations       = VALUE #(
        ( allocation = VALUE #(
            request_id = 'BATCH-REQ-1' material = 'MAT-1'
            target_plant = '2000' batch = 'LOT-A'
            requested_quantity = '5.000' available_quantity = '5.000'
            allocated_quantity = '5.000' shortfall_quantity = '0.000' )
          source_quantity = '5.000' source_unit = 'EA'
          base_quantity = '5.000' base_unit = 'EA'
          available_source_quantity = '5.000'
          allocated_source_quantity = '5.000'
          shortfall_source_quantity = '0.000' )
        ( allocation = VALUE #(
            request_id = 'BATCH-REQ-2' material = 'MAT-2'
            target_plant = '3000' batch = 'LOT-C'
            requested_quantity = '4.000' available_quantity = '4.000'
            allocated_quantity = '4.000' shortfall_quantity = '0.000' )
          source_quantity = '4.000' source_unit = 'EA'
          base_quantity = '4.000' base_unit = 'EA'
          available_source_quantity = '4.000'
          allocated_source_quantity = '4.000'
          shortfall_source_quantity = '0.000' ) )
      plant_allocations = VALUE #(
        ( allocation = VALUE #(
            request_id = 'BATCH-REQ-1' material = 'MAT-1'
            target_plant = '2000' source_plant = '1000'
            batch = 'LOT-A' available_quantity = '3.000'
            allocated_quantity = '3.000' )
          source_unit = 'EA' base_unit = 'EA'
          available_source_quantity = '3.000'
          allocated_source_quantity = '3.000' )
        ( allocation = VALUE #(
            request_id = 'BATCH-REQ-1' material = 'MAT-1'
            target_plant = '2000' source_plant = '1000'
            batch = 'LOT-B' available_quantity = '2.000'
            allocated_quantity = '2.000' )
          source_unit = 'EA' base_unit = 'EA'
          available_source_quantity = '2.000'
          allocated_source_quantity = '2.000' )
        ( allocation = VALUE #(
            request_id = 'BATCH-REQ-2' material = 'MAT-2'
            target_plant = '3000' source_plant = '1200'
            batch = 'LOT-C' available_quantity = '4.000'
            allocated_quantity = '4.000' )
          source_unit = 'EA' base_unit = 'EA'
          available_source_quantity = '4.000'
          allocated_source_quantity = '4.000' ) ) ).
  ENDMETHOD.

  METHOD get_fefo_allocation.
    rs_allocation = VALUE #(
      allocations       = VALUE #(
        ( allocation = VALUE #(
            request_id = 'FEFO-REQ-1' material = 'MAT-1'
            target_plant = '2000' required_date = '20261130'
            requested_quantity = '5.000' available_quantity = '5.000'
            allocated_quantity = '5.000' shortfall_quantity = '0.000' )
          source_quantity = '5.000' source_unit = 'BOX'
          base_quantity = '50.000' base_unit = 'EA'
          available_source_quantity = '5.000'
          allocated_source_quantity = '5.000'
          shortfall_source_quantity = '0.000' )
        ( allocation = VALUE #(
            request_id = 'FEFO-REQ-2' material = 'MAT-2'
            target_plant = '3000' required_date = '20261201'
            requested_quantity = '4.000' available_quantity = '4.000'
            allocated_quantity = '4.000' shortfall_quantity = '0.000' )
          source_quantity = '4.000' source_unit = 'EA'
          base_quantity = '4.000' base_unit = 'EA'
          available_source_quantity = '4.000'
          allocated_source_quantity = '4.000'
          shortfall_source_quantity = '0.000' ) )
      batch_allocations = VALUE #(
        ( allocation = VALUE #(
            required_date = '20261130' priority = 1
            allocation = VALUE #(
              request_id = 'FEFO-REQ-1' material = 'MAT-1'
              target_plant = '2000' source_plant = '1000'
              storage_location = '0001' batch = 'FEFO-A'
              expiration_date = '20261215'
              available_quantity = '3.000' allocated_quantity = '3.000' ) )
          source_unit = 'BOX' base_unit = 'EA'
          available_source_quantity = '3.000'
          allocated_source_quantity = '3.000' )
        ( allocation = VALUE #(
            required_date = '20261130' priority = 1
            allocation = VALUE #(
              request_id = 'FEFO-REQ-1' material = 'MAT-1'
              target_plant = '2000' source_plant = '1000'
              storage_location = '0002' batch = 'FEFO-B'
              expiration_date = '20270110'
              available_quantity = '2.000' allocated_quantity = '2.000' ) )
          source_unit = 'BOX' base_unit = 'EA'
          available_source_quantity = '2.000'
          allocated_source_quantity = '2.000' )
        ( allocation = VALUE #(
            required_date = '20261201' priority = 1
            allocation = VALUE #(
              request_id = 'FEFO-REQ-2' material = 'MAT-2'
              target_plant = '3000' source_plant = '1200'
              storage_location = '0010' batch = 'FEFO-C'
              expiration_date = '20270201'
              available_quantity = '4.000' allocated_quantity = '4.000' ) )
          source_unit = 'EA' base_unit = 'EA'
          available_source_quantity = '4.000'
          allocated_source_quantity = '4.000' ) ) ).
  ENDMETHOD.

  METHOD get_sto_order_for_deletion.
    rs_order = VALUE #(
      purchase_order_number = '4500004321'
      submitted_items       = VALUE #(
        ( item_number       = '00010'
          source_request_id = 'REQ-1'
          material          = 'MAT-1'
          supplying_plant   = '1000'
          receiving_plant   = '2000'
          quantity          = '2.000'
          unit              = 'EA'
          delivery_date     = '20261010' ) )
      is_successful         = abap_true
      is_test_run           = abap_false
      bapi_was_called       = abap_true
      is_committed          = abap_true ).
  ENDMETHOD.

  METHOD get_sto_orders_for_deletion.
    DATA(ls_first_order) = get_sto_order_for_deletion( ).
    DATA(ls_second_order) = ls_first_order.
    ls_second_order-purchase_order_number = '4500004322'.
    ls_second_order-submitted_items[ 1 ]-source_request_id = 'REQ-2'.

    rs_orders = VALUE #(
      is_successful = abap_true
      is_test_run   = abap_false
      orders        = VALUE #(
        ( supplying_plant = '1000'
          receiving_plant = '2000'
          result          = ls_first_order )
        ( supplying_plant = '1100'
          receiving_plant = '3000'
          result          = ls_second_order ) ) ).
  ENDMETHOD.

  METHOD creates_order_from_allocation.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_write_result( is_result = VALUE #(
      purchase_order_number = '4500001234'
      is_successful         = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc(
      io_api = lo_api ).

    DATA(ls_result) = lo_cut->create_from_allocation(
      is_allocation            = VALUE #(
        allocations       = VALUE #(
          ( allocation = VALUE #(
              request_id = 'REQ-1' material = 'MAT-1'
              target_plant = '2000' required_date = '20261115'
              requested_quantity = '5.000' available_quantity = '5.000'
              allocated_quantity = '5.000' shortfall_quantity = '0.000' )
            source_quantity = '5.000' source_unit = 'EA'
            base_quantity = '5.000' base_unit = 'EA'
            available_source_quantity = '5.000'
            allocated_source_quantity = '5.000'
            shortfall_source_quantity = '0.000' )
          ( allocation = VALUE #(
              request_id = 'REQ-2' material = 'MAT-2'
              target_plant = '3000' required_date = '20261116'
              requested_quantity = '4.000' available_quantity = '0.000'
              allocated_quantity = '0.000' shortfall_quantity = '4.000' )
            source_quantity = '4.000' source_unit = 'EA'
            base_quantity = '4.000' base_unit = 'EA'
            available_source_quantity = '0.000'
            allocated_source_quantity = '0.000'
            shortfall_source_quantity = '4.000' ) )
        plant_allocations = VALUE #(
          ( allocation = VALUE #(
              request_id = 'REQ-1' material = 'MAT-1'
              target_plant = '2000' source_plant = '1000'
              required_date = '20261115' available_quantity = '5.000'
              allocated_quantity = '5.000' )
            source_unit = 'EA' base_unit = 'EA'
            available_source_quantity = '5.000'
            allocated_source_quantity = '5.000' )
          ( allocation = VALUE #(
              request_id = 'REQ-OTHER' material = 'MAT-3'
              target_plant = '2000' source_plant = '1100'
              required_date = '20261117' available_quantity = '2.000'
              allocated_quantity = '2.000' )
            source_unit = 'EA' base_unit = 'EA'
            available_source_quantity = '2.000'
            allocated_source_quantity = '2.000' ) ) )
      iv_supplying_plant       = '1000'
      iv_receiving_plant       = '2000'
      iv_receiving_storage_loc = '0001'
      iv_company_code          = '1000'
      iv_purchasing_org        = '1000'
      iv_purchasing_group      = '001' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500001234'
      act = ls_result-purchase_order_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lo_api->ms_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_stock_xfer_order_svc=>c_document_type
      act = lo_api->ms_request-document_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-1'
      act = lo_api->ms_request-items[ 1 ]-source_request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MAT-1'
      act = lo_api->ms_request-items[ 1 ]-material ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = lo_api->ms_request-items[ 1 ]-supplying_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = lo_api->ms_request-items[ 1 ]-receiving_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lo_api->ms_request-items[ 1 ]-receiving_storage_loc ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lo_api->ms_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261115' )
      act = lo_api->ms_request-items[ 1 ]-delivery_date ).
  ENDMETHOD.

  METHOD creates_batch_order.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_write_result( is_result = VALUE #(
      purchase_order_number = '4500002233'
      is_successful         = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc(
      io_api = lo_api ).

    DATA(ls_result) = lo_cut->create_from_batch_allocation(
      is_allocation            = VALUE #(
        allocations       = VALUE #(
          ( allocation = VALUE #(
              request_id = 'BATCH-REQ-1' material = 'MAT-1'
              target_plant = '2000' batch = 'LOT-0001'
              requested_quantity = '4.000' available_quantity = '4.000'
              allocated_quantity = '4.000' shortfall_quantity = '0.000' )
            source_quantity = '4.000' source_unit = 'BOX'
            base_quantity = '40.000' base_unit = 'EA'
            available_source_quantity = '4.000'
            allocated_source_quantity = '4.000'
            shortfall_source_quantity = '0.000' ) )
        plant_allocations = VALUE #(
          ( allocation = VALUE #(
              request_id = 'BATCH-REQ-1' material = 'MAT-1'
              target_plant = '2000' source_plant = '1000'
              batch = 'LOT-0001' available_quantity = '4.000'
              allocated_quantity = '4.000' )
            source_unit = 'BOX' base_unit = 'EA'
            available_source_quantity = '4.000'
            allocated_source_quantity = '4.000' ) ) )
      iv_supplying_plant       = '1000'
      iv_receiving_plant       = '2000'
      iv_delivery_date         = '20261120'
      iv_receiving_storage_loc = '0004'
      iv_company_code          = '1000'
      iv_purchasing_org        = '1000'
      iv_purchasing_group      = '001' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lo_api->ms_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LOT-0001'
      act = lo_api->ms_request-items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BATCH-REQ-1'
      act = lo_api->ms_request-items[ 1 ]-source_request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lo_api->ms_request-items[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lo_api->ms_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261120' )
      act = lo_api->ms_request-items[ 1 ]-delivery_date ).
  ENDMETHOD.

  METHOD creates_all_batch_plant_pairs.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_write_result( is_result = VALUE #(
      purchase_order_number = '4500003233'
      is_successful         = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc(
      io_api = lo_api ).
    DATA(lt_locations) = VALUE zcl_stock_xfer_order_svc=>ty_receiving_locations(
      ( receiving_plant = '2000' receiving_storage_loc = '0002' )
      ( receiving_plant = '3000' receiving_storage_loc = '0003' ) ).

    DATA(ls_result) = lo_cut->create_for_batch_pairs(
      is_allocation          = get_multi_batch_allocation( )
      iv_delivery_date       = '20261125'
      it_receiving_locations = lt_locations
      iv_company_code        = '1000'
      iv_purchasing_org      = '1000'
      iv_purchasing_group    = '001'
      iv_atomic              = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-orders ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-orders[ 1 ]-result-submitted_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LOT-A'
      act = ls_result-orders[ 1 ]-result-submitted_items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LOT-B'
      act = ls_result-orders[ 1 ]-result-submitted_items[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-orders[ 1 ]-result-submitted_items[ 1 ]-receiving_storage_loc ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LOT-C'
      act = ls_result-orders[ 2 ]-result-submitted_items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = ls_result-orders[ 2 ]-result-submitted_items[ 1 ]-receiving_storage_loc ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD validates_batch_pairs_first.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc(
      io_api = lo_api ).
    DATA(ls_allocation) = get_multi_batch_allocation( ).
    CLEAR ls_allocation-plant_allocations[ 3 ]-allocation-batch.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->create_for_batch_pairs(
          is_allocation       = ls_allocation
          iv_delivery_date    = '20261125'
          iv_company_code     = '1000'
          iv_purchasing_org   = '1000'
          iv_purchasing_group = '001' ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD creates_fefo_pair_orders.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_write_result( is_result = VALUE #(
      purchase_order_number = '4500004233'
      is_successful         = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc(
      io_api = lo_api ).
    DATA(lt_locations) = VALUE zcl_stock_xfer_order_svc=>ty_receiving_locations(
      ( receiving_plant = '2000' receiving_storage_loc = '0002' )
      ( receiving_plant = '3000' receiving_storage_loc = '0003' ) ).

    DATA(ls_result) = lo_cut->create_for_fefo_pairs(
      is_allocation          = get_fefo_allocation( )
      it_receiving_locations = lt_locations
      iv_company_code        = '1000'
      iv_purchasing_org      = '1000'
      iv_purchasing_group    = '001'
      iv_atomic              = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-orders ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-orders[ 1 ]-result-submitted_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'FEFO-A'
      act = ls_result-orders[ 1 ]-result-submitted_items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-orders[ 1 ]-result-submitted_items[ 1 ]-supplying_storage_loc ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-orders[ 1 ]-result-submitted_items[ 1 ]-receiving_storage_loc ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = ls_result-orders[ 1 ]-result-submitted_items[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-orders[ 1 ]-result-submitted_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261130' )
      act = ls_result-orders[ 1 ]-result-submitted_items[ 1 ]-delivery_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'FEFO-B'
      act = ls_result-orders[ 1 ]-result-submitted_items[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'FEFO-C'
      act = ls_result-orders[ 2 ]-result-submitted_items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261201' )
      act = ls_result-orders[ 2 ]-result-submitted_items[ 1 ]-delivery_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD validates_fefo_pairs_first.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc(
      io_api = lo_api ).
    DATA(ls_allocation) = get_fefo_allocation( ).
    CLEAR ls_allocation-batch_allocations[ 3 ]-allocation-required_date.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->create_for_fefo_pairs(
          is_allocation       = ls_allocation
          iv_company_code     = '1000'
          iv_purchasing_org   = '1000'
          iv_purchasing_group = '001' ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_batch_without_identity.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc(
      io_api = lo_api ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->create_from_batch_allocation(
          is_allocation       = VALUE #(
            plant_allocations = VALUE #(
              ( allocation = VALUE #(
                  request_id = 'BATCH-REQ-1' material = 'MAT-1'
                  target_plant = '2000' source_plant = '1000'
                  available_quantity = '1.000'
                  allocated_quantity = '1.000' )
                source_unit = 'EA' base_unit = 'EA'
                available_source_quantity = '1.000'
                allocated_source_quantity = '1.000' ) ) )
          iv_supplying_plant  = '1000'
          iv_receiving_plant  = '2000'
          iv_delivery_date    = '20261120'
          iv_company_code     = '1000'
          iv_purchasing_org   = '1000'
          iv_purchasing_group = '001' ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD simulates_order_without_commit.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_write_result( is_result = VALUE #(
      purchase_order_number = '4500005678'
      is_successful         = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc(
      io_api = lo_api ).

    DATA(ls_result) = lo_cut->create_from_allocation(
      is_allocation       = VALUE #(
        allocations       = VALUE #(
          ( allocation = VALUE #(
              request_id = 'REQ-1' material = 'MAT-1'
              target_plant = '2000' required_date = '20261115'
              requested_quantity = '2.000' available_quantity = '2.000'
              allocated_quantity = '2.000' shortfall_quantity = '0.000' )
            source_quantity = '2.000' source_unit = 'EA'
            base_quantity = '2.000' base_unit = 'EA'
            available_source_quantity = '2.000'
            allocated_source_quantity = '2.000' ) )
        plant_allocations = VALUE #(
          ( allocation = VALUE #(
              request_id = 'REQ-1' material = 'MAT-1'
              target_plant = '2000' source_plant = '1000'
              required_date = '20261115' available_quantity = '2.000'
              allocated_quantity = '2.000' )
            source_unit = 'EA' base_unit = 'EA'
            available_source_quantity = '2.000'
            allocated_source_quantity = '2.000' ) ) )
      iv_supplying_plant  = '1000'
      iv_receiving_plant  = '2000'
      iv_company_code     = '1000'
      iv_purchasing_org   = '1000'
      iv_purchasing_group = '001'
      iv_test_run         = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_commit_count( ) ).

  ENDMETHOD.

  METHOD creates_multi_source_orders.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_write_result( is_result = VALUE #(
      purchase_order_number = '4500001234'
      is_successful         = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc(
      io_api = lo_api ).

    DATA(ls_result) = lo_cut->create_from_source_plants(
      is_allocation       = get_multi_source_allocation( )
      iv_receiving_plant  = '2000'
      iv_company_code     = '1000'
      iv_purchasing_org   = '1000'
      iv_purchasing_group = '001'
      iv_test_run         = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = ls_result-receiving_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-orders ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = ls_result-orders[ 1 ]-supplying_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1100'
      act = ls_result-orders[ 2 ]-supplying_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = ls_result-orders[ 1 ]-result-submitted_items[ 1 ]-supplying_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1100'
      act = ls_result-orders[ 2 ]-result-submitted_items[ 1 ]-supplying_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-orders[ 1 ]-result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD commits_atomic_source_orders.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_write_result( is_result = VALUE #(
      purchase_order_number = '4500001234'
      is_successful         = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc(
      io_api = lo_api ).

    DATA(ls_result) = lo_cut->create_from_source_plants(
      is_allocation       = get_multi_source_allocation( )
      iv_receiving_plant  = '2000'
      iv_company_code     = '1000'
      iv_purchasing_org   = '1000'
      iv_purchasing_group = '001'
      iv_atomic           = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-orders ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-orders[ 1 ]-result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-orders[ 2 ]-result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_atomic_sources.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_write_result( is_result = VALUE #(
      purchase_order_number = '4500001234'
      is_successful         = abap_true ) ).
    lo_api->set_write_result_for_call(
      iv_call_number = 2
      is_result      = VALUE #(
        messages      = VALUE #( ( type = 'E' message = 'Create failed' ) )
        is_successful = abap_false ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc(
      io_api = lo_api ).

    DATA(ls_result) = lo_cut->create_from_source_plants(
      is_allocation       = get_multi_source_allocation( )
      iv_receiving_plant  = '2000'
      iv_company_code     = '1000'
      iv_purchasing_org   = '1000'
      iv_purchasing_group = '001'
      iv_atomic           = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-orders ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-orders[ 1 ]-result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-orders[ 1 ]-result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD fails_atomic_source_commit.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_write_result( is_result = VALUE #(
      purchase_order_number = '4500001234'
      is_successful         = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_false
      message       = VALUE #( type = 'E' message = 'Commit failed' ) ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc(
      io_api = lo_api ).

    DATA(ls_result) = lo_cut->create_from_source_plants(
      is_allocation       = get_multi_source_allocation( )
      iv_receiving_plant  = '2000'
      iv_company_code     = '1000'
      iv_purchasing_org   = '1000'
      iv_purchasing_group = '001'
      iv_atomic           = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-orders[ 1 ]-result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Commit failed'
      act = ls_result-orders[ 2 ]-result-messages[ 1 ]-message ).
  ENDMETHOD.

  METHOD creates_atp_source_orders.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_write_result( is_result = VALUE #(
      purchase_order_number = '4500001234'
      is_successful         = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc(
      io_api = lo_api ).

    DATA(ls_result) = lo_cut->create_from_atp_source_plants(
      is_allocation       = get_atp_source_alloc( )
      iv_receiving_plant  = '2000'
      iv_company_code     = '1000'
      iv_purchasing_org   = '1000'
      iv_purchasing_group = '001'
      iv_atomic           = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-orders ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = ls_result-orders[ 1 ]-supplying_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1100'
      act = ls_result-orders[ 2 ]-supplying_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-orders[ 1 ]-result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-orders[ 2 ]-result-is_committed ).
  ENDMETHOD.

  METHOD rejects_short_atp_sources.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc(
      io_api = lo_api ).
    DATA(ls_allocation) = get_atp_source_alloc( ).
    ls_allocation-atp_checks[ 1 ]-confirmed_base_quantity = '2.000'.
    ls_allocation-atp_checks[ 1 ]-atp_result-confirmed_quantity = '2.000'.
    ls_allocation-atp_checks[ 1 ]-atp_result-is_fully_available =
      abap_false.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->create_from_atp_source_plants(
          is_allocation       = ls_allocation
          iv_receiving_plant  = '2000'
          iv_company_code     = '1000'
          iv_purchasing_org   = '1000'
          iv_purchasing_group = '001'
          iv_test_run         = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_commit_count( ) ).

    DELETE ls_allocation-atp_checks INDEX 2.
    CLEAR lv_exception_raised.
    TRY.
        lo_cut->create_from_atp_source_plants(
          is_allocation       = ls_allocation
          iv_receiving_plant  = '2000'
          iv_company_code     = '1000'
          iv_purchasing_org   = '1000'
          iv_purchasing_group = '001'
          iv_test_run         = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD creates_atp_plant_pairs.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_write_result( is_result = VALUE #(
      purchase_order_number = '4500001234'
      is_successful         = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc(
      io_api = lo_api ).
    DATA(lt_locations) = VALUE zcl_stock_xfer_order_svc=>ty_receiving_locations(
      ( receiving_plant = '2000' receiving_storage_loc = '0002' )
      ( receiving_plant = '3000' receiving_storage_loc = '0003' ) ).

    DATA(ls_result) = lo_cut->create_for_atp_plant_pairs(
      is_allocation          = get_atp_pair_alloc( )
      it_receiving_locations = lt_locations
      iv_company_code        = '1000'
      iv_purchasing_org      = '1000'
      iv_purchasing_group    = '001'
      iv_atomic              = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( ls_result-orders ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = ls_result-orders[ 1 ]-supplying_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = ls_result-orders[ 1 ]-receiving_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-orders[ 4 ]-result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lo_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_short_atp_pairs.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc(
      io_api = lo_api ).
    DATA(ls_allocation) = get_atp_pair_alloc( ).
    ls_allocation-atp_checks[ 4 ]-confirmed_base_quantity = '0.000'.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->create_for_atp_plant_pairs(
          is_allocation       = ls_allocation
          iv_company_code     = '1000'
          iv_purchasing_org   = '1000'
          iv_purchasing_group = '001' ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD creates_atp_fefo_pairs.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_write_result( is_result = VALUE #(
      purchase_order_number = '4500005233'
      is_successful         = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc(
      io_api = lo_api ).
    DATA(lt_locations) = VALUE zcl_stock_xfer_order_svc=>ty_receiving_locations(
      ( receiving_plant = '2000' receiving_storage_loc = '0002' )
      ( receiving_plant = '3000' receiving_storage_loc = '0003' ) ).

    DATA(ls_result) = lo_cut->create_for_atp_fefo_pairs(
      is_allocation          = get_atp_fefo_alloc( )
      it_receiving_locations = lt_locations
      iv_company_code        = '1000'
      iv_purchasing_org      = '1000'
      iv_purchasing_group    = '001'
      iv_atomic              = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-orders ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-orders[ 1 ]-result-submitted_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'FEFO-A'
      act = ls_result-orders[ 1 ]-result-submitted_items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-orders[ 2 ]-result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_short_atp_fefo.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc(
      io_api = lo_api ).
    DATA(ls_allocation) = get_atp_fefo_alloc( ).
    ls_allocation-atp_checks[ 1 ]-confirmed_base_quantity = '0.000'.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->create_for_atp_fefo_pairs(
          is_allocation       = ls_allocation
          iv_company_code     = '1000'
          iv_purchasing_org   = '1000'
          iv_purchasing_group = '001' ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD creates_all_plant_pairs.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_write_result( is_result = VALUE #(
      purchase_order_number = '4500001234'
      is_successful         = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc(
      io_api = lo_api ).
    DATA(lt_locations) = VALUE zcl_stock_xfer_order_svc=>ty_receiving_locations(
      ( receiving_plant = '2000' receiving_storage_loc = '0002' )
      ( receiving_plant = '3000' receiving_storage_loc = '0003' ) ).

    DATA(ls_result) = lo_cut->create_for_all_plant_pairs(
      is_allocation          = get_multi_plant_allocation( )
      it_receiving_locations = lt_locations
      iv_company_code        = '1000'
      iv_purchasing_org      = '1000'
      iv_purchasing_group    = '001'
      iv_atomic              = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( ls_result-orders ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = ls_result-orders[ 1 ]-supplying_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = ls_result-orders[ 1 ]-receiving_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-orders[ 1 ]-result-submitted_items[ 1 ]-receiving_storage_loc ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1300'
      act = ls_result-orders[ 4 ]-supplying_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = '3000'
      act = ls_result-orders[ 4 ]-receiving_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = ls_result-orders[ 4 ]-result-submitted_items[ 1 ]-receiving_storage_loc ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lo_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD fails_atomic_plant_pairs.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_write_result( is_result = VALUE #(
      purchase_order_number = '4500001234'
      is_successful         = abap_true ) ).
    lo_api->set_write_result_for_call(
      iv_call_number = 2
      is_result      = VALUE #(
        is_successful = abap_false
        messages      = VALUE #(
          ( type = 'E' message = 'Second STO failed' ) ) ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc(
      io_api = lo_api ).

    DATA(ls_result) = lo_cut->create_for_all_plant_pairs(
      is_allocation       = get_multi_plant_allocation( )
      iv_company_code     = '1000'
      iv_purchasing_org   = '1000'
      iv_purchasing_group = '001'
      iv_atomic           = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-orders ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-orders[ 1 ]-result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-orders[ 1 ]-result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD fails_atomic_pair_commit.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_write_result( is_result = VALUE #(
      purchase_order_number = '4500001234'
      is_successful         = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_false
      message       = VALUE #( type = 'E' message = 'Commit failed' ) ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc(
      io_api = lo_api ).

    DATA(ls_result) = lo_cut->create_for_batch_pairs(
      is_allocation       = get_multi_batch_allocation( )
      iv_delivery_date    = '20261125'
      iv_company_code     = '1000'
      iv_purchasing_org   = '1000'
      iv_purchasing_group = '001'
      iv_atomic           = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-orders[ 1 ]-result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Commit failed'
      act = ls_result-orders[ 2 ]-result-messages[ 1 ]-message ).
  ENDMETHOD.

  METHOD validates_pairs_first.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc(
      io_api = lo_api ).
    DATA(ls_allocation) = get_multi_plant_allocation( ).
    CLEAR ls_allocation-plant_allocations[ 4 ]-allocation-required_date.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->create_for_all_plant_pairs(
          is_allocation       = ls_allocation
          iv_company_code     = '1000'
          iv_purchasing_org   = '1000'
          iv_purchasing_group = '001' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_location_map.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc(
      io_api = lo_api ).
    DATA(lt_locations) = VALUE zcl_stock_xfer_order_svc=>ty_receiving_locations(
      ( receiving_plant = '2000' receiving_storage_loc = '0002' )
      ( receiving_plant = '2000' receiving_storage_loc = '0003' ) ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->create_for_all_plant_pairs(
          is_allocation          = get_multi_plant_allocation( )
          it_receiving_locations = lt_locations
          iv_company_code        = '1000'
          iv_purchasing_org      = '1000'
          iv_purchasing_group    = '001' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD validates_sources_first.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc(
      io_api = lo_api ).
    DATA(ls_allocation) = get_multi_source_allocation( ).
    CLEAR ls_allocation-plant_allocations[ 2 ]-allocation-required_date.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->create_from_source_plants(
          is_allocation       = ls_allocation
          iv_receiving_plant  = '2000'
          iv_company_code     = '1000'
          iv_purchasing_org   = '1000'
          iv_purchasing_group = '001' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD reports_pair_failure.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_write_result( is_result = VALUE #(
      purchase_order_number = '4500001234'
      is_successful         = abap_true ) ).
    lo_api->set_write_result_for_call(
      iv_call_number = 2
      is_result      = VALUE #(
        is_successful = abap_false
        messages      = VALUE #(
          ( type = 'E' message = 'Second STO failed' ) ) ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc(
      io_api = lo_api ).

    DATA(ls_result) = lo_cut->create_for_all_plant_pairs(
      is_allocation       = get_multi_plant_allocation( )
      iv_company_code     = '1000'
      iv_purchasing_org   = '1000'
      iv_purchasing_group = '001' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( ls_result-orders ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-orders[ 1 ]-result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-orders[ 2 ]-result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-orders[ 3 ]-result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rejects_short_allocation.
    DATA lv_shortfall_rejected TYPE abap_bool.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc(
      io_api = lo_api ).

    TRY.
        lo_cut->create_from_allocation(
          is_allocation       = VALUE #(
            allocations       = VALUE #(
              ( allocation = VALUE #(
                  request_id = 'REQ-1' material = 'MAT-1'
                  target_plant = '2000' required_date = '20261115'
                  requested_quantity = '5.000'
                  available_quantity = '3.000'
                  allocated_quantity = '3.000'
                  shortfall_quantity = '2.000' )
                source_quantity = '5.000' source_unit = 'EA'
                base_quantity = '5.000' base_unit = 'EA'
                available_source_quantity = '3.000'
                allocated_source_quantity = '3.000'
                shortfall_source_quantity = '2.000' ) )
            plant_allocations = VALUE #(
              ( allocation = VALUE #(
                  request_id = 'REQ-1' material = 'MAT-1'
                  target_plant = '2000' source_plant = '1000'
                  required_date = '20261115' available_quantity = '3.000'
                  allocated_quantity = '3.000' )
                source_unit = 'EA' base_unit = 'EA'
                available_source_quantity = '3.000'
                allocated_source_quantity = '3.000' ) ) )
          iv_supplying_plant  = '1000'
          iv_receiving_plant  = '2000'
          iv_company_code     = '1000'
          iv_purchasing_org   = '1000'
          iv_purchasing_group = '001' ).
      CATCH zcx_invalid_stock_request.
        lv_shortfall_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_shortfall_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_create_error.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_write_result( is_result = VALUE #(
      is_successful = abap_false
      messages      = VALUE #(
        ( type = 'E' message = 'STO creation failed' ) ) ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc(
      io_api = lo_api ).

    DATA(ls_result) = lo_cut->create_from_allocation(
      is_allocation       = VALUE #(
        plant_allocations = VALUE #(
          ( allocation = VALUE #(
              request_id = 'REQ-1' material = 'MAT-1'
              target_plant = '2000' source_plant = '1000'
              required_date = '20261115' allocated_quantity = '2.000' )
            source_unit = 'EA' base_unit = 'EA'
            available_source_quantity = '2.000'
            allocated_source_quantity = '2.000' ) ) )
      iv_supplying_plant  = '1000'
      iv_receiving_plant  = '2000'
      iv_company_code     = '1000'
      iv_purchasing_org   = '1000'
      iv_purchasing_group = '001' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_commit_error.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_write_result( is_result = VALUE #(
      purchase_order_number = '4500009999'
      is_successful         = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_false
      message       = VALUE #(
        type = 'E' message = 'Commit failed' ) ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc(
      io_api = lo_api ).

    DATA(ls_result) = lo_cut->create_from_allocation(
      is_allocation       = VALUE #(
        plant_allocations = VALUE #(
          ( allocation = VALUE #(
              request_id = 'REQ-1' material = 'MAT-1'
              target_plant = '2000' source_plant = '1000'
              required_date = '20261115' allocated_quantity = '2.000' )
            source_unit = 'EA' base_unit = 'EA'
            available_source_quantity = '2.000'
            allocated_source_quantity = '2.000' ) ) )
      iv_supplying_plant  = '1000'
      iv_receiving_plant  = '2000'
      iv_company_code     = '1000'
      iv_purchasing_org   = '1000'
      iv_purchasing_group = '001' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Commit failed'
      act = ls_result-messages[ 1 ]-message ).
  ENDMETHOD.

  METHOD deletes_single_sto.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_change_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc( io_api = lo_api ).
    DATA(ls_order) = get_sto_order_for_deletion( ).

    DATA(ls_result) = lo_cut->mark_sto_for_deletion(
      is_order = ls_order ).
    DATA(ls_delete_call) = lo_api->get_delete_call(
      iv_call_number = 1 ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_attempted ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_deleted ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500004321'
      act = ls_delete_call-purchase_order ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00010'
      act = ls_delete_call-item_numbers[ 1 ] ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD continues_sto_delete_failure.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_change_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    lo_api->set_change_result_for_call(
      iv_call_number = 1
      is_result      = VALUE #(
        is_successful = abap_false
        messages      = VALUE #(
          ( type = 'E' message = 'First STO item deletion failed' ) ) ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc( io_api = lo_api ).
    DATA(ls_orders_input) = get_sto_orders_for_deletion( ).

    DATA(ls_result) = lo_cut->mark_sto_pairs_for_deletion(
      is_orders = ls_orders_input ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_api->get_delete_count( ) ).
    DATA(ls_first_delete) = lo_api->get_delete_call(
      iv_call_number = 1 ).
    DATA(ls_second_delete) = lo_api->get_delete_call(
      iv_call_number = 2 ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500004321'
      act = ls_first_delete-purchase_order ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500004322'
      act = ls_second_delete-purchase_order ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-orders[ 1 ]-deletion-is_deleted ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-orders[ 2 ]-deletion-is_deleted ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD deletes_sto_pairs_atomically.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_change_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc( io_api = lo_api ).

    DATA(ls_result) = lo_cut->mark_sto_pairs_for_deletion(
      is_orders = get_sto_orders_for_deletion( )
      iv_atomic = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_api->get_delete_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-orders[ 1 ]-deletion-is_deleted ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-orders[ 2 ]-deletion-is_deleted ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_atomic_sto_delete.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_change_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    lo_api->set_change_result_for_call(
      iv_call_number = 2
      is_result      = VALUE #(
        is_successful = abap_false
        messages      = VALUE #(
          ( type = 'E' message = 'Second deletion failed' ) ) ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc( io_api = lo_api ).

    DATA(ls_result) = lo_cut->mark_sto_pairs_for_deletion(
      is_orders = get_sto_orders_for_deletion( )
      iv_atomic = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_api->get_delete_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-orders[ 1 ]-deletion-is_deleted ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-orders[ 2 ]-deletion-is_deleted ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD fails_atomic_delete_commit.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_change_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_false
      message       = VALUE #(
        type = 'E' message = 'Atomic deletion commit failed' ) ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc( io_api = lo_api ).

    DATA(ls_result) = lo_cut->mark_sto_pairs_for_deletion(
      is_orders = get_sto_orders_for_deletion( )
      iv_atomic = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-orders[ 1 ]-deletion-is_deleted ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Atomic deletion commit failed'
      act = ls_result-orders[ 2 ]-deletion-deletion_messages[ 1 ]-message ).
  ENDMETHOD.

  METHOD rejects_atomic_ineligible_sto.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc( io_api = lo_api ).
    DATA(ls_orders) = get_sto_orders_for_deletion( ).
    CLEAR ls_orders-orders[ 2 ]-result-is_committed.
    ls_orders-orders[ 2 ]-result-is_test_run = abap_true.

    DATA(ls_result) = lo_cut->mark_sto_pairs_for_deletion(
      is_orders = ls_orders
      iv_atomic = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-orders[ 1 ]-deletion-is_attempted ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_delete_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD prevalidates_sto_deletions.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc( io_api = lo_api ).
    DATA(ls_orders) = get_sto_orders_for_deletion( ).
    CLEAR ls_orders-orders[ 2 ]-result-submitted_items[ 1 ]-item_number.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->mark_sto_pairs_for_deletion( is_orders = ls_orders ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_delete_count( ) ).
  ENDMETHOD.

  METHOD skips_uncommitted_sto_deletion.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_change_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc( io_api = lo_api ).
    DATA(ls_orders) = get_sto_orders_for_deletion( ).
    CLEAR ls_orders-orders[ 1 ]-result-is_committed.
    ls_orders-orders[ 1 ]-result-is_test_run = abap_true.

    DATA(ls_result) = lo_cut->mark_sto_pairs_for_deletion(
      is_orders = ls_orders ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-orders[ 1 ]-deletion-is_attempted ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-orders[ 2 ]-deletion-is_deleted ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_delete_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_deletion_commit.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_change_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_false
      message       = VALUE #(
        type = 'E' message = 'Deletion commit failed' ) ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc( io_api = lo_api ).
    DATA(ls_order) = get_sto_order_for_deletion( ).

    DATA(ls_result) = lo_cut->mark_sto_for_deletion(
      is_order = ls_order ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_attempted ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_deleted ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Deletion commit failed'
      act = ls_result-deletion_messages[ 1 ]-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD completes_single_sto_delivery.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_change_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc( io_api = lo_api ).
    DATA(ls_order) = get_sto_order_for_deletion( ).

    DATA(ls_result) = lo_cut->mark_sto_delivery_complete(
      is_order = ls_order ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_completed ).
    DATA(ls_call) = lo_api->get_delivery_complete_call(
      iv_call_number = 1 ).
    cl_abap_unit_assert=>assert_equals(
      exp = ls_order-purchase_order_number
      act = ls_call-purchase_order ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00010'
      act = ls_call-item_numbers[ 1 ] ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD continues_complete_failure.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_change_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    lo_api->set_change_result_for_call(
      iv_call_number = 1
      is_result      = VALUE #(
        is_successful = abap_false
        messages      = VALUE #(
          ( type = 'E' message = 'Delivery completion failed' ) ) ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc( io_api = lo_api ).
    DATA(ls_orders_input) = get_sto_orders_for_deletion( ).

    DATA(ls_result) = lo_cut->mark_sto_pairs_deliv_complete(
      is_orders = ls_orders_input ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_api->get_delivery_complete_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-orders[ 1 ]-delivery_completion-is_completed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-orders[ 2 ]-delivery_completion-is_completed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD completes_pairs_atomically.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_change_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc( io_api = lo_api ).

    DATA(ls_result) = lo_cut->mark_sto_pairs_deliv_complete(
      is_orders = get_sto_orders_for_deletion( )
      iv_atomic = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_api->get_delivery_complete_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-orders[ 1 ]-delivery_completion-is_completed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-orders[ 2 ]-delivery_completion-is_completed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_atomic_complete.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_change_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    lo_api->set_change_result_for_call(
      iv_call_number = 2
      is_result      = VALUE #(
        is_successful = abap_false
        messages      = VALUE #(
          ( type = 'E' message = 'Second completion failed' ) ) ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc( io_api = lo_api ).

    DATA(ls_result) = lo_cut->mark_sto_pairs_deliv_complete(
      is_orders = get_sto_orders_for_deletion( )
      iv_atomic = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_api->get_delivery_complete_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-orders[ 1 ]-delivery_completion-is_completed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-orders[ 2 ]-delivery_completion-is_completed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD fails_atomic_complete_commit.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_change_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_false
      message       = VALUE #(
        type = 'E' message = 'Atomic completion commit failed' ) ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc( io_api = lo_api ).

    DATA(ls_result) = lo_cut->mark_sto_pairs_deliv_complete(
      is_orders = get_sto_orders_for_deletion( )
      iv_atomic = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-orders[ 1 ]-delivery_completion-is_completed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Atomic completion commit failed'
      act = ls_result-orders[ 2 ]-delivery_completion-completion_messages[ 1 ]-message ).
  ENDMETHOD.

  METHOD rejects_atomic_complete_input.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc( io_api = lo_api ).
    DATA(ls_orders) = get_sto_orders_for_deletion( ).
    CLEAR ls_orders-orders[ 2 ]-result-is_committed.
    ls_orders-orders[ 2 ]-result-is_test_run = abap_true.

    DATA(ls_result) = lo_cut->mark_sto_pairs_deliv_complete(
      is_orders = ls_orders
      iv_atomic = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-orders[ 1 ]-delivery_completion-is_attempted ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_delivery_complete_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD prevalidates_sto_completion.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc( io_api = lo_api ).
    DATA(ls_orders) = get_sto_orders_for_deletion( ).
    CLEAR ls_orders-orders[ 2 ]-result-submitted_items[ 1 ]-item_number.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->mark_sto_pairs_deliv_complete(
          is_orders = ls_orders ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_delivery_complete_count( ) ).
  ENDMETHOD.

  METHOD skips_uncommitted_completion.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_change_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc( io_api = lo_api ).
    DATA(ls_orders) = get_sto_orders_for_deletion( ).
    CLEAR ls_orders-orders[ 1 ]-result-is_committed.
    ls_orders-orders[ 1 ]-result-is_test_run = abap_true.

    DATA(ls_result) = lo_cut->mark_sto_pairs_deliv_complete(
      is_orders = ls_orders ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-orders[ 1 ]-delivery_completion-is_attempted ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-orders[ 2 ]-delivery_completion-is_completed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_delivery_complete_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_completion_commit.
    DATA(lo_api) = NEW lcl_sto_api_double( ).
    lo_api->set_change_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_false
      message       = VALUE #(
        type = 'E' message = 'Completion commit failed' ) ) ).
    DATA(lo_cut) = NEW zcl_stock_xfer_order_svc( io_api = lo_api ).
    DATA(ls_order) = get_sto_order_for_deletion( ).

    DATA(ls_result) = lo_cut->mark_sto_delivery_complete(
      is_order = ls_order ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_attempted ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_completed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Completion commit failed'
      act = ls_result-completion_messages[ 1 ]-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_rollback_count( ) ).
  ENDMETHOD.
ENDCLASS.
