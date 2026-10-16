CLASS ltcl_alloc_invariant_check DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_invariant_check.
    DATA mt_res TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS setup.

    METHODS add_line
      IMPORTING
        iv_id            TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_req           TYPE menge_d
        iv_alloc         TYPE menge_d
        iv_missing_trace TYPE abap_bool.

    METHODS check_of
      IMPORTING
        iv_available     TYPE menge_d
      RETURNING
        VALUE(rt_checks) TYPE zcl_alloc_invariant_check=>ty_check_tt.

    METHODS rule_ok
      IMPORTING
        it_checks    TYPE zcl_alloc_invariant_check=>ty_check_tt
        iv_rule      TYPE string
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS empty_result   FOR TESTING.
    METHODS good_result    FOR TESTING.
    METHODS negative_quantity FOR TESTING.
    METHODS over_requested FOR TESTING.
    METHODS shortage_mismatch FOR TESTING.
    METHODS exceeds_available FOR TESTING.
    METHODS missing_trace  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_invariant_check IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_invariant_check( ).
  ENDMETHOD.

  METHOD add_line.
    DATA ls_line  TYPE zcl_stock_allocator=>ty_result.
    DATA ls_alloc TYPE zcl_stock_allocator=>ty_allocation.

    ls_line-requirement_id = iv_id.
    ls_line-requested_qty = iv_req.
    ls_line-allocated_qty = iv_alloc.
    ls_line-shortage_qty = iv_req - iv_alloc.

    IF iv_missing_trace = abap_false AND iv_alloc <> 0.
      ls_alloc-quantity = iv_alloc.
      APPEND ls_alloc TO ls_line-allocations.
    ENDIF.

    APPEND ls_line TO mt_res.
  ENDMETHOD.

  METHOD check_of.
    rt_checks = mo_cut->check( it_result    = mt_res
                               iv_available = iv_available ).
  ENDMETHOD.

  METHOD rule_ok.
    READ TABLE it_checks INTO DATA(ls_check) WITH KEY rule_id = iv_rule.
    IF sy-subrc = 0.
      rv_ok = ls_check-ok.
    ENDIF.
  ENDMETHOD.

  METHOD empty_result.
    DATA(lt_checks) = check_of( iv_available = 100 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_checks ) exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_clean( lt_checks ) exp = abap_true ).
  ENDMETHOD.

  METHOD good_result.
    add_line( iv_id = 'R1' iv_req = 10 iv_alloc = 10
              iv_missing_trace = abap_false ).
    add_line( iv_id = 'R2' iv_req = 5 iv_alloc = 3
              iv_missing_trace = abap_false ).

    DATA(lt_checks) = check_of( iv_available = 20 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_clean( lt_checks ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = rule_ok( it_checks = lt_checks iv_rule = 'no_negative' )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = rule_ok( it_checks = lt_checks iv_rule = 'within_available' )
      exp = abap_true ).
  ENDMETHOD.

  METHOD negative_quantity.
    add_line( iv_id = 'R1' iv_req = 10 iv_alloc = -2
              iv_missing_trace = abap_false ).

    DATA(lt_checks) = check_of( iv_available = 20 ).

    cl_abap_unit_assert=>assert_equals(
      act = rule_ok( it_checks = lt_checks iv_rule = 'no_negative' )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_clean( lt_checks ) exp = abap_false ).
  ENDMETHOD.

  METHOD over_requested.
    add_line( iv_id = 'R1' iv_req = 4 iv_alloc = 9
              iv_missing_trace = abap_false ).

    DATA(lt_checks) = check_of( iv_available = 20 ).

    cl_abap_unit_assert=>assert_equals(
      act = rule_ok( it_checks = lt_checks iv_rule = 'not_over_requested' )
      exp = abap_false ).
  ENDMETHOD.

  METHOD shortage_mismatch.
    DATA ls_line TYPE zcl_stock_allocator=>ty_result.

    ls_line-requirement_id = 'R1'.
    ls_line-requested_qty = 10.
    ls_line-allocated_qty = 10.
    ls_line-shortage_qty = 7.
    APPEND ls_line TO mt_res.

    DATA(lt_checks) = check_of( iv_available = 20 ).

    cl_abap_unit_assert=>assert_equals(
      act = rule_ok( it_checks = lt_checks iv_rule = 'shortage_consistent' )
      exp = abap_false ).
  ENDMETHOD.

  METHOD exceeds_available.
    add_line( iv_id = 'R1' iv_req = 10 iv_alloc = 10
              iv_missing_trace = abap_false ).
    add_line( iv_id = 'R2' iv_req = 10 iv_alloc = 10
              iv_missing_trace = abap_false ).

    DATA(lt_checks) = check_of( iv_available = 15 ).

    cl_abap_unit_assert=>assert_equals(
      act = rule_ok( it_checks = lt_checks iv_rule = 'within_available' )
      exp = abap_false ).
  ENDMETHOD.

  METHOD missing_trace.
    add_line( iv_id = 'R1' iv_req = 10 iv_alloc = 10
              iv_missing_trace = abap_true ).

    DATA(lt_checks) = check_of( iv_available = 20 ).

    cl_abap_unit_assert=>assert_equals(
      act = rule_ok( it_checks = lt_checks iv_rule = 'trace_present' )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
