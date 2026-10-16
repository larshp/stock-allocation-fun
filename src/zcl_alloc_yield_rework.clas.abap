CLASS zcl_alloc_yield_rework DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS rework
      IMPORTING
        iv_total          TYPE i
        iv_rework_percent TYPE i
      RETURNING
        VALUE(rv_rework)  TYPE i.

    METHODS is_reworked
      IMPORTING
        iv_rework    TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS rework_percent
      IMPORTING
        iv_rework         TYPE i
        iv_total          TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

ENDCLASS.


CLASS zcl_alloc_yield_rework IMPLEMENTATION.

  METHOD rework.
    " The rework is the quantity at the rework percentage.
    IF iv_total <= 0 OR iv_rework_percent <= 0.
      RETURN.
    ENDIF.

    rv_rework = iv_total * iv_rework_percent DIV 100.
  ENDMETHOD.

  METHOD is_reworked.
    " The order is reworked once any quantity goes back through.
    rv_ok = xsdbool( iv_rework > 0 ).
  ENDMETHOD.

  METHOD rework_percent.
    " The rework as a share of the whole.
    IF iv_total = 0.
      RETURN.
    ENDIF.

    rv_percent = iv_rework * 100 DIV iv_total.
  ENDMETHOD.

ENDCLASS.
