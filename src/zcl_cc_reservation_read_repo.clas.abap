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
      it_cost_centers = VALUE #( ( iv_cost_center ) ) ).
  ENDMETHOD.

  METHOD zif_cc_reservation_read_repo~get_open_reservations_bulk.
    IF it_cost_centers IS INITIAL.
      RETURN.
    ENDIF.

    SELECT header~kostl AS cost_center,
           item~rsnum AS reservation_number,
           item~rspos AS reservation_item,
           item~matnr AS material,
           item~werks AS plant,
           item~lgort AS storage_location,
           item~charg AS batch,
           item~bdter AS required_date,
           item~meins AS unit,
           item~bdmng AS required_quantity,
           item~enmng AS withdrawn_quantity
      FROM resb AS item
      INNER JOIN rkpf AS header
        ON header~rsnum = item~rsnum
      FOR ALL ENTRIES IN @it_cost_centers
      WHERE header~kostl = @it_cost_centers-table_line
        AND item~bwart = '201'
        AND item~sobkz = @space
        AND item~xloek = @space
        AND item~kzear = @space
        AND item~bdmng > item~enmng
      ORDER BY item~matnr, item~werks, item~bdter, item~rsnum, item~rspos
      INTO CORRESPONDING FIELDS OF TABLE @rt_reservations.

    LOOP AT rt_reservations ASSIGNING FIELD-SYMBOL(<ls_reservation>).
      <ls_reservation>-open_quantity =
        <ls_reservation>-required_quantity
        - <ls_reservation>-withdrawn_quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_cc_reservation_read_repo~get_reservation_item_scopes.
    IF iv_cost_center IS INITIAL OR it_item_keys IS INITIAL.
      RETURN.
    ENDIF.

    SELECT header~kostl AS cost_center,
           item~rsnum AS reservation_number,
           item~rspos AS reservation_item
      FROM resb AS item
      INNER JOIN rkpf AS header
        ON header~rsnum = item~rsnum
      FOR ALL ENTRIES IN @it_item_keys
      WHERE header~kostl = @iv_cost_center
        AND item~rsnum = @it_item_keys-reservation_number
        AND item~rspos = @it_item_keys-reservation_item
        AND item~bwart = '201'
        AND item~sobkz = @space
      ORDER BY item~rsnum, item~rspos
      INTO CORRESPONDING FIELDS OF TABLE @rt_scopes.
  ENDMETHOD.

ENDCLASS.
