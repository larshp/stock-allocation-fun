CLASS zcl_date_validation DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    CLASS-METHODS is_valid_gregorian_date
      IMPORTING
        iv_date            TYPE d
      RETURNING
        VALUE(rv_is_valid) TYPE abap_bool.
    CLASS-METHODS is_valid_time
      IMPORTING
        iv_time            TYPE t
      RETURNING
        VALUE(rv_is_valid) TYPE abap_bool.
ENDCLASS.

CLASS zcl_date_validation IMPLEMENTATION.

  METHOD is_valid_gregorian_date.
    IF iv_date IS INITIAL
        OR iv_date CN '0123456789'.
      RETURN.
    ENDIF.

    DATA(lv_year) = CONV i( iv_date+0(4) ).
    DATA(lv_month) = CONV i( iv_date+4(2) ).
    DATA(lv_day) = CONV i( iv_date+6(2) ).
    DATA(lv_max_day) = 0.

    IF lv_year = 0.
      RETURN.
    ENDIF.

    CASE lv_month.
      WHEN 1 OR 3 OR 5 OR 7 OR 8 OR 10 OR 12.
        lv_max_day = 31.
      WHEN 4 OR 6 OR 9 OR 11.
        lv_max_day = 30.
      WHEN 2.
        lv_max_day = 28.
        IF lv_year MOD 400 = 0
            OR ( lv_year MOD 4 = 0 AND lv_year MOD 100 <> 0 ).
          lv_max_day = 29.
        ENDIF.
      WHEN OTHERS.
        RETURN.
    ENDCASE.

    IF lv_day < 1 OR lv_day > lv_max_day.
      RETURN.
    ENDIF.

    rv_is_valid = abap_true.
  ENDMETHOD.

  METHOD is_valid_time.
    IF iv_time+0(2) CN '0123456789'
        OR iv_time+2(2) CN '0123456789'
        OR iv_time+4(2) CN '0123456789'.
      RETURN.
    ENDIF.

    DATA(lv_hours) = CONV i( iv_time+0(2) ).
    DATA(lv_minutes) = CONV i( iv_time+2(2) ).
    DATA(lv_seconds) = CONV i( iv_time+4(2) ).

    IF lv_hours > 23 OR lv_minutes > 59 OR lv_seconds > 59.
      RETURN.
    ENDIF.

    rv_is_valid = abap_true.
  ENDMETHOD.

ENDCLASS.
