CLASS zcl_alloc_kpi_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS build
      IMPORTING
        is_kpi         TYPE zcl_alloc_kpi=>ty_kpi
      RETURNING
        VALUE(rv_json) TYPE string.

ENDCLASS.


CLASS zcl_alloc_kpi_json IMPLEMENTATION.

  METHOD build.
    rv_json = '{'.
    rv_json = rv_json && |"requirements":{ is_kpi-requirements },|.
    rv_json = rv_json && |"fully_delivered":{ is_kpi-fully_delivered },|.
    rv_json = rv_json && |"short":{ is_kpi-short },|.
    rv_json = rv_json && |"requested_qty":{ is_kpi-requested_qty },|.
    rv_json = rv_json && |"allocated_qty":{ is_kpi-allocated_qty },|.
    rv_json = rv_json && |"shortage_qty":{ is_kpi-shortage_qty },|.
    rv_json = rv_json && |"coverage_pct":{ is_kpi-coverage_pct },|.
    rv_json = rv_json && |"fill_rate_pct":{ is_kpi-fill_rate_pct }|.
    rv_json = rv_json && '}'.
  ENDMETHOD.

ENDCLASS.
