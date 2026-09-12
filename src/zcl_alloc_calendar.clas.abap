CLASS zcl_alloc_calendar DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             start_date TYPE d,
             days       TYPE i,
           END OF ty_input.

    METHODS add_working_days
      IMPORTING
        is_input       TYPE ty_input
      RETURNING
        VALUE(rv_date) TYPE d.

    METHODS is_weekend
      IMPORTING
        iv_date           TYPE d
      RETURNING
        VALUE(rv_weekend) TYPE abap_bool.

  PRIVATE SECTION.
    METHODS next_day
      IMPORTING
        iv_date        TYPE d
      RETURNING
        VALUE(rv_date) TYPE d.

    METHODS days_in_month
      IMPORTING
        iv_year        TYPE i
        iv_month       TYPE i
      RETURNING
        VALUE(rv_days) TYPE i.

    METHODS pad_num
      IMPORTING
        iv_value       TYPE i
        iv_width       TYPE i
      RETURNING
        VALUE(rv_text) TYPE string.

ENDCLASS.


CLASS zcl_alloc_calendar IMPLEMENTATION.

  METHOD pad_num.
    DATA lv_text  TYPE string.
    DATA lv_zeros TYPE i.

    lv_text = |{ iv_value }|.

    IF strlen( lv_text ) < iv_width.
      lv_zeros = iv_width - strlen( lv_text ).
      WHILE lv_zeros > 0.
        lv_text = '0' && lv_text.
        lv_zeros = lv_zeros - 1.
      ENDWHILE.
    ENDIF.

    rv_text = lv_text.
  ENDMETHOD.

  METHOD days_in_month.
    DATA lv_leap TYPE abap_bool.

    CASE iv_month.
      WHEN 1 OR 3 OR 5 OR 7 OR 8 OR 10 OR 12.
        rv_days = 31.
      WHEN 4 OR 6 OR 9 OR 11.
        rv_days = 30.
      WHEN 2.
        lv_leap = abap_false.
        IF iv_year MOD 4 = 0.
          lv_leap = abap_true.
        ENDIF.
        IF iv_year MOD 100 = 0 AND iv_year MOD 400 <> 0.
          lv_leap = abap_false.
        ENDIF.
        IF lv_leap = abap_true.
          rv_days = 29.
        ELSE.
          rv_days = 28.
        ENDIF.
    ENDCASE.
  ENDMETHOD.

  METHOD next_day.
    DATA lv_year TYPE i.
    DATA lv_month TYPE i.
    DATA lv_day TYPE i.
    DATA lv_max TYPE i.
    DATA lv_text TYPE string.
    DATA lv_part TYPE string.

    lv_year = iv_date+0(4).
    lv_month = iv_date+4(2).
    lv_day = iv_date+6(2).

    lv_max = days_in_month( iv_year  = lv_year
                            iv_month = lv_month ).

    lv_day = lv_day + 1.
    IF lv_day > lv_max.
      lv_day = 1.
      lv_month = lv_month + 1.
      IF lv_month > 12.
        lv_month = 1.
        lv_year = lv_year + 1.
      ENDIF.
    ENDIF.

    lv_part = pad_num( iv_value = lv_year
                       iv_width = 4 ).
    lv_text = lv_part.
    lv_part = pad_num( iv_value = lv_month
                       iv_width = 2 ).
    lv_text = lv_text && lv_part.
    lv_part = pad_num( iv_value = lv_day
                       iv_width = 2 ).
    lv_text = lv_text && lv_part.

    rv_date = lv_text.
  ENDMETHOD.

  METHOD is_weekend.
    DATA lv_year  TYPE i.
    DATA lv_month TYPE i.
    DATA lv_day   TYPE i.
    DATA lv_y     TYPE i.
    DATA lv_m     TYPE i.
    DATA lv_k     TYPE i.
    DATA lv_j     TYPE i.
    DATA lv_h     TYPE i.

    " Zeller's congruence: h = 0 is Saturday, 1 is Sunday
    lv_year = iv_date+0(4).
    lv_month = iv_date+4(2).
    lv_day = iv_date+6(2).

    lv_y = lv_year.
    lv_m = lv_month.
    IF lv_m <= 2.
      lv_m = lv_m + 12.
      lv_y = lv_y - 1.
    ENDIF.

    lv_k = lv_y MOD 100.
    lv_j = lv_y DIV 100.

    lv_h = ( lv_day + ( 13 * ( lv_m + 1 ) ) DIV 5 + lv_k
      + lv_k DIV 4 + lv_j DIV 4 + 5 * lv_j ) MOD 7.

    IF lv_h = 0 OR lv_h = 1.
      rv_weekend = abap_true.
    ELSE.
      rv_weekend = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD add_working_days.
    DATA lv_date  TYPE d.
    DATA lv_added TYPE i.

    lv_date = is_input-start_date.

    IF is_input-days <= 0.
      rv_date = lv_date.
      RETURN.
    ENDIF.

    WHILE lv_added < is_input-days.
      lv_date = next_day( lv_date ).
      IF is_weekend( lv_date ) = abap_false.
        lv_added = lv_added + 1.
      ENDIF.
    ENDWHILE.

    rv_date = lv_date.
  ENDMETHOD.

ENDCLASS.
