CLASS zcl_alloc_valm_watch DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material  TYPE matnr,
             value     TYPE i,
             threshold TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_watch,
             material TYPE matnr,
             excess   TYPE i,
           END OF ty_watch.
    TYPES ty_watch_tt TYPE STANDARD TABLE OF ty_watch WITH DEFAULT KEY.

    METHODS watch
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rt_watch) TYPE ty_watch_tt.

    METHODS watch_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS is_watched
      IMPORTING
        iv_value     TYPE i
        iv_threshold TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_valm_watch IMPLEMENTATION.

  METHOD is_watched.
    " A value lands on the watchlist once it passes its threshold.
    rv_ok = xsdbool( iv_value > iv_threshold ).
  ENDMETHOD.

  METHOD watch.
    DATA ls_watch TYPE ty_watch.

    " Every line over its threshold goes on the watchlist with its excess.
    LOOP AT it_lines INTO DATA(ls_line).
      IF is_watched( iv_value     = ls_line-value
                     iv_threshold = ls_line-threshold ) = abap_false.
        CONTINUE.
      ENDIF.

      ls_watch-material = ls_line-material.
      ls_watch-excess = ls_line-value - ls_line-threshold.
      APPEND ls_watch TO rt_watch.
    ENDLOOP.
  ENDMETHOD.

  METHOD watch_count.
    DATA lt_watch TYPE ty_watch_tt.

    " The count is how many lines came back on the watchlist.
    lt_watch = watch( it_lines ).
    rv_count = lines( lt_watch ).
  ENDMETHOD.

ENDCLASS.
