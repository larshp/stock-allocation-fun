CLASS zcl_alloc_sla_csv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS constructor.

    METHODS build
      IMPORTING
        is_result       TYPE zcl_alloc_sla=>ty_result
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

  PRIVATE SECTION.
    DATA mo_csv TYPE REF TO zcl_alloc_csv.

ENDCLASS.


CLASS zcl_alloc_sla_csv IMPLEMENTATION.

  METHOD constructor.
    mo_csv = NEW zcl_alloc_csv( ).
  ENDMETHOD.

  METHOD build.
    DATA lt_fields TYPE zcl_alloc_csv=>ty_field_tt.
    DATA lv_line   TYPE string.
    DATA lv_flag   TYPE string.

    APPEND 'REQUIREMENT_ID' TO lt_fields.
    APPEND 'LEAD_DAYS' TO lt_fields.
    APPEND 'TARGET_DAYS' TO lt_fields.
    APPEND 'ON_TIME' TO lt_fields.
    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.

    LOOP AT is_result-lines INTO DATA(ls_line).
      lv_flag = 'N'.
      IF ls_line-on_time = abap_true.
        lv_flag = 'Y'.
      ENDIF.

      CLEAR lt_fields.
      APPEND |{ ls_line-requirement_id }| TO lt_fields.
      APPEND |{ ls_line-lead_days }| TO lt_fields.
      APPEND |{ ls_line-target_days }| TO lt_fields.
      APPEND lv_flag TO lt_fields.

      lv_line = mo_csv->build_line( lt_fields ).
      APPEND lv_line TO rt_lines.
    ENDLOOP.

    CLEAR lt_fields.
    APPEND 'SUMMARY' TO lt_fields.
    APPEND |{ is_result-total }| TO lt_fields.
    APPEND |{ is_result-on_time }| TO lt_fields.
    APPEND |{ is_result-compliance_pct }| TO lt_fields.

    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.
  ENDMETHOD.

ENDCLASS.
