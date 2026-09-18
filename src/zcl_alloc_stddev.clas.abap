CLASS zcl_alloc_stddev DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_series_tt TYPE STANDARD TABLE OF menge_d WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_result,
             count         TYPE i,
             mean          TYPE menge_d,
             variance_x100 TYPE i,
             sd_x100       TYPE i,
           END OF ty_result.

    METHODS calculate
      IMPORTING
        it_values        TYPE ty_series_tt
      RETURNING
        VALUE(rs_result) TYPE ty_result.

    METHODS mean_of
      IMPORTING
        it_values      TYPE ty_series_tt
      RETURNING
        VALUE(rv_mean) TYPE menge_d.

  PRIVATE SECTION.
    METHODS root_of
      IMPORTING
        iv_value       TYPE i
      RETURNING
        VALUE(rv_root) TYPE i.

ENDCLASS.


CLASS zcl_alloc_stddev IMPLEMENTATION.

  METHOD root_of.
    DATA lv_try TYPE i.

    IF iv_value <= 0.
      RETURN.
    ENDIF.

    " Largest integer whose square does not exceed the input.
    lv_try = 1.
    WHILE lv_try * lv_try <= iv_value.
      lv_try = lv_try + 1.
    ENDWHILE.

    rv_root = lv_try - 1.
  ENDMETHOD.

  METHOD mean_of.
    DATA lv_count TYPE i.

    lv_count = lines( it_values ).
    IF lv_count = 0.
      RETURN.
    ENDIF.

    LOOP AT it_values INTO DATA(lv_value).
      rv_mean = rv_mean + lv_value.
    ENDLOOP.

    rv_mean = rv_mean DIV lv_count.
  ENDMETHOD.

  METHOD calculate.
    DATA lv_dev    TYPE menge_d.
    DATA lv_var    TYPE menge_d.
    DATA lv_scaled TYPE i.

    rs_result-count = lines( it_values ).
    IF rs_result-count = 0.
      RETURN.
    ENDIF.

    rs_result-mean = mean_of( it_values ).

    LOOP AT it_values INTO DATA(lv_value).
      lv_dev = lv_value - rs_result-mean.
      lv_var = lv_var + lv_dev * lv_dev.
    ENDLOOP.

    lv_var = lv_var DIV rs_result-count.

    rs_result-variance_x100 = lv_var * 100.

    " The deviation is scaled by 100 as well, so its square is scaled by 10000.
    lv_scaled = lv_var * 10000.
    rs_result-sd_x100 = root_of( iv_value = lv_scaled ).
  ENDMETHOD.

ENDCLASS.
