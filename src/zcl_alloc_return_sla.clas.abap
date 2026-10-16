CLASS zcl_alloc_return_sla DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_hours_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS is_met
      IMPORTING
        iv_elapsed_hours TYPE i
        iv_target_hours  TYPE i
      RETURNING
        VALUE(rv_ok)     TYPE abap_bool.

    METHODS elapsed_hours
      IMPORTING
        iv_start_day    TYPE d
        iv_end_day      TYPE d
      RETURNING
        VALUE(rv_hours) TYPE i.

    METHODS breach_count
      IMPORTING
        it_elapsed      TYPE ty_hours_tt
        iv_target       TYPE i
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_return_sla IMPLEMENTATION.

  METHOD is_met.
    " The service level is met when the elapsed time is within the target.
    rv_ok = xsdbool( iv_target_hours > 0
                     AND iv_elapsed_hours >= 0
                     AND iv_elapsed_hours <= iv_target_hours ).
  ENDMETHOD.

  METHOD elapsed_hours.
    " Each day between the start and end day counts as twenty-four hours.
    IF iv_start_day IS INITIAL OR iv_end_day IS INITIAL.
      RETURN.
    ENDIF.

    IF iv_end_day < iv_start_day.
      RETURN.
    ENDIF.

    rv_hours = ( iv_end_day - iv_start_day ) * 24.
  ENDMETHOD.

  METHOD breach_count.
    LOOP AT it_elapsed INTO DATA(lv_elapsed).
      IF lv_elapsed > iv_target.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
