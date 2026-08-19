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

ENDCLASS.
