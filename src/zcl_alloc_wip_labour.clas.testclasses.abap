CLASS ltcl_alloc_wip_labour DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_wip_labour.

    METHODS setup.

    METHODS computes_cost    FOR TESTING.
    METHODS computes_applied FOR TESTING.
    METHODS reads_balance    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_wip_labour IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_wip_labour( ).
  ENDMETHOD.

  METHOD computes_cost.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->labour_cost( iv_hours = 10 iv_rate = 20 )
      exp = 200 ).
  ENDMETHOD.

  METHOD computes_applied.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->applied( iv_budget = 1000 iv_percent = 40 )
      exp = 400 ).
  ENDMETHOD.

  METHOD reads_balance.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->balance( iv_budget = 1000 iv_applied = 400 )
      exp = 600 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->balance( iv_budget = 1000 iv_applied = 1200 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
