CLASS zcl_alloc_unload_time DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS estimate
      IMPORTING
        iv_units            TYPE i
        iv_items            TYPE i
        iv_seconds_per_unit TYPE i
        iv_seconds_per_item TYPE i
        iv_fixed            TYPE i
      RETURNING
        VALUE(rv_seconds)   TYPE i.

    METHODS hours
      IMPORTING
        iv_seconds      TYPE i
      RETURNING
        VALUE(rv_hours) TYPE i.

ENDCLASS.


CLASS zcl_alloc_unload_time IMPLEMENTATION.

  METHOD estimate.
    " Unloading has two rates: one per handling unit moved off the trailer and one
    " per item unpacked afterwards. A load with neither takes only the fixed time.
    rv_seconds = iv_fixed
              + iv_units * iv_seconds_per_unit
              + iv_items * iv_seconds_per_item.

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

ENDCLASS.
