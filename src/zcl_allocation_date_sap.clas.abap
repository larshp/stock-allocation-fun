CLASS zcl_allocation_date_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS is_valid_or_initial
      IMPORTING
        iv_date         TYPE d
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.
    CLASS-METHODS can_add_days
      IMPORTING
        iv_date           TYPE d
        iv_days           TYPE i
      RETURNING
        VALUE(rv_can_add) TYPE abap_bool.
ENDCLASS.

CLASS zcl_allocation_date_sap IMPLEMENTATION.
  METHOD is_valid_or_initial.
    DATA lv_year TYPE i.
    DATA lv_month TYPE i.
    DATA lv_day TYPE i.
    DATA lv_days TYPE i.
    DATA lv_leap TYPE abap_bool.

    rv_valid = abap_false.
    IF iv_date IS INITIAL.
      rv_valid = abap_true.
      RETURN.
    ENDIF.
    IF strlen( iv_date ) <> 8 OR iv_date CN '0123456789'.
      RETURN.
    ENDIF.

    lv_year = iv_date(4).
    lv_month = iv_date+4(2).
    lv_day = iv_date+6(2).
    IF lv_year = 0 OR lv_month < 1 OR lv_month > 12 OR lv_day < 1.
      RETURN.
    ENDIF.

    IF lv_year MOD 400 = 0
        OR ( lv_year MOD 4 = 0 AND lv_year MOD 100 <> 0 ).
      lv_leap = abap_true.
    ENDIF.
    CASE lv_month.
      WHEN 2.
        lv_days = 28.
        IF lv_leap = abap_true.
          lv_days = 29.
        ENDIF.
      WHEN 4 OR 6 OR 9 OR 11.
        lv_days = 30.
      WHEN OTHERS.
        lv_days = 31.
    ENDCASE.
    IF lv_day <= lv_days.
      rv_valid = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD can_add_days.
    DATA lv_last_supported_date TYPE d VALUE '99991231'.
    DATA lv_maximum_days TYPE i.

    rv_can_add = abap_false.
    IF iv_days < 0
        OR iv_date IS INITIAL
        OR is_valid_or_initial( iv_date ) <> abap_true.
      RETURN.
    ENDIF.

    lv_maximum_days = lv_last_supported_date - iv_date.
    IF iv_days <= lv_maximum_days.
      rv_can_add = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
