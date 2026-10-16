CLASS ltcl_alloc_mrp_net DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_mrp_net.

    METHODS setup.

    METHODS make_input
      IMPORTING
        iv_demand       TYPE menge_d
        iv_stock        TYPE menge_d
        iv_sched        TYPE menge_d
        iv_safety       TYPE menge_d
      RETURNING
        VALUE(rs_input) TYPE zcl_alloc_mrp_net=>ty_input.

    METHODS no_demand         FOR TESTING.
    METHODS stock_covers      FOR TESTING.
    METHODS net_is_shortfall  FOR TESTING.
    METHODS scheduled_helps   FOR TESTING.
    METHODS safety_stock_blocks FOR TESTING.
    METHODS negative_stock    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_mrp_net IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_mrp_net( ).
  ENDMETHOD.

  METHOD make_input.
    rs_input-demand = iv_demand.
    rs_input-stock = iv_stock.
    rs_input-scheduled_in = iv_sched.
    rs_input-safety_stock = iv_safety.
  ENDMETHOD.

  METHOD no_demand.
    DATA(ls_input) = make_input( iv_demand = 0 iv_stock = 50
                                 iv_sched = 0 iv_safety = 0 ).
    DATA(ls_result) = mo_cut->calculate( ls_input ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-net_requirement exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-available exp = 50 ).
  ENDMETHOD.

  METHOD stock_covers.
    DATA(ls_input) = make_input( iv_demand = 100 iv_stock = 200
                                 iv_sched = 0 iv_safety = 0 ).
    DATA(ls_result) = mo_cut->calculate( ls_input ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-net_requirement exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-covered exp = 100 ).
  ENDMETHOD.

  METHOD net_is_shortfall.
    DATA(ls_input) = make_input( iv_demand = 100 iv_stock = 40
                                 iv_sched = 0 iv_safety = 0 ).
    DATA(ls_result) = mo_cut->calculate( ls_input ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-net_requirement exp = 60 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-covered exp = 40 ).
  ENDMETHOD.

  METHOD scheduled_helps.
    DATA(ls_input) = make_input( iv_demand = 100 iv_stock = 40
                                 iv_sched = 30 iv_safety = 0 ).
    DATA(ls_result) = mo_cut->calculate( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-available exp = 70 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-net_requirement exp = 30 ).
  ENDMETHOD.

  METHOD safety_stock_blocks.
    DATA(ls_input) = make_input( iv_demand = 100 iv_stock = 50
                                 iv_sched = 0 iv_safety = 80 ).
    DATA(ls_result) = mo_cut->calculate( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-available exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-net_requirement exp = 100 ).
  ENDMETHOD.

  METHOD negative_stock.
    DATA(ls_input) = make_input( iv_demand = 10 iv_stock = -20
                                 iv_sched = 0 iv_safety = 0 ).
    DATA(ls_result) = mo_cut->calculate( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-available exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-net_requirement exp = 10 ).
  ENDMETHOD.

ENDCLASS.
