CLASS ltcl_alloc_diff_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_diff_csv.

    METHODS setup.

    METHODS diff_with
      IMPORTING
        iv_id         TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_old        TYPE menge_d
        iv_new        TYPE menge_d
        iv_change     TYPE c
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_diff=>ty_result.

    METHODS header_only FOR TESTING.
    METHODS one_line    FOR TESTING.
    METHODS two_lines   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_diff_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_diff_csv( ).
  ENDMETHOD.

  METHOD diff_with.
    DATA ls_line TYPE zcl_alloc_diff=>ty_line.

    ls_line-requirement_id = iv_id.
    ls_line-old_qty = iv_old.
    ls_line-new_qty = iv_new.
    ls_line-delta_qty = iv_new - iv_old.
    ls_line-change_type = iv_change.
    APPEND ls_line TO rs_row-lines.
  ENDMETHOD.

  METHOD header_only.
    DATA ls_diff TYPE zcl_alloc_diff=>ty_result.

    DATA(lt_lines) = mo_cut->build( ls_diff ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ]
      exp = 'REQUIREMENT_ID;OLD_QTY;NEW_QTY;DELTA_QTY;CHANGE_TYPE' ).
  ENDMETHOD.

  METHOD one_line.
    DATA ls_diff TYPE zcl_alloc_diff=>ty_result.

    ls_diff = diff_with( iv_id = 'REQ-1' iv_old = '5' iv_new = '8'
                         iv_change = '~' ).

    DATA(lt_lines) = mo_cut->build( ls_diff ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = 'REQ-1;5.000;8.000;3.000;~' ).
  ENDMETHOD.

  METHOD two_lines.
    DATA ls_diff TYPE zcl_alloc_diff=>ty_result.
    DATA ls_line TYPE zcl_alloc_diff=>ty_line.

    ls_diff = diff_with( iv_id = 'REQ-1' iv_old = '0' iv_new = '4'
                         iv_change = '+' ).

    ls_line-requirement_id = 'REQ-2'.
    ls_line-old_qty = '9'.
    ls_line-new_qty = '0'.
    ls_line-delta_qty = '-9'.
    ls_line-change_type = '-'.
    APPEND ls_line TO ls_diff-lines.

    DATA(lt_lines) = mo_cut->build( ls_diff ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ]
                                        exp = 'REQ-2;9.000;0.000;-9.000;-' ).
  ENDMETHOD.

ENDCLASS.
