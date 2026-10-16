CLASS zcl_alloc_rout_capacity DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS capacity
      IMPORTING
        iv_available       TYPE i
        iv_unit_time       TYPE i
      RETURNING
        VALUE(rv_capacity) TYPE i.

    METHODS is_over
      IMPORTING
        iv_required  TYPE i
        iv_capacity  TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS spare
      IMPORTING
        iv_capacity     TYPE i
        iv_required     TYPE i
      RETURNING
        VALUE(rv_spare) TYPE i.

ENDCLASS.


CLASS zcl_alloc_rout_capacity IMPLEMENTATION.

  METHOD capacity.
    " The capacity is the available time over the unit time.
    IF iv_unit_time <= 0.
      RETURN.
    ENDIF.

    rv_capacity = iv_available DIV iv_unit_time.
  ENDMETHOD.

  METHOD is_over.
    " The operation is over capacity once the demand passes it.
    rv_ok = xsdbool( iv_required > iv_capacity ).
  ENDMETHOD.

  METHOD spare.
    " The spare capacity left once the demand is taken off.
    IF iv_required >= iv_capacity.
      RETURN.
    ENDIF.

    rv_spare = iv_capacity - iv_required.
  ENDMETHOD.

ENDCLASS.
