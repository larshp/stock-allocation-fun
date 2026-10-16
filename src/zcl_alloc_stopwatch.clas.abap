CLASS zcl_alloc_stopwatch DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_lap,
             lap TYPE i,
             ms  TYPE i,
           END OF ty_lap.
    TYPES ty_lap_tt TYPE STANDARD TABLE OF ty_lap WITH DEFAULT KEY.

    METHODS lap
      IMPORTING
        iv_ms         TYPE i
      RETURNING
        VALUE(rs_lap) TYPE ty_lap.

    METHODS laps
      RETURNING
        VALUE(rt_laps) TYPE ty_lap_tt.

    METHODS count
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS total
      RETURNING
        VALUE(rv_ms) TYPE i.

    METHODS fastest
      RETURNING
        VALUE(rv_ms) TYPE i.

    METHODS slowest
      RETURNING
        VALUE(rv_ms) TYPE i.

  PRIVATE SECTION.
    DATA mt_laps TYPE ty_lap_tt.

ENDCLASS.


CLASS zcl_alloc_stopwatch IMPLEMENTATION.

  METHOD lap.
    rs_lap-lap = lines( mt_laps ) + 1.
    rs_lap-ms = iv_ms.

    APPEND rs_lap TO mt_laps.
  ENDMETHOD.

  METHOD laps.
    rt_laps = mt_laps.
  ENDMETHOD.

  METHOD count.
    rv_count = lines( mt_laps ).
  ENDMETHOD.

  METHOD total.
    DATA ls_lap TYPE ty_lap.

    rv_ms = 0.

    LOOP AT mt_laps INTO ls_lap.
      rv_ms = rv_ms + ls_lap-ms.
    ENDLOOP.
  ENDMETHOD.

  METHOD fastest.
    DATA ls_lap TYPE ty_lap.
    DATA lv_found TYPE abap_bool.

    LOOP AT mt_laps INTO ls_lap.
      IF lv_found = abap_false OR ls_lap-ms < rv_ms.
        rv_ms = ls_lap-ms.
        lv_found = abap_true.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD slowest.
    DATA ls_lap TYPE ty_lap.
    DATA lv_found TYPE abap_bool.

    LOOP AT mt_laps INTO ls_lap.
      IF lv_found = abap_false OR ls_lap-ms > rv_ms.
        rv_ms = ls_lap-ms.
        lv_found = abap_true.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
