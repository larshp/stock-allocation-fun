CLASS ltcl_alloc_swap_opt DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut  TYPE REF TO zcl_alloc_swap_opt.
    DATA mt_node TYPE zcl_alloc_swap_opt=>ty_nodes_tt.
    DATA mt_arc  TYPE zcl_alloc_swap_opt=>ty_arc_tt.

    METHODS setup.

    METHODS add_node
      IMPORTING
        iv_id TYPE string.

    METHODS add_arc
      IMPORTING
        iv_from TYPE string
        iv_to   TYPE string
        iv_cost TYPE menge_d.

    METHODS improves_order   FOR TESTING.
    METHODS already_optimal  FOR TESTING.
    METHODS single_node      FOR TESTING.
    METHODS empty_order      FOR TESTING.
    METHODS two_nodes        FOR TESTING.
    METHODS unknown_arc_free FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_swap_opt IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_swap_opt( ).
  ENDMETHOD.

  METHOD add_node.
    APPEND iv_id TO mt_node.
  ENDMETHOD.

  METHOD add_arc.
    DATA ls_arc TYPE zcl_alloc_swap_opt=>ty_arc.

    ls_arc-from_node = iv_from.
    ls_arc-to_node = iv_to.
    ls_arc-cost = iv_cost.
    APPEND ls_arc TO mt_arc.
  ENDMETHOD.

  METHOD improves_order.
    add_node( 'A' ).
    add_node( 'B' ).
    add_node( 'C' ).
    add_arc( iv_from = 'A' iv_to = 'B' iv_cost = 5 ).
    add_arc( iv_from = 'B' iv_to = 'C' iv_cost = 5 ).
    add_arc( iv_from = 'B' iv_to = 'A' iv_cost = 5 ).
    add_arc( iv_from = 'A' iv_to = 'C' iv_cost = 1 ).
    add_arc( iv_from = 'C' iv_to = 'A' iv_cost = 5 ).
    add_arc( iv_from = 'C' iv_to = 'B' iv_cost = 5 ).

    DATA(ls_result) = mo_cut->improve( it_nodes = mt_node
                                       it_arcs  = mt_arc ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-swaps exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-total_cost exp = 6 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-order[ 1 ] exp = 'B' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-order[ 2 ] exp = 'A' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-order[ 3 ] exp = 'C' ).
  ENDMETHOD.

  METHOD already_optimal.
    add_node( 'A' ).
    add_node( 'C' ).
    add_node( 'B' ).
    add_arc( iv_from = 'A' iv_to = 'C' iv_cost = 1 ).
    add_arc( iv_from = 'C' iv_to = 'B' iv_cost = 1 ).
    add_arc( iv_from = 'C' iv_to = 'A' iv_cost = 9 ).
    add_arc( iv_from = 'A' iv_to = 'B' iv_cost = 9 ).
    add_arc( iv_from = 'B' iv_to = 'C' iv_cost = 9 ).
    add_arc( iv_from = 'B' iv_to = 'A' iv_cost = 9 ).

    DATA(ls_result) = mo_cut->improve( it_nodes = mt_node
                                       it_arcs  = mt_arc ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-swaps exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-total_cost exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-order[ 1 ] exp = 'A' ).
  ENDMETHOD.

  METHOD single_node.
    add_node( 'A' ).

    DATA(ls_result) = mo_cut->improve( it_nodes = mt_node
                                       it_arcs  = mt_arc ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-total_cost exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-swaps exp = 0 ).
  ENDMETHOD.

  METHOD empty_order.
    DATA(ls_result) = mo_cut->improve( it_nodes = mt_node
                                       it_arcs  = mt_arc ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-order ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-total_cost exp = 0 ).
  ENDMETHOD.

  METHOD two_nodes.
    add_node( 'A' ).
    add_node( 'B' ).
    add_arc( iv_from = 'A' iv_to = 'B' iv_cost = 3 ).
    add_arc( iv_from = 'B' iv_to = 'A' iv_cost = 3 ).

    DATA(ls_result) = mo_cut->improve( it_nodes = mt_node
                                       it_arcs  = mt_arc ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-total_cost exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-swaps exp = 0 ).
  ENDMETHOD.

  METHOD unknown_arc_free.
    add_node( 'A' ).
    add_node( 'B' ).

    DATA(ls_result) = mo_cut->improve( it_nodes = mt_node
                                       it_arcs  = mt_arc ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-total_cost exp = 0 ).
  ENDMETHOD.

ENDCLASS.
