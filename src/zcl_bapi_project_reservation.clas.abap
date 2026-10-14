CLASS zcl_bapi_project_reservation DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_project_reservation_api.
ENDCLASS.

CLASS zcl_bapi_project_reservation IMPLEMENTATION.

  METHOD zif_project_reservation_api~create_reservation.
    DATA ls_header TYPE bapi2093_res_head.
    DATA ls_item TYPE bapi2093_res_item.
    DATA lt_items TYPE STANDARD TABLE OF bapi2093_res_item
      WITH DEFAULT KEY.
    DATA ls_atp_check TYPE bapi2093_atpcheck.
    DATA ls_return TYPE bapiret2.
    DATA lt_return TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.
    DATA lv_test_run TYPE c LENGTH 1.

    rs_result-is_successful = abap_true.
    IF is_request-wbs_element IS INITIAL
        OR is_request-required_date IS INITIAL
        OR is_request-items IS INITIAL.
      APPEND VALUE #(
        type    = 'E'
        message = 'WBS, required date, and reservation items are required' )
        TO rs_result-messages.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    ls_header-res_date = sy-datum.
    ls_header-move_type = '221'.
    ls_header-wbs_element = is_request-wbs_element.
    ls_atp_check-atpcheck = abap_true.
    IF iv_test_run = abap_true.
      lv_test_run = abap_true.
    ENDIF.

    LOOP AT is_request-items INTO DATA(ls_request_item).
      CLEAR ls_item.
      ls_item-material = ls_request_item-material.
      ls_item-plant = ls_request_item-plant.
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

    IF iv_test_run <> abap_true
        AND rs_result-reservation_number IS INITIAL.
      APPEND VALUE #(
        type    = 'E'
        message = 'Reservation BAPI returned no reservation number' )
        TO rs_result-messages.
      rs_result-is_successful = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD zif_project_reservation_api~delete_reservation.
    DATA lt_return TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.
    DATA lv_test_run TYPE c LENGTH 1.

    rs_result-is_successful = abap_true.
    IF iv_reservation_number IS INITIAL.
      APPEND VALUE #(
        type    = 'E'
        message = 'A reservation number is required for deletion' )
        TO rs_result-messages.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    IF iv_test_run = abap_true.
      lv_test_run = abap_true.
    ENDIF.

    CALL FUNCTION 'BAPI_RESERVATION_DELETE'
      EXPORTING
        reservation = iv_reservation_number
        testrun     = lv_test_run
      TABLES
        return      = lt_return.

    LOOP AT lt_return INTO DATA(ls_return).
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

  METHOD zif_project_reservation_api~delete_reservation_items.
    TYPES ty_seen_item TYPE resb-rspos.
    DATA lt_seen_items TYPE HASHED TABLE OF ty_seen_item
      WITH UNIQUE KEY table_line.
    DATA lt_changed_items TYPE STANDARD TABLE OF
      bapi2093_res_item_change WITH DEFAULT KEY.
    DATA lt_changed_itemsx TYPE STANDARD TABLE OF
      bapi2093_res_item_changex WITH DEFAULT KEY.
    DATA lt_return TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.

    rs_result-is_successful = abap_true.
    IF iv_reservation_number IS INITIAL OR it_item_numbers IS INITIAL.
      APPEND VALUE #(
        type    = 'E'
        message = 'Reservation number and at least one item are required' )
        TO rs_result-messages.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    LOOP AT it_item_numbers INTO DATA(lv_item_number).
      INSERT lv_item_number INTO TABLE lt_seen_items.
      IF lv_item_number IS INITIAL OR sy-subrc <> 0.
        APPEND VALUE #(
          type    = 'E'
          message = 'Reservation item numbers must be nonblank and unique' )
          TO rs_result-messages.
        rs_result-is_successful = abap_false.
        RETURN.
      ENDIF.
      APPEND VALUE #(
        res_item   = lv_item_number
        delete_ind = abap_true ) TO lt_changed_items.
      APPEND VALUE #(
        res_item   = lv_item_number
        delete_ind = abap_true ) TO lt_changed_itemsx.
    ENDLOOP.

    CALL FUNCTION 'BAPI_RESERVATION_CHANGE'
      EXPORTING
        reservation               = iv_reservation_number
      TABLES
        reservationitems_changed  = lt_changed_items
        reservationitems_changedx = lt_changed_itemsx
        return                    = lt_return.

    LOOP AT lt_return INTO DATA(ls_return).
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

  METHOD zif_project_reservation_api~change_reservation_item_dates.
    TYPES ty_seen_item TYPE resb-rspos.
    DATA lt_seen_items TYPE HASHED TABLE OF ty_seen_item
      WITH UNIQUE KEY table_line.
    DATA lt_changed_items TYPE STANDARD TABLE OF
      bapi2093_res_item_change WITH DEFAULT KEY.
    DATA lt_changed_itemsx TYPE STANDARD TABLE OF
      bapi2093_res_item_changex WITH DEFAULT KEY.
    DATA lt_return TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.

    rs_result-is_successful = abap_true.
    IF iv_reservation_number IS INITIAL
        OR it_item_numbers IS INITIAL
        OR iv_required_date IS INITIAL.
      APPEND VALUE #(
        type    = 'E'
        message = 'Reservation, items, and required date are required' )
        TO rs_result-messages.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    LOOP AT it_item_numbers INTO DATA(lv_item_number).
      INSERT lv_item_number INTO TABLE lt_seen_items.
      IF lv_item_number IS INITIAL OR sy-subrc <> 0.
        APPEND VALUE #(
          type    = 'E'
          message = 'Reservation item numbers must be nonblank and unique' )
          TO rs_result-messages.
        rs_result-is_successful = abap_false.
        RETURN.
      ENDIF.
      APPEND VALUE #(
        res_item = lv_item_number
        req_date = iv_required_date ) TO lt_changed_items.
      APPEND VALUE #(
        res_item = lv_item_number
        req_date = abap_true ) TO lt_changed_itemsx.
    ENDLOOP.

    CALL FUNCTION 'BAPI_RESERVATION_CHANGE'
      EXPORTING
        reservation               = iv_reservation_number
      TABLES
        reservationitems_changed  = lt_changed_items
        reservationitems_changedx = lt_changed_itemsx
        return                    = lt_return.

    LOOP AT lt_return INTO DATA(ls_return).
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

  METHOD zif_project_reservation_api~change_reservation_qty.
    TYPES ty_seen_item TYPE resb-rspos.
    DATA lt_seen_items TYPE HASHED TABLE OF ty_seen_item
      WITH UNIQUE KEY table_line.
    DATA lt_changed_items TYPE STANDARD TABLE OF
      bapi2093_res_item_change WITH DEFAULT KEY.
    DATA lt_changed_itemsx TYPE STANDARD TABLE OF
      bapi2093_res_item_changex WITH DEFAULT KEY.
    DATA lt_return TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.

    rs_result-is_successful = abap_true.
    IF iv_reservation_number IS INITIAL OR it_item_quantities IS INITIAL.
      APPEND VALUE #(
        type    = 'E'
        message = 'Reservation and item quantities are required' )
        TO rs_result-messages.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    LOOP AT it_item_quantities INTO DATA(ls_item_quantity).
      INSERT ls_item_quantity-item_number INTO TABLE lt_seen_items.
      IF ls_item_quantity-item_number IS INITIAL
          OR ls_item_quantity-required_quantity <= 0
          OR sy-subrc <> 0.
        APPEND VALUE #(
          type    = 'E'
          message = 'Items need unique numbers and positive quantities' )
          TO rs_result-messages.
        rs_result-is_successful = abap_false.
        RETURN.
      ENDIF.
      APPEND VALUE #(
        res_item  = ls_item_quantity-item_number
        entry_qnt = ls_item_quantity-required_quantity )
        TO lt_changed_items.
      APPEND VALUE #(
        res_item  = ls_item_quantity-item_number
        entry_qnt = abap_true )
        TO lt_changed_itemsx.
    ENDLOOP.

    CALL FUNCTION 'BAPI_RESERVATION_CHANGE'
      EXPORTING
        reservation               = iv_reservation_number
      TABLES
        reservationitems_changed  = lt_changed_items
        reservationitems_changedx = lt_changed_itemsx
        return                    = lt_return.

    LOOP AT lt_return INTO DATA(ls_return).
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

  METHOD zif_project_reservation_api~change_reservation_stock.
    TYPES ty_seen_item TYPE resb-rspos.
    DATA lt_seen_items TYPE HASHED TABLE OF ty_seen_item
      WITH UNIQUE KEY table_line.
    DATA lt_changed_items TYPE STANDARD TABLE OF
      bapi2093_res_item_change WITH DEFAULT KEY.
    DATA lt_changed_itemsx TYPE STANDARD TABLE OF
      bapi2093_res_item_changex WITH DEFAULT KEY.
    DATA lt_return TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.

    rs_result-is_successful = abap_true.
    IF iv_reservation_number IS INITIAL OR it_item_changes IS INITIAL.
      APPEND VALUE #(
        type    = 'E'
        message = 'Reservation and stock item changes are required' )
        TO rs_result-messages.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    LOOP AT it_item_changes INTO DATA(ls_item_change).
      INSERT ls_item_change-item_number INTO TABLE lt_seen_items.
      IF ls_item_change-item_number IS INITIAL
          OR ( ls_item_change-change_storage_location <> abap_true
            AND ls_item_change-change_storage_location <> abap_false )
          OR ( ls_item_change-change_batch <> abap_true
            AND ls_item_change-change_batch <> abap_false )
          OR ( ls_item_change-change_storage_location = abap_false
            AND ls_item_change-change_batch = abap_false )
          OR sy-subrc <> 0.
        APPEND VALUE #(
          type    = 'E'
          message = 'Each item needs a unique number and a valid stock field' )
          TO rs_result-messages.
        rs_result-is_successful = abap_false.
        RETURN.
      ENDIF.

      DATA(ls_changed_item) = VALUE bapi2093_res_item_change(
        res_item = ls_item_change-item_number ).
      DATA(ls_changed_itemx) = VALUE bapi2093_res_item_changex(
        res_item = ls_item_change-item_number ).
      IF ls_item_change-change_storage_location = abap_true.
        ls_changed_item-stge_loc = ls_item_change-storage_location.
        ls_changed_itemx-stge_loc = abap_true.
      ENDIF.
      IF ls_item_change-change_batch = abap_true.
        ls_changed_item-batch = ls_item_change-batch.
        ls_changed_itemx-batch = abap_true.
      ENDIF.
      APPEND ls_changed_item TO lt_changed_items.
      APPEND ls_changed_itemx TO lt_changed_itemsx.
    ENDLOOP.

    CALL FUNCTION 'BAPI_RESERVATION_CHANGE'
      EXPORTING
        reservation               = iv_reservation_number
      TABLES
        reservationitems_changed  = lt_changed_items
        reservationitems_changedx = lt_changed_itemsx
        return                    = lt_return.

    LOOP AT lt_return INTO DATA(ls_return).
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

  METHOD zif_project_reservation_api~set_items_final_issue.
    TYPES ty_seen_item TYPE resb-rspos.
    DATA lt_seen_items TYPE HASHED TABLE OF ty_seen_item
      WITH UNIQUE KEY table_line.
    DATA lt_changed_items TYPE STANDARD TABLE OF
      bapi2093_res_item_change WITH DEFAULT KEY.
    DATA lt_changed_itemsx TYPE STANDARD TABLE OF
      bapi2093_res_item_changex WITH DEFAULT KEY.
    DATA lt_return TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.

    rs_result-is_successful = abap_true.
    IF iv_reservation_number IS INITIAL
        OR it_item_numbers IS INITIAL
        OR ( iv_final_issue <> abap_true AND iv_final_issue <> abap_false ).
      APPEND VALUE #(
        type    = 'E'
        message = 'Reservation, items, and a valid final-issue flag are required' )
        TO rs_result-messages.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    LOOP AT it_item_numbers INTO DATA(lv_item_number).
      INSERT lv_item_number INTO TABLE lt_seen_items.
      IF lv_item_number IS INITIAL OR sy-subrc <> 0.
        APPEND VALUE #(
          type    = 'E'
          message = 'Reservation item numbers must be nonblank and unique' )
          TO rs_result-messages.
        rs_result-is_successful = abap_false.
        RETURN.
      ENDIF.
      APPEND VALUE #(
        res_item    = lv_item_number
        final_issue = iv_final_issue ) TO lt_changed_items.
      APPEND VALUE #(
        res_item    = lv_item_number
        final_issue = abap_true ) TO lt_changed_itemsx.
    ENDLOOP.

    CALL FUNCTION 'BAPI_RESERVATION_CHANGE'
      EXPORTING
        reservation               = iv_reservation_number
      TABLES
        reservationitems_changed  = lt_changed_items
        reservationitems_changedx = lt_changed_itemsx
        return                    = lt_return.

    LOOP AT lt_return INTO DATA(ls_return).
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

  METHOD zif_project_reservation_api~commit.
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

  METHOD zif_project_reservation_api~rollback.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDMETHOD.

ENDCLASS.
