CLASS zcl_alloc_replenish_schedule DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS schedule
      IMPORTING
        iv_last_date   TYPE d
        iv_cycle_days  TYPE i
      RETURNING
        VALUE(rv_date) TYPE d.

    METHODS next_date
      IMPORTING
        iv_last_date   TYPE d
        iv_cycle_days  TYPE i
        iv_count       TYPE i
      RETURNING
        VALUE(rv_date) TYPE d.

    METHODS is_overdue
      IMPORTING
        iv_planned_date TYPE d
        iv_today        TYPE d
      RETURNING
        VALUE(rv_ok)    TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_replenish_schedule IMPLEMENTATION.

  METHOD schedule.
    DATA lo_window TYPE REF TO zcl_alloc_return_window.

    " The next run falls one cycle after the last one.
    IF iv_last_date IS INITIAL OR iv_cycle_days < 0.
      RETURN.
    ENDIF.

    lo_window = NEW zcl_alloc_return_window( ).
    rv_date = lo_window->add_days( iv_date = iv_last_date
                                   iv_days = iv_cycle_days ).
  ENDMETHOD.

  METHOD next_date.
    DATA lo_window TYPE REF TO zcl_alloc_return_window.
    DATA lv_days   TYPE i.

    " The nth run falls cycle times count days after the last one.
    IF iv_last_date IS INITIAL OR iv_cycle_days < 0 OR iv_count < 0.
      RETURN.
    ENDIF.

    lv_days = iv_cycle_days * iv_count.
    lo_window = NEW zcl_alloc_return_window( ).
    rv_date = lo_window->add_days( iv_date = iv_last_date
                                   iv_days = lv_days ).
  ENDMETHOD.

  METHOD is_overdue.
    " The plan is overdue while its day sits before today.
    IF iv_planned_date IS INITIAL OR iv_today IS INITIAL.
      RETURN.
    ENDIF.

    rv_ok = xsdbool( iv_planned_date < iv_today ).
  ENDMETHOD.

ENDCLASS.
