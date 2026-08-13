CLASS zcl_allocation_time_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS is_valid_or_initial
      IMPORTING
        iv_time         TYPE t
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.
ENDCLASS.

CLASS zcl_allocation_time_sap IMPLEMENTATION.
  METHOD is_valid_or_initial.
    DATA lv_hour TYPE i.
    DATA lv_minute TYPE i.
    DATA lv_second TYPE i.

    rv_valid = abap_false.
    IF iv_time IS INITIAL.
      rv_valid = abap_true.
      RETURN.
    ENDIF.
    IF strlen( iv_time ) <> 6 OR iv_time CN '0123456789'.
      RETURN.
    ENDIF.

    lv_hour = iv_time(2).
    lv_minute = iv_time+2(2).
    lv_second = iv_time+4(2).
    IF lv_hour <= 23
        AND lv_minute <= 59
        AND lv_second <= 59.
      rv_valid = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
