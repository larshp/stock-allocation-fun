CLASS ltcl_alloc_lot_ppb DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_lot_ppb.
    DATA mt_dem TYPE zcl_alloc_lot_ppb=>ty_series_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE menge_d.

    METHODS make_cost
      IMPORTING
        iv_setup       TYPE menge_d
        iv_unit        TYPE menge_d
        iv_holding     TYPE i
        iv_max         TYPE i
      RETURNING
        VALUE(rs_cost) TYPE zcl_alloc_lot_ppb=>ty_cost.

    METHODS empty_series   FOR TESTING.
    METHODS cheap_holding  FOR TESTING.
    METHODS dear_holding   FOR TESTING.
    METHODS max_periods_cap FOR TESTING.
    METHODS single_period  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_lot_ppb IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_lot_ppb( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_dem.
  ENDMETHOD.

  METHOD make_cost.
    rs_cost-setup_cost = iv_setup.
    rs_cost-unit_cost = iv_unit.
    rs_cost-holding_pct = iv_holding.
    rs_cost-max_periods = iv_max.
  ENDMETHOD.

  METHOD empty_series.
    DATA(ls_cost) = make_cost( iv_setup = 100 iv_unit = 1
                               iv_holding = 100 iv_max = 0 ).
    DATA(lt_lots) = mo_cut->size( it_demand = mt_dem
                                  is_cost   = ls_cost ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lots ) exp = 0 ).
  ENDMETHOD.

  METHOD cheap_holding.
    add( iv_value = 10 ).
    add( iv_value = 10 ).
    add( iv_value = 10 ).

    DATA(ls_cost) = make_cost( iv_setup = 100 iv_unit = 1
                               iv_holding = 100 iv_max = 0 ).
    DATA(lt_lots) = mo_cut->size( it_demand = mt_dem
                                  is_cost   = ls_cost ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lots ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lots[ 1 ]-period_to exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lots[ 1 ]-quantity exp = 30 ).
  ENDMETHOD.

  METHOD dear_holding.
    add( iv_value = 10 ).
    add( iv_value = 10 ).
    add( iv_value = 10 ).

    DATA(ls_cost) = make_cost( iv_setup = 20 iv_unit = 1
                               iv_holding = 100 iv_max = 0 ).
    DATA(lt_lots) = mo_cut->size( it_demand = mt_dem
                                  is_cost   = ls_cost ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lots ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lots[ 1 ]-period_from exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lots[ 1 ]-period_to exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lots[ 1 ]-quantity exp = 20 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lots[ 2 ]-period_from exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lots[ 2 ]-quantity exp = 10 ).
  ENDMETHOD.

  METHOD max_periods_cap.
    add( iv_value = 10 ).
    add( iv_value = 10 ).
    add( iv_value = 10 ).

    DATA(ls_cost) = make_cost( iv_setup = 1000 iv_unit = 1
                               iv_holding = 1 iv_max = 2 ).
    DATA(lt_lots) = mo_cut->size( it_demand = mt_dem
                                  is_cost   = ls_cost ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lots ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lots[ 1 ]-period_to exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lots[ 2 ]-period_from exp = 3 ).
  ENDMETHOD.

  METHOD single_period.
    add( iv_value = 7 ).

    DATA(ls_cost) = make_cost( iv_setup = 50 iv_unit = 1
                               iv_holding = 50 iv_max = 0 ).
    DATA(lt_lots) = mo_cut->size( it_demand = mt_dem
                                  is_cost   = ls_cost ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lots ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lots[ 1 ]-quantity exp = 7 ).
  ENDMETHOD.

ENDCLASS.
