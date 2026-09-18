CLASS ltcl_alloc_daily_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_daily_json.

    METHODS setup.

    METHODS empty_list FOR TESTING.
    METHODS one_line   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_daily_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_daily_json( ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_days TYPE zcl_alloc_daily_report=>ty_line_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_days )
                                        exp = '[]' ).
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

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( lt_days )
      exp = '[{"run_date":"20260101","lines":3,"requested_qty":30.000,' &&
            '"allocated_qty":24.000,"coverage_pct":80}]' ).
  ENDMETHOD.

ENDCLASS.
