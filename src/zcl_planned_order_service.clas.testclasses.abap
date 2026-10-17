CLASS lcl_planned_order_api DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_planned_order_api.
    DATA requests TYPE zif_planned_order_api=>ty_requests.
    DATA deleted_orders TYPE zif_planned_order_api=>ty_order_numbers.
    DATA change_requests TYPE zif_planned_order_api=>ty_change_requests.
    DATA converted_orders TYPE zif_planned_order_api=>ty_order_numbers.
    DATA create_calls TYPE i.
    DATA delete_calls TYPE i.
    DATA change_calls TYPE i.
    DATA conversion_calls TYPE i.
    DATA fail_on_call TYPE i.
    DATA delete_fail_on_call TYPE i.
    DATA change_fail_on_call TYPE i.
    DATA conversion_fail_on_call TYPE i.
    DATA commit_calls TYPE i.
    DATA rollback_calls TYPE i.
    DATA commit_success TYPE abap_bool.
    DATA fail_commit_on_call TYPE i.
ENDCLASS.

CLASS lcl_planned_order_api IMPLEMENTATION.
  METHOD zif_planned_order_api~create_order.
    APPEND is_request TO requests.
    ADD 1 TO create_calls.
    rs_result-is_successful = abap_true.
    DATA lv_order_number TYPE n LENGTH 10.
    lv_order_number = create_calls.
    rs_result-planned_order = lv_order_number.
    IF create_calls = fail_on_call.
      rs_result-is_successful = abap_false.
      rs_result-message-type = 'E'.
      rs_result-message-message = 'Planned order creation failed'.
    ENDIF.
  ENDMETHOD.

  METHOD zif_planned_order_api~delete_order.
    APPEND iv_planned_order TO deleted_orders.
    ADD 1 TO delete_calls.
    rs_result-planned_order = iv_planned_order.
    rs_result-is_successful = abap_true.
    IF delete_calls = delete_fail_on_call.
      rs_result-is_successful = abap_false.
      rs_result-message-type = 'E'.
      rs_result-message-message = 'Planned order deletion failed'.
    ENDIF.
  ENDMETHOD.

  METHOD zif_planned_order_api~change_order.
    APPEND is_request TO change_requests.
    ADD 1 TO change_calls.
    rs_result-planned_order = is_request-planned_order.
    rs_result-is_successful = abap_true.
    IF change_calls = change_fail_on_call.
      rs_result-is_successful = abap_false.
      rs_result-message-type = 'E'.
      rs_result-message-message = 'Planned order change failed'.
    ENDIF.
  ENDMETHOD.

  METHOD zif_planned_order_api~convert_order.
    APPEND iv_planned_order TO converted_orders.
    ADD 1 TO conversion_calls.
    rs_result-planned_order = iv_planned_order.
    DATA lv_production_order TYPE n LENGTH 12.
    lv_production_order = conversion_calls.
    rs_result-production_order = lv_production_order.
    rs_result-is_successful = abap_true.
    IF conversion_calls = conversion_fail_on_call.
      rs_result-is_successful = abap_false.
      rs_result-message-type = 'E'.
      rs_result-message-message = 'Planned order conversion failed'.
    ENDIF.
  ENDMETHOD.

  METHOD zif_planned_order_api~commit.
    ADD 1 TO commit_calls.
    rs_result-is_successful = commit_success.
    IF commit_success = abap_false OR commit_calls = fail_commit_on_call.
      rs_result-is_successful = abap_false.
      rs_result-message-type = 'E'.
      rs_result-message-message = 'Commit failed'.
    ENDIF.
  ENDMETHOD.

  METHOD zif_planned_order_api~rollback.
    ADD 1 TO rollback_calls.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_planned_order_service DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS creates_multiple_atomically FOR TESTING
      RAISING cx_static_check.
    METHODS rolls_back_failed_create FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_bad_input_before_api FOR TESTING
      RAISING cx_static_check.
    METHODS rolls_back_failed_commit FOR TESTING
      RAISING cx_static_check.
    METHODS creates_from_lot_suggestion FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_external_suggestion FOR TESTING
      RAISING cx_static_check.
    METHODS prepares_lots_without_writing FOR TESTING
      RAISING cx_static_check.
    METHODS deletes_multiple_atomically FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_duplicate_delete_keys FOR TESTING
      RAISING cx_static_check.
    METHODS rolls_back_failed_delete FOR TESTING
      RAISING cx_static_check.
    METHODS rolls_back_delete_commit FOR TESTING
      RAISING cx_static_check.
    METHODS bulk_create_commits_each FOR TESTING
      RAISING cx_static_check.
    METHODS bulk_suggestion_maps_indexes FOR TESTING
      RAISING cx_static_check.
    METHODS bulk_create_continues_on_error FOR TESTING
      RAISING cx_static_check.
    METHODS bulk_create_commit_failure FOR TESTING
      RAISING cx_static_check.
    METHODS bulk_delete_continues_on_error FOR TESTING
      RAISING cx_static_check.
    METHODS bulk_delete_commit_failure FOR TESTING
      RAISING cx_static_check.
    METHODS changes_orders_atomically FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_bad_change_requests FOR TESTING
      RAISING cx_static_check.
    METHODS rolls_back_failed_change FOR TESTING
      RAISING cx_static_check.
    METHODS rolls_back_change_commit FOR TESTING
      RAISING cx_static_check.
    METHODS bulk_change_continues_on_error FOR TESTING
      RAISING cx_static_check.
    METHODS bulk_change_commit_failure FOR TESTING
      RAISING cx_static_check.
    METHODS converts_orders_atomically FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_duplicate_convert_keys FOR TESTING
      RAISING cx_static_check.
    METHODS rolls_back_failed_conversion FOR TESTING
      RAISING cx_static_check.
    METHODS bulk_convert_continues_error FOR TESTING
      RAISING cx_static_check.
    METHODS bulk_conversion_commit_failure FOR TESTING
      RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_planned_order_service IMPLEMENTATION.
  METHOD creates_multiple_atomically.
    DATA(lo_api) = NEW lcl_planned_order_api( ).
    lo_api->commit_success = abap_true.
    DATA(lo_cut) = NEW zcl_planned_order_service( lo_api ).

    DATA(ls_result) = lo_cut->create_orders_atomic(
      it_requests = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          quantity = '12.000' planned_end_date = '20261115' )
        ( material = 'MAT-2' plant = '2000'
          quantity = '2.500' planned_end_date = '20261120' ) ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-orders )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->requests[ 2 ]-planned_end_date
      exp = '20261120' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-planned_order-planned_order
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 2 ]-is_committed ).
  ENDMETHOD.

  METHOD rolls_back_failed_create.
    DATA(lo_api) = NEW lcl_planned_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_on_call = 2.
    DATA(lo_cut) = NEW zcl_planned_order_service( lo_api ).

    DATA(ls_result) = lo_cut->create_orders_atomic(
      it_requests = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          quantity = '12.000' planned_end_date = '20261115' )
        ( material = 'MAT-2' plant = '1000'
          quantity = '2.500' planned_end_date = '20261120' )
        ( material = 'MAT-3' plant = '1000'
          quantity = '1.000' planned_end_date = '20261121' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->create_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 1 ]-planned_order-planned_order ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-planned_order-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-planned_order-message-type
      exp = 'E' ).
  ENDMETHOD.

  METHOD rejects_bad_input_before_api.
    DATA(lo_api) = NEW lcl_planned_order_api( ).
    DATA(lo_cut) = NEW zcl_planned_order_service( lo_api ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->create_orders_atomic(
          it_requests = VALUE #(
            ( material = 'MAT-1' plant = '1000'
              quantity = '12.000' planned_end_date = '20261115' )
            ( material = 'MAT-2' plant = '1000'
              quantity = '0.000' planned_end_date = '20261120' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->create_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rolls_back_failed_commit.
    DATA(lo_api) = NEW lcl_planned_order_api( ).
    lo_api->commit_success = abap_false.
    DATA(lo_cut) = NEW zcl_planned_order_service( lo_api ).

    DATA(ls_result) = lo_cut->create_orders_atomic(
      it_requests = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          quantity = '12.000' planned_end_date = '20261115' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_false(
      ls_result-commit_result-is_successful ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 1 ]-planned_order-planned_order ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD creates_from_lot_suggestion.
    DATA(lo_api) = NEW lcl_planned_order_api( ).
    lo_api->commit_success = abap_true.
    DATA(lo_cut) = NEW zcl_planned_order_service( lo_api ).

    DATA(ls_result) = lo_cut->create_from_suggestions(
      it_suggestions = VALUE #(
        ( material                    = 'MAT-1'
          plant                       = '1000'
          base_unit                   = 'EA'
          required_date               = '20261115'
          procurement_type            = 'E'
          suggested_base_quantity     = '25.000'
          suggested_receipt_count     = 3
          maximum_base_quantity       = '10.000'
          final_receipt_base_quantity = '5.000' ) ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lo_api->requests )
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->requests[ 1 ]-quantity
      exp = '10.000' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->requests[ 3 ]-quantity
      exp = '5.000' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->requests[ 2 ]-planned_end_date
      exp = '20261115' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 3 ]-source_suggestion_index
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 3 ]-receipt_index
      exp = 3 ).
  ENDMETHOD.

  METHOD rejects_external_suggestion.
    DATA(lo_api) = NEW lcl_planned_order_api( ).
    DATA(lo_cut) = NEW zcl_planned_order_service( lo_api ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->create_from_suggestions(
          it_suggestions = VALUE #(
            ( material                    = 'MAT-1'
              plant                       = '1000'
              base_unit                   = 'EA'
              required_date               = '20261115'
              procurement_type            = 'F'
              suggested_base_quantity     = '2.000'
              suggested_receipt_count     = 1
              final_receipt_base_quantity = '2.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->create_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD prepares_lots_without_writing.
    DATA(lo_api) = NEW lcl_planned_order_api( ).
    DATA(lo_cut) = NEW zcl_planned_order_service( lo_api ).

    DATA(lt_plan) = lo_cut->prepare_from_suggestions(
      it_suggestions = VALUE #(
        ( material                    = 'MAT-1'
          plant                       = '1000'
          base_unit                   = 'EA'
          required_date               = '20261115'
          procurement_type            = 'E'
          suggested_base_quantity     = '25.000'
          suggested_receipt_count     = 3
          maximum_base_quantity       = '10.000'
          final_receipt_base_quantity = '5.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_plan )
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_plan[ 1 ]-request-quantity
      exp = '10.000' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_plan[ 3 ]-request-quantity
      exp = '5.000' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_plan[ 3 ]-source_suggestion_index
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_plan[ 3 ]-receipt_index
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->create_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD deletes_multiple_atomically.
    DATA(lo_api) = NEW lcl_planned_order_api( ).
    lo_api->commit_success = abap_true.
    DATA(lo_cut) = NEW zcl_planned_order_service( lo_api ).

    DATA(ls_result) = lo_cut->delete_orders_atomic(
      it_planned_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' ) ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->deleted_orders[ 2 ]
      exp = '0000000102' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 1 ]-is_committed ).
  ENDMETHOD.

  METHOD rejects_duplicate_delete_keys.
    DATA(lo_api) = NEW lcl_planned_order_api( ).
    DATA(lo_cut) = NEW zcl_planned_order_service( lo_api ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->delete_orders_atomic(
          it_planned_orders = VALUE #(
            ( '0000000101' )
            ( '0000000101' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->delete_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rolls_back_failed_delete.
    DATA(lo_api) = NEW lcl_planned_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->delete_fail_on_call = 2.
    DATA(lo_cut) = NEW zcl_planned_order_service( lo_api ).

    DATA(ls_result) = lo_cut->delete_orders_atomic(
      it_planned_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' )
        ( '0000000103' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->delete_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-planned_order-message-type
      exp = 'E' ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-planned_order-is_successful ).
  ENDMETHOD.

  METHOD rolls_back_delete_commit.
    DATA(lo_api) = NEW lcl_planned_order_api( ).
    lo_api->commit_success = abap_false.
    DATA(lo_cut) = NEW zcl_planned_order_service( lo_api ).

    DATA(ls_result) = lo_cut->delete_orders_atomic(
      it_planned_orders = VALUE #(
        ( '0000000101' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_false(
      ls_result-commit_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD bulk_create_commits_each.
    DATA(lo_api) = NEW lcl_planned_order_api( ).
    lo_api->commit_success = abap_true.
    DATA(lo_cut) = NEW zcl_planned_order_service( lo_api ).

    DATA(ls_result) = lo_cut->create_orders_bulk(
      it_requests = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          quantity = '2.000' planned_end_date = '20261115' )
        ( material = 'MAT-2' plant = '1000'
          quantity = '3.000' planned_end_date = '20261116' ) ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-successful_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 2 ]-is_committed ).
  ENDMETHOD.

  METHOD bulk_suggestion_maps_indexes.
    DATA(lo_api) = NEW lcl_planned_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_on_call = 2.
    DATA(lo_cut) = NEW zcl_planned_order_service( lo_api ).

    DATA(ls_result) = lo_cut->create_from_suggestions_bulk(
      it_suggestions = VALUE #(
        ( material                    = 'MAT-1'
          plant                       = '1000'
          base_unit                   = 'EA'
          required_date               = '20261115'
          procurement_type            = 'E'
          suggested_base_quantity     = '25.000'
          suggested_receipt_count     = 3
          maximum_base_quantity       = '10.000'
          final_receipt_base_quantity = '5.000' )
        ( material                    = 'MAT-2'
          plant                       = '2000'
          base_unit                   = 'EA'
          required_date               = '20261120'
          procurement_type            = 'E'
          suggested_base_quantity     = '4.000'
          suggested_receipt_count     = 1
          final_receipt_base_quantity = '4.000' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-successful_count
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-orders )
      exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-source_suggestion_index
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-receipt_index
      exp = 2 ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 2 ]-planned_order-planned_order ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 3 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 4 ]-source_suggestion_index
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 4 ]-receipt_index
      exp = 1 ).
  ENDMETHOD.

  METHOD bulk_create_continues_on_error.
    DATA(lo_api) = NEW lcl_planned_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_on_call = 2.
    DATA(lo_cut) = NEW zcl_planned_order_service( lo_api ).

    DATA(ls_result) = lo_cut->create_orders_bulk(
      it_requests = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          quantity = '2.000' planned_end_date = '20261115' )
        ( material = 'MAT-2' plant = '1000'
          quantity = '3.000' planned_end_date = '20261116' )
        ( material = 'MAT-3' plant = '1000'
          quantity = '4.000' planned_end_date = '20261117' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-successful_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->create_calls
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 2 ]-planned_order-planned_order ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 3 ]-is_committed ).
  ENDMETHOD.

  METHOD bulk_create_commit_failure.
    DATA(lo_api) = NEW lcl_planned_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_commit_on_call = 1.
    DATA(lo_cut) = NEW zcl_planned_order_service( lo_api ).

    DATA(ls_result) = lo_cut->create_orders_bulk(
      it_requests = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          quantity = '2.000' planned_end_date = '20261115' )
        ( material = 'MAT-2' plant = '1000'
          quantity = '3.000' planned_end_date = '20261116' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-commit_result-is_successful ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 1 ]-planned_order-planned_order ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 2 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD bulk_delete_continues_on_error.
    DATA(lo_api) = NEW lcl_planned_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->delete_fail_on_call = 2.
    DATA(lo_cut) = NEW zcl_planned_order_service( lo_api ).

    DATA(ls_result) = lo_cut->delete_orders_bulk(
      it_planned_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' )
        ( '0000000103' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-successful_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->delete_calls
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 3 ]-is_committed ).
  ENDMETHOD.

  METHOD bulk_delete_commit_failure.
    DATA(lo_api) = NEW lcl_planned_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_commit_on_call = 1.
    DATA(lo_cut) = NEW zcl_planned_order_service( lo_api ).

    DATA(ls_result) = lo_cut->delete_orders_bulk(
      it_planned_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-successful_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-commit_result-is_successful ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-planned_order-is_successful ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 2 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD changes_orders_atomically.
    DATA(lo_api) = NEW lcl_planned_order_api( ).
    lo_api->commit_success = abap_true.
    DATA(lo_cut) = NEW zcl_planned_order_service( lo_api ).

    DATA(ls_result) = lo_cut->change_orders_atomic(
      it_requests = VALUE #(
        ( planned_order   = '0000000101'
          quantity        = '5.000'
          change_quantity = abap_true )
        ( planned_order      = '0000000102'
          planned_start_date = '20261130'
          planned_end_date   = '20261201'
          change_start_date  = abap_true
          change_end_date    = abap_true )
        ( planned_order          = '0000000103'
          fixed_indicator        = abap_true
          change_fixed_indicator = abap_true )
        ( planned_order          = '0000000104'
          change_fixed_indicator = abap_true ) ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->change_calls
      exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->change_requests[ 1 ]-quantity
      exp = '5.000' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->change_requests[ 2 ]-planned_end_date
      exp = '20261201' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->change_requests[ 2 ]-planned_start_date
      exp = '20261130' ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_true(
      lo_api->change_requests[ 3 ]-fixed_indicator ).
    cl_abap_unit_assert=>assert_true(
      lo_api->change_requests[ 3 ]-change_fixed_indicator ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->change_requests[ 4 ]-fixed_indicator
      exp = abap_false ).
    cl_abap_unit_assert=>assert_true(
      lo_api->change_requests[ 4 ]-change_fixed_indicator ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD rejects_bad_change_requests.
    DATA(lo_api) = NEW lcl_planned_order_api( ).
    DATA(lo_cut) = NEW zcl_planned_order_service( lo_api ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->change_orders_atomic(
          it_requests = VALUE #(
            ( planned_order   = '0000000101'
              quantity        = '5.000'
              change_quantity = abap_true )
            ( planned_order    = '0000000102' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->change_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->change_orders_bulk(
          it_requests = VALUE #(
            ( planned_order   = '0000000101'
              quantity        = '5.000'
              change_quantity = abap_true )
            ( planned_order   = '0000000101'
              quantity        = '7.000'
              change_quantity = abap_true ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->change_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->change_orders_atomic(
          it_requests = VALUE #(
            ( planned_order          = '0000000103'
              fixed_indicator        = 'A'
              change_fixed_indicator = abap_true ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->change_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->change_orders_bulk(
          it_requests = VALUE #(
            ( planned_order      = '0000000104'
              quantity           = '5.000'
              planned_start_date = '20261201'
              change_quantity    = abap_true ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->change_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->change_orders_atomic(
          it_requests = VALUE #(
            ( planned_order     = '0000000105'
              change_start_date = abap_true ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->change_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rolls_back_failed_change.
    DATA(lo_api) = NEW lcl_planned_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->change_fail_on_call = 2.
    DATA(lo_cut) = NEW zcl_planned_order_service( lo_api ).

    DATA(ls_result) = lo_cut->change_orders_atomic(
      it_requests = VALUE #(
        ( planned_order   = '0000000101'
          quantity        = '5.000'
          change_quantity = abap_true )
        ( planned_order   = '0000000102'
          quantity        = '7.000'
          change_quantity = abap_true )
        ( planned_order   = '0000000103'
          quantity        = '9.000'
          change_quantity = abap_true ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->change_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-planned_order-is_successful ).
  ENDMETHOD.

  METHOD rolls_back_change_commit.
    DATA(lo_api) = NEW lcl_planned_order_api( ).
    lo_api->commit_success = abap_false.
    DATA(lo_cut) = NEW zcl_planned_order_service( lo_api ).

    DATA(ls_result) = lo_cut->change_orders_atomic(
      it_requests = VALUE #(
        ( planned_order   = '0000000101'
          quantity        = '5.000'
          change_quantity = abap_true ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_false(
      ls_result-commit_result-is_successful ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-planned_order-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD bulk_change_continues_on_error.
    DATA(lo_api) = NEW lcl_planned_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->change_fail_on_call = 2.
    DATA(lo_cut) = NEW zcl_planned_order_service( lo_api ).

    DATA(ls_result) = lo_cut->change_orders_bulk(
      it_requests = VALUE #(
        ( planned_order   = '0000000101'
          quantity        = '5.000'
          change_quantity = abap_true )
        ( planned_order   = '0000000102'
          quantity        = '7.000'
          change_quantity = abap_true )
        ( planned_order    = '0000000103'
          planned_end_date = '20261203'
          change_end_date  = abap_true ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-successful_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->change_calls
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 3 ]-is_committed ).
  ENDMETHOD.

  METHOD bulk_change_commit_failure.
    DATA(lo_api) = NEW lcl_planned_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_commit_on_call = 1.
    DATA(lo_cut) = NEW zcl_planned_order_service( lo_api ).

    DATA(ls_result) = lo_cut->change_orders_bulk(
      it_requests = VALUE #(
        ( planned_order   = '0000000101'
          quantity        = '5.000'
          change_quantity = abap_true )
        ( planned_order   = '0000000102'
          quantity        = '7.000'
          change_quantity = abap_true ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-successful_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-planned_order-is_successful ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 2 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD converts_orders_atomically.
    DATA(lo_api) = NEW lcl_planned_order_api( ).
    lo_api->commit_success = abap_true.
    DATA(lo_cut) = NEW zcl_planned_order_service( lo_api ).

    DATA(ls_result) = lo_cut->convert_planned_orders_atomic(
      it_planned_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' ) ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-conversion_result-production_order
      exp = '000000000002' ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->converted_orders[ 1 ]
      exp = '0000000101' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD rejects_duplicate_convert_keys.
    DATA(lo_api) = NEW lcl_planned_order_api( ).
    DATA(lo_cut) = NEW zcl_planned_order_service( lo_api ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->convert_planned_orders_atomic(
          it_planned_orders = VALUE #(
            ( '0000000101' )
            ( '0000000101' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->conversion_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rolls_back_failed_conversion.
    DATA(lo_api) = NEW lcl_planned_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->conversion_fail_on_call = 2.
    DATA(lo_cut) = NEW zcl_planned_order_service( lo_api ).

    DATA(ls_result) = lo_cut->convert_planned_orders_atomic(
      it_planned_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' )
        ( '0000000103' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->conversion_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 1 ]-conversion_result-production_order ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-conversion_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-conversion_result-message-type
      exp = 'E' ).
  ENDMETHOD.

  METHOD bulk_convert_continues_error.
    DATA(lo_api) = NEW lcl_planned_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->conversion_fail_on_call = 2.
    DATA(lo_cut) = NEW zcl_planned_order_service( lo_api ).

    DATA(ls_result) = lo_cut->convert_planned_orders_bulk(
      it_planned_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' )
        ( '0000000103' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-successful_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->conversion_calls
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 2 ]-conversion_result-production_order ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 3 ]-is_committed ).
  ENDMETHOD.

  METHOD bulk_conversion_commit_failure.
    DATA(lo_api) = NEW lcl_planned_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_commit_on_call = 1.
    DATA(lo_cut) = NEW zcl_planned_order_service( lo_api ).

    DATA(ls_result) = lo_cut->convert_planned_orders_bulk(
      it_planned_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-successful_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-orders[ 1 ]-conversion_result-production_order ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-conversion_result-is_successful ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 2 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
  ENDMETHOD.
ENDCLASS.
