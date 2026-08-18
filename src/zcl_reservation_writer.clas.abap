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

    TYPES ty_item_tab   TYPE STANDARD TABLE OF bapi2093_res_item WITH EMPTY KEY.
    TYPES ty_return_tab TYPE STANDARD TABLE OF bapiret2 WITH EMPTY KEY.

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
