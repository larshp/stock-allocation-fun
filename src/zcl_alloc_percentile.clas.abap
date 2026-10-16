CLASS zcl_alloc_percentile DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_series_tt TYPE STANDARD TABLE OF menge_d WITH DEFAULT KEY.

    METHODS rank_of
      IMPORTING
        it_values      TYPE ty_series_tt
        iv_pct         TYPE i
      RETURNING
        VALUE(rv_rank) TYPE i.

    METHODS value
      IMPORTING
        it_values       TYPE ty_series_tt
        iv_pct          TYPE i
      RETURNING
        VALUE(rv_value) TYPE menge_d.

ENDCLASS.


CLASS zcl_alloc_percentile IMPLEMENTATION.

  METHOD rank_of.
    DATA lv_count TYPE i.
    DATA lv_pct   TYPE i.
    DATA lv_rank  TYPE i.

    lv_count = lines( it_values ).
    IF lv_count = 0.
      RETURN.
    ENDIF.

    lv_pct = iv_pct.
    IF lv_pct < 0.
      lv_pct = 0.
    ENDIF.
    IF lv_pct > 100.
      lv_pct = 100.
    ENDIF.

    " Nearest rank: the smallest rank whose cumulative share reaches the
    " requested percentage, so the rank is never 0 and never past the end.
    lv_rank = ( lv_pct * lv_count + 99 ) DIV 100.
    IF lv_rank < 1.
      lv_rank = 1.
    ENDIF.
    IF lv_rank > lv_count.
      lv_rank = lv_count.
    ENDIF.

    rv_rank = lv_rank.
  ENDMETHOD.

  METHOD value.
    DATA lt_values TYPE ty_series_tt.
    DATA lv_rank   TYPE i.
    DATA lv_value  TYPE menge_d.

    lt_values = it_values.
    SORT lt_values ASCENDING.

    lv_rank = rank_of( it_values = lt_values iv_pct = iv_pct ).
    IF lv_rank = 0.
      RETURN.
    ENDIF.

    READ TABLE lt_values INTO lv_value INDEX lv_rank.
    rv_value = lv_value.
  ENDMETHOD.

ENDCLASS.
