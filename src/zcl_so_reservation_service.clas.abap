CLASS zcl_so_reservation_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_api TYPE REF TO zif_so_reservation_api OPTIONAL.

    METHODS delete_reservations
      IMPORTING
        it_reservation_numbers TYPE zif_so_reservation_api=>ty_reservation_numbers
        iv_test_run            TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)       TYPE zif_so_reservation_api=>ty_delete_result
      RAISING
        zcx_invalid_reservation.

  PRIVATE SECTION.
    DATA mo_api TYPE REF TO zif_so_reservation_api.
ENDCLASS.

CLASS zcl_so_reservation_service IMPLEMENTATION.

  METHOD constructor.
    IF io_api IS BOUND.
      mo_api = io_api.
    ELSE.
      mo_api = NEW zcl_bapi_so_reservation_api( ).
    ENDIF.
  ENDMETHOD.

  METHOD delete_reservations.
    IF it_reservation_numbers IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    DATA lt_seen TYPE HASHED TABLE OF bapi2093_res_key-reserv_no
      WITH UNIQUE KEY table_line.
    LOOP AT it_reservation_numbers INTO DATA(lv_reservation_number).
      IF lv_reservation_number IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.

      INSERT lv_reservation_number INTO TABLE lt_seen.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
    ENDLOOP.

    rs_result = mo_api->delete_reservations(
      it_reservation_numbers = it_reservation_numbers
      iv_test_run            = iv_test_run ).

    LOOP AT rs_result-messages INTO DATA(ls_message).
      IF ls_message-type = 'A'
          OR ls_message-type = 'E'
          OR ls_message-type = 'X'.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.

    IF rs_result-is_successful = abap_false.
      mo_api->rollback( ).
      RETURN.
    ENDIF.

    IF iv_test_run = abap_true.
      rs_result-is_successful = abap_true.
      RETURN.
    ENDIF.

    DATA(ls_commit_result) = mo_api->commit( ).
    IF ls_commit_result-is_successful = abap_false.
      mo_api->rollback( ).
      IF ls_commit_result-message-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
      ENDIF.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
  ENDMETHOD.

ENDCLASS.
