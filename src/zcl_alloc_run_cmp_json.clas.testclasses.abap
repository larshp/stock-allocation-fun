CLASS ltcl_alloc_run_cmp_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_run_cmp_json.

    METHODS setup.

    METHODS line
      IMPORTING
        iv_run_id     TYPE zstock_run_id
        iv_matnr      TYPE matnr
        iv_change     TYPE c
        iv_old        TYPE i
        iv_new        TYPE i
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_run_compare=>ty_line.

    METHODS empty_list  FOR TESTING.
    METHODS one_line    FOR TESTING.
    METHODS two_lines   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_run_cmp_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_run_cmp_json( ).
  ENDMETHOD.

  METHOD line.
    rs_row-run_id = iv_run_id.
    rs_row-matnr = iv_matnr.
    rs_row-change_type = iv_change.
    rs_row-old_coverage = iv_old.
    rs_row-new_coverage = iv_new.
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_changes TYPE zcl_alloc_run_compare=>ty_line_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_changes )
                                        exp = '[]' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_changes TYPE zcl_alloc_run_compare=>ty_line_tt.

    APPEND line( iv_run_id = 'R1' iv_matnr = 'MAT-1' iv_change = '~'
                 iv_old = 50 iv_new = 80 ) TO lt_changes.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( lt_changes )
      exp = '[{"run_id":"R1","matnr":"MAT-1","change_type":"~",' &&
            '"old_coverage":50,"new_coverage":80}]' ).
  ENDMETHOD.

  METHOD two_lines.
    DATA lt_changes TYPE zcl_alloc_run_compare=>ty_line_tt.

    APPEND line( iv_run_id = 'R1' iv_matnr = 'MAT-1' iv_change = '+'
                 iv_old = 0 iv_new = 90 ) TO lt_changes.
    APPEND line( iv_run_id = 'R2' iv_matnr = 'MAT-2' iv_change = '='
                 iv_old = 70 iv_new = 70 ) TO lt_changes.

    DATA(lv_json) = mo_cut->build( lt_changes ).

    cl_abap_unit_assert=>assert_differs(
      act = find( val = lv_json sub = '"run_id":"R2"' )
      exp = -1 ).
  ENDMETHOD.

ENDCLASS.
