CLASS zcl_alloc_return_seq DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_point,
             id       TYPE string,
             distance TYPE i,
           END OF ty_point.
    TYPES ty_point_tt TYPE STANDARD TABLE OF ty_point WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_stop,
             position TYPE i,
             id       TYPE string,
             distance TYPE i,
           END OF ty_stop.
    TYPES ty_stop_tt TYPE STANDARD TABLE OF ty_stop WITH DEFAULT KEY.

    METHODS sequence
      IMPORTING
        it_points          TYPE ty_point_tt
      RETURNING
        VALUE(rt_sequence) TYPE ty_stop_tt.

    METHODS position_of
      IMPORTING
        it_sequence   TYPE ty_stop_tt
        iv_id         TYPE string
      RETURNING
        VALUE(rv_pos) TYPE i.

    METHODS distance
      IMPORTING
        it_sequence        TYPE ty_stop_tt
      RETURNING
        VALUE(rv_distance) TYPE i.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_work,
             id       TYPE string,
             distance TYPE i,
             seq      TYPE i,
           END OF ty_work.
    TYPES ty_work_tt TYPE STANDARD TABLE OF ty_work WITH DEFAULT KEY.

ENDCLASS.


CLASS zcl_alloc_return_seq IMPLEMENTATION.

  METHOD sequence.
    DATA lt_work TYPE ty_work_tt.
    DATA ls_work TYPE ty_work.
    DATA lv_seq  TYPE i.
    DATA lv_pos  TYPE i.
    DATA ls_stop TYPE ty_stop.

    " Pickups are visited nearest first; the first point seen breaks a tie.
    LOOP AT it_points INTO DATA(ls_point).
      IF ls_point-id IS INITIAL.
        CONTINUE.
      ENDIF.

      lv_seq = lv_seq + 1.

      CLEAR ls_work.
      ls_work-id = ls_point-id.
      ls_work-distance = ls_point-distance.
      ls_work-seq = lv_seq.
      APPEND ls_work TO lt_work.
    ENDLOOP.

    SORT lt_work BY distance ASCENDING
                    seq      ASCENDING.

    LOOP AT lt_work INTO ls_work.
      lv_pos = lv_pos + 1.

      CLEAR ls_stop.
      ls_stop-position = lv_pos.
      ls_stop-id = ls_work-id.
      ls_stop-distance = ls_work-distance.
      APPEND ls_stop TO rt_sequence.
    ENDLOOP.
  ENDMETHOD.

  METHOD position_of.
    LOOP AT it_sequence INTO DATA(ls_stop).
      IF ls_stop-id = iv_id.
        rv_pos = ls_stop-position.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD distance.
    LOOP AT it_sequence INTO DATA(ls_stop).
      IF ls_stop-distance > 0.
        rv_distance = rv_distance + ls_stop-distance.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
