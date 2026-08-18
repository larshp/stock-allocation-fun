CLASS cl_stub_reservation DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_item_tab   TYPE STANDARD TABLE OF bapi2093_res_item WITH EMPTY KEY.
    TYPES ty_return_tab TYPE STANDARD TABLE OF bapiret2 WITH EMPTY KEY.

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
                      bdter = ls_item-req_date ) TO lt_resb.
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
