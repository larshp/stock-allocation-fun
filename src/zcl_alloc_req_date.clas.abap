CLASS zcl_alloc_req_date DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS date_of
      IMPORTING
        iv_requirement_date TYPE d
        iv_lead_days        TYPE i
      RETURNING
        VALUE(rv_date)      TYPE d.

    METHODS offset_date
      IMPORTING
        iv_date        TYPE d
        iv_days        TYPE i
      RETURNING
        VALUE(rv_date) TYPE d.

    METHODS is_late
      IMPORTING
        iv_order_date       TYPE d
        iv_requirement_date TYPE d
      RETURNING
        VALUE(rv_ok)        TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_req_date IMPLEMENTATION.

  METHOD date_of.
    DATA lo_window TYPE REF TO zcl_alloc_return_window.

    " The planned order date sits the lead time before the requirement date.
    IF iv_requirement_date IS INITIAL OR iv_lead_days <= 0.
      rv_date = iv_requirement_date.
      RETURN.
    ENDIF.

    lo_window = NEW zcl_alloc_return_window( ).
    rv_date = lo_window->subtract_days( iv_date = iv_requirement_date
                                        iv_days = iv_lead_days ).
  ENDMETHOD.

  METHOD offset_date.
    DATA lo_window TYPE REF TO zcl_alloc_return_window.

    " A positive offset moves the date forward.
    IF iv_date IS INITIAL OR iv_days <= 0.
      rv_date = iv_date.
      RETURN.
    ENDIF.

    lo_window = NEW zcl_alloc_return_window( ).
    rv_date = lo_window->add_days( iv_date = iv_date
                                   iv_days = iv_days ).
  ENDMETHOD.

  METHOD is_late.
    " The order is late once it sits after the requirement date.
    IF iv_order_date IS INITIAL OR iv_requirement_date IS INITIAL.
      RETURN.
    ENDIF.

    rv_ok = xsdbool( iv_order_date > iv_requirement_date ).
  ENDMETHOD.

ENDCLASS.
