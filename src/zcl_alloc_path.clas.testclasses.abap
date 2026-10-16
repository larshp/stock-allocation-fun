CLASS ltcl_alloc_path DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_path.
    DATA mt_arc TYPE zcl_alloc_path=>ty_arc_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_from TYPE string
        iv_to   TYPE string
        iv_dist TYPE i.

    METHODS empty_arcs        FOR TESTING.
    METHODS same_node         FOR TESTING.
    METHODS single_hop        FOR TESTING.
    METHODS prefers_detour    FOR TESTING.
    METHODS unreachable       FOR TESTING.
    METHODS path_is_ordered   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_path IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_path( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_arc TYPE zcl_alloc_path=>ty_arc.

    ls_arc-from_node = iv_from.
    ls_arc-to_node = iv_to.
    ls_arc-distance = iv_dist.
    APPEND ls_arc TO mt_arc.
  ENDMETHOD.

  METHOD empty_arcs.
    DATA(ls_result) = mo_cut->shortest( it_arcs = mt_arc
                                        iv_from = 'A'
                                        iv_to   = 'B' ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-found exp = abap_false ).
  ENDMETHOD.

  METHOD same_node.
    DATA(ls_result) = mo_cut->shortest( it_arcs = mt_arc
                                        iv_from = 'A'
                                        iv_to   = 'A' ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-found exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-distance exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-hops exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-path[ 1 ] exp = 'A' ).
  ENDMETHOD.

  METHOD single_hop.
    add( iv_from = 'A' iv_to = 'B' iv_dist = 7 ).

    DATA(ls_result) = mo_cut->shortest( it_arcs = mt_arc
                                        iv_from = 'A'
                                        iv_to   = 'B' ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-found exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-distance exp = 7 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-hops exp = 1 ).
  ENDMETHOD.

  METHOD prefers_detour.
    add( iv_from = 'A' iv_to = 'B' iv_dist = 5 ).
    add( iv_from = 'B' iv_to = 'C' iv_dist = 3 ).
    add( iv_from = 'A' iv_to = 'C' iv_dist = 20 ).

    DATA(ls_result) = mo_cut->shortest( it_arcs = mt_arc
                                        iv_from = 'A'
                                        iv_to   = 'C' ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-found exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-distance exp = 8 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-hops exp = 2 ).
  ENDMETHOD.

  METHOD unreachable.
    add( iv_from = 'A' iv_to = 'B' iv_dist = 1 ).
    add( iv_from = 'X' iv_to = 'Y' iv_dist = 1 ).

    DATA(ls_result) = mo_cut->shortest( it_arcs = mt_arc
                                        iv_from = 'A'
                                        iv_to   = 'Y' ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-found exp = abap_false ).
  ENDMETHOD.

  METHOD path_is_ordered.
    add( iv_from = 'A' iv_to = 'B' iv_dist = 5 ).
    add( iv_from = 'B' iv_to = 'C' iv_dist = 3 ).
    add( iv_from = 'A' iv_to = 'C' iv_dist = 20 ).

    DATA(ls_result) = mo_cut->shortest( it_arcs = mt_arc
                                        iv_from = 'A'
                                        iv_to   = 'C' ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-path ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-path[ 1 ] exp = 'A' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-path[ 2 ] exp = 'B' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-path[ 3 ] exp = 'C' ).
  ENDMETHOD.

ENDCLASS.
