CLASS zcl_alloc_shortage_csv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS constructor.

    METHODS build
      IMPORTING
        is_report       TYPE zcl_alloc_shortage_report=>ty_report
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

  PRIVATE SECTION.
    DATA mo_csv TYPE REF TO zcl_alloc_csv.

    METHODS flag_of
      IMPORTING
        iv_flag        TYPE abap_bool
      RETURNING
        VALUE(rv_flag) TYPE string.

ENDCLASS.


CLASS zcl_alloc_shortage_csv IMPLEMENTATION.

  METHOD constructor.
    mo_csv = NEW zcl_alloc_csv( ).
  ENDMETHOD.

  METHOD flag_of.
    IF iv_flag = abap_true.
      rv_flag = 'Y'.
    ELSE.
      rv_flag = 'N'.
    ENDIF.
  ENDMETHOD.

  METHOD build.
    DATA lt_fields TYPE zcl_alloc_csv=>ty_field_tt.
    DATA lv_line   TYPE string.
    DATA lv_flag   TYPE string.

    APPEND 'REQUIREMENT_ID' TO lt_fields.
    APPEND 'REQUESTED' TO lt_fields.
    APPEND 'ALLOCATED' TO lt_fields.
    APPEND 'SHORTAGE' TO lt_fields.
    APPEND 'COVERAGE' TO lt_fields.
    APPEND 'COVERED' TO lt_fields.
    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.

    LOOP AT is_report-lines INTO DATA(ls_line).
      CLEAR lt_fields.
      APPEND |{ ls_line-requirement_id }| TO lt_fields.
      APPEND |{ ls_line-requested_qty }| TO lt_fields.
      APPEND |{ ls_line-allocated_qty }| TO lt_fields.
      APPEND |{ ls_line-shortage_qty }| TO lt_fields.
      APPEND |{ ls_line-coverage_pct }| TO lt_fields.
      lv_flag = flag_of( ls_line-covered ).
      APPEND lv_flag TO lt_fields.
      lv_line = mo_csv->build_line( lt_fields ).
      APPEND lv_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
