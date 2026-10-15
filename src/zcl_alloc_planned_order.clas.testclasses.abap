CLASS ltcl_alloc_planned_order DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_planned_order.

    METHODS setup.

    METHODS proposes_lot   FOR TESTING.
    METHODS needed_rule    FOR TESTING.
    METHODS respects_min   FOR TESTING.
    METHODS no_requirement FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_planned_order IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_planned_order( ).
  ENDMETHOD.

  METHOD proposes_lot.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->proposal( iv_net_req = 30 iv_lot_size = 20 )
      exp = 40 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->proposal( iv_net_req = 30 iv_lot_size = 0 )
      exp = 30 ).
  ENDMETHOD.

  METHOD needed_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_needed( 30 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_needed( 0 ) exp = abap_false ).
  ENDMETHOD.

  METHOD respects_min.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->quantity( iv_net_req = 30 iv_min_order = 50 )
      exp = 50 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->quantity( iv_net_req = 30 iv_min_order = 10 )
      exp = 30 ).
  ENDMETHOD.

  METHOD no_requirement.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->quantity( iv_net_req = 0 iv_min_order = 50 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
