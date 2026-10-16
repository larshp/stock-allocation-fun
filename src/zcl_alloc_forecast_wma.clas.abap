CLASS zcl_alloc_forecast_wma DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_period,
             value  TYPE i,
             weight TYPE i,
           END OF ty_period.
    TYPES ty_period_tt TYPE STANDARD TABLE OF ty_period WITH DEFAULT KEY.

    METHODS forecast
      IMPORTING
        it_periods         TYPE ty_period_tt
      RETURNING
        VALUE(rv_forecast) TYPE i.

    METHODS weight_sum
      IMPORTING
        it_periods    TYPE ty_period_tt
      RETURNING
        VALUE(rv_sum) TYPE i.

    METHODS periods
      IMPORTING
        it_periods      TYPE ty_period_tt
      RETURNING
        VALUE(rv_count) TYPE i.

  PRIVATE SECTION.
    METHODS weighted_total
      IMPORTING
        it_periods    TYPE ty_period_tt
      RETURNING
        VALUE(rv_sum) TYPE i.

    METHODS qualifies
      IMPORTING
        is_period    TYPE ty_period
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_forecast_wma IMPLEMENTATION.

  METHOD qualifies.
    " Only a period with both a demand and a weight contributes to the forecast.
    rv_ok = xsdbool( is_period-value > 0 AND is_period-weight > 0 ).
  ENDMETHOD.

  METHOD weighted_total.
    LOOP AT it_periods INTO DATA(ls_period).
      IF qualifies( ls_period ) = abap_true.
        rv_sum = rv_sum + ls_period-value * ls_period-weight.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD weight_sum.
    LOOP AT it_periods INTO DATA(ls_period).
      IF qualifies( ls_period ) = abap_true.
        rv_sum = rv_sum + ls_period-weight.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD periods.
    LOOP AT it_periods INTO DATA(ls_period).
      IF qualifies( ls_period ) = abap_true.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD forecast.
    DATA lv_weights TYPE i.

    lv_weights = weight_sum( it_periods ).

    " A forecast without any weight is left at zero.
    IF lv_weights <= 0.
      RETURN.
    ENDIF.

    rv_forecast = weighted_total( it_periods ) DIV lv_weights.
  ENDMETHOD.

ENDCLASS.
