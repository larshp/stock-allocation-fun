CLASS zcl_so_reservation_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_order_delete_result,
        sales_document      TYPE resb-kdauf,
        item_number         TYPE resb-kdpos,
        reservation_numbers TYPE zif_so_reservation_api=>ty_reservation_numbers,
        messages            TYPE zif_so_reservation_api=>ty_messages,
        is_successful       TYPE abap_bool,
      END OF ty_order_delete_result.
    TYPES:
      BEGIN OF ty_order_release_scope,
        sales_document      TYPE resb-kdauf,
        item_number         TYPE resb-kdpos,
        reservation_numbers TYPE zif_so_reservation_api=>ty_reservation_numbers,
      END OF ty_order_release_scope.
    TYPES ty_order_release_scopes TYPE STANDARD TABLE OF ty_order_release_scope
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_order_delete_result,
        scopes              TYPE ty_order_release_scopes,
        reservation_numbers TYPE zif_so_reservation_api=>ty_reservation_numbers,
        messages            TYPE zif_so_reservation_api=>ty_messages,
        is_successful       TYPE abap_bool,
      END OF ty_bulk_order_delete_result.

    METHODS constructor
      IMPORTING
        io_api                TYPE REF TO zif_so_reservation_api OPTIONAL
        io_reservation_finder TYPE REF TO zif_so_reservation_finder OPTIONAL.

    METHODS delete_reservations
      IMPORTING
        it_reservation_numbers TYPE zif_so_reservation_api=>ty_reservation_numbers
        iv_test_run            TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)       TYPE zif_so_reservation_api=>ty_delete_result
      RAISING
        zcx_invalid_reservation.

    METHODS delete_order_reservations
      IMPORTING
        iv_sales_document TYPE resb-kdauf
        iv_item_number    TYPE resb-kdpos OPTIONAL
        iv_test_run       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)  TYPE ty_order_delete_result
      RAISING
        zcx_invalid_reservation.

    METHODS delete_orders_reservations
      IMPORTING
        it_sales_documents TYPE zif_so_reservation_finder=>ty_sales_documents
        iv_test_run        TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_order_delete_result
      RAISING
        zcx_invalid_reservation.

    METHODS preview_orders_release
      IMPORTING
        it_sales_documents TYPE zif_so_reservation_finder=>ty_sales_documents
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_order_delete_result
      RAISING
        zcx_invalid_reservation.

    METHODS delete_items_reservations
      IMPORTING
        it_sales_order_items TYPE zif_so_reservation_finder=>ty_sales_order_items
        iv_test_run          TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)     TYPE ty_bulk_order_delete_result
      RAISING
        zcx_invalid_reservation.

    METHODS preview_order_items_release
      IMPORTING
        it_sales_order_items TYPE zif_so_reservation_finder=>ty_sales_order_items
      RETURNING
        VALUE(rs_result)     TYPE ty_bulk_order_delete_result
      RAISING
        zcx_invalid_reservation.

    METHODS preview_order_release
      IMPORTING
        iv_sales_document TYPE resb-kdauf
        iv_item_number    TYPE resb-kdpos OPTIONAL
      RETURNING
        VALUE(rs_result)  TYPE ty_order_delete_result
      RAISING
        zcx_invalid_reservation.

  PRIVATE SECTION.
    DATA mo_api                TYPE REF TO zif_so_reservation_api.
    DATA mo_reservation_finder TYPE REF TO zif_so_reservation_finder.
ENDCLASS.

CLASS zcl_so_reservation_service IMPLEMENTATION.

  METHOD constructor.
    IF io_api IS BOUND.
      mo_api = io_api.
    ELSE.
      mo_api = NEW zcl_bapi_so_reservation_api( ).
    ENDIF.

    IF io_reservation_finder IS BOUND.
      mo_reservation_finder = io_reservation_finder.
    ELSE.
      mo_reservation_finder = NEW zcl_mard_stock_repository( ).
    ENDIF.
  ENDMETHOD.

  METHOD delete_order_reservations.
    rs_result = preview_order_release(
      iv_sales_document = iv_sales_document
      iv_item_number    = iv_item_number ).

    IF rs_result-reservation_numbers IS INITIAL.
      RETURN.
    ENDIF.

    DATA(ls_delete_result) = delete_reservations(
      it_reservation_numbers = rs_result-reservation_numbers
      iv_test_run            = iv_test_run ).
    rs_result-messages = ls_delete_result-messages.
    rs_result-is_successful = ls_delete_result-is_successful.
  ENDMETHOD.

  METHOD delete_orders_reservations.
    rs_result = preview_orders_release(
      it_sales_documents = it_sales_documents ).

    IF rs_result-reservation_numbers IS INITIAL.
      RETURN.
    ENDIF.

    DATA(ls_delete_result) = delete_reservations(
      it_reservation_numbers = rs_result-reservation_numbers
      iv_test_run            = iv_test_run ).
    rs_result-messages = ls_delete_result-messages.
    rs_result-is_successful = ls_delete_result-is_successful.
  ENDMETHOD.

  METHOD preview_orders_release.
    TYPES:
      BEGIN OF ty_reservation_owner,
        reservation_number TYPE bapi2093_res_key-reserv_no,
        sales_document     TYPE resb-kdauf,
      END OF ty_reservation_owner.
    DATA lt_seen_documents TYPE HASHED TABLE OF resb-kdauf
      WITH UNIQUE KEY table_line.
    DATA lt_reservations TYPE zif_so_reservation_finder=>ty_order_reservations.
    DATA lt_reservation_owners TYPE HASHED TABLE OF ty_reservation_owner
      WITH UNIQUE KEY reservation_number.

    IF it_sales_documents IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    LOOP AT it_sales_documents INTO DATA(lv_sales_document).
      IF lv_sales_document IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      INSERT lv_sales_document INTO TABLE lt_seen_documents.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      APPEND VALUE #( sales_document = lv_sales_document )
        TO rs_result-scopes.
    ENDLOOP.

    lt_reservations = mo_reservation_finder->get_open_reservations_bulk(
      it_sales_documents = it_sales_documents ).

    LOOP AT lt_reservations INTO DATA(ls_reservation).
      IF ls_reservation-sales_document IS INITIAL
          OR ls_reservation-reservation_number IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.

      READ TABLE lt_seen_documents WITH TABLE KEY
        table_line = ls_reservation-sales_document
        TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.

      READ TABLE lt_reservation_owners INTO DATA(ls_existing_owner)
        WITH TABLE KEY reservation_number = ls_reservation-reservation_number.
      IF sy-subrc = 0.
        IF ls_existing_owner-sales_document <> ls_reservation-sales_document.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
        CONTINUE.
      ENDIF.

      INSERT VALUE #(
        reservation_number = ls_reservation-reservation_number
        sales_document     = ls_reservation-sales_document )
        INTO TABLE lt_reservation_owners.
      READ TABLE rs_result-scopes ASSIGNING FIELD-SYMBOL(<scope>)
        WITH KEY sales_document = ls_reservation-sales_document.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      APPEND ls_reservation-reservation_number
        TO <scope>-reservation_numbers.
    ENDLOOP.

    LOOP AT lt_reservation_owners INTO DATA(ls_owner).
      APPEND ls_owner-reservation_number TO rs_result-reservation_numbers.
    ENDLOOP.
    SORT rs_result-reservation_numbers.
    rs_result-is_successful = abap_true.
  ENDMETHOD.

  METHOD delete_items_reservations.
    rs_result = preview_order_items_release(
      it_sales_order_items = it_sales_order_items ).

    IF rs_result-reservation_numbers IS INITIAL.
      RETURN.
    ENDIF.

    DATA(ls_delete_result) = delete_reservations(
      it_reservation_numbers = rs_result-reservation_numbers
      iv_test_run            = iv_test_run ).
    rs_result-messages = ls_delete_result-messages.
    rs_result-is_successful = ls_delete_result-is_successful.
  ENDMETHOD.

  METHOD preview_order_items_release.
    TYPES:
      BEGIN OF ty_reservation_owner,
        reservation_number TYPE bapi2093_res_key-reserv_no,
        sales_document     TYPE resb-kdauf,
        item_number        TYPE resb-kdpos,
      END OF ty_reservation_owner.
    DATA lt_seen_scopes TYPE HASHED TABLE OF
      zif_so_reservation_finder=>ty_sales_order_item
      WITH UNIQUE KEY sales_document item_number.
    DATA lt_reservations TYPE zif_so_reservation_finder=>ty_item_reservations.
    DATA lt_reservation_owners TYPE HASHED TABLE OF ty_reservation_owner
      WITH UNIQUE KEY reservation_number.

    IF it_sales_order_items IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    LOOP AT it_sales_order_items INTO DATA(ls_requested_scope).
      IF ls_requested_scope-sales_document IS INITIAL
          OR ls_requested_scope-item_number IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      INSERT ls_requested_scope INTO TABLE lt_seen_scopes.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      APPEND VALUE #(
        sales_document = ls_requested_scope-sales_document
        item_number    = ls_requested_scope-item_number )
        TO rs_result-scopes.
    ENDLOOP.

    lt_reservations = mo_reservation_finder->get_open_item_reservations(
      it_sales_order_items = it_sales_order_items ).

    LOOP AT lt_reservations INTO DATA(ls_reservation).
      IF ls_reservation-sales_document IS INITIAL
          OR ls_reservation-item_number IS INITIAL
          OR ls_reservation-reservation_number IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.

      READ TABLE lt_seen_scopes WITH TABLE KEY
        sales_document = ls_reservation-sales_document
        item_number    = ls_reservation-item_number
        TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.

      READ TABLE lt_reservation_owners INTO DATA(ls_existing_owner)
        WITH TABLE KEY reservation_number = ls_reservation-reservation_number.
      IF sy-subrc = 0.
        IF ls_existing_owner-sales_document <> ls_reservation-sales_document
            OR ls_existing_owner-item_number <> ls_reservation-item_number.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
        CONTINUE.
      ENDIF.

      INSERT VALUE #(
        reservation_number = ls_reservation-reservation_number
        sales_document     = ls_reservation-sales_document
        item_number        = ls_reservation-item_number )
        INTO TABLE lt_reservation_owners.
      READ TABLE rs_result-scopes ASSIGNING FIELD-SYMBOL(<scope>)
        WITH KEY sales_document = ls_reservation-sales_document
                 item_number    = ls_reservation-item_number.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      APPEND ls_reservation-reservation_number
        TO <scope>-reservation_numbers.
    ENDLOOP.

    LOOP AT lt_reservation_owners INTO DATA(ls_owner).
      APPEND ls_owner-reservation_number TO rs_result-reservation_numbers.
    ENDLOOP.
    SORT rs_result-reservation_numbers.
    rs_result-is_successful = abap_true.
  ENDMETHOD.

  METHOD preview_order_release.
    IF iv_sales_document IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    rs_result-sales_document = iv_sales_document.
    rs_result-item_number = iv_item_number.
    rs_result-reservation_numbers =
      mo_reservation_finder->get_open_reservation_numbers(
        iv_sales_document = iv_sales_document
        iv_item_number    = iv_item_number ).
    rs_result-is_successful = abap_true.
  ENDMETHOD.

  METHOD delete_reservations.
    IF it_reservation_numbers IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    DATA lt_seen TYPE HASHED TABLE OF bapi2093_res_key-reserv_no
      WITH UNIQUE KEY table_line.
    LOOP AT it_reservation_numbers INTO DATA(lv_reservation_number).
      IF lv_reservation_number IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.

      INSERT lv_reservation_number INTO TABLE lt_seen.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
    ENDLOOP.

    rs_result = mo_api->delete_reservations(
      it_reservation_numbers = it_reservation_numbers
      iv_test_run            = iv_test_run ).

    LOOP AT rs_result-messages INTO DATA(ls_message).
      IF ls_message-type = 'A'
          OR ls_message-type = 'E'
          OR ls_message-type = 'X'.
        rs_result-is_successful = abap_false.
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

    DATA(ls_commit_result) = mo_api->commit( ).
    IF ls_commit_result-is_successful = abap_false.
      mo_api->rollback( ).
      IF ls_commit_result-message-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
      ENDIF.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
  ENDMETHOD.

ENDCLASS.
