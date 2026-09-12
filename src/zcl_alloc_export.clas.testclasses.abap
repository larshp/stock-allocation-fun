CLASS ltcl_alloc_export DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_export.

    METHODS setup.

    METHODS run_json_empty            FOR TESTING.
    METHODS run_json_contains_fields  FOR TESTING.
    METHODS run_json_two_rows         FOR TESTING.
    METHODS material_json_empty       FOR TESTING.
    METHODS material_json_contains    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_export IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_export( ).
  ENDMETHOD.

  METHOD run_json_empty.
    DATA lt_overview TYPE zcl_alloc_run_report=>ty_overview_tt.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->run_overview_json( lt_overview )
      exp = '[]' ).
  ENDMETHOD.

  METHOD run_json_contains_fields.
    DATA lt_overview TYPE zcl_alloc_run_report=>ty_overview_tt.
    DATA ls_row      TYPE zcl_alloc_run_report=>ty_overview.

    ls_row-run_id = 'RUN-1'.
    ls_row-matnr = 'MAT-1'.
    ls_row-werks = '1000'.
    ls_row-status = 'D'.
    ls_row-item_count = 2.
    ls_row-coverage_pct = 60.
    APPEND ls_row TO lt_overview.

    DATA(lv_json) = mo_cut->run_overview_json( lt_overview ).

    cl_abap_unit_assert=>assert_equals(
      act = substring( val = lv_json off = 0 len = 1 ) exp = '[' ).
    cl_abap_unit_assert=>assert_true(
      act = boolc( find( val = lv_json sub = `"run_id":"RUN-1"` ) >= 0 ) ).
    cl_abap_unit_assert=>assert_true(
      act = boolc( find( val = lv_json sub = `"matnr":"MAT-1"` ) >= 0 ) ).
    cl_abap_unit_assert=>assert_true(
      act = boolc( find( val = lv_json sub = `"coverage_pct":60` ) >= 0 ) ).
  ENDMETHOD.

  METHOD run_json_two_rows.
    DATA lt_overview TYPE zcl_alloc_run_report=>ty_overview_tt.
    DATA ls_row      TYPE zcl_alloc_run_report=>ty_overview.

    ls_row-run_id = 'RUN-1'.
    APPEND ls_row TO lt_overview.
    ls_row-run_id = 'RUN-2'.
    APPEND ls_row TO lt_overview.

    DATA(lv_json) = mo_cut->run_overview_json( lt_overview ).

    cl_abap_unit_assert=>assert_true(
      act = boolc( find( val = lv_json sub = `"run_id":"RUN-1"` ) >= 0 ) ).
    cl_abap_unit_assert=>assert_true(
      act = boolc( find( val = lv_json sub = `"run_id":"RUN-2"` ) >= 0 ) ).
    cl_abap_unit_assert=>assert_true(
      act = boolc( find( val = lv_json sub = `},{` ) >= 0 ) ).
  ENDMETHOD.

  METHOD material_json_empty.
    DATA lt_overview TYPE zcl_alloc_material_report=>ty_material_line_tt.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->material_overview_json( lt_overview )
      exp = '[]' ).
  ENDMETHOD.

  METHOD material_json_contains.
    DATA lt_overview TYPE zcl_alloc_material_report=>ty_material_line_tt.
    DATA ls_row      TYPE zcl_alloc_material_report=>ty_material_line.

    ls_row-matnr = 'MAT-1'.
    ls_row-werks = '1000'.
    ls_row-run_count = 2.
    ls_row-positions = 3.
    ls_row-coverage_pct = 75.
    APPEND ls_row TO lt_overview.

    DATA(lv_json) = mo_cut->material_overview_json( lt_overview ).

    cl_abap_unit_assert=>assert_true(
      act = boolc( find( val = lv_json sub = `"run_count":2` ) >= 0 ) ).
    cl_abap_unit_assert=>assert_true(
      act = boolc( find( val = lv_json sub = `"positions":3` ) >= 0 ) ).
    cl_abap_unit_assert=>assert_true(
      act = boolc( find( val = lv_json sub = `"coverage_pct":75` ) >= 0 ) ).
  ENDMETHOD.

ENDCLASS.
