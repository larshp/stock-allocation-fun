CLASS zcl_alloc_rout_time DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS total_time
      IMPORTING
        iv_setup       TYPE i
        iv_run         TYPE i
        iv_qty         TYPE i
      RETURNING
        VALUE(rv_time) TYPE i.

    METHODS is_zero
      IMPORTING
        iv_time      TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS unit_time
      IMPORTING
        iv_total       TYPE i
        iv_qty         TYPE i
      RETURNING
        VALUE(rv_unit) TYPE i.

ENDCLASS.


CLASS zcl_alloc_rout_time IMPLEMENTATION.

  METHOD total_time.
    " The operation time is the setup plus the run at its quantity.
    rv_time = iv_setup + iv_run * iv_qty.
  ENDMETHOD.

  METHOD is_zero.
    " The operation takes no time at zero.
    rv_ok = xsdbool( iv_time = 0 ).
  ENDMETHOD.

  METHOD unit_time.
    " The time for one unit out of the whole operation time.
    IF iv_qty <= 0.
      RETURN.
    ENDIF.

    rv_unit = iv_total DIV iv_qty.
  ENDMETHOD.

ENDCLASS.
