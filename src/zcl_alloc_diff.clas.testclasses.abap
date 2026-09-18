CLASS ltcl_alloc_diff DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_diff.

    METHODS setup.

    METHODS add_line
      IMPORTING
        it_result        TYPE zcl_stock_allocator=>ty_result_tt
        iv_id            TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_allocated     TYPE menge_d
      RETURNING
        VALUE(rt_result) TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS added_line             FOR TESTING.
    METHODS removed_line           FOR TESTING.
    METHODS changed_line           FOR TESTING.
    METHODS unchanged_hidden       FOR TESTING.
    METHODS include_unchanged      FOR TESTING.
    METHODS summary_totals         FOR TESTING.
    METHODS reduced_to_zero_changed FOR TESTING.
    METHODS empty_both_empty       FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_diff IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_diff( ).
  ENDMETHOD.

  METHOD add_line.
    DATA ls_line TYPE zcl_stock_allocator=>ty_result.

    rt_result = it_result.

    ls_line-requirement_id = iv_id.
    ls_line-allocated_qty = iv_allocated.

    APPEND ls_line TO rt_result.
  ENDMETHOD.

  METHOD added_line.
    DATA lt_old TYPE zcl_stock_allocator=>ty_result_tt.
    DATA lt_new TYPE zcl_stock_allocator=>ty_result_tt.

    lt_new = add_line( it_result    = lt_new
                       iv_id        = 'REQ-1'
                       iv_allocated = '5' ).

    DATA(ls_result) = mo_cut->compare( it_old = lt_old
                                       it_new = lt_new ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-lines )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-lines[ 1 ]-change_type
                                        exp = '+' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-lines[ 1 ]-delta_qty
                                        exp = '5' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-summary-added
                                        exp = 1 ).
  ENDMETHOD.

  METHOD removed_line.
    DATA lt_old TYPE zcl_stock_allocator=>ty_result_tt.
    DATA lt_new TYPE zcl_stock_allocator=>ty_result_tt.

    lt_old = add_line( it_result    = lt_old
                       iv_id        = 'REQ-1'
                       iv_allocated = '5' ).

    DATA(ls_result) = mo_cut->compare( it_old = lt_old
                                       it_new = lt_new ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-lines )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-lines[ 1 ]-change_type
                                        exp = '-' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-lines[ 1 ]-delta_qty
                                        exp = '-5' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-summary-removed
                                        exp = 1 ).
  ENDMETHOD.

  METHOD changed_line.
    DATA lt_old TYPE zcl_stock_allocator=>ty_result_tt.
    DATA lt_new TYPE zcl_stock_allocator=>ty_result_tt.

    lt_old = add_line( it_result    = lt_old
                       iv_id        = 'REQ-1'
                       iv_allocated = '5' ).
    lt_new = add_line( it_result    = lt_new
                       iv_id        = 'REQ-1'
                       iv_allocated = '3' ).

    DATA(ls_result) = mo_cut->compare( it_old = lt_old
                                       it_new = lt_new ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-lines )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-lines[ 1 ]-change_type
                                        exp = '~' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-lines[ 1 ]-delta_qty
                                        exp = '-2' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-summary-changed
                                        exp = 1 ).
  ENDMETHOD.

  METHOD unchanged_hidden.
    DATA lt_old TYPE zcl_stock_allocator=>ty_result_tt.
    DATA lt_new TYPE zcl_stock_allocator=>ty_result_tt.

    lt_old = add_line( it_result    = lt_old
                       iv_id        = 'REQ-1'
                       iv_allocated = '5' ).
    lt_new = add_line( it_result    = lt_new
                       iv_id        = 'REQ-1'
                       iv_allocated = '5' ).

    DATA(ls_result) = mo_cut->compare( it_old = lt_old
                                       it_new = lt_new ).

    cl_abap_unit_assert=>assert_initial( act = ls_result-lines ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-summary-unchanged
                                        exp = 1 ).
  ENDMETHOD.

  METHOD include_unchanged.
    DATA lt_old TYPE zcl_stock_allocator=>ty_result_tt.
    DATA lt_new TYPE zcl_stock_allocator=>ty_result_tt.

    lt_old = add_line( it_result    = lt_old
                       iv_id        = 'REQ-1'
                       iv_allocated = '5' ).
    lt_new = add_line( it_result    = lt_new
                       iv_id        = 'REQ-1'
                       iv_allocated = '5' ).

    DATA(ls_result) = mo_cut->compare( it_old               = lt_old
                                       it_new               = lt_new
                                       iv_include_unchanged = abap_true ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-lines )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-lines[ 1 ]-change_type
                                        exp = '=' ).
  ENDMETHOD.

  METHOD summary_totals.
    DATA lt_old TYPE zcl_stock_allocator=>ty_result_tt.
    DATA lt_new TYPE zcl_stock_allocator=>ty_result_tt.

    lt_old = add_line( it_result    = lt_old
                       iv_id        = 'REQ-1'
                       iv_allocated = '5' ).
    lt_new = add_line( it_result    = lt_new
                       iv_id        = 'REQ-1'
                       iv_allocated = '3' ).
    lt_new = add_line( it_result    = lt_new
                       iv_id        = 'REQ-2'
                       iv_allocated = '4' ).

    DATA(ls_result) = mo_cut->compare( it_old = lt_old
                                       it_new = lt_new ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-summary-old_total
                                        exp = '5' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-summary-new_total
                                        exp = '7' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-summary-delta_total
                                        exp = '2' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-summary-changed
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-summary-added
                                        exp = 1 ).
  ENDMETHOD.

  METHOD reduced_to_zero_changed.
    DATA lt_old TYPE zcl_stock_allocator=>ty_result_tt.
    DATA lt_new TYPE zcl_stock_allocator=>ty_result_tt.

    lt_old = add_line( it_result    = lt_old
                       iv_id        = 'REQ-1'
                       iv_allocated = '5' ).
    lt_new = add_line( it_result    = lt_new
                       iv_id        = 'REQ-1'
                       iv_allocated = '0' ).

    DATA(ls_result) = mo_cut->compare( it_old = lt_old
                                       it_new = lt_new ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-lines[ 1 ]-change_type
                                        exp = '~' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-summary-removed
                                        exp = 0 ).
  ENDMETHOD.

  METHOD empty_both_empty.
    DATA lt_old TYPE zcl_stock_allocator=>ty_result_tt.
    DATA lt_new TYPE zcl_stock_allocator=>ty_result_tt.

    DATA(ls_result) = mo_cut->compare( it_old = lt_old
                                       it_new = lt_new ).

    cl_abap_unit_assert=>assert_initial( act = ls_result-lines ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-summary-delta_total
                                        exp = '0' ).
  ENDMETHOD.

ENDCLASS.
