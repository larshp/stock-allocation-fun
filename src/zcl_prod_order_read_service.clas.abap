CLASS zcl_prod_order_read_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_status_result,
        status_code       TYPE zif_prod_order_read_repo=>ty_order_status-status_code,
        is_user_status    TYPE abap_bool,
        status_short_name TYPE zif_prod_order_read_repo=>ty_order_status-status_short_name,
        status_name       TYPE zif_prod_order_read_repo=>ty_order_status-status_name,
      END OF ty_status_result.
    TYPES ty_status_results TYPE STANDARD TABLE OF ty_status_result
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_item_result,
        order_item             TYPE
          zif_prod_order_read_repo=>ty_order_item,
        order_quantity_base    TYPE decfloat34,
        received_quantity_base TYPE decfloat34,
        open_quantity_base     TYPE decfloat34,
        is_quantity_converted  TYPE abap_bool,
      END OF ty_item_result.
    TYPES ty_item_results TYPE STANDARD TABLE OF ty_item_result
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_order_result,
        request_index    TYPE i,
        production_order TYPE
          zif_prod_order_read_repo=>ty_order_number,
        items            TYPE ty_item_results,
        statuses         TYPE ty_status_results,
        is_found         TYPE abap_bool,
      END OF ty_order_result.
    TYPES ty_order_results TYPE STANDARD TABLE OF ty_order_result
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_read_result,
        orders                  TYPE ty_order_results,
        found_count             TYPE i,
        not_found_count         TYPE i,
        conversion_failed_count TYPE i,
        is_successful           TYPE abap_bool,
      END OF ty_bulk_read_result.
    TYPES:
      BEGIN OF ty_confirmation_order_result,
        request_index    TYPE i,
        production_order TYPE
          zif_prod_order_read_repo=>ty_order_number,
        confirmations    TYPE
          zif_prod_order_read_repo=>ty_order_confirmations,
        is_found         TYPE abap_bool,
      END OF ty_confirmation_order_result.
    TYPES ty_confirmation_order_results TYPE STANDARD TABLE OF
      ty_confirmation_order_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_operation_order_result,
        request_index    TYPE i,
        production_order TYPE
          zif_prod_order_read_repo=>ty_order_number,
        operations       TYPE
          zif_prod_order_read_repo=>ty_order_operations,
        is_found         TYPE abap_bool,
      END OF ty_operation_order_result.
    TYPES ty_operation_order_results TYPE STANDARD TABLE OF
      ty_operation_order_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_confirmation_read_result,
        orders        TYPE ty_confirmation_order_results,
        found_count   TYPE i,
        empty_count   TYPE i,
        is_successful TYPE abap_bool,
      END OF ty_bulk_confirmation_read_result.
    TYPES:
      BEGIN OF ty_bulk_operation_read_result,
        orders        TYPE ty_operation_order_results,
        found_count   TYPE i,
        empty_count   TYPE i,
        is_successful TYPE abap_bool,
      END OF ty_bulk_operation_read_result.

    METHODS constructor
      IMPORTING
        io_repository TYPE REF TO zif_prod_order_read_repo.

    METHODS read_orders_bulk
      IMPORTING
        it_production_orders TYPE
          zif_prod_order_read_repo=>ty_order_numbers
      RETURNING
        VALUE(rs_result)     TYPE ty_bulk_read_result
      RAISING
        zcx_invalid_stock_request.

    METHODS read_confirmations_bulk
      IMPORTING
        it_production_orders TYPE
          zif_prod_order_read_repo=>ty_order_numbers
      RETURNING
        VALUE(rs_result)     TYPE ty_bulk_confirmation_read_result
      RAISING
        zcx_invalid_stock_request.

    METHODS read_operations_bulk
      IMPORTING
        it_production_orders TYPE
          zif_prod_order_read_repo=>ty_order_numbers
      RETURNING
        VALUE(rs_result)     TYPE ty_bulk_operation_read_result
      RAISING
        zcx_invalid_stock_request.

  PRIVATE SECTION.
    METHODS validate_order_numbers
      IMPORTING
        it_production_orders TYPE
          zif_prod_order_read_repo=>ty_order_numbers
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_confirmation_results
      IMPORTING
        it_production_orders TYPE
          zif_prod_order_read_repo=>ty_order_numbers
        it_confirmations     TYPE
          zif_prod_order_read_repo=>ty_order_confirmations
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_operation_results
      IMPORTING
        it_production_orders TYPE
          zif_prod_order_read_repo=>ty_order_numbers
        it_operations        TYPE
          zif_prod_order_read_repo=>ty_order_operations
      RAISING
        zcx_invalid_stock_request.

    DATA mo_repository TYPE REF TO zif_prod_order_read_repo.
ENDCLASS.

CLASS zcl_prod_order_read_service IMPLEMENTATION.

  METHOD constructor.
    mo_repository = io_repository.
  ENDMETHOD.

  METHOD validate_order_numbers.
    TYPES ty_seen_order TYPE zif_prod_order_read_repo=>ty_order_number.
    DATA lt_seen_orders TYPE HASHED TABLE OF ty_seen_order
      WITH UNIQUE KEY table_line.

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      INSERT lv_production_order INTO TABLE lt_seen_orders.
      IF lv_production_order IS INITIAL OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_confirmation_results.
    TYPES:
      BEGIN OF ty_confirmation_key,
        confirmation         TYPE
          zif_prod_order_read_repo=>ty_order_confirmation-confirmation,
        confirmation_counter TYPE
          zif_prod_order_read_repo=>ty_order_confirmation-confirmation_counter,
      END OF ty_confirmation_key.
    TYPES ty_confirmation_keys TYPE HASHED TABLE OF ty_confirmation_key
      WITH UNIQUE KEY confirmation confirmation_counter.
    DATA lt_requested_orders TYPE HASHED TABLE OF
      zif_prod_order_read_repo=>ty_order_number WITH UNIQUE KEY table_line.
    DATA lt_confirmation_keys TYPE ty_confirmation_keys.

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      INSERT lv_production_order INTO TABLE lt_requested_orders.
    ENDLOOP.

    LOOP AT it_confirmations INTO DATA(ls_confirmation).
      READ TABLE lt_requested_orders
        WITH TABLE KEY table_line = ls_confirmation-production_order
        TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0
          OR ls_confirmation-confirmation IS INITIAL
          OR ls_confirmation-confirmation_counter IS INITIAL
          OR ls_confirmation-production_order IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      INSERT VALUE #(
        confirmation         = ls_confirmation-confirmation
        confirmation_counter = ls_confirmation-confirmation_counter )
        INTO TABLE lt_confirmation_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD read_orders_bulk.
    DATA(lo_quantity_calculator) = NEW zcl_prod_order_qty_calc( ).
    rs_result-is_successful = abap_true.

    IF it_production_orders IS INITIAL.
      RETURN.
    ENDIF.

    validate_order_numbers( it_production_orders = it_production_orders ).
    DATA(lt_order_items) = mo_repository->read_orders(
      it_production_orders = it_production_orders ).
    DATA(lt_order_statuses) = mo_repository->read_order_statuses(
      it_production_orders = it_production_orders ).

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index    = lv_request_index
        production_order = lv_production_order ) TO rs_result-orders.
      ASSIGN rs_result-orders[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_order_result>).

      LOOP AT lt_order_items INTO DATA(ls_order_item)
          WHERE production_order = lv_production_order.
        DATA(ls_item_result) = VALUE ty_item_result(
          order_item = ls_order_item ).
        APPEND ls_item_result TO <ls_order_result>-items.
        ASSIGN <ls_order_result>-items[ lines(
          <ls_order_result>-items ) ] TO FIELD-SYMBOL(<ls_item_result>).

        IF <ls_order_result>-is_found <> abap_true.
          <ls_order_result>-is_found = abap_true.
          ADD 1 TO rs_result-found_count.
        ENDIF.

        IF ls_order_item-order_unit IS INITIAL
            OR ls_order_item-base_unit IS INITIAL
            OR ls_order_item-order_quantity < 0
            OR ls_order_item-received_quantity < 0
            OR ls_order_item-order_to_base_numerator <= 0
            OR ls_order_item-order_to_base_denominator <= 0.
          rs_result-is_successful = abap_false.
          ADD 1 TO rs_result-conversion_failed_count.
          CONTINUE.
        ENDIF.

        <ls_item_result>-order_quantity_base =
          lo_quantity_calculator->calculate_base_quantity(
            iv_quantity            = ls_order_item-order_quantity
            iv_order_to_base_num   =
              ls_order_item-order_to_base_numerator
            iv_order_to_base_denom =
              ls_order_item-order_to_base_denominator ).
        <ls_item_result>-received_quantity_base =
          lo_quantity_calculator->calculate_base_quantity(
            iv_quantity            = ls_order_item-received_quantity
            iv_order_to_base_num   =
              ls_order_item-order_to_base_numerator
            iv_order_to_base_denom =
              ls_order_item-order_to_base_denominator ).
        <ls_item_result>-open_quantity_base =
          lo_quantity_calculator->calculate_open_base_quantity(
            iv_order_quantity      = ls_order_item-order_quantity
            iv_received_quantity   = ls_order_item-received_quantity
            iv_order_to_base_num   =
              ls_order_item-order_to_base_numerator
            iv_order_to_base_denom =
              ls_order_item-order_to_base_denominator ).
        <ls_item_result>-is_quantity_converted = abap_true.
      ENDLOOP.

      LOOP AT lt_order_statuses INTO DATA(ls_order_status)
          WHERE production_order = lv_production_order.
        APPEND VALUE #(
          status_code       = ls_order_status-status_code
          is_user_status    = ls_order_status-is_user_status
          status_short_name = ls_order_status-status_short_name
          status_name       = ls_order_status-status_name )
          TO <ls_order_result>-statuses.
      ENDLOOP.

      IF <ls_order_result>-is_found <> abap_true.
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-not_found_count.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD read_confirmations_bulk.
    rs_result-is_successful = abap_true.
    IF it_production_orders IS INITIAL.
      RETURN.
    ENDIF.

    validate_order_numbers(
      it_production_orders = it_production_orders ).
    DATA(lt_confirmations) = mo_repository->read_confirmations(
      it_production_orders = it_production_orders ).
    validate_confirmation_results(
      it_production_orders = it_production_orders
      it_confirmations     = lt_confirmations ).

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index    = lv_request_index
        production_order = lv_production_order ) TO rs_result-orders.
      ASSIGN rs_result-orders[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_confirmation_order>).

      LOOP AT lt_confirmations INTO DATA(ls_confirmation)
          WHERE production_order = lv_production_order.
        APPEND ls_confirmation TO <ls_confirmation_order>-confirmations.
      ENDLOOP.

      IF <ls_confirmation_order>-confirmations IS INITIAL.
        ADD 1 TO rs_result-empty_count.
      ELSE.
        <ls_confirmation_order>-is_found = abap_true.
        ADD 1 TO rs_result-found_count.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_operation_results.
    TYPES:
      BEGIN OF ty_operation_key,
        production_order  TYPE
          zif_prod_order_read_repo=>ty_order_operation-production_order,
        operation_counter TYPE
          zif_prod_order_read_repo=>ty_order_operation-operation_counter,
      END OF ty_operation_key.
    TYPES ty_operation_keys TYPE HASHED TABLE OF ty_operation_key
      WITH UNIQUE KEY production_order operation_counter.
    DATA lt_requested_orders TYPE HASHED TABLE OF
      zif_prod_order_read_repo=>ty_order_number WITH UNIQUE KEY table_line.
    DATA lt_operation_keys TYPE ty_operation_keys.

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      INSERT lv_production_order INTO TABLE lt_requested_orders.
    ENDLOOP.

    LOOP AT it_operations INTO DATA(ls_operation).
      READ TABLE lt_requested_orders
        WITH TABLE KEY table_line = ls_operation-production_order
        TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0
          OR ls_operation-production_order IS INITIAL
          OR ls_operation-operation_counter IS INITIAL
          OR ls_operation-operation_number IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      INSERT VALUE #(
        production_order  = ls_operation-production_order
        operation_counter = ls_operation-operation_counter )
        INTO TABLE lt_operation_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD read_operations_bulk.
    rs_result-is_successful = abap_true.
    IF it_production_orders IS INITIAL.
      RETURN.
    ENDIF.

    validate_order_numbers(
      it_production_orders = it_production_orders ).
    DATA(lt_operations) = mo_repository->read_operations(
      it_production_orders = it_production_orders ).
    validate_operation_results(
      it_production_orders = it_production_orders
      it_operations        = lt_operations ).

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index    = lv_request_index
        production_order = lv_production_order ) TO rs_result-orders.
      ASSIGN rs_result-orders[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_operation_order>).

      LOOP AT lt_operations INTO DATA(ls_operation)
          WHERE production_order = lv_production_order.
        APPEND ls_operation TO <ls_operation_order>-operations.
      ENDLOOP.

      IF <ls_operation_order>-operations IS INITIAL.
        ADD 1 TO rs_result-empty_count.
      ELSE.
        <ls_operation_order>-is_found = abap_true.
        ADD 1 TO rs_result-found_count.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
