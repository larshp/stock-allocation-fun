CLASS zcl_alloc_kpi_csv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS constructor.

    METHODS build
      IMPORTING
        is_kpi          TYPE zcl_alloc_kpi=>ty_kpi
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

  PRIVATE SECTION.
    DATA mo_csv TYPE REF TO zcl_alloc_csv.

ENDCLASS.


CLASS zcl_alloc_kpi_csv IMPLEMENTATION.

  METHOD constructor.
    mo_csv = NEW zcl_alloc_csv( ).
  ENDMETHOD.

  METHOD build.
    DATA lt_fields TYPE zcl_alloc_csv=>ty_field_tt.
    DATA lv_line   TYPE string.

    APPEND 'REQUIREMENTS' TO lt_fields.
    APPEND 'FULLY_DELIVERED' TO lt_fields.
    APPEND 'SHORT' TO lt_fields.
    APPEND 'REQUESTED_QTY' TO lt_fields.
    APPEND 'ALLOCATED_QTY' TO lt_fields.
    APPEND 'SHORTAGE_QTY' TO lt_fields.
    APPEND 'COVERAGE_PCT' TO lt_fields.
    APPEND 'FILL_RATE_PCT' TO lt_fields.
    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.

    CLEAR lt_fields.
    APPEND |{ is_kpi-requirements }| TO lt_fields.
    APPEND |{ is_kpi-fully_delivered }| TO lt_fields.
    APPEND |{ is_kpi-short }| TO lt_fields.
    APPEND |{ is_kpi-requested_qty }| TO lt_fields.
    APPEND |{ is_kpi-allocated_qty }| TO lt_fields.
    APPEND |{ is_kpi-shortage_qty }| TO lt_fields.
    APPEND |{ is_kpi-coverage_pct }| TO lt_fields.
    APPEND |{ is_kpi-fill_rate_pct }| TO lt_fields.

    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.
  ENDMETHOD.

ENDCLASS.
