CLASS ltcl_alloc_replenishment DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_replenishment.

    METHODS setup.

    METHODS add_line
      IMPORTING
        it_result        TYPE zcl_stock_allocator=>ty_result_tt
        iv_id            TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_requested     TYPE menge_d
        iv_allocated     TYPE menge_d
      RETURNING
        VALUE(rt_result) TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS shortage_proposal      FOR TESTING.
    METHODS full_delivery_skipped  FOR TESTING.
    METHODS rounds_up_to_multiple  FOR TESTING.
    METHODS exact_multiple_kept    FOR TESTING.
    METHODS respects_min_order     FOR TESTING.
    METHODS rounding_off           FOR TESTING.
    METHODS summary_totals         FOR TESTING.
    METHODS empty_result_is_empty  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_replenishment IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_replenishment( ).
  ENDMETHOD.

  METHOD add_line.
    DATA ls_line TYPE zcl_stock_allocator=>ty_result.

    rt_result = it_result.

    ls_line-requirement_id = iv_id.
    ls_line-requested_qty = iv_requested.
    ls_line-allocated_qty = iv_allocated.
    ls_line-shortage_qty = iv_requested - iv_allocated.

    APPEND ls_line TO rt_result.
  ENDMETHOD.

  METHOD shortage_proposal.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    lt_result = add_line( it_result    = lt_result
                          iv_id        = 'REQ-1'
                          iv_requested = '10'
                          iv_allocated = '6' ).

    DATA(ls_proposal) = mo_cut->build( iv_matnr  = 'MAT-1'
                                       it_result = lt_result ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_proposal-proposals )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_proposal-proposals[ 1 ]-matnr exp = 'MAT-1' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_proposal-proposals[ 1 ]-shortage_qty exp = '4' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_proposal-proposals[ 1 ]-order_qty exp = '4' ).
  ENDMETHOD.

  METHOD full_delivery_skipped.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    lt_result = add_line( it_result    = lt_result
                          iv_id        = 'REQ-1'
                          iv_requested = '10'
                          iv_allocated = '10' ).

    DATA(ls_proposal) = mo_cut->build( iv_matnr  = 'MAT-1'
                                       it_result = lt_result ).

    cl_abap_unit_assert=>assert_initial( act = ls_proposal-proposals ).
    cl_abap_unit_assert=>assert_equals( act = ls_proposal-summary-proposals
                                        exp = 0 ).
  ENDMETHOD.

  METHOD rounds_up_to_multiple.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    lt_result = add_line( it_result    = lt_result
                          iv_id        = 'REQ-1'
                          iv_requested = '10'
                          iv_allocated = '0' ).

    DATA(ls_proposal) = mo_cut->build( iv_matnr    = 'MAT-1'
                                       it_result   = lt_result
                                       iv_round_to = '3' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_proposal-proposals[ 1 ]-order_qty exp = '12' ).
  ENDMETHOD.

  METHOD exact_multiple_kept.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    lt_result = add_line( it_result    = lt_result
                          iv_id        = 'REQ-1'
                          iv_requested = '10'
                          iv_allocated = '4' ).

    DATA(ls_proposal) = mo_cut->build( iv_matnr    = 'MAT-1'
                                       it_result   = lt_result
                                       iv_round_to = '3' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_proposal-proposals[ 1 ]-order_qty exp = '6' ).
  ENDMETHOD.

  METHOD respects_min_order.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    lt_result = add_line( it_result    = lt_result
                          iv_id        = 'REQ-1'
                          iv_requested = '10'
                          iv_allocated = '9' ).

    DATA(ls_proposal) = mo_cut->build( iv_matnr     = 'MAT-1'
                                       it_result    = lt_result
                                       iv_min_order = '5' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_proposal-proposals[ 1 ]-shortage_qty exp = '1' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_proposal-proposals[ 1 ]-order_qty exp = '5' ).
  ENDMETHOD.

  METHOD rounding_off.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    lt_result = add_line( it_result    = lt_result
                          iv_id        = 'REQ-1'
                          iv_requested = '10'
                          iv_allocated = '3' ).

    DATA(ls_proposal) = mo_cut->build( iv_matnr  = 'MAT-1'
                                       it_result = lt_result ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_proposal-proposals[ 1 ]-order_qty exp = '7' ).
  ENDMETHOD.

  METHOD summary_totals.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    lt_result = add_line( it_result    = lt_result
                          iv_id        = 'REQ-1'
                          iv_requested = '10'
                          iv_allocated = '6' ).
    lt_result = add_line( it_result    = lt_result
                          iv_id        = 'REQ-2'
                          iv_requested = '10'
                          iv_allocated = '10' ).

    DATA(ls_proposal) = mo_cut->build( iv_matnr  = 'MAT-1'
                                       it_result = lt_result ).

    cl_abap_unit_assert=>assert_equals( act = ls_proposal-summary-proposals
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_proposal-summary-shortage_qty
                                        exp = '4' ).
    cl_abap_unit_assert=>assert_equals( act = ls_proposal-summary-order_qty
                                        exp = '4' ).
  ENDMETHOD.

  METHOD empty_result_is_empty.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    DATA(ls_proposal) = mo_cut->build( iv_matnr  = 'MAT-1'
                                       it_result = lt_result ).

    cl_abap_unit_assert=>assert_initial( act = ls_proposal-proposals ).
    cl_abap_unit_assert=>assert_equals( act = ls_proposal-summary-order_qty
                                        exp = '0' ).
  ENDMETHOD.

ENDCLASS.
