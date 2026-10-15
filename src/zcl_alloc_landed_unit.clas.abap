CLASS zcl_alloc_landed_unit DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS per_unit
      IMPORTING
        iv_landed_total TYPE i
        iv_quantity     TYPE i
      RETURNING
        VALUE(rv_unit)  TYPE i.

    METHODS is_high
      IMPORTING
        iv_landed_unit   TYPE i
        iv_standard_unit TYPE i
      RETURNING
        VALUE(rv_ok)     TYPE abap_bool.

    METHODS vs_standard
      IMPORTING
        iv_landed_unit   TYPE i
        iv_standard_unit TYPE i
      RETURNING
        VALUE(rv_delta)  TYPE i.

ENDCLASS.


CLASS zcl_alloc_landed_unit IMPLEMENTATION.

  METHOD per_unit.
    " The landed cost spreads over the quantity it was incurred for.
    IF iv_quantity <= 0.
      RETURN.
    ENDIF.

    rv_unit = iv_landed_total DIV iv_quantity.
  ENDMETHOD.

  METHOD is_high.
    " The landed cost is high once it passes the standard unit cost.
    rv_ok = xsdbool( iv_landed_unit > iv_standard_unit ).
  ENDMETHOD.

  METHOD vs_standard.
    " The gap is the landed unit cost less the standard one.
    rv_delta = iv_landed_unit - iv_standard_unit.
  ENDMETHOD.

ENDCLASS.
