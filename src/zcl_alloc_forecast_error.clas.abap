CLASS zcl_alloc_forecast_error DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS error
      IMPORTING
        iv_actual       TYPE i
        iv_forecast     TYPE i
      RETURNING
        VALUE(rv_error) TYPE i.

    METHODS error_percent
      IMPORTING
        iv_actual     TYPE i
        iv_forecast   TYPE i
      RETURNING
        VALUE(rv_pct) TYPE i.

    METHODS within_tolerance
      IMPORTING
        iv_actual    TYPE i
        iv_forecast  TYPE i
        iv_tolerance TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

  PRIVATE SECTION.
    METHODS abs_error
      IMPORTING
        iv_actual       TYPE i
        iv_forecast     TYPE i
      RETURNING
        VALUE(rv_error) TYPE i.

ENDCLASS.


CLASS zcl_alloc_forecast_error IMPLEMENTATION.

  METHOD error.
    " A positive error means the forecast was too low.
    rv_error = iv_actual - iv_forecast.
  ENDMETHOD.

  METHOD abs_error.
    DATA lv_error TYPE i.

    lv_error = error( iv_actual   = iv_actual
                      iv_forecast = iv_forecast ).

    " The absolute error is measured without the ABS built-in.
    IF lv_error < 0.
      rv_error = 0 - lv_error.
    ELSE.
      rv_error = lv_error.
    ENDIF.
  ENDMETHOD.

  METHOD error_percent.
    " The percentage error relates the absolute error to the actual demand.
    IF iv_actual <= 0.
      RETURN.
    ENDIF.

    rv_pct = abs_error( iv_actual   = iv_actual
                        iv_forecast = iv_forecast ) * 100 DIV iv_actual.
  ENDMETHOD.

  METHOD within_tolerance.
    " A forecast is within tolerance when the absolute error does not exceed it.
    rv_ok = xsdbool( iv_tolerance >= 0
                     AND abs_error( iv_actual   = iv_actual
                                    iv_forecast = iv_forecast ) <= iv_tolerance ).
  ENDMETHOD.

ENDCLASS.
