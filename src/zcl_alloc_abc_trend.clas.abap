CLASS zcl_alloc_abc_trend DEFINITION
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

    METHODS delta
      IMPORTING
        iv_previous     TYPE i
        iv_current      TYPE i
      RETURNING
        VALUE(rv_delta) TYPE i.

    METHODS is_rising
      IMPORTING
        iv_previous  TYPE i
        iv_current   TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_abc_trend IMPLEMENTATION.

  METHOD direction.
    " The trend reads up, down or flat from two activity costs.
    IF iv_current > iv_previous.
      rv_dir = 'UP'.
    ELSEIF iv_current < iv_previous.
      rv_dir = 'DOWN'.
    ELSE.
      rv_dir = 'FLAT'.
    ENDIF.
  ENDMETHOD.

  METHOD delta.
    " The move is the current cost less the previous one.
    rv_delta = iv_current - iv_previous.
  ENDMETHOD.

  METHOD is_rising.
    " The cost is rising once the new one is higher.
    rv_ok = xsdbool( iv_current > iv_previous ).
  ENDMETHOD.

ENDCLASS.
