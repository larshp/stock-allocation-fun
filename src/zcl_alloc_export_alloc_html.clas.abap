CLASS zcl_alloc_export_alloc_html DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_result       TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

  PRIVATE SECTION.
    METHODS escape
      IMPORTING
        iv_value       TYPE c
      RETURNING
        VALUE(rv_text) TYPE string.

    METHODS cell
      IMPORTING
        iv_value       TYPE c
      RETURNING
        VALUE(rv_cell) TYPE string.

ENDCLASS.


CLASS zcl_alloc_export_alloc_html IMPLEMENTATION.

  METHOD escape.
    DATA lv_text TYPE string.

    lv_text = iv_value.
    replace all occurrences of '&' in lv_text with '&amp;'.
    replace all occurrences of '<' in lv_text with '&lt;'.
    replace all occurrences of '>' in lv_text with '&gt;'.

    rv_text = lv_text.
  ENDMETHOD.

  METHOD cell.
    rv_cell = '<td>'.
    rv_cell = rv_cell && escape( iv_value ).
    rv_cell = rv_cell && '</td>'.
  ENDMETHOD.

  METHOD build.
    DATA lv_row TYPE string.

    APPEND '<table>' TO rt_lines.
    APPEND '<thead><tr>' TO rt_lines.
    APPEND '<th>Requirement</th><th>Material</th><th>Location</th>' &&
           '<th>Batch</th><th>Quantity</th>' TO rt_lines.
    APPEND '</tr></thead>' TO rt_lines.
    APPEND '<tbody>' TO rt_lines.

    LOOP AT it_result INTO DATA(ls_result).
      LOOP AT ls_result-allocations INTO DATA(ls_allocation).
        IF ls_allocation-quantity <= 0.
          CONTINUE.
        ENDIF.

        CLEAR lv_row.
        lv_row = '<tr>'.
        lv_row = lv_row && cell( ls_result-requirement_id ).
        lv_row = lv_row && cell( ls_allocation-matnr ).
        lv_row = lv_row && cell( ls_allocation-lgort ).
        lv_row = lv_row && cell( ls_allocation-charg ).
        lv_row = lv_row && cell( |{ ls_allocation-quantity }| ).
        lv_row = lv_row && '</tr>'.

        APPEND lv_row TO rt_lines.
      ENDLOOP.
    ENDLOOP.

    APPEND '</tbody>' TO rt_lines.
    APPEND '</table>' TO rt_lines.
  ENDMETHOD.

ENDCLASS.
