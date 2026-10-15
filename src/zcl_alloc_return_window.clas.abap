CLASS zcl_alloc_return_window DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS expiry_day
      IMPORTING
        iv_receipt_day TYPE d
        iv_window_days TYPE i
      RETURNING
        VALUE(rv_day)  TYPE d.

    METHODS is_open
      IMPORTING
        iv_return_day  TYPE d
        iv_receipt_day TYPE d
        iv_window_days TYPE i
      RETURNING
        VALUE(rv_ok)   TYPE abap_bool.

    METHODS days_left
      IMPORTING
        iv_return_day  TYPE d
        iv_receipt_day TYPE d
        iv_window_days TYPE i
      RETURNING
        VALUE(rv_days) TYPE i.

    METHODS add_days
      IMPORTING
        iv_date        TYPE d
        iv_days        TYPE i
      RETURNING
        VALUE(rv_date) TYPE d.

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


CLASS zcl_alloc_return_window IMPLEMENTATION.

  METHOD expiry_day.
    IF iv_receipt_day IS INITIAL OR iv_window_days < 0.
      RETURN.
    ENDIF.

    rv_day = add_days( iv_date = iv_receipt_day
                       iv_days = iv_window_days ).
  ENDMETHOD.

  METHOD is_open.
    DATA lv_expiry TYPE d.

    " The window is inclusive: a return on the expiry day itself is still accepted.
    IF iv_window_days < 0 OR iv_receipt_day IS INITIAL
        OR iv_return_day IS INITIAL.
      RETURN.
    ENDIF.

    IF iv_return_day < iv_receipt_day.
      RETURN.
    ENDIF.

    lv_expiry = expiry_day( iv_receipt_day = iv_receipt_day
                            iv_window_days = iv_window_days ).
    rv_ok = xsdbool( iv_return_day <= lv_expiry ).
  ENDMETHOD.

  METHOD days_left.
    DATA lv_expiry TYPE d.

    IF iv_window_days < 0 OR iv_receipt_day IS INITIAL
        OR iv_return_day IS INITIAL.
      RETURN.
    ENDIF.

    lv_expiry = expiry_day( iv_receipt_day = iv_receipt_day
                            iv_window_days = iv_window_days ).
    rv_days = lv_expiry - iv_return_day.
  ENDMETHOD.

  METHOD add_days.
    DATA lv_step TYPE i.
    DATA lv_date TYPE d.

    lv_date = iv_date.

    WHILE lv_step < iv_days.
      lv_date = next_day( lv_date ).
      lv_step = lv_step + 1.
    ENDWHILE.

    rv_date = lv_date.
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

ENDCLASS.
