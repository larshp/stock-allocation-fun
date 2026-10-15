CLASS zcl_alloc_cpool_split DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS split
      IMPORTING
        iv_total       TYPE i
        iv_parts       TYPE i
      RETURNING
        VALUE(rv_part) TYPE i.

    METHODS share_of
      IMPORTING
        iv_part           TYPE i
        iv_total          TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS per_unit
      IMPORTING
        iv_total       TYPE i
        iv_units       TYPE i
      RETURNING
        VALUE(rv_rate) TYPE i.

ENDCLASS.


CLASS zcl_alloc_cpool_split IMPLEMENTATION.

  METHOD split.
    " The pool is spread evenly over its parts.
    IF iv_parts <= 0.
      RETURN.
    ENDIF.

    rv_part = iv_total DIV iv_parts.
  ENDMETHOD.

  METHOD share_of.
    " One part's share of the pool as a percentage.
    IF iv_total = 0.
      RETURN.
    ENDIF.

    rv_percent = iv_part * 100 DIV iv_total.
  ENDMETHOD.

  METHOD per_unit.
    " The pool spread over the units it serves.
    IF iv_units <= 0.
      RETURN.
    ENDIF.

    rv_rate = iv_total DIV iv_units.
  ENDMETHOD.

ENDCLASS.
