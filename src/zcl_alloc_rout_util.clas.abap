CLASS zcl_alloc_rout_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS utilisation_percent
      IMPORTING
        iv_used           TYPE i
        iv_available      TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS is_idle
      IMPORTING
        iv_used      TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS spare
      IMPORTING
        iv_available    TYPE i
        iv_used         TYPE i
      RETURNING
        VALUE(rv_spare) TYPE i.

ENDCLASS.


CLASS zcl_alloc_rout_util IMPLEMENTATION.

  METHOD utilisation_percent.
    " The utilisation is the used time as a share of the available time.
    IF iv_available = 0.
      RETURN.
    ENDIF.

    rv_percent = iv_used * 100 DIV iv_available.
  ENDMETHOD.

  METHOD is_idle.
    " The operation is idle once no time is used.
    rv_ok = xsdbool( iv_used <= 0 ).
  ENDMETHOD.

  METHOD spare.
    " The spare time left once the used time is taken off.
    IF iv_used >= iv_available.
      RETURN.
    ENDIF.

    rv_spare = iv_available - iv_used.
  ENDMETHOD.

ENDCLASS.
