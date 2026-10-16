CLASS zcl_alloc_retention DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        iv_retention_days TYPE i DEFAULT 365.

    METHODS is_expired
      IMPORTING
        iv_archived_on    TYPE d
        iv_reference      TYPE d
      RETURNING
        VALUE(rv_expired) TYPE abap_bool.

    METHODS days_left
      IMPORTING
        iv_archived_on TYPE d
        iv_reference   TYPE d
      RETURNING
        VALUE(rv_days) TYPE i.

    METHODS get_retention_days
      RETURNING
        VALUE(rv_days) TYPE i.

  PRIVATE SECTION.
    DATA mv_retention_days TYPE i.

    METHODS to_day_number
      IMPORTING
        iv_date        TYPE d
      RETURNING
        VALUE(rv_days) TYPE i.

    METHODS age_days
      IMPORTING
        iv_archived_on TYPE d
        iv_reference   TYPE d
      RETURNING
        VALUE(rv_days) TYPE i.

ENDCLASS.


CLASS zcl_alloc_retention IMPLEMENTATION.

  METHOD constructor.
    IF iv_retention_days < 0.
      mv_retention_days = 0.
    ELSE.
      mv_retention_days = iv_retention_days.
    ENDIF.
  ENDMETHOD.

  METHOD get_retention_days.
    rv_days = mv_retention_days.
  ENDMETHOD.

  METHOD to_day_number.
    DATA lv_year  TYPE i.
    DATA lv_month TYPE i.
    DATA lv_day   TYPE i.
    DATA lv_a     TYPE i.
    DATA lv_y     TYPE i.
    DATA lv_m     TYPE i.

    lv_year = iv_date+0(4).
    lv_month = iv_date+4(2).
    lv_day = iv_date+6(2).

    lv_a = ( 14 - lv_month ) DIV 12.
    lv_y = lv_year + 4800 - lv_a.
    lv_m = lv_month + 12 * lv_a - 3.

    rv_days = lv_day + ( 153 * lv_m + 2 ) DIV 5 + 365 * lv_y.
    rv_days = rv_days + lv_y DIV 4.
    rv_days = rv_days - lv_y DIV 100.
    rv_days = rv_days + lv_y DIV 400.
    rv_days = rv_days - 32045.
  ENDMETHOD.

  METHOD age_days.
    DATA lv_from TYPE i.
    DATA lv_to   TYPE i.

    lv_from = me->to_day_number( iv_archived_on ).
    lv_to = me->to_day_number( iv_reference ).

    rv_days = lv_to - lv_from.

    IF rv_days < 0.
      rv_days = 0.
    ENDIF.
  ENDMETHOD.

  METHOD is_expired.
    DATA lv_age TYPE i.

    lv_age = me->age_days( iv_archived_on = iv_archived_on iv_reference = iv_reference ).

    IF lv_age >= mv_retention_days.
      rv_expired = abap_true.
    ELSE.
      rv_expired = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD days_left.
    DATA lv_age TYPE i.

    lv_age = me->age_days( iv_archived_on = iv_archived_on iv_reference = iv_reference ).

    rv_days = mv_retention_days - lv_age.

    IF rv_days < 0.
      rv_days = 0.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
