CLASS zcl_alloc_warranty_check DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_warranty,
             material  TYPE matnr,
             start_day TYPE d,
             days      TYPE i,
           END OF ty_warranty.

    METHODS is_covered
      IMPORTING
        is_warranty  TYPE ty_warranty
        iv_check_day TYPE d
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS reason
      IMPORTING
        is_warranty      TYPE ty_warranty
        iv_check_day     TYPE d
      RETURNING
        VALUE(rv_reason) TYPE string.

    METHODS remaining_days
      IMPORTING
        is_warranty    TYPE ty_warranty
        iv_check_day   TYPE d
      RETURNING
        VALUE(rv_days) TYPE i.

  PRIVATE SECTION.
    METHODS age_days
      IMPORTING
        is_warranty    TYPE ty_warranty
        iv_check_day   TYPE d
      RETURNING
        VALUE(rv_days) TYPE i.

ENDCLASS.


CLASS zcl_alloc_warranty_check IMPLEMENTATION.

  METHOD age_days.
    IF is_warranty-start_day IS INITIAL OR iv_check_day IS INITIAL.
      RETURN.
    ENDIF.

    rv_days = iv_check_day - is_warranty-start_day.
  ENDMETHOD.

  METHOD is_covered.
    DATA lv_age TYPE i.

    IF is_warranty-start_day IS INITIAL OR iv_check_day IS INITIAL
        OR is_warranty-days <= 0.
      RETURN.
    ENDIF.

    lv_age = age_days( is_warranty  = is_warranty
                       iv_check_day = iv_check_day ).

    " The cover is inclusive on both ends of the warranty period.
    rv_ok = xsdbool( lv_age >= 0 AND lv_age <= is_warranty-days ).
  ENDMETHOD.

  METHOD reason.
    DATA lv_age TYPE i.

    IF is_warranty-start_day IS INITIAL OR iv_check_day IS INITIAL.
      RETURN.
    ENDIF.

    IF is_warranty-days <= 0.
      rv_reason = 'NO_WARRANTY'.
      RETURN.
    ENDIF.

    lv_age = age_days( is_warranty  = is_warranty
                       iv_check_day = iv_check_day ).

    IF lv_age < 0.
      rv_reason = 'NOT_STARTED'.
    ELSEIF lv_age > is_warranty-days.
      rv_reason = 'EXPIRED'.
    ELSE.
      rv_reason = 'COVERED'.
    ENDIF.
  ENDMETHOD.

  METHOD remaining_days.
    DATA lv_age TYPE i.

    IF is_warranty-start_day IS INITIAL OR iv_check_day IS INITIAL
        OR is_warranty-days <= 0.
      RETURN.
    ENDIF.

    lv_age = age_days( is_warranty  = is_warranty
                       iv_check_day = iv_check_day ).

    rv_days = is_warranty-days - lv_age.
  ENDMETHOD.

ENDCLASS.
