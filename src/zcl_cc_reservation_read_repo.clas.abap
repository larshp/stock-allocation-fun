CLASS zcl_cc_reservation_read_repo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_cc_reservation_read_repo.
ENDCLASS.

CLASS zcl_cc_reservation_read_repo IMPLEMENTATION.

  METHOD zif_cc_reservation_read_repo~get_open_reservations.
    rt_reservations = zif_cc_reservation_read_repo~get_open_reservations_bulk(
      it_cost_centers          = VALUE #( ( iv_cost_center ) )
      iv_required_through_date = iv_required_through_date ).
  ENDMETHOD.

  METHOD zif_cc_reservation_read_repo~get_open_reservations_bulk.
    TYPES:
      BEGIN OF ty_cost_center_key,
        cost_center TYPE rkpf-kostl,
      END OF ty_cost_center_key,
      ty_cost_center_keys TYPE SORTED TABLE OF ty_cost_center_key
        WITH UNIQUE KEY cost_center,
      BEGIN OF ty_reservation_header,
        reservation_number TYPE rkpf-rsnum,
        cost_center        TYPE rkpf-kostl,
      END OF ty_reservation_header,
      ty_reservation_headers TYPE HASHED TABLE OF ty_reservation_header
        WITH UNIQUE KEY reservation_number.
    DATA lt_cost_center_keys TYPE ty_cost_center_keys.
    DATA lt_headers TYPE ty_reservation_headers.
    DATA lt_items TYPE STANDARD TABLE OF resb WITH EMPTY KEY.
    DATA lv_initial_required_date TYPE resb-bdter.

    IF it_cost_centers IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_cost_centers INTO DATA(lv_cost_center).
      INSERT VALUE #( cost_center = lv_cost_center )
        INTO TABLE lt_cost_center_keys.
    ENDLOOP.

    SELECT rsnum AS reservation_number,
           kostl AS cost_center
      FROM rkpf
      FOR ALL ENTRIES IN @lt_cost_center_keys
      WHERE kostl = @lt_cost_center_keys-cost_center
      INTO TABLE @lt_headers.

    IF lt_headers IS INITIAL.
      RETURN.
    ENDIF.

    SELECT rsnum,
           rspos,
           matnr,
           werks,
           lgort,
           charg,
           bdter,
           meins,
           bdmng,
           enmng
      FROM resb
      FOR ALL ENTRIES IN @lt_headers
      WHERE rsnum = @lt_headers-reservation_number
        AND bwart = '201'
        AND sobkz = @space
        AND xloek = @space
        AND kzear = @space
        AND ( @iv_required_through_date = @lv_initial_required_date
          OR bdter = @lv_initial_required_date
          OR bdter <= @iv_required_through_date )
      INTO CORRESPONDING FIELDS OF TABLE @lt_items.

    LOOP AT lt_items INTO DATA(ls_item).
      READ TABLE lt_headers INTO DATA(ls_header)
        WITH TABLE KEY reservation_number = ls_item-rsnum.
      IF sy-subrc <> 0 OR ls_item-bdmng <= ls_item-enmng.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        cost_center        = ls_header-cost_center
        reservation_number = ls_item-rsnum
        reservation_item   = ls_item-rspos
        material           = ls_item-matnr
        plant              = ls_item-werks
        storage_location   = ls_item-lgort
        batch              = ls_item-charg
        required_date      = ls_item-bdter
        unit               = ls_item-meins
        required_quantity  = ls_item-bdmng
        withdrawn_quantity = ls_item-enmng )
        TO rt_reservations.
    ENDLOOP.

    SORT rt_reservations BY material plant required_date
      reservation_number reservation_item.

    LOOP AT rt_reservations ASSIGNING FIELD-SYMBOL(<ls_reservation>).
      <ls_reservation>-open_quantity =
        zcl_stock_avail_qty_calc=>calculate_open_res_qty(
          iv_required_quantity  = <ls_reservation>-required_quantity
          iv_withdrawn_quantity = <ls_reservation>-withdrawn_quantity ).
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_cc_reservation_read_repo~get_reservation_item_scopes.
    TYPES:
      BEGIN OF ty_cost_center_key,
        cost_center TYPE rkpf-kostl,
      END OF ty_cost_center_key,
      ty_cost_center_keys TYPE SORTED TABLE OF ty_cost_center_key
        WITH UNIQUE KEY cost_center,
      BEGIN OF ty_reservation_header,
        reservation_number TYPE rkpf-rsnum,
        cost_center        TYPE rkpf-kostl,
      END OF ty_reservation_header,
      ty_reservation_headers TYPE HASHED TABLE OF ty_reservation_header
        WITH UNIQUE KEY reservation_number.
    DATA lt_cost_center_keys TYPE ty_cost_center_keys.
    DATA lt_headers TYPE ty_reservation_headers.
    DATA lt_items TYPE STANDARD TABLE OF resb WITH EMPTY KEY.

    IF iv_cost_center IS INITIAL OR it_item_keys IS INITIAL.
      RETURN.
    ENDIF.

    INSERT VALUE #( cost_center = iv_cost_center )
      INTO TABLE lt_cost_center_keys.

    SELECT rsnum AS reservation_number,
           kostl AS cost_center
      FROM rkpf
      FOR ALL ENTRIES IN @lt_cost_center_keys
      WHERE kostl = @lt_cost_center_keys-cost_center
      INTO TABLE @lt_headers.

    IF lt_headers IS INITIAL.
      RETURN.
    ENDIF.

    SELECT rsnum,
           rspos
      FROM resb
      FOR ALL ENTRIES IN @it_item_keys
      WHERE rsnum = @it_item_keys-reservation_number
        AND rspos = @it_item_keys-reservation_item
        AND bwart = '201'
        AND sobkz = @space
      INTO CORRESPONDING FIELDS OF TABLE @lt_items.

    LOOP AT lt_items INTO DATA(ls_item).
      READ TABLE lt_headers INTO DATA(ls_header)
        WITH TABLE KEY reservation_number = ls_item-rsnum.
      IF sy-subrc = 0.
        APPEND VALUE #(
          cost_center        = ls_header-cost_center
          reservation_number = ls_item-rsnum
          reservation_item   = ls_item-rspos ) TO rt_scopes.
      ENDIF.
    ENDLOOP.

    SORT rt_scopes BY reservation_number reservation_item.
  ENDMETHOD.

ENDCLASS.
