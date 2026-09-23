CLASS zcl_sales_order_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
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

    METHODS create_order
      IMPORTING
        is_order         TYPE zif_sales_order_api=>ty_order
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE zif_sales_order_api=>ty_write_result
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

  PRIVATE SECTION.
    METHODS validate_items
      IMPORTING
        it_items TYPE zif_sales_order_api=>ty_items
      RAISING
        zcx_invalid_sales_order.

    METHODS complete_write
      IMPORTING
        is_result        TYPE zif_sales_order_api=>ty_write_result
        iv_test_run      TYPE abap_bool
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

  METHOD create_order.
    IF is_order-order_type IS INITIAL
        OR is_order-sales_organization IS INITIAL
        OR is_order-distribution_channel IS INITIAL
        OR is_order-division IS INITIAL
        OR is_order-sold_to_party IS INITIAL
        OR is_order-document_date IS INITIAL
        OR is_order-items IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_sales_order.
    ENDIF.

    validate_items( it_items = is_order-items ).

    DATA(ls_write_result) = mo_api->create_order(
      is_order    = is_order
      iv_test_run = iv_test_run ).
    rs_result = complete_write(
      is_result   = ls_write_result
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD change_order.
    IF iv_sales_document IS INITIAL OR it_items IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_sales_order.
    ENDIF.

    validate_items( it_items = it_items ).

    DATA(ls_write_result) = mo_api->change_order(
      iv_sales_document = iv_sales_document
      it_items          = it_items
      iv_test_run       = iv_test_run ).
    rs_result = complete_write(
      is_result   = ls_write_result
      iv_test_run = iv_test_run ).
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

  METHOD complete_write.
    rs_result = is_result.
    LOOP AT rs_result-messages INTO DATA(ls_message).
      IF ls_message-type = 'A'
          OR ls_message-type = 'E'
          OR ls_message-type = 'X'.
        mo_api->rollback( ).
        rs_result-is_successful = abap_false.
        RETURN.
      ENDIF.
    ENDLOOP.

    IF rs_result-is_successful = abap_false.
      mo_api->rollback( ).
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
    IF ls_commit_result-is_successful = abap_false.
      mo_api->rollback( ).
      IF ls_commit_result-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
      ENDIF.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
  ENDMETHOD.

ENDCLASS.
