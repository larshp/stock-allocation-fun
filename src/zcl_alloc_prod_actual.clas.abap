CLASS zcl_alloc_prod_actual DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS actual
      IMPORTING
        iv_qty              TYPE i
        iv_actual_unit_cost TYPE i
      RETURNING
        VALUE(rv_actual)    TYPE i.

    METHODS is_over
      IMPORTING
        iv_actual    TYPE i
        iv_planned   TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS variance_percent
      IMPORTING
        iv_actual         TYPE i
        iv_planned        TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

ENDCLASS.


CLASS zcl_alloc_prod_actual IMPLEMENTATION.

  METHOD actual.
    " The actual cost is the quantity at the actual unit cost.
    rv_actual = iv_qty * iv_actual_unit_cost.
  ENDMETHOD.

  METHOD is_over.
    " The actual is over once it passes the plan.
    rv_ok = xsdbool( iv_actual > iv_planned ).
  ENDMETHOD.

  METHOD variance_percent.
    DATA lv_diff TYPE i.

    " The variance is the amount over plan as a share of plan.
    IF iv_planned = 0.
      RETURN.
    ENDIF.

    lv_diff = iv_actual - iv_planned.
    rv_percent = lv_diff * 100 DIV iv_planned.
  ENDMETHOD.

ENDCLASS.
