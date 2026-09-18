CLASS zcl_alloc_trend_csv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS constructor.

    METHODS build
      IMPORTING
        is_trend        TYPE zcl_alloc_trend=>ty_trend
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

  PRIVATE SECTION.
    DATA mo_csv TYPE REF TO zcl_alloc_csv.

ENDCLASS.


CLASS zcl_alloc_trend_csv IMPLEMENTATION.

  METHOD constructor.
    mo_csv = NEW zcl_alloc_csv( ).
  ENDMETHOD.

  METHOD build.
    DATA lt_fields TYPE zcl_alloc_csv=>ty_field_tt.
    DATA lv_line   TYPE string.

    APPEND 'COUNT' TO lt_fields.
    APPEND 'FIRST_QTY' TO lt_fields.
    APPEND 'LAST_QTY' TO lt_fields.
    APPEND 'CHANGE_PCT' TO lt_fields.
    APPEND 'DIRECTION' TO lt_fields.
    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.

    CLEAR lt_fields.
    APPEND |{ is_trend-count }| TO lt_fields.
    APPEND |{ is_trend-first_qty }| TO lt_fields.
    APPEND |{ is_trend-last_qty }| TO lt_fields.
    APPEND |{ is_trend-change_pct }| TO lt_fields.
    APPEND |{ is_trend-direction }| TO lt_fields.

    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.
  ENDMETHOD.

ENDCLASS.
