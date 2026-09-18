CLASS ltcl_alloc_snap_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_snap_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS one_line    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_snap_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_snap_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA lt_diffs TYPE zcl_alloc_snapshot=>ty_diff_tt.

    DATA(lt_lines) = mo_cut->build( lt_diffs ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ]
      exp = 'REQUIREMENT_ID;BEFORE_QTY;AFTER_QTY;DELTA_QTY' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_diffs TYPE zcl_alloc_snapshot=>ty_diff_tt.
    DATA ls_diff  TYPE zcl_alloc_snapshot=>ty_diff.

    ls_diff-requirement_id = 'REQ-1'.
    ls_diff-before_qty = '5'.
    ls_diff-after_qty = '8'.
    ls_diff-delta_qty = '3'.
    APPEND ls_diff TO lt_diffs.

    DATA(lt_lines) = mo_cut->build( lt_diffs ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = 'REQ-1;5.000;8.000;3.000' ).
  ENDMETHOD.

ENDCLASS.
