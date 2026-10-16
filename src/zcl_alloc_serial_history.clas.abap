CLASS zcl_alloc_serial_history DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_event,
             serial     TYPE i,
             event_type TYPE string,
             day        TYPE i,
           END OF ty_event.
    TYPES ty_event_tt TYPE STANDARD TABLE OF ty_event WITH DEFAULT KEY.

    METHODS add
      IMPORTING
        is_event TYPE ty_event.

    METHODS history
      IMPORTING
        iv_serial        TYPE i
      RETURNING
        VALUE(rt_events) TYPE ty_event_tt.

    METHODS count_of
      IMPORTING
        iv_serial       TYPE i
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS last_event
      IMPORTING
        iv_serial      TYPE i
      RETURNING
        VALUE(rv_type) TYPE string.

    METHODS clear.

  PRIVATE SECTION.
    DATA mt_events TYPE ty_event_tt.

ENDCLASS.


CLASS zcl_alloc_serial_history IMPLEMENTATION.

  METHOD add.
    APPEND is_event TO mt_events.
  ENDMETHOD.

  METHOD history.
    LOOP AT mt_events INTO DATA(ls_event).
      IF ls_event-serial = iv_serial.
        APPEND ls_event TO rt_events.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD count_of.
    DATA lt_events TYPE ty_event_tt.

    lt_events = history( iv_serial ).
    rv_count = lines( lt_events ).
  ENDMETHOD.

  METHOD last_event.
    DATA lv_latest TYPE i.
    DATA lv_seen   TYPE abap_bool.

    " "Last" means the latest day, and the first event recorded on that day wins,
    " so the answer does not depend on the insertion order of same-day events.
    LOOP AT mt_events INTO DATA(ls_event).
      IF ls_event-serial <> iv_serial.
        CONTINUE.
      ENDIF.

      IF lv_seen = abap_false OR ls_event-day > lv_latest.
        lv_latest = ls_event-day.
        rv_type = ls_event-event_type.
        lv_seen = abap_true.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD clear.
    CLEAR mt_events.
  ENDMETHOD.

ENDCLASS.
