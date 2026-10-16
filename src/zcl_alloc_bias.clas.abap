CLASS zcl_alloc_bias DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_series_tt TYPE STANDARD TABLE OF menge_d WITH DEFAULT KEY.

    METHODS errors_of
      IMPORTING
        it_forecast      TYPE zcl_alloc_mad=>ty_series_tt
        it_actual        TYPE zcl_alloc_mad=>ty_series_tt
      RETURNING
        VALUE(rt_errors) TYPE ty_series_tt.

    METHODS calculate
      IMPORTING
        it_forecast    TYPE zcl_alloc_mad=>ty_series_tt
        it_actual      TYPE zcl_alloc_mad=>ty_series_tt
      RETURNING
        VALUE(rv_bias) TYPE menge_d.

    METHODS direction
      IMPORTING
        it_forecast   TYPE zcl_alloc_mad=>ty_series_tt
        it_actual     TYPE zcl_alloc_mad=>ty_series_tt
      RETURNING
        VALUE(rv_dir) TYPE string.

ENDCLASS.


CLASS zcl_alloc_bias IMPLEMENTATION.

  METHOD errors_of.
    DATA lv_limit TYPE i.
    DATA lv_pos   TYPE i.

    lv_limit = lines( it_forecast ).
    IF lines( it_actual ) < lv_limit.
      lv_limit = lines( it_actual ).
    ENDIF.

    lv_pos = 0.
    WHILE lv_pos < lv_limit.
      lv_pos = lv_pos + 1.

      READ TABLE it_forecast INTO DATA(lv_fc) INDEX lv_pos.
      READ TABLE it_actual INTO DATA(lv_ac) INDEX lv_pos.

      APPEND lv_fc - lv_ac TO rt_errors.
    ENDWHILE.
  ENDMETHOD.

  METHOD calculate.
    DATA lt_errors TYPE ty_series_tt.
    DATA lv_sum    TYPE menge_d.
    DATA lv_count  TYPE i.

    lt_errors = errors_of( it_forecast = it_forecast
                           it_actual   = it_actual ).

    lv_count = lines( lt_errors ).
    IF lv_count = 0.
      RETURN.
    ENDIF.

    LOOP AT lt_errors INTO DATA(lv_error).
      lv_sum = lv_sum + lv_error.
    ENDLOOP.

    rv_bias = lv_sum DIV lv_count.
  ENDMETHOD.

  METHOD direction.
    DATA lv_bias TYPE menge_d.

    lv_bias = calculate( it_forecast = it_forecast
                         it_actual   = it_actual ).

    IF lv_bias > 0.
      rv_dir = 'over'.
    ELSEIF lv_bias < 0.
      rv_dir = 'under'.
    ELSE.
      rv_dir = 'unbiased'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
