CLASS zcl_alloc_markdown DEFINITION
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

  PRIVATE SECTION.
    METHODS add_cell
      IMPORTING
        iv_line        TYPE string
        iv_value       TYPE string
      RETURNING
        VALUE(rv_line) TYPE string.

ENDCLASS.


CLASS zcl_alloc_markdown IMPLEMENTATION.

  METHOD add_cell.
    DATA lv_space TYPE string.

    lv_space = ` `.
    rv_line = iv_line.
    rv_line = rv_line && '|'.
    rv_line = rv_line && lv_space.
    rv_line = rv_line && iv_value.
    rv_line = rv_line && lv_space.
  ENDMETHOD.

  METHOD run_overview.
    DATA lv_line TYPE string.

    APPEND '| Run | Material | Plant | Status | Items | Requested | Allocated | Shortage | Coverage |' TO rt_lines.
    APPEND '| --- | --- | --- | --- | --- | --- | --- | --- | --- |' TO rt_lines.

    LOOP AT it_overview INTO DATA(ls_overview).
      CLEAR lv_line.
      lv_line = add_cell( iv_line  = lv_line
                          iv_value = |{ ls_overview-run_id }| ).
      lv_line = add_cell( iv_line  = lv_line
                          iv_value = |{ ls_overview-matnr }| ).
      lv_line = add_cell( iv_line  = lv_line
                          iv_value = |{ ls_overview-werks }| ).
      lv_line = add_cell( iv_line  = lv_line
                          iv_value = |{ ls_overview-status }| ).
      lv_line = add_cell( iv_line  = lv_line
                          iv_value = |{ ls_overview-item_count }| ).
      lv_line = add_cell( iv_line  = lv_line
                          iv_value = |{ ls_overview-requested_qty }| ).
      lv_line = add_cell( iv_line  = lv_line
                          iv_value = |{ ls_overview-allocated_qty }| ).
      lv_line = add_cell( iv_line  = lv_line
                          iv_value = |{ ls_overview-shortage_qty }| ).
      lv_line = add_cell( iv_line  = lv_line
                          iv_value = |{ ls_overview-coverage_pct }| ).
      lv_line = lv_line && '|'.
      APPEND lv_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
