CLASS zcl_alloc_cpool_cover DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS coverage_percent
      IMPORTING
        iv_assigned       TYPE i
        iv_pool           TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS is_covered
      IMPORTING
        iv_assigned  TYPE i
        iv_pool      TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS shortfall
      IMPORTING
        iv_assigned     TYPE i
        iv_pool         TYPE i
      RETURNING
        VALUE(rv_short) TYPE i.

ENDCLASS.


CLASS zcl_alloc_cpool_cover IMPLEMENTATION.

  METHOD coverage_percent.
    " Coverage is how much of the pool has been assigned out.
    IF iv_pool = 0.
      RETURN.
    ENDIF.

    rv_percent = iv_assigned * 100 DIV iv_pool.
  ENDMETHOD.

  METHOD is_covered.
    " The pool is covered once everything has been assigned.
    rv_ok = xsdbool( iv_assigned >= iv_pool ).
  ENDMETHOD.

  METHOD shortfall.
    " The shortfall is what is still uncovered.
    IF iv_assigned >= iv_pool.
      RETURN.
    ENDIF.

    rv_short = iv_pool - iv_assigned.
  ENDMETHOD.

ENDCLASS.
