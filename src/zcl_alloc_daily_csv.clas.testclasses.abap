CLASS ltcl_alloc_daily_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_daily_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS one_line    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_daily_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_daily_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA lt_days TYPE zcl_alloc_daily_report=>ty_line_tt.

    DATA(lt_lines) = mo_cut->build( lt_days ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ]
      exp = 'RUN_DATE;LINES;REQUESTED_QTY;ALLOCATED_QTY;COVERAGE_PCT' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_days TYPE zcl_alloc_daily_report=>ty_line_tt.
    DATA ls_day  TYPE zcl_alloc_daily_report=>ty_line.

    ls_day-run_date = '20260101'.
    ls_day-lines = 3.
    ls_day-requested_qty = '30'.
    ls_day-allocated_qty = '24'.
    ls_day-coverage_pct = 80.
    APPEND ls_day TO lt_days.

    DATA(lt_lines) = mo_cut->build( lt_days ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 2 ]
      exp = '20260101;3;30.000;24.000;80' ).
  ENDMETHOD.

ENDCLASS.
