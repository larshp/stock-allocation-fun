CLASS ltcl_alloc_e2e_scenario DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_e2e_scenario.
    DATA mt_res TYPE zcl_stock_allocator=>ty_result_tt.
    DATA mt_pos TYPE zcl_alloc_stock_guard=>ty_position_tt.

    METHODS setup.

    METHODS add_line
      IMPORTING
        iv_id    TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_req   TYPE menge_d
        iv_alloc TYPE menge_d.

    METHODS add_position
      IMPORTING
        iv_lgort TYPE lgort_d
        iv_open  TYPE menge_d
        iv_move  TYPE menge_d.

    METHODS run_of
      IMPORTING
        iv_available      TYPE menge_d
      RETURNING
        VALUE(rs_verdict) TYPE zcl_alloc_e2e_scenario=>ty_verdict.

    METHODS clean_run_is_ok   FOR TESTING.
    METHODS negative_blocks   FOR TESTING.
    METHODS over_blocks       FOR TESTING.
    METHODS stock_blocks      FOR TESTING.
    METHODS empty_run_is_ok   FOR TESTING.
    METHODS totals_are_carried FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_e2e_scenario IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_e2e_scenario( ).
  ENDMETHOD.

  METHOD add_line.
    DATA ls_line TYPE zcl_stock_allocator=>ty_result.
    DATA ls_alloc TYPE zcl_stock_allocator=>ty_allocation.

    ls_line-requirement_id = iv_id.
    ls_line-requested_qty = iv_req.
    ls_line-allocated_qty = iv_alloc.
    ls_line-shortage_qty = iv_req - iv_alloc.

    IF iv_alloc > 0.
      ls_alloc-quantity = iv_alloc.
      APPEND ls_alloc TO ls_line-allocations.
    ENDIF.

    APPEND ls_line TO mt_res.
  ENDMETHOD.

  METHOD add_position.
    DATA ls_position TYPE zcl_alloc_stock_guard=>ty_position.

    ls_position-lgort = iv_lgort.
    ls_position-opening = iv_open.
    ls_position-movement = iv_move.
    APPEND ls_position TO mt_pos.
  ENDMETHOD.

  METHOD run_of.
    rs_verdict = mo_cut->run( it_result    = mt_res
                              iv_available = iv_available
                              it_positions = mt_pos ).
  ENDMETHOD.

  METHOD clean_run_is_ok.
    add_line( iv_id = 'R1' iv_req = 10 iv_alloc = 10 ).
    add_line( iv_id = 'R2' iv_req = 5 iv_alloc = 3 ).
    add_position( iv_lgort = '0001' iv_open = 100 iv_move = -13 ).

    DATA(ls_verdict) = run_of( iv_available = 20 ).

    cl_abap_unit_assert=>assert_equals( act = ls_verdict-posting_ok exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_verdict-reason exp = 'ok' ).
    cl_abap_unit_assert=>assert_equals( act = ls_verdict-rules_failed exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_verdict-stock_alerts exp = 0 ).
  ENDMETHOD.

  METHOD negative_blocks.
    add_line( iv_id = 'R1' iv_req = 10 iv_alloc = -2 ).

    DATA(ls_verdict) = run_of( iv_available = 20 ).

    cl_abap_unit_assert=>assert_equals( act = ls_verdict-posting_ok exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = ls_verdict-reason exp = 'no_negative' ).

    " A negative quantity also breaks the trace rule, because no allocation
    " detail can sum to a negative quantity.
    cl_abap_unit_assert=>assert_equals( act = ls_verdict-rules_failed exp = 2 ).
  ENDMETHOD.

  METHOD over_blocks.
    add_line( iv_id = 'R1' iv_req = 4 iv_alloc = 9 ).

    DATA(ls_verdict) = run_of( iv_available = 20 ).

    cl_abap_unit_assert=>assert_equals( act = ls_verdict-posting_ok exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_verdict-reason exp = 'not_over_requested' ).
  ENDMETHOD.

  METHOD stock_blocks.
    add_line( iv_id = 'R1' iv_req = 10 iv_alloc = 10 ).
    add_position( iv_lgort = '0001' iv_open = 5 iv_move = -9 ).

    DATA(ls_verdict) = run_of( iv_available = 20 ).

    cl_abap_unit_assert=>assert_equals( act = ls_verdict-posting_ok exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_verdict-reason exp = 'stock would go negative' ).
    cl_abap_unit_assert=>assert_equals( act = ls_verdict-rules_failed exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_verdict-stock_alerts exp = 1 ).
  ENDMETHOD.

  METHOD empty_run_is_ok.
    DATA(ls_verdict) = run_of( iv_available = 0 ).

    cl_abap_unit_assert=>assert_equals( act = ls_verdict-lines exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_verdict-posting_ok exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_verdict-reason exp = 'ok' ).
  ENDMETHOD.

  METHOD totals_are_carried.
    add_line( iv_id = 'R1' iv_req = 10 iv_alloc = 10 ).
    add_line( iv_id = 'R2' iv_req = 5 iv_alloc = 3 ).

    DATA(ls_verdict) = run_of( iv_available = 20 ).

    cl_abap_unit_assert=>assert_equals( act = ls_verdict-lines exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_verdict-requested exp = 15 ).
    cl_abap_unit_assert=>assert_equals( act = ls_verdict-allocated exp = 13 ).
    cl_abap_unit_assert=>assert_equals( act = ls_verdict-shortage exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_verdict-posting_ok exp = abap_true ).
  ENDMETHOD.

ENDCLASS.
