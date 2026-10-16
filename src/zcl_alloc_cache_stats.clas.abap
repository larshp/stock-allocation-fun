CLASS zcl_alloc_cache_stats DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS note_hit.

    METHODS note_miss.

    METHODS hits
      RETURNING
        VALUE(rv_hits) TYPE i.

    METHODS misses
      RETURNING
        VALUE(rv_misses) TYPE i.

    METHODS hit_rate
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS reset.

  PRIVATE SECTION.
    DATA mv_hits   TYPE i.
    DATA mv_misses TYPE i.

ENDCLASS.


CLASS zcl_alloc_cache_stats IMPLEMENTATION.

  METHOD note_hit.
    mv_hits = mv_hits + 1.
  ENDMETHOD.

  METHOD note_miss.
    mv_misses = mv_misses + 1.
  ENDMETHOD.

  METHOD hits.
    rv_hits = mv_hits.
  ENDMETHOD.

  METHOD misses.
    rv_misses = mv_misses.
  ENDMETHOD.

  METHOD hit_rate.
    DATA lv_total TYPE i.

    lv_total = mv_hits + mv_misses.

    IF lv_total = 0.
      rv_percent = 0.
    ELSE.
      rv_percent = ( mv_hits * 100 ) DIV lv_total.
    ENDIF.
  ENDMETHOD.

  METHOD reset.
    mv_hits = 0.
    mv_misses = 0.
  ENDMETHOD.

ENDCLASS.
