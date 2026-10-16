CLASS zcl_alloc_schedule DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_dates_tt TYPE STANDARD TABLE OF d WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        iv_start_date    TYPE d
        iv_count         TYPE i
        iv_interval_days TYPE i
      RETURNING
        VALUE(rt_dates)  TYPE ty_dates_tt.

    METHODS dates
      IMPORTING
        iv_start_date    TYPE d
        iv_count         TYPE i
        iv_interval_days TYPE i
      RETURNING
        VALUE(rv_count)  TYPE i.

    METHODS is_on_time
      IMPORTING
        iv_actual_date  TYPE d
        iv_planned_date TYPE d
      RETURNING
        VALUE(rv_ok)    TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_schedule IMPLEMENTATION.

  METHOD build.
    DATA lo_window TYPE REF TO zcl_alloc_return_window.
    DATA lv_index  TYPE i.
    DATA lv_offset TYPE i.
    DATA lv_date   TYPE d.

    " A schedule of dates is stepped from the start date in fixed intervals.
    IF iv_start_date IS INITIAL OR iv_count <= 0.
      RETURN.
    ENDIF.

    lo_window = NEW zcl_alloc_return_window( ).

    WHILE lv_index < iv_count.
      lv_offset = lv_index * iv_interval_days.
      lv_date = lo_window->add_days( iv_date = iv_start_date
                                     iv_days = lv_offset ).
      APPEND lv_date TO rt_dates.
      lv_index = lv_index + 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD dates.
    " The date count is what was asked for, never negative.
    IF iv_count <= 0 OR iv_start_date IS INITIAL.
      RETURN.
    ENDIF.

    rv_count = iv_count.
  ENDMETHOD.

  METHOD is_on_time.
    " A delivery is on time when it does not sit after the planned date.
    IF iv_actual_date IS INITIAL OR iv_planned_date IS INITIAL.
      RETURN.
    ENDIF.

    rv_ok = xsdbool( iv_actual_date <= iv_planned_date ).
  ENDMETHOD.

ENDCLASS.
