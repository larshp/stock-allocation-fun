CLASS zcl_alloc_seasonal DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_series_tt TYPE STANDARD TABLE OF menge_d WITH DEFAULT KEY.
    TYPES ty_index_tt  TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_result,
             index   TYPE ty_index_tt,
             overall TYPE menge_d,
           END OF ty_result.

    METHODS index
      IMPORTING
        it_series        TYPE ty_series_tt
        iv_period        TYPE i
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_seasonal IMPLEMENTATION.

  METHOD index.
    DATA lv_period  TYPE i.
    DATA lv_count   TYPE i.
    DATA lv_pos     TYPE i.
    DATA lv_season  TYPE i.
    DATA lv_sum_all TYPE menge_d.
    DATA lv_sum     TYPE menge_d.
    DATA lv_hits    TYPE i.
    DATA lv_avg     TYPE menge_d.

    lv_period = iv_period.
    lv_count = lines( it_series ).

    IF lv_period <= 0 OR lv_count = 0.
      RETURN.
    ENDIF.

    LOOP AT it_series INTO DATA(lv_value).
      lv_sum_all = lv_sum_all + lv_value.
    ENDLOOP.

    rs_result-overall = lv_sum_all DIV lv_count.

    lv_season = 1.
    WHILE lv_season <= lv_period.
      CLEAR lv_sum.
      CLEAR lv_hits.
      lv_pos = 0.

      LOOP AT it_series INTO lv_value.
        lv_pos = lv_pos + 1.
        IF ( lv_pos - 1 ) MOD lv_period + 1 <> lv_season.
          CONTINUE.
        ENDIF.

        lv_sum = lv_sum + lv_value.
        lv_hits = lv_hits + 1.
      ENDLOOP.

      IF lv_hits > 0 AND rs_result-overall <> 0.
        lv_avg = lv_sum DIV lv_hits.
        APPEND lv_avg * 100 DIV rs_result-overall TO rs_result-index.
      ELSE.
        APPEND 0 TO rs_result-index.
      ENDIF.

      lv_season = lv_season + 1.
    ENDWHILE.
  ENDMETHOD.

ENDCLASS.
