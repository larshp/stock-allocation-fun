CLASS zcl_alloc_run_compare DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             run_id       TYPE zstock_run_id,
             matnr        TYPE matnr,
             change_type  TYPE c LENGTH 1,
             old_coverage TYPE i,
             new_coverage TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_input,
             old               TYPE zcl_alloc_run_report=>ty_overview_tt,
             new               TYPE zcl_alloc_run_report=>ty_overview_tt,
             include_unchanged TYPE abap_bool,
           END OF ty_input.

    METHODS compare
      IMPORTING
        is_input        TYPE ty_input
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

ENDCLASS.


CLASS zcl_alloc_run_compare IMPLEMENTATION.

  METHOD compare.
    DATA ls_line TYPE ty_line.

    LOOP AT is_input-new INTO DATA(ls_new).
      CLEAR ls_line.
      ls_line-run_id = ls_new-run_id.
      ls_line-matnr = ls_new-matnr.
      ls_line-new_coverage = ls_new-coverage_pct.

      READ TABLE is_input-old INTO DATA(ls_old)
        WITH KEY run_id = ls_new-run_id
                 matnr = ls_new-matnr.
      IF sy-subrc <> 0.
        ls_line-change_type = '+'.
      ELSE.
        ls_line-old_coverage = ls_old-coverage_pct.
        IF ls_old-coverage_pct <> ls_new-coverage_pct.
          ls_line-change_type = '~'.
        ELSE.
          ls_line-change_type = '='.
          IF is_input-include_unchanged = abap_false.
            CONTINUE.
          ENDIF.
        ENDIF.
      ENDIF.

      APPEND ls_line TO rt_lines.
    ENDLOOP.

    LOOP AT is_input-old INTO DATA(ls_removed).
      READ TABLE is_input-new INTO DATA(ls_found)
        WITH KEY run_id = ls_removed-run_id
                 matnr = ls_removed-matnr.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      CLEAR ls_line.
      ls_line-run_id = ls_removed-run_id.
      ls_line-matnr = ls_removed-matnr.
      ls_line-change_type = '-'.
      ls_line-old_coverage = ls_removed-coverage_pct.
      APPEND ls_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
