CLASS zcl_alloc_drv_trend DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS direction
      IMPORTING
        iv_previous   TYPE i
        iv_current    TYPE i
      RETURNING
        VALUE(rv_dir) TYPE string.

    METHODS is_rising
      IMPORTING
        iv_previous  TYPE i
        iv_current   TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS delta
      IMPORTING
        iv_previous     TYPE i
        iv_current      TYPE i
      RETURNING
        VALUE(rv_delta) TYPE i.

ENDCLASS.


CLASS zcl_alloc_drv_trend IMPLEMENTATION.

  METHOD direction.
    " The trend reads up, down or flat from two driver quantities.
    IF iv_current > iv_previous.
      rv_dir = 'UP'.
    ELSEIF iv_current < iv_previous.
      rv_dir = 'DOWN'.
    ELSE.
      rv_dir = 'FLAT'.
    ENDIF.
  ENDMETHOD.

  METHOD is_rising.
    " The driver is rising once the new quantity is higher.
    rv_ok = xsdbool( iv_current > iv_previous ).
  ENDMETHOD.

  METHOD delta.
    " The move is the current quantity less the previous one.
    rv_delta = iv_current - iv_previous.
  ENDMETHOD.

ENDCLASS.
