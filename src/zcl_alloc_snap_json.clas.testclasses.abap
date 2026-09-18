CLASS ltcl_alloc_snap_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_snap_json.

    METHODS setup.

    METHODS empty_list FOR TESTING.
    METHODS one_line   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_snap_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_snap_json( ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_diffs TYPE zcl_alloc_snapshot=>ty_diff_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_diffs )
                                        exp = '[]' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_diffs TYPE zcl_alloc_snapshot=>ty_diff_tt.
    DATA ls_diff  TYPE zcl_alloc_snapshot=>ty_diff.

    ls_diff-requirement_id = 'REQ-1'.
    ls_diff-before_qty = '5'.
    ls_diff-after_qty = '8'.
    ls_diff-delta_qty = '3'.
    APPEND ls_diff TO lt_diffs.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( lt_diffs )
      exp = '[{"requirement_id":"REQ-1","before_qty":5.000,' &&
            '"after_qty":8.000,"delta_qty":3.000}]' ).
  ENDMETHOD.

ENDCLASS.
