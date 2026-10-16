CLASS zcl_alloc_cpool_var DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS variance
      IMPORTING
        iv_actual          TYPE i
        iv_plan            TYPE i
      RETURNING
        VALUE(rv_variance) TYPE i.

    METHODS is_over
      IMPORTING
        iv_actual    TYPE i
        iv_plan      TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS percent
      IMPORTING
        iv_actual         TYPE i
        iv_plan           TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

ENDCLASS.


CLASS zcl_alloc_cpool_var IMPLEMENTATION.

  METHOD variance.
    " A positive variance is a pool spent above its plan.
    rv_variance = iv_actual - iv_plan.
  ENDMETHOD.

  METHOD is_over.
    " The pool is over once the actual cost passes the plan.
    rv_ok = xsdbool( iv_actual > iv_plan ).
  ENDMETHOD.

  METHOD percent.
    DATA lv_variance TYPE i.

    " The variance as a share of the planned pool cost.
    IF iv_plan = 0.
      RETURN.
    ENDIF.

    lv_variance = variance( iv_actual = iv_actual iv_plan = iv_plan ).
    rv_percent = lv_variance * 100 DIV iv_plan.
  ENDMETHOD.

ENDCLASS.
