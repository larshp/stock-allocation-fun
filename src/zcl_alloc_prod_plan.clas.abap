CLASS zcl_alloc_prod_plan DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS planned
      IMPORTING
        iv_qty            TYPE i
        iv_std_unit_cost  TYPE i
      RETURNING
        VALUE(rv_planned) TYPE i.

    METHODS is_within
      IMPORTING
        iv_actual    TYPE i
        iv_planned   TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS variance
      IMPORTING
        iv_actual          TYPE i
        iv_planned         TYPE i
      RETURNING
        VALUE(rv_variance) TYPE i.

ENDCLASS.


CLASS zcl_alloc_prod_plan IMPLEMENTATION.

  METHOD planned.
    " The planned cost is the quantity at the standard unit cost.
    rv_planned = iv_qty * iv_std_unit_cost.
  ENDMETHOD.

  METHOD is_within.
    " The actual stays within plan while it does not exceed it.
    rv_ok = xsdbool( iv_actual <= iv_planned ).
  ENDMETHOD.

  METHOD variance.
    " A positive variance is cost above plan.
    rv_variance = iv_actual - iv_planned.
  ENDMETHOD.

ENDCLASS.
