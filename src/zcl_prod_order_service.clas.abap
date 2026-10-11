CLASS zcl_prod_order_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_order_result,
        request_index  TYPE i,
        release_result TYPE zif_prod_order_api=>ty_order_result,
        is_attempted   TYPE abap_bool,
        is_committed   TYPE abap_bool,
      END OF ty_order_result.
    TYPES ty_order_results TYPE STANDARD TABLE OF ty_order_result
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_create_order_result,
        request        TYPE zif_prod_order_api=>ty_create_order_request,
        create_result  TYPE zif_prod_order_api=>ty_order_result,
        commit_result  TYPE zif_prod_order_api=>ty_commit_result,
        is_successful  TYPE abap_bool,
        is_committed   TYPE abap_bool,
        is_rolled_back TYPE abap_bool,
      END OF ty_create_order_result.
    TYPES:
      BEGIN OF ty_create_order_item,
        request_index TYPE i,
        request       TYPE zif_prod_order_api=>ty_create_order_request,
        create_result TYPE zif_prod_order_api=>ty_order_result,
        commit_result TYPE zif_prod_order_api=>ty_commit_result,
        is_attempted  TYPE abap_bool,
        is_committed  TYPE abap_bool,
      END OF ty_create_order_item.
    TYPES ty_create_order_items TYPE STANDARD TABLE OF
      ty_create_order_item WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_create_orders_atomic_result,
        orders           TYPE ty_create_order_items,
        commit_result    TYPE zif_prod_order_api=>ty_commit_result,
        successful_count TYPE i,
        failed_count     TYPE i,
        is_successful    TYPE abap_bool,
        is_committed     TYPE abap_bool,
        is_rolled_back   TYPE abap_bool,
      END OF ty_create_orders_atomic_result.
    TYPES:
      BEGIN OF ty_create_orders_bulk_result,
        orders           TYPE ty_create_order_items,
        successful_count TYPE i,
        failed_count     TYPE i,
        is_successful    TYPE abap_bool,
      END OF ty_create_orders_bulk_result.
    TYPES:
      BEGIN OF ty_release_result,
        orders         TYPE ty_order_results,
        commit_result  TYPE zif_prod_order_api=>ty_commit_result,
        is_successful  TYPE abap_bool,
        is_committed   TYPE abap_bool,
        is_rolled_back TYPE abap_bool,
      END OF ty_release_result.
    TYPES:
      BEGIN OF ty_operation_release_item,
        request_index  TYPE i,
        operation_key  TYPE zif_prod_order_api=>ty_operation_key,
        release_result TYPE zif_prod_order_api=>ty_operation_result,
        commit_result  TYPE zif_prod_order_api=>ty_commit_result,
        is_attempted   TYPE abap_bool,
        is_committed   TYPE abap_bool,
      END OF ty_operation_release_item.
    TYPES ty_operation_release_items TYPE STANDARD TABLE OF
      ty_operation_release_item WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_operation_release_result,
        operations     TYPE ty_operation_release_items,
        commit_result  TYPE zif_prod_order_api=>ty_commit_result,
        is_successful  TYPE abap_bool,
        is_committed   TYPE abap_bool,
        is_rolled_back TYPE abap_bool,
      END OF ty_operation_release_result.
    TYPES:
      BEGIN OF ty_bulk_operation_release_result,
        operations       TYPE ty_operation_release_items,
        successful_count TYPE i,
        failed_count     TYPE i,
        is_successful    TYPE abap_bool,
      END OF ty_bulk_operation_release_result.
    TYPES:
      BEGIN OF ty_confirmation_cancel_item,
        request_index TYPE i,
        request       TYPE
          zif_prod_order_api=>ty_confirmation_cancel_request,
        cancel_result TYPE
          zif_prod_order_api=>ty_confirmation_cancel_result,
        commit_result TYPE zif_prod_order_api=>ty_commit_result,
        is_attempted  TYPE abap_bool,
        is_committed  TYPE abap_bool,
      END OF ty_confirmation_cancel_item.
    TYPES ty_confirmation_cancel_items TYPE STANDARD TABLE OF
      ty_confirmation_cancel_item WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_confirmation_cancel_result,
        confirmations  TYPE ty_confirmation_cancel_items,
        commit_result  TYPE zif_prod_order_api=>ty_commit_result,
        is_successful  TYPE abap_bool,
        is_committed   TYPE abap_bool,
        is_rolled_back TYPE abap_bool,
      END OF ty_confirmation_cancel_result.
    TYPES:
      BEGIN OF ty_bulk_confirmation_cancel_result,
        confirmations    TYPE ty_confirmation_cancel_items,
        successful_count TYPE i,
        failed_count     TYPE i,
        is_successful    TYPE abap_bool,
      END OF ty_bulk_confirmation_cancel_result.
    TYPES:
      BEGIN OF ty_confirmation_create_item,
        request_index TYPE i,
        request       TYPE
          zif_prod_order_api=>ty_confirmation_create_request,
        create_result TYPE
          zif_prod_order_api=>ty_confirmation_create_result,
        commit_result TYPE zif_prod_order_api=>ty_commit_result,
        is_attempted  TYPE abap_bool,
        is_committed  TYPE abap_bool,
      END OF ty_confirmation_create_item.
    TYPES ty_confirmation_create_items TYPE STANDARD TABLE OF
      ty_confirmation_create_item WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_confirmation_create_result,
        confirmations    TYPE ty_confirmation_create_items,
        successful_count TYPE i,
        failed_count     TYPE i,
        is_successful    TYPE abap_bool,
      END OF ty_bulk_confirmation_create_result.
    TYPES:
      BEGIN OF ty_bulk_order_result,
        request_index  TYPE i,
        release_result TYPE zif_prod_order_api=>ty_order_result,
        commit_result  TYPE zif_prod_order_api=>ty_commit_result,
        is_attempted   TYPE abap_bool,
        is_committed   TYPE abap_bool,
      END OF ty_bulk_order_result.
    TYPES ty_bulk_order_results TYPE STANDARD TABLE OF ty_bulk_order_result
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_release_result,
        orders           TYPE ty_bulk_order_results,
        successful_count TYPE i,
        failed_count     TYPE i,
        is_successful    TYPE abap_bool,
      END OF ty_bulk_release_result.
    TYPES:
      BEGIN OF ty_completion_order_result,
        request_index     TYPE i,
        completion_result TYPE zif_prod_order_api=>ty_order_result,
        commit_result     TYPE zif_prod_order_api=>ty_commit_result,
        is_attempted      TYPE abap_bool,
        is_committed      TYPE abap_bool,
      END OF ty_completion_order_result.
    TYPES ty_completion_order_results TYPE STANDARD TABLE OF
      ty_completion_order_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_completion_result,
        orders         TYPE ty_completion_order_results,
        commit_result  TYPE zif_prod_order_api=>ty_commit_result,
        is_successful  TYPE abap_bool,
        is_committed   TYPE abap_bool,
        is_rolled_back TYPE abap_bool,
      END OF ty_completion_result.
    TYPES:
      BEGIN OF ty_bulk_completion_result,
        orders          TYPE ty_completion_order_results,
        completed_count TYPE i,
        failed_count    TYPE i,
        is_successful   TYPE abap_bool,
      END OF ty_bulk_completion_result.
    TYPES:
      BEGIN OF ty_deletion_flag_order_result,
        request_index        TYPE i,
        deletion_flag_result TYPE zif_prod_order_api=>ty_order_result,
        commit_result        TYPE zif_prod_order_api=>ty_commit_result,
        is_attempted         TYPE abap_bool,
        is_committed         TYPE abap_bool,
      END OF ty_deletion_flag_order_result.
    TYPES ty_deletion_flag_order_results TYPE STANDARD TABLE OF
      ty_deletion_flag_order_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_deletion_flag_result,
        orders         TYPE ty_deletion_flag_order_results,
        commit_result  TYPE zif_prod_order_api=>ty_commit_result,
        is_successful  TYPE abap_bool,
        is_committed   TYPE abap_bool,
        is_rolled_back TYPE abap_bool,
      END OF ty_deletion_flag_result.
    TYPES:
      BEGIN OF ty_bulk_deletion_flag_result,
        orders           TYPE ty_deletion_flag_order_results,
        successful_count TYPE i,
        failed_count     TYPE i,
        is_successful    TYPE abap_bool,
      END OF ty_bulk_deletion_flag_result.
    TYPES:
      BEGIN OF ty_close_order_result,
        request_index TYPE i,
        close_result  TYPE zif_prod_order_api=>ty_order_result,
        commit_result TYPE zif_prod_order_api=>ty_commit_result,
        is_attempted  TYPE abap_bool,
        is_committed  TYPE abap_bool,
      END OF ty_close_order_result.
    TYPES ty_close_order_results TYPE STANDARD TABLE OF
      ty_close_order_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_close_result,
        orders         TYPE ty_close_order_results,
        commit_result  TYPE zif_prod_order_api=>ty_commit_result,
        is_successful  TYPE abap_bool,
        is_committed   TYPE abap_bool,
        is_rolled_back TYPE abap_bool,
      END OF ty_close_result.
    TYPES:
      BEGIN OF ty_bulk_close_result,
        orders        TYPE ty_close_order_results,
        closed_count  TYPE i,
        failed_count  TYPE i,
        is_successful TYPE abap_bool,
      END OF ty_bulk_close_result.
    TYPES:
      BEGIN OF ty_deletion_indicator_order_result,
        request_index      TYPE i,
        deletion_indicator TYPE zif_prod_order_api=>ty_order_result,
        commit_result      TYPE zif_prod_order_api=>ty_commit_result,
        is_attempted       TYPE abap_bool,
        is_committed       TYPE abap_bool,
      END OF ty_deletion_indicator_order_result.
    TYPES ty_deletion_indicator_orders TYPE STANDARD TABLE OF
      ty_deletion_indicator_order_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_deletion_indicator_result,
        orders         TYPE ty_deletion_indicator_orders,
        commit_result  TYPE zif_prod_order_api=>ty_commit_result,
        is_successful  TYPE abap_bool,
        is_committed   TYPE abap_bool,
        is_rolled_back TYPE abap_bool,
      END OF ty_deletion_indicator_result.
    TYPES:
      BEGIN OF ty_bulk_deletion_indicator_result,
        orders           TYPE ty_deletion_indicator_orders,
        successful_count TYPE i,
        failed_count     TYPE i,
        is_successful    TYPE abap_bool,
      END OF ty_bulk_deletion_indicator_result.
    TYPES:
      BEGIN OF ty_change_order_result,
        request_index TYPE i,
        request       TYPE zif_prod_order_api=>ty_change_request,
        change_result TYPE zif_prod_order_api=>ty_order_result,
        commit_result TYPE zif_prod_order_api=>ty_commit_result,
        is_attempted  TYPE abap_bool,
        is_committed  TYPE abap_bool,
      END OF ty_change_order_result.
    TYPES ty_change_order_results TYPE STANDARD TABLE OF
      ty_change_order_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_change_result,
        orders         TYPE ty_change_order_results,
        commit_result  TYPE zif_prod_order_api=>ty_commit_result,
        is_successful  TYPE abap_bool,
        is_committed   TYPE abap_bool,
        is_rolled_back TYPE abap_bool,
      END OF ty_change_result.
    TYPES:
      BEGIN OF ty_bulk_change_result,
        orders        TYPE ty_change_order_results,
        changed_count TYPE i,
        failed_count  TYPE i,
        is_successful TYPE abap_bool,
      END OF ty_bulk_change_result.
    TYPES:
      BEGIN OF ty_atp_release_result,
        component_readiness TYPE
          zif_prod_order_atp_checker=>ty_order_readinesses,
        release_result      TYPE ty_release_result,
        message             TYPE zif_prod_order_api=>ty_message,
        is_atp_ready        TYPE abap_bool,
        is_successful       TYPE abap_bool,
        is_released         TYPE abap_bool,
      END OF ty_atp_release_result.
    TYPES:
      BEGIN OF ty_atp_bulk_order_result,
        request_index       TYPE i,
        production_order    TYPE zif_prod_order_api=>ty_order_number,
        component_readiness TYPE
          zif_prod_order_atp_checker=>ty_order_readiness,
        release_result      TYPE zif_prod_order_api=>ty_order_result,
        commit_result       TYPE zif_prod_order_api=>ty_commit_result,
        message             TYPE zif_prod_order_api=>ty_message,
        is_atp_ready        TYPE abap_bool,
        is_attempted        TYPE abap_bool,
        is_committed        TYPE abap_bool,
      END OF ty_atp_bulk_order_result.
    TYPES ty_atp_bulk_order_results TYPE STANDARD TABLE OF
      ty_atp_bulk_order_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_atp_bulk_release_result,
        orders            TYPE ty_atp_bulk_order_results,
        message           TYPE zif_prod_order_api=>ty_message,
        successful_count  TYPE i,
        failed_count      TYPE i,
        atp_blocked_count TYPE i,
        is_atp_checked    TYPE abap_bool,
        is_successful     TYPE abap_bool,
      END OF ty_atp_bulk_release_result.

    METHODS constructor
      IMPORTING
        io_api         TYPE REF TO zif_prod_order_api
        io_atp_checker TYPE REF TO zif_prod_order_atp_checker OPTIONAL.

    METHODS create_order
      IMPORTING
        is_request       TYPE zif_prod_order_api=>ty_create_order_request
      RETURNING
        VALUE(rs_result) TYPE ty_create_order_result
      RAISING
        zcx_invalid_production_order.

    METHODS create_orders_atomic
      IMPORTING
        it_requests      TYPE zif_prod_order_api=>ty_create_order_requests
      RETURNING
        VALUE(rs_result) TYPE ty_create_orders_atomic_result
      RAISING
        zcx_invalid_production_order.

    METHODS create_orders_bulk
      IMPORTING
        it_requests      TYPE zif_prod_order_api=>ty_create_order_requests
      RETURNING
        VALUE(rs_result) TYPE ty_create_orders_bulk_result
      RAISING
        zcx_invalid_production_order.

    METHODS release_orders_atomic
      IMPORTING
        it_production_orders TYPE zif_prod_order_api=>ty_order_numbers
        iv_release_control   TYPE zif_prod_order_api=>ty_release_control
      RETURNING
        VALUE(rs_result)     TYPE ty_release_result
      RAISING
        zcx_invalid_production_order.

    METHODS release_operations_atomic
      IMPORTING
        it_operations      TYPE zif_prod_order_api=>ty_operation_keys
        iv_release_control TYPE zif_prod_order_api=>ty_release_control
      RETURNING
        VALUE(rs_result)   TYPE ty_operation_release_result
      RAISING
        zcx_invalid_production_order.

    METHODS release_operations_bulk
      IMPORTING
        it_operations      TYPE zif_prod_order_api=>ty_operation_keys
        iv_release_control TYPE zif_prod_order_api=>ty_release_control
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_operation_release_result
      RAISING
        zcx_invalid_production_order.

    METHODS cancel_confirmations_atomic
      IMPORTING
        it_requests      TYPE
          zif_prod_order_api=>ty_confirmation_cancel_requests
      RETURNING
        VALUE(rs_result) TYPE ty_confirmation_cancel_result
      RAISING
        zcx_invalid_production_order.

    METHODS cancel_confirmations_bulk
      IMPORTING
        it_requests      TYPE
          zif_prod_order_api=>ty_confirmation_cancel_requests
      RETURNING
        VALUE(rs_result) TYPE ty_bulk_confirmation_cancel_result
      RAISING
        zcx_invalid_production_order.

    METHODS create_confirmations_bulk
      IMPORTING
        it_requests      TYPE
          zif_prod_order_api=>ty_confirmation_create_requests
      RETURNING
        VALUE(rs_result) TYPE ty_bulk_confirmation_create_result
      RAISING
        zcx_invalid_production_order.

    METHODS release_orders_after_atp
      IMPORTING
        it_production_orders TYPE zif_prod_order_api=>ty_order_numbers
        iv_release_control   TYPE zif_prod_order_api=>ty_release_control
        iv_check_rule        TYPE zif_material_availability_api=>ty_check_rule
      RETURNING
        VALUE(rs_result)     TYPE ty_atp_release_result
      RAISING
        zcx_invalid_production_order
        zcx_invalid_stock_request.

    METHODS release_orders_bulk_after_atp
      IMPORTING
        it_production_orders TYPE zif_prod_order_api=>ty_order_numbers
        iv_release_control   TYPE zif_prod_order_api=>ty_release_control
        iv_check_rule        TYPE zif_material_availability_api=>ty_check_rule
      RETURNING
        VALUE(rs_result)     TYPE ty_atp_bulk_release_result
      RAISING
        zcx_invalid_production_order
        zcx_invalid_stock_request.

    METHODS release_orders_bulk
      IMPORTING
        it_production_orders TYPE zif_prod_order_api=>ty_order_numbers
        iv_release_control   TYPE zif_prod_order_api=>ty_release_control
      RETURNING
        VALUE(rs_result)     TYPE ty_bulk_release_result
      RAISING
        zcx_invalid_production_order.

    METHODS complete_orders_tech_atomic
      IMPORTING
        it_production_orders TYPE zif_prod_order_api=>ty_order_numbers
      RETURNING
        VALUE(rs_result)     TYPE ty_completion_result
      RAISING
        zcx_invalid_production_order.

    METHODS complete_orders_tech_bulk
      IMPORTING
        it_production_orders TYPE zif_prod_order_api=>ty_order_numbers
      RETURNING
        VALUE(rs_result)     TYPE ty_bulk_completion_result
      RAISING
        zcx_invalid_production_order.

    METHODS set_deletion_flags_atomic
      IMPORTING
        it_production_orders TYPE zif_prod_order_api=>ty_order_numbers
      RETURNING
        VALUE(rs_result)     TYPE ty_deletion_flag_result
      RAISING
        zcx_invalid_production_order.

    METHODS set_deletion_flags_bulk
      IMPORTING
        it_production_orders TYPE zif_prod_order_api=>ty_order_numbers
      RETURNING
        VALUE(rs_result)     TYPE ty_bulk_deletion_flag_result
      RAISING
        zcx_invalid_production_order.

    METHODS close_orders_atomic
      IMPORTING
        it_production_orders TYPE zif_prod_order_api=>ty_order_numbers
      RETURNING
        VALUE(rs_result)     TYPE ty_close_result
      RAISING
        zcx_invalid_production_order.

    METHODS close_orders_bulk
      IMPORTING
        it_production_orders TYPE zif_prod_order_api=>ty_order_numbers
      RETURNING
        VALUE(rs_result)     TYPE ty_bulk_close_result
      RAISING
        zcx_invalid_production_order.

    METHODS set_deletion_indicators_atomic
      IMPORTING
        it_production_orders TYPE zif_prod_order_api=>ty_order_numbers
      RETURNING
        VALUE(rs_result)     TYPE ty_deletion_indicator_result
      RAISING
        zcx_invalid_production_order.

    METHODS set_deletion_indicators_bulk
      IMPORTING
        it_production_orders TYPE zif_prod_order_api=>ty_order_numbers
      RETURNING
        VALUE(rs_result)     TYPE ty_bulk_deletion_indicator_result
      RAISING
        zcx_invalid_production_order.

    METHODS change_orders_atomic
      IMPORTING
        it_requests      TYPE zif_prod_order_api=>ty_change_requests
      RETURNING
        VALUE(rs_result) TYPE ty_change_result
      RAISING
        zcx_invalid_production_order.

    METHODS change_orders_bulk
      IMPORTING
        it_requests      TYPE zif_prod_order_api=>ty_change_requests
      RETURNING
        VALUE(rs_result) TYPE ty_bulk_change_result
      RAISING
        zcx_invalid_production_order.

  PRIVATE SECTION.
    METHODS validate_create_order
      IMPORTING
        is_request TYPE zif_prod_order_api=>ty_create_order_request
      RAISING
        zcx_invalid_production_order.

    METHODS validate_create_orders
      IMPORTING
        it_requests TYPE zif_prod_order_api=>ty_create_order_requests
      RAISING
        zcx_invalid_production_order.

    METHODS prepare_create_order_request
      IMPORTING
        is_request        TYPE zif_prod_order_api=>ty_create_order_request
      RETURNING
        VALUE(rs_request) TYPE zif_prod_order_api=>ty_create_order_request.

    METHODS execute_order_create
      IMPORTING
        is_request       TYPE zif_prod_order_api=>ty_create_order_request
      RETURNING
        VALUE(rs_result) TYPE zif_prod_order_api=>ty_order_result.

    METHODS validate_order_numbers
      IMPORTING
        it_production_orders TYPE zif_prod_order_api=>ty_order_numbers
      RAISING
        zcx_invalid_production_order.

    METHODS validate_operation_keys
      IMPORTING
        it_operations      TYPE zif_prod_order_api=>ty_operation_keys
        iv_release_control TYPE zif_prod_order_api=>ty_release_control
      RAISING
        zcx_invalid_production_order.

    METHODS validate_confirmation_cancels
      IMPORTING
        it_requests TYPE
          zif_prod_order_api=>ty_confirmation_cancel_requests
      RAISING
        zcx_invalid_production_order.

    METHODS validate_confirmation_creates
      IMPORTING
        it_requests TYPE
          zif_prod_order_api=>ty_confirmation_create_requests
      RAISING
        zcx_invalid_production_order.

    METHODS validate_requests
      IMPORTING
        it_production_orders TYPE zif_prod_order_api=>ty_order_numbers
        iv_release_control   TYPE zif_prod_order_api=>ty_release_control
      RAISING
        zcx_invalid_production_order.

    METHODS validate_change_requests
      IMPORTING
        it_requests TYPE zif_prod_order_api=>ty_change_requests
      RAISING
        zcx_invalid_production_order.

    DATA mo_api TYPE REF TO zif_prod_order_api.
    DATA mo_atp_checker TYPE REF TO zif_prod_order_atp_checker.
ENDCLASS.

CLASS zcl_prod_order_service IMPLEMENTATION.

  METHOD constructor.
    mo_api = io_api.
    mo_atp_checker = io_atp_checker.
  ENDMETHOD.

  METHOD create_order.
    validate_create_order( is_request = is_request ).
    DATA(ls_request) = prepare_create_order_request(
      is_request = is_request ).

    rs_result-request = ls_request.
    rs_result-create_result = execute_order_create(
      is_request = ls_request ).

    IF rs_result-create_result-is_successful = abap_false.
      mo_api->rollback( ).
      rs_result-is_rolled_back = abap_true.
      RETURN.
    ENDIF.

    rs_result-commit_result = mo_api->commit( ).
    IF rs_result-commit_result-message-type = 'A'
        OR rs_result-commit_result-message-type = 'E'
        OR rs_result-commit_result-message-type = 'X'.
      rs_result-commit_result-is_successful = abap_false.
    ENDIF.
    IF rs_result-commit_result-is_successful = abap_false.
      mo_api->rollback( ).
      rs_result-create_result-is_successful = abap_false.
      rs_result-is_rolled_back = abap_true.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_committed = abap_true.
  ENDMETHOD.

  METHOD create_orders_atomic.
    DATA lt_created_orders TYPE HASHED TABLE OF
      zif_prod_order_api=>ty_order_number WITH UNIQUE KEY table_line.
    DATA lv_create_failed TYPE abap_bool.

    validate_create_orders( it_requests = it_requests ).
    LOOP AT it_requests INTO DATA(ls_request).
      DATA(ls_prepared_request) = prepare_create_order_request(
        is_request = ls_request ).
      APPEND VALUE #(
        request_index = sy-tabix
        request       = ls_prepared_request ) TO rs_result-orders.
    ENDLOOP.

    LOOP AT rs_result-orders ASSIGNING FIELD-SYMBOL(<ls_create_item>).
      <ls_create_item>-is_attempted = abap_true.
      <ls_create_item>-create_result = execute_order_create(
        is_request = <ls_create_item>-request ).
      lv_create_failed = xsdbool(
        <ls_create_item>-create_result-is_successful = abap_false ).
      IF lv_create_failed = abap_false.
        INSERT <ls_create_item>-create_result-production_order
          INTO TABLE lt_created_orders.
        IF sy-subrc <> 0.
          lv_create_failed = abap_true.
          <ls_create_item>-create_result-is_successful = abap_false.
          <ls_create_item>-create_result-message-type = 'E'.
          <ls_create_item>-create_result-message-message =
            'Duplicate production order number returned'.
        ENDIF.
      ENDIF.

      IF lv_create_failed = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_create_failed = abap_true.
      mo_api->rollback( ).
      rs_result-is_rolled_back = abap_true.
      rs_result-failed_count = lines( rs_result-orders ).
      LOOP AT rs_result-orders ASSIGNING FIELD-SYMBOL(<ls_rolled_back>).
        <ls_rolled_back>-create_result-is_successful = abap_false.
        IF <ls_rolled_back>-create_result-message-message IS INITIAL.
          <ls_rolled_back>-create_result-message-type = 'E'.
          IF <ls_rolled_back>-is_attempted = abap_true.
            <ls_rolled_back>-create_result-message-message =
              'Creation was rolled back because another order failed'.
          ELSE.
            <ls_rolled_back>-create_result-message-message =
              'Order was not attempted because the batch failed'.
          ENDIF.
        ENDIF.
      ENDLOOP.
      RETURN.
    ENDIF.

    rs_result-commit_result = mo_api->commit( ).
    IF rs_result-commit_result-message-type = 'A'
        OR rs_result-commit_result-message-type = 'E'
        OR rs_result-commit_result-message-type = 'X'.
      rs_result-commit_result-is_successful = abap_false.
    ENDIF.
    IF rs_result-commit_result-is_successful = abap_false.
      mo_api->rollback( ).
      rs_result-is_rolled_back = abap_true.
      rs_result-failed_count = lines( rs_result-orders ).
      LOOP AT rs_result-orders ASSIGNING <ls_create_item>.
        <ls_create_item>-create_result-is_successful = abap_false.
        <ls_create_item>-commit_result = rs_result-commit_result.
        IF rs_result-commit_result-message-message IS NOT INITIAL.
          <ls_create_item>-create_result-message =
            rs_result-commit_result-message.
        ENDIF.
      ENDLOOP.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_committed = abap_true.
    rs_result-successful_count = lines( rs_result-orders ).
    LOOP AT rs_result-orders ASSIGNING <ls_create_item>.
      <ls_create_item>-commit_result = rs_result-commit_result.
      <ls_create_item>-is_committed = abap_true.
    ENDLOOP.
  ENDMETHOD.

  METHOD create_orders_bulk.
    DATA lt_created_orders TYPE HASHED TABLE OF
      zif_prod_order_api=>ty_order_number WITH UNIQUE KEY table_line.

    validate_create_orders( it_requests = it_requests ).
    rs_result-is_successful = abap_true.

    LOOP AT it_requests INTO DATA(ls_request).
      DATA(ls_create_item) = VALUE ty_create_order_item(
        request_index = sy-tabix
        request       = prepare_create_order_request(
          is_request = ls_request )
        is_attempted  = abap_true ).
      ls_create_item-create_result = execute_order_create(
        is_request = ls_create_item-request ).

      IF ls_create_item-create_result-is_successful = abap_true.
        INSERT ls_create_item-create_result-production_order
          INTO TABLE lt_created_orders.
        IF sy-subrc <> 0.
          ls_create_item-create_result-is_successful = abap_false.
          ls_create_item-create_result-message-type = 'E'.
          ls_create_item-create_result-message-message =
            'Duplicate production order number returned'.
        ENDIF.
      ENDIF.

      IF ls_create_item-create_result-is_successful = abap_false.
        mo_api->rollback( ).
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-failed_count.
        APPEND ls_create_item TO rs_result-orders.
        CONTINUE.
      ENDIF.

      ls_create_item-commit_result = mo_api->commit( ).
      IF ls_create_item-commit_result-message-type = 'A'
          OR ls_create_item-commit_result-message-type = 'E'
          OR ls_create_item-commit_result-message-type = 'X'.
        ls_create_item-commit_result-is_successful = abap_false.
      ENDIF.
      IF ls_create_item-commit_result-is_successful = abap_false.
        mo_api->rollback( ).
        DELETE TABLE lt_created_orders
          FROM ls_create_item-create_result-production_order.
        ls_create_item-create_result-is_successful = abap_false.
        IF ls_create_item-commit_result-message-message IS NOT INITIAL.
          ls_create_item-create_result-message =
            ls_create_item-commit_result-message.
        ENDIF.
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-failed_count.
        APPEND ls_create_item TO rs_result-orders.
        CONTINUE.
      ENDIF.

      ls_create_item-is_committed = abap_true.
      ADD 1 TO rs_result-successful_count.
      APPEND ls_create_item TO rs_result-orders.
    ENDLOOP.
  ENDMETHOD.

  METHOD release_orders_after_atp.
    validate_requests(
      it_production_orders = it_production_orders
      iv_release_control   = iv_release_control ).
    IF iv_check_rule IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF mo_atp_checker IS NOT BOUND.
      rs_result-message-type = 'E'.
      rs_result-message-message = 'ATP checker is not configured'.
      RETURN.
    ENDIF.

    rs_result-component_readiness = mo_atp_checker->check_components(
      it_production_orders = it_production_orders
      iv_check_rule        = iv_check_rule ).
    IF lines( rs_result-component_readiness ) <>
        lines( it_production_orders ).
      rs_result-message-type = 'E'.
      rs_result-message-message =
        'ATP checker returned an incomplete order list'.
      RETURN.
    ENDIF.

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      DATA(lv_request_index) = sy-tabix.
      READ TABLE rs_result-component_readiness
        INTO DATA(ls_readiness) INDEX lv_request_index.
      IF sy-subrc <> 0
          OR ls_readiness-production_order <> lv_production_order.
        rs_result-message-type = 'E'.
        rs_result-message-message =
          'ATP checker returned results in an unexpected order'.
        RETURN.
      ENDIF.

      IF ls_readiness-component_count < 0
          OR ls_readiness-not_fully_confirmed_count < 0
          OR ls_readiness-not_fully_confirmed_count >
            ls_readiness-component_count
          OR ls_readiness-requested_base_quantity < 0
          OR ls_readiness-confirmed_base_quantity < 0
          OR ls_readiness-unconfirmed_base_quantity < 0
          OR ls_readiness-confirmed_base_quantity
            + ls_readiness-unconfirmed_base_quantity <>
            ls_readiness-requested_base_quantity
          OR ( ls_readiness-component_count = 0
            AND ls_readiness-requested_base_quantity <> 0 ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      IF ls_readiness-is_fully_confirmed <> abap_true
          OR ls_readiness-not_fully_confirmed_count > 0
          OR ls_readiness-unconfirmed_base_quantity > 0.
        rs_result-message-type = 'E'.
        rs_result-message-message =
          'One or more order components are not fully confirmed'.
        RETURN.
      ENDIF.
    ENDLOOP.

    rs_result-is_atp_ready = abap_true.
    rs_result-release_result = release_orders_atomic(
      it_production_orders = it_production_orders
      iv_release_control   = iv_release_control ).
    rs_result-is_successful = rs_result-release_result-is_successful.
    rs_result-is_released = rs_result-release_result-is_committed.
  ENDMETHOD.

  METHOD release_orders_bulk_after_atp.
    DATA lt_ready_orders TYPE zif_prod_order_api=>ty_order_numbers.
    DATA lt_ready_request_indexes TYPE STANDARD TABLE OF i
      WITH EMPTY KEY.

    validate_requests(
      it_production_orders = it_production_orders
      iv_release_control   = iv_release_control ).
    IF iv_check_rule IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      APPEND VALUE #(
        request_index    = sy-tabix
        production_order = lv_production_order ) TO rs_result-orders.
    ENDLOOP.

    IF mo_atp_checker IS NOT BOUND.
      rs_result-message-type = 'E'.
      rs_result-message-message = 'ATP checker is not configured'.
      rs_result-failed_count = lines( it_production_orders ).
      LOOP AT rs_result-orders ASSIGNING FIELD-SYMBOL(<ls_atp_order>).
        <ls_atp_order>-message = rs_result-message.
      ENDLOOP.
      RETURN.
    ENDIF.

    DATA(lt_readiness) = mo_atp_checker->check_components(
      it_production_orders = it_production_orders
      iv_check_rule        = iv_check_rule ).
    IF lines( lt_readiness ) <> lines( it_production_orders ).
      rs_result-message-type = 'E'.
      rs_result-message-message =
        'ATP checker returned an incomplete order list'.
      rs_result-failed_count = lines( it_production_orders ).
      LOOP AT rs_result-orders ASSIGNING <ls_atp_order>.
        <ls_atp_order>-message = rs_result-message.
      ENDLOOP.
      RETURN.
    ENDIF.

    LOOP AT it_production_orders INTO lv_production_order.
      DATA(lv_readiness_index) = sy-tabix.
      READ TABLE lt_readiness INTO DATA(ls_readiness)
        INDEX lv_readiness_index.
      IF sy-subrc <> 0
          OR ls_readiness-production_order <> lv_production_order.
        rs_result-message-type = 'E'.
        rs_result-message-message =
          'ATP checker returned results in an unexpected order'.
        rs_result-failed_count = lines( it_production_orders ).
        LOOP AT rs_result-orders ASSIGNING <ls_atp_order>.
          <ls_atp_order>-message = rs_result-message.
        ENDLOOP.
        RETURN.
      ENDIF.

      IF ls_readiness-component_count < 0
          OR ls_readiness-not_fully_confirmed_count < 0
          OR ls_readiness-not_fully_confirmed_count >
            ls_readiness-component_count
          OR ls_readiness-requested_base_quantity < 0
          OR ls_readiness-confirmed_base_quantity < 0
          OR ls_readiness-unconfirmed_base_quantity < 0
          OR ls_readiness-confirmed_base_quantity
            + ls_readiness-unconfirmed_base_quantity <>
            ls_readiness-requested_base_quantity
          OR ( ls_readiness-component_count = 0
            AND ls_readiness-requested_base_quantity <> 0 )
          OR ( ls_readiness-is_fully_confirmed <> abap_true
            AND ls_readiness-is_fully_confirmed <> abap_false ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    rs_result-is_atp_checked = abap_true.
    rs_result-is_successful = abap_true.
    LOOP AT it_production_orders INTO lv_production_order.
      DATA(lv_request_index) = sy-tabix.
      READ TABLE lt_readiness INTO ls_readiness INDEX lv_request_index.
      ASSIGN rs_result-orders[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_order_result>).
      <ls_order_result>-component_readiness = ls_readiness.
      IF ls_readiness-is_fully_confirmed = abap_true
          AND ls_readiness-not_fully_confirmed_count = 0
          AND ls_readiness-unconfirmed_base_quantity = 0.
        <ls_order_result>-is_atp_ready = abap_true.
        APPEND lv_production_order TO lt_ready_orders.
        APPEND lv_request_index TO lt_ready_request_indexes.
        CONTINUE.
      ENDIF.

      rs_result-is_successful = abap_false.
      ADD 1 TO rs_result-atp_blocked_count.
      ADD 1 TO rs_result-failed_count.
      <ls_order_result>-message-type = 'E'.
      <ls_order_result>-message-message =
        'One or more order components are not fully confirmed'.
    ENDLOOP.

    IF lt_ready_orders IS INITIAL.
      RETURN.
    ENDIF.

    DATA(ls_release_result) = release_orders_bulk(
      it_production_orders = lt_ready_orders
      iv_release_control   = iv_release_control ).
    rs_result-successful_count = ls_release_result-successful_count.
    rs_result-failed_count = rs_result-failed_count
      + ls_release_result-failed_count.
    IF ls_release_result-is_successful = abap_false.
      rs_result-is_successful = abap_false.
    ENDIF.

    LOOP AT ls_release_result-orders INTO DATA(ls_released_order).
      READ TABLE lt_ready_request_indexes INTO DATA(lv_original_index)
        INDEX ls_released_order-request_index.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      ASSIGN rs_result-orders[ lv_original_index ]
        TO <ls_order_result>.
      <ls_order_result>-release_result = ls_released_order-release_result.
      <ls_order_result>-commit_result = ls_released_order-commit_result.
      <ls_order_result>-is_attempted = ls_released_order-is_attempted.
      <ls_order_result>-is_committed = ls_released_order-is_committed.
      <ls_order_result>-message = ls_released_order-release_result-message.
      IF ls_released_order-is_committed = abap_false
          AND ls_released_order-release_result-is_successful = abap_true.
        <ls_order_result>-message = ls_released_order-commit_result-message.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD prepare_create_order_request.
    rs_request = is_request.
    IF rs_request-planning_plant IS INITIAL.
      rs_request-planning_plant = rs_request-plant.
    ENDIF.
  ENDMETHOD.

  METHOD execute_order_create.
    rs_result = mo_api->create_order( is_request = is_request ).
    IF rs_result-is_successful = abap_true
        AND ( rs_result-production_order IS INITIAL
          OR ( is_request-order_number IS NOT INITIAL
            AND rs_result-production_order <> is_request-order_number ) ).
      rs_result-is_successful = abap_false.
      rs_result-message-type = 'E'.
      rs_result-message-message =
        'Production order result did not match the request'.
    ENDIF.
  ENDMETHOD.

  METHOD validate_create_orders.
    DATA lt_seen_order_numbers TYPE HASHED TABLE OF
      zif_prod_order_api=>ty_order_number WITH UNIQUE KEY table_line.

    IF it_requests IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_production_order.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      validate_create_order( is_request = ls_request ).
      IF ls_request-order_number IS NOT INITIAL.
        INSERT ls_request-order_number INTO TABLE lt_seen_order_numbers.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_production_order.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_create_order.
    IF is_request-material IS INITIAL
        OR is_request-plant IS INITIAL
        OR is_request-order_type IS INITIAL
        OR is_request-quantity <= 0
        OR is_request-quantity_uom IS INITIAL
        OR ( is_request-basic_start_date IS INITIAL
          AND is_request-basic_finish_date IS INITIAL )
        OR ( is_request-basic_start_date IS NOT INITIAL
          AND is_request-basic_finish_date IS NOT INITIAL
          AND is_request-basic_start_date
            > is_request-basic_finish_date ).
      RAISE EXCEPTION TYPE zcx_invalid_production_order.
    ENDIF.
  ENDMETHOD.

  METHOD validate_requests.
    IF iv_release_control IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_production_order.
    ENDIF.

    validate_order_numbers( it_production_orders = it_production_orders ).
  ENDMETHOD.

  METHOD validate_order_numbers.
    TYPES ty_seen_order TYPE zif_prod_order_api=>ty_order_number.
    DATA lt_seen_orders TYPE HASHED TABLE OF ty_seen_order
      WITH UNIQUE KEY table_line.

    IF it_production_orders IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_production_order.
    ENDIF.

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      INSERT lv_production_order INTO TABLE lt_seen_orders.
      IF lv_production_order IS INITIAL OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_production_order.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_operation_keys.
    TYPES:
      BEGIN OF ty_seen_operation,
        production_order TYPE zif_prod_order_api=>ty_order_number,
        operation_number TYPE zif_prod_order_api=>ty_operation_number,
      END OF ty_seen_operation.
    TYPES ty_seen_operations TYPE HASHED TABLE OF ty_seen_operation
      WITH UNIQUE KEY production_order operation_number.
    DATA lt_seen_operations TYPE ty_seen_operations.

    IF iv_release_control IS INITIAL OR it_operations IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_production_order.
    ENDIF.

    LOOP AT it_operations INTO DATA(ls_operation).
      INSERT VALUE #(
        production_order = ls_operation-production_order
        operation_number = ls_operation-operation_number )
        INTO TABLE lt_seen_operations.
      IF ls_operation-production_order IS INITIAL
          OR ls_operation-operation_number IS INITIAL
          OR ls_operation-operation_number+3(1) IS INITIAL
          OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_production_order.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_confirmation_cancels.
    TYPES:
      BEGIN OF ty_seen_confirmation,
        confirmation         TYPE
          zif_prod_order_api=>ty_confirmation_number,
        confirmation_counter TYPE
          zif_prod_order_api=>ty_confirmation_counter,
      END OF ty_seen_confirmation.
    TYPES ty_seen_confirmations TYPE HASHED TABLE OF
      ty_seen_confirmation
      WITH UNIQUE KEY confirmation confirmation_counter.
    DATA lt_seen_confirmations TYPE ty_seen_confirmations.

    IF it_requests IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_production_order.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      INSERT VALUE #(
        confirmation         = ls_request-confirmation
        confirmation_counter = ls_request-confirmation_counter )
        INTO TABLE lt_seen_confirmations.
      IF ls_request-confirmation IS INITIAL
          OR ls_request-confirmation_counter IS INITIAL
          OR ls_request-posting_date IS INITIAL
          OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_production_order.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_confirmation_creates.
    IF it_requests IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_production_order.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-production_order IS INITIAL
          OR ls_request-operation_number CN '0123456789'
          OR ls_request-operation_sequence CN '0123456789'
          OR ls_request-posting_date IS INITIAL
          OR ls_request-yield_quantity < 0
          OR ls_request-scrap_quantity < 0
          OR ls_request-rework_quantity < 0
          OR ls_request-quantity_unit_iso IS INITIAL
          OR ( ls_request-final_confirmation IS NOT INITIAL
            AND ls_request-final_confirmation <> '1'
            AND ls_request-final_confirmation <> 'X' )
          OR ( ls_request-clear_reservations IS NOT INITIAL
            AND ls_request-clear_reservations <> abap_true ).
        RAISE EXCEPTION TYPE zcx_invalid_production_order.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD release_operations_atomic.
    TYPES:
      BEGIN OF ty_seen_operation,
        production_order TYPE zif_prod_order_api=>ty_order_number,
        operation_number TYPE zif_prod_order_api=>ty_operation_number,
      END OF ty_seen_operation.
    TYPES ty_seen_operations TYPE HASHED TABLE OF ty_seen_operation
      WITH UNIQUE KEY production_order operation_number.
    DATA lt_seen_results TYPE ty_seen_operations.

    validate_operation_keys(
      it_operations      = it_operations
      iv_release_control = iv_release_control ).
    rs_result-is_successful = abap_true.

    DATA(ls_api_result) = mo_api->release_operations(
      it_operations      = it_operations
      iv_release_control = iv_release_control ).
    IF lines( ls_api_result-operations ) <> lines( it_operations ).
      rs_result-is_successful = abap_false.
    ENDIF.

    LOOP AT ls_api_result-operations INTO DATA(ls_api_operation).
      INSERT VALUE #(
        production_order = ls_api_operation-production_order
        operation_number = ls_api_operation-operation_number )
        INTO TABLE lt_seen_results.
      IF sy-subrc <> 0 OR NOT line_exists( it_operations[
          production_order = ls_api_operation-production_order
          operation_number = ls_api_operation-operation_number ] ).
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.

    LOOP AT it_operations INTO DATA(ls_operation).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index = lv_request_index
        operation_key = ls_operation
        is_attempted  = abap_true ) TO rs_result-operations.
      ASSIGN rs_result-operations[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_operation_result>).

      READ TABLE ls_api_result-operations
        ASSIGNING FIELD-SYMBOL(<ls_api_operation>)
        WITH KEY production_order = ls_operation-production_order
          operation_number = ls_operation-operation_number.
      IF sy-subrc = 0.
        <ls_operation_result>-release_result = <ls_api_operation>.
      ELSE.
        <ls_operation_result>-release_result-production_order =
          ls_operation-production_order.
        <ls_operation_result>-release_result-operation_number =
          ls_operation-operation_number.
        <ls_operation_result>-release_result-is_successful = abap_false.
        <ls_operation_result>-release_result-message-type = 'E'.
        <ls_operation_result>-release_result-message-message =
          'Operation release result was missing or mismatched'.
        rs_result-is_successful = abap_false.
      ENDIF.

      IF <ls_operation_result>-release_result-is_successful = abap_false.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.

    IF ls_api_result-is_successful = abap_false.
      rs_result-is_successful = abap_false.
    ENDIF.
    IF rs_result-is_successful = abap_false.
      mo_api->rollback( ).
      rs_result-is_rolled_back = abap_true.
      LOOP AT rs_result-operations ASSIGNING <ls_operation_result>.
        <ls_operation_result>-release_result-is_successful = abap_false.
      ENDLOOP.
      RETURN.
    ENDIF.

    rs_result-commit_result = mo_api->commit( ).
    IF rs_result-commit_result-message-type = 'A'
        OR rs_result-commit_result-message-type = 'E'
        OR rs_result-commit_result-message-type = 'X'.
      rs_result-commit_result-is_successful = abap_false.
    ENDIF.
    IF rs_result-commit_result-is_successful = abap_false.
      mo_api->rollback( ).
      rs_result-is_successful = abap_false.
      rs_result-is_rolled_back = abap_true.
      LOOP AT rs_result-operations ASSIGNING <ls_operation_result>.
        <ls_operation_result>-release_result-is_successful = abap_false.
      ENDLOOP.
      RETURN.
    ENDIF.

    rs_result-is_committed = abap_true.
    LOOP AT rs_result-operations ASSIGNING <ls_operation_result>.
      <ls_operation_result>-is_committed = abap_true.
    ENDLOOP.
  ENDMETHOD.

  METHOD release_operations_bulk.
    validate_operation_keys(
      it_operations      = it_operations
      iv_release_control = iv_release_control ).
    rs_result-is_successful = abap_true.

    LOOP AT it_operations INTO DATA(ls_operation).
      DATA(lv_request_index) = sy-tabix.
      DATA(lt_single_operation) =
        VALUE zif_prod_order_api=>ty_operation_keys( ( ls_operation ) ).
      APPEND VALUE #(
        request_index = lv_request_index
        operation_key = ls_operation
        is_attempted  = abap_true ) TO rs_result-operations.
      ASSIGN rs_result-operations[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_bulk_operation_result>).

      DATA(ls_api_result) = mo_api->release_operations(
        it_operations      = lt_single_operation
        iv_release_control = iv_release_control ).
      READ TABLE ls_api_result-operations
        ASSIGNING FIELD-SYMBOL(<ls_api_operation>) INDEX 1.
      IF lines( ls_api_result-operations ) = 1
          AND sy-subrc = 0
          AND <ls_api_operation>-production_order =
            ls_operation-production_order
          AND <ls_api_operation>-operation_number =
            ls_operation-operation_number.
        <ls_bulk_operation_result>-release_result = <ls_api_operation>.
      ELSE.
        <ls_bulk_operation_result>-release_result-production_order =
          ls_operation-production_order.
        <ls_bulk_operation_result>-release_result-operation_number =
          ls_operation-operation_number.
        <ls_bulk_operation_result>-release_result-is_successful =
          abap_false.
        <ls_bulk_operation_result>-release_result-message-type = 'E'.
        <ls_bulk_operation_result>-release_result-message-message =
          'Operation release result was missing or did not match'.
      ENDIF.

      IF ls_api_result-is_successful = abap_false
          OR <ls_bulk_operation_result>-release_result-is_successful =
            abap_false.
        mo_api->rollback( ).
        <ls_bulk_operation_result>-release_result-is_successful =
          abap_false.
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-failed_count.
        CONTINUE.
      ENDIF.

      <ls_bulk_operation_result>-commit_result = mo_api->commit( ).
      IF <ls_bulk_operation_result>-commit_result-message-type = 'A'
          OR <ls_bulk_operation_result>-commit_result-message-type = 'E'
          OR <ls_bulk_operation_result>-commit_result-message-type = 'X'.
        <ls_bulk_operation_result>-commit_result-is_successful = abap_false.
      ENDIF.
      IF <ls_bulk_operation_result>-commit_result-is_successful = abap_false.
        mo_api->rollback( ).
        <ls_bulk_operation_result>-release_result-is_successful =
          abap_false.
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-failed_count.
        CONTINUE.
      ENDIF.

      <ls_bulk_operation_result>-is_committed = abap_true.
      ADD 1 TO rs_result-successful_count.
    ENDLOOP.
  ENDMETHOD.

  METHOD cancel_confirmations_atomic.
    validate_confirmation_cancels( it_requests = it_requests ).
    rs_result-is_successful = abap_true.

    LOOP AT it_requests INTO DATA(ls_request).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index = lv_request_index
        request       = ls_request
        is_attempted  = abap_true ) TO rs_result-confirmations.
      ASSIGN rs_result-confirmations[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_cancel_item>).

      <ls_cancel_item>-cancel_result = mo_api->cancel_confirmation(
        is_request = ls_request ).
      IF <ls_cancel_item>-cancel_result-confirmation <>
            ls_request-confirmation
          OR <ls_cancel_item>-cancel_result-confirmation_counter <>
            ls_request-confirmation_counter.
        <ls_cancel_item>-cancel_result-confirmation =
          ls_request-confirmation.
        <ls_cancel_item>-cancel_result-confirmation_counter =
          ls_request-confirmation_counter.
        <ls_cancel_item>-cancel_result-is_successful = abap_false.
        <ls_cancel_item>-cancel_result-message-type = 'E'.
        <ls_cancel_item>-cancel_result-message-message =
          'Confirmation cancellation result did not match the request'.
      ENDIF.
      IF <ls_cancel_item>-cancel_result-is_successful = abap_false.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.

    IF rs_result-is_successful = abap_false.
      mo_api->rollback( ).
      rs_result-is_rolled_back = abap_true.
      LOOP AT rs_result-confirmations ASSIGNING <ls_cancel_item>.
        <ls_cancel_item>-cancel_result-is_successful = abap_false.
      ENDLOOP.
      RETURN.
    ENDIF.

    rs_result-commit_result = mo_api->commit( ).
    IF rs_result-commit_result-message-type = 'A'
        OR rs_result-commit_result-message-type = 'E'
        OR rs_result-commit_result-message-type = 'X'.
      rs_result-commit_result-is_successful = abap_false.
    ENDIF.
    IF rs_result-commit_result-is_successful = abap_false.
      mo_api->rollback( ).
      rs_result-is_successful = abap_false.
      rs_result-is_rolled_back = abap_true.
      LOOP AT rs_result-confirmations ASSIGNING <ls_cancel_item>.
        <ls_cancel_item>-cancel_result-is_successful = abap_false.
      ENDLOOP.
      RETURN.
    ENDIF.

    rs_result-is_committed = abap_true.
    LOOP AT rs_result-confirmations ASSIGNING <ls_cancel_item>.
      <ls_cancel_item>-is_committed = abap_true.
    ENDLOOP.
  ENDMETHOD.

  METHOD cancel_confirmations_bulk.
    validate_confirmation_cancels( it_requests = it_requests ).
    rs_result-is_successful = abap_true.

    LOOP AT it_requests INTO DATA(ls_request).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index = lv_request_index
        request       = ls_request
        is_attempted  = abap_true ) TO rs_result-confirmations.
      ASSIGN rs_result-confirmations[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_bulk_cancel_item>).

      <ls_bulk_cancel_item>-cancel_result = mo_api->cancel_confirmation(
        is_request = ls_request ).
      IF <ls_bulk_cancel_item>-cancel_result-confirmation <>
            ls_request-confirmation
          OR <ls_bulk_cancel_item>-cancel_result-confirmation_counter <>
            ls_request-confirmation_counter.
        <ls_bulk_cancel_item>-cancel_result-confirmation =
          ls_request-confirmation.
        <ls_bulk_cancel_item>-cancel_result-confirmation_counter =
          ls_request-confirmation_counter.
        <ls_bulk_cancel_item>-cancel_result-is_successful = abap_false.
        <ls_bulk_cancel_item>-cancel_result-message-type = 'E'.
        <ls_bulk_cancel_item>-cancel_result-message-message =
          'Confirmation cancellation result did not match the request'.
      ENDIF.

      IF <ls_bulk_cancel_item>-cancel_result-is_successful = abap_false.
        mo_api->rollback( ).
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-failed_count.
        CONTINUE.
      ENDIF.

      <ls_bulk_cancel_item>-commit_result = mo_api->commit( ).
      IF <ls_bulk_cancel_item>-commit_result-message-type = 'A'
          OR <ls_bulk_cancel_item>-commit_result-message-type = 'E'
          OR <ls_bulk_cancel_item>-commit_result-message-type = 'X'.
        <ls_bulk_cancel_item>-commit_result-is_successful = abap_false.
      ENDIF.
      IF <ls_bulk_cancel_item>-commit_result-is_successful = abap_false.
        mo_api->rollback( ).
        <ls_bulk_cancel_item>-cancel_result-is_successful = abap_false.
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-failed_count.
        CONTINUE.
      ENDIF.

      <ls_bulk_cancel_item>-is_committed = abap_true.
      ADD 1 TO rs_result-successful_count.
    ENDLOOP.
  ENDMETHOD.

  METHOD create_confirmations_bulk.
    validate_confirmation_creates( it_requests = it_requests ).
    rs_result-is_successful = abap_true.

    LOOP AT it_requests INTO DATA(ls_request).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index = lv_request_index
        request       = ls_request
        is_attempted  = abap_true ) TO rs_result-confirmations.
      ASSIGN rs_result-confirmations[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_create_item>).

      <ls_create_item>-create_result = mo_api->create_confirmation(
        is_request = ls_request ).
      <ls_create_item>-commit_result =
        <ls_create_item>-create_result-commit_result.
      IF <ls_create_item>-create_result-production_order <>
            ls_request-production_order
          OR <ls_create_item>-create_result-operation_number <>
            ls_request-operation_number
          OR <ls_create_item>-create_result-operation_sequence <>
            ls_request-operation_sequence.
        <ls_create_item>-create_result-production_order =
          ls_request-production_order.
        <ls_create_item>-create_result-operation_number =
          ls_request-operation_number.
        <ls_create_item>-create_result-operation_sequence =
          ls_request-operation_sequence.
        <ls_create_item>-create_result-is_successful = abap_false.
        <ls_create_item>-create_result-message-type = 'E'.
        <ls_create_item>-create_result-message-message =
          'Confirmation result did not match the request'.
      ENDIF.

      IF <ls_create_item>-commit_result-message-type = 'A'
          OR <ls_create_item>-commit_result-message-type = 'E'
          OR <ls_create_item>-commit_result-message-type = 'X'.
        <ls_create_item>-commit_result-is_successful = abap_false.
      ENDIF.
      IF <ls_create_item>-create_result-is_successful = abap_false
          OR <ls_create_item>-commit_result-is_successful = abap_false.
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-failed_count.
        CONTINUE.
      ENDIF.

      <ls_create_item>-is_committed = abap_true.
      ADD 1 TO rs_result-successful_count.
    ENDLOOP.
  ENDMETHOD.

  METHOD release_orders_atomic.
    validate_requests(
      it_production_orders = it_production_orders
      iv_release_control   = iv_release_control ).
    rs_result-is_successful = abap_true.

    DATA(ls_api_result) = mo_api->release_orders(
      it_production_orders = it_production_orders
      iv_release_control   = iv_release_control ).

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index = lv_request_index
        is_attempted  = abap_true ) TO rs_result-orders.
      ASSIGN rs_result-orders[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_order_result>).

      READ TABLE ls_api_result-orders
        ASSIGNING FIELD-SYMBOL(<ls_api_order_result>)
        INDEX lv_request_index.
      IF sy-subrc = 0
          AND <ls_api_order_result>-production_order = lv_production_order.
        <ls_order_result>-release_result = <ls_api_order_result>.
      ELSE.
        <ls_order_result>-release_result-production_order =
          lv_production_order.
        <ls_order_result>-release_result-is_successful = abap_false.
        <ls_order_result>-release_result-message-type = 'E'.
        <ls_order_result>-release_result-message-message =
          'Release API result was missing or out of order'.
        rs_result-is_successful = abap_false.
      ENDIF.

      IF <ls_order_result>-release_result-is_successful = abap_false.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.

    IF ls_api_result-is_successful = abap_false.
      rs_result-is_successful = abap_false.
    ENDIF.
    IF rs_result-is_successful = abap_false.
      mo_api->rollback( ).
      rs_result-is_rolled_back = abap_true.
      LOOP AT rs_result-orders ASSIGNING <ls_order_result>.
        <ls_order_result>-release_result-is_successful = abap_false.
      ENDLOOP.
      RETURN.
    ENDIF.

    rs_result-commit_result = mo_api->commit( ).
    IF rs_result-commit_result-message-type = 'A'
        OR rs_result-commit_result-message-type = 'E'
        OR rs_result-commit_result-message-type = 'X'.
      rs_result-commit_result-is_successful = abap_false.
    ENDIF.
    IF rs_result-commit_result-is_successful = abap_false.
      mo_api->rollback( ).
      rs_result-is_successful = abap_false.
      rs_result-is_rolled_back = abap_true.
      LOOP AT rs_result-orders ASSIGNING <ls_order_result>.
        <ls_order_result>-release_result-is_successful = abap_false.
      ENDLOOP.
      RETURN.
    ENDIF.

    rs_result-is_committed = abap_true.
    LOOP AT rs_result-orders ASSIGNING <ls_order_result>.
      <ls_order_result>-is_committed = abap_true.
    ENDLOOP.
  ENDMETHOD.

  METHOD release_orders_bulk.
    validate_requests(
      it_production_orders = it_production_orders
      iv_release_control   = iv_release_control ).
    rs_result-is_successful = abap_true.

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      DATA(lv_request_index) = sy-tabix.
      DATA(lt_single_order) = VALUE zif_prod_order_api=>ty_order_numbers(
        ( lv_production_order ) ).
      APPEND VALUE #(
        request_index = lv_request_index
        is_attempted  = abap_true ) TO rs_result-orders.
      ASSIGN rs_result-orders[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_bulk_order_result>).

      DATA(ls_api_result) = mo_api->release_orders(
        it_production_orders = lt_single_order
        iv_release_control   = iv_release_control ).
      READ TABLE ls_api_result-orders
        ASSIGNING FIELD-SYMBOL(<ls_api_order_result>) INDEX 1.
      IF sy-subrc = 0
          AND <ls_api_order_result>-production_order = lv_production_order.
        <ls_bulk_order_result>-release_result = <ls_api_order_result>.
      ELSE.
        <ls_bulk_order_result>-release_result-production_order =
          lv_production_order.
        <ls_bulk_order_result>-release_result-is_successful = abap_false.
        <ls_bulk_order_result>-release_result-message-type = 'E'.
        <ls_bulk_order_result>-release_result-message-message =
          'Release API result was missing or did not match'.
      ENDIF.

      IF ls_api_result-is_successful = abap_false
          OR <ls_bulk_order_result>-release_result-is_successful =
            abap_false.
        mo_api->rollback( ).
        <ls_bulk_order_result>-release_result-is_successful = abap_false.
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-failed_count.
        CONTINUE.
      ENDIF.

      <ls_bulk_order_result>-commit_result = mo_api->commit( ).
      IF <ls_bulk_order_result>-commit_result-message-type = 'A'
          OR <ls_bulk_order_result>-commit_result-message-type = 'E'
          OR <ls_bulk_order_result>-commit_result-message-type = 'X'.
        <ls_bulk_order_result>-commit_result-is_successful = abap_false.
      ENDIF.
      IF <ls_bulk_order_result>-commit_result-is_successful = abap_false.
        mo_api->rollback( ).
        <ls_bulk_order_result>-release_result-is_successful = abap_false.
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-failed_count.
        CONTINUE.
      ENDIF.

      <ls_bulk_order_result>-is_committed = abap_true.
      ADD 1 TO rs_result-successful_count.
    ENDLOOP.
  ENDMETHOD.

  METHOD complete_orders_tech_atomic.
    validate_order_numbers( it_production_orders = it_production_orders ).
    rs_result-is_successful = abap_true.

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index = lv_request_index
        is_attempted  = abap_true ) TO rs_result-orders.
      ASSIGN rs_result-orders[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_completion_order>).

      <ls_completion_order>-completion_result =
        mo_api->complete_technically(
          iv_production_order = lv_production_order ).
      IF <ls_completion_order>-completion_result-production_order <>
          lv_production_order.
        <ls_completion_order>-completion_result-production_order =
          lv_production_order.
        <ls_completion_order>-completion_result-is_successful =
          abap_false.
        <ls_completion_order>-completion_result-message-type = 'E'.
        <ls_completion_order>-completion_result-message-message =
          'Completion API result did not match the requested order'.
      ENDIF.

      IF <ls_completion_order>-completion_result-is_successful =
          abap_false.
        rs_result-is_successful = abap_false.
        mo_api->rollback( ).
        rs_result-is_rolled_back = abap_true.
        LOOP AT rs_result-orders ASSIGNING <ls_completion_order>.
          <ls_completion_order>-completion_result-is_successful =
            abap_false.
        ENDLOOP.
        RETURN.
      ENDIF.
    ENDLOOP.

    rs_result-commit_result = mo_api->commit( ).
    IF rs_result-commit_result-message-type = 'A'
        OR rs_result-commit_result-message-type = 'E'
        OR rs_result-commit_result-message-type = 'X'.
      rs_result-commit_result-is_successful = abap_false.
    ENDIF.
    IF rs_result-commit_result-is_successful = abap_false.
      rs_result-is_successful = abap_false.
      mo_api->rollback( ).
      rs_result-is_rolled_back = abap_true.
      LOOP AT rs_result-orders ASSIGNING <ls_completion_order>.
        <ls_completion_order>-completion_result-is_successful =
          abap_false.
      ENDLOOP.
      RETURN.
    ENDIF.

    rs_result-is_committed = abap_true.
    LOOP AT rs_result-orders ASSIGNING <ls_completion_order>.
      <ls_completion_order>-is_committed = abap_true.
    ENDLOOP.
  ENDMETHOD.

  METHOD complete_orders_tech_bulk.
    validate_order_numbers( it_production_orders = it_production_orders ).
    rs_result-is_successful = abap_true.

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index = lv_request_index
        is_attempted  = abap_true ) TO rs_result-orders.
      ASSIGN rs_result-orders[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_completion_order>).

      <ls_completion_order>-completion_result =
        mo_api->complete_technically(
          iv_production_order = lv_production_order ).
      IF <ls_completion_order>-completion_result-production_order <>
          lv_production_order.
        <ls_completion_order>-completion_result-production_order =
          lv_production_order.
        <ls_completion_order>-completion_result-is_successful =
          abap_false.
        <ls_completion_order>-completion_result-message-type = 'E'.
        <ls_completion_order>-completion_result-message-message =
          'Completion API result did not match the requested order'.
      ENDIF.

      IF <ls_completion_order>-completion_result-is_successful =
          abap_false.
        mo_api->rollback( ).
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-failed_count.
        CONTINUE.
      ENDIF.

      <ls_completion_order>-commit_result = mo_api->commit( ).
      IF <ls_completion_order>-commit_result-message-type = 'A'
          OR <ls_completion_order>-commit_result-message-type = 'E'
          OR <ls_completion_order>-commit_result-message-type = 'X'.
        <ls_completion_order>-commit_result-is_successful = abap_false.
      ENDIF.
      IF <ls_completion_order>-commit_result-is_successful = abap_false.
        mo_api->rollback( ).
        <ls_completion_order>-completion_result-is_successful = abap_false.
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-failed_count.
        CONTINUE.
      ENDIF.

      <ls_completion_order>-is_committed = abap_true.
      ADD 1 TO rs_result-completed_count.
    ENDLOOP.
  ENDMETHOD.

  METHOD set_deletion_flags_atomic.
    validate_order_numbers( it_production_orders = it_production_orders ).
    rs_result-is_successful = abap_true.

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index = lv_request_index
        is_attempted  = abap_true ) TO rs_result-orders.
      ASSIGN rs_result-orders[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_deletion_order>).

      <ls_deletion_order>-deletion_flag_result =
        mo_api->set_deletion_flag(
          iv_production_order = lv_production_order ).
      IF <ls_deletion_order>-deletion_flag_result-production_order <>
          lv_production_order.
        <ls_deletion_order>-deletion_flag_result-production_order =
          lv_production_order.
        <ls_deletion_order>-deletion_flag_result-is_successful =
          abap_false.
        <ls_deletion_order>-deletion_flag_result-message-type = 'E'.
        <ls_deletion_order>-deletion_flag_result-message-message =
          'Deletion-flag API result did not match the requested order'.
      ENDIF.

      IF <ls_deletion_order>-deletion_flag_result-is_successful =
          abap_false.
        rs_result-is_successful = abap_false.
        mo_api->rollback( ).
        rs_result-is_rolled_back = abap_true.
        LOOP AT rs_result-orders ASSIGNING <ls_deletion_order>.
          <ls_deletion_order>-deletion_flag_result-is_successful =
            abap_false.
        ENDLOOP.
        RETURN.
      ENDIF.
    ENDLOOP.

    rs_result-commit_result = mo_api->commit( ).
    IF rs_result-commit_result-message-type = 'A'
        OR rs_result-commit_result-message-type = 'E'
        OR rs_result-commit_result-message-type = 'X'.
      rs_result-commit_result-is_successful = abap_false.
    ENDIF.
    IF rs_result-commit_result-is_successful = abap_false.
      rs_result-is_successful = abap_false.
      mo_api->rollback( ).
      rs_result-is_rolled_back = abap_true.
      LOOP AT rs_result-orders ASSIGNING <ls_deletion_order>.
        <ls_deletion_order>-deletion_flag_result-is_successful =
          abap_false.
      ENDLOOP.
      RETURN.
    ENDIF.

    rs_result-is_committed = abap_true.
    LOOP AT rs_result-orders ASSIGNING <ls_deletion_order>.
      <ls_deletion_order>-is_committed = abap_true.
    ENDLOOP.
  ENDMETHOD.

  METHOD set_deletion_flags_bulk.
    validate_order_numbers( it_production_orders = it_production_orders ).
    rs_result-is_successful = abap_true.

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index = lv_request_index
        is_attempted  = abap_true ) TO rs_result-orders.
      ASSIGN rs_result-orders[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_deletion_order>).

      <ls_deletion_order>-deletion_flag_result =
        mo_api->set_deletion_flag(
          iv_production_order = lv_production_order ).
      IF <ls_deletion_order>-deletion_flag_result-production_order <>
          lv_production_order.
        <ls_deletion_order>-deletion_flag_result-production_order =
          lv_production_order.
        <ls_deletion_order>-deletion_flag_result-is_successful =
          abap_false.
        <ls_deletion_order>-deletion_flag_result-message-type = 'E'.
        <ls_deletion_order>-deletion_flag_result-message-message =
          'Deletion-flag API result did not match the requested order'.
      ENDIF.

      IF <ls_deletion_order>-deletion_flag_result-is_successful =
          abap_false.
        mo_api->rollback( ).
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-failed_count.
        CONTINUE.
      ENDIF.

      <ls_deletion_order>-commit_result = mo_api->commit( ).
      IF <ls_deletion_order>-commit_result-message-type = 'A'
          OR <ls_deletion_order>-commit_result-message-type = 'E'
          OR <ls_deletion_order>-commit_result-message-type = 'X'.
        <ls_deletion_order>-commit_result-is_successful = abap_false.
      ENDIF.
      IF <ls_deletion_order>-commit_result-is_successful = abap_false.
        mo_api->rollback( ).
        <ls_deletion_order>-deletion_flag_result-is_successful = abap_false.
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-failed_count.
        CONTINUE.
      ENDIF.

      <ls_deletion_order>-is_committed = abap_true.
      ADD 1 TO rs_result-successful_count.
    ENDLOOP.
  ENDMETHOD.

  METHOD close_orders_atomic.
    validate_order_numbers( it_production_orders = it_production_orders ).
    rs_result-is_successful = abap_true.

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index = lv_request_index
        is_attempted  = abap_true ) TO rs_result-orders.
      ASSIGN rs_result-orders[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_close_order>).

      <ls_close_order>-close_result = mo_api->close_order(
        iv_production_order = lv_production_order ).
      IF <ls_close_order>-close_result-production_order <>
          lv_production_order.
        <ls_close_order>-close_result-production_order =
          lv_production_order.
        <ls_close_order>-close_result-is_successful = abap_false.
        <ls_close_order>-close_result-message-type = 'E'.
        <ls_close_order>-close_result-message-message =
          'Close API result did not match the requested order'.
      ENDIF.

      IF <ls_close_order>-close_result-is_successful = abap_false.
        rs_result-is_successful = abap_false.
        mo_api->rollback( ).
        rs_result-is_rolled_back = abap_true.
        LOOP AT rs_result-orders ASSIGNING <ls_close_order>.
          <ls_close_order>-close_result-is_successful = abap_false.
        ENDLOOP.
        RETURN.
      ENDIF.
    ENDLOOP.

    rs_result-commit_result = mo_api->commit( ).
    IF rs_result-commit_result-message-type = 'A'
        OR rs_result-commit_result-message-type = 'E'
        OR rs_result-commit_result-message-type = 'X'.
      rs_result-commit_result-is_successful = abap_false.
    ENDIF.
    IF rs_result-commit_result-is_successful = abap_false.
      rs_result-is_successful = abap_false.
      mo_api->rollback( ).
      rs_result-is_rolled_back = abap_true.
      LOOP AT rs_result-orders ASSIGNING <ls_close_order>.
        <ls_close_order>-close_result-is_successful = abap_false.
      ENDLOOP.
      RETURN.
    ENDIF.

    rs_result-is_committed = abap_true.
    LOOP AT rs_result-orders ASSIGNING <ls_close_order>.
      <ls_close_order>-is_committed = abap_true.
    ENDLOOP.
  ENDMETHOD.

  METHOD close_orders_bulk.
    validate_order_numbers( it_production_orders = it_production_orders ).
    rs_result-is_successful = abap_true.

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index = lv_request_index
        is_attempted  = abap_true ) TO rs_result-orders.
      ASSIGN rs_result-orders[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_close_order>).

      <ls_close_order>-close_result = mo_api->close_order(
        iv_production_order = lv_production_order ).
      IF <ls_close_order>-close_result-production_order <>
          lv_production_order.
        <ls_close_order>-close_result-production_order =
          lv_production_order.
        <ls_close_order>-close_result-is_successful = abap_false.
        <ls_close_order>-close_result-message-type = 'E'.
        <ls_close_order>-close_result-message-message =
          'Close API result did not match the requested order'.
      ENDIF.

      IF <ls_close_order>-close_result-is_successful = abap_false.
        mo_api->rollback( ).
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-failed_count.
        CONTINUE.
      ENDIF.

      <ls_close_order>-commit_result = mo_api->commit( ).
      IF <ls_close_order>-commit_result-message-type = 'A'
          OR <ls_close_order>-commit_result-message-type = 'E'
          OR <ls_close_order>-commit_result-message-type = 'X'.
        <ls_close_order>-commit_result-is_successful = abap_false.
      ENDIF.
      IF <ls_close_order>-commit_result-is_successful = abap_false.
        mo_api->rollback( ).
        <ls_close_order>-close_result-is_successful = abap_false.
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-failed_count.
        CONTINUE.
      ENDIF.

      <ls_close_order>-is_committed = abap_true.
      ADD 1 TO rs_result-closed_count.
    ENDLOOP.
  ENDMETHOD.

  METHOD set_deletion_indicators_atomic.
    validate_order_numbers( it_production_orders = it_production_orders ).
    rs_result-is_successful = abap_true.

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index = lv_request_index
        is_attempted  = abap_true ) TO rs_result-orders.
      ASSIGN rs_result-orders[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_indicator_order>).

      <ls_indicator_order>-deletion_indicator =
        mo_api->set_deletion_indicator(
          iv_production_order = lv_production_order ).
      IF <ls_indicator_order>-deletion_indicator-production_order <>
          lv_production_order.
        <ls_indicator_order>-deletion_indicator-production_order =
          lv_production_order.
        <ls_indicator_order>-deletion_indicator-is_successful =
          abap_false.
        <ls_indicator_order>-deletion_indicator-message-type = 'E'.
        <ls_indicator_order>-deletion_indicator-message-message =
          'Deletion-indicator API result did not match the requested order'.
      ENDIF.

      IF <ls_indicator_order>-deletion_indicator-is_successful =
          abap_false.
        rs_result-is_successful = abap_false.
        mo_api->rollback( ).
        rs_result-is_rolled_back = abap_true.
        LOOP AT rs_result-orders ASSIGNING <ls_indicator_order>.
          <ls_indicator_order>-deletion_indicator-is_successful =
            abap_false.
        ENDLOOP.
        RETURN.
      ENDIF.
    ENDLOOP.

    rs_result-commit_result = mo_api->commit( ).
    IF rs_result-commit_result-message-type = 'A'
        OR rs_result-commit_result-message-type = 'E'
        OR rs_result-commit_result-message-type = 'X'.
      rs_result-commit_result-is_successful = abap_false.
    ENDIF.
    IF rs_result-commit_result-is_successful = abap_false.
      rs_result-is_successful = abap_false.
      mo_api->rollback( ).
      rs_result-is_rolled_back = abap_true.
      LOOP AT rs_result-orders ASSIGNING <ls_indicator_order>.
        <ls_indicator_order>-deletion_indicator-is_successful =
          abap_false.
      ENDLOOP.
      RETURN.
    ENDIF.

    rs_result-is_committed = abap_true.
    LOOP AT rs_result-orders ASSIGNING <ls_indicator_order>.
      <ls_indicator_order>-is_committed = abap_true.
    ENDLOOP.
  ENDMETHOD.

  METHOD set_deletion_indicators_bulk.
    validate_order_numbers( it_production_orders = it_production_orders ).
    rs_result-is_successful = abap_true.

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index = lv_request_index
        is_attempted  = abap_true ) TO rs_result-orders.
      ASSIGN rs_result-orders[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_indicator_order>).

      <ls_indicator_order>-deletion_indicator =
        mo_api->set_deletion_indicator(
          iv_production_order = lv_production_order ).
      IF <ls_indicator_order>-deletion_indicator-production_order <>
          lv_production_order.
        <ls_indicator_order>-deletion_indicator-production_order =
          lv_production_order.
        <ls_indicator_order>-deletion_indicator-is_successful =
          abap_false.
        <ls_indicator_order>-deletion_indicator-message-type = 'E'.
        <ls_indicator_order>-deletion_indicator-message-message =
          'Deletion-indicator API result did not match the requested order'.
      ENDIF.

      IF <ls_indicator_order>-deletion_indicator-is_successful =
          abap_false.
        mo_api->rollback( ).
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-failed_count.
        CONTINUE.
      ENDIF.

      <ls_indicator_order>-commit_result = mo_api->commit( ).
      IF <ls_indicator_order>-commit_result-message-type = 'A'
          OR <ls_indicator_order>-commit_result-message-type = 'E'
          OR <ls_indicator_order>-commit_result-message-type = 'X'.
        <ls_indicator_order>-commit_result-is_successful = abap_false.
      ENDIF.
      IF <ls_indicator_order>-commit_result-is_successful = abap_false.
        mo_api->rollback( ).
        <ls_indicator_order>-deletion_indicator-is_successful =
          abap_false.
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-failed_count.
        CONTINUE.
      ENDIF.

      <ls_indicator_order>-is_committed = abap_true.
      ADD 1 TO rs_result-successful_count.
    ENDLOOP.
  ENDMETHOD.

  METHOD change_orders_atomic.
    validate_change_requests( it_requests = it_requests ).
    rs_result-is_successful = abap_true.

    LOOP AT it_requests INTO DATA(ls_request).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index = lv_request_index
        request       = ls_request
        is_attempted  = abap_true ) TO rs_result-orders.
      ASSIGN rs_result-orders[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_change_order>).

      <ls_change_order>-change_result = mo_api->change_order(
        is_request = ls_request ).
      IF <ls_change_order>-change_result-production_order <>
          ls_request-production_order.
        <ls_change_order>-change_result-production_order =
          ls_request-production_order.
        <ls_change_order>-change_result-is_successful = abap_false.
        <ls_change_order>-change_result-message-type = 'E'.
        <ls_change_order>-change_result-message-message =
          'Change API result did not match the requested order'.
      ENDIF.

      IF <ls_change_order>-change_result-is_successful = abap_false.
        rs_result-is_successful = abap_false.
        mo_api->rollback( ).
        rs_result-is_rolled_back = abap_true.
        LOOP AT rs_result-orders ASSIGNING <ls_change_order>.
          <ls_change_order>-change_result-is_successful = abap_false.
        ENDLOOP.
        RETURN.
      ENDIF.
    ENDLOOP.

    rs_result-commit_result = mo_api->commit( ).
    IF rs_result-commit_result-message-type = 'A'
        OR rs_result-commit_result-message-type = 'E'
        OR rs_result-commit_result-message-type = 'X'.
      rs_result-commit_result-is_successful = abap_false.
    ENDIF.
    IF rs_result-commit_result-is_successful = abap_false.
      rs_result-is_successful = abap_false.
      mo_api->rollback( ).
      rs_result-is_rolled_back = abap_true.
      LOOP AT rs_result-orders ASSIGNING <ls_change_order>.
        <ls_change_order>-change_result-is_successful = abap_false.
      ENDLOOP.
      RETURN.
    ENDIF.

    rs_result-is_committed = abap_true.
    LOOP AT rs_result-orders ASSIGNING <ls_change_order>.
      <ls_change_order>-is_committed = abap_true.
    ENDLOOP.
  ENDMETHOD.

  METHOD change_orders_bulk.
    validate_change_requests( it_requests = it_requests ).
    rs_result-is_successful = abap_true.

    LOOP AT it_requests INTO DATA(ls_request).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index = lv_request_index
        request       = ls_request
        is_attempted  = abap_true ) TO rs_result-orders.
      ASSIGN rs_result-orders[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_change_order>).

      <ls_change_order>-change_result = mo_api->change_order(
        is_request = ls_request ).
      IF <ls_change_order>-change_result-production_order <>
          ls_request-production_order.
        <ls_change_order>-change_result-production_order =
          ls_request-production_order.
        <ls_change_order>-change_result-is_successful = abap_false.
        <ls_change_order>-change_result-message-type = 'E'.
        <ls_change_order>-change_result-message-message =
          'Change API result did not match the requested order'.
      ENDIF.

      IF <ls_change_order>-change_result-is_successful = abap_false.
        mo_api->rollback( ).
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-failed_count.
        CONTINUE.
      ENDIF.

      <ls_change_order>-commit_result = mo_api->commit( ).
      IF <ls_change_order>-commit_result-message-type = 'A'
          OR <ls_change_order>-commit_result-message-type = 'E'
          OR <ls_change_order>-commit_result-message-type = 'X'.
        <ls_change_order>-commit_result-is_successful = abap_false.
      ENDIF.
      IF <ls_change_order>-commit_result-is_successful = abap_false.
        mo_api->rollback( ).
        <ls_change_order>-change_result-is_successful = abap_false.
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-failed_count.
        CONTINUE.
      ENDIF.

      <ls_change_order>-is_committed = abap_true.
      ADD 1 TO rs_result-changed_count.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_change_requests.
    TYPES ty_seen_order TYPE zif_prod_order_api=>ty_order_number.
    DATA lt_seen_orders TYPE HASHED TABLE OF ty_seen_order
      WITH UNIQUE KEY table_line.

    IF it_requests IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_production_order.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      INSERT ls_request-production_order INTO TABLE lt_seen_orders.
      IF ls_request-production_order IS INITIAL OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_production_order.
      ENDIF.

      IF ( ls_request-change_quantity <> abap_true
            AND ls_request-change_quantity <> abap_false )
          OR ( ls_request-change_start_date <> abap_true
            AND ls_request-change_start_date <> abap_false )
          OR ( ls_request-change_finish_date <> abap_true
            AND ls_request-change_finish_date <> abap_false ).
        RAISE EXCEPTION TYPE zcx_invalid_production_order.
      ENDIF.

      IF ls_request-change_quantity <> abap_true
          AND ls_request-change_start_date <> abap_true
          AND ls_request-change_finish_date <> abap_true.
        RAISE EXCEPTION TYPE zcx_invalid_production_order.
      ENDIF.

      IF ls_request-change_quantity = abap_true.
        IF ls_request-quantity <= 0 OR ls_request-quantity_uom IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_production_order.
        ENDIF.
      ELSEIF ls_request-quantity IS NOT INITIAL
          OR ls_request-quantity_uom IS NOT INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_production_order.
      ENDIF.

      IF ls_request-change_start_date = abap_true.
        IF ls_request-basic_start_date IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_production_order.
        ENDIF.
      ELSEIF ls_request-basic_start_date IS NOT INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_production_order.
      ENDIF.

      IF ls_request-change_finish_date = abap_true.
        IF ls_request-basic_finish_date IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_production_order.
        ENDIF.
      ELSEIF ls_request-basic_finish_date IS NOT INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_production_order.
      ENDIF.

      IF ls_request-change_start_date = abap_true
          AND ls_request-change_finish_date = abap_true
          AND ls_request-basic_start_date > ls_request-basic_finish_date.
        RAISE EXCEPTION TYPE zcx_invalid_production_order.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
