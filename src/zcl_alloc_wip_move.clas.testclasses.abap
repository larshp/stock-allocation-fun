CLASS ltcl_alloc_wip_move DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_wip_move.

    METHODS setup.

    METHODS moves_value    FOR TESTING.
    METHODS increased_rule FOR TESTING.
    METHODS computes_delta FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_wip_move IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_wip_move( ).
  ENDMETHOD.

  METHOD moves_value.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->move_by( iv_current = 100 iv_delta = 50 )
      exp = 150 ).
  ENDMETHOD.

  METHOD increased_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_increased( iv_current = 100 iv_new = 150 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_increased( iv_current = 100 iv_new = 80 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_delta.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->delta( iv_current = 100 iv_new = 150 )
      exp = 50 ).
  ENDMETHOD.

ENDCLASS.
