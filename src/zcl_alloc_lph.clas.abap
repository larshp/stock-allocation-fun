CLASS zcl_alloc_lph DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_pick,
             start_min TYPE i,
             end_min   TYPE i,
             lines     TYPE i,
           END OF ty_pick.
    TYPES ty_pick_tt TYPE STANDARD TABLE OF ty_pick WITH DEFAULT KEY.

    METHODS total_lines
      IMPORTING
        it_picks        TYPE ty_pick_tt
      RETURNING
        VALUE(rv_lines) TYPE i.

    METHODS total_minutes
      IMPORTING
        it_picks      TYPE ty_pick_tt
      RETURNING
        VALUE(rv_min) TYPE i.

    METHODS lines_per_hour
      IMPORTING
        it_picks      TYPE ty_pick_tt
      RETURNING
        VALUE(rv_lph) TYPE i.

    METHODS achievement_percent
      IMPORTING
        iv_actual     TYPE i
        iv_target     TYPE i
      RETURNING
        VALUE(rv_pct) TYPE i.

ENDCLASS.


CLASS zcl_alloc_lph IMPLEMENTATION.

  METHOD total_lines.
    LOOP AT it_picks INTO DATA(ls_pick).
      IF ls_pick-lines > 0.
        rv_lines = rv_lines + ls_pick-lines.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD total_minutes.
    DATA lv_span TYPE i.

    " A pick whose end is before its start contributes no time rather than
    " subtracting from the working minutes.
    LOOP AT it_picks INTO DATA(ls_pick).
      lv_span = ls_pick-end_min - ls_pick-start_min.
      IF lv_span > 0.
        rv_min = rv_min + lv_span.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD lines_per_hour.
    DATA lv_minutes TYPE i.

    lv_minutes = total_minutes( it_picks ).

    IF lv_minutes <= 0.
      RETURN.
    ENDIF.

    rv_lph = total_lines( it_picks ) * 60 DIV lv_minutes.
  ENDMETHOD.

  METHOD achievement_percent.
    IF iv_target <= 0 OR iv_actual <= 0.
      RETURN.
    ENDIF.

    rv_pct = iv_actual * 100 DIV iv_target.
  ENDMETHOD.

ENDCLASS.
