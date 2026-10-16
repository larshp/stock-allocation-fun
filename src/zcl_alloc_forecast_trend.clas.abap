CLASS zcl_alloc_forecast_trend DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS slope_sign
      IMPORTING
        it_values      TYPE ty_values_tt
      RETURNING
        VALUE(rv_sign) TYPE i.

    METHODS project
      IMPORTING
        it_values       TYPE ty_values_tt
        iv_periods      TYPE i
      RETURNING
        VALUE(rv_value) TYPE i.

    METHODS is_rising
      IMPORTING
        it_values    TYPE ty_values_tt
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_forecast_trend IMPLEMENTATION.

  METHOD slope_sign.
    DATA lv_first TYPE i.
    DATA lv_last  TYPE i.
    DATA lv_count TYPE i.
    DATA lv_seen  TYPE abap_bool.

    " The slope sign compares the first and the last value of the series.
    LOOP AT it_values INTO DATA(lv_value).
      lv_count = lv_count + 1.
      lv_last = lv_value.
      IF lv_seen = abap_false.
        lv_seen = abap_true.
        lv_first = lv_value.
      ENDIF.
    ENDLOOP.

    IF lv_count < 2.
      RETURN.
    ENDIF.

    IF lv_last > lv_first.
      rv_sign = 1.
    ELSEIF lv_last < lv_first.
      rv_sign = -1.
    ENDIF.
  ENDMETHOD.

  METHOD project.
    DATA lv_first TYPE i.
    DATA lv_last  TYPE i.
    DATA lv_count TYPE i.
    DATA lv_seen  TYPE abap_bool.
    DATA lv_step  TYPE i.

    LOOP AT it_values INTO DATA(lv_value).
      lv_count = lv_count + 1.
      lv_last = lv_value.
      IF lv_seen = abap_false.
        lv_seen = abap_true.
        lv_first = lv_value.
      ENDIF.
    ENDLOOP.

    IF lv_count < 1.
      RETURN.
    ENDIF.

    " The step between periods is taken from the whole span.
    IF lv_count > 1.
      lv_step = ( lv_last - lv_first ) DIV ( lv_count - 1 ).
    ENDIF.

    rv_value = lv_last + lv_step * iv_periods.
  ENDMETHOD.

  METHOD is_rising.
    rv_ok = xsdbool( slope_sign( it_values ) > 0 ).
  ENDMETHOD.

ENDCLASS.
