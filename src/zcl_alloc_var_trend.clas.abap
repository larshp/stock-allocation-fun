CLASS zcl_alloc_var_trend DEFINITION
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

    METHODS is_improving
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


CLASS zcl_alloc_var_trend IMPLEMENTATION.

  METHOD direction.
    " A smaller variance than before is an improvement.
    IF iv_current < iv_previous.
      rv_dir = 'IMPROVING'.
    ELSEIF iv_current > iv_previous.
      rv_dir = 'WORSENING'.
    ELSE.
      rv_dir = 'FLAT'.
    ENDIF.
  ENDMETHOD.

  METHOD is_improving.
    " The variance improved once it moved below its previous level.
    rv_ok = xsdbool( iv_current < iv_previous ).
  ENDMETHOD.

  METHOD delta.
    " The move is the current variance less the previous one.
    rv_delta = iv_current - iv_previous.
  ENDMETHOD.

ENDCLASS.
