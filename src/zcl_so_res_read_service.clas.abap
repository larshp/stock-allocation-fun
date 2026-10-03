CLASS zcl_so_res_read_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_reader TYPE REF TO zif_so_reservation_reader OPTIONAL.

    METHODS read_reservation
      IMPORTING
        iv_reservation_number TYPE bapi2093_res_key-reserv_no
      RETURNING
        VALUE(rs_result)      TYPE zif_so_reservation_reader=>ty_result
      RAISING
        zcx_invalid_reservation.

  PRIVATE SECTION.
    DATA mo_reader TYPE REF TO zif_so_reservation_reader.
ENDCLASS.

CLASS zcl_so_res_read_service IMPLEMENTATION.

  METHOD constructor.
    IF io_reader IS BOUND.
      mo_reader = io_reader.
    ELSE.
      mo_reader = NEW zcl_bapi_so_reservation_api( ).
    ENDIF.
  ENDMETHOD.

  METHOD read_reservation.
    IF iv_reservation_number IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    rs_result = mo_reader->read_reservation(
      iv_reservation_number = iv_reservation_number ).

    LOOP AT rs_result-messages INTO DATA(ls_message).
      IF ls_message-type = 'A'
          OR ls_message-type = 'E'
          OR ls_message-type = 'X'.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.

    LOOP AT rs_result-items INTO DATA(ls_item).
      IF ls_item-reservation_number <> iv_reservation_number
          OR ls_item-item_number IS INITIAL.
        APPEND VALUE #(
          type    = 'E'
          message = 'Reservation API returned mismatched item details' )
          TO rs_result-messages.
        rs_result-is_successful = abap_false.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF rs_result-is_successful = abap_false.
      CLEAR rs_result-items.
      RETURN.
    ENDIF.

    IF rs_result-items IS INITIAL.
      APPEND VALUE #(
        type    = 'E'
        message = 'Reservation API returned no reservation items' )
        TO rs_result-messages.
      rs_result-is_successful = abap_false.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
