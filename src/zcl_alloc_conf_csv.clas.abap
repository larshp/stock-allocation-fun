CLASS zcl_alloc_conf_csv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS constructor.

    METHODS build
      IMPORTING
        is_confidence   TYPE zcl_alloc_confidence=>ty_confidence
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

  PRIVATE SECTION.
    DATA mo_csv TYPE REF TO zcl_alloc_csv.

ENDCLASS.


CLASS zcl_alloc_conf_csv IMPLEMENTATION.

  METHOD constructor.
    mo_csv = NEW zcl_alloc_csv( ).
  ENDMETHOD.

  METHOD build.
    DATA lt_fields TYPE zcl_alloc_csv=>ty_field_tt.
    DATA lv_line   TYPE string.

    APPEND 'REQUIREMENTS' TO lt_fields.
    APPEND 'COVERAGE_PCT' TO lt_fields.
    APPEND 'FILL_RATE_PCT' TO lt_fields.
    APPEND 'SCORE' TO lt_fields.
    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.

    CLEAR lt_fields.
    APPEND |{ is_confidence-requirements }| TO lt_fields.
    APPEND |{ is_confidence-coverage_pct }| TO lt_fields.
    APPEND |{ is_confidence-fill_rate_pct }| TO lt_fields.
    APPEND |{ is_confidence-score }| TO lt_fields.

    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.
  ENDMETHOD.

ENDCLASS.
