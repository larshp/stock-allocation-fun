CLASS lcl_prod_order_api DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_prod_order_api.
    DATA released_orders TYPE zif_prod_order_api=>ty_order_numbers.
    DATA released_operations TYPE zif_prod_order_api=>ty_operation_keys.
    DATA confirmation_cancel_requests TYPE
      zif_prod_order_api=>ty_confirmation_cancel_requests.
    DATA create_order_calls TYPE i.
    DATA create_order_request TYPE zif_prod_order_api=>ty_create_order_request.
    DATA create_order_number TYPE zif_prod_order_api=>ty_order_number.
    DATA fail_create_order TYPE abap_bool.
    DATA fail_create_order_call TYPE i.
    DATA confirmation_create_requests TYPE
      zif_prod_order_api=>ty_confirmation_create_requests.
    DATA conf_create_commit_flags TYPE STANDARD TABLE OF abap_bool
      WITH EMPTY KEY.
    DATA conf_create_test_flags TYPE STANDARD TABLE OF abap_bool
      WITH EMPTY KEY.
    DATA release_calls TYPE i.
    DATA operation_release_calls TYPE i.
    DATA confirmation_cancel_calls TYPE i.
    DATA confirmation_create_calls TYPE i.
    DATA fail_confirmation_create_call TYPE i.
    DATA commit_calls TYPE i.
    DATA rollback_calls TYPE i.
    DATA fail_on_order TYPE zif_prod_order_api=>ty_order_number.
    DATA fail_operation_order TYPE zif_prod_order_api=>ty_order_number.
    DATA fail_operation_number TYPE
      zif_prod_order_api=>ty_operation_number.
    DATA fail_confirmation_cancel TYPE
      zif_prod_order_api=>ty_confirmation_number.
    DATA fail_complete_on_order TYPE zif_prod_order_api=>ty_order_number.
    DATA completed_orders TYPE zif_prod_order_api=>ty_order_numbers.
    DATA complete_calls TYPE i.
    DATA fail_set_deletion_on_order TYPE
      zif_prod_order_api=>ty_order_number.
    DATA deletion_flagged_orders TYPE zif_prod_order_api=>ty_order_numbers.
    DATA set_deletion_calls TYPE i.
    DATA fail_close_on_order TYPE zif_prod_order_api=>ty_order_number.
    DATA closed_orders TYPE zif_prod_order_api=>ty_order_numbers.
    DATA close_calls TYPE i.
    DATA fail_del_indicator_order TYPE
      zif_prod_order_api=>ty_order_number.
    DATA deletion_indicated_orders TYPE zif_prod_order_api=>ty_order_numbers.
    DATA set_deletion_indicator_calls TYPE i.
    DATA change_requests TYPE zif_prod_order_api=>ty_change_requests.
    DATA fail_change_on_order TYPE zif_prod_order_api=>ty_order_number.
    DATA change_calls TYPE i.
    DATA fail_commit_on_call TYPE i.
    DATA commit_success TYPE abap_bool.
    DATA last_release_control TYPE zif_prod_order_api=>ty_release_control.
ENDCLASS.

CLASS lcl_prod_order_api IMPLEMENTATION.
  METHOD zif_prod_order_api~create_order.
    ADD 1 TO create_order_calls.
    create_order_request = is_request.
    rs_result-production_order = create_order_number.
    IF rs_result-production_order IS INITIAL.
      rs_result-production_order = is_request-order_number.
    ENDIF.
    IF rs_result-production_order IS INITIAL.
      CASE create_order_calls.
        WHEN 1.
          rs_result-production_order = '0000000101'.
        WHEN 2.
          rs_result-production_order = '0000000102'.
        WHEN 3.
          rs_result-production_order = '0000000103'.
        WHEN OTHERS.
          rs_result-production_order = '0000000199'.
      ENDCASE.
    ENDIF.
    rs_result-is_successful = abap_true.
    IF fail_create_order = abap_true
        OR create_order_calls = fail_create_order_call.
      rs_result-is_successful = abap_false.
      rs_result-message-type = 'E'.
      rs_result-message-message = 'Production order creation failed'.
    ENDIF.
  ENDMETHOD.

  METHOD zif_prod_order_api~release_orders.
    ADD 1 TO release_calls.
    last_release_control = iv_release_control.
    rs_result-is_successful = abap_true.

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      APPEND lv_production_order TO released_orders.
      APPEND VALUE #(
        production_order = lv_production_order
        is_successful    = abap_true ) TO rs_result-orders.
      IF lv_production_order = fail_on_order.
        rs_result-is_successful = abap_false.
        rs_result-orders[ lines( rs_result-orders ) ]-is_successful =
          abap_false.
        rs_result-orders[ lines( rs_result-orders ) ]-message-type = 'E'.
        rs_result-orders[ lines( rs_result-orders ) ]-message-message =
          'Production order release failed'.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_prod_order_api~release_operations.
    ADD 1 TO operation_release_calls.
    rs_result-is_successful = abap_true.

    LOOP AT it_operations INTO DATA(ls_operation).
      APPEND ls_operation TO released_operations.
      APPEND VALUE #(
        production_order = ls_operation-production_order
        operation_number = ls_operation-operation_number
        is_successful    = abap_true ) TO rs_result-operations.
      IF ls_operation-production_order = fail_operation_order
          AND ls_operation-operation_number = fail_operation_number.
        rs_result-is_successful = abap_false.
        rs_result-operations[ lines( rs_result-operations ) ]-is_successful =
          abap_false.
        rs_result-operations[ lines( rs_result-operations ) ]-message-type =
          'E'.
        rs_result-operations[ lines( rs_result-operations ) ]-message-message =
          'Production order operation release failed'.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_prod_order_api~cancel_confirmation.
    ADD 1 TO confirmation_cancel_calls.
    APPEND is_request TO confirmation_cancel_requests.
    rs_result-confirmation = is_request-confirmation.
    rs_result-confirmation_counter = is_request-confirmation_counter.
    rs_result-is_successful = abap_true.
    IF is_request-confirmation = fail_confirmation_cancel.
      rs_result-is_successful = abap_false.
      rs_result-message-type = 'E'.
      rs_result-message-message = 'Confirmation cancellation failed'.
    ENDIF.
  ENDMETHOD.

  METHOD zif_prod_order_api~create_confirmation.
    ADD 1 TO confirmation_create_calls.
    APPEND is_request TO confirmation_create_requests.
    APPEND iv_commit TO conf_create_commit_flags.
    APPEND iv_test_run TO conf_create_test_flags.
    rs_result-production_order = is_request-production_order.
    rs_result-operation_number = is_request-operation_number.
    rs_result-operation_sequence = is_request-operation_sequence.
    rs_result-is_successful = abap_true.
    IF confirmation_create_calls = fail_confirmation_create_call.
      rs_result-is_successful = abap_false.
      rs_result-message-type = 'E'.
      rs_result-message-message = 'Production confirmation failed'.
    ELSEIF iv_test_run <> abap_true.
      rs_result-confirmation = confirmation_create_calls.
      rs_result-confirmation_counter = '00000001'.
    ENDIF.

    IF iv_commit = abap_true AND iv_test_run <> abap_true.
      rs_result-commit_result = zif_prod_order_api~commit( ).
      IF rs_result-commit_result-is_successful = abap_false.
        zif_prod_order_api~rollback( ).
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD zif_prod_order_api~complete_technically.
    ADD 1 TO complete_calls.
    APPEND iv_production_order TO completed_orders.
    rs_result-production_order = iv_production_order.
    rs_result-is_successful = abap_true.
    IF iv_production_order = fail_complete_on_order.
      rs_result-is_successful = abap_false.
      rs_result-message-type = 'E'.
      rs_result-message-message = 'Technical completion failed'.
    ENDIF.
  ENDMETHOD.

  METHOD zif_prod_order_api~set_deletion_flag.
    ADD 1 TO set_deletion_calls.
    APPEND iv_production_order TO deletion_flagged_orders.
    rs_result-production_order = iv_production_order.
    rs_result-is_successful = abap_true.
    IF iv_production_order = fail_set_deletion_on_order.
      rs_result-is_successful = abap_false.
      rs_result-message-type = 'E'.
      rs_result-message-message = 'Deletion flag failed'.
    ENDIF.
  ENDMETHOD.

  METHOD zif_prod_order_api~close_order.
    ADD 1 TO close_calls.
    APPEND iv_production_order TO closed_orders.
    rs_result-production_order = iv_production_order.
    rs_result-is_successful = abap_true.
    IF iv_production_order = fail_close_on_order.
      rs_result-is_successful = abap_false.
      rs_result-message-type = 'E'.
      rs_result-message-message = 'Production order close failed'.
    ENDIF.
  ENDMETHOD.

  METHOD zif_prod_order_api~set_deletion_indicator.
    ADD 1 TO set_deletion_indicator_calls.
    APPEND iv_production_order TO deletion_indicated_orders.
    rs_result-production_order = iv_production_order.
    rs_result-is_successful = abap_true.
    IF iv_production_order = fail_del_indicator_order.
      rs_result-is_successful = abap_false.
      rs_result-message-type = 'E'.
      rs_result-message-message = 'Deletion indicator failed'.
    ENDIF.
  ENDMETHOD.

  METHOD zif_prod_order_api~change_order.
    ADD 1 TO change_calls.
    APPEND is_request TO change_requests.
    rs_result-production_order = is_request-production_order.
    rs_result-is_successful = abap_true.
    IF is_request-production_order = fail_change_on_order.
      rs_result-is_successful = abap_false.
      rs_result-message-type = 'E'.
      rs_result-message-message = 'Production order change failed'.
    ENDIF.
  ENDMETHOD.

  METHOD zif_prod_order_api~commit.
    ADD 1 TO commit_calls.
    rs_result-is_successful = commit_success.
    IF commit_success = abap_false OR commit_calls = fail_commit_on_call.
      rs_result-is_successful = abap_false.
      rs_result-message-type = 'E'.
      rs_result-message-message = 'Commit failed'.
    ENDIF.
  ENDMETHOD.

  METHOD zif_prod_order_api~rollback.
    ADD 1 TO rollback_calls.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_prod_order_atp_checker DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_prod_order_atp_checker.
    DATA readiness TYPE zif_prod_order_atp_checker=>ty_order_readinesses.
    DATA check_calls TYPE i.
    DATA checked_orders TYPE zif_prod_order_api=>ty_order_numbers.
    DATA checked_rule TYPE zif_material_availability_api=>ty_check_rule.
ENDCLASS.

CLASS lcl_prod_order_atp_checker IMPLEMENTATION.
  METHOD zif_prod_order_atp_checker~check_components.
    ADD 1 TO check_calls.
    checked_orders = it_production_orders.
    checked_rule = iv_check_rule.
    rt_readiness = readiness.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_prod_order_service DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS creates_production_order FOR TESTING
      RAISING cx_static_check.
    METHODS creates_orders_atomic FOR TESTING
      RAISING cx_static_check.
    METHODS creates_orders_bulk FOR TESTING
      RAISING cx_static_check.
    METHODS stops_order_create_failures FOR TESTING
      RAISING cx_static_check.
    METHODS rolls_back_order_create_batch FOR TESTING
      RAISING cx_static_check.
    METHODS rolls_back_order_creation FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_invalid_order_create FOR TESTING
      RAISING cx_static_check.
    METHODS validates_order_create_batch FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_duplicate_create_id FOR TESTING
      RAISING cx_static_check.
    METHODS releases_orders_atomically FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_bad_release_requests FOR TESTING
      RAISING cx_static_check.
    METHODS releases_operations_atomically FOR TESTING
      RAISING cx_static_check.
    METHODS rolls_back_operation_release FOR TESTING
      RAISING cx_static_check.
    METHODS bulk_op_release_continues FOR TESTING
      RAISING cx_static_check.
    METHODS stops_op_release_failures FOR TESTING
      RAISING cx_static_check.
    METHODS validates_op_release_keys FOR TESTING
      RAISING cx_static_check.
    METHODS cancels_confirms_atomic FOR TESTING
      RAISING cx_static_check.
    METHODS bulk_cancel_continues FOR TESTING
      RAISING cx_static_check.
    METHODS validates_conf_cancels FOR TESTING
      RAISING cx_static_check.
    METHODS rolls_back_cancel_commit FOR TESTING
      RAISING cx_static_check.
    METHODS creates_confirmation_batch FOR TESTING
      RAISING cx_static_check.
    METHODS validates_confirmation_creates FOR TESTING
      RAISING cx_static_check.
    METHODS continues_after_create_error FOR TESTING
      RAISING cx_static_check.
    METHODS handles_create_commit_failure FOR TESTING
      RAISING cx_static_check.
    METHODS creates_confirms_atomic FOR TESTING
      RAISING cx_static_check.
    METHODS simulates_confirmation_batch FOR TESTING
      RAISING cx_static_check.
    METHODS rolls_back_failed_conf_batch FOR TESTING
      RAISING cx_static_check.
    METHODS rolls_back_confirmation_commit FOR TESTING
      RAISING cx_static_check.
    METHODS rolls_back_failed_release FOR TESTING
      RAISING cx_static_check.
    METHODS bulk_release_continues FOR TESTING
      RAISING cx_static_check.
    METHODS stops_order_release_failures FOR TESTING
      RAISING cx_static_check.
    METHODS bulk_release_commit_failure FOR TESTING
      RAISING cx_static_check.
    METHODS releases_only_when_atp_ready FOR TESTING
      RAISING cx_static_check.
    METHODS blocks_release_for_short_atp FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_incomplete_atp_results FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_atp_sum_overflow FOR TESTING
      RAISING cx_static_check.
    METHODS bulk_atp_release_skips_short FOR TESTING
      RAISING cx_static_check.
    METHODS bulk_atp_release_continues FOR TESTING
      RAISING cx_static_check.
    METHODS stops_atp_block_rows FOR TESTING
      RAISING cx_static_check.
    METHODS stops_atp_release_failure FOR TESTING
      RAISING cx_static_check.
    METHODS blocks_bulk_on_incomplete_atp FOR TESTING
      RAISING cx_static_check.
    METHODS bulk_atp_requires_checker FOR TESTING
      RAISING cx_static_check.
    METHODS completes_orders_technically FOR TESTING
      RAISING cx_static_check.
    METHODS rolls_back_teco_group FOR TESTING
      RAISING cx_static_check.
    METHODS rolls_back_teco_commit FOR TESTING
      RAISING cx_static_check.
    METHODS bulk_completion_continues FOR TESTING
      RAISING cx_static_check.
    METHODS validates_completion_requests FOR TESTING
      RAISING cx_static_check.
    METHODS sets_deletion_flags_atomically FOR TESTING
      RAISING cx_static_check.
    METHODS rolls_back_deletion_group FOR TESTING
      RAISING cx_static_check.
    METHODS rolls_back_deletion_commit FOR TESTING
      RAISING cx_static_check.
    METHODS bulk_deletion_continues FOR TESTING
      RAISING cx_static_check.
    METHODS validates_deletion_requests FOR TESTING
      RAISING cx_static_check.
    METHODS closes_orders_atomically FOR TESTING
      RAISING cx_static_check.
    METHODS rolls_back_close_group FOR TESTING
      RAISING cx_static_check.
    METHODS rolls_back_close_commit FOR TESTING
      RAISING cx_static_check.
    METHODS bulk_close_continues FOR TESTING
      RAISING cx_static_check.
    METHODS validates_close_requests FOR TESTING
      RAISING cx_static_check.
    METHODS sets_del_indicators_atomic FOR TESTING
      RAISING cx_static_check.
    METHODS rolls_back_indicator_group FOR TESTING
      RAISING cx_static_check.
    METHODS rolls_back_indicator_commit FOR TESTING
      RAISING cx_static_check.
    METHODS bulk_indicator_continues FOR TESTING
      RAISING cx_static_check.
    METHODS validates_indicator_requests FOR TESTING
      RAISING cx_static_check.
    METHODS changes_orders_atomically FOR TESTING
      RAISING cx_static_check.
    METHODS rolls_back_change_group FOR TESTING
      RAISING cx_static_check.
    METHODS rolls_back_change_commit FOR TESTING
      RAISING cx_static_check.
    METHODS bulk_change_continues FOR TESTING
      RAISING cx_static_check.
    METHODS stops_order_change_failures FOR TESTING
      RAISING cx_static_check.
    METHODS validates_change_requests FOR TESTING
      RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_prod_order_service IMPLEMENTATION.
  METHOD creates_production_order.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->create_order(
      is_request = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        order_type        = 'PP01'
        basic_finish_date = '20261101'
        quantity          = '12.000'
        quantity_uom      = 'EA' ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-create_result-production_order
      exp = '0000000101' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->create_order_request-planning_plant
      exp = '1000' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->create_order_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD creates_orders_atomic.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->create_orders_atomic(
      it_requests = VALUE #(
        ( order_number      = '0000000201'
          material          = 'MAT-1'
          plant             = '1000'
          order_type        = 'PP01'
          basic_finish_date = '20261101'
          quantity          = '12.000'
          quantity_uom      = 'EA' )
        ( order_number     = '0000000202'
          material         = 'MAT-2'
          plant            = '1000'
          order_type       = 'PP01'
          basic_start_date = '20261011'
          quantity         = '8.000'
          quantity_uom     = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-successful_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->create_order_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-create_result-production_order
      exp = '0000000202' ).
  ENDMETHOD.

  METHOD creates_orders_bulk.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_create_order_call = 2.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->create_orders_bulk(
      it_requests = VALUE #(
        ( order_number      = '0000000301'
          material          = 'MAT-1'
          plant             = '1000'
          order_type        = 'PP01'
          basic_finish_date = '20261101'
          quantity          = '12.000'
          quantity_uom      = 'EA' )
        ( order_number      = '0000000302'
          material          = 'MAT-2'
          plant             = '1000'
          order_type        = 'PP01'
          basic_finish_date = '20261102'
          quantity          = '8.000'
          quantity_uom      = 'EA' )
        ( order_number      = '0000000303'
          material          = 'MAT-3'
          plant             = '1000'
          order_type        = 'PP01'
          basic_finish_date = '20261103'
          quantity          = '6.000'
          quantity_uom      = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-successful_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 3 ]-is_committed ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 2 ]-create_result-is_successful ).
  ENDMETHOD.

  METHOD stops_order_create_failures.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_create_order_call = 2.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->create_orders_bulk(
      it_requests        = VALUE #(
        ( order_number      = '0000000301'
          material          = 'MAT-1'
          plant             = '1000'
          order_type        = 'PP01'
          basic_finish_date = '20261101'
          quantity          = '12.000'
          quantity_uom      = 'EA' )
        ( order_number      = '0000000302'
          material          = 'MAT-2'
          plant             = '1000'
          order_type        = 'PP01'
          basic_finish_date = '20261102'
          quantity          = '8.000'
          quantity_uom      = 'EA' )
        ( order_number      = '0000000303'
          material          = 'MAT-3'
          plant             = '1000'
          order_type        = 'PP01'
          basic_finish_date = '20261103'
          quantity          = '6.000'
          quantity_uom      = 'EA' ) )
      iv_stop_on_failure = abap_true ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-stopped_on_failure ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-successful_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-skipped_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->create_order_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 2 ]-is_attempted ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 3 ]-is_skipped ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD rolls_back_order_create_batch.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_create_order_call = 2.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->create_orders_atomic(
      it_requests = VALUE #(
        ( order_number      = '0000000401'
          material          = 'MAT-1'
          plant             = '1000'
          order_type        = 'PP01'
          basic_finish_date = '20261101'
          quantity          = '12.000'
          quantity_uom      = 'EA' )
        ( order_number      = '0000000402'
          material          = 'MAT-2'
          plant             = '1000'
          order_type        = 'PP01'
          basic_finish_date = '20261102'
          quantity          = '8.000'
          quantity_uom      = 'EA' )
        ( order_number      = '0000000403'
          material          = 'MAT-3'
          plant             = '1000'
          order_type        = 'PP01'
          basic_finish_date = '20261103'
          quantity          = '6.000'
          quantity_uom      = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->create_order_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-create_result-is_successful ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 2 ]-create_result-is_successful ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 3 ]-is_attempted ).

    DATA(lo_commit_api) = NEW lcl_prod_order_api( ).
    lo_commit_api->commit_success = abap_true.
    lo_commit_api->fail_commit_on_call = 1.
    DATA(lo_commit_cut) = NEW zcl_prod_order_service( lo_commit_api ).
    ls_result = lo_commit_cut->create_orders_atomic(
      it_requests = VALUE #(
        ( order_number      = '0000000411'
          material          = 'MAT-1'
          plant             = '1000'
          order_type        = 'PP01'
          basic_finish_date = '20261101'
          quantity          = '12.000'
          quantity_uom      = 'EA' )
        ( order_number      = '0000000412'
          material          = 'MAT-2'
          plant             = '1000'
          order_type        = 'PP01'
          basic_finish_date = '20261102'
          quantity          = '8.000'
          quantity_uom      = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_commit_api->create_order_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_commit_api->commit_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_commit_api->rollback_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD validates_order_create_batch.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->create_orders_atomic(
          it_requests = VALUE #(
            ( order_number      = '0000000501'
              material          = 'MAT-1'
              plant             = '1000'
              order_type        = 'PP01'
              basic_finish_date = '20261101'
              quantity          = '12.000'
              quantity_uom      = 'EA' )
            ( order_number      = '0000000501'
              material          = 'MAT-2'
              plant             = '1000'
              order_type        = 'PP01'
              basic_finish_date = '20261102'
              quantity          = '8.000'
              quantity_uom      = 'EA' ) ) ).
      CATCH zcx_invalid_production_order.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->create_order_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_duplicate_create_id.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->create_order_number = '0000000601'.
    lo_api->commit_success = abap_true.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->create_orders_atomic(
      it_requests = VALUE #(
        ( material          = 'MAT-1'
          plant             = '1000'
          order_type        = 'PP01'
          basic_finish_date = '20261101'
          quantity          = '12.000'
          quantity_uom      = 'EA' )
        ( material          = 'MAT-2'
          plant             = '1000'
          order_type        = 'PP01'
          basic_finish_date = '20261102'
          quantity          = '8.000'
          quantity_uom      = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-create_result-message-message
      exp = 'Duplicate production order number returned' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->create_order_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).

  ENDMETHOD.

  METHOD rolls_back_order_creation.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_create_order = abap_true.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->create_order(
      is_request = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        order_type        = 'PP01'
        basic_finish_date = '20261101'
        quantity          = '12.000'
        quantity_uom      = 'EA' ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).

    DATA(lo_commit_api) = NEW lcl_prod_order_api( ).
    lo_commit_api->commit_success = abap_true.
    lo_commit_api->fail_commit_on_call = 1.
    DATA(lo_commit_cut) = NEW zcl_prod_order_service( lo_commit_api ).
    ls_result = lo_commit_cut->create_order(
      is_request = VALUE #(
        material          = 'MAT-1'
        plant             = '1000'
        order_type        = 'PP01'
        basic_finish_date = '20261101'
        quantity          = '12.000'
        quantity_uom      = 'EA' ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_commit_api->commit_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_commit_api->rollback_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD rejects_invalid_order_create.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        lo_cut->create_order(
          is_request = VALUE #(
            material     = 'MAT-1'
            plant        = '1000'
            order_type   = 'PP01'
            quantity     = '0.000'
            quantity_uom = 'EA' ) ).
      CATCH zcx_invalid_production_order.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->create_order_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD releases_orders_atomically.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->release_orders_atomic(
      it_production_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' ) )
      iv_release_control   = '1' ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->release_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->released_orders[ 2 ]
      exp = '0000000102' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->last_release_control
      exp = '1' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 1 ]-is_committed ).
  ENDMETHOD.

  METHOD rejects_bad_release_requests.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->release_orders_atomic(
          it_production_orders = VALUE #(
            ( '0000000101' )
            ( '0000000101' ) )
          iv_release_control   = '1' ).
      CATCH zcx_invalid_production_order.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    TRY.
        lo_cut->release_orders_bulk(
          it_production_orders = VALUE #( ( '0000000101' ) )
          iv_release_control   = space ).
      CATCH zcx_invalid_production_order.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->release_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rolls_back_failed_release.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_on_order = '0000000102'.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->release_orders_atomic(
      it_production_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' ) )
      iv_release_control   = '1' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-release_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-release_result-message-type
      exp = 'E' ).
  ENDMETHOD.

  METHOD bulk_release_continues.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_on_order = '0000000102'.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->release_orders_bulk(
      it_production_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' )
        ( '0000000103' ) )
      iv_release_control   = '1' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-successful_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->release_calls
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

  METHOD stops_order_release_failures.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_on_order = '0000000102'.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->release_orders_bulk(
      it_production_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' )
        ( '0000000103' ) )
      iv_release_control   = '1'
      iv_stop_on_failure   = abap_true ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-stopped_on_failure ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-successful_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-skipped_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->release_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 2 ]-is_attempted ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 3 ]-is_skipped ).
  ENDMETHOD.

  METHOD bulk_release_commit_failure.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_commit_on_call = 1.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->release_orders_bulk(
      it_production_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' ) )
      iv_release_control   = '1' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-successful_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-release_result-is_successful ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 2 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD releases_only_when_atp_ready.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    DATA(lo_checker) = NEW lcl_prod_order_atp_checker( ).
    lo_checker->readiness = VALUE #(
      ( production_order        = '0000000101'
        component_count         = 2
        requested_base_quantity = '15.000'
        confirmed_base_quantity = '15.000'
        is_fully_confirmed      = abap_true )
      ( production_order        = '0000000102'
        component_count         = 1
        requested_base_quantity = '5.000'
        confirmed_base_quantity = '5.000'
        is_fully_confirmed      = abap_true ) ).
    DATA(lo_cut) = NEW zcl_prod_order_service(
      io_api         = lo_api
      io_atp_checker = lo_checker ).

    DATA(ls_result) = lo_cut->release_orders_after_atp(
      it_production_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' ) )
      iv_release_control   = '1'
      iv_check_rule        = 'A' ).

    cl_abap_unit_assert=>assert_true( ls_result-is_atp_ready ).
    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_released ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_checker->check_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_checker->checked_rule
      exp = 'A' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->release_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD blocks_release_for_short_atp.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    DATA(lo_checker) = NEW lcl_prod_order_atp_checker( ).
    lo_checker->readiness = VALUE #(
      ( production_order          = '0000000101'
        component_count           = 1
        not_fully_confirmed_count = 1
        requested_base_quantity   = '10.000'
        confirmed_base_quantity   = '6.000'
        unconfirmed_base_quantity = '4.000'
        is_fully_confirmed        = abap_false ) ).
    DATA(lo_cut) = NEW zcl_prod_order_service(
      io_api         = lo_api
      io_atp_checker = lo_checker ).

    DATA(ls_result) = lo_cut->release_orders_after_atp(
      it_production_orders = VALUE #( ( '0000000101' ) )
      iv_release_control   = '1'
      iv_check_rule        = 'A' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_atp_ready ).
    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message-type
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->release_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_atp_sum_overflow.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    DATA(lo_checker) = NEW lcl_prod_order_atp_checker( ).
    DATA(lo_cut) = NEW zcl_prod_order_service(
      io_api         = lo_api
      io_atp_checker = lo_checker ).
    DATA lv_rejected TYPE abap_bool.
    lo_checker->readiness = VALUE #(
      ( production_order          = '0000000101'
        component_count           = 1
        requested_base_quantity   = '9999999999.999'
        confirmed_base_quantity   = '9999999999.999'
        unconfirmed_base_quantity = '9999999999.999'
        is_fully_confirmed        = abap_false ) ).

    TRY.
        lo_cut->release_orders_after_atp(
          it_production_orders = VALUE #( ( '0000000101' ) )
          iv_release_control   = '1'
          iv_check_rule        = 'A' ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->release_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_incomplete_atp_results.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    DATA(lo_checker) = NEW lcl_prod_order_atp_checker( ).
    lo_checker->readiness = VALUE #(
      ( production_order   = '0000000101'
        is_fully_confirmed = abap_true ) ).
    DATA(lo_cut) = NEW zcl_prod_order_service(
      io_api         = lo_api
      io_atp_checker = lo_checker ).

    DATA(ls_result) = lo_cut->release_orders_after_atp(
      it_production_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' ) )
      iv_release_control   = '1'
      iv_check_rule        = 'A' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_atp_ready ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message-type
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->release_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD bulk_atp_release_skips_short.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    DATA(lo_checker) = NEW lcl_prod_order_atp_checker( ).
    lo_checker->readiness = VALUE #(
      ( production_order        = '0000000101'
        component_count         = 1
        requested_base_quantity = '10.000'
        confirmed_base_quantity = '10.000'
        is_fully_confirmed      = abap_true )
      ( production_order          = '0000000102'
        component_count           = 1
        not_fully_confirmed_count = 1
        requested_base_quantity   = '10.000'
        confirmed_base_quantity   = '6.000'
        unconfirmed_base_quantity = '4.000'
        is_fully_confirmed        = abap_false ) ).
    DATA(lo_cut) = NEW zcl_prod_order_service(
      io_api         = lo_api
      io_atp_checker = lo_checker ).

    DATA(ls_result) = lo_cut->release_orders_bulk_after_atp(
      it_production_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' ) )
      iv_release_control   = '1'
      iv_check_rule        = 'A' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_atp_checked ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-successful_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-atp_blocked_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 2 ]-is_atp_ready ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 2 ]-is_attempted ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->released_orders[ 1 ]
      exp = '0000000101' ).
  ENDMETHOD.

  METHOD bulk_atp_release_continues.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_on_order = '0000000102'.
    DATA(lo_checker) = NEW lcl_prod_order_atp_checker( ).
    lo_checker->readiness = VALUE #(
      ( production_order          = '0000000101'
        component_count           = 1
        not_fully_confirmed_count = 1
        requested_base_quantity   = '1.000'
        unconfirmed_base_quantity = '1.000'
        is_fully_confirmed        = abap_false )
      ( production_order        = '0000000102'
        component_count         = 1
        requested_base_quantity = '1.000'
        confirmed_base_quantity = '1.000'
        is_fully_confirmed      = abap_true )
      ( production_order        = '0000000103'
        component_count         = 1
        requested_base_quantity = '1.000'
        confirmed_base_quantity = '1.000'
        is_fully_confirmed      = abap_true ) ).
    DATA(lo_cut) = NEW zcl_prod_order_service(
      io_api         = lo_api
      io_atp_checker = lo_checker ).

    DATA(ls_result) = lo_cut->release_orders_bulk_after_atp(
      it_production_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' )
        ( '0000000103' ) )
      iv_release_control   = '1'
      iv_check_rule        = 'A' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-successful_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-atp_blocked_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-is_attempted ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 2 ]-is_attempted ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 2 ]-release_result-is_successful ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 3 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 3 ]-request_index
      exp = 3 ).
  ENDMETHOD.

  METHOD stops_atp_block_rows.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    DATA(lo_checker) = NEW lcl_prod_order_atp_checker( ).
    lo_checker->readiness = VALUE #(
      ( production_order        = '0000000101'
        component_count         = 1
        requested_base_quantity = '1.000'
        confirmed_base_quantity = '1.000'
        is_fully_confirmed      = abap_true )
      ( production_order          = '0000000102'
        component_count           = 1
        not_fully_confirmed_count = 1
        requested_base_quantity   = '1.000'
        unconfirmed_base_quantity = '1.000'
        is_fully_confirmed        = abap_false )
      ( production_order          = '0000000103'
        component_count           = 1
        not_fully_confirmed_count = 1
        requested_base_quantity   = '1.000'
        unconfirmed_base_quantity = '1.000'
        is_fully_confirmed        = abap_false ) ).
    DATA(lo_cut) = NEW zcl_prod_order_service(
      io_api         = lo_api
      io_atp_checker = lo_checker ).

    DATA(ls_result) = lo_cut->release_orders_bulk_after_atp(
      it_production_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' )
        ( '0000000103' ) )
      iv_release_control   = '1'
      iv_check_rule        = 'A'
      iv_stop_on_failure   = abap_true ).

    cl_abap_unit_assert=>assert_true( ls_result-stopped_on_failure ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-successful_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-skipped_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-atp_blocked_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 2 ]-is_attempted ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 2 ]-is_skipped ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 3 ]-is_skipped ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->release_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD stops_atp_release_failure.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_on_order = '0000000101'.
    DATA(lo_checker) = NEW lcl_prod_order_atp_checker( ).
    lo_checker->readiness = VALUE #(
      ( production_order        = '0000000101'
        component_count         = 1
        requested_base_quantity = '1.000'
        confirmed_base_quantity = '1.000'
        is_fully_confirmed      = abap_true )
      ( production_order        = '0000000102'
        component_count         = 1
        requested_base_quantity = '1.000'
        confirmed_base_quantity = '1.000'
        is_fully_confirmed      = abap_true )
      ( production_order          = '0000000103'
        component_count           = 1
        not_fully_confirmed_count = 1
        requested_base_quantity   = '1.000'
        unconfirmed_base_quantity = '1.000'
        is_fully_confirmed        = abap_false ) ).
    DATA(lo_cut) = NEW zcl_prod_order_service(
      io_api         = lo_api
      io_atp_checker = lo_checker ).

    DATA(ls_result) = lo_cut->release_orders_bulk_after_atp(
      it_production_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' )
        ( '0000000103' ) )
      iv_release_control   = '1'
      iv_check_rule        = 'A'
      iv_stop_on_failure   = abap_true ).

    cl_abap_unit_assert=>assert_true( ls_result-stopped_on_failure ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-successful_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-skipped_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-atp_blocked_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 1 ]-is_attempted ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 2 ]-is_skipped ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 3 ]-is_skipped ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->release_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD blocks_bulk_on_incomplete_atp.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    DATA(lo_checker) = NEW lcl_prod_order_atp_checker( ).
    lo_checker->readiness = VALUE #(
      ( production_order   = '0000000101'
        is_fully_confirmed = abap_true ) ).
    DATA(lo_cut) = NEW zcl_prod_order_service(
      io_api         = lo_api
      io_atp_checker = lo_checker ).

    DATA(ls_result) = lo_cut->release_orders_bulk_after_atp(
      it_production_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' ) )
      iv_release_control   = '1'
      iv_check_rule        = 'A' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_false( ls_result-is_atp_checked ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message-type
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->release_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD bulk_atp_requires_checker.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->release_orders_bulk_after_atp(
      it_production_orders = VALUE #( ( '0000000101' ) )
      iv_release_control   = '1'
      iv_check_rule        = 'A' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-message-type
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->release_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD completes_orders_technically.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->complete_orders_tech_atomic(
      it_production_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' ) ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->complete_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-completion_result-production_order
      exp = '0000000102' ).
  ENDMETHOD.

  METHOD rolls_back_teco_group.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_complete_on_order = '0000000102'.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->complete_orders_tech_atomic(
      it_production_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-completion_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-completion_result-message-type
      exp = 'E' ).
  ENDMETHOD.

  METHOD rolls_back_teco_commit.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_false.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->complete_orders_tech_atomic(
      it_production_orders = VALUE #( ( '0000000101' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-completion_result-is_successful ).
  ENDMETHOD.

  METHOD bulk_completion_continues.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_complete_on_order = '0000000102'.
    lo_api->fail_commit_on_call = 2.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->complete_orders_tech_bulk(
      it_production_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' )
        ( '0000000103' )
        ( '0000000104' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-completed_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->complete_calls
      exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 2 ]-completion_result-is_successful ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 3 ]-is_committed ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 4 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 4 ]-request_index
      exp = 4 ).
  ENDMETHOD.

  METHOD validates_completion_requests.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->complete_orders_tech_bulk(
          it_production_orders = VALUE #(
            ( '0000000101' )
            ( '0000000101' ) ) ).
      CATCH zcx_invalid_production_order.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    TRY.
        lo_cut->complete_orders_tech_atomic(
          it_production_orders = VALUE #(
            ( '0000000101' )
            ( ) ) ).
      CATCH zcx_invalid_production_order.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->complete_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD sets_deletion_flags_atomically.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->set_deletion_flags_atomic(
      it_production_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' ) ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->set_deletion_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->deletion_flagged_orders[ 2 ]
      exp = '0000000102' ).
  ENDMETHOD.

  METHOD rolls_back_deletion_group.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_set_deletion_on_order = '0000000102'.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->set_deletion_flags_atomic(
      it_production_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-deletion_flag_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-deletion_flag_result-message-type
      exp = 'E' ).
  ENDMETHOD.

  METHOD rolls_back_deletion_commit.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_false.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->set_deletion_flags_atomic(
      it_production_orders = VALUE #( ( '0000000101' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-deletion_flag_result-is_successful ).
  ENDMETHOD.

  METHOD bulk_deletion_continues.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_set_deletion_on_order = '0000000102'.
    lo_api->fail_commit_on_call = 2.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->set_deletion_flags_bulk(
      it_production_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' )
        ( '0000000103' )
        ( '0000000104' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-successful_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->set_deletion_calls
      exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 2 ]-deletion_flag_result-is_successful ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 3 ]-is_committed ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 4 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 4 ]-request_index
      exp = 4 ).
  ENDMETHOD.

  METHOD validates_deletion_requests.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->set_deletion_flags_bulk(
          it_production_orders = VALUE #(
            ( '0000000101' )
            ( '0000000101' ) ) ).
      CATCH zcx_invalid_production_order.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    TRY.
        lo_cut->set_deletion_flags_atomic(
          it_production_orders = VALUE #(
            ( '0000000101' )
            ( ) ) ).
      CATCH zcx_invalid_production_order.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->set_deletion_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD closes_orders_atomically.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->close_orders_atomic(
      it_production_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' ) ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->close_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-request_index
      exp = 2 ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 2 ]-is_committed ).
  ENDMETHOD.

  METHOD rolls_back_close_group.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_close_on_order = '0000000102'.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->close_orders_atomic(
      it_production_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-close_result-is_successful ).
  ENDMETHOD.

  METHOD rolls_back_close_commit.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_false.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->close_orders_atomic(
      it_production_orders = VALUE #( ( '0000000101' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-close_result-is_successful ).
  ENDMETHOD.

  METHOD bulk_close_continues.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_close_on_order = '0000000102'.
    lo_api->fail_commit_on_call = 2.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->close_orders_bulk(
      it_production_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' )
        ( '0000000103' )
        ( '0000000104' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-closed_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->close_calls
      exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 4 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->closed_orders[ 4 ]
      exp = '0000000104' ).
  ENDMETHOD.

  METHOD validates_close_requests.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->close_orders_bulk(
          it_production_orders = VALUE #(
            ( '0000000101' )
            ( '0000000101' ) ) ).
      CATCH zcx_invalid_production_order.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    TRY.
        lo_cut->close_orders_atomic(
          it_production_orders = VALUE #(
            ( '0000000101' )
            ( ) ) ).
      CATCH zcx_invalid_production_order.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->close_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD sets_del_indicators_atomic.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->set_deletion_indicators_atomic(
      it_production_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' ) ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->set_deletion_indicator_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->deletion_indicated_orders[ 2 ]
      exp = '0000000102' ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 2 ]-is_committed ).
  ENDMETHOD.

  METHOD rolls_back_indicator_group.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_del_indicator_order = '0000000102'.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->set_deletion_indicators_atomic(
      it_production_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-deletion_indicator-is_successful ).
  ENDMETHOD.

  METHOD rolls_back_indicator_commit.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_false.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->set_deletion_indicators_atomic(
      it_production_orders = VALUE #( ( '0000000101' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-deletion_indicator-is_successful ).
  ENDMETHOD.

  METHOD bulk_indicator_continues.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_del_indicator_order = '0000000102'.
    lo_api->fail_commit_on_call = 2.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->set_deletion_indicators_bulk(
      it_production_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' )
        ( '0000000103' )
        ( '0000000104' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-successful_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->set_deletion_indicator_calls
      exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 4 ]-is_committed ).
  ENDMETHOD.

  METHOD validates_indicator_requests.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->set_deletion_indicators_bulk(
          it_production_orders = VALUE #(
            ( '0000000101' )
            ( '0000000101' ) ) ).
      CATCH zcx_invalid_production_order.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    TRY.
        lo_cut->set_deletion_indicators_atomic(
          it_production_orders = VALUE #(
            ( '0000000101' )
            ( ) ) ).
      CATCH zcx_invalid_production_order.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->set_deletion_indicator_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD changes_orders_atomically.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->change_orders_atomic(
      it_requests = VALUE #(
        ( production_order = '0000000101'
          quantity         = '12.500'
          quantity_uom     = 'EA'
          change_quantity  = abap_true )
        ( production_order   = '0000000102'
          basic_start_date   = '20261012'
          basic_finish_date  = '20261015'
          change_start_date  = abap_true
          change_finish_date = abap_true ) ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->change_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->change_requests[ 1 ]-quantity
      exp = CONV bapi_pp_order_change-quantity( '12.500' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-request_index
      exp = 2 ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 2 ]-is_committed ).
  ENDMETHOD.

  METHOD rolls_back_change_group.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_change_on_order = '0000000102'.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->change_orders_atomic(
      it_requests = VALUE #(
        ( production_order = '0000000101'
          quantity         = 2
          quantity_uom     = 'EA'
          change_quantity  = abap_true )
        ( production_order = '0000000102'
          quantity         = 3
          quantity_uom     = 'EA'
          change_quantity  = abap_true ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-change_result-is_successful ).
  ENDMETHOD.

  METHOD rolls_back_change_commit.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_false.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->change_orders_atomic(
      it_requests = VALUE #(
        ( production_order  = '0000000101'
          basic_start_date  = '20261012'
          change_start_date = abap_true ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-change_result-is_successful ).
  ENDMETHOD.

  METHOD bulk_change_continues.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_change_on_order = '0000000102'.
    lo_api->fail_commit_on_call = 2.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->change_orders_bulk(
      it_requests = VALUE #(
        ( production_order = '0000000101'
          quantity         = 1
          quantity_uom     = 'EA'
          change_quantity  = abap_true )
        ( production_order = '0000000102'
          quantity         = 2
          quantity_uom     = 'EA'
          change_quantity  = abap_true )
        ( production_order = '0000000103'
          quantity         = 3
          quantity_uom     = 'EA'
          change_quantity  = abap_true )
        ( production_order = '0000000104'
          quantity         = 4
          quantity_uom     = 'EA'
          change_quantity  = abap_true ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-changed_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->change_calls
      exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 4 ]-is_committed ).
  ENDMETHOD.

  METHOD stops_order_change_failures.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_change_on_order = '0000000102'.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->change_orders_bulk(
      it_requests        = VALUE #(
        ( production_order = '0000000101'
          quantity         = 1
          quantity_uom     = 'EA'
          change_quantity  = abap_true )
        ( production_order = '0000000102'
          quantity         = 2
          quantity_uom     = 'EA'
          change_quantity  = abap_true )
        ( production_order = '0000000103'
          quantity         = 3
          quantity_uom     = 'EA'
          change_quantity  = abap_true ) )
      iv_stop_on_failure = abap_true ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-stopped_on_failure ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-changed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-skipped_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->change_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 2 ]-is_attempted ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 3 ]-is_skipped ).
  ENDMETHOD.

  METHOD validates_change_requests.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->change_orders_bulk(
          it_requests = VALUE #(
            ( production_order = '0000000101'
              quantity         = 2
              quantity_uom     = 'EA'
              change_quantity  = abap_true )
            ( production_order = '0000000101'
              quantity         = 3
              quantity_uom     = 'EA'
              change_quantity  = abap_true ) ) ).
      CATCH zcx_invalid_production_order.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    TRY.
        lo_cut->change_orders_atomic(
          it_requests = VALUE #(
            ( production_order   = '0000000102'
              basic_start_date   = '20261016'
              basic_finish_date  = '20261015'
              change_start_date  = abap_true
              change_finish_date = abap_true ) ) ).
      CATCH zcx_invalid_production_order.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->change_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD releases_operations_atomically.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->release_operations_atomic(
      it_operations      = VALUE #(
        ( production_order = '0000000101' operation_number = '0010' )
        ( production_order = '0000000101' operation_number = '0020' ) )
      iv_release_control = '1' ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->operation_release_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operations[ 2 ]-release_result-operation_number
      exp = '0020' ).
    cl_abap_unit_assert=>assert_true(
      ls_result-operations[ 1 ]-is_committed ).
  ENDMETHOD.

  METHOD rolls_back_operation_release.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->fail_operation_order = '0000000101'.
    lo_api->fail_operation_number = '0020'.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->release_operations_atomic(
      it_operations      = VALUE #(
        ( production_order = '0000000101' operation_number = '0010' )
        ( production_order = '0000000101' operation_number = '0020' ) )
      iv_release_control = '1' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_false(
      ls_result-operations[ 2 ]-release_result-is_successful ).
  ENDMETHOD.

  METHOD bulk_op_release_continues.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_operation_order = '0000000101'.
    lo_api->fail_operation_number = '0020'.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->release_operations_bulk(
      it_operations      = VALUE #(
        ( production_order = '0000000101' operation_number = '0010' )
        ( production_order = '0000000101' operation_number = '0020' )
        ( production_order = '0000000102' operation_number = '0010' ) )
      iv_release_control = '1' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-successful_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->operation_release_calls
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_true(
      ls_result-operations[ 3 ]-is_committed ).
  ENDMETHOD.

  METHOD stops_op_release_failures.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_operation_order = '0000000101'.
    lo_api->fail_operation_number = '0020'.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->release_operations_bulk(
      it_operations      = VALUE #(
        ( production_order = '0000000101' operation_number = '0010' )
        ( production_order = '0000000101' operation_number = '0020' )
        ( production_order = '0000000102' operation_number = '0010' ) )
      iv_release_control = '1'
      iv_stop_on_failure = abap_true ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-stopped_on_failure ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-successful_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-skipped_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->operation_release_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_true(
      ls_result-operations[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_true(
      ls_result-operations[ 3 ]-is_skipped ).
  ENDMETHOD.

  METHOD validates_op_release_keys.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->release_operations_bulk(
          it_operations      = VALUE #(
            ( production_order = '0000000101' operation_number = '0010' )
            ( production_order = '0000000101' operation_number = '0010' ) )
          iv_release_control = '1' ).
      CATCH zcx_invalid_production_order.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->operation_release_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->release_operations_atomic(
          it_operations      = VALUE #(
            ( production_order = '0000000101' operation_number = '10' ) )
          iv_release_control = '1' ).
      CATCH zcx_invalid_production_order.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->operation_release_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD cancels_confirms_atomic.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->cancel_confirmations_atomic(
      it_requests = VALUE #(
        ( confirmation         = '0000000001'
          confirmation_counter = '00000001'
          posting_date         = '20261011' )
        ( confirmation         = '0000000002'
          confirmation_counter = '00000001'
          posting_date         = '20261011' ) ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->confirmation_cancel_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_true(
      ls_result-confirmations[ 2 ]-is_committed ).
  ENDMETHOD.

  METHOD bulk_cancel_continues.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_confirmation_cancel = '0000000002'.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->cancel_confirmations_bulk(
      it_requests = VALUE #(
        ( confirmation         = '0000000001'
          confirmation_counter = '00000001'
          posting_date         = '20261011' )
        ( confirmation         = '0000000002'
          confirmation_counter = '00000001'
          posting_date         = '20261011' )
        ( confirmation         = '0000000003'
          confirmation_counter = '00000001'
          posting_date         = '20261011' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-successful_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->confirmation_cancel_calls
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_true(
      ls_result-confirmations[ 3 ]-is_committed ).
  ENDMETHOD.

  METHOD validates_conf_cancels.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->cancel_confirmations_bulk(
          it_requests = VALUE #(
            ( confirmation         = '0000000001'
              confirmation_counter = '00000001'
              posting_date         = '20261011' )
            ( confirmation         = '0000000001'
              confirmation_counter = '00000001'
              posting_date         = '20261012' ) ) ).
      CATCH zcx_invalid_production_order.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->confirmation_cancel_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->cancel_confirmations_atomic(
          it_requests = VALUE #(
            ( confirmation         = '0000000001'
              confirmation_counter = '00000001' ) ) ).
      CATCH zcx_invalid_production_order.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->confirmation_cancel_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rolls_back_cancel_commit.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_false.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->cancel_confirmations_atomic(
      it_requests = VALUE #(
        ( confirmation         = '0000000001'
          confirmation_counter = '00000001'
          posting_date         = '20261011' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD creates_confirms_atomic.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->create_confirmations_atomic(
      it_requests = VALUE #(
        ( production_order   = '0000000101'
          operation_number   = '0010'
          operation_sequence = '000000'
          posting_date       = '20261011'
          yield_quantity     = '3.000'
          quantity_unit_iso  = 'EA' )
        ( production_order   = '0000000102'
          operation_number   = '0020'
          operation_sequence = '000000'
          posting_date       = '20261011'
          yield_quantity     = '4.000'
          quantity_unit_iso  = 'EA'
          final_confirmation = 'X' ) ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_committed ).
    cl_abap_unit_assert=>assert_false( ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->confirmation_create_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->conf_create_commit_flags[ 1 ]
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->conf_create_commit_flags[ 2 ]
      exp = abap_false ).
    cl_abap_unit_assert=>assert_true(
      ls_result-confirmations[ 2 ]-is_committed ).
  ENDMETHOD.

  METHOD rolls_back_failed_conf_batch.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_confirmation_create_call = 2.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->create_confirmations_atomic(
      it_requests = VALUE #(
        ( production_order   = '0000000101'
          operation_number   = '0010'
          operation_sequence = '000000'
          posting_date       = '20261011'
          yield_quantity     = '3.000'
          quantity_unit_iso  = 'EA' )
        ( production_order   = '0000000102'
          operation_number   = '0020'
          operation_sequence = '000000'
          posting_date       = '20261011'
          yield_quantity     = '4.000'
          quantity_unit_iso  = 'EA' )
        ( production_order   = '0000000103'
          operation_number   = '0030'
          operation_sequence = '000000'
          posting_date       = '20261011'
          yield_quantity     = '5.000'
          quantity_unit_iso  = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->confirmation_create_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_false(
      ls_result-confirmations[ 1 ]-create_result-is_successful ).
    cl_abap_unit_assert=>assert_false(
      ls_result-confirmations[ 3 ]-is_attempted ).
  ENDMETHOD.

  METHOD simulates_confirmation_batch.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->create_confirmations_atomic(
      it_requests = VALUE #(
        ( production_order   = '0000000101'
          operation_number   = '0010'
          operation_sequence = '000000'
          posting_date       = '20261011'
          yield_quantity     = '3.000'
          quantity_unit_iso  = 'EA' )
        ( production_order   = '0000000102'
          operation_number   = '0020'
          operation_sequence = '000000'
          posting_date       = '20261011'
          yield_quantity     = '4.000'
          quantity_unit_iso  = 'EA' ) )
      iv_test_run = abap_true ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_false( ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_false( ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->confirmation_create_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->conf_create_test_flags[ 1 ]
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->conf_create_test_flags[ 2 ]
      exp = abap_true ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-confirmations[ 1 ]-create_result-confirmation ).
    cl_abap_unit_assert=>assert_initial(
      ls_result-confirmations[ 1 ]-create_result-confirmation_counter ).

    DATA(lo_failed_api) = NEW lcl_prod_order_api( ).
    lo_failed_api->commit_success = abap_true.
    lo_failed_api->fail_confirmation_create_call = 2.
    DATA(lo_failed_cut) = NEW zcl_prod_order_service( lo_failed_api ).
    DATA(ls_failed_result) = lo_failed_cut->create_confirmations_atomic(
      it_requests = VALUE #(
        ( production_order   = '0000000201'
          operation_number   = '0010'
          operation_sequence = '000000'
          posting_date       = '20261011'
          yield_quantity     = '3.000'
          quantity_unit_iso  = 'EA' )
        ( production_order   = '0000000202'
          operation_number   = '0020'
          operation_sequence = '000000'
          posting_date       = '20261011'
          yield_quantity     = '4.000'
          quantity_unit_iso  = 'EA' )
        ( production_order   = '0000000203'
          operation_number   = '0030'
          operation_sequence = '000000'
          posting_date       = '20261011'
          yield_quantity     = '5.000'
          quantity_unit_iso  = 'EA' ) )
      iv_test_run = abap_true ).

    cl_abap_unit_assert=>assert_false( ls_failed_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_failed_result-is_test_run ).
    cl_abap_unit_assert=>assert_false( ls_failed_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_true(
      ls_failed_result-confirmations[ 1 ]-create_result-is_successful ).
    cl_abap_unit_assert=>assert_false(
      ls_failed_result-confirmations[ 2 ]-create_result-is_successful ).
    cl_abap_unit_assert=>assert_false(
      ls_failed_result-confirmations[ 3 ]-is_attempted ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_failed_api->commit_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_failed_api->rollback_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rolls_back_confirmation_commit.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_commit_on_call = 1.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->create_confirmations_atomic(
      it_requests = VALUE #(
        ( production_order   = '0000000101'
          operation_number   = '0010'
          operation_sequence = '000000'
          posting_date       = '20261011'
          yield_quantity     = '3.000'
          quantity_unit_iso  = 'EA' )
        ( production_order   = '0000000102'
          operation_number   = '0020'
          operation_sequence = '000000'
          posting_date       = '20261011'
          yield_quantity     = '4.000'
          quantity_unit_iso  = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true( ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->confirmation_create_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_false(
      ls_result-confirmations[ 1 ]-create_result-is_successful ).
    cl_abap_unit_assert=>assert_false(
      ls_result-confirmations[ 2 ]-is_committed ).
  ENDMETHOD.

  METHOD creates_confirmation_batch.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->create_confirmations_bulk(
      it_requests = VALUE #(
        ( production_order   = '0000000101'
          operation_number   = '0010'
          operation_sequence = '000000'
          posting_date       = '20261011'
          yield_quantity     = '3.000'
          quantity_unit_iso  = 'EA' )
        ( production_order   = '0000000102'
          operation_number   = '0020'
          operation_sequence = '000000'
          posting_date       = '20261011'
          yield_quantity     = '4.000'
          quantity_unit_iso  = 'EA'
          final_confirmation = 'X'
          clear_reservations = abap_true ) ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-successful_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->confirmation_create_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->confirmation_create_requests[ 2 ]-final_confirmation
      exp = 'X' ).
    cl_abap_unit_assert=>assert_true(
      ls_result-confirmations[ 2 ]-is_committed ).
  ENDMETHOD.

  METHOD validates_confirmation_creates.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->create_confirmations_bulk(
          it_requests = VALUE #(
            ( production_order   = '0000000101'
              operation_number   = '0010'
              operation_sequence = '00000'
              posting_date       = '20261011'
              quantity_unit_iso  = 'EA' ) ) ).
      CATCH zcx_invalid_production_order.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->confirmation_create_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->create_confirmations_bulk(
          it_requests = VALUE #(
            ( production_order   = '0000000101'
              operation_number   = '0010'
              operation_sequence = '000000'
              posting_date       = '20261011'
              yield_quantity     = '-1.000'
              quantity_unit_iso  = 'EA' ) ) ).
      CATCH zcx_invalid_production_order.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->confirmation_create_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->create_confirmations_atomic(
          it_requests = VALUE #(
            ( production_order   = '0000000101'
              operation_number   = '0010'
              operation_sequence = '000000'
              posting_date       = '20261011'
              yield_quantity     = '3.000'
              quantity_unit_iso  = 'EA' ) )
          iv_test_run = 'Y' ).
      CATCH zcx_invalid_production_order.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->confirmation_create_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD continues_after_create_error.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_confirmation_create_call = 2.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->create_confirmations_bulk(
      it_requests = VALUE #(
        ( production_order   = '0000000101'
          operation_number   = '0010'
          operation_sequence = '000000'
          posting_date       = '20261011'
          yield_quantity     = '3.000'
          quantity_unit_iso  = 'EA' )
        ( production_order   = '0000000102'
          operation_number   = '0020'
          operation_sequence = '000000'
          posting_date       = '20261011'
          yield_quantity     = '4.000'
          quantity_unit_iso  = 'EA' )
        ( production_order   = '0000000103'
          operation_number   = '0030'
          operation_sequence = '000000'
          posting_date       = '20261011'
          yield_quantity     = '5.000'
          quantity_unit_iso  = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-successful_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_true(
      ls_result-confirmations[ 3 ]-is_committed ).
  ENDMETHOD.

  METHOD handles_create_commit_failure.
    DATA(lo_api) = NEW lcl_prod_order_api( ).
    lo_api->commit_success = abap_true.
    lo_api->fail_commit_on_call = 1.
    DATA(lo_cut) = NEW zcl_prod_order_service( lo_api ).

    DATA(ls_result) = lo_cut->create_confirmations_bulk(
      it_requests = VALUE #(
        ( production_order   = '0000000101'
          operation_number   = '0010'
          operation_sequence = '000000'
          posting_date       = '20261011'
          yield_quantity     = '3.000'
          quantity_unit_iso  = 'EA' )
        ( production_order   = '0000000102'
          operation_number   = '0020'
          operation_sequence = '000000'
          posting_date       = '20261011'
          yield_quantity     = '4.000'
          quantity_unit_iso  = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-successful_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-failed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->rollback_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_api->commit_calls
      exp = 2 ).
    cl_abap_unit_assert=>assert_true(
      ls_result-confirmations[ 2 ]-is_committed ).
  ENDMETHOD.
ENDCLASS.
