CLASS cl_stub_reservation DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_item_tab   TYPE STANDARD TABLE OF bapi2093_res_item WITH EMPTY KEY.
    TYPES ty_return_tab TYPE STANDARD TABLE OF bapiret2 WITH EMPTY KEY.
    TYPES ty_change_tab TYPE STANDARD TABLE OF bapi2093_res_item_change WITH EMPTY KEY.
    TYPES ty_changex_tab TYPE STANDARD TABLE OF bapi2093_res_item_changex WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_result,
        reservation TYPE rkpf-rsnum,
        messages    TYPE ty_return_tab,
      END OF ty_result.

    "! <p class="shorttext synchronized">Create a reservation from RKPF and RESB</p>
    "!
    "! Carries the part of BAPI_RESERVATION_CREATE1 that the custom code
    "! actually depends on: an empty item table is rejected, otherwise the next
    "! reservation number is handed out and the tables are written.
    "!
    "! @parameter is_header | <p class="shorttext synchronized">Reservation header</p>
    "! @parameter it_item   | <p class="shorttext synchronized">Reservation items</p>
    "! @parameter rs_result | <p class="shorttext synchronized">Reservation number and messages</p>
    CLASS-METHODS create
      IMPORTING
        is_header        TYPE bapi2093_res_head
        it_item          TYPE ty_item_tab
      RETURNING
        VALUE(rs_result) TYPE ty_result.

    "! <p class="shorttext synchronized">Change the items of an existing reservation</p>
    "!
    "! Carries the part of BAPI_RESERVATION_CHANGE the custom code depends on:
    "! an item whose deletion indicator is set and marked as changed gets
    "! RESB-XLOEK, which is what the readers of a live reservation look at. A
    "! reservation that is not there is refused.
    "!
    "! @parameter iv_reservation | <p class="shorttext synchronized">Reservation number</p>
    "! @parameter it_item        | <p class="shorttext synchronized">Items as they are to be</p>
    "! @parameter it_itemx       | <p class="shorttext synchronized">Which of their fields to take</p>
    "! @parameter rt_message     | <p class="shorttext synchronized">What the BAPI would say</p>
    CLASS-METHODS change
      IMPORTING
        iv_reservation    TYPE rkpf-rsnum
        it_item           TYPE ty_change_tab
        it_itemx          TYPE ty_changex_tab
      RETURNING
        VALUE(rt_message) TYPE ty_return_tab.

  PRIVATE SECTION.

    CLASS-METHODS next_reservation_number
      RETURNING
        VALUE(rv_rsnum) TYPE rkpf-rsnum.

    CLASS-METHODS error
      IMPORTING
        iv_number         TYPE bapiret2-number
        iv_message        TYPE bapiret2-message
      RETURNING
        VALUE(rs_message) TYPE bapiret2.

ENDCLASS.


CLASS cl_stub_reservation IMPLEMENTATION.

  METHOD create.

    DATA lt_resb TYPE STANDARD TABLE OF resb WITH EMPTY KEY.
    DATA lv_rspos TYPE resb-rspos.

    IF it_item IS INITIAL.
      APPEND error(
        iv_number  = '018'
        iv_message = 'No items transferred' ) TO rs_result-messages.
      RETURN.
    ENDIF.

    DATA(lv_rsnum) = next_reservation_number( ).

    INSERT rkpf FROM @( VALUE #( mandt = sy-mandt
                                 rsnum = lv_rsnum
                                 rsdat = is_header-res_date
                                 usnam = is_header-created_by
                                 bwart = is_header-move_type ) ).
    IF sy-subrc <> 0.
      APPEND error(
        iv_number  = '001'
        iv_message = 'Reservation header could not be created' ) TO rs_result-messages.
      RETURN.
    ENDIF.

    LOOP AT it_item INTO DATA(ls_item).
      lv_rspos = lv_rspos + 1.
      APPEND VALUE #( mandt = sy-mandt
                      rsnum = lv_rsnum
                      rspos = lv_rspos
                      matnr = ls_item-material
                      werks = ls_item-plant
                      lgort = ls_item-stge_loc
                      bdmng = ls_item-entry_qnt
                      meins = ls_item-entry_uom
                      bdter = ls_item-req_date
                      sgtxt = ls_item-item_text ) TO lt_resb.
    ENDLOOP.

    INSERT resb FROM TABLE @lt_resb.
    IF sy-subrc <> 0.
      APPEND error(
        iv_number  = '002'
        iv_message = 'Reservation items could not be created' ) TO rs_result-messages.
      RETURN.
    ENDIF.

    rs_result-reservation = lv_rsnum.
    APPEND VALUE #( type       = 'S'
                    id         = 'M7'
                    number     = '060'
                    message    = 'Reservation created'
                    message_v1 = lv_rsnum ) TO rs_result-messages.

  ENDMETHOD.

  METHOD change.

    DATA lv_touched    TYPE abap_bool.
    DATA lt_item_range TYPE RANGE OF resb-rspos.

    SELECT SINGLE rsnum FROM rkpf
      WHERE rsnum = @iv_reservation
      INTO @DATA(lv_rsnum).
    IF sy-subrc <> 0.
      APPEND error(
        iv_number  = '003'
        iv_message = 'Reservation does not exist' ) TO rt_message.
      RETURN.
    ENDIF.

    " a field is only taken when the X structure says so, which is how every
    " change BAPI tells a blank apart from a field nobody set
    LOOP AT it_item INTO DATA(ls_item).
      IF line_exists( it_itemx[ res_item   = ls_item-res_item
                                delete_ind = abap_true ] ).
        APPEND VALUE #( sign   = 'I'
                        option = 'EQ'
                        low    = ls_item-res_item ) TO lt_item_range.
      ENDIF.
    ENDLOOP.

    IF lt_item_range IS NOT INITIAL.
      UPDATE resb SET xloek = @abap_true
        WHERE rsnum = @lv_rsnum
          AND rspos IN @lt_item_range.
      IF sy-subrc = 0.
        lv_touched = abap_true.
      ENDIF.
    ENDIF.

    IF lv_touched = abap_false.
      APPEND error(
        iv_number  = '004'
        iv_message = 'No reservation item was changed' ) TO rt_message.
      RETURN.
    ENDIF.

    APPEND VALUE #( type       = 'S'
                    id         = 'M7'
                    number     = '061'
                    message    = 'Reservation changed'
                    message_v1 = lv_rsnum ) TO rt_message.

  ENDMETHOD.

  METHOD next_reservation_number.

    SELECT MAX( rsnum ) FROM rkpf INTO @DATA(lv_highest).
    IF sy-subrc <> 0.
      CLEAR lv_highest.
    ENDIF.

    rv_rsnum = lv_highest + 1.

  ENDMETHOD.

  METHOD error.

    rs_message = VALUE #( type    = 'E'
                          id      = 'M7'
                          number  = iv_number
                          message = iv_message ).

  ENDMETHOD.

ENDCLASS.
