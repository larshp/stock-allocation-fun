CLASS zcl_alloc_risk_csv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS constructor.

    METHODS build
      IMPORTING
        is_risk         TYPE zcl_alloc_risk=>ty_risk
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

  PRIVATE SECTION.
    DATA mo_csv TYPE REF TO zcl_alloc_csv.

ENDCLASS.


CLASS zcl_alloc_risk_csv IMPLEMENTATION.

  METHOD constructor.
    mo_csv = NEW zcl_alloc_csv( ).
  ENDMETHOD.

  METHOD build.
    DATA lt_fields TYPE zcl_alloc_csv=>ty_field_tt.
    DATA lv_line   TYPE string.

    APPEND 'LINES' TO lt_fields.
    APPEND 'SHORTAGE_QTY' TO lt_fields.
    APPEND 'RISK_PCT' TO lt_fields.
    APPEND 'LEVEL' TO lt_fields.
    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.

    CLEAR lt_fields.
    APPEND |{ is_risk-lines }| TO lt_fields.
    APPEND |{ is_risk-shortage_qty }| TO lt_fields.
    APPEND |{ is_risk-risk_pct }| TO lt_fields.
    APPEND |{ is_risk-level }| TO lt_fields.

    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.
  ENDMETHOD.

ENDCLASS.
