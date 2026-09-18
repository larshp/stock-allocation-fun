CLASS ltcl_alloc_feasible DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_feasible.

    METHODS setup.

    METHODS make_input
      IMPORTING
        iv_demand       TYPE menge_d
        iv_supply       TYPE menge_d
        iv_min          TYPE menge_d
        iv_max          TYPE menge_d
        iv_lot          TYPE menge_d
      RETURNING
        VALUE(rs_input) TYPE zcl_alloc_feasible=>ty_input.

    METHODS no_demand          FOR TESTING.
    METHODS plain_order_ok     FOR TESTING.
    METHODS insufficient_supply FOR TESTING.
    METHODS below_minimum      FOR TESTING.
    METHODS rounds_up_to_lot   FOR TESTING.
    METHODS splits_over_max    FOR TESTING.
    METHODS order_over_supply  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_feasible IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_feasible( ).
  ENDMETHOD.

  METHOD make_input.
    rs_input-demand = iv_demand.
    rs_input-supply = iv_supply.
    rs_input-min_order = iv_min.
    rs_input-max_order = iv_max.
    rs_input-lot_size = iv_lot.
  ENDMETHOD.

  METHOD no_demand.
    DATA(ls_input) = make_input( iv_demand = 0 iv_supply = 0 iv_min = 0
                                 iv_max = 0 iv_lot = 0 ).
    DATA(ls_result) = mo_cut->check( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-feasible exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-reason exp = 'no demand' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-orders exp = 0 ).
  ENDMETHOD.

  METHOD plain_order_ok.
    DATA(ls_input) = make_input( iv_demand = 10 iv_supply = 10 iv_min = 0
                                 iv_max = 0 iv_lot = 0 ).
    DATA(ls_result) = mo_cut->check( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-feasible exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-reason exp = 'ok' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-orders exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-order_qty exp = 10 ).
  ENDMETHOD.

  METHOD insufficient_supply.
    DATA(ls_input) = make_input( iv_demand = 10 iv_supply = 9 iv_min = 0
                                 iv_max = 0 iv_lot = 0 ).
    DATA(ls_result) = mo_cut->check( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-feasible exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-reason exp = 'insufficient supply' ).
  ENDMETHOD.

  METHOD below_minimum.
    DATA(ls_input) = make_input( iv_demand = 3 iv_supply = 100 iv_min = 5
                                 iv_max = 0 iv_lot = 0 ).
    DATA(ls_result) = mo_cut->check( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-feasible exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-reason exp = 'demand below minimum order quantity' ).
  ENDMETHOD.

  METHOD rounds_up_to_lot.
    DATA(ls_input) = make_input( iv_demand = 7 iv_supply = 100 iv_min = 0
                                 iv_max = 0 iv_lot = 5 ).
    DATA(ls_result) = mo_cut->check( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-feasible exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-order_qty exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-orders exp = 1 ).
  ENDMETHOD.

  METHOD splits_over_max.
    DATA(ls_input) = make_input( iv_demand = 25 iv_supply = 100 iv_min = 0
                                 iv_max = 10 iv_lot = 0 ).
    DATA(ls_result) = mo_cut->check( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-feasible exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-orders exp = 3 ).
  ENDMETHOD.

  METHOD order_over_supply.
    DATA(ls_input) = make_input( iv_demand = 7 iv_supply = 8 iv_min = 0
                                 iv_max = 0 iv_lot = 5 ).
    DATA(ls_result) = mo_cut->check( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-feasible exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-reason exp = 'order exceeds supply' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-orders exp = 0 ).
  ENDMETHOD.

ENDCLASS.
