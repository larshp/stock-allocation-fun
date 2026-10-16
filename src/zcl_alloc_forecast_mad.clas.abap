CLASS zcl_alloc_forecast_mad DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS deviation
      IMPORTING
        it_actual           TYPE ty_values_tt
        it_forecast         TYPE ty_values_tt
      RETURNING
        VALUE(rv_deviation) TYPE i.

    METHODS per_period
      IMPORTING
        it_actual           TYPE ty_values_tt
        it_forecast         TYPE ty_values_tt
      RETURNING
        VALUE(rv_deviation) TYPE i.

    METHODS count
      IMPORTING
        it_actual       TYPE ty_values_tt
        it_forecast     TYPE ty_values_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_forecast_mad IMPLEMENTATION.

  METHOD count.
    DATA lv_actual   TYPE i.
    DATA lv_forecast TYPE i.

    lv_actual = lines( it_actual ).
    lv_forecast = lines( it_forecast ).

    " Only the periods present in both series are compared.
    IF lv_actual < lv_forecast.
      rv_count = lv_actual.
    ELSE.
      rv_count = lv_forecast.
    ENDIF.
  ENDMETHOD.

  METHOD deviation.
    DATA lv_index TYPE i.

    LOOP AT it_actual INTO DATA(lv_actual).
      lv_index = lv_index + 1.

      READ TABLE it_forecast INTO DATA(lv_forecast) INDEX lv_index.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.

      DATA(lv_diff) = lv_actual - lv_forecast.
      IF lv_diff < 0.
        lv_diff = 0 - lv_diff.
      ENDIF.

      rv_deviation = rv_deviation + lv_diff.
    ENDLOOP.
  ENDMETHOD.

  METHOD per_period.
    DATA lv_count TYPE i.

    lv_count = count( it_actual   = it_actual
                      it_forecast = it_forecast ).

    IF lv_count <= 0.
      RETURN.
    ENDIF.

    rv_deviation = deviation( it_actual   = it_actual
                              it_forecast = it_forecast ) DIV lv_count.
  ENDMETHOD.

ENDCLASS.
