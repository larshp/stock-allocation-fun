CLASS zcl_alloc_gini DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_series_tt TYPE STANDARD TABLE OF menge_d WITH DEFAULT KEY.

    METHODS calculate
      IMPORTING
        it_values             TYPE ty_series_tt
      RETURNING
        VALUE(rv_gini_x10000) TYPE i.

ENDCLASS.


CLASS zcl_alloc_gini IMPLEMENTATION.

  METHOD calculate.
    DATA lt_values TYPE ty_series_tt.
    DATA lv_count  TYPE i.
    DATA lv_pos    TYPE i.
    DATA lv_sum    TYPE menge_d.
    DATA lv_weight TYPE menge_d.
    DATA lv_num    TYPE menge_d.
    DATA lv_den    TYPE menge_d.

    lt_values = it_values.
    SORT lt_values ASCENDING.

    lv_count = lines( lt_values ).
    IF lv_count = 0.
      RETURN.
    ENDIF.

    LOOP AT lt_values INTO DATA(lv_value).
      lv_pos = lv_pos + 1.
      lv_sum = lv_sum + lv_value.
      lv_weight = lv_weight + lv_pos * lv_value.
    ENDLOOP.

    IF lv_sum <= 0.
      RETURN.
    ENDIF.

    " Gini = 2 * sum(i * x_i) / (n * sum(x_i)) - (n + 1) / n, in ten-thousandths.
    lv_num = 2 * lv_weight * 10000.
    lv_den = lv_count * lv_sum.
    rv_gini_x10000 = lv_num DIV lv_den.
    rv_gini_x10000 = rv_gini_x10000 - ( lv_count + 1 ) * 10000 DIV lv_count.

    IF rv_gini_x10000 < 0.
      rv_gini_x10000 = 0.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
