CLASS zcl_sales_order_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_sales_documents TYPE STANDARD TABLE OF
      zif_sales_order_api=>ty_sales_document WITH EMPTY KEY.
    TYPES ty_orders TYPE STANDARD TABLE OF
      zif_sales_order_api=>ty_order WITH EMPTY KEY.
    TYPES ty_order_read TYPE zif_sales_order_api=>ty_order_read.
    TYPES ty_order_reads TYPE zif_sales_order_api=>ty_order_reads.
    TYPES:
      BEGIN OF ty_order_change,
        sales_document TYPE zif_sales_order_api=>ty_sales_document,
        items          TYPE zif_sales_order_api=>ty_items,
      END OF ty_order_change.
    TYPES ty_order_changes TYPE STANDARD TABLE OF ty_order_change WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_order_rejection,
        sales_document  TYPE zif_sales_order_api=>ty_sales_document,
        item_rejections TYPE zif_sales_order_api=>ty_item_rejections,
      END OF ty_order_rejection.
    TYPES ty_order_rejections TYPE STANDARD TABLE OF
      ty_order_rejection WITH EMPTY KEY.
    TYPES ty_item_number TYPE c LENGTH 6.
    TYPES ty_item_numbers TYPE STANDARD TABLE OF
      ty_item_number WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_order_item_clear,
        sales_document TYPE zif_sales_order_api=>ty_sales_document,
        item_numbers   TYPE ty_item_numbers,
      END OF ty_order_item_clear.
    TYPES ty_order_item_clears TYPE STANDARD TABLE OF
      ty_order_item_clear WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_order_write_result,
        sales_document TYPE zif_sales_order_api=>ty_sales_document,
        write_result   TYPE zif_sales_order_api=>ty_write_result,
      END OF ty_order_write_result.
    TYPES ty_order_write_results TYPE STANDARD TABLE OF
      ty_order_write_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_atomic_write_result,
        order_results TYPE ty_order_write_results,
        commit_result TYPE zif_sales_order_api=>ty_commit_result,
        is_successful TYPE abap_bool,
        is_test_run   TYPE abap_bool,
        is_committed  TYPE abap_bool,
      END OF ty_atomic_write_result.
    TYPES:
      BEGIN OF ty_bulk_write_result,
        order_results TYPE ty_order_write_results,
        is_successful TYPE abap_bool,
        is_test_run   TYPE abap_bool,
      END OF ty_bulk_write_result.

    METHODS constructor
      IMPORTING
        io_api TYPE REF TO zif_sales_order_api.

    METHODS read_order
      IMPORTING
        iv_sales_document TYPE zif_sales_order_api=>ty_sales_document
      RETURNING
        VALUE(rs_result)  TYPE zif_sales_order_api=>ty_read_result
      RAISING
        zcx_invalid_sales_order.

    METHODS read_orders
      IMPORTING
        it_sales_documents TYPE ty_sales_documents
      RETURNING
        VALUE(rt_results)  TYPE ty_order_reads
      RAISING
        zcx_invalid_sales_order.

    METHODS create_order
      IMPORTING
        is_order         TYPE zif_sales_order_api=>ty_order
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE zif_sales_order_api=>ty_write_result
      RAISING
        zcx_invalid_sales_order.

    METHODS create_orders_atomic
      IMPORTING
        it_orders        TYPE ty_orders
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_atomic_write_result
      RAISING
        zcx_invalid_sales_order.

    METHODS create_orders_bulk
      IMPORTING
        it_orders        TYPE ty_orders
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_bulk_write_result
      RAISING
        zcx_invalid_sales_order.

    METHODS change_order
      IMPORTING
        iv_sales_document TYPE zif_sales_order_api=>ty_sales_document
        it_items          TYPE zif_sales_order_api=>ty_items
        iv_test_run       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)  TYPE zif_sales_order_api=>ty_write_result
      RAISING
        zcx_invalid_sales_order.

    METHODS change_orders_atomic
      IMPORTING
        it_changes       TYPE ty_order_changes
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_atomic_write_result
      RAISING
        zcx_invalid_sales_order.

    METHODS change_orders_bulk
      IMPORTING
        it_changes       TYPE ty_order_changes
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_bulk_write_result
      RAISING
        zcx_invalid_sales_order.

    METHODS reject_order_items
      IMPORTING
        iv_sales_document  TYPE zif_sales_order_api=>ty_sales_document
        it_item_rejections TYPE zif_sales_order_api=>ty_item_rejections
        iv_test_run        TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE zif_sales_order_api=>ty_write_result
      RAISING
        zcx_invalid_sales_order.

    METHODS reject_orders_atomic
      IMPORTING
        it_rejections    TYPE ty_order_rejections
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_atomic_write_result
      RAISING
        zcx_invalid_sales_order.

    METHODS reject_orders_bulk
      IMPORTING
        it_rejections    TYPE ty_order_rejections
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_bulk_write_result
      RAISING
        zcx_invalid_sales_order.

    METHODS clear_order_item_rejections
      IMPORTING
        iv_sales_document TYPE zif_sales_order_api=>ty_sales_document
        it_item_numbers   TYPE ty_item_numbers
        iv_test_run       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)  TYPE zif_sales_order_api=>ty_write_result
      RAISING
        zcx_invalid_sales_order.

    METHODS clear_order_rejections_atomic
      IMPORTING
        it_clears        TYPE ty_order_item_clears
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_atomic_write_result
      RAISING
        zcx_invalid_sales_order.

    METHODS clear_order_rejections_bulk
      IMPORTING
        it_clears        TYPE ty_order_item_clears
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_bulk_write_result
      RAISING
        zcx_invalid_sales_order.

  PRIVATE SECTION.
    METHODS complete_atomic_write
      IMPORTING
        is_result        TYPE ty_atomic_write_result
        iv_has_failure   TYPE abap_bool
        iv_test_run      TYPE abap_bool
        iv_is_create     TYPE abap_bool
      RETURNING
        VALUE(rs_result) TYPE ty_atomic_write_result.

    METHODS validate_items
      IMPORTING
        it_items TYPE zif_sales_order_api=>ty_items
      RAISING
        zcx_invalid_sales_order.

    METHODS validate_item_rejections
      IMPORTING
        it_item_rejections TYPE zif_sales_order_api=>ty_item_rejections
      RAISING
        zcx_invalid_sales_order.

    METHODS validate_item_numbers
      IMPORTING
        it_item_numbers TYPE ty_item_numbers
      RAISING
        zcx_invalid_sales_order.

    METHODS complete_write
      IMPORTING
        is_result        TYPE zif_sales_order_api=>ty_write_result
        iv_test_run      TYPE abap_bool
        iv_is_create     TYPE abap_bool
      RETURNING
        VALUE(rs_result) TYPE zif_sales_order_api=>ty_write_result.

    DATA mo_api TYPE REF TO zif_sales_order_api.
ENDCLASS.

CLASS zcl_sales_order_service IMPLEMENTATION.

  METHOD constructor.
    mo_api = io_api.
  ENDMETHOD.

  METHOD read_order.
    IF iv_sales_document IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_sales_order.
    ENDIF.

    rs_result = mo_api->read_order( iv_sales_document ).
  ENDMETHOD.

  METHOD read_orders.
    DATA lt_sales_documents TYPE HASHED TABLE OF
      zif_sales_order_api=>ty_sales_document
      WITH UNIQUE KEY table_line.

    IF it_sales_documents IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_sales_documents INTO DATA(lv_sales_document).
      IF lv_sales_document IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_sales_order.
      ENDIF.
      INSERT lv_sales_document INTO TABLE lt_sales_documents.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_sales_order.
      ENDIF.
    ENDLOOP.

    rt_results = mo_api->read_orders( it_sales_documents ).
  ENDMETHOD.

  METHOD create_order.
    IF is_order-order_type IS INITIAL
        OR is_order-sales_organization IS INITIAL
        OR is_order-distribution_channel IS INITIAL
        OR is_order-division IS INITIAL
        OR is_order-sold_to_party IS INITIAL
        OR is_order-document_date IS INITIAL
        OR is_order-items IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_sales_order.
    ENDIF.

    validate_items( it_items = is_order-items ).

    DATA(ls_write_result) = mo_api->create_order(
      is_order    = is_order
      iv_test_run = iv_test_run ).
    rs_result = complete_write(
      is_result    = ls_write_result
      iv_test_run  = iv_test_run
      iv_is_create = abap_true ).
  ENDMETHOD.

  METHOD create_orders_atomic.
    DATA lv_has_failure TYPE abap_bool.

    IF it_orders IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_sales_order.
    ENDIF.

    LOOP AT it_orders INTO DATA(ls_order).
      IF ls_order-order_type IS INITIAL
          OR ls_order-sales_organization IS INITIAL
          OR ls_order-distribution_channel IS INITIAL
          OR ls_order-division IS INITIAL
          OR ls_order-sold_to_party IS INITIAL
          OR ls_order-document_date IS INITIAL
          OR ls_order-items IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_sales_order.
      ENDIF.
      validate_items( it_items = ls_order-items ).
    ENDLOOP.

    rs_result-is_test_run = iv_test_run.
    LOOP AT it_orders INTO ls_order.
      DATA(ls_write_result) = mo_api->create_order(
        is_order    = ls_order
        iv_test_run = iv_test_run ).

      DATA(lv_order_failed) = xsdbool(
        ls_write_result-is_successful = abap_false ).
      DATA(lv_has_error_message) = abap_false.
      LOOP AT ls_write_result-messages INTO DATA(ls_message).
        IF ls_message-type = 'A'
            OR ls_message-type = 'E'
            OR ls_message-type = 'X'.
          lv_order_failed = abap_true.
          lv_has_error_message = abap_true.
        ENDIF.
      ENDLOOP.
      IF iv_test_run = abap_false
          AND ls_write_result-sales_document IS INITIAL.
        lv_order_failed = abap_true.
        APPEND VALUE #(
          type    = 'E'
          message = 'Sales order create returned no document number' )
          TO ls_write_result-messages.
        lv_has_error_message = abap_true.
      ENDIF.

      IF lv_order_failed = abap_true.
        IF lv_has_error_message = abap_false.
          APPEND VALUE #(
            type    = 'E'
            message = 'Sales order create failed without an error message' )
            TO ls_write_result-messages.
        ENDIF.
        ls_write_result-is_successful = abap_false.
        lv_has_failure = abap_true.
      ELSE.
        ls_write_result-is_successful = abap_true.
      ENDIF.

      APPEND VALUE #(
        sales_document = ls_write_result-sales_document
        write_result   = ls_write_result )
        TO rs_result-order_results.
    ENDLOOP.

    rs_result = complete_atomic_write(
      is_result      = rs_result
      iv_has_failure = lv_has_failure
      iv_test_run    = iv_test_run
      iv_is_create   = abap_true ).
  ENDMETHOD.

  METHOD create_orders_bulk.
    IF it_orders IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_sales_order.
    ENDIF.

    LOOP AT it_orders INTO DATA(ls_order).
      IF ls_order-order_type IS INITIAL
          OR ls_order-sales_organization IS INITIAL
          OR ls_order-distribution_channel IS INITIAL
          OR ls_order-division IS INITIAL
          OR ls_order-sold_to_party IS INITIAL
          OR ls_order-document_date IS INITIAL
          OR ls_order-items IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_sales_order.
      ENDIF.
      validate_items( it_items = ls_order-items ).
    ENDLOOP.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_orders INTO ls_order.
      DATA(ls_write_result) = create_order(
        is_order    = ls_order
        iv_test_run = iv_test_run ).
      APPEND VALUE #(
        sales_document = ls_write_result-sales_document
        write_result   = ls_write_result ) TO rs_result-order_results.
      IF ls_write_result-is_successful = abap_false.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD change_order.
    IF iv_sales_document IS INITIAL OR it_items IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_sales_order.
    ENDIF.

    validate_items( it_items = it_items ).

    DATA(ls_write_result) = mo_api->change_order(
      iv_sales_document = iv_sales_document
      it_items          = it_items
      iv_test_run       = iv_test_run ).
    rs_result = complete_write(
      is_result    = ls_write_result
      iv_test_run  = iv_test_run
      iv_is_create = abap_false ).
  ENDMETHOD.

  METHOD reject_order_items.
    IF iv_sales_document IS INITIAL OR it_item_rejections IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_sales_order.
    ENDIF.

    validate_item_rejections( it_item_rejections = it_item_rejections ).

    DATA(ls_write_result) = mo_api->reject_order_items(
      iv_sales_document  = iv_sales_document
      it_item_rejections = it_item_rejections
      iv_test_run        = iv_test_run ).
    rs_result = complete_write(
      is_result    = ls_write_result
      iv_test_run  = iv_test_run
      iv_is_create = abap_false ).
  ENDMETHOD.

  METHOD reject_orders_atomic.
    DATA lt_sales_documents TYPE HASHED TABLE OF
      zif_sales_order_api=>ty_sales_document
      WITH UNIQUE KEY table_line.
    DATA lv_has_failure TYPE abap_bool.

    IF it_rejections IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_sales_order.
    ENDIF.

    LOOP AT it_rejections INTO DATA(ls_rejection).
      IF ls_rejection-sales_document IS INITIAL
          OR ls_rejection-item_rejections IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_sales_order.
      ENDIF.
      INSERT ls_rejection-sales_document INTO TABLE lt_sales_documents.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_sales_order.
      ENDIF.
      validate_item_rejections(
        it_item_rejections = ls_rejection-item_rejections ).
    ENDLOOP.

    rs_result-is_test_run = iv_test_run.
    LOOP AT it_rejections INTO ls_rejection.
      DATA(ls_write_result) = mo_api->reject_order_items(
        iv_sales_document  = ls_rejection-sales_document
        it_item_rejections = ls_rejection-item_rejections
        iv_test_run        = iv_test_run ).
      IF ls_write_result-sales_document IS INITIAL.
        ls_write_result-sales_document = ls_rejection-sales_document.
      ENDIF.

      DATA(lv_order_failed) = xsdbool(
        ls_write_result-is_successful = abap_false ).
      DATA(lv_has_error_message) = abap_false.
      LOOP AT ls_write_result-messages INTO DATA(ls_message).
        IF ls_message-type = 'A'
            OR ls_message-type = 'E'
            OR ls_message-type = 'X'.
          lv_order_failed = abap_true.
          lv_has_error_message = abap_true.
        ENDIF.
      ENDLOOP.
      IF lv_order_failed = abap_true.
        IF lv_has_error_message = abap_false.
          APPEND VALUE #(
            type    = 'E'
            message = 'Sales order rejection update failed without an error message' )
            TO ls_write_result-messages.
        ENDIF.
        ls_write_result-is_successful = abap_false.
        lv_has_failure = abap_true.
      ELSE.
        ls_write_result-is_successful = abap_true.
      ENDIF.

      APPEND VALUE #(
        sales_document = ls_rejection-sales_document
        write_result   = ls_write_result )
        TO rs_result-order_results.
    ENDLOOP.

    rs_result = complete_atomic_write(
      is_result      = rs_result
      iv_has_failure = lv_has_failure
      iv_test_run    = iv_test_run
      iv_is_create   = abap_false ).
  ENDMETHOD.

  METHOD reject_orders_bulk.
    DATA lt_sales_documents TYPE HASHED TABLE OF
      zif_sales_order_api=>ty_sales_document
      WITH UNIQUE KEY table_line.

    IF it_rejections IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_sales_order.
    ENDIF.

    LOOP AT it_rejections INTO DATA(ls_rejection).
      IF ls_rejection-sales_document IS INITIAL
          OR ls_rejection-item_rejections IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_sales_order.
      ENDIF.
      INSERT ls_rejection-sales_document INTO TABLE lt_sales_documents.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_sales_order.
      ENDIF.
      validate_item_rejections(
        it_item_rejections = ls_rejection-item_rejections ).
    ENDLOOP.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_rejections INTO ls_rejection.
      DATA(ls_write_result) = reject_order_items(
        iv_sales_document  = ls_rejection-sales_document
        it_item_rejections = ls_rejection-item_rejections
        iv_test_run        = iv_test_run ).
      APPEND VALUE #(
        sales_document = ls_rejection-sales_document
        write_result   = ls_write_result ) TO rs_result-order_results.
      IF ls_write_result-is_successful = abap_false.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD clear_order_item_rejections.
    DATA lt_item_rejections TYPE zif_sales_order_api=>ty_item_rejections.

    IF iv_sales_document IS INITIAL
        OR it_item_numbers IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_sales_order.
    ENDIF.

    validate_item_numbers( it_item_numbers = it_item_numbers ).
    LOOP AT it_item_numbers INTO DATA(lv_item_number).
      APPEND VALUE #(
        item_number = lv_item_number ) TO lt_item_rejections.
    ENDLOOP.

    DATA(ls_write_result) = mo_api->reject_order_items(
      iv_sales_document  = iv_sales_document
      it_item_rejections = lt_item_rejections
      iv_test_run        = iv_test_run ).
    IF ls_write_result-sales_document IS INITIAL.
      ls_write_result-sales_document = iv_sales_document.
    ENDIF.
    rs_result = complete_write(
      is_result    = ls_write_result
      iv_test_run  = iv_test_run
      iv_is_create = abap_false ).
  ENDMETHOD.

  METHOD clear_order_rejections_atomic.
    DATA lt_sales_documents TYPE HASHED TABLE OF
      zif_sales_order_api=>ty_sales_document
      WITH UNIQUE KEY table_line.
    DATA lv_has_failure TYPE abap_bool.

    IF it_clears IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_sales_order.
    ENDIF.

    LOOP AT it_clears INTO DATA(ls_clear).
      IF ls_clear-sales_document IS INITIAL
          OR ls_clear-item_numbers IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_sales_order.
      ENDIF.
      INSERT ls_clear-sales_document INTO TABLE lt_sales_documents.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_sales_order.
      ENDIF.
      validate_item_numbers( it_item_numbers = ls_clear-item_numbers ).
    ENDLOOP.

    rs_result-is_test_run = iv_test_run.
    LOOP AT it_clears INTO ls_clear.
      DATA lt_item_rejections TYPE zif_sales_order_api=>ty_item_rejections.
      CLEAR lt_item_rejections.
      LOOP AT ls_clear-item_numbers INTO DATA(lv_item_number).
        APPEND VALUE #(
          item_number = lv_item_number ) TO lt_item_rejections.
      ENDLOOP.

      DATA(ls_write_result) = mo_api->reject_order_items(
        iv_sales_document  = ls_clear-sales_document
        it_item_rejections = lt_item_rejections
        iv_test_run        = iv_test_run ).
      IF ls_write_result-sales_document IS INITIAL.
        ls_write_result-sales_document = ls_clear-sales_document.
      ENDIF.

      DATA(lv_order_failed) = xsdbool(
        ls_write_result-is_successful = abap_false ).
      DATA(lv_has_error_message) = abap_false.
      LOOP AT ls_write_result-messages INTO DATA(ls_message).
        IF ls_message-type = 'A'
            OR ls_message-type = 'E'
            OR ls_message-type = 'X'.
          lv_order_failed = abap_true.
          lv_has_error_message = abap_true.
        ENDIF.
      ENDLOOP.
      IF lv_order_failed = abap_true.
        IF lv_has_error_message = abap_false.
          APPEND VALUE #(
            type    = 'E'
            message = 'Sales order rejection clear failed without an error message' )
            TO ls_write_result-messages.
        ENDIF.
        ls_write_result-is_successful = abap_false.
        lv_has_failure = abap_true.
      ELSE.
        ls_write_result-is_successful = abap_true.
      ENDIF.

      APPEND VALUE #(
        sales_document = ls_clear-sales_document
        write_result   = ls_write_result )
        TO rs_result-order_results.
    ENDLOOP.

    rs_result = complete_atomic_write(
      is_result      = rs_result
      iv_has_failure = lv_has_failure
      iv_test_run    = iv_test_run
      iv_is_create   = abap_false ).
  ENDMETHOD.

  METHOD clear_order_rejections_bulk.
    DATA lt_sales_documents TYPE HASHED TABLE OF
      zif_sales_order_api=>ty_sales_document
      WITH UNIQUE KEY table_line.

    IF it_clears IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_sales_order.
    ENDIF.

    LOOP AT it_clears INTO DATA(ls_clear).
      IF ls_clear-sales_document IS INITIAL
          OR ls_clear-item_numbers IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_sales_order.
      ENDIF.
      INSERT ls_clear-sales_document INTO TABLE lt_sales_documents.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_sales_order.
      ENDIF.
      validate_item_numbers( it_item_numbers = ls_clear-item_numbers ).
    ENDLOOP.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_clears INTO ls_clear.
      DATA(ls_write_result) = clear_order_item_rejections(
        iv_sales_document = ls_clear-sales_document
        it_item_numbers   = ls_clear-item_numbers
        iv_test_run       = iv_test_run ).
      APPEND VALUE #(
        sales_document = ls_clear-sales_document
        write_result   = ls_write_result ) TO rs_result-order_results.
      IF ls_write_result-is_successful = abap_false.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD change_orders_atomic.
    DATA lt_sales_documents TYPE HASHED TABLE OF
      zif_sales_order_api=>ty_sales_document
      WITH UNIQUE KEY table_line.
    DATA lv_has_failure TYPE abap_bool.

    IF it_changes IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_sales_order.
    ENDIF.

    LOOP AT it_changes INTO DATA(ls_change).
      IF ls_change-sales_document IS INITIAL OR ls_change-items IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_sales_order.
      ENDIF.
      INSERT ls_change-sales_document INTO TABLE lt_sales_documents.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_sales_order.
      ENDIF.
      validate_items( it_items = ls_change-items ).
    ENDLOOP.

    rs_result-is_test_run = iv_test_run.
    LOOP AT it_changes INTO ls_change.
      DATA(ls_write_result) = mo_api->change_order(
        iv_sales_document = ls_change-sales_document
        it_items          = ls_change-items
        iv_test_run       = iv_test_run ).
      IF ls_write_result-sales_document IS INITIAL.
        ls_write_result-sales_document = ls_change-sales_document.
      ENDIF.

      DATA(lv_order_failed) = xsdbool(
        ls_write_result-is_successful = abap_false ).
      DATA(lv_has_error_message) = abap_false.
      LOOP AT ls_write_result-messages INTO DATA(ls_message).
        IF ls_message-type = 'A'
            OR ls_message-type = 'E'
            OR ls_message-type = 'X'.
          lv_order_failed = abap_true.
          lv_has_error_message = abap_true.
        ENDIF.
      ENDLOOP.
      IF lv_order_failed = abap_true.
        IF lv_has_error_message = abap_false.
          APPEND VALUE #(
            type    = 'E'
            message = 'Sales order change failed without an error message' )
            TO ls_write_result-messages.
        ENDIF.
        ls_write_result-is_successful = abap_false.
        lv_has_failure = abap_true.
      ELSE.
        ls_write_result-is_successful = abap_true.
      ENDIF.

      APPEND VALUE #(
        sales_document = ls_change-sales_document
        write_result   = ls_write_result )
        TO rs_result-order_results.
    ENDLOOP.

    rs_result = complete_atomic_write(
      is_result      = rs_result
      iv_has_failure = lv_has_failure
      iv_test_run    = iv_test_run
      iv_is_create   = abap_false ).
  ENDMETHOD.

  METHOD change_orders_bulk.
    DATA lt_sales_documents TYPE HASHED TABLE OF
      zif_sales_order_api=>ty_sales_document
      WITH UNIQUE KEY table_line.

    IF it_changes IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_sales_order.
    ENDIF.

    LOOP AT it_changes INTO DATA(ls_change).
      IF ls_change-sales_document IS INITIAL OR ls_change-items IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_sales_order.
      ENDIF.
      INSERT ls_change-sales_document INTO TABLE lt_sales_documents.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_sales_order.
      ENDIF.
      validate_items( it_items = ls_change-items ).
    ENDLOOP.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_changes INTO ls_change.
      DATA(ls_write_result) = change_order(
        iv_sales_document = ls_change-sales_document
        it_items          = ls_change-items
        iv_test_run       = iv_test_run ).
      APPEND VALUE #(
        sales_document = ls_change-sales_document
        write_result   = ls_write_result ) TO rs_result-order_results.
      IF ls_write_result-is_successful = abap_false.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_items.
    DATA lv_item_index TYPE i.
    LOOP AT it_items INTO DATA(ls_item).
      lv_item_index = lv_item_index + 1.
      IF ls_item-item_number IS INITIAL
          OR ls_item-schedule_line IS INITIAL
          OR ls_item-material IS INITIAL
          OR ls_item-plant IS INITIAL
          OR ls_item-quantity <= 0
          OR ls_item-entry_unit IS INITIAL
          OR ls_item-requested_date IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_sales_order.
      ENDIF.

      LOOP AT it_items INTO DATA(ls_other_item).
        IF sy-tabix > lv_item_index
            AND ls_other_item-item_number = ls_item-item_number.
          RAISE EXCEPTION TYPE zcx_invalid_sales_order.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_item_rejections.
    DATA lv_item_index TYPE i.
    LOOP AT it_item_rejections INTO DATA(ls_rejection).
      lv_item_index = lv_item_index + 1.
      IF ls_rejection-item_number IS INITIAL
          OR ls_rejection-rejection_reason IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_sales_order.
      ENDIF.

      LOOP AT it_item_rejections INTO DATA(ls_other_rejection).
        IF sy-tabix > lv_item_index
            AND ls_other_rejection-item_number =
              ls_rejection-item_number.
          RAISE EXCEPTION TYPE zcx_invalid_sales_order.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_item_numbers.
    DATA lt_seen_item_numbers TYPE HASHED TABLE OF ty_item_number
      WITH UNIQUE KEY table_line.

    IF it_item_numbers IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_sales_order.
    ENDIF.

    LOOP AT it_item_numbers INTO DATA(lv_item_number).
      INSERT lv_item_number INTO TABLE lt_seen_item_numbers.
      IF lv_item_number IS INITIAL OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_sales_order.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD complete_write.
    rs_result = is_result.
    rs_result-is_test_run = iv_test_run.
    rs_result-is_committed = abap_false.
    DATA lv_has_error_message TYPE abap_bool.
    LOOP AT rs_result-messages INTO DATA(ls_message).
      IF ls_message-type = 'A'
          OR ls_message-type = 'E'
          OR ls_message-type = 'X'.
        lv_has_error_message = abap_true.
        mo_api->rollback( ).
        rs_result-is_successful = abap_false.
        IF iv_is_create = abap_true.
          CLEAR rs_result-sales_document.
        ENDIF.
        RETURN.
      ENDIF.
    ENDLOOP.

    IF rs_result-is_successful = abap_false.
      IF lv_has_error_message = abap_false.
        APPEND VALUE #(
          type    = 'E'
          message = 'Sales order write failed without an error message' )
          TO rs_result-messages.
      ENDIF.
      mo_api->rollback( ).
      IF iv_is_create = abap_true.
        CLEAR rs_result-sales_document.
      ENDIF.
      RETURN.
    ENDIF.

    IF iv_test_run = abap_true.
      rs_result-is_successful = abap_true.
      RETURN.
    ENDIF.

    IF rs_result-sales_document IS INITIAL.
      mo_api->rollback( ).
      APPEND VALUE #(
        type    = 'E'
        message = 'Sales order write returned no document number' )
        TO rs_result-messages.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    DATA(ls_commit_result) = mo_api->commit( ).
    DATA(lv_commit_failed) = xsdbool(
      ls_commit_result-is_successful = abap_false ).
    IF ls_commit_result-message-type = 'A'
        OR ls_commit_result-message-type = 'E'
        OR ls_commit_result-message-type = 'X'.
      lv_commit_failed = abap_true.
    ENDIF.
    IF lv_commit_failed = abap_true.
      mo_api->rollback( ).
      IF ls_commit_result-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
      ENDIF.
      rs_result-is_successful = abap_false.
      IF iv_is_create = abap_true.
        CLEAR rs_result-sales_document.
      ENDIF.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_committed = abap_true.
  ENDMETHOD.

  METHOD complete_atomic_write.
    rs_result = is_result.
    LOOP AT rs_result-order_results
        ASSIGNING FIELD-SYMBOL(<ls_order_result>).
      <ls_order_result>-write_result-is_test_run = iv_test_run.
      <ls_order_result>-write_result-is_committed = abap_false.
    ENDLOOP.

    IF iv_has_failure = abap_true.
      mo_api->rollback( ).
      LOOP AT rs_result-order_results ASSIGNING <ls_order_result>.
        <ls_order_result>-write_result-is_successful = abap_false.
        IF iv_is_create = abap_true.
          CLEAR:
            <ls_order_result>-sales_document,
            <ls_order_result>-write_result-sales_document.
        ENDIF.
      ENDLOOP.
      RETURN.
    ENDIF.

    IF iv_test_run = abap_true.
      rs_result-is_successful = abap_true.
      LOOP AT rs_result-order_results ASSIGNING <ls_order_result>.
        <ls_order_result>-write_result-is_successful = abap_true.
      ENDLOOP.
      RETURN.
    ENDIF.

    rs_result-commit_result = mo_api->commit( ).
    DATA(lv_commit_failed) = xsdbool(
      rs_result-commit_result-is_successful = abap_false ).
    IF rs_result-commit_result-message-type = 'A'
        OR rs_result-commit_result-message-type = 'E'
        OR rs_result-commit_result-message-type = 'X'.
      lv_commit_failed = abap_true.
    ENDIF.

    IF lv_commit_failed = abap_true.
      mo_api->rollback( ).
      LOOP AT rs_result-order_results ASSIGNING <ls_order_result>.
        <ls_order_result>-write_result-is_successful = abap_false.
        IF iv_is_create = abap_true.
          CLEAR:
            <ls_order_result>-sales_document,
            <ls_order_result>-write_result-sales_document.
        ENDIF.
      ENDLOOP.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_committed = abap_true.
    LOOP AT rs_result-order_results ASSIGNING <ls_order_result>.
      <ls_order_result>-write_result-is_successful = abap_true.
      <ls_order_result>-write_result-is_committed = abap_true.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
