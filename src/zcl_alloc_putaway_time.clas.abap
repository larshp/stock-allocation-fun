CLASS zcl_alloc_putaway_time DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS total_minutes
      IMPORTING
        iv_tasks            TYPE i
        iv_minutes_per_task TYPE i
        iv_travel_minutes   TYPE i
      RETURNING
        VALUE(rv_min)       TYPE i.

    METHODS per_task
      IMPORTING
        iv_tasks            TYPE i
        iv_minutes_per_task TYPE i
        iv_travel_minutes   TYPE i
      RETURNING
        VALUE(rv_avg)       TYPE i.

    METHODS is_within
      IMPORTING
        iv_minutes   TYPE i
        iv_target    TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_putaway_time IMPLEMENTATION.

  METHOD total_minutes.
    " The travel time is paid once per trip, not once per task.
    IF iv_tasks <= 0.
      RETURN.
    ENDIF.

    rv_min = iv_travel_minutes + iv_tasks * iv_minutes_per_task.

    IF rv_min < 0.
      CLEAR rv_min.
    ENDIF.
  ENDMETHOD.

  METHOD per_task.
    DATA lv_total TYPE i.

    IF iv_tasks <= 0.
      RETURN.
    ENDIF.

    lv_total = total_minutes( iv_tasks            = iv_tasks
                              iv_minutes_per_task = iv_minutes_per_task
                              iv_travel_minutes   = iv_travel_minutes ).
    rv_avg = lv_total DIV iv_tasks.
  ENDMETHOD.

  METHOD is_within.
    rv_ok = xsdbool( iv_target > 0 AND iv_minutes <= iv_target ).
  ENDMETHOD.

ENDCLASS.
