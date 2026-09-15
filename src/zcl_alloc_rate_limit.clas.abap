CLASS zcl_alloc_rate_limit DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        iv_limit TYPE i DEFAULT 10.

    METHODS consume
      IMPORTING
        iv_units          TYPE i
      RETURNING
        VALUE(rv_allowed) TYPE abap_bool.

    METHODS remaining
      RETURNING
        VALUE(rv_units) TYPE i.

    METHODS reset.

  PRIVATE SECTION.
    DATA mv_consumed TYPE i.
    DATA mv_limit    TYPE i.

ENDCLASS.


CLASS zcl_alloc_rate_limit IMPLEMENTATION.

  METHOD constructor.
    IF iv_limit <= 0.
      mv_limit = 1.
    ELSE.
      mv_limit = iv_limit.
    ENDIF.

    mv_consumed = 0.
  ENDMETHOD.

  METHOD reset.
    mv_consumed = 0.
  ENDMETHOD.

  METHOD remaining.
    rv_units = mv_limit - mv_consumed.

    IF rv_units < 0.
      rv_units = 0.
    ENDIF.
  ENDMETHOD.

  METHOD consume.
    IF iv_units <= 0.
      rv_allowed = abap_true.
      RETURN.
    ENDIF.

    IF mv_consumed + iv_units > mv_limit.
      rv_allowed = abap_false.
      RETURN.
    ENDIF.

    mv_consumed = mv_consumed + iv_units.
    rv_allowed = abap_true.
  ENDMETHOD.

ENDCLASS.
