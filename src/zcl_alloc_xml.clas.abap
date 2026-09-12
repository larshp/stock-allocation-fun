CLASS zcl_alloc_xml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS run_overview
      IMPORTING
        it_overview     TYPE zcl_alloc_run_report=>ty_overview_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

    METHODS escape
      IMPORTING
        iv_value        TYPE string
      RETURNING
        VALUE(rv_value) TYPE string.

  PRIVATE SECTION.
    METHODS element
      IMPORTING
        iv_name        TYPE string
        iv_value       TYPE string
      RETURNING
        VALUE(rv_line) TYPE string.

ENDCLASS.


CLASS zcl_alloc_xml IMPLEMENTATION.

  METHOD escape.
    rv_value = iv_value.
    REPLACE ALL OCCURRENCES OF '&' IN rv_value WITH '&amp;'.
    REPLACE ALL OCCURRENCES OF '<' IN rv_value WITH '&lt;'.
    REPLACE ALL OCCURRENCES OF '>' IN rv_value WITH '&gt;'.
  ENDMETHOD.

  METHOD element.
    DATA lv_open TYPE string.
    DATA lv_shut TYPE string.
    DATA lv_value TYPE string.

    lv_open = '  <'.
    lv_open = lv_open && iv_name.
    lv_open = lv_open && '>'.

    lv_shut = '</'.
    lv_shut = lv_shut && iv_name.
    lv_shut = lv_shut && '>'.

    lv_value = escape( iv_value ).

    rv_line = lv_open.
    rv_line = rv_line && lv_value.
    rv_line = rv_line && lv_shut.
  ENDMETHOD.

  METHOD run_overview.
    DATA lv_line TYPE string.

    APPEND '<?xml version="1.0" encoding="UTF-8"?>' TO rt_lines.
    APPEND '<runs>' TO rt_lines.

    LOOP AT it_overview INTO DATA(ls_overview).
      APPEND '  <run>' TO rt_lines.

      lv_line = element( iv_name  = 'run_id'
                         iv_value = |{ ls_overview-run_id }| ).
      APPEND lv_line TO rt_lines.
      lv_line = element( iv_name  = 'material'
                         iv_value = |{ ls_overview-matnr }| ).
      APPEND lv_line TO rt_lines.
      lv_line = element( iv_name  = 'plant'
                         iv_value = |{ ls_overview-werks }| ).
      APPEND lv_line TO rt_lines.
      lv_line = element( iv_name  = 'status'
                         iv_value = |{ ls_overview-status }| ).
      APPEND lv_line TO rt_lines.
      lv_line = element( iv_name  = 'items'
                         iv_value = |{ ls_overview-item_count }| ).
      APPEND lv_line TO rt_lines.
      lv_line = element( iv_name  = 'requested'
                         iv_value = |{ ls_overview-requested_qty }| ).
      APPEND lv_line TO rt_lines.
      lv_line = element( iv_name  = 'allocated'
                         iv_value = |{ ls_overview-allocated_qty }| ).
      APPEND lv_line TO rt_lines.
      lv_line = element( iv_name  = 'shortage'
                         iv_value = |{ ls_overview-shortage_qty }| ).
      APPEND lv_line TO rt_lines.
      lv_line = element( iv_name  = 'coverage'
                         iv_value = |{ ls_overview-coverage_pct }| ).
      APPEND lv_line TO rt_lines.

      APPEND '  </run>' TO rt_lines.
    ENDLOOP.

    APPEND '</runs>' TO rt_lines.
  ENDMETHOD.

ENDCLASS.
