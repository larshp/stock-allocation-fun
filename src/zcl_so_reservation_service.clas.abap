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
