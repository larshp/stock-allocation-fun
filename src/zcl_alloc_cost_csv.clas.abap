CLASS zcl_alloc_cost_csv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS constructor.

    METHODS build
      IMPORTING
        is_result       TYPE zcl_alloc_cost=>ty_result
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

  PRIVATE SECTION.
    DATA mo_csv TYPE REF TO zcl_alloc_csv.

ENDCLASS.


CLASS zcl_alloc_cost_csv IMPLEMENTATION.

  METHOD constructor.
    mo_csv = NEW zcl_alloc_csv( ).
  ENDMETHOD.

  METHOD build.
    DATA lt_fields TYPE zcl_alloc_csv=>ty_field_tt.
    DATA lv_line   TYPE string.

    APPEND 'WERKS' TO lt_fields.
    APPEND 'TAKEN' TO lt_fields.
    APPEND 'COST' TO lt_fields.
    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.

    LOOP AT is_result-lines INTO DATA(ls_line).
      CLEAR lt_fields.
      APPEND |{ ls_line-werks }| TO lt_fields.
      APPEND |{ ls_line-taken }| TO lt_fields.
      APPEND |{ ls_line-cost }| TO lt_fields.

      lv_line = mo_csv->build_line( lt_fields ).
      APPEND lv_line TO rt_lines.
    ENDLOOP.

    CLEAR lt_fields.
    APPEND 'SUMMARY' TO lt_fields.
    APPEND |{ is_result-total_cost }| TO lt_fields.
    APPEND |{ is_result-remaining }| TO lt_fields.

    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.
  ENDMETHOD.

ENDCLASS.
