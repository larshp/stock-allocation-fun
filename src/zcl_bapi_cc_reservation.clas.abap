CLASS zcl_bapi_cc_reservation DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_cc_reservation_api.
ENDCLASS.

CLASS zcl_bapi_cc_reservation IMPLEMENTATION.

  METHOD zif_cc_reservation_api~create_reservation.
    DATA ls_header TYPE bapi2093_res_head.
    DATA ls_item TYPE bapi2093_res_item.
    DATA lt_items TYPE STANDARD TABLE OF bapi2093_res_item
      WITH DEFAULT KEY.
    DATA ls_atp_check TYPE bapi2093_atpcheck.
    DATA ls_return TYPE bapiret2.
    DATA lt_return TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.
    DATA lv_test_run TYPE c LENGTH 1.

    rs_result-is_successful = abap_true.
    IF is_request-items IS INITIAL.
      APPEND VALUE #(
        type    = 'E'
        message = 'At least one cost-center reservation item is required' )
        TO rs_result-messages.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    ls_header-res_date = sy-datum.
    ls_header-move_type = '201'.
    ls_header-costcenter = is_request-cost_center.
    ls_atp_check-atpcheck = abap_true.
    IF iv_test_run = abap_true.
      lv_test_run = abap_true.
    ENDIF.

    LOOP AT is_request-items INTO DATA(ls_request_item).
      CLEAR ls_item.
      ls_item-material = is_request-material.
      ls_item-plant = is_request-plant.
      ls_item-stge_loc = ls_request_item-storage_location.
      ls_item-batch = ls_request_item-batch.
      ls_item-entry_qnt = ls_request_item-quantity.
      ls_item-entry_uom = ls_request_item-unit.
      ls_item-req_date = is_request-required_date.
      ls_item-movement = abap_true.
      APPEND ls_item TO lt_items.
    ENDLOOP.

    CALL FUNCTION 'BAPI_RESERVATION_CREATE1'
      EXPORTING
        reservationheader = ls_header
        testrun           = lv_test_run
        atpcheck          = ls_atp_check
      IMPORTING
        reservation       = rs_result-reservation_number
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
  ENDMETHOD.

  METHOD zif_cc_reservation_api~commit.
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

  METHOD zif_cc_reservation_api~rollback.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDMETHOD.

ENDCLASS.
