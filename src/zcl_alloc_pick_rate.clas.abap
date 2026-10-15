CLASS zcl_alloc_pick_rate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS per_hour
      IMPORTING
        iv_lines       TYPE i
        iv_minutes     TYPE i
      RETURNING
        VALUE(rv_rate) TYPE i.

    METHODS per_minute
      IMPORTING
        iv_lines       TYPE i
        iv_minutes     TYPE i
      RETURNING
        VALUE(rv_rate) TYPE i.

    METHODS minutes_for
      IMPORTING
        iv_lines          TYPE i
        iv_rate_per_hour  TYPE i
      RETURNING
        VALUE(rv_minutes) TYPE i.

ENDCLASS.


CLASS zcl_alloc_pick_rate IMPLEMENTATION.

  METHOD per_hour.
    IF iv_lines < 0 OR iv_minutes <= 0.
      RETURN.
    ENDIF.

    rv_rate = iv_lines * 60 DIV iv_minutes.
  ENDMETHOD.

  METHOD per_minute.
    IF iv_lines < 0 OR iv_minutes <= 0.
      RETURN.
    ENDIF.

    rv_rate = iv_lines DIV iv_minutes.
  ENDMETHOD.

  METHOD minutes_for.
    IF iv_lines <= 0 OR iv_rate_per_hour <= 0.
      RETURN.
    ENDIF.

    rv_minutes = iv_lines * 60 DIV iv_rate_per_hour.
  ENDMETHOD.

ENDCLASS.
