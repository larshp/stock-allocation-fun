CLASS zcl_alloc_html DEFINITION
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
    METHODS add_cell
      IMPORTING
        iv_line        TYPE string
        iv_tag         TYPE string
        iv_value       TYPE string
      RETURNING
        VALUE(rv_line) TYPE string.

ENDCLASS.


CLASS zcl_alloc_html IMPLEMENTATION.

  METHOD escape.
    rv_value = iv_value.
    REPLACE ALL OCCURRENCES OF '&' IN rv_value WITH '&amp;'.
    REPLACE ALL OCCURRENCES OF '<' IN rv_value WITH '&lt;'.
    REPLACE ALL OCCURRENCES OF '>' IN rv_value WITH '&gt;'.
  ENDMETHOD.

  METHOD add_cell.
    DATA lv_open TYPE string.
    DATA lv_shut TYPE string.
    DATA lv_value TYPE string.

    lv_open = '<'.
    lv_open = lv_open && iv_tag.
    lv_open = lv_open && '>'.

    lv_shut = '</'.
    lv_shut = lv_shut && iv_tag.
    lv_shut = lv_shut && '>'.

    lv_value = escape( iv_value ).

    rv_line = iv_line.
    rv_line = rv_line && lv_open.
    rv_line = rv_line && lv_value.
    rv_line = rv_line && lv_shut.
  ENDMETHOD.

  METHOD run_overview.
    DATA lv_line TYPE string.
    DATA lv_head TYPE string.

    APPEND '<table>' TO rt_lines.

    lv_head = '<tr>'.
    lv_head = add_cell( iv_line  = lv_head
                        iv_tag   = 'th'
                        iv_value = 'Run' ).
    lv_head = add_cell( iv_line  = lv_head
                        iv_tag   = 'th'
                        iv_value = 'Material' ).
    lv_head = add_cell( iv_line  = lv_head
                        iv_tag   = 'th'
                        iv_value = 'Plant' ).
    lv_head = add_cell( iv_line  = lv_head
                        iv_tag   = 'th'
                        iv_value = 'Status' ).
    lv_head = add_cell( iv_line  = lv_head
                        iv_tag   = 'th'
                        iv_value = 'Items' ).
    lv_head = add_cell( iv_line  = lv_head
                        iv_tag   = 'th'
                        iv_value = 'Requested' ).
    lv_head = add_cell( iv_line  = lv_head
                        iv_tag   = 'th'
                        iv_value = 'Allocated' ).
    lv_head = add_cell( iv_line  = lv_head
                        iv_tag   = 'th'
                        iv_value = 'Shortage' ).
    lv_head = add_cell( iv_line  = lv_head
                        iv_tag   = 'th'
                        iv_value = 'Coverage' ).
    lv_head = lv_head && '</tr>'.
    APPEND lv_head TO rt_lines.

    LOOP AT it_overview INTO DATA(ls_overview).
      CLEAR lv_line.
      lv_line = '<tr>'.
      lv_line = add_cell( iv_line  = lv_line
                          iv_tag   = 'td'
                          iv_value = |{ ls_overview-run_id }| ).
      lv_line = add_cell( iv_line  = lv_line
                          iv_tag   = 'td'
                          iv_value = |{ ls_overview-matnr }| ).
      lv_line = add_cell( iv_line  = lv_line
                          iv_tag   = 'td'
                          iv_value = |{ ls_overview-werks }| ).
      lv_line = add_cell( iv_line  = lv_line
                          iv_tag   = 'td'
                          iv_value = |{ ls_overview-status }| ).
      lv_line = add_cell( iv_line  = lv_line
                          iv_tag   = 'td'
                          iv_value = |{ ls_overview-item_count }| ).
      lv_line = add_cell( iv_line  = lv_line
                          iv_tag   = 'td'
                          iv_value = |{ ls_overview-requested_qty }| ).
      lv_line = add_cell( iv_line  = lv_line
                          iv_tag   = 'td'
                          iv_value = |{ ls_overview-allocated_qty }| ).
      lv_line = add_cell( iv_line  = lv_line
                          iv_tag   = 'td'
                          iv_value = |{ ls_overview-shortage_qty }| ).
      lv_line = add_cell( iv_line  = lv_line
                          iv_tag   = 'td'
                          iv_value = |{ ls_overview-coverage_pct }| ).
      lv_line = lv_line && '</tr>'.
      APPEND lv_line TO rt_lines.
    ENDLOOP.

    APPEND '</table>' TO rt_lines.
  ENDMETHOD.

ENDCLASS.
