CLASS zcl_alloc_valm_rate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS rate
      IMPORTING
        iv_previous    TYPE i
        iv_current     TYPE i
      RETURNING
        VALUE(rv_rate) TYPE i.

    METHODS is_spike
      IMPORTING
        iv_rate_percent  TYPE i
        iv_limit_percent TYPE i
      RETURNING
        VALUE(rv_ok)     TYPE abap_bool.

    METHODS direction
      IMPORTING
        iv_previous   TYPE i
        iv_current    TYPE i
      RETURNING
        VALUE(rv_dir) TYPE string.

ENDCLASS.


CLASS zcl_alloc_valm_rate IMPLEMENTATION.

  METHOD rate.
    " The change is related to the value it moved from.
    IF iv_previous = 0.
      RETURN.
    ENDIF.

    rv_rate = ( iv_current - iv_previous ) * 100 DIV iv_previous.
  ENDMETHOD.

  METHOD is_spike.
    " A spike is a change bigger than the allowed one either way.
    IF iv_rate_percent < 0.
      rv_ok = xsdbool( -1 * iv_rate_percent > iv_limit_percent ).
    ELSE.
      rv_ok = xsdbool( iv_rate_percent > iv_limit_percent ).
    ENDIF.
  ENDMETHOD.

  METHOD direction.
    " The direction names the way the valuation moved.
    IF iv_current > iv_previous.
      rv_dir = 'UP'.
    ELSEIF iv_current < iv_previous.
      rv_dir = 'DOWN'.
    ELSE.
      rv_dir = 'FLAT'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
