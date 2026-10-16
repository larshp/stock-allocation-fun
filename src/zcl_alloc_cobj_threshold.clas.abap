CLASS zcl_alloc_cobj_threshold DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS is_over
      IMPORTING
        iv_cost      TYPE i
        iv_limit     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS breach
      IMPORTING
        iv_cost          TYPE i
        iv_limit         TYPE i
      RETURNING
        VALUE(rv_breach) TYPE i.

    METHODS level
      IMPORTING
        iv_cost         TYPE i
        iv_limit        TYPE i
      RETURNING
        VALUE(rv_level) TYPE string.

ENDCLASS.


CLASS zcl_alloc_cobj_threshold IMPLEMENTATION.

  METHOD is_over.
    " The object is over once its cost passes the limit.
    rv_ok = xsdbool( iv_cost > iv_limit ).
  ENDMETHOD.

  METHOD breach.
    " The breach is how far the cost sits above the limit.
    IF iv_cost <= iv_limit.
      RETURN.
    ENDIF.

    rv_breach = iv_cost - iv_limit.
  ENDMETHOD.

  METHOD level.
    " The cost sits over, on or under its limit.
    IF iv_cost > iv_limit.
      rv_level = 'OVER'.
    ELSEIF iv_cost < iv_limit.
      rv_level = 'UNDER'.
    ELSE.
      rv_level = 'ON'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
