CLASS ltcl_alloc_sensitivity DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_sensitivity.

    METHODS setup.

    METHODS make_input
      IMPORTING
        iv_stock        TYPE menge_d
        iv_demand       TYPE menge_d
        iv_steps        TYPE i
        iv_pct          TYPE i
      RETURNING
        VALUE(rs_input) TYPE zcl_alloc_sensitivity=>ty_input.

    METHODS three_readings   FOR TESTING.
    METHODS stock_drives_qty FOR TESTING.
    METHODS demand_caps      FOR TESTING.
    METHODS zero_steps       FOR TESTING.
    METHODS never_negative   FOR TESTING.
    METHODS shifted_center   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_sensitivity IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_sensitivity( ).
  ENDMETHOD.

  METHOD make_input.
    rs_input-base_stock = iv_stock.
    rs_input-demand = iv_demand.
    rs_input-steps = iv_steps.
    rs_input-step_pct = iv_pct.
  ENDMETHOD.

  METHOD three_readings.
    DATA(ls_input) = make_input( iv_stock = 100 iv_demand = 80
                                 iv_steps = 1 iv_pct = 50 ).
    DATA(lt_readings) = mo_cut->analyze( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_readings ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_readings[ 1 ]-delta_pct exp = -50 ).
    cl_abap_unit_assert=>assert_equals( act = lt_readings[ 2 ]-delta_pct exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lt_readings[ 3 ]-delta_pct exp = 50 ).
  ENDMETHOD.

  METHOD stock_drives_qty.
    DATA(ls_input) = make_input( iv_stock = 100 iv_demand = 80
                                 iv_steps = 1 iv_pct = 50 ).
    DATA(lt_readings) = mo_cut->analyze( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lt_readings[ 1 ]-stock exp = 50 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_readings[ 1 ]-allocated exp = 50 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_readings[ 1 ]-delta_qty exp = -30 ).
  ENDMETHOD.

  METHOD demand_caps.
    DATA(ls_input) = make_input( iv_stock = 100 iv_demand = 80
                                 iv_steps = 1 iv_pct = 50 ).
    DATA(lt_readings) = mo_cut->analyze( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lt_readings[ 2 ]-allocated exp = 80 ).
    cl_abap_unit_assert=>assert_equals( act = lt_readings[ 2 ]-delta_qty exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lt_readings[ 3 ]-allocated exp = 80 ).
    cl_abap_unit_assert=>assert_equals( act = lt_readings[ 3 ]-delta_qty exp = 0 ).
  ENDMETHOD.

  METHOD zero_steps.
    DATA(ls_input) = make_input( iv_stock = 100 iv_demand = 80
                                 iv_steps = 0 iv_pct = 50 ).
    DATA(lt_readings) = mo_cut->analyze( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_readings ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_readings[ 1 ]-delta_pct exp = 0 ).
  ENDMETHOD.

  METHOD never_negative.
    DATA(ls_input) = make_input( iv_stock = 10 iv_demand = 100
                                 iv_steps = 3 iv_pct = 100 ).
    DATA(lt_readings) = mo_cut->analyze( ls_input ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_readings[ 1 ]-stock exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_readings[ 1 ]-allocated exp = 0 ).
  ENDMETHOD.

  METHOD shifted_center.
    DATA(ls_input) = make_input( iv_stock = 200 iv_demand = 200
                                 iv_steps = 2 iv_pct = 10 ).
    DATA(lt_readings) = mo_cut->analyze( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_readings ) exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = lt_readings[ 1 ]-delta_pct exp = -20 ).
    cl_abap_unit_assert=>assert_equals( act = lt_readings[ 5 ]-delta_pct exp = 20 ).
    cl_abap_unit_assert=>assert_equals( act = lt_readings[ 5 ]-stock exp = 240 ).
  ENDMETHOD.

ENDCLASS.
