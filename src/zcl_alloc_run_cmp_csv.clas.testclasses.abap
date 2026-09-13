CLASS ltcl_alloc_run_cmp_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_run_cmp_csv.

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

    METHODS header_only FOR TESTING.
    METHODS one_line    FOR TESTING.
    METHODS two_lines   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_run_cmp_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_run_cmp_csv( ).
  ENDMETHOD.

  METHOD line.
    rs_row-run_id = iv_run_id.
    rs_row-matnr = iv_matnr.
    rs_row-change_type = iv_change.
    rs_row-old_coverage = iv_old.
    rs_row-new_coverage = iv_new.
  ENDMETHOD.

  METHOD header_only.
    DATA lt_changes TYPE zcl_alloc_run_compare=>ty_line_tt.

    DATA(lt_lines) = mo_cut->build( lt_changes ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ]
      exp = 'RUN_ID;MATNR;CHANGE_TYPE;OLD_COVERAGE;NEW_COVERAGE' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_changes TYPE zcl_alloc_run_compare=>ty_line_tt.

    APPEND line( iv_run_id = 'R1' iv_matnr = 'MAT-1' iv_change = '~'
                 iv_old = 50 iv_new = 80 ) TO lt_changes.

    DATA(lt_lines) = mo_cut->build( lt_changes ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = 'R1;MAT-1;~;50;80' ).
  ENDMETHOD.

  METHOD two_lines.
    DATA lt_changes TYPE zcl_alloc_run_compare=>ty_line_tt.

    APPEND line( iv_run_id = 'R1' iv_matnr = 'MAT-1' iv_change = '+'
                 iv_old = 0 iv_new = 90 ) TO lt_changes.
    APPEND line( iv_run_id = 'R2' iv_matnr = 'MAT-2' iv_change = '-'
                 iv_old = 70 iv_new = 0 ) TO lt_changes.

    DATA(lt_lines) = mo_cut->build( lt_changes ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ]
                                        exp = 'R2;MAT-2;-;70;0' ).
  ENDMETHOD.

ENDCLASS.
