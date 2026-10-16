CLASS ltcl_alloc_transport DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_transport.
    DATA mt_sup TYPE zcl_alloc_transport=>ty_supply_tt.
    DATA mt_dem TYPE zcl_alloc_transport=>ty_demand_tt.
    DATA mt_lan TYPE zcl_alloc_transport=>ty_lane_tt.

    METHODS setup.

    METHODS add_supply
      IMPORTING
        iv_id  TYPE string
        iv_qty TYPE menge_d.

    METHODS add_demand
      IMPORTING
        iv_id  TYPE string
        iv_qty TYPE menge_d.

    METHODS add_lane
      IMPORTING
        iv_from TYPE string
        iv_to   TYPE string
        iv_cost TYPE menge_d.

    METHODS no_lanes            FOR TESTING.
    METHODS uses_cheap_lane     FOR TESTING.
    METHODS splits_across_lanes FOR TESTING.
    METHODS reports_unshipped   FOR TESTING.
    METHODS missing_node_skipped FOR TESTING.
    METHODS zero_demand         FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_transport IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_transport( ).
  ENDMETHOD.

  METHOD add_supply.
    DATA ls_supply TYPE zcl_alloc_transport=>ty_supply.

    ls_supply-node_id = iv_id.
    ls_supply-supply = iv_qty.
    APPEND ls_supply TO mt_sup.
  ENDMETHOD.

  METHOD add_demand.
    DATA ls_demand TYPE zcl_alloc_transport=>ty_demand.

    ls_demand-node_id = iv_id.
    ls_demand-demand = iv_qty.
    APPEND ls_demand TO mt_dem.
  ENDMETHOD.

  METHOD add_lane.
    DATA ls_lane TYPE zcl_alloc_transport=>ty_lane.

    ls_lane-from_node = iv_from.
    ls_lane-to_node = iv_to.
    ls_lane-unit_cost = iv_cost.
    APPEND ls_lane TO mt_lan.
  ENDMETHOD.

  METHOD no_lanes.
    add_supply( iv_id = 'P1' iv_qty = 10 ).
    add_demand( iv_id = 'C1' iv_qty = 5 ).

    DATA(ls_result) = mo_cut->solve( it_supply = mt_sup
                                     it_demand = mt_dem
                                     it_lanes  = mt_lan ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-shipments ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-unshipped exp = 5 ).
  ENDMETHOD.

  METHOD uses_cheap_lane.
    add_supply( iv_id = 'P1' iv_qty = 10 ).
    add_supply( iv_id = 'P2' iv_qty = 10 ).
    add_demand( iv_id = 'C1' iv_qty = 4 ).
    add_lane( iv_from = 'P1' iv_to = 'C1' iv_cost = 9 ).
    add_lane( iv_from = 'P2' iv_to = 'C1' iv_cost = 2 ).

    DATA(ls_result) = mo_cut->solve( it_supply = mt_sup
                                     it_demand = mt_dem
                                     it_lanes  = mt_lan ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-shipments ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-shipments[ 1 ]-from_node exp = 'P2' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-total_cost exp = 8 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-unshipped exp = 0 ).
  ENDMETHOD.

  METHOD splits_across_lanes.
    add_supply( iv_id = 'P1' iv_qty = 3 ).
    add_supply( iv_id = 'P2' iv_qty = 10 ).
    add_demand( iv_id = 'C1' iv_qty = 5 ).
    add_lane( iv_from = 'P1' iv_to = 'C1' iv_cost = 1 ).
    add_lane( iv_from = 'P2' iv_to = 'C1' iv_cost = 2 ).

    DATA(ls_result) = mo_cut->solve( it_supply = mt_sup
                                     it_demand = mt_dem
                                     it_lanes  = mt_lan ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-shipments ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-shipments[ 1 ]-quantity exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-shipments[ 2 ]-quantity exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-total_cost exp = 7 ).
  ENDMETHOD.

  METHOD reports_unshipped.
    add_supply( iv_id = 'P1' iv_qty = 2 ).
    add_demand( iv_id = 'C1' iv_qty = 5 ).
    add_lane( iv_from = 'P1' iv_to = 'C1' iv_cost = 1 ).

    DATA(ls_result) = mo_cut->solve( it_supply = mt_sup
                                     it_demand = mt_dem
                                     it_lanes  = mt_lan ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-unshipped exp = 3 ).
  ENDMETHOD.

  METHOD missing_node_skipped.
    add_supply( iv_id = 'P1' iv_qty = 5 ).
    add_lane( iv_from = 'P1' iv_to = 'C1' iv_cost = 1 ).
    add_lane( iv_from = 'PX' iv_to = 'C1' iv_cost = 1 ).
    add_demand( iv_id = 'C1' iv_qty = 5 ).

    DATA(ls_result) = mo_cut->solve( it_supply = mt_sup
                                     it_demand = mt_dem
                                     it_lanes  = mt_lan ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-shipments ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-unshipped exp = 0 ).
  ENDMETHOD.

  METHOD zero_demand.
    add_supply( iv_id = 'P1' iv_qty = 5 ).
    add_demand( iv_id = 'C1' iv_qty = 0 ).
    add_lane( iv_from = 'P1' iv_to = 'C1' iv_cost = 1 ).

    DATA(ls_result) = mo_cut->solve( it_supply = mt_sup
                                     it_demand = mt_dem
                                     it_lanes  = mt_lan ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-shipments ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-unshipped exp = 0 ).
  ENDMETHOD.

ENDCLASS.
