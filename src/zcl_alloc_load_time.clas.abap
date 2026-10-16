CLASS zcl_alloc_load_time DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS estimate
      IMPORTING
        iv_items            TYPE i
        iv_seconds_per_item TYPE i
        iv_setup            TYPE i
      RETURNING
        VALUE(rv_seconds)   TYPE i.

    METHODS hours
      IMPORTING
        iv_seconds      TYPE i
      RETURNING
        VALUE(rv_hours) TYPE i.

    METHODS minutes
      IMPORTING
        iv_seconds        TYPE i
      RETURNING
        VALUE(rv_minutes) TYPE i.

ENDCLASS.


CLASS zcl_alloc_load_time IMPLEMENTATION.

  METHOD estimate.
    IF iv_items <= 0.
      RETURN.
    ENDIF.

    " The fixed setup happens once per load; a negative rate would shorten the
    " load and is treated as no progress.
    rv_seconds = iv_setup + iv_items * iv_seconds_per_item.

    IF rv_seconds < 0.
      CLEAR rv_seconds.
    ENDIF.
  ENDMETHOD.

  METHOD hours.
    IF iv_seconds <= 0.
      RETURN.
    ENDIF.

    rv_hours = iv_seconds DIV 3600.
  ENDMETHOD.

  METHOD minutes.
    IF iv_seconds <= 0.
      RETURN.
    ENDIF.

    rv_minutes = ( iv_seconds DIV 60 ) MOD 60.
  ENDMETHOD.

ENDCLASS.
