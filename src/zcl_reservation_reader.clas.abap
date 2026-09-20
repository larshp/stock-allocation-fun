CLASS zcl_reservation_reader DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_reservation_reader.

ENDCLASS.


CLASS zcl_reservation_reader IMPLEMENTATION.

  METHOD zif_reservation_reader~live_reservations.

    " one reservation can hold several items of the same material, so the
    " numbers are deduplicated. DELETE ADJACENT DUPLICATES rather than SELECT
    " DISTINCT, which the transpiler drops, see ANOMALIES.md.
    SELECT rsnum
      FROM resb
      WHERE matnr = @iv_matnr
        AND werks = @iv_werks
        AND xloek = @space
      ORDER BY rsnum
      INTO TABLE @rt_reservation.
    IF sy-subrc <> 0.
      CLEAR rt_reservation.
      RETURN.
    ENDIF.

    DELETE ADJACENT DUPLICATES FROM rt_reservation.

  ENDMETHOD.

  METHOD zif_reservation_reader~held_quantity.

    IF iv_reservation IS INITIAL.
      RETURN.
    ENDIF.

    " the same definition of live as above: an item flagged for deletion holds
    " nothing, and a reservation whose items are all flagged holds nothing at
    " all rather than not existing
    SELECT SUM( bdmng )
      FROM resb
      WHERE rsnum = @iv_reservation
        AND xloek = @space
      INTO @DATA(lv_quantity).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    IF lv_quantity > 0.
      rv_quantity = lv_quantity.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
