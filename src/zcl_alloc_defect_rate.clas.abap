CLASS zcl_alloc_defect_rate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS percent
      IMPORTING
        iv_defects    TYPE i
        iv_inspected  TYPE i
      RETURNING
        VALUE(rv_pct) TYPE i.

    METHODS per_thousand
      IMPORTING
        iv_defects      TYPE i
        iv_inspected    TYPE i
      RETURNING
        VALUE(rv_per_k) TYPE i.

ENDCLASS.


CLASS zcl_alloc_defect_rate IMPLEMENTATION.

  METHOD percent.
    IF iv_defects <= 0 OR iv_inspected <= 0.
      RETURN.
    ENDIF.

    " Whole-percent rate; a rate below one percent is reported as zero, which is
    " why the finer per-thousand figure exists.
    rv_pct = iv_defects * 100 DIV iv_inspected.
  ENDMETHOD.

  METHOD per_thousand.
    IF iv_defects <= 0 OR iv_inspected <= 0.
      RETURN.
    ENDIF.

    rv_per_k = iv_defects * 1000 DIV iv_inspected.
  ENDMETHOD.

ENDCLASS.
