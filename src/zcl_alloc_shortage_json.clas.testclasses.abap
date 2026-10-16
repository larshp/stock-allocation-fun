CLASS ltcl_alloc_shortage_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_shortage_json.

    METHODS setup.

    METHODS line
      IMPORTING
        iv_id          TYPE zcl_alloc_shortage_report=>ty_line-requirement_id
        iv_requested   TYPE menge_d
        iv_allocated   TYPE menge_d
        iv_covered     TYPE abap_bool
      RETURNING
        VALUE(rs_line) TYPE zcl_alloc_shortage_report=>ty_line.

    METHODS empty_report    FOR TESTING.
    METHODS summary_fields  FOR TESTING.
    METHODS line_fields     FOR TESTING.
    METHODS covered_flag    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_shortage_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_shortage_json( ).
  ENDMETHOD.

  METHOD line.
    rs_line-requirement_id = iv_id.
    rs_line-requested_qty = iv_requested.
    rs_line-allocated_qty = iv_allocated.
    rs_line-shortage_qty = iv_requested - iv_allocated.
    IF iv_requested > 0.
      rs_line-coverage_pct = iv_allocated * 100 DIV iv_requested.
    ENDIF.
    rs_line-covered = iv_covered.
  ENDMETHOD.

  METHOD empty_report.
    DATA ls_report TYPE zcl_alloc_shortage_report=>ty_report.
    DATA lv_exp    TYPE string.

    lv_exp = '{"summary":{"requested_qty":0.000,"allocated_qty":0.000,'.
    lv_exp = lv_exp && '"shortage_qty":0.000,"coverage_pct":0,"lines":0,'.
    lv_exp = lv_exp && '"short_lines":0,"covered_lines":0},"lines":[]}'.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( ls_report )
                                        exp = lv_exp ).
  ENDMETHOD.

  METHOD summary_fields.
    DATA ls_report TYPE zcl_alloc_shortage_report=>ty_report.

    ls_report-summary-requested_qty = '10'.
    ls_report-summary-allocated_qty = '6'.
    ls_report-summary-shortage_qty = '4'.
    ls_report-summary-coverage_pct = 60.
    ls_report-summary-lines = 1.
    ls_report-summary-short_lines = 1.

    DATA(lv_json) = mo_cut->build( ls_report ).

    cl_abap_unit_assert=>assert_equals(
      act = substring( val = lv_json off = 0 len = 22 )
      exp = '{"summary":{"requested' ).
    cl_abap_unit_assert=>assert_differs(
      act = find( val = lv_json sub = '"coverage_pct":60' )
      exp = -1 ).
  ENDMETHOD.

  METHOD line_fields.
    DATA ls_report TYPE zcl_alloc_shortage_report=>ty_report.

    APPEND line( iv_id        = 'REQ-1'
                 iv_requested = '10'
                 iv_allocated = '6'
                 iv_covered   = abap_false ) TO ls_report-lines.

    DATA(lv_json) = mo_cut->build( ls_report ).

    cl_abap_unit_assert=>assert_differs(
      act = find( val = lv_json sub = '"requirement_id":"REQ-1"' )
      exp = -1 ).
    cl_abap_unit_assert=>assert_differs(
      act = find( val = lv_json sub = '"allocated_qty":6.000' )
      exp = -1 ).
    cl_abap_unit_assert=>assert_differs(
      act = find( val = lv_json sub = '"covered":false' )
      exp = -1 ).
  ENDMETHOD.

  METHOD covered_flag.
    DATA ls_report TYPE zcl_alloc_shortage_report=>ty_report.

    APPEND line( iv_id        = 'REQ-1'
                 iv_requested = '10'
                 iv_allocated = '10'
                 iv_covered   = abap_true ) TO ls_report-lines.

    DATA(lv_json) = mo_cut->build( ls_report ).

    cl_abap_unit_assert=>assert_differs(
      act = find( val = lv_json sub = '"covered":true' )
      exp = -1 ).
  ENDMETHOD.

ENDCLASS.
