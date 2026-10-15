CLASS zcl_alloc_disposal_time DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS lead_days
      IMPORTING
        iv_base_days     TYPE i
        iv_quantity      TYPE i
        iv_per_unit_days TYPE i
      RETURNING
        VALUE(rv_days)   TYPE i.

    METHODS is_urgent
      IMPORTING
        iv_days      TYPE i
        iv_limit     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS planned_day
      IMPORTING
        iv_start      TYPE d
        iv_days       TYPE i
      RETURNING
        VALUE(rv_day) TYPE d.

ENDCLASS.


CLASS zcl_alloc_disposal_time IMPLEMENTATION.

  METHOD lead_days.
    " The lead time is a fixed part plus a per-unit part; a negative input leaves
    " the lead time unknown.
    IF iv_base_days < 0 OR iv_quantity < 0 OR iv_per_unit_days < 0.
      RETURN.
    ENDIF.

    rv_days = iv_base_days + iv_quantity * iv_per_unit_days.
  ENDMETHOD.

  METHOD is_urgent.
    " A disposal is urgent when the lead time is within the allowed window.
    rv_ok = xsdbool( iv_limit > 0 AND iv_days >= 0 AND iv_days <= iv_limit ).
  ENDMETHOD.

  METHOD planned_day.
    DATA lo_window TYPE REF TO zcl_alloc_return_window.

    IF iv_start IS INITIAL OR iv_days < 0.
      RETURN.
    ENDIF.

    " The calendar walk for adding days is the one already built for the return
    " window, so it is reused.
    lo_window = NEW zcl_alloc_return_window( ).
    rv_day = lo_window->add_days( iv_date = iv_start
                                  iv_days = iv_days ).
  ENDMETHOD.

ENDCLASS.
