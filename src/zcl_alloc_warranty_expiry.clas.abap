CLASS zcl_alloc_warranty_expiry DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_warranty,
             start_day TYPE d,
             days      TYPE i,
           END OF ty_warranty.

    METHODS expiry_day
      IMPORTING
        is_warranty   TYPE ty_warranty
      RETURNING
        VALUE(rv_day) TYPE d.

    METHODS has_expired
      IMPORTING
        is_warranty  TYPE ty_warranty
        iv_check_day TYPE d
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS days_left
      IMPORTING
        is_warranty    TYPE ty_warranty
        iv_check_day   TYPE d
      RETURNING
        VALUE(rv_days) TYPE i.

ENDCLASS.


CLASS zcl_alloc_warranty_expiry IMPLEMENTATION.

  METHOD expiry_day.
    DATA lo_window TYPE REF TO zcl_alloc_return_window.

    IF is_warranty-start_day IS INITIAL OR is_warranty-days < 0.
      RETURN.
    ENDIF.

    " The calendar walk needed to turn a start day and a duration into an end day
    " is the one already built for the return window, so it is reused.
    lo_window = NEW zcl_alloc_return_window( ).
    rv_day = lo_window->add_days( iv_date = is_warranty-start_day
                                  iv_days = is_warranty-days ).
  ENDMETHOD.

  METHOD has_expired.
    DATA lv_expiry TYPE d.

    lv_expiry = expiry_day( is_warranty ).

    IF lv_expiry IS INITIAL OR iv_check_day IS INITIAL.
      RETURN.
    ENDIF.

    rv_ok = xsdbool( iv_check_day > lv_expiry ).
  ENDMETHOD.

  METHOD days_left.
    DATA lv_expiry TYPE d.

    lv_expiry = expiry_day( is_warranty ).

    IF lv_expiry IS INITIAL OR iv_check_day IS INITIAL.
      RETURN.
    ENDIF.

    rv_days = lv_expiry - iv_check_day.
  ENDMETHOD.

ENDCLASS.
