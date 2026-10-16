CLASS ltcl_alloc_stdcost_update DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_stdcost_update.

    METHODS setup.

    METHODS refreshes_cost FOR TESTING.
    METHODS changed_rule   FOR TESTING.
    METHODS reads_percent  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_stdcost_update IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_stdcost_update( ).
  ENDMETHOD.

  METHOD refreshes_cost.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->refresh( iv_current = 100 iv_new = 105 ) exp = 105 ).
  ENDMETHOD.

  METHOD changed_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_changed( iv_current = 100 iv_new = 105 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_changed( iv_current = 100 iv_new = 100 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD reads_percent.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->delta_percent( iv_current = 100 iv_new = 105 )
      exp = 5 ).
  ENDMETHOD.

ENDCLASS.
