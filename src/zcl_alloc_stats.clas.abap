CLASS zcl_alloc_stats DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_stats,
             requests      TYPE i,
             allocated     TYPE i,
             shortage      TYPE i,
             fully_covered TYPE i,
             short_covered TYPE i,
           END OF ty_stats.

    METHODS constructor.

    METHODS note
      IMPORTING
        iv_requested    TYPE i
        iv_allocated    TYPE i
      RETURNING
        VALUE(rs_stats) TYPE ty_stats.

    METHODS get
      RETURNING
        VALUE(rs_stats) TYPE ty_stats.

    METHODS runs
      RETURNING
        VALUE(rv_count) TYPE i.

  PRIVATE SECTION.
    DATA ms_stats TYPE ty_stats.
    DATA mv_runs  TYPE i.

ENDCLASS.


CLASS zcl_alloc_stats IMPLEMENTATION.

  METHOD constructor.
    CLEAR ms_stats.
    mv_runs = 0.
  ENDMETHOD.

  METHOD note.
    DATA lv_short TYPE i.

    mv_runs = mv_runs + 1.

    ms_stats-requests = ms_stats-requests + 1.
    ms_stats-allocated = ms_stats-allocated + iv_allocated.

    lv_short = iv_requested - iv_allocated.
    IF lv_short < 0.
      lv_short = 0.
    ENDIF.
    ms_stats-shortage = ms_stats-shortage + lv_short.

    IF iv_allocated >= iv_requested.
      ms_stats-fully_covered = ms_stats-fully_covered + 1.
    ELSE.
      ms_stats-short_covered = ms_stats-short_covered + 1.
    ENDIF.

    rs_stats = ms_stats.
  ENDMETHOD.

  METHOD get.
    rs_stats = ms_stats.
  ENDMETHOD.

  METHOD runs.
    rv_count = mv_runs.
  ENDMETHOD.

ENDCLASS.
