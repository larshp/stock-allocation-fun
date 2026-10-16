CLASS zcl_alloc_season_index DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_period,
             period TYPE i,
             value  TYPE i,
           END OF ty_period.
    TYPES ty_period_tt TYPE STANDARD TABLE OF ty_period WITH DEFAULT KEY.

    METHODS index_of
      IMPORTING
        it_periods      TYPE ty_period_tt
        iv_period       TYPE i
      RETURNING
        VALUE(rv_index) TYPE i.

    METHODS is_peak
      IMPORTING
        it_periods   TYPE ty_period_tt
        iv_period    TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS peak_period
      IMPORTING
        it_periods       TYPE ty_period_tt
      RETURNING
        VALUE(rv_period) TYPE i.

  PRIVATE SECTION.
    METHODS average
      IMPORTING
        it_periods    TYPE ty_period_tt
      RETURNING
        VALUE(rv_avg) TYPE i.

ENDCLASS.


CLASS zcl_alloc_season_index IMPLEMENTATION.

  METHOD average.
    DATA lv_total TYPE i.
    DATA lv_count TYPE i.

    LOOP AT it_periods INTO DATA(ls_period).
      lv_total = lv_total + ls_period-value.
      lv_count = lv_count + 1.
    ENDLOOP.

    IF lv_count <= 0.
      RETURN.
    ENDIF.

    rv_avg = lv_total DIV lv_count.
  ENDMETHOD.

  METHOD index_of.
    DATA lv_avg   TYPE i.
    DATA lv_value TYPE i.

    lv_avg = average( it_periods ).
    IF lv_avg <= 0.
      RETURN.
    ENDIF.

    LOOP AT it_periods INTO DATA(ls_period).
      IF ls_period-period = iv_period.
        lv_value = ls_period-value.
        EXIT.
      ENDIF.
    ENDLOOP.

    " The seasonal index is the period's value over the average, in percent.
    rv_index = lv_value * 100 DIV lv_avg.
  ENDMETHOD.

  METHOD is_peak.
    rv_ok = xsdbool( index_of( it_periods = it_periods
                                iv_period = iv_period ) > 100 ).
  ENDMETHOD.

  METHOD peak_period.
    DATA lv_best  TYPE i.
    DATA lv_found TYPE abap_bool.

    LOOP AT it_periods INTO DATA(ls_period).
      IF lv_found = abap_false OR ls_period-value > lv_best.
        lv_found = abap_true.
        lv_best = ls_period-value.
        rv_period = ls_period-period.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
