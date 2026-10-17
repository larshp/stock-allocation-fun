CLASS zcl_planned_order_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_order_result,
        request_index           TYPE i,
        source_suggestion_index TYPE i,
        receipt_index           TYPE i,
        request                 TYPE zif_planned_order_api=>ty_request,
        planned_order           TYPE zif_planned_order_api=>ty_result,
        is_attempted            TYPE abap_bool,
        is_committed            TYPE abap_bool,
      END OF ty_order_result.
    TYPES ty_order_results TYPE STANDARD TABLE OF ty_order_result
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_order_plan_row,
        source_suggestion_index TYPE i,
        receipt_index           TYPE i,
        request                 TYPE zif_planned_order_api=>ty_request,
      END OF ty_order_plan_row.
    TYPES ty_order_plan TYPE STANDARD TABLE OF ty_order_plan_row
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_create_result,
        orders         TYPE ty_order_results,
        commit_result  TYPE zif_planned_order_api=>ty_commit_result,
        is_successful  TYPE abap_bool,
        is_committed   TYPE abap_bool,
        is_rolled_back TYPE abap_bool,
      END OF ty_create_result.
    TYPES:
      BEGIN OF ty_bulk_order_result,
        request_index           TYPE i,
        source_suggestion_index TYPE i,
        receipt_index           TYPE i,
        request                 TYPE zif_planned_order_api=>ty_request,
        planned_order           TYPE zif_planned_order_api=>ty_result,
        commit_result           TYPE zif_planned_order_api=>ty_commit_result,
        is_attempted            TYPE abap_bool,
        is_committed            TYPE abap_bool,
      END OF ty_bulk_order_result.
    TYPES ty_bulk_order_results TYPE STANDARD TABLE OF
      ty_bulk_order_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_create_result,
        orders           TYPE ty_bulk_order_results,
        successful_count TYPE i,
        failed_count     TYPE i,
        is_successful    TYPE abap_bool,
      END OF ty_bulk_create_result.
    TYPES:
      BEGIN OF ty_delete_order_result,
        request_index TYPE i,
        planned_order TYPE zif_planned_order_api=>ty_result,
        is_attempted  TYPE abap_bool,
        is_committed  TYPE abap_bool,
      END OF ty_delete_order_result.
    TYPES ty_delete_order_results TYPE STANDARD TABLE OF
      ty_delete_order_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_delete_result,
        orders         TYPE ty_delete_order_results,
        commit_result  TYPE zif_planned_order_api=>ty_commit_result,
        is_successful  TYPE abap_bool,
        is_committed   TYPE abap_bool,
        is_rolled_back TYPE abap_bool,
      END OF ty_delete_result.
    TYPES:
      BEGIN OF ty_bulk_delete_order_result,
        request_index TYPE i,
        planned_order TYPE zif_planned_order_api=>ty_result,
        commit_result TYPE zif_planned_order_api=>ty_commit_result,
        is_attempted  TYPE abap_bool,
        is_committed  TYPE abap_bool,
      END OF ty_bulk_delete_order_result.
    TYPES ty_bulk_delete_order_results TYPE STANDARD TABLE OF
      ty_bulk_delete_order_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_delete_result,
        orders           TYPE ty_bulk_delete_order_results,
        successful_count TYPE i,
        failed_count     TYPE i,
        is_successful    TYPE abap_bool,
      END OF ty_bulk_delete_result.
    TYPES:
      BEGIN OF ty_change_order_result,
        request_index TYPE i,
        request       TYPE zif_planned_order_api=>ty_change_request,
        planned_order TYPE zif_planned_order_api=>ty_result,
        commit_result TYPE zif_planned_order_api=>ty_commit_result,
        is_attempted  TYPE abap_bool,
        is_committed  TYPE abap_bool,
      END OF ty_change_order_result.
    TYPES ty_change_order_results TYPE STANDARD TABLE OF
      ty_change_order_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_change_result,
        orders         TYPE ty_change_order_results,
        commit_result  TYPE zif_planned_order_api=>ty_commit_result,
        is_successful  TYPE abap_bool,
        is_committed   TYPE abap_bool,
        is_rolled_back TYPE abap_bool,
      END OF ty_change_result.
    TYPES:
      BEGIN OF ty_bulk_change_result,
        orders           TYPE ty_change_order_results,
        successful_count TYPE i,
        failed_count     TYPE i,
        is_successful    TYPE abap_bool,
      END OF ty_bulk_change_result.
    TYPES:
      BEGIN OF ty_conversion_order_result,
        request_index     TYPE i,
        conversion_result TYPE zif_planned_order_api=>ty_conversion_result,
        is_attempted      TYPE abap_bool,
        is_committed      TYPE abap_bool,
      END OF ty_conversion_order_result.
    TYPES ty_conversion_order_results TYPE STANDARD TABLE OF
      ty_conversion_order_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_conversion_result,
        orders         TYPE ty_conversion_order_results,
        commit_result  TYPE zif_planned_order_api=>ty_commit_result,
        is_successful  TYPE abap_bool,
        is_committed   TYPE abap_bool,
        is_rolled_back TYPE abap_bool,
      END OF ty_conversion_result.
    TYPES:
      BEGIN OF ty_bulk_conversion_order_result,
        request_index     TYPE i,
        conversion_result TYPE zif_planned_order_api=>ty_conversion_result,
        commit_result     TYPE zif_planned_order_api=>ty_commit_result,
        is_attempted      TYPE abap_bool,
        is_committed      TYPE abap_bool,
      END OF ty_bulk_conversion_order_result.
    TYPES ty_bulk_conversion_order_results TYPE STANDARD TABLE OF
      ty_bulk_conversion_order_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_conversion_result,
        orders           TYPE ty_bulk_conversion_order_results,
        successful_count TYPE i,
        failed_count     TYPE i,
        is_successful    TYPE abap_bool,
      END OF ty_bulk_conversion_result.

    METHODS constructor
      IMPORTING
        io_api TYPE REF TO zif_planned_order_api.

    METHODS create_orders_atomic
      IMPORTING
        it_requests      TYPE zif_planned_order_api=>ty_requests
      RETURNING
        VALUE(rs_result) TYPE ty_create_result
      RAISING
        zcx_invalid_stock_request.

    METHODS create_orders_bulk
      IMPORTING
        it_requests      TYPE zif_planned_order_api=>ty_requests
      RETURNING
        VALUE(rs_result) TYPE ty_bulk_create_result
      RAISING
        zcx_invalid_stock_request.

    METHODS create_from_suggestions
      IMPORTING
        it_suggestions   TYPE zcl_prod_comp_service=>ty_comp_replenishments
      RETURNING
        VALUE(rs_result) TYPE ty_create_result
      RAISING
        zcx_invalid_stock_request.

    METHODS create_from_suggestions_bulk
      IMPORTING
        it_suggestions   TYPE zcl_prod_comp_service=>ty_comp_replenishments
      RETURNING
        VALUE(rs_result) TYPE ty_bulk_create_result
      RAISING
        zcx_invalid_stock_request.

    METHODS prepare_from_suggestions
      IMPORTING
        it_suggestions TYPE zcl_prod_comp_service=>ty_comp_replenishments
      RETURNING
        VALUE(rt_plan) TYPE ty_order_plan
      RAISING
        zcx_invalid_stock_request.

    METHODS delete_orders_atomic
      IMPORTING
        it_planned_orders TYPE zif_planned_order_api=>ty_order_numbers
      RETURNING
        VALUE(rs_result)  TYPE ty_delete_result
      RAISING
        zcx_invalid_stock_request.

    METHODS delete_orders_bulk
      IMPORTING
        it_planned_orders TYPE zif_planned_order_api=>ty_order_numbers
      RETURNING
        VALUE(rs_result)  TYPE ty_bulk_delete_result
      RAISING
        zcx_invalid_stock_request.

    METHODS change_orders_atomic
      IMPORTING
        it_requests      TYPE zif_planned_order_api=>ty_change_requests
      RETURNING
        VALUE(rs_result) TYPE ty_change_result
      RAISING
        zcx_invalid_stock_request.

    METHODS change_orders_bulk
      IMPORTING
        it_requests      TYPE zif_planned_order_api=>ty_change_requests
      RETURNING
        VALUE(rs_result) TYPE ty_bulk_change_result
      RAISING
        zcx_invalid_stock_request.

    METHODS convert_planned_orders_atomic
      IMPORTING
        it_planned_orders TYPE zif_planned_order_api=>ty_order_numbers
      RETURNING
        VALUE(rs_result)  TYPE ty_conversion_result
      RAISING
        zcx_invalid_stock_request.

    METHODS convert_planned_orders_bulk
      IMPORTING
        it_planned_orders TYPE zif_planned_order_api=>ty_order_numbers
      RETURNING
        VALUE(rs_result)  TYPE ty_bulk_conversion_result
      RAISING
        zcx_invalid_stock_request.

  PRIVATE SECTION.
    METHODS validate_requests
      IMPORTING
        it_requests TYPE zif_planned_order_api=>ty_requests
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_delete_requests
      IMPORTING
        it_planned_orders TYPE zif_planned_order_api=>ty_order_numbers
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_change_requests
      IMPORTING
        it_requests TYPE zif_planned_order_api=>ty_change_requests
      RAISING
        zcx_invalid_stock_request.

    DATA mo_api TYPE REF TO zif_planned_order_api.
ENDCLASS.

CLASS zcl_planned_order_service IMPLEMENTATION.

  METHOD constructor.
    mo_api = io_api.
  ENDMETHOD.

  METHOD validate_requests.
    IF it_requests IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-quantity <= 0
          OR ls_request-planned_end_date IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_delete_requests.
    TYPES ty_seen_order TYPE zif_planned_order_api=>ty_order_number.
    DATA lt_seen_orders TYPE HASHED TABLE OF ty_seen_order
      WITH UNIQUE KEY table_line.

    IF it_planned_orders IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_planned_orders INTO DATA(lv_planned_order).
      INSERT lv_planned_order INTO TABLE lt_seen_orders.
      IF lv_planned_order IS INITIAL OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_change_requests.
    TYPES ty_seen_order TYPE zif_planned_order_api=>ty_order_number.
    DATA lt_seen_orders TYPE HASHED TABLE OF ty_seen_order
      WITH UNIQUE KEY table_line.

    IF it_requests IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      INSERT ls_request-planned_order INTO TABLE lt_seen_orders.
      IF ls_request-planned_order IS INITIAL
          OR sy-subrc <> 0
          OR ( ls_request-change_quantity <> abap_true
            AND ls_request-change_quantity <> abap_false )
          OR ( ls_request-change_start_date <> abap_true
            AND ls_request-change_start_date <> abap_false )
          OR ( ls_request-change_end_date <> abap_true
            AND ls_request-change_end_date <> abap_false )
          OR ( ls_request-change_fixed_indicator <> abap_true
            AND ls_request-change_fixed_indicator <> abap_false )
          OR ( ls_request-change_quantity = abap_false
            AND ls_request-quantity IS NOT INITIAL )
          OR ( ls_request-change_start_date = abap_false
            AND ls_request-planned_start_date IS NOT INITIAL )
          OR ( ls_request-change_end_date = abap_false
            AND ls_request-planned_end_date IS NOT INITIAL )
          OR ( ls_request-change_fixed_indicator = abap_false
            AND ls_request-fixed_indicator IS NOT INITIAL )
          OR ( ls_request-change_fixed_indicator = abap_true
            AND ls_request-fixed_indicator <> abap_true
            AND ls_request-fixed_indicator <> abap_false )
          OR ( ls_request-change_quantity = abap_true
            AND ls_request-quantity <= 0 )
          OR ( ls_request-change_start_date = abap_true
            AND ls_request-planned_start_date IS INITIAL )
          OR ( ls_request-change_end_date = abap_true
            AND ls_request-planned_end_date IS INITIAL )
          OR ( ls_request-change_quantity = abap_false
            AND ls_request-change_start_date = abap_false
            AND ls_request-change_end_date = abap_false
            AND ls_request-change_fixed_indicator = abap_false ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD create_orders_atomic.
    validate_requests( it_requests = it_requests ).
    rs_result-is_successful = abap_true.

    LOOP AT it_requests INTO DATA(ls_request).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index = lv_request_index
        request       = ls_request ) TO rs_result-orders.
      ASSIGN rs_result-orders[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_order_result>).
      <ls_order_result>-is_attempted = abap_true.
      <ls_order_result>-planned_order = mo_api->create_order(
        is_request = ls_request ).

      IF <ls_order_result>-planned_order-is_successful = abap_false
          OR <ls_order_result>-planned_order-planned_order IS INITIAL.
        rs_result-is_successful = abap_false.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF rs_result-is_successful = abap_false.
      mo_api->rollback( ).
      rs_result-is_rolled_back = abap_true.
      LOOP AT rs_result-orders ASSIGNING <ls_order_result>.
        CLEAR <ls_order_result>-planned_order-planned_order.
        <ls_order_result>-planned_order-is_successful = abap_false.
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
        CLEAR <ls_order_result>-planned_order-planned_order.
        <ls_order_result>-planned_order-is_successful = abap_false.
      ENDLOOP.
      RETURN.
    ENDIF.

    rs_result-is_committed = abap_true.
    LOOP AT rs_result-orders ASSIGNING <ls_order_result>.
      <ls_order_result>-is_committed = abap_true.
    ENDLOOP.
  ENDMETHOD.

  METHOD create_orders_bulk.
    validate_requests( it_requests = it_requests ).
    rs_result-is_successful = abap_true.

    LOOP AT it_requests INTO DATA(ls_request).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index = lv_request_index
        request       = ls_request
        is_attempted  = abap_true ) TO rs_result-orders.
      ASSIGN rs_result-orders[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_order_result>).

      <ls_order_result>-planned_order = mo_api->create_order(
        is_request = ls_request ).
      IF <ls_order_result>-planned_order-is_successful = abap_false
          OR <ls_order_result>-planned_order-planned_order IS INITIAL.
        mo_api->rollback( ).
        CLEAR <ls_order_result>-planned_order-planned_order.
        <ls_order_result>-planned_order-is_successful = abap_false.
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-failed_count.
        CONTINUE.
      ENDIF.

      <ls_order_result>-commit_result = mo_api->commit( ).
      IF <ls_order_result>-commit_result-message-type = 'A'
          OR <ls_order_result>-commit_result-message-type = 'E'
          OR <ls_order_result>-commit_result-message-type = 'X'.
        <ls_order_result>-commit_result-is_successful = abap_false.
      ENDIF.
      IF <ls_order_result>-commit_result-is_successful = abap_false
          OR <ls_order_result>-commit_result-message-type = 'A'
          OR <ls_order_result>-commit_result-message-type = 'E'
          OR <ls_order_result>-commit_result-message-type = 'X'.
        mo_api->rollback( ).
        CLEAR <ls_order_result>-planned_order-planned_order.
        <ls_order_result>-planned_order-is_successful = abap_false.
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-failed_count.
        CONTINUE.
      ENDIF.

      <ls_order_result>-planned_order-is_successful = abap_true.
      <ls_order_result>-is_committed = abap_true.
      ADD 1 TO rs_result-successful_count.
    ENDLOOP.
  ENDMETHOD.

  METHOD create_from_suggestions.
    DATA lt_requests TYPE zif_planned_order_api=>ty_requests.

    DATA(lt_plan) = prepare_from_suggestions(
      it_suggestions = it_suggestions ).
    LOOP AT lt_plan INTO DATA(ls_plan_row).
      APPEND ls_plan_row-request TO lt_requests.
    ENDLOOP.

    IF lt_requests IS INITIAL.
      rs_result-is_successful = abap_true.
      RETURN.
    ENDIF.

    rs_result = create_orders_atomic( it_requests = lt_requests ).
    LOOP AT rs_result-orders ASSIGNING FIELD-SYMBOL(<ls_order_result>).
      READ TABLE lt_plan INDEX <ls_order_result>-request_index
        INTO ls_plan_row.
      IF sy-subrc = 0.
        <ls_order_result>-source_suggestion_index =
          ls_plan_row-source_suggestion_index.
        <ls_order_result>-receipt_index = ls_plan_row-receipt_index.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD create_from_suggestions_bulk.
    DATA lt_requests TYPE zif_planned_order_api=>ty_requests.

    DATA(lt_plan) = prepare_from_suggestions(
      it_suggestions = it_suggestions ).
    LOOP AT lt_plan INTO DATA(ls_plan_row).
      APPEND ls_plan_row-request TO lt_requests.
    ENDLOOP.

    IF lt_requests IS INITIAL.
      rs_result-is_successful = abap_true.
      RETURN.
    ENDIF.

    rs_result = create_orders_bulk( it_requests = lt_requests ).
    LOOP AT rs_result-orders ASSIGNING FIELD-SYMBOL(<ls_order_result>).
      READ TABLE lt_plan INDEX <ls_order_result>-request_index
        INTO ls_plan_row.
      IF sy-subrc = 0.
        <ls_order_result>-source_suggestion_index =
          ls_plan_row-source_suggestion_index.
        <ls_order_result>-receipt_index = ls_plan_row-receipt_index.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD prepare_from_suggestions.
    DATA lv_suggestion_index TYPE i.
    DATA lv_receipt_count TYPE i.
    DATA lv_receipt_quantity TYPE mard-labst.

    LOOP AT it_suggestions INTO DATA(ls_suggestion).
      lv_suggestion_index = sy-tabix.
      IF ls_suggestion-material IS INITIAL
          OR ls_suggestion-plant IS INITIAL
          OR ls_suggestion-base_unit IS INITIAL
          OR ls_suggestion-required_date IS INITIAL
          OR ls_suggestion-suggested_base_quantity < 0
          OR ls_suggestion-suggested_receipt_count < 0
          OR ls_suggestion-final_receipt_base_quantity < 0
          OR ls_suggestion-fixed_base_quantity < 0
          OR ls_suggestion-maximum_base_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      IF ls_suggestion-suggested_base_quantity = 0.
        IF ls_suggestion-suggested_receipt_count <> 0
            OR ls_suggestion-final_receipt_base_quantity <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        CONTINUE.
      ENDIF.

      IF ls_suggestion-procurement_type <> 'E'
          OR ls_suggestion-special_procurement_key IS NOT INITIAL
          OR ls_suggestion-suggested_receipt_count <= 0
          OR ls_suggestion-suggested_receipt_count > 9999
          OR ls_suggestion-final_receipt_base_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      lv_receipt_count = CONV i(
        ls_suggestion-suggested_receipt_count ).
      IF lv_receipt_count = 1.
        IF ls_suggestion-final_receipt_base_quantity
            <> ls_suggestion-suggested_base_quantity.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        lv_receipt_quantity =
          ls_suggestion-final_receipt_base_quantity.
      ELSEIF ls_suggestion-fixed_base_quantity > 0.
        IF ls_suggestion-rounding_profile IS INITIAL.
          IF ls_suggestion-final_receipt_base_quantity
                <> ls_suggestion-fixed_base_quantity
              OR ls_suggestion-suggested_base_quantity
                <> ls_suggestion-fixed_base_quantity * lv_receipt_count.
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
          ENDIF.
        ELSEIF ls_suggestion-suggested_base_quantity
              <> ls_suggestion-final_receipt_base_quantity
                * lv_receipt_count.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        lv_receipt_quantity =
          ls_suggestion-final_receipt_base_quantity.
      ELSEIF ls_suggestion-maximum_base_quantity > 0.
        IF ls_suggestion-final_receipt_base_quantity
              > ls_suggestion-maximum_base_quantity
            OR ls_suggestion-suggested_base_quantity
              <> ls_suggestion-maximum_base_quantity
                * ( lv_receipt_count - 1 )
                + ls_suggestion-final_receipt_base_quantity.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        lv_receipt_quantity = ls_suggestion-maximum_base_quantity.
      ELSE.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      DO lv_receipt_count TIMES.
        IF sy-index = lv_receipt_count.
          lv_receipt_quantity =
            ls_suggestion-final_receipt_base_quantity.
        ENDIF.
        APPEND VALUE #(
          source_suggestion_index = lv_suggestion_index
          receipt_index           = sy-index
          request                 = VALUE #(
            material         = ls_suggestion-material
            plant            = ls_suggestion-plant
            quantity         = lv_receipt_quantity
            planned_end_date = ls_suggestion-required_date ) )
          TO rt_plan.
      ENDDO.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete_orders_atomic.
    validate_delete_requests( it_planned_orders = it_planned_orders ).
    rs_result-is_successful = abap_true.

    LOOP AT it_planned_orders INTO DATA(lv_planned_order).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index = lv_request_index ) TO rs_result-orders.
      ASSIGN rs_result-orders[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_delete_result>).
      <ls_delete_result>-is_attempted = abap_true.
      <ls_delete_result>-planned_order = mo_api->delete_order(
        iv_planned_order = lv_planned_order ).

      IF <ls_delete_result>-planned_order-is_successful = abap_false.
        rs_result-is_successful = abap_false.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF rs_result-is_successful = abap_false.
      mo_api->rollback( ).
      rs_result-is_rolled_back = abap_true.
      LOOP AT rs_result-orders ASSIGNING <ls_delete_result>.
        <ls_delete_result>-planned_order-is_successful = abap_false.
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
      LOOP AT rs_result-orders ASSIGNING <ls_delete_result>.
        <ls_delete_result>-planned_order-is_successful = abap_false.
      ENDLOOP.
      RETURN.
    ENDIF.

    rs_result-is_committed = abap_true.
    LOOP AT rs_result-orders ASSIGNING <ls_delete_result>.
      <ls_delete_result>-is_committed = abap_true.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete_orders_bulk.
    validate_delete_requests( it_planned_orders = it_planned_orders ).
    rs_result-is_successful = abap_true.

    LOOP AT it_planned_orders INTO DATA(lv_planned_order).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index = lv_request_index
        is_attempted  = abap_true ) TO rs_result-orders.
      ASSIGN rs_result-orders[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_delete_result>).

      <ls_delete_result>-planned_order = mo_api->delete_order(
        iv_planned_order = lv_planned_order ).
      IF <ls_delete_result>-planned_order-is_successful = abap_false.
        mo_api->rollback( ).
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-failed_count.
        CONTINUE.
      ENDIF.

      <ls_delete_result>-commit_result = mo_api->commit( ).
      IF <ls_delete_result>-commit_result-message-type = 'A'
          OR <ls_delete_result>-commit_result-message-type = 'E'
          OR <ls_delete_result>-commit_result-message-type = 'X'.
        <ls_delete_result>-commit_result-is_successful = abap_false.
      ENDIF.
      IF <ls_delete_result>-commit_result-is_successful = abap_false
          OR <ls_delete_result>-commit_result-message-type = 'A'
          OR <ls_delete_result>-commit_result-message-type = 'E'
          OR <ls_delete_result>-commit_result-message-type = 'X'.
        mo_api->rollback( ).
        <ls_delete_result>-planned_order-is_successful = abap_false.
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-failed_count.
        CONTINUE.
      ENDIF.

      <ls_delete_result>-is_committed = abap_true.
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
        TO FIELD-SYMBOL(<ls_change_result>).
      <ls_change_result>-planned_order = mo_api->change_order(
        is_request = ls_request ).

      IF <ls_change_result>-planned_order-is_successful = abap_false.
        rs_result-is_successful = abap_false.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF rs_result-is_successful = abap_false.
      mo_api->rollback( ).
      rs_result-is_rolled_back = abap_true.
      LOOP AT rs_result-orders ASSIGNING <ls_change_result>.
        <ls_change_result>-planned_order-is_successful = abap_false.
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
      LOOP AT rs_result-orders ASSIGNING <ls_change_result>.
        <ls_change_result>-planned_order-is_successful = abap_false.
      ENDLOOP.
      RETURN.
    ENDIF.

    rs_result-is_committed = abap_true.
    LOOP AT rs_result-orders ASSIGNING <ls_change_result>.
      <ls_change_result>-is_committed = abap_true.
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
        TO FIELD-SYMBOL(<ls_change_result>).

      <ls_change_result>-planned_order = mo_api->change_order(
        is_request = ls_request ).
      IF <ls_change_result>-planned_order-is_successful = abap_false.
        mo_api->rollback( ).
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-failed_count.
        CONTINUE.
      ENDIF.

      <ls_change_result>-commit_result = mo_api->commit( ).
      IF <ls_change_result>-commit_result-message-type = 'A'
          OR <ls_change_result>-commit_result-message-type = 'E'
          OR <ls_change_result>-commit_result-message-type = 'X'.
        <ls_change_result>-commit_result-is_successful = abap_false.
      ENDIF.
      IF <ls_change_result>-commit_result-is_successful = abap_false.
        mo_api->rollback( ).
        <ls_change_result>-planned_order-is_successful = abap_false.
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-failed_count.
        CONTINUE.
      ENDIF.

      <ls_change_result>-is_committed = abap_true.
      ADD 1 TO rs_result-successful_count.
    ENDLOOP.
  ENDMETHOD.

  METHOD convert_planned_orders_atomic.
    validate_delete_requests( it_planned_orders = it_planned_orders ).
    rs_result-is_successful = abap_true.

    LOOP AT it_planned_orders INTO DATA(lv_planned_order).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index = lv_request_index
        is_attempted  = abap_true ) TO rs_result-orders.
      ASSIGN rs_result-orders[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_conversion_order>).

      <ls_conversion_order>-conversion_result = mo_api->convert_order(
        iv_planned_order = lv_planned_order ).
      IF <ls_conversion_order>-conversion_result-is_successful = abap_false.
        rs_result-is_successful = abap_false.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF rs_result-is_successful = abap_false.
      mo_api->rollback( ).
      rs_result-is_rolled_back = abap_true.
      LOOP AT rs_result-orders ASSIGNING <ls_conversion_order>.
        <ls_conversion_order>-conversion_result-is_successful = abap_false.
        CLEAR <ls_conversion_order>-conversion_result-production_order.
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
      LOOP AT rs_result-orders ASSIGNING <ls_conversion_order>.
        <ls_conversion_order>-conversion_result-is_successful = abap_false.
        CLEAR <ls_conversion_order>-conversion_result-production_order.
      ENDLOOP.
      RETURN.
    ENDIF.

    rs_result-is_committed = abap_true.
    LOOP AT rs_result-orders ASSIGNING <ls_conversion_order>.
      <ls_conversion_order>-is_committed = abap_true.
    ENDLOOP.
  ENDMETHOD.

  METHOD convert_planned_orders_bulk.
    validate_delete_requests( it_planned_orders = it_planned_orders ).
    rs_result-is_successful = abap_true.

    LOOP AT it_planned_orders INTO DATA(lv_planned_order).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index = lv_request_index
        is_attempted  = abap_true ) TO rs_result-orders.
      ASSIGN rs_result-orders[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_conversion_order>).

      <ls_conversion_order>-conversion_result = mo_api->convert_order(
        iv_planned_order = lv_planned_order ).
      IF <ls_conversion_order>-conversion_result-is_successful = abap_false.
        mo_api->rollback( ).
        CLEAR <ls_conversion_order>-conversion_result-production_order.
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-failed_count.
        CONTINUE.
      ENDIF.

      <ls_conversion_order>-commit_result = mo_api->commit( ).
      IF <ls_conversion_order>-commit_result-message-type = 'A'
          OR <ls_conversion_order>-commit_result-message-type = 'E'
          OR <ls_conversion_order>-commit_result-message-type = 'X'.
        <ls_conversion_order>-commit_result-is_successful = abap_false.
      ENDIF.
      IF <ls_conversion_order>-commit_result-is_successful = abap_false.
        mo_api->rollback( ).
        <ls_conversion_order>-conversion_result-is_successful = abap_false.
        CLEAR <ls_conversion_order>-conversion_result-production_order.
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-failed_count.
        CONTINUE.
      ENDIF.

      <ls_conversion_order>-is_committed = abap_true.
      ADD 1 TO rs_result-successful_count.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
