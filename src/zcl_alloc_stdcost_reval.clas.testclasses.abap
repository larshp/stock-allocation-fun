CLASS ltcl_alloc_stdcost_reval DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_stdcost_reval.

    METHODS setup.

    METHODS computes_reval    FOR TESTING.
    METHODS increased_rule    FOR TESTING.
    METHODS computes_delta    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_stdcost_reval IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_stdcost_reval( ).
  ENDMETHOD.

  METHOD computes_reval.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->revalue( iv_qty = 5 iv_new_unit_cost = 25 )
      exp = 125 ).
  ENDMETHOD.

  METHOD increased_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_increased( iv_old = 100 iv_new = 125 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_increased( iv_old = 100 iv_new = 80 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_delta.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->delta( iv_old = 100 iv_new = 125 ) exp = 25 ).
  ENDMETHOD.

ENDCLASS.
