CLASS ltcl_alloc_run_audit DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_run_audit.
    DATA mt_res TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS setup.

    METHODS add_line
      IMPORTING
        iv_id    TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_req   TYPE menge_d
        iv_alloc TYPE menge_d
        iv_defer TYPE abap_bool.

    METHODS empty_run     FOR TESTING.
    METHODS totals_are_summed FOR TESTING.
    METHODS shortage_is_derived FOR TESTING.
    METHODS full_when_nothing_short FOR TESTING.
    METHODS over_allocation_detected FOR TESTING.
    METHODS negative_detected FOR TESTING.
    METHODS deferred_counted FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_run_audit IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_run_audit( ).
  ENDMETHOD.

  METHOD add_line.
    DATA ls_line TYPE zcl_stock_allocator=>ty_result.

    ls_line-requirement_id = iv_id.
    ls_line-requested_qty = iv_req.
    ls_line-allocated_qty = iv_alloc.
    ls_line-deferred = iv_defer.
    APPEND ls_line TO mt_res.
  ENDMETHOD.

  METHOD empty_run.
    DATA(ls_audit) = mo_cut->audit( mt_res ).

    cl_abap_unit_assert=>assert_equals( act = ls_audit-lines exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_audit-requested exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_audit-full exp = abap_false ).
  ENDMETHOD.

  METHOD totals_are_summed.
    add_line( iv_id = 'R1' iv_req = 10 iv_alloc = 10
              iv_defer = abap_false ).
    add_line( iv_id = 'R2' iv_req = 5 iv_alloc = 3
              iv_defer = abap_false ).

    DATA(ls_audit) = mo_cut->audit( mt_res ).

    cl_abap_unit_assert=>assert_equals( act = ls_audit-lines exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_audit-requested exp = 15 ).
    cl_abap_unit_assert=>assert_equals( act = ls_audit-allocated exp = 13 ).
  ENDMETHOD.

  METHOD shortage_is_derived.
    add_line( iv_id = 'R1' iv_req = 10 iv_alloc = 10
              iv_defer = abap_false ).
    add_line( iv_id = 'R2' iv_req = 5 iv_alloc = 3
              iv_defer = abap_false ).

    DATA(ls_audit) = mo_cut->audit( mt_res ).

    cl_abap_unit_assert=>assert_equals( act = ls_audit-shortage exp = 2 ).
  ENDMETHOD.

  METHOD full_when_nothing_short.
    add_line( iv_id = 'R1' iv_req = 10 iv_alloc = 10
              iv_defer = abap_false ).

    DATA(ls_audit) = mo_cut->audit( mt_res ).

    cl_abap_unit_assert=>assert_equals( act = ls_audit-shortage exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_audit-full exp = abap_true ).
  ENDMETHOD.

  METHOD over_allocation_detected.
    add_line( iv_id = 'R1' iv_req = 4 iv_alloc = 9
              iv_defer = abap_false ).

    DATA(ls_audit) = mo_cut->audit( mt_res ).

    cl_abap_unit_assert=>assert_equals( act = ls_audit-over_alloc exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_audit-shortage exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_audit-full exp = abap_true ).
  ENDMETHOD.

  METHOD negative_detected.
    add_line( iv_id = 'R1' iv_req = 10 iv_alloc = -2
              iv_defer = abap_false ).

    DATA(ls_audit) = mo_cut->audit( mt_res ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_audit-has_negative exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_audit-allocated exp = -2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_audit-shortage exp = 12 ).
  ENDMETHOD.

  METHOD deferred_counted.
    add_line( iv_id = 'R1' iv_req = 10 iv_alloc = 0
              iv_defer = abap_true ).
    add_line( iv_id = 'R2' iv_req = 5 iv_alloc = 5
              iv_defer = abap_false ).

    DATA(ls_audit) = mo_cut->audit( mt_res ).

    cl_abap_unit_assert=>assert_equals( act = ls_audit-deferred exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_audit-shortage exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = ls_audit-full exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
