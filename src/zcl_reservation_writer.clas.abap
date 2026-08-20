CLASS zcl_reservation_writer DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_reservation_writer.

    "! Movement type an allocation reserves under. Which one a system uses is
    "! Customizing; 311 is a plant internal transfer and is a safe default for
    "! earmarking stock that has been promised but not yet issued.
    CONSTANTS c_default_move_type TYPE rkpf-bwart VALUE '311'.

    "! <p class="shorttext synchronized">Wire up the writer</p>
    "!
    "! @parameter iv_move_type | <p class="shorttext synchronized">Movement type of the reservation</p>
    METHODS constructor
      IMPORTING
        iv_move_type TYPE rkpf-bwart DEFAULT c_default_move_type.

  PRIVATE SECTION.

    TYPES ty_item_tab    TYPE STANDARD TABLE OF bapi2093_res_item WITH EMPTY KEY.
    TYPES ty_return_tab  TYPE STANDARD TABLE OF bapiret2 WITH EMPTY KEY.
    TYPES ty_change_tab  TYPE STANDARD TABLE OF bapi2093_res_item_change WITH EMPTY KEY.
    TYPES ty_changex_tab TYPE STANDARD TABLE OF bapi2093_res_item_changex WITH EMPTY KEY.
    TYPES ty_rspos_tab   TYPE STANDARD TABLE OF resb-rspos WITH EMPTY KEY.

    DATA mv_move_type TYPE rkpf-bwart.

    METHODS build_items
      IMPORTING
        iv_matnr       TYPE mard-matnr
        iv_werks       TYPE mard-werks
        iv_lgort       TYPE mard-lgort
        it_allocation  TYPE zif_allocation=>ty_allocation_tab
      RETURNING
        VALUE(rt_item) TYPE ty_item_tab.

    METHODS raise_on_error
      IMPORTING
        it_return TYPE ty_return_tab
      RAISING
        zcx_allocation.

    METHODS live_items_of
      IMPORTING
        iv_reservation  TYPE rkpf-rsnum
      RETURNING
        VALUE(rt_rspos) TYPE ty_rspos_tab.

ENDCLASS.


CLASS zcl_reservation_writer IMPLEMENTATION.

  METHOD constructor.
    mv_move_type = iv_move_type.
  ENDMETHOD.

  METHOD zif_reservation_writer~reserve.

    DATA lt_return      TYPE ty_return_tab.
    DATA lv_reservation TYPE rkpf-rsnum.

    DATA(lt_item) = build_items(
      iv_matnr      = iv_matnr
      iv_werks      = iv_werks
      iv_lgort      = iv_lgort
      it_allocation = it_allocation ).

    IF lt_item IS INITIAL.
      RETURN.
    ENDIF.

    CALL FUNCTION 'BAPI_RESERVATION_CREATE1'
      EXPORTING
        reservationheader = VALUE bapi2093_res_head(
                                    res_date   = sy-datum
                                    created_by = sy-uname
                                    move_type  = mv_move_type )
      IMPORTING
        reservation       = lv_reservation
      TABLES
        reservationitems  = lt_item
        return            = lt_return.

    raise_on_error( lt_return ).

    rv_reservation = lv_reservation.

  ENDMETHOD.

  METHOD zif_reservation_writer~cancel.

    DATA lt_item   TYPE ty_change_tab.
    DATA lt_itemx  TYPE ty_changex_tab.
    DATA lt_return TYPE ty_return_tab.

    IF iv_reservation IS INITIAL.
      RETURN.
    ENDIF.

    " an item that is already deleted is left alone: there is nothing to give
    " back, and a BAPI told to delete what is deleted answers with an error
    " that says nothing went wrong
    DATA(lt_rspos) = live_items_of( iv_reservation ).
    IF lt_rspos IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_rspos INTO DATA(lv_rspos).
      APPEND VALUE #( res_item   = lv_rspos
                      delete_ind = abap_true ) TO lt_item.
      APPEND VALUE #( res_item   = lv_rspos
                      delete_ind = abap_true ) TO lt_itemx.
    ENDLOOP.

    CALL FUNCTION 'BAPI_RESERVATION_CHANGE'
      EXPORTING
        reservation       = iv_reservation
      TABLES
        reservationitems  = lt_item
        reservationitemsx = lt_itemx
        return            = lt_return.

    raise_on_error( lt_return ).

  ENDMETHOD.

  METHOD live_items_of.

    SELECT rspos
      FROM resb
      WHERE rsnum = @iv_reservation
        AND xloek = @space
      ORDER BY rspos
      INTO TABLE @rt_rspos.
    IF sy-subrc <> 0.
      CLEAR rt_rspos.
    ENDIF.

  ENDMETHOD.

  METHOD build_items.

    " the unit of entry is left empty on purpose, the BAPI then falls back to
    " the base unit of measure of the material
    LOOP AT it_allocation INTO DATA(ls_allocation) WHERE confirmed > 0.
      APPEND VALUE #(
        material  = iv_matnr
        plant     = iv_werks
        stge_loc  = iv_lgort
        entry_qnt = ls_allocation-confirmed
        req_date  = ls_allocation-req_date ) TO rt_item.
    ENDLOOP.

  ENDMETHOD.

  METHOD raise_on_error.

    LOOP AT it_return INTO DATA(ls_return) WHERE type = 'E' OR type = 'A'.
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>reserve_failed
        mv_message = |{ ls_return-message }| ).
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
