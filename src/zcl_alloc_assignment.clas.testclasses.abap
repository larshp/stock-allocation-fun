CLASS ltcl_alloc_assignment DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_assignment.
    DATA mt_dem TYPE zcl_alloc_assignment=>ty_ids_tt.
    DATA mt_par TYPE zcl_alloc_assignment=>ty_pair_tt.

    METHODS setup.

    METHODS add_demand
      IMPORTING
        iv_id TYPE string.

    METHODS add_pair
      IMPORTING
        iv_dem  TYPE string
        iv_src  TYPE string
        iv_cost TYPE menge_d.

    METHODS single_pair        FOR TESTING.
    METHODS cheapest_wins      FOR TESTING.
    METHODS source_used_once   FOR TESTING.
    METHODS unassigned_reported FOR TESTING.
    METHODS no_demands         FOR TESTING.
    METHODS no_pairs           FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_assignment IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_assignment( ).
  ENDMETHOD.

  METHOD add_demand.
    APPEND iv_id TO mt_dem.
  ENDMETHOD.

  METHOD add_pair.
    DATA ls_pair TYPE zcl_alloc_assignment=>ty_pair.

    ls_pair-demand_id = iv_dem.
    ls_pair-source_id = iv_src.
    ls_pair-cost = iv_cost.
    APPEND ls_pair TO mt_par.
  ENDMETHOD.

  METHOD single_pair.
    add_demand( 'D1' ).
    add_pair( iv_dem = 'D1' iv_src = 'S1' iv_cost = 5 ).

    DATA(lt_result) = mo_cut->solve( it_demands = mt_dem
                                     it_pairs   = mt_par ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_result ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-assigned exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-source_id exp = 'S1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-cost exp = 5 ).
  ENDMETHOD.

  METHOD cheapest_wins.
    add_demand( 'D1' ).
    add_pair( iv_dem = 'D1' iv_src = 'S1' iv_cost = 9 ).
    add_pair( iv_dem = 'D1' iv_src = 'S2' iv_cost = 2 ).

    DATA(lt_result) = mo_cut->solve( it_demands = mt_dem
                                     it_pairs   = mt_par ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-source_id exp = 'S2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-cost exp = 2 ).
  ENDMETHOD.

  METHOD source_used_once.
    add_demand( 'D1' ).
    add_demand( 'D2' ).
    add_pair( iv_dem = 'D1' iv_src = 'S1' iv_cost = 1 ).
    add_pair( iv_dem = 'D2' iv_src = 'S1' iv_cost = 2 ).
    add_pair( iv_dem = 'D2' iv_src = 'S2' iv_cost = 8 ).

    DATA(lt_result) = mo_cut->solve( it_demands = mt_dem
                                     it_pairs   = mt_par ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_result ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-source_id exp = 'S1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 2 ]-source_id exp = 'S2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 2 ]-assigned exp = abap_true ).
  ENDMETHOD.

  METHOD unassigned_reported.
    add_demand( 'D1' ).
    add_demand( 'D2' ).

    DATA(lt_result) = mo_cut->solve( it_demands = mt_dem
                                     it_pairs   = mt_par ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_result ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-assigned exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-demand_id exp = 'D1' ).
  ENDMETHOD.

  METHOD no_demands.
    add_pair( iv_dem = 'D1' iv_src = 'S1' iv_cost = 1 ).

    DATA(lt_result) = mo_cut->solve( it_demands = mt_dem
                                     it_pairs   = mt_par ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_result ) exp = 0 ).
  ENDMETHOD.

  METHOD no_pairs.
    add_demand( 'D1' ).

    DATA(lt_result) = mo_cut->solve( it_demands = mt_dem
                                     it_pairs   = mt_par ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_result ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-assigned exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
