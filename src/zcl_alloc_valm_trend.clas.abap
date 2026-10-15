CLASS zcl_alloc_valm_trend DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS direction
      IMPORTING
        iv_previous   TYPE i
        iv_current    TYPE i
      RETURNING
        VALUE(rv_dir) TYPE string.

    METHODS is_rising
      IMPORTING
        iv_previous  TYPE i
        iv_current   TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS streak
      IMPORTING
        it_values        TYPE ty_values_tt
      RETURNING
        VALUE(rv_streak) TYPE i.

ENDCLASS.


CLASS zcl_alloc_valm_trend IMPLEMENTATION.

  METHOD direction.
    " The trend reads up, down or flat from two values.
    IF iv_current > iv_previous.
      rv_dir = 'UP'.
    ELSEIF iv_current < iv_previous.
      rv_dir = 'DOWN'.
    ELSE.
      rv_dir = 'FLAT'.
    ENDIF.
  ENDMETHOD.

  METHOD is_rising.
    " The valuation is rising once the new one is higher.
    rv_ok = xsdbool( iv_current > iv_previous ).
  ENDMETHOD.

  METHOD streak.
    DATA lv_prev   TYPE i.
    DATA lv_first  TYPE abap_bool.

    " The streak is the run of rises at the end of the series.
    lv_first = abap_true.

    LOOP AT it_values INTO DATA(lv_value).
      IF lv_first = abap_true.
        lv_first = abap_false.
        lv_prev = lv_value.
        CONTINUE.
      ENDIF.

      IF lv_value > lv_prev.
        rv_streak = rv_streak + 1.
      ELSE.
        rv_streak = 0.
      ENDIF.

      lv_prev = lv_value.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
