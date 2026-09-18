CLASS ltcl_alloc_route DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_route.
    DATA mt_stp TYPE zcl_alloc_route=>ty_stop_tt.
    DATA mt_arc TYPE zcl_alloc_path=>ty_arc_tt.

    METHODS setup.

    METHODS add_stop
      IMPORTING
        iv_id  TYPE string
        iv_seq TYPE i.

    METHODS add_arc
      IMPORTING
        iv_from TYPE string
        iv_to   TYPE string
        iv_dist TYPE i.

    METHODS empty_stops      FOR TESTING.
    METHODS sorts_by_sequence FOR TESTING.
    METHODS sums_legs        FOR TESTING.
    METHODS single_stop      FOR TESTING.
    METHODS missing_arc_zero FOR TESTING.
    METHODS lookup_arc       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_route IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_route( ).
  ENDMETHOD.

  METHOD add_stop.
    DATA ls_stop TYPE zcl_alloc_route=>ty_stop.

    ls_stop-stop_id = iv_id.
    ls_stop-sequence = iv_seq.
    APPEND ls_stop TO mt_stp.
  ENDMETHOD.

  METHOD add_arc.
    DATA ls_arc TYPE zcl_alloc_path=>ty_arc.

    ls_arc-from_node = iv_from.
    ls_arc-to_node = iv_to.
    ls_arc-distance = iv_dist.
    APPEND ls_arc TO mt_arc.
  ENDMETHOD.

  METHOD empty_stops.
    DATA(ls_result) = mo_cut->build( it_stops = mt_stp
                                     it_arcs  = mt_arc ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-stops ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-distance exp = 0 ).
  ENDMETHOD.

  METHOD sorts_by_sequence.
    add_stop( iv_id = 'S2' iv_seq = 2 ).
    add_stop( iv_id = 'S1' iv_seq = 1 ).
    add_stop( iv_id = 'S3' iv_seq = 3 ).

    DATA(ls_result) = mo_cut->build( it_stops = mt_stp
                                     it_arcs  = mt_arc ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-stops[ 1 ]-stop_id exp = 'S1' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-stops[ 2 ]-stop_id exp = 'S2' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-stops[ 3 ]-stop_id exp = 'S3' ).
  ENDMETHOD.

  METHOD sums_legs.
    add_stop( iv_id = 'S1' iv_seq = 1 ).
    add_stop( iv_id = 'S2' iv_seq = 2 ).
    add_stop( iv_id = 'S3' iv_seq = 3 ).
    add_arc( iv_from = 'S1' iv_to = 'S2' iv_dist = 10 ).
    add_arc( iv_from = 'S2' iv_to = 'S3' iv_dist = 20 ).

    DATA(ls_result) = mo_cut->build( it_stops = mt_stp
                                     it_arcs  = mt_arc ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-distance exp = 30 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-legs exp = 2 ).
  ENDMETHOD.

  METHOD single_stop.
    add_stop( iv_id = 'ONLY' iv_seq = 1 ).

    DATA(ls_result) = mo_cut->build( it_stops = mt_stp
                                     it_arcs  = mt_arc ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-distance exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-legs exp = 0 ).
  ENDMETHOD.

  METHOD missing_arc_zero.
    add_stop( iv_id = 'S1' iv_seq = 1 ).
    add_stop( iv_id = 'S2' iv_seq = 2 ).
    add_arc( iv_from = 'S1' iv_to = 'S2' iv_dist = 10 ).

    DATA(ls_result) = mo_cut->build( it_stops = mt_stp
                                     it_arcs  = mt_arc ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-distance exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-legs exp = 1 ).
  ENDMETHOD.

  METHOD lookup_arc.
    add_arc( iv_from = 'A' iv_to = 'B' iv_dist = 42 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->distance_between( it_arcs = mt_arc
                                      iv_from = 'A'
                                      iv_to   = 'B' )
      exp = 42 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->distance_between( it_arcs = mt_arc
                                      iv_from = 'B'
                                      iv_to   = 'A' )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
