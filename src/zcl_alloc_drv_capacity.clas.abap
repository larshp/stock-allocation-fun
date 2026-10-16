CLASS zcl_alloc_drv_capacity DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS capacity
      IMPORTING
        iv_used           TYPE i
        iv_available      TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS is_over
      IMPORTING
        iv_used      TYPE i
        iv_available TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS spare
      IMPORTING
        iv_used         TYPE i
        iv_available    TYPE i
      RETURNING
        VALUE(rv_spare) TYPE i.

ENDCLASS.


CLASS zcl_alloc_drv_capacity IMPLEMENTATION.

  METHOD capacity.
    " The capacity used is the load as a share of what is available.
    IF iv_available <= 0.
      RETURN.
    ENDIF.

    rv_percent = iv_used * 100 DIV iv_available.
  ENDMETHOD.

  METHOD is_over.
    " The driver is over capacity once the load passes what is available.
    rv_ok = xsdbool( iv_used > iv_available ).
  ENDMETHOD.

  METHOD spare.
    " The spare capacity is what is left once the load is taken off.
    IF iv_used >= iv_available.
      RETURN.
    ENDIF.

    rv_spare = iv_available - iv_used.
  ENDMETHOD.

ENDCLASS.
