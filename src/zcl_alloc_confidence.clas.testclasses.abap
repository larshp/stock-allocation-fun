CLASS ltcl_alloc_confidence DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_confidence.

    METHODS setup.

    METHODS empty_result  FOR TESTING.
    METHODS full_delivery FOR TESTING.
    METHODS partial_only  FOR TESTING.
    METHODS mixed_lines   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_confidence IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_confidence( ).
  ENDMETHOD.

  METHOD empty_result.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    DATA(rs_score) = mo_cut->assess( lt_result ).

    cl_abap_unit_assert=>assert_equals( act = rs_score-score exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = rs_score-requirements exp = 0 ).
  ENDMETHOD.

  METHOD full_delivery.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.
    DATA ls_line   TYPE zcl_stock_allocator=>ty_result.

    ls_line-requested_qty = '10'.
    ls_line-allocated_qty = '10'.
    ls_line-shortage_qty = '0'.
    APPEND ls_line TO lt_result.

    DATA(rs_score) = mo_cut->assess( lt_result ).

    cl_abap_unit_assert=>assert_equals( act = rs_score-coverage_pct exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = rs_score-fill_rate_pct exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = rs_score-score exp = 100 ).
  ENDMETHOD.

  METHOD partial_only.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.
    DATA ls_line   TYPE zcl_stock_allocator=>ty_result.

    ls_line-requested_qty = '10'.
    ls_line-allocated_qty = '6'.
    ls_line-shortage_qty = '4'.
    APPEND ls_line TO lt_result.

    DATA(rs_score) = mo_cut->assess( lt_result ).

    cl_abap_unit_assert=>assert_equals( act = rs_score-coverage_pct exp = 60 ).
    cl_abap_unit_assert=>assert_equals( act = rs_score-fill_rate_pct exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = rs_score-score exp = 30 ).
  ENDMETHOD.

  METHOD mixed_lines.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.
    DATA ls_line   TYPE zcl_stock_allocator=>ty_result.

    ls_line-requested_qty = '10'.
    ls_line-allocated_qty = '10'.
    ls_line-shortage_qty = '0'.
    APPEND ls_line TO lt_result.

    ls_line-requested_qty = '10'.
    ls_line-allocated_qty = '5'.
    ls_line-shortage_qty = '5'.
    APPEND ls_line TO lt_result.

    DATA(rs_score) = mo_cut->assess( lt_result ).

    cl_abap_unit_assert=>assert_equals( act = rs_score-coverage_pct exp = 75 ).
    cl_abap_unit_assert=>assert_equals( act = rs_score-fill_rate_pct exp = 50 ).
    cl_abap_unit_assert=>assert_equals( act = rs_score-score exp = 62 ).
  ENDMETHOD.

ENDCLASS.
