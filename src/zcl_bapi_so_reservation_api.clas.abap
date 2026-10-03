CLASS zcl_bapi_so_reservation_api DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_so_reservation_api.
    INTERFACES zif_so_reservation_reader.
ENDCLASS.

CLASS zcl_bapi_so_reservation_api IMPLEMENTATION.

  METHOD zif_so_reservation_reader~read_reservation.
    DATA ls_header TYPE bapi2093_res_head_detail.
    DATA ls_item TYPE bapi2093_res_item_detail.
    DATA lt_items TYPE STANDARD TABLE OF bapi2093_res_item_detail
      WITH DEFAULT KEY.
    DATA ls_return TYPE bapiret2.
    DATA lt_return TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.

    rs_result-is_successful = abap_true.

    CALL FUNCTION 'BAPI_RESERVATION_GETDETAIL1'
      EXPORTING
        reservation        = iv_reservation_number
      IMPORTING
        reservation_header = ls_header
      TABLES
        reservation_items  = lt_items
        return             = lt_return.

    LOOP AT lt_return INTO ls_return.
      APPEND VALUE #(
        type    = ls_return-type
        message = ls_return-message ) TO rs_result-messages.
      IF ls_return-type = 'A'
          OR ls_return-type = 'E'
          OR ls_return-type = 'X'.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_items INTO ls_item.
      APPEND VALUE #(
        reservation_number = ls_item-res_no
        item_number        = ls_item-res_item
        record_type        = ls_item-res_type
        status             = ls_item-res_status
        is_deleted         = ls_item-delete_ind
        movement_allowed   = ls_item-movement
        is_final_issue     = ls_item-withdrawn
        material           = ls_item-material
        plant              = ls_item-plant
        storage_location   = ls_item-store_loc
        batch              = ls_item-batch
        requirement_date   = ls_item-req_date
        required_quantity  = ls_item-req_quan
        base_unit          = ls_item-base_uom
        base_unit_iso      = ls_item-base_uom_iso
        withdrawn_quantity = ls_item-withd_quan
        entry_quantity     = ls_item-quantity
        entry_unit         = ls_item-entry_uom )
        TO rs_result-items.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_so_reservation_api~create_reservations.
    DATA ls_header TYPE bapi2093_res_head.
    DATA ls_item TYPE bapi2093_res_item.
    DATA lt_items TYPE STANDARD TABLE OF bapi2093_res_item
      WITH DEFAULT KEY.
    DATA ls_atp_check TYPE bapi2093_atpcheck.
    DATA ls_return TYPE bapiret2.
    DATA lt_return TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.
    DATA lv_reservation TYPE bapi2093_res_key-reserv_no.
    DATA lv_test_run TYPE c LENGTH 1.
    DATA lv_required_date TYPE d.

    rs_result-is_successful = abap_true.
    ls_atp_check-atpcheck = abap_true.
    IF iv_test_run = abap_true.
      lv_test_run = abap_true.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      CLEAR: ls_header, ls_item, lt_items, lt_return, lv_reservation.
      ls_header-res_date = sy-datum.
      ls_header-move_type = '231'.
      ls_header-sales_ord = ls_request-sales_document.
      ls_header-s_ord_item = ls_request-item_number.

      ls_item-material = ls_request-material.
      ls_item-plant = ls_request-plant.
      ls_item-stge_loc = ls_request-storage_location.
      ls_item-batch = ls_request-batch.
      ls_item-entry_qnt = ls_request-quantity.
      ls_item-entry_uom = ls_request-unit.
      IF ls_request-required_date IS INITIAL.
        lv_required_date = sy-datum.
      ELSE.
        lv_required_date = ls_request-required_date.
      ENDIF.
      ls_item-req_date = lv_required_date.
      ls_item-movement = abap_true.
      APPEND ls_item TO lt_items.

      CALL FUNCTION 'BAPI_RESERVATION_CREATE1'
        EXPORTING
          reservationheader = ls_header
          testrun           = lv_test_run
          atpcheck          = ls_atp_check
        IMPORTING
          reservation       = lv_reservation
        TABLES
          reservationitems  = lt_items
          return            = lt_return.

      LOOP AT lt_return INTO ls_return.
        APPEND VALUE #(
          type    = ls_return-type
          message = ls_return-message ) TO rs_result-messages.
        IF ls_return-type = 'A'
            OR ls_return-type = 'E'
            OR ls_return-type = 'X'.
          rs_result-is_successful = abap_false.
        ENDIF.
      ENDLOOP.

      IF rs_result-is_successful = abap_false.
        EXIT.
      ENDIF.

      APPEND VALUE #(
        request_id         = ls_request-request_id
        reservation_number = lv_reservation
        storage_location   = ls_request-storage_location
        batch              = ls_request-batch
        required_date      = lv_required_date
        quantity           = ls_request-quantity )
        TO rs_result-reservations.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_so_reservation_api~delete_reservations.
    DATA ls_return TYPE bapiret2.
    DATA lt_return TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.
    DATA lv_test_run TYPE c LENGTH 1.

    rs_result-is_successful = abap_true.
    IF iv_test_run = abap_true.
      lv_test_run = abap_true.
    ENDIF.

    LOOP AT it_reservation_numbers INTO DATA(lv_reservation_number).
      CLEAR lt_return.
      CALL FUNCTION 'BAPI_RESERVATION_DELETE'
        EXPORTING
          reservation = lv_reservation_number
          testrun     = lv_test_run
        TABLES
          return      = lt_return.

      LOOP AT lt_return INTO ls_return.
        APPEND VALUE #(
          type    = ls_return-type
          message = ls_return-message ) TO rs_result-messages.
        IF ls_return-type = 'A'
            OR ls_return-type = 'E'
            OR ls_return-type = 'X'.
          rs_result-is_successful = abap_false.
        ENDIF.
      ENDLOOP.

      IF rs_result-is_successful = abap_false.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_so_reservation_api~commit.
    DATA ls_return TYPE bapiret2.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait   = abap_true
      IMPORTING
        return = ls_return.

    rs_result-message-type = ls_return-type.
    rs_result-message-message = ls_return-message.
    rs_result-is_successful = abap_true.
    IF ls_return-type = 'A'
        OR ls_return-type = 'E'
        OR ls_return-type = 'X'.
      rs_result-is_successful = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD zif_so_reservation_api~rollback.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDMETHOD.

ENDCLASS.
